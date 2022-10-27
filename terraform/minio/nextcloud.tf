resource "minio_iam_user" "nextcloud" {
  name   = "nextcloud"
  secret = data.sops_file.minio_secrets.data["minio_nextcloud_password"]
}

resource "minio_s3_bucket" "nextcloud" {
  bucket = "nextcloud"
  acl    = "private"
}

data "minio_iam_policy_document" "nextcloud" {
  statement {

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetBucketVersioning",
      "s3:DeleteObject"
    ]

    resources = [
      "${minio_s3_bucket.nextcloud.arn}/*",
      minio_s3_bucket.nextcloud.arn
    ]
  }
}

resource "minio_iam_policy" "nextcloud" {
  name   = "nextcloud"
  policy = data.minio_iam_policy_document.nextcloud.json
}

resource "minio_iam_user_policy_attachment" "nextcloud" {
  user_name   = minio_iam_user.nextcloud.id
  policy_name = minio_iam_policy.nextcloud.id
}
