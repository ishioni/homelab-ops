resource "proxmox_virtual_environment_container" "unifi" {
  description = "Unifi controller managed by terraform"

  node_name    = "proxmox-4"
  vm_id        = 102
  unprivileged = true

  tags = ["ubuntu"]

  initialization {
    hostname = "unifi"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 2 * 1024
  }

  disk {
    datastore_id = "local-zfs"
    size         = 8
  }

  network_interface {
    bridge = "vmbr0"
    name   = "eth0"
  }

  operating_system {
    type             = "ubuntu"
    template_file_id = "ISO:/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
  }

  console {
    enabled   = true
    tty_count = 2
    type      = "console"
  }
}

# Import broken for lxc :()
