terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "authentik/state.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.10.0"
    }
  }
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
  item   = "pve"
}

module "secret_nextcloud" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "nextcloud"
}

module "secret_tandoor" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "tandoor"
}

module "secret_audiobookshelf" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "audiobookshelf"
}

module "secret_paperless" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "paperless"
}

module "secret_romm" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "romm"
}

module "secret_ocis" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "ocis"
}

module "secret_vaultwarden" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "vaultwarden"
}

provider "authentik" {
  url   = module.secret_authentik.fields["ENDPOINT_URL"]
  token = module.secret_authentik.fields["TERRAFORM_TOKEN"]
}
