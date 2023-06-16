resource "macaddress" "node" {
}

resource "unifi_user" "node" {
  mac        = macaddress.node.address
  name       = var.machine_name
  fixed_ip   = var.ip_address
  network_id = var.network_id
}

resource "time_sleep" "node" {
  create_duration = "120s"
  depends_on      = [unifi_user.node]
}

resource "proxmox_vm_qemu" "node" {
  name        = var.machine_name
  tags        = var.tags
  target_node = var.target_node
  iso         = var.iso_path
  qemu_os     = "l26"

  oncreate = var.oncreate
  onboot   = var.onboot

  cpu     = "host"
  sockets = 1
  cores   = var.cpu_cores
  memory  = var.memory
  scsihw  = "virtio-scsi-single"

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    tag      = var.network_tag
    firewall = false
    macaddr  = macaddress.node.address
  }

  boot = "order=scsi0;ide2"
  disk {
    type    = "scsi"
    storage = var.storage
    size    = var.storage_size
    cache   = "writethrough"
    ssd     = 1
    backup  = true
  }

  lifecycle {
    ignore_changes = [
      desc,
      numa,
      agent
    ]
  }
  depends_on = [time_sleep.node]
}
