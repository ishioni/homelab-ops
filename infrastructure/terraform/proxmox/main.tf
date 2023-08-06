terraform {

  backend "remote" {
    organization = "ishioni"
    workspaces {
      name = "talos"
    }
  }

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
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
  item   = "proxmox"
}

module "secret_unifi" {
  # Remember to export OP_CONNECT_HOST and OP_CONNECT_TOKEN
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "unifi"
}

provider "proxmox" {
  pm_api_url          = module.secret_pve.fields.pm_api_url
  pm_api_token_id     = module.secret_pve.fields.pm_api_token_id
  pm_api_token_secret = module.secret_pve.fields.pm_api_token_secret
  pm_tls_insecure     = true
  # pm_parallel         = 2
}

provider "unifi" {
  username = module.secret_unifi.fields.username
  password = module.secret_unifi.fields.password
  api_url  = module.secret_unifi.fields.api_url
}
