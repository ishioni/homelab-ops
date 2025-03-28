resource "macaddress" "node" {
  prefix = [188, 36, 17]
}

resource "proxmox_virtual_environment_vm" "node" {
  name      = var.machine_name
  tags      = var.tags
  node_name = var.target_node
  vm_id     = var.vmid

  on_boot         = var.onboot
  started         = var.started
  tablet_device   = false
  timeout_stop_vm = var.timeout_stop_vm
  boot_order      = ["scsi0", "ide0"]

  operating_system {
    type = "l26"
  }

  agent {
    enabled = var.qemu_agent
    type    = "virtio"
    timeout = "10s"
  }

  bios = var.uefi ? "ovmf" : "seabios"
  efi_disk {
    datastore_id      = var.storage
    file_format       = var.file_format
    type              = "4m"
    pre_enrolled_keys = false
  }

  machine = "q35"

  cpu {
    architecture = "x86_64"
    cores        = var.cpu_cores
    type         = "host"
  }

  memory {
    dedicated = var.memory
    floating  = var.memory
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    cache        = "writethrough"
    datastore_id = var.storage
    discard      = "on"
    file_format  = var.file_format
    interface    = "scsi0"
    iothread     = true
    size         = var.storage_size
    ssd          = true
  }

  dynamic "disk" {
    for_each = var.secondary_disk ? [1] : []
    content {
      size         = var.secondary_disk_size
      datastore_id = var.storage
      interface    = "scsi1"
      discard      = "on"
      file_format  = var.file_format
      ssd          = true
      iothread     = false
      cache        = "writethrough"
    }
  }

  network_device {
    model       = "virtio"
    bridge      = var.bridge
    mac_address = upper(macaddress.node.address)
    vlan_id     = var.vlan_id
  }

  cdrom {
    file_id   = var.iso_path
    interface = "ide0"
  }

  vga {
    type   = "std"
    memory = 16
  }

  dynamic "hostpci" {
    for_each = var.gpu_gvtd ? [1] : []
    content {
      device  = "hostpci0"
      mapping = "i915"
      mdev    = "i915-GVTg_V5_4"
      rombar  = true
    }
  }
}
