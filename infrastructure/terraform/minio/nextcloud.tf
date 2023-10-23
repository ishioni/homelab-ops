module "s3_nextcloud" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "nextcloud"
  user_secret_item = "s3_secret_key"
}
