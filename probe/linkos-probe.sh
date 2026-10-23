#!/usr/bin/env bash
# LinkOS Status 大陆检测点：检测各项服务，把结果推送到 Gatus 的 external endpoints（见 gatus/external.yaml）。
# 由 linkos-probe.timer 每分钟运行一次。以下环境变量由 systemd 从 /etc/linkos-probe/env 读入：
#   GATUS_URL    Gatus 地址，如 https://uptime.linkos.org
#   PROBE_GROUP  本检测点在 Gatus 里的分组名，必须和 gatus/external.yaml 一致，如 Mainland China - Shanghai BGP
#                Gatus 不解码路径里的 key，所以分组名和名称只能用 ASCII 字母、数字、空格和 -
#   PROBE_TOKEN  推送令牌
# 每项最多检测 3 次：每次最长 20 秒（建连 10 秒），失败后隔 5 秒再试，3 次都失败才算失败，
# 这样跨境线路偶尔变慢、服务重启几秒都不会记成异常。各项并行检测，一轮最多约 75 秒。状态页只显示简短原因；
# 节点 IP、各阶段耗时和 curl 原始报错只写进本机日志（journalctl -u linkos-probe），不公开。
set -uo pipefail

# 名称|地址：名称要和 gatus/external.yaml 里的 name 一致
TARGETS=(
  "docker.linkos.org|https://docker.linkos.org/healthz"
  "gcr.linkos.org|https://gcr.linkos.org/healthz"
  "ghcr.linkos.org|https://ghcr.linkos.org/healthz"
  "k8s.linkos.org|https://k8s.linkos.org/healthz"
  "quay.linkos.org|https://quay.linkos.org/healthz"
  "linkos.org|https://linkos.org/"
)
SUMMARY="Reachability"

# 和 Gatus 的 key.ConvertGroupAndNameToKey 一致：转小写，空格 / _ , . # + & 换成 -
sanitize() {
  local s="${1,,}"
  s="${s//[\/_,.#+& ]/-}"
  printf '%s' "$s"
}

# 按字节做百分号编码，用于 URL 路径和查询参数
urlencode() {
  local LC_ALL=C s="$1" out="" c i
  for ((i = 0; i < ${#s}; i++)); do
    c="${s:i:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) out+="$c" ;;
      *) printf -v c '%%%02X' "'$c"; out+="$c" ;;
    esac
  done
  printf '%s' "$out"
}

# 推送也经过 CDN：结果先登记，最后用一个 curl 进程依次发出，复用同一条 TLS 连接，不必每项都握手一次。
names=()
urls=()

# push <名称> <true|false> <错误说明> <耗时毫秒>：只登记，send 时才发出
push() {
  local key
  key="$(urlencode "$(sanitize "$PROBE_GROUP")_$(sanitize "$1")")"
  names+=("$1")
  urls+=("$GATUS_URL/api/v1/endpoints/$key/external?success=$2&error=$(urlencode "$3")&duration=${4}ms")
}

# send：发出登记的结果，失败的再重试一次
send() {
  local try i n args codes again last=()
  local todo=("${!urls[@]}")
  for try in 1 2; do
    args=()
    for i in "${todo[@]}"; do args+=(-o /dev/null "${urls[i]}"); done
    # --fail-early：连不上 Gatus 时第一项就停，不让每一项都等到超时
    mapfile -t codes < <(curl -s --connect-timeout 5 -m 10 --fail-early -X POST \
      -H "Authorization: Bearer $PROBE_TOKEN" -w '%{http_code}\n' "${args[@]}")
    again=()
    n=0
    for i in "${todo[@]}"; do
      last[i]="${codes[n]:-000}"
      [ "${last[i]}" = 200 ] || again+=("$i")
      n=$((n + 1))
    done
    todo=("${again[@]}")
    [ ${#todo[@]} -eq 0 ] && return
  done
  for i in "${todo[@]}"; do echo "推送 ${names[i]} 失败：HTTP ${last[i]}" >&2; done
}

# check <地址>：HEAD 请求一次（只取状态码，不下载正文，省 CDN 流量），输出
# 「curl 退出码|状态码|解析|建连|TLS|总耗时|节点IP|错误信息」，耗时单位秒；用 | 分隔，连接没建立时节点 IP 为空也不会错位
check() {
  curl -s -I -o /dev/null --connect-timeout 10 -m 20 \
    -w '%{exitcode}|%{http_code}|%{time_namelookup}|%{time_connect}|%{time_appconnect}|%{time_total}|%{remote_ip}|%{errormsg}' "$1"
}

# reason <退出码> <状态码> <curl 错误信息>：推送到状态页的简短原因，不含节点和耗时
reason() {
  case "$1" in
    0) echo "HTTP $2" ;;
    6) echo "DNS 解析失败" ;;
    7) echo "连接失败" ;;
    28)
      # 超时卡在哪一步，看 curl 的报错
      case "$3" in
        "Connection timed out"*) echo "连接超时" ;;
        *SSL*) echo "TLS 握手超时" ;;
        *) echo "响应超时" ;;
      esac ;;
    35) echo "TLS 握手失败" ;;
    52 | 55 | 56) echo "连接中断" ;;
    60) echo "证书校验失败" ;;
    *) echo "请求失败（curl $1）" ;;
  esac
}

