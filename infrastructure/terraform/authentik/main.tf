terraform {

  backend "remote" {
    organization = "ishioni"
    workspaces {
      name = "authentik"
    }
  }

  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2023.6.0"
    }
  }
}

data "sops_file" "authentik_secrets" {
  source_file = "secret.sops.yaml"
}


module "secret_authentik" {
  # Remember to export OP_CONNECT_HOST and OP_CONNECT_TOKEN
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "authentik"
}

module "secret_immich" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "immich"
}
module "secret_grafana" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "grafana"
}

module "secret_proxmox" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "immich"
}
module "secret_nextcloud" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "immich"
}
module "secret_tandoor" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "immich"
}
provider "authentik" {
  url   = module.secret_authentik.fields["endpoint_url"]
  token = module.secret_authentik.fields["terraform_token"]
}
