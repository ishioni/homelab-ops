module "s3_cloudnative-pg" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "cloudnative-pg"
  # The OP provider converts the fields with toLower!
  user_secret_item = "postgres_s3_secret_key"
}
