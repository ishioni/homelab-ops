module "talos" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "talos"
  # The OP provider converts the fields with toLower!
  user_secret_item = "s3_secret_key"
  versioning       = true
}

resource "minio_ilm_policy" "talos-expiration" {
  bucket = module.talos.bucket

  rule {
    id         = "expire-14d"
    expiration = "14d"
  }
}
