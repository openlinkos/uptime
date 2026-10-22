#!/usr/bin/env bash
# LinkOS Status 大陆检测点：检测各项服务，把结果推送到 Gatus 的 external endpoints（见 gatus/external.yaml）。
# 由 linkos-probe.timer 每分钟运行一次。以下环境变量由 systemd 从 /etc/linkos-probe/env 读入：
#   GATUS_URL    Gatus 地址，如 https://uptime.linkos.org
#   PROBE_GROUP  本检测点在 Gatus 里的分组名，必须和 gatus/external.yaml 一致，如 Mainland China - Shanghai BGP
#                Gatus 不解码路径里的 key，所以分组名和名称只能用 ASCII 字母、数字、空格和 -
#   PROBE_TOKEN  推送令牌
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
    mapfile -t codes < <(curl -s -m 15 -X POST -H "Authorization: Bearer $PROBE_TOKEN" -w '%{http_code}\n' "${args[@]}")
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

failed=()
ok_ms=0   # 成功的检测耗时合计
all_ms=0  # 全部检测耗时合计
for t in "${TARGETS[@]}"; do
  name="${t%%|*}"
  url="${t#*|}"
  # HEAD：只取状态码，不下载正文，省 CDN 流量
  out=$(curl -s -I -o /dev/null -m 20 -w '%{http_code} %{time_total}' "$url")
  status="${out% *}"
  ms=$(awk -v s="${out#* }" 'BEGIN { printf "%d", s * 1000 }')
  all_ms=$((all_ms + ms))
  if [ "$status" = 200 ]; then
    ok_ms=$((ok_ms + ms))
    push "$name" true "" "$ms"
  else
    push "$name" false "HTTP $status" "$ms"
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
