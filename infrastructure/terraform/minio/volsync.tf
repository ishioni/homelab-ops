module "s3_volsync" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "volsync"
  user_secret_item = "s3_secret_key"
}
