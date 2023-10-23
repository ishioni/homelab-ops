module "s3_testbucket" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "testbucket"
  user_secret_item = "s3_secret_key"
}
