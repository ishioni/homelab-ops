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

resource "minio_s3_bucket_policy" "rcdn_authentik_public_avatars" {
  provider   = minio.cdn
  depends_on = [module.rcdn_authentik]
  bucket     = "authentik"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadUserAvatars"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["arn:aws:s3:::authentik/user-avatars/*"]
      }
    ]
  })
}
