resource "minio_s3_bucket" "cloudinit" {
  bucket = "cloudinit"
  acl    = "public"
}

data "minio_iam_policy_document" "cloudinit" {
  statement {

    effect = "Allow"

    actions = [
      "s3:GetBucketLocation"
    ]

    principal = "*"

    resources = [
      minio_s3_bucket.cloudinit.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
  
  principal = "*"

    resources = [
      "${minio_s3_bucket.cloudinit.arn}/*"
    ]
  }
}

resource "minio_s3_bucket_policy" "cloudinit" {
  bucket = minio_s3_bucket.cloudinit.bucket
  policy = data.minio_iam_policy_document.cloudinit.json
}

