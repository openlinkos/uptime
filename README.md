<p>
  <img alt="LinkOS Status" src="https://openlinkos.com/brand/linkos-status/github/readme.svg" height="56">
</p>

# LinkOS Status

[uptime.linkos.org](https://uptime.linkos.org) 显示 [LinkOS](https://linkos.org) 各项服务的实时状态。LinkOS 是 [OpenLinkOS](https://openlinkos.com) 运营的托管服务线。本仓库保存监控配置、大陆检测点脚本和事故记录。

LinkOS Status shows the live status of the LinkOS services, checked from overseas and from mainland China. This repository holds its configuration, the mainland probe and the incident reports.

## 怎么检测

```
浏览器 → uptime.linkos.org → LinkOS CDN → Gatus（洛杉矶的一台服务器）
                                         ├─ 每分钟从洛杉矶检测各项服务
                                         ├─ 接收两个大陆检测点每分钟推送的结果
                                         └─ 故障时在本仓库开 issue，恢复后关闭
大陆检测点（上海 BGP、浙江电信）→ 每分钟检测各项服务 → 推送到 Gatus
```

- 监控用 [Gatus](https://github.com/TwiN/gatus)，状态页由它自己提供，不依赖 GitHub，大陆也能正常打开。
- Gatus 和镜像服务是各自独立的程序，状态页走的 CDN 线路也和镜像不同：镜像服务出问题时，状态页仍然可以访问。
- 海外和大陆都失败，说明是服务本身的问题；只有大陆失败，说明是大陆到服务的线路或 CDN 的问题。
- 检测都经过 CDN，而 CDN 节点的流量有限，所以只用 HEAD 请求取状态码，不下载正文，也不做拉取测试。
- 大陆检测点每项失败后隔 2 秒重试一次，两次都失败才算失败，偶发的跨境丢包不会显示成故障。状态页只显示简短原因（如「连接超时」），连的哪个节点、各阶段耗时只记在检测点本机的日志里。

| 分组 | 检测内容 | 告警 |
| --- | --- | --- |
| Overseas - Los Angeles | 五个镜像的 `/healthz`（缓存就绪才返回 200），linkos.org，openlinkos.com；证书剩余不到 7 天也算失败 | 每项单独开 issue |
| Mainland China - Shanghai BGP、Mainland China - Zhejiang Telecom | 五个镜像的 `/healthz` 和 linkos.org，外加连通性 Reachability（全部检测都失败才算失败，耗时是平均值）；超过 5 分钟没有收到推送也算失败 | 每个检测点只用 Reachability 开 issue：线路断了才告警，单个服务的故障由洛杉矶那组告警 |

## 告警

告警就是本仓库的 [issue](https://github.com/openlinkos/uptime/issues)：连续 3 次失败时，Gatus 开一个标题以 `alert(gatus):` 开头的 issue；连续 2 次成功后自动关闭。关注本仓库就能收到通知。

## 修改检测项

- 配置在 [`gatus/`](gatus)：`config.yaml` 是界面、存储和告警，`endpoints.yaml` 是洛杉矶的检测项，`external.yaml` 是大陆检测点推送的检测项。
- 合入 `master` 后，服务器在 5 分钟内拉取新配置，Gatus 自动重载；写错的配置会被忽略，继续用上一份。
- 大陆检测点检测的地址写在 [`probe/linkos-probe.sh`](probe/linkos-probe.sh) 的 `TARGETS` 里，名称要和 `external.yaml` 一致；合入后用 `probe/deploy.sh` 更新到各检测点。

## 部署

**Gatus**（[`deploy/`](deploy)）：

```bash
git clone https://github.com/openlinkos/uptime.git /data/project/linkos-status
echo LINKOS_STATUS_PORT=<端口> > /data/project/linkos-status/deploy/.env   # 宿主机端口，按服务器的端口规划分配
install -d -m 700 /etc/linkos-status/certs /var/lib/linkos-status
# /etc/linkos-status/env：GITHUB_TOKEN=（只能读写本仓库 issue 的细粒度令牌）、PROBE_TOKEN=（随机字符串）
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 -nodes -days 3650 -subj /CN=uptime.linkos.org \
  -keyout /etc/linkos-status/certs/origin.key -out /etc/linkos-status/certs/origin.crt
docker compose -f /data/project/linkos-status/deploy/compose.yaml up -d
cp /data/project/linkos-status/deploy/linkos-status-sync.* /etc/systemd/system/ && systemctl enable --now linkos-status-sync.timer
```

CDN 把 `uptime.linkos.org` 回源到这台服务器的 `https://<地址>:<端口>`。

**大陆检测点**（[`probe/`](probe)）：

检测点要放在直连公网的服务器上。经过代理出口的机器测到的是代理线路，不能代表大陆用户的访问情况。

大陆访问 GitHub 不稳定，检测点不自己拉取，而是在本机的仓库克隆里用 [`probe/deploy.sh`](probe/deploy.sh) 推送过去。它部署当前提交里的版本，只更新有变化的文件，然后运行一轮，检查本轮成功、推送没有失败：

```bash
probe/deploy.sh <ssh 目标>...                       # 更新已有的检测点
PROBE_GROUP="Mainland China - Shanghai BGP" PROBE_TOKEN=... probe/deploy.sh <ssh 目标>   # 首次部署，一次一台
```

分组名要先加进 `gatus/external.yaml`，合入并等 Gatus 重载后再部署，否则推送会返回 404。

## 历史数据

2023-12 到 2026-10 用的是 [Upptime](https://upptime.js.org)，它的数据原样保留在本仓库：[`history/`](history)（每次状态变化的提交记录）、[`api/`](api)、[`graphs/`](graphs)，以及那段时间的 issue。Upptime 靠 GitHub Actions 定时检测，实际间隔常常长达几个小时，只从海外检测，状态页的数据又从 GitHub 加载，大陆打不开，所以换成了现在的方式。

## 许可

配置和脚本以 [MIT License](LICENSE) 发布。LinkOS 与 OpenLinkOS 的名称和标志不在该许可范围内，见 [openlinkos.com/brand](https://openlinkos.com/brand)。
