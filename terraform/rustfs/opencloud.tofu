module "s3_opencloud" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "opencloud"
  # The OP provider converts the fields with toLower!
  user_secret_item = "S3_SECRET_KEY"
}
