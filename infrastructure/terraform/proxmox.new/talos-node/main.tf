terraform {
  backend "remote" {
    organization = "ishioni"
    workspaces {
      name = "talos"
    }
  }
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
    macaddress = {
      source = "ivoronin/macaddress"
    }
    unifi = {
      source = "paultyng/unifi"
    }
  }
}
