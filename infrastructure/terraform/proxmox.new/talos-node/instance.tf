resource "macaddress" "node" {
}

resource "unifi_user" "node" {
  mac              = macaddress.node.address
  name             = var.machine_name
  local_dns_record = var.machine_name
  fixed_ip         = var.ip_address
  network_id       = var.network_id
}

resource "time_sleep" "node" {
  create_duration = "120s"
  depends_on      = [unifi_user.node]
}

resource "proxmox_virtual_environment_vm" "node" {
  name = var.machine_name
  tags = var.tags
  node_name = var.target_node
  vm_id = var.vmid

  on_boot = var.onboot
  started = var.oncreate
  tablet_device = false
  timeout_stop_vm = var.timeout_stop_vm

  operating_system {
    type = "l26"
  }

  agent {
    enabled = var.qemu_agent
    type = "virtio"
    timeout = "10s"
  }

  bios = "ovmf"
  efi_disk {
    datastore_id = var.storage
    file_format = var.file_format
    type = "4m"
    pre_enrolled_keys = false
  }

  machine = "q35"

  cpu {
    architecture = "x86_64"
    cores = var.cpu_cores
    type = "host"
  }

  memory {
    dedicated = var.memory
    floating = var.memory
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    cache = "writethrough"
    datastore_id = var.storage
    discard = "on"
    file_format = var.file_format
    interface = "scsi0"
    iothread = true
    size = var.storage_size
    ssd = true
  }

  network_device {
    model = "virtio"
    bridge = var.bridge
    mac_address = upper(macaddress.node.address)
    vlan_id = var.vlan_id
  }

  cdrom {
    enabled = true
    file_id = var.iso_path
    interface = "ide0"
  }
  depends_on = [time_sleep.node]
}

# resource "proxmox_vm_qemu" "node" {
#   name        = var.machine_name
#   tags        = var.tags
#   vmid        = var.vmid
#   target_node = var.target_node
#   iso         = var.iso_path
#   qemu_os     = "l26"
#   agent       = var.qemu_agent

#   oncreate = var.oncreate
#   onboot   = var.onboot
#   startup  = var.startup

#   cpu     = "host"
#   sockets = 1
#   cores   = var.cpu_cores
#   memory  = var.memory
#   scsihw  = "virtio-scsi-single"

#   network {
#     model    = "virtio"
#     bridge   = "vmbr0"
#     tag      = var.network_tag
#     firewall = false
#     macaddr  = macaddress.node.address
#   }

#   boot = "order=scsi0;ide2"
#   disk {
#     type    = "scsi"
#     storage = var.storage
#     size    = var.storage_size
#     cache   = "writethrough"
#     ssd     = 1
#     backup  = true
#   }

#   lifecycle {
#     ignore_changes = [
#       desc,
#       numa,
#       agent
#     ]
#   }
#   depends_on = [time_sleep.node]
# }
