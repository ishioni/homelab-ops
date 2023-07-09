module "controlplanes" {
  count        = 3
  machine_name = "talos-master-${count.index}"
  vmid         = sum([1000, count.index])
  source       = "./proxmox-node"
  tags         = "control-plane;talos"
  target_node  = "proxmox-${count.index + 1}"
  iso_path     = var.proxmox_image
  startup      = "down=300"
  cpu_cores    = 4
  memory       = 4 * 1024
  network_tag  = 4
  storage      = "local-zfs"
  storage_size = "20G"
  network_id   = data.unifi_network.kubernetes.id
  ip_address   = cidrhost("10.1.4.0/24", 20 + count.index)
}

module "workers" {
  count        = 3
  machine_name = "talos-worker-${count.index}"
  vmid         = sum([2000, count.index])
  source       = "./proxmox-node"
  tags         = "talos;worker"
  target_node  = "proxmox-${count.index + 1}"
  iso_path     = var.proxmox_image
  startup      = "down=600"
  cpu_cores    = 8
  memory       = 24 * 1024
  network_tag  = 4
  storage      = "local-zfs"
  storage_size = "40G"
  network_id   = data.unifi_network.kubernetes.id
  ip_address   = cidrhost("10.1.4.0/24", 30 + count.index)
}
