resource "minio_iam_user" "k3s" {
  name   = "k3s"
  secret = data.sops_file.minio_secrets.data["minio_k3s_password"]
}

resource "minio_s3_bucket" "k3s" {
  bucket = "k3s"
  acl    = "private"
}

data "minio_iam_policy_document" "k3s" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      minio_s3_bucket.k3s.arn
    ]
  }
  statement {
    effect = "Allow"

    actions = [
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject"
    ]

    resources = [
      "${minio_s3_bucket.k3s.arn}/*",
    ]
  }
}

resource "minio_iam_policy" "k3s" {
  name   = "k3s"
  policy = data.minio_iam_policy_document.k3s.json
}

resource "minio_iam_user_policy_attachment" "k3s" {
  user_name   = minio_iam_user.k3s.id
  policy_name = minio_iam_policy.k3s.id
}

