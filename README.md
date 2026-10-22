<p>
  <img alt="LinkOS Status" src="https://openlinkos.com/brand/linkos-status/github/readme.svg" height="56">
</p>

# LinkOS Status

[uptime.linkos.org](https://uptime.linkos.org) 显示 [LinkOS](https://linkos.org) 各项服务的实时状态。LinkOS 是 [OpenLinkOS](https://openlinkos.com) 运营的托管服务线。本仓库保存监控配置、大陆检测点脚本和事故记录。

LinkOS Status shows the live status of the LinkOS services, checked from overseas and from mainland China. This repository holds its configuration, the mainland probe and the incident reports.

## 怎么检测

```
浏览器 → uptime.linkos.org → LinkOS CDN → Gatus（洛杉矶的一台 VPS）
                                         ├─ 每分钟从海外检测各项服务
                                         ├─ 接收两个大陆检测点每分钟推送的结果
                                         └─ 故障时在本仓库开 issue，恢复后关闭
大陆检测点（腾讯云、物语云）→ 每分钟检测各项服务 → 推送到 Gatus
```

- 监控用 [Gatus](https://github.com/TwiN/gatus)，状态页由它自己提供，不依赖 GitHub，大陆也能正常打开。
- Gatus 所在的服务器和 CDN 节点，都不在被监控的镜像链路上：镜像出问题时，状态页仍然可以访问。
- 海外和大陆都失败，说明是服务本身的问题；只有大陆失败，说明是大陆到服务的线路或 CDN 的问题。

| 分组 | 检测内容 | 告警 |
| --- | --- | --- |
| 海外检测 | 五个镜像的 `/healthz`（缓存就绪才返回 200），linkos.org，openlinkos.com；证书剩余不到 7 天也算失败 | 每项单独开 issue |
| 拉取测试（海外） | 每个上游用 HEAD 请求一个固定镜像的 manifest（HEAD 不计入 Docker Hub 的拉取次数） | 不开 issue |
| 大陆检测（腾讯云）、大陆检测（物语云） | 五个镜像的 `/healthz` 和 linkos.org，外加汇总项「全部服务」；超过 5 分钟没有收到推送也算失败 | 每个检测点只用「全部服务」开 issue |

## 告警

告警就是本仓库的 [issue](https://github.com/openlinkos/uptime/issues)：连续 3 次失败时，Gatus 开一个标题以 `alert(gatus):` 开头的 issue；连续 2 次成功后自动关闭。关注本仓库就能收到通知。

## 修改检测项

- 配置在 [`gatus/`](gatus)：`config.yaml` 是界面、存储和告警，`endpoints.yaml` 是海外检测，`external.yaml` 是大陆检测点推送的检测项。
- 合入 `master` 后，服务器在 5 分钟内拉取新配置，Gatus 自动重载；写错的配置会被忽略，继续用上一份。
- 大陆检测点检测的地址写在 [`probe/linkos-probe.sh`](probe/linkos-probe.sh) 的 `TARGETS` 里，名称要和 `external.yaml` 一致；改了以后要更新到检测点上。

## 部署

**Gatus**（[`deploy/`](deploy)）：

```bash
git clone https://github.com/openlinkos/uptime.git /opt/linkos-status
install -d -m 700 /etc/linkos-status/certs /var/lib/linkos-status
# /etc/linkos-status/env：GITHUB_TOKEN=（只能读写本仓库 issue 的细粒度令牌）、PROBE_TOKEN=（随机字符串）
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 -nodes -days 3650 -subj /CN=uptime.linkos.org \
  -keyout /etc/linkos-status/certs/origin.key -out /etc/linkos-status/certs/origin.crt
docker compose -f /opt/linkos-status/deploy/compose.yaml up -d
cp /opt/linkos-status/deploy/linkos-status-sync.* /etc/systemd/system/ && systemctl enable --now linkos-status-sync.timer
```

CDN 把 `uptime.linkos.org` 回源到这台服务器的 `https://<地址>:18443`。

**大陆检测点**（[`probe/`](probe)）：

```bash
install -m 755 probe/linkos-probe.sh /usr/local/bin/linkos-probe
install -d -m 700 /etc/linkos-probe
# /etc/linkos-probe/env：GATUS_URL=https://uptime.linkos.org、PROBE_GROUP=大陆检测（腾讯云）、PROBE_TOKEN=
cp probe/linkos-probe.service probe/linkos-probe.timer /etc/systemd/system/ && systemctl enable --now linkos-probe.timer
```

## 历史数据

2023-12 到 2026-10 用的是 [Upptime](https://upptime.js.org)，它的数据原样保留在本仓库：[`history/`](history)（每次状态变化的提交记录）、[`api/`](api)、[`graphs/`](graphs)，以及那段时间的 issue。Upptime 靠 GitHub Actions 定时检测，实际间隔常常长达几个小时，只从海外检测，状态页的数据又从 GitHub 加载，大陆打不开，所以换成了现在的方式。

## 许可

配置和脚本以 [MIT License](LICENSE) 发布。LinkOS 与 OpenLinkOS 的名称和标志不在该许可范围内，见 [openlinkos.com/brand](https://openlinkos.com/brand)。
