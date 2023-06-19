module "controlplanes" {
  count        = 3
  machine_name = "talos-master-${count.index}"
  source       = "./proxmox-node"
  tags         = "talos,control-plane"
  target_node  = "proxmox-${count.index + 1}"
  iso_path     = var.proxmox_image
  cpu_cores    = 4
  memory       = 8 * 1024
  network_tag  = 4
  storage      = "local-zfs"
  storage_size = "20G"
  network_id   = data.unifi_network.kubernetes.id
  ip_address   = cidrhost("10.1.4.0/24", 20 + count.index)
}

module "workers" {
  count        = 3
  machine_name = "talos-worker-${count.index}"
  source       = "./proxmox-node"
  tags         = "talos,worker"
  target_node  = "proxmox-${count.index + 1}"
  iso_path     = var.proxmox_image
  cpu_cores    = 8
  memory       = 8 * 1024
  network_tag  = 4
  storage      = "local-zfs"
  storage_size = "40G"
  network_id   = data.unifi_network.kubernetes.id
  ip_address   = cidrhost("10.1.4.0/24", 30 + count.index)
}
