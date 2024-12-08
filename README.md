<div align="center">


### My Kubernetes Lab cluster ⛵️

_... managed with Flux and Renovate_ :robot:

</div>

<br/>

<div align="center">

[![Talos](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.movishell.pl%2Ftalos_version&style=for-the-badge&logo=talos&logoColor=white&color=blue&label=%20)](https://talos.dev)&nbsp;&nbsp;
[![Kubernetes](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.movishell.pl%2Fkubernetes_version&style=for-the-badge&logo=kubernetes&logoColor=white&color=blue&label=%20)](https://kubernetes.io)&nbsp;&nbsp;
[![Renovate](https://img.shields.io/github/actions/workflow/status/ishioni/homelab-ops/renovate.yaml?branch=master&label=&logo=renovatebot&style=for-the-badge&color=blue)](https://github.com/ishioni/homelab-ops/actions/workflows/renovate.yaml)

</div>

<div align="center">

[![Age-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.movishell.pl%2Fcluster_age_days&style=flat-square&label=Age)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Uptime-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.movishell.pl%2Fcluster_uptime_days&style=flat-square&label=Uptime)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Node-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.movishell.pl%2Fcluster_node_count&style=flat-square&label=Nodes)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Pod-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.movishell.pl%2Fcluster_pod_count&style=flat-square&label=Pods)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![CPU-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.movishell.pl%2Fcluster_cpu_usage&style=flat-square&label=CPU)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Memory-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.movishell.pl%2Fcluster_memory_usage&style=flat-square&label=Memory)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;

</div>

---

## 📖 Overview

This is home to my personal Kubernetes lab cluster. [Flux](https://github.com/fluxcd/flux2) watches this Git repository and makes the changes to my cluster based on the manifests in the [kubernetes](./kubernetes/) directory. [Renovate](https://github.com/renovatebot/renovate) also watches this Git repository and creates pull requests when it finds updates to Docker images, Helm charts, and other dependencies.

---

## ⛵ Kubernetes

There is a template over at [onedr0p/flux-cluster-template](https://github.com/onedr0p/flux-cluster-template) if you wanted to try and follow along with some of the practices I use here.

### Installation

My cluster is [talos](https://talos.dev/) running on proxmox VMs. This is a semi hyper-converged cluster, workloads are sharing the same available resources on my nodes while I have a separate server for data storage.

🔸 _[Click here](./infrastructure/ansible/) to see my Ansible playbooks and roles._

### Core Components

- [cilium](https://cilium.io): Internal Kubernetes networking plugin
- [cert-manager](https://cert-manager.io/docs/): Creates SSL certificates for services in my Kubernetes cluster
- [external-dns](https://github.com/kubernetes-sigs/external-dns): Automatically manages DNS records from my cluster in a cloud DNS provider
- [external-secrets](https://github.com/external-secrets/external-secrets/): Managed Kubernetes secrets using [1Password Connect](https://github.com/1Password/connect)
- [ingress-nginx](https://github.com/kubernetes/ingress-nginx/): Ingress controller to expose HTTP traffic to pods over DNS
- [sops](https://toolkit.fluxcd.io/guides/mozilla-sops/): Managed secrets for Kubernetes, Ansible and Terraform which are commited to Git
- [Democratic CSI](https://github.com/democratic-csi/democratic-csi): Provides block and NFS storage provisioning
- [volsync](https://github.com/backube/volsync): Backup and recovery of persistent volume claims

### GitOps

[Flux](https://github.com/fluxcd/flux2) watches my [kubernetes](./kubernetes/) folder (see Directories below) and makes the changes to my cluster based on the YAML manifests.

[Renovate](https://github.com/renovatebot/renovate) watches my **entire** repository looking for dependency updates, when they are found a PR is automatically created. When some PRs are merged [Flux](https://github.com/fluxcd/flux2) applies the changes to my cluster.

### Directories

This Git repository contains the following directories under [kubernetes](./kubernetes/).

```sh
📁 kubernetes      # Kubernetes cluster defined as code
├── 📁 talos           # main cluster
│   ├─📁 apps          # applications
│   ├─📁 bootstrap     # bootstrap procedures
│   └─📁 flux          # core flux configuration
📁 truenas         # Truenas docker-compose
├── 📁 stacks          # applications
```

### Networking

| Name                               | CIDR             |
| ---------------------------------- | ---------------- |
| Network VLAN                       | `10.1.1.0/24`    |
| Servers VLAN                       | `10.1.2.0/24`    |
| Talos external services (BGP)      | `10.84.2.0/24`   |
| Kubernetes pods                    | `172.16.0.0/16`  |
| Kubernetes services                | `10.100.0.0/16`  |

---

## ☁️ Cloud Dependencies

While most of my infrastructure and workloads are selfhosted I do rely upon the cloud for certain key parts of my setup. This saves me from having to worry about two things. (1) Dealing with chicken/egg scenarios and (2) services I critically need whether my cluster is online or not.

The alternative solution to these two problems would be to host a Kubernetes cluster in the cloud and deploy applications like [HCVault](https://www.vaultproject.io/), [Vaultwarden](https://github.com/dani-garcia/vaultwarden), [ntfy](https://ntfy.sh/), and [Gatus](https://gatus.io/). However, maintaining another cluster and monitoring another group of workloads is a lot more time and effort than I am willing to put in and only saves me roughly $18/month.

| Service                                      | Use                                                            | Cost             |
| -------------------------------------------- | -------------------------------------------------------------- | ---------------- |
| [1Password](https://1password.com/)          | Secrets with [External Secrets](https://external-secrets.io/)  | 73Eur/yr         |
| [Cloudflare](https://www.cloudflare.com/)    | Domain, DNS and proxy management                               | Free             |
| [Fastmail](https://fastmail.com/)            | Email hosting                                                  | $75/yr           |
| [GitHub](https://github.com/)                | Hosting this repository and continuous integration/deployments | Free             |
|                                              |                                                                | Total: $12.75/mo |

---

## 🌐 DNS

### Home DNS

In my cluster there are two [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) instances deployed. One is deployed with the [ExternalDNS webhook provider for UniFi](https://github.com/kashalls/external-dns-unifi-webhook) which syncs DNS records to my UniFi router. The other ExternalDNS instance syncs DNS records to Cloudflare only when the ingresses and services have an ingress class name of `external` and contain an ingress annotation `external-dns.alpha.kubernetes.io/target`. All local clients on my network use my UniFi router as the upstream DNS server.

---

## 🔧 Hardware

| Device                     | Count | OS Disk Size | Data Disk Size          | Ram  | Operating System | Purpose             |
| -------------------------- | ----- | ------------ | ----------------------- | ---- | ---------------- | ------------------- |
| Unifi Cloud Gateway         | 1     | -            | -                       | -    |                  | Router              |
| Unifi USW-Enterprise-24-POE | 1     | -            | -                       | -    | -                | Network Switch      |
| Dell Optiplex 7040         | 4     | 512GB NVMe   | -                       | 64GB | Debian 12 (PVE)  | Virtualization Host |
| Cyberpower OR600ERM1U      | 1     | -            | -                       | -    | -                | UPS                 |
| QNAP TVS-682               | 1     | 2x256GB SATA | 2x512GB SSD + 4x12TB HDD| 32GB | TrueNAS Scale    | NAS                 |
| ESP32+Ebyte 72 POE adapter | 1     | -            | -                       | -    | ESPHome          | Zigbee adapter      |

---

## ⭐ Stargazers

<div align="center">

[![Star History Chart](https://api.star-history.com/svg?repos=ishioni/homelab-ops&type=Date)](https://star-history.com/#ishioni/homelab-ops&Date)

</div>

---

## 🤝 Gratitude and Thanks

Thanks to all the people who donate their time to the [Home Operations](https://discord.gg/home-operations) Discord community. A lot of inspiration for my cluster comes from the people that have shared their clusters using the [k8s-at-home](https://github.com/topics/k8s-at-home) GitHub topic. Be sure to check out the [kubesearch.dev](kubesearch.dev) for ideas on how to deploy applications or get ideas on what you can deploy.

---

## 📜 Changelog

See the _awful_ [commit history](https://github.com/ishioni/homelab-ops/commits/master)

---

## 🔏 License:

See [LICENSE](./LICENSE)
