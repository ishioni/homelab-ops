module "talos" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "talos"
  # The OP provider converts the fields with toLower!
  user_secret_item = "S3_SECRET_KEY"
  versioning       = true
}

resource "minio_ilm_policy" "talos-expiration" {
  bucket = module.talos.bucket

  rule {
    id         = "expire-3d"
    expiration = "3d"
  }

  rule {
    id = "noncurrent-expire-1h"
    noncurrent_expiration {
      days = "1d"
    }
    expiration = "DeleteMarker"
  }
}
