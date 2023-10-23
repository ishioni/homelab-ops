module "s3_thanos" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "thanos"
  user_secret_item = "s3_secret_key"
}
