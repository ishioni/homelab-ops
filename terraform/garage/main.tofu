terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "garage/state.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }

  required_providers {
    garage = {
      source  = "registry.terraform.io/jkossis/garage"
      version = "1.0.4"
    }
  }
}

module "onepassword_item_garage" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = "Homelab"
  item   = "garage"
}

provider "garage" {
  endpoint   = "https://garage-api.ishioni.casa"
  token     = module.onepassword_item_garage.fields.GARAGE_ADMIN_TOKEN
}
