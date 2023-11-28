module "s3_loki" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "loki"
  # The OP provider converts the fields with toLower!
  user_secret_item = "S3_SECRET_KEY"
}
