terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "proxmox/state.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.57.1"
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
  endpoint = "https://proxmox.ishioni.casa"
  username = module.secret_pve.fields.username
  password = module.secret_pve.fields.password
  insecure = false
}

provider "unifi" {
  username = module.secret_unifi.fields.username
  password = module.secret_unifi.fields.password
  api_url  = "https://unifi.ishioni.casa"
}
