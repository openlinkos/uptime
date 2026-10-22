#!/usr/bin/env bash
# 把大陆检测点（脚本和 systemd 单元）部署或更新到一台或多台机器上，运行一轮并检查结果。
# 在本机的仓库克隆里运行，只部署已经推送到 GitHub master 的版本：
#   probe/deploy.sh <ssh 目标>...
# ssh 目标是 ssh 能直接连上的名字，如 ~/.ssh/config 里的 Host 别名；需要目标上的 root 权限。
# 机器清单不放在这个公开仓库里。
# 首次部署时目标上还没有 /etc/linkos-probe/env，要给出分组名，一次只部署一台；令牌从一台已有的检测点读取：
#   TOKEN_FROM=<已有检测点> PROBE_GROUP="Mainland China - Shanghai BGP" probe/deploy.sh <ssh 目标>
# 也可以把令牌放在环境变量 PROBE_TOKEN 里（例如从密码管理器读出），但不要直接写在命令行上，会留在 shell 历史里。
# 令牌放在 ssh 传输的数据里，不出现在任何一台机器的命令行上。
# 大陆访问 GitHub 不稳定，所以由本机推送过去，而不是让检测点自己拉取。
set -euo pipefail

if [ $# -eq 0 ]; then
  sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
fi

cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
# 只部署 GitHub 上看得到的版本：本地 HEAD 必须等于 origin/master，probe/ 不能有未提交的改动
git fetch -q origin master
rev=$(git rev-parse --short HEAD)
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/master)" ] ||
  { echo "本地 HEAD（$rev）和 GitHub 上的 master 不一致：先推送或 git pull" >&2; exit 1; }
git diff --quiet HEAD -- probe/ || { echo "probe/ 有未提交的改动：先提交并推送" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
# 关掉换行转换：Windows 上的克隆也要导出 LF 换行的脚本
git -c core.autocrlf=false archive HEAD probe/linkos-probe.sh probe/linkos-probe.service probe/linkos-probe.timer |
  tar -xf - -C "$tmp"

if [ -n "${PROBE_GROUP:-}" ]; then
  [ $# -eq 1 ] || { echo "首次部署一次只能给一台机器：每台的分组名不同" >&2; exit 2; }
  if [ -z "${PROBE_TOKEN:-}" ] && [ -n "${TOKEN_FROM:-}" ]; then
    PROBE_TOKEN=$(ssh -o BatchMode=yes -o ConnectTimeout=15 "$TOKEN_FROM" "sed -n 's/^PROBE_TOKEN=//p' /etc/linkos-probe/env")
  fi
  [ -n "${PROBE_TOKEN:-}" ] ||
    { echo "首次部署要有令牌：TOKEN_FROM=<已有检测点>，或环境变量 PROBE_TOKEN" >&2; exit 2; }
  (umask 077 && printf 'GATUS_URL=%s\nPROBE_GROUP=%s\nPROBE_TOKEN=%s\n' \
    "${GATUS_URL:-https://uptime.linkos.org}" "$PROBE_GROUP" "$PROBE_TOKEN" > "$tmp/probe/env")
fi

# 在目标机器上执行：只更新有变化的文件，启用定时器，手动跑一轮，报告结果
cat > "$tmp/probe/install.sh" <<'EOF'
set -euo pipefail
src="$1"
changed=""
put() { # put <文件> <安装到> <权限>
  if ! cmp -s "$src/$1" "$2"; then
    install -m "$3" "$src/$1" "$2"
    changed+=" $(basename "$2")"
  fi
}
put linkos-probe.sh /usr/local/bin/linkos-probe 755
put linkos-probe.service /etc/systemd/system/linkos-probe.service 644
put linkos-probe.timer /etc/systemd/system/linkos-probe.timer 644
if [ -f "$src/env" ]; then
  install -d -m 700 /etc/linkos-probe
  put env /etc/linkos-probe/env 600
fi
[ -f /etc/linkos-probe/env ] || { echo "缺少 /etc/linkos-probe/env：首次部署要给出 PROBE_GROUP 和 PROBE_TOKEN" >&2; exit 1; }

systemctl daemon-reload
systemctl enable --now linkos-probe.timer 2>/dev/null
since=$(date '+%Y-%m-%d %H:%M:%S')
systemctl start linkos-probe.service || true # oneshot：等这一轮跑完；失败时下面会报告
result=$(systemctl show linkos-probe.service -p Result --value)
failed=$(journalctl -u linkos-probe.service --since "$since" -o cat --no-pager | grep -c '^推送 .* 失败' || true)
group=$(sed -n 's/^PROBE_GROUP=//p' /etc/linkos-probe/env)
echo "$(hostname)：更新${changed:- 无}；分组 $group；本轮 $result，推送失败 $failed 项"
[ "$result" = success ] && [ "$failed" = 0 ]
EOF

status=0
for target in "$@"; do
  echo "== $target"
  tar -cf - -C "$tmp" probe |
    ssh -o BatchMode=yes -o ConnectTimeout=15 "$target" \
      'd=$(mktemp -d) && tar --no-same-owner -xf - -C "$d" && bash "$d/probe/install.sh" "$d/probe"; rc=$?; rm -rf "$d"; exit $rc' ||
    status=1
done
echo "版本 $rev"
exit $status
