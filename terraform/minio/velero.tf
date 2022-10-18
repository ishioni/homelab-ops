resource "minio_iam_user" "velero" {
  name   = "velero"
  secret = data.sops_file.minio_secrets.data["minio_velero_password"]
}

resource "minio_s3_bucket" "velero" {
  bucket = "velero"
  acl    = "private"
}

data "minio_iam_policy_document" "velero" {
  statement {

    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject"
    ]

    resources = [
      "${minio_s3_bucket.velero.arn}/*"
    ]
  }
  statement {

    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      minio_s3_bucket.velero.arn
    ]


  }
}

resource "minio_iam_policy" "velero" {
  name   = "velero"
  policy = data.minio_iam_policy_document.velero.json
}

resource "minio_iam_user_policy_attachment" "velero" {
  user_name   = minio_iam_user.velero.id
  policy_name = minio_iam_policy.velero.id
}

