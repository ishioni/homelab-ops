terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "unifi/state.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }

  required_providers {
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

module "secret_unifi" {
  # Remember to export OP_CONNECT_HOST and OP_CONNECT_TOKEN
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "unifi"
}

provider "unifi" {
  username       = module.secret_unifi.fields.username
  password       = module.secret_unifi.fields.password
  api_url        = "https://unifi.ishioni.casa:8443"
  allow_insecure = true
}
