terraform {
  backend "remote" {
    organization = "ishioni"
    workspaces {
      name = "cloudflare"
    }
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.12.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.0"
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
  email   = module.secret_cf.fields.email
  api_key = module.secret_cf.fields.api_key
}
