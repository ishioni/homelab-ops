module "s3_cloudnative-pg" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "cloudnative-pg"
  # The OP provider converts the fields with toLower!
  user_secret_item = "POSTGRES_S3_SECRET_KEY"
}
