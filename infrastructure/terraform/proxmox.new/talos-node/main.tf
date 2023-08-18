terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.29.0"
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
