module "public" {
  source = "./modules/rustfs"
  providers = {
    minio = minio.cdn
  }
  bucket_name = "public"
  acl         = "public"
  create_user = false
}
