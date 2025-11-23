module "s3_thanos" {
  source      = "./modules/garage"
  vault       = "Homelab"
  bucket_name = "thanos"
  # The OP provider converts the fields with toLower!
  access_key = "GARAGE_ACCESS_KEY"
  secret_key = "GARAGE_SECRET_KEY"
}
