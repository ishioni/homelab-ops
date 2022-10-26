terraform {

  backend "remote" {
    organization = "ishioni"
    workspaces {
      name = "proxmox"
    }
  }

  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.11"
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