# probe <序号> <名称> <地址>：检测一项，最多 3 次，失败的细节写进日志；
# 最后一次的「状态码|总耗时|失败原因」写到 $tmp/<序号>，所有项检测完后再按 TARGETS 的顺序登记
probe() {
  local i="$1" name="$2" url="$3" attempt rc code t_dns t_conn t_tls t_total ip msg why=""
  for attempt in 1 2 3; do
    IFS='|' read -r rc code t_dns t_conn t_tls t_total ip msg <<< "$(check "$url")"
    [ "$code" = 200 ] && break
    why="$(reason "$rc" "$code" "$msg")"
    echo "$name 第 $attempt 次失败：$why；节点 ${ip:--}，解析 ${t_dns}s，建连 ${t_conn}s，TLS ${t_tls}s，总计 ${t_total}s；curl $rc ${msg}" >&2
    if [ "$attempt" -lt 3 ]; then sleep 5; fi
  done
  printf '%s|%s|%s\n' "$code" "$t_total" "$why" > "$tmp/$i"
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
for i in "${!TARGETS[@]}"; do
  probe "$i" "${TARGETS[i]%%|*}" "${TARGETS[i]#*|}" &
done
wait

failed=()
ok_ms=0   # 成功的检测耗时合计
all_ms=0  # 全部检测耗时合计
for i in "${!TARGETS[@]}"; do
  name="${TARGETS[i]%%|*}"
  code=000 t_total=0 why="检测没有完成"
  if [ -s "$tmp/$i" ]; then IFS='|' read -r code t_total why < "$tmp/$i"; fi
  ms=$(awk -v s="$t_total" 'BEGIN { printf "%d", s * 1000 }')
  all_ms=$((all_ms + ms))
  if [ "$code" = 200 ]; then
    ok_ms=$((ok_ms + ms))
    push "$name" true "" "$ms"
  else
    push "$name" false "$why" "$ms"
    failed+=("$name")
  fi
done

# 连通性：全部失败才算失败；部分失败仍算成功，失败的服务在各自那一行显示。
# 耗时：取成功检测的平均值；全部失败时取全部检测的平均值。
total=${#TARGETS[@]}
ok=$((total - ${#failed[@]}))
if [ "$ok" -gt 0 ]; then
  push "$SUMMARY" true "" $((ok_ms / ok))
else
  push "$SUMMARY" false "全部失败：${failed[*]}" $((all_ms / total))
fi
send
