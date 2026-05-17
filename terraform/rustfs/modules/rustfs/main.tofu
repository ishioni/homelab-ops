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
  name  = var.vault
  lifecycle {
    enabled = var.create_user
  }
}

data "onepassword_item" "item" {
  vault = data.onepassword_vault.vault.uuid
  title = var.user_name != null ? var.user_name : var.bucket_name
  lifecycle {
    enabled = var.create_user
  }
}

locals {
  user_secret = var.create_user ? sensitive(one([
    for field in flatten([
      for section in data.onepassword_item.item.section : section.field
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
  lifecycle {
    enabled = var.versioning
  }
}

resource "minio_iam_policy" "rw_policy" {
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
  lifecycle {
    enabled = var.create_user
  }
}

resource "minio_iam_user" "user" {
  name          = var.user_name != null ? var.user_name : var.bucket_name
  force_destroy = true
  secret        = local.user_secret
  lifecycle {
    enabled = var.create_user
  }
}

resource "minio_iam_user_policy_attachment" "user_rw" {
  user_name   = minio_iam_user.user.id
  policy_name = minio_iam_policy.rw_policy.id
  lifecycle {
    enabled = var.create_user
  }
}
