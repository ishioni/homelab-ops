module "s3_thanos" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "thanos"
  # The OP provider converts the fields with toLower!
  user_secret_item = "S3_SECRET_KEY"
}
