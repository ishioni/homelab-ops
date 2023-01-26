resource "minio_iam_user" "loki" {
  name   = "loki"
  secret = data.sops_file.minio_secrets.data["minio_loki_password"]
}

resource "minio_s3_bucket" "loki" {
  bucket = "loki"
  acl    = "private"
}

data "minio_iam_policy_document" "loki" {
  statement {

    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${minio_s3_bucket.loki.arn}",
      "${minio_s3_bucket.loki.arn}/*"
    ]
  }
}

resource "minio_iam_policy" "loki" {
  name   = "loki"
  policy = data.minio_iam_policy_document.loki.json
}

resource "minio_iam_user_policy_attachment" "loki" {
  user_name   = minio_iam_user.loki.id
  policy_name = minio_iam_policy.loki.id
}
