module "s3_ocis" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "ocis"
  # The OP provider converts the fields with toLower!
  user_secret_item = "S3_SECRET_KEY"
}
