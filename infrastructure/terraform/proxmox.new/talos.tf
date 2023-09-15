data "unifi_network" "kubernetes" {
  name = "Kubernetes"
}

module "controlplanes" {
  source          = "./talos-node"
  oncreate        = false
  count           = 1
  machine_name    = "master-${count.index}"
  vmid            = sum([4000, count.index])
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

# module "workers" {
#   count        = 3
#   machine_name = "talos-worker-${count.index}"
#   vmid         = sum([2000, count.index])
#   source       = "./proxmox-node"
#   tags         = "talos;worker"
#   target_node  = "proxmox-${count.index + 1}"
#   iso_path     = var.proxmox_image
#   startup      = "down=600"
#   qemu_agent   = 1
#   cpu_cores    = 8
  # memory       = 24 * 1024
  # gpu_gvtd     = true
#   network_tag  = 4
#   storage      = "local-zfs"
#   storage_size = "40G"
#   network_id   = data.unifi_network.kubernetes.id
#   ip_address   = cidrhost("10.1.4.0/24", 30 + count.index)
# }
