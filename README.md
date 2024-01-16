<div align="center">

<img src="https://camo.githubusercontent.com/5b298bf6b0596795602bd771c5bddbb963e83e0f/68747470733a2f2f692e696d6775722e636f6d2f7031527a586a512e706e67" align="center" width="144px" height="144px"/>

### My Kubernetes Lab cluster ⛵️

_... managed with Flux and Renovate_ :robot:

</div>

<br/>

<div align="center">

[![Talos](https://img.shields.io/badge/v1.28-blue?style=for-the-badge&logo=kubernetes&logoColor=white)](https://talos.dev/)
[![Renovate](https://img.shields.io/github/actions/workflow/status/ishioni/homelab-ops/renovate.yaml?branch=master&label=&logo=renovatebot&style=for-the-badge&color=blue)](https://github.com/ishioni/homelab-ops/actions/workflows/renovate.yaml)

</div>

---

## 📖 Overview

This is home to my personal Kubernetes lab cluster. [Flux](https://github.com/fluxcd/flux2) watches this Git repository and makes the changes to my cluster based on the manifests in the [kubernetes](./kubernetes/) directory. [Renovate](https://github.com/renovatebot/renovate) also watches this Git repository and creates pull requests when it finds updates to Docker images, Helm charts, and other dependencies.

---

## ⛵ Kubernetes

There is a template over at [onedr0p/flux-cluster-template](https://github.com/onedr0p/flux-cluster-template) if you wanted to try and follow along with some of the practices I use here.

### Installation

My cluster is [talos](https://talos.dev/) running on proxmox VMs. This is a semi hyper-converged cluster, workloads are sharing the same available resources on my nodes while I have a separate server for data storage.

🔸 _[Click here](./ansible/) to see my Ansible playbooks and roles._

### Core Components

- [cilium](https://cilium.io): Internal Kubernetes networking plugin
- [cert-manager](https://cert-manager.io/docs/): Creates SSL certificates for services in my Kubernetes cluster
- [external-dns](https://github.com/kubernetes-sigs/external-dns): Automatically manages DNS records from my cluster in a cloud DNS provider
- [external-secrets](https://github.com/external-secrets/external-secrets/): Managed Kubernetes secrets using [1Password Connect](https://github.com/1Password/connect)
- [k8s-gateway](https://gateway-api.sigs.k8s.io/): Runs a separate internal-only DNS zone for some services
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
├── 📁 talos            # main cluster
│   ├─📁 apps          # applications
│   ├─📁 bootstrap     # bootstrap procedures
│   └─📁 flux           # core flux configuration
└── 📁 truenas     # Truenas k3s
    ├─📁 apps          # applications
    ├─📁 bootstrap     # bootstrap procedures
    └─📁 flux           # core flux configuration
```

### Networking

| Name                               | CIDR             |
| ---------------------------------- | ---------------- |
| Network VLAN                       | `10.1.1.0/24`    |
| Servers VLAN                       | `10.1.2.0/24`    |
| TrueNAS external services (BGP)    | `10.84.1.0/24`   |
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
| [Terraform Cloud](https://www.terraform.io/) | Storing Terraform state                                        | Free             |
|                                              |                                                                | Total: $12.75/mo |

---

## 🌐 DNS

### (Public) Ingress Controller

Over WAN, I have port forwarded ports `80` and `443` to the load balancer IP of my ingress controller that's running in my Kubernetes cluster. This is then managed by BGP to point to the right nodes.

### Split-horizon DNS

[dnsmasq](https://thekelleys.org.uk/dnsmasq/doc.html) is running on my `USG Pro 4` and all DNS queries for **internal** domains are forwarded to [k8s_gateway](https://github.com/ori-edge/k8s_gateway) that is running in my cluster. With this setup `k8s_gateway` has direct access to my clusters ingresses and services and serves DNS for them in my internal network.

### Ad Blocking

[AdGuard DNS](https://adguard-dns.io/en/welcome.html) is used as the primary DNS for the whole network as I don't have the means to reliably run an adblocker selfhosted without making the setup unstable

### External DNS

[external-dns](https://github.com/kubernetes-sigs/external-dns) is deployed in my cluster and configure to sync DNS records to [Cloudflare](https://www.cloudflare.com/). The only ingresses `external-dns` looks at to gather DNS records to put in `Cloudflare` are ones that I explicitly set an annotation of `external-dns.home.arpa/enabled: "true"`

🔸 _[Click here](./terraform/cloudflare) to see how else I manage Cloudflare with Terraform._

### Dynamic DNS

My home IP can change at any given time and in order to keep my WAN IP address up to date on Cloudflare. I have patched the vyatta part of unifi's vyos to work with cloudflare to make that work

---

## 🔧 Hardware

| Device                     | Count | OS Disk Size | Data Disk Size          | Ram  | Operating System | Purpose             |
| -------------------------- | ----- | ------------ | ----------------------- | ---- | ---------------- | ------------------- |
| Unifi USG4                 | 1     | 2G eMMC      | -                       | 4GB  | Debian 7         | Router              |
| Unifi USW-24-PoE           | 1     | -            | -                       | -    | -                | Network Switch      |
| Unifi USW-Aggregation      | 1     | -            | -                       |      | -                | Network Switch      |
| Dell Optiplex 7040         | 4     | 256GB NVMe   | -                       | 64GB | Debian 12 (PVE)  | Virtualization Host |
| Cyberpower OR600ERM1U      | 1     | -            | -                       | -    | -                | UPS                 |
| QNAP TVS-682               | 1     | 2x256GB SATA | 2x512GB SSD + 4x4TB HDD | 32GB | TrueNAS Scale    | NAS                 |
| Odroid C4                  | 1     | 32GB eMMC    | -                       | 4GB  | Ubuntu           | Misc services       |
| ESP32+Ebyte 72 POE adapter | 1     | -            | -                       | -    | ESPHome          | Zigbee adapter      |

---

## 🤝 Gratitude and Thanks

Thanks to all the people who donate their time to the [Home Operations](https://discord.gg/home-operations) Discord community. A lot of inspiration for my cluster comes from the people that have shared their clusters using the [k8s-at-home](https://github.com/topics/k8s-at-home) GitHub topic. Be sure to check out the [kubesearch.dev](kubesearch.dev) for ideas on how to deploy applications or get ideas on what you can deploy.

---

## 📜 Changelog

See the _awful_ [commit history](https://github.com/ishioni/homelab-ops/commits/master)

---

## 🔏 License

See [LICENSE](./LICENSE)
