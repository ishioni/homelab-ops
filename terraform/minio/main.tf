terraform {

  backend "remote" {
    organization = "ishioni"
    workspaces {
      name = "minio"
    }
  }

  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }
    minio = {
      source  = "aminueza/minio"
      version = "1.10.0"
    }
  }
}

data "sops_file" "minio_secrets" {
  source_file = "secret.sops.yaml"
}

module "onepassword_item_minio" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "minio"
}

provider "minio" {
  minio_server   = module.onepassword_item_minio.fields.server
  minio_user     = module.onepassword_item_minio.fields.username
  minio_password = module.onepassword_item_minio.fields.password
  minio_ssl      = true
}
