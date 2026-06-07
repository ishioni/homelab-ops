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
      version = "2026.2.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.3.1"
    }
  }
}

module "secret_authentik" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "authentik"
}

module "secret_bookboss" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "bookboss"
}

module "secret_immich" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "immich"
}

module "secret_grafana" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "grafana"
}

module "secret_paperless" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "paperless"
}

module "secret_vaultwarden" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "vaultwarden"
}

module "secret_fluxcd" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "flux"
}

module "secret_meshmonitor" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "meshmonitor"
}

module "secret_toolhive" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "toolhive"
}

provider "authentik" {
  url   = module.secret_authentik.fields["ENDPOINT_URL"]
  token = module.secret_authentik.fields["TERRAFORM_TOKEN"]
}
