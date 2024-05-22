terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "minio/state.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }

  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "2.2.1"
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
