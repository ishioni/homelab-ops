data "unifi_network" "kubernetes" {
  name = "Kubernetes"
}

module "controlplanes" {
  source          = "./talos-node"
  oncreate        = true
  count           = 3
  machine_name    = "master-${count.index}"
  vmid            = sum([4010, count.index])
  target_node     = "proxmox-${count.index + 1}"
  iso_path        = var.talos_image
  timeout_stop_vm = 300
  qemu_agent      = true
  cpu_cores       = 4
  memory          = 4 * 1024
  vlan_id         = data.unifi_network.kubernetes.vlan_id
  storage         = "local-zfs"
  storage_size    = 20
  network_id      = data.unifi_network.kubernetes.id
  ip_address      = cidrhost("10.1.4.0/24", 10 + count.index)
}

module "workers" {
  source          = "./talos-node"
  oncreate        = true
  count           = 1
  machine_name    = "worker-${count.index}"
  vmid            = sum([4020, count.index])
  target_node     = "proxmox-${count.index + 1}"
  iso_path        = var.talos_image
  timeout_stop_vm = 300
  qemu_agent      = true
  uefi             = false #gvtd doesn't play nice with UEFI
  cpu_cores       = 8
  memory          = 24 * 1024
  gpu_gvtd        = true
  vlan_id         = data.unifi_network.kubernetes.vlan_id
  storage         = "local-zfs"
  storage_size    = 40
  network_id      = data.unifi_network.kubernetes.id
  ip_address      = cidrhost("10.1.4.0/24", 20 + count.index)
}
