module "s3_volsync" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "volsync"
  # The OP provider converts the fields with toLower!
  user_secret_item = "s3_secret_key"
}
