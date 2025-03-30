module "s3_volsync" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "volsync"
  # The OP provider converts the fields with toLower!
  user_secret_item = "S3_SECRET_KEY"
}
