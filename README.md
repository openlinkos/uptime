<p>
  <img alt="LinkOS Status" src="https://openlinkos.com/brand/linkos-status/github/readme.svg" height="56">
</p>

# LinkOS Status（已归档）

**2026-11-06 起，LinkOS 的服务状态由 [Beacon](https://github.com/openlinkos/beacon) 提供，本仓库归档，只读保留历史。**

- 免费公共服务（LinkOS Mirrors、linkos.org）：[status.linkos.org](https://status.linkos.org)
- LinkOS 的站点和开发基础设施：[status.linkos.io](https://status.linkos.io)

新状态页每分钟从美国和中国大陆的多个检测点检测。故障和处理进展发在状态页上，也可以订阅每页的 Atom 订阅源，例如 [status.linkos.org/feed.atom](https://status.linkos.org/feed.atom)；本仓库不再开 issue。uptime.linkos.org 和原来的徽标地址会自动跳到新状态页和对应组件的徽标。

As of 2026-11-06, LinkOS Status is served by [Beacon](https://github.com/openlinkos/beacon): [status.linkos.org](https://status.linkos.org) for the free public services, [status.linkos.io](https://status.linkos.io) for LinkOS's sites and development infrastructure. Each page has an Atom feed for incidents. This repository is archived; uptime.linkos.org and the old badges redirect to the new pages.

## 当前状态

徽标来自新状态页，点击打开所在的状态页。

| 服务 | 状态 |
| --- | --- |
| [docker.linkos.org](https://docker.linkos.org) | [![状态](https://status.linkos.org/components/docker/badge.svg)](https://status.linkos.org/) |
| [gcr.linkos.org](https://gcr.linkos.org) | [![状态](https://status.linkos.org/components/gcr/badge.svg)](https://status.linkos.org/) |
| [ghcr.linkos.org](https://ghcr.linkos.org) | [![状态](https://status.linkos.org/components/ghcr/badge.svg)](https://status.linkos.org/) |
| [k8s.linkos.org](https://k8s.linkos.org) | [![状态](https://status.linkos.org/components/k8s/badge.svg)](https://status.linkos.org/) |
| [quay.linkos.org](https://quay.linkos.org) | [![状态](https://status.linkos.org/components/quay/badge.svg)](https://status.linkos.org/) |
| [linkos.org](https://linkos.org) | [![状态](https://status.linkos.org/components/portal/badge.svg)](https://status.linkos.org/) |
| [linkos.io](https://linkos.io) | [![状态](https://status.linkos.io/components/linkos-io/badge.svg)](https://status.linkos.io/) |
| [openlinkos.com](https://openlinkos.com) | [![状态](https://status.linkos.io/components/openlinkos/badge.svg)](https://status.linkos.io/) |

## 历史

- [`gatus/`](gatus)、[`probe/`](probe)：2026-10 到 2026-11-06 使用 [Gatus](https://github.com/TwiN/gatus) 时的检测配置和大陆检测脚本，原样保留。
- [`history/`](history)、[`api/`](api)、[`graphs/`](graphs)：2023-12 到 2026-10 使用 [Upptime](https://upptime.js.org) 时的数据，原样保留。
- [issue](https://github.com/openlinkos/uptime/issues?q=is%3Aissue)：2023-12 到 2026-11 的故障记录。

## 许可

配置和脚本以 [MIT License](LICENSE) 发布。LinkOS 与 OpenLinkOS 的名称和标志不在该许可范围内，见 [openlinkos.com/brand](https://openlinkos.com/brand)。
