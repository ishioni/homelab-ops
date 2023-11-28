module "s3_nextcloud" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "nextcloud"
  # The OP provider converts the fields with toLower!
  user_secret_item = "S3_SECRET_KEY"
}
