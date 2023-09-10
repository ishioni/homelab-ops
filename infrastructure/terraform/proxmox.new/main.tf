terraform {

  backend "local" {}

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.31.0"
    }
    unifi = {
      source  = "paultyng/unifi"
      version = "0.41.0"
    }
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }
  }
}

module "secret_pve" {
  # Remember to export OP_CONNECT_HOST and OP_CONNECT_TOKEN
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "pve"
}

module "secret_unifi" {
  # Remember to export OP_CONNECT_HOST and OP_CONNECT_TOKEN
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "unifi"
}

provider "proxmox" {
  endpoint          = module.secret_pve.fields.pm_api_url
  username     = module.secret_pve.fields.username
  password = module.secret_pve.fields.password
  insecure     = false
}

provider "unifi" {
  username = module.secret_unifi.fields.username
  password = module.secret_unifi.fields.password
  api_url  = module.secret_unifi.fields.api_url
}
