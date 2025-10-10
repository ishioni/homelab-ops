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
      version = "5.11.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
  }
}

module "secret_cf" {
  # Remember to export OP_CONNECT_HOST and OP_CONNECT_TOKEN
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "cloudflare"
}

provider "cloudflare" {
  email   = module.secret_cf.fields.EMAIL
  api_key = module.secret_cf.fields.GLOBAL_API_KEY
}
