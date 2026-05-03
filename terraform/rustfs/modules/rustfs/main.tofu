terraform {
  required_providers {
    minio = {
      source = "aminueza/minio"
    }
    onepassword = {
      source = "1Password/onepassword"
    }
  }
}

data "onepassword_vault" "vault" {
  count = var.create_user ? 1 : 0
  name  = var.vault
}

data "onepassword_item" "item" {
  count = var.create_user ? 1 : 0
  vault = data.onepassword_vault.vault[0].uuid
  title = var.user_name != null ? var.user_name : var.bucket_name
}

locals {
  user_secret = var.create_user ? sensitive(one([
    for field in flatten([
      for section in data.onepassword_item.item[0].section : section.field
    ]) : field.value
    if field.label == var.user_secret_item
  ])) : null
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

resource "minio_iam_policy" "rw_policy" {
  count = var.create_user ? 1 : 0
  name  = format("%s-private", var.bucket_name)
  policy = jsonencode({
    ID      = ""
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = ""
        Effect    = "Allow"
        Action    = ["s3:*"]
        Condition = {}
        Resource = [
          "arn:aws:s3:::${minio_s3_bucket.bucket.bucket}",
          "arn:aws:s3:::${minio_s3_bucket.bucket.bucket}/*"
        ]
      }
    ]
  })
}

resource "minio_iam_user" "user" {
  count         = var.create_user ? 1 : 0
  name          = var.user_name != null ? var.user_name : var.bucket_name
  force_destroy = true
  secret        = local.user_secret
}

resource "minio_iam_user_policy_attachment" "user_rw" {
  count       = var.create_user ? 1 : 0
  user_name   = minio_iam_user.user[0].id
  policy_name = minio_iam_policy.rw_policy[0].id
}
