terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }
    unifi = {
      source  = "paultyng/unifi"
      version = "0.41.0"
    }
  }
}
