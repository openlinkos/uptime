<p>
  <img alt="LinkOS Status" src="https://openlinkos.com/brand/linkos-status/github/readme.svg" height="56">
</p>

# LinkOS Status

[uptime.linkos.org](https://uptime.linkos.org) 显示 [LinkOS](https://linkos.org) 各项服务的实时状态。LinkOS 是 [OpenLinkOS](https://openlinkos.com) 运营的托管服务线。本仓库保存监控配置、大陆检测点脚本和事故记录。

LinkOS Status shows the live status of the LinkOS services, checked from overseas and from mainland China. This repository holds its configuration, the mainland probe and the incident reports.

## 当前状态

徽标由 Gatus 实时生成。前 7 行是从洛杉矶检测的结果，后 2 行是大陆检测点的连通性；点击徽标打开对应的检测项。

| 服务 | 状态 | 7 天可用率 | 30 天可用率 |
| --- | --- | --- | --- |
| [docker.linkos.org](https://docker.linkos.org) | [![状态](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_docker-linkos-org/health/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_docker-linkos-org) | [![7 天可用率](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_docker-linkos-org/uptimes/7d/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_docker-linkos-org) | [![30 天可用率](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_docker-linkos-org/uptimes/30d/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_docker-linkos-org) |
| [gcr.linkos.org](https://gcr.linkos.org) | [![状态](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_gcr-linkos-org/health/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_gcr-linkos-org) | [![7 天可用率](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_gcr-linkos-org/uptimes/7d/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_gcr-linkos-org) | [![30 天可用率](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_gcr-linkos-org/uptimes/30d/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_gcr-linkos-org) |
| [ghcr.linkos.org](https://ghcr.linkos.org) | [![状态](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_ghcr-linkos-org/health/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_ghcr-linkos-org) | [![7 天可用率](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_ghcr-linkos-org/uptimes/7d/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_ghcr-linkos-org) | [![30 天可用率](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_ghcr-linkos-org/uptimes/30d/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_ghcr-linkos-org) |
| [k8s.linkos.org](https://k8s.linkos.org) | [![状态](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_k8s-linkos-org/health/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_k8s-linkos-org) | [![7 天可用率](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_k8s-linkos-org/uptimes/7d/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_k8s-linkos-org) | [![30 天可用率](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_k8s-linkos-org/uptimes/30d/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_k8s-linkos-org) |
| [quay.linkos.org](https://quay.linkos.org) | [![状态](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_quay-linkos-org/health/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_quay-linkos-org) | [![7 天可用率](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_quay-linkos-org/uptimes/7d/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_quay-linkos-org) | [![30 天可用率](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_quay-linkos-org/uptimes/30d/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_quay-linkos-org) |
| [linkos.org](https://linkos.org) | [![状态](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_linkos-org/health/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_linkos-org) | [![7 天可用率](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_linkos-org/uptimes/7d/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_linkos-org) | [![30 天可用率](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_linkos-org/uptimes/30d/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_linkos-org) |
| [openlinkos.com](https://openlinkos.com) | [![状态](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_openlinkos-com/health/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_openlinkos-com) | [![7 天可用率](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_openlinkos-com/uptimes/7d/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_openlinkos-com) | [![30 天可用率](https://uptime.linkos.org/api/v1/endpoints/overseas---los-angeles_openlinkos-com/uptimes/30d/badge.svg)](https://uptime.linkos.org/endpoints/overseas---los-angeles_openlinkos-com) |
| 大陆连通性：上海 BGP | [![状态](https://uptime.linkos.org/api/v1/endpoints/mainland-china---shanghai-bgp_reachability/health/badge.svg)](https://uptime.linkos.org/endpoints/mainland-china---shanghai-bgp_reachability) | [![7 天可用率](https://uptime.linkos.org/api/v1/endpoints/mainland-china---shanghai-bgp_reachability/uptimes/7d/badge.svg)](https://uptime.linkos.org/endpoints/mainland-china---shanghai-bgp_reachability) | [![30 天可用率](https://uptime.linkos.org/api/v1/endpoints/mainland-china---shanghai-bgp_reachability/uptimes/30d/badge.svg)](https://uptime.linkos.org/endpoints/mainland-china---shanghai-bgp_reachability) |
| 大陆连通性：浙江电信 | [![状态](https://uptime.linkos.org/api/v1/endpoints/mainland-china---zhejiang-telecom_reachability/health/badge.svg)](https://uptime.linkos.org/endpoints/mainland-china---zhejiang-telecom_reachability) | [![7 天可用率](https://uptime.linkos.org/api/v1/endpoints/mainland-china---zhejiang-telecom_reachability/uptimes/7d/badge.svg)](https://uptime.linkos.org/endpoints/mainland-china---zhejiang-telecom_reachability) | [![30 天可用率](https://uptime.linkos.org/api/v1/endpoints/mainland-china---zhejiang-telecom_reachability/uptimes/30d/badge.svg)](https://uptime.linkos.org/endpoints/mainland-china---zhejiang-telecom_reachability) |

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
- 大陆检测点检测的地址写在 [`probe/linkos-probe.sh`](probe/linkos-probe.sh) 的 `TARGETS` 里，名称要和 `external.yaml` 一致；合入后由维护者更新到各检测点。

## 历史数据

2023-12 到 2026-10 用的是 [Upptime](https://upptime.js.org)，它的数据原样保留在本仓库：[`history/`](history)（每次状态变化的提交记录）、[`api/`](api)、[`graphs/`](graphs)，以及那段时间的 issue。Upptime 靠 GitHub Actions 定时检测，实际间隔常常长达几个小时，只从海外检测，状态页的数据又从 GitHub 加载，大陆打不开，所以换成了现在的方式。

## 许可

配置和脚本以 [MIT License](LICENSE) 发布。LinkOS 与 OpenLinkOS 的名称和标志不在该许可范围内，见 [openlinkos.com/brand](https://openlinkos.com/brand)。
