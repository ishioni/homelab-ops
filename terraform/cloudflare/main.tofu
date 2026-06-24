terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "cloudflare/state.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.52.8"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.6.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.3.1"
    }
  }
}

module "secret_cf" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "cloudflare"
}

provider "cloudflare" {
  email   = module.secret_cf.fields.EMAIL
  api_key = module.secret_cf.fields.GLOBAL_API_KEY
}
