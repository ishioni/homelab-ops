terraform {
  required_providers {
    minio = {
      source = "aminueza/minio"
    }
  }
}

module "onepassword" {
  source = "github.com/bjw-s/terraform-1password-item?ref=main"
  vault  = var.vault
  item   = var.user_name != null ? var.user_name : var.bucket_name
}

resource "minio_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = var.acl
}

resource "minio_s3_bucket_versioning" "bucket" {
  depends_on = [minio_s3_bucket.bucket]
  bucket     = minio_s3_bucket.bucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
  count = var.versioning ? 1 : 0
}

data "minio_iam_policy_document" "rw_policy" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${minio_s3_bucket.bucket.bucket}",
      "arn:aws:s3:::${minio_s3_bucket.bucket.bucket}/*"
    ]
  }
}

resource "minio_iam_policy" "rw_policy" {
  name   = format("%s-private", var.bucket_name)
  policy = data.minio_iam_policy_document.rw_policy.json
}

resource "minio_iam_user" "user" {
  name          = var.user_name != null ? var.user_name : var.bucket_name
  force_destroy = true
  secret        = module.onepassword.fields[var.user_secret_item]
  #   secret        = var.user_secret
}


resource "minio_iam_user_policy_attachment" "user_rw" {
  user_name   = minio_iam_user.user.id
  policy_name = minio_iam_policy.rw_policy.id
}
