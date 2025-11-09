module "cdn" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "cdn"
  # The OP provider converts the fields with toLower!
  user_name        = "authentik"
  user_secret_item = "S3_SECRET_KEY"
  acl              = "public"
}
