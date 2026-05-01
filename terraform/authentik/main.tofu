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
      version = "2025.12.1"
    }
    onepassword = {
      source = "1Password/onepassword"
      version = "3.3.1"
    }
  }
}

module "secret_authentik" {
  # Remember to export OP_CONNECT_HOST and OP_CONNECT_TOKEN
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "authentik"
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

module "secret_nextcloud" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "nextcloud"
}

module "secret_tandoor" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "tandoor"
}

module "secret_audiobookshelf" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "audiobookshelf"
}

module "secret_paperless" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "paperless"
}

module "secret_romm" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "romm"
}

module "secret_vaultwarden" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "vaultwarden"
}

module "secret_openwebui" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "openwebui"
}

module "secret_readur" {
  source = "./modules/1password-item"
  vault = "Homelab"
  item = "readur"
}

module "secret_qui" {
  source = "./modules/1password-item"
  vault = "Homelab"
  item = "qui"
}

module "secret_fluxcd" {
  source = "./modules/1password-item"
  vault = "Homelab"
  item = "flux"
}

module "secret_meshmonitor" {
  source = "./modules/1password-item"
  vault = "Homelab"
  item = "meshmonitor"
}

module "secret_toolhive" {
  source = "./modules/1password-item"
  vault = "Homelab"
  item = "toolhive"
}

provider "authentik" {
  url   = module.secret_authentik.fields["ENDPOINT_URL"]
  token = module.secret_authentik.fields["TERRAFORM_TOKEN"]
}
