resource "minio_iam_user" "postgres" {
  name   = "postgres"
  secret = data.sops_file.minio_secrets.data["minio_postgres_password"]
}

resource "minio_s3_bucket" "postgres" {
  bucket = "postgres"
  acl    = "private"
}

data "minio_iam_policy_document" "postgres" {
  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${minio_s3_bucket.postgres.arn}/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    resources = [
      "${minio_s3_bucket.postgres.arn}"
    ]
  }
}

resource "minio_iam_policy" "postgres" {
  name   = "postgres"
  policy = data.minio_iam_policy_document.postgres.json
}

resource "minio_iam_user_policy_attachment" "postgres" {
  user_name   = minio_iam_user.postgres.id
  policy_name = minio_iam_policy.postgres.id
}
