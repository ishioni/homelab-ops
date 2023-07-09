terraform {

  backend "remote" {
    organization = "ishioni"
    workspaces {
      name = "talos"
    }
  }

  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }
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

data "sops_file" "proxmox_secrets" {
  source_file = "secrets.sops.yaml"
}

provider "proxmox" {
  pm_api_url          = data.sops_file.proxmox_secrets.data["pm_api_url"]
  pm_api_token_id     = data.sops_file.proxmox_secrets.data["pm_api_token_id"]
  pm_api_token_secret = data.sops_file.proxmox_secrets.data["pm_api_token_secret"]
  pm_tls_insecure     = true
  # pm_parallel         = 2
}

provider "unifi" {
  username = data.sops_file.proxmox_secrets.data["unifi_username"]
  password = data.sops_file.proxmox_secrets.data["unifi_password"]
  api_url  = data.sops_file.proxmox_secrets.data["unifi_url"]
}
