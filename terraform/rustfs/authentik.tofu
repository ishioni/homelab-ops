module "rcdn_authentik" {
  source      = "./modules/rustfs"
  vault       = "Homelab"
  bucket_name = "authentik"
  providers = {
    minio = minio.cdn
  }
  # The OP provider converts the fields with toLower!
  user_secret_item = "S3_SECRET_KEY"
}
