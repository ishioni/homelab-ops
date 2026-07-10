module "s3_kopiur" {
  source      = "./modules/rustfs"
  vault       = "Homelab"
  bucket_name = "kopiur"
  # The OP provider converts the fields with toLower!
  user_secret_item = "S3_SECRET_KEY"
}
