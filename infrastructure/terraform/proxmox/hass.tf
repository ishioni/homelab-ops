data "unifi_network" "IoT" {
  name = "IoT"
}

resource "macaddress" "homeassistant" {
}

resource "proxmox_virtual_environment_vm" "homeassistant" {
  name          = "homeassistant"
  description   = "HASS OS managed by terraform"
  node_name     = "proxmox-3"
  vm_id         = 3001
  on_boot       = true
  started       = true
  tablet_device = false

  tags = ["iot"]

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
    type    = "virtio"
    trim    = true
  }

  bios = "ovmf"
  efi_disk {
    datastore_id = "local-zfs"
    file_format  = "raw"
    type         = "4m"
  }
  machine = "q35"

  cpu {
    architecture = "x86_64"
    cores        = 4
    type         = "host"
  }

  memory {
    dedicated = 4096
    floating  = 4096
  }

  network_device {
    bridge      = "vmbr0"
    enabled     = true
    model       = "virtio"
    mac_address = upper(macaddress.homeassistant.address)
    vlan_id     = data.unifi_network.IoT.vlan_id
  }

  vga {
    type   = "std"
    memory = 16
  }

  scsi_hardware = "virtio-scsi-pci"

  disk {
    datastore_id = "local-zfs"
    file_format  = "raw"
    discard      = "on"
    interface    = "scsi0"
    size         = 32
  }
  lifecycle {
    ignore_changes = []
  }
}
