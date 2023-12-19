terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "ishioni"
    workspaces {
      name = "cloudflare"
    }
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.20.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.1"
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
  api_key = module.secret_cf.fields.API_KEY
}
