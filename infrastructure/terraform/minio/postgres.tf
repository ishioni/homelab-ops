module "s3_cloudnative-pg" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "cloudnative-pg"
  user_secret_item = "postgres_s3_secret_key"
}
