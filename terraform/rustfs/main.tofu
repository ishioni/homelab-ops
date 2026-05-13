terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "rustfs/state.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }

  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "3.35.2"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.3.1"
    }
  }
}

module "onepassword_item_rustfs" {
  source = "./modules/1password-item"
  vault  = "Homelab"
  item   = "rustfs"
}

provider "minio" {
  minio_server   = "rs3.ishioni.casa"
  minio_user     = module.onepassword_item_rustfs.fields.username
  minio_password = module.onepassword_item_rustfs.fields.password
  minio_ssl      = true
}

provider "minio" {
  alias          = "cdn"
  minio_server   = "rcdn.movishell.pl"
  minio_user     = module.onepassword_item_rustfs.fields.username
  minio_password = module.onepassword_item_rustfs.fields.password
  minio_ssl      = true
}
