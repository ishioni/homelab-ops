module "s3_dragonfly" {
  source      = "./modules/garage"
  vault       = "Homelab"
  bucket_name = "dragonfly"
  # The OP provider converts the fields with toLower!
  user_secret_item = "S3_SECRET_KEY"
}
