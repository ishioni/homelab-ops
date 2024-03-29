data "unifi_network" "Servers" {
  name = "Servers"
}

module "talos-controlplanes" {
  source          = "./talos-node"
  oncreate        = false
  count           = 3
  machine_name    = "master-${count.index}"
  vmid            = sum([2030, count.index])
  target_node     = "proxmox-${count.index + 1}"
  iso_path        = "ISO:iso/talos-v1.6.1-cp.iso"
  timeout_stop_vm = 300
  qemu_agent      = true
  cpu_cores       = 4
  memory          = 4 * 1024
  vlan_id         = data.unifi_network.Servers.vlan_id
  storage         = "local-zfs"
  storage_size    = 20
}

output "cp-macaddresses" {
  value = module.talos-controlplanes[*].macaddr
}

module "talos-workers" {
  source          = "./talos-node"
  oncreate        = false
  count           = 3
  machine_name    = "worker-${count.index}"
  vmid            = sum([2040, count.index])
  target_node     = "proxmox-${count.index + 1}"
  iso_path        = "ISO:iso/talos-v1.6.1-worker.iso"
  timeout_stop_vm = 300
  qemu_agent      = true
  uefi             = false #gvtd doesn't play nice with UEFI
  cpu_cores       = 8
  memory          = 24 * 1024
  gpu_gvtd        = true
  vlan_id         = data.unifi_network.Servers.vlan_id
  storage         = "local-zfs"
  storage_size    = 40
}

output "workers-macaddresses" {
  value = module.talos-workers[*].macaddr
}
