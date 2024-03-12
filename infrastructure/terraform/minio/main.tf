terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "ishioni"
    workspaces {
      name = "minio"
    }
  }

  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "2.2.0"
    }
  }
}

module "onepassword_item_minio" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "minio"
}

provider "minio" {
  minio_server   = "s3.nas.ishioni.casa"
  minio_user     = module.onepassword_item_minio.fields.username
  minio_password = module.onepassword_item_minio.fields.password
  minio_ssl      = true
}
