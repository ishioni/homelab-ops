terraform {
  required_providers {
    garage = {
      source = "registry.terraform.io/jkossis/garage"
    }
  }
}

module "onepassword" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = var.vault
  item   = var.user_name != null ? var.user_name : var.bucket_name
}

resource "garage_bucket" "bucket" {
  global_alias = var.bucket_name
}

# I wish the op provider would allow me to write
# those fields in to an existing secret...
resource "garage_key" "user" {
  name = var.user_name != null ? var.user_name : var.bucket_name
  # starts with `GK`, followed by 12 hex-encoded bytes
  # ex: GK4a02e315f9e7f3130c0ecf47
  id = module.onepassword.fields[var.access_key]
  # 64 hex bytes
  # ex: 2910eb274cf34abe3fefa20802e172ca37c7912614baf417de2b86f94be1e1c8
  secret_access_key = module.onepassword.fields[var.secret_key]
}

resource "garage_bucket_permission" "rw_policy" {
  bucket_id     = garage_bucket.bucket.id
  access_key_id = garage_key.user.id
  read          = true
  write         = true
  owner         = false
}
