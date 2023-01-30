module "s3_k3s" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "k3s"
  # The OP provider converts the fields with toLower!
  user_secret_item = "s3_secret_key"
}
