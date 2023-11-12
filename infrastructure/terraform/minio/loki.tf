module "s3_thanos" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "loki"
  # The OP provider converts the fields with toLower!
  user_secret_item = "s3_secret_key"
}
