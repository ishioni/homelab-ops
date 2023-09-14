data "unifi_network" "IOT" {
  name = "IOT"
}

resource "macaddress" "homeassistant" {
}

resource "unifi_user" "homeassistant" {
  mac              = macaddress.homeassistant.address
  name             = "homeassistant"
  local_dns_record = "homeassistant"
  fixed_ip         = "10.1.3.2"
  network_id       = data.unifi_network.IOT.vlan_id
  dev_id_override  = 4589 #HA Cast icon
}

resource "time_sleep" "homeassistant" {
  create_duration = "120s"
  depends_on      = [unifi_user.homeassistant]
}

resource "proxmox_virtual_environment_vm" "homeassistant" {
  name          = "homeassistant"
  description   = "HASS OS managed by terraform"
  node_name     = "proxmox-4"
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
  }

  bios = "ovmf"
  efi_disk {
    datastore_id = "local-zfs"
    file_format  = "raw"
    type         = "4m"
  }
  machine = "q35"

  cpu {
    cores = 4
    type  = "host"
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
    vlan_id     = data.unifi_network.IOT.vlan_id
  }

  vga {
    enabled = true
  }

  scsi_hardware = "virtio-scsi-pci"

  disk {
    datastore_id = "local-zfs"
    file_format  = "raw"
    discard      = "on"
    interface    = "scsi0"
    size         = 32
  }
  depends_on = [time_sleep.homeassistant]
  lifecycle {
    ignore_changes = []
  }
}
