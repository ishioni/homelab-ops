module "s3_thanos" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "thanos"
  # The OP provider converts the fields with toLower!
  user_secret_item = "s3_secret_key"
}

# resource "minio_iam_user" "thanos" {
#   name   = "thanos"
#   secret = data.sops_file.minio_secrets.data["minio_thanos_password"]
# }

# resource "minio_s3_bucket" "thanos" {
#   bucket = "thanos"
#   acl    = "private"
#   force_destroy = true
# }

# data "minio_iam_policy_document" "thanos" {
#   statement {

#     effect = "Allow"

#     actions = [
#       "s3:ListBucket",
#       "s3:GetObject",
#       "s3:DeleteObject",
#       "s3:PutObject"

#     ]

#     resources = [
#       "${minio_s3_bucket.thanos.arn}/*",
#       "${minio_s3_bucket.thanos.arn}"
#     ]
#   }
# }

# resource "minio_iam_policy" "thanos" {
#   name   = "thanos"
#   policy = data.minio_iam_policy_document.thanos.json
# }

# resource "minio_iam_user_policy_attachment" "thanos" {
#   user_name   = minio_iam_user.thanos.id
#   policy_name = minio_iam_policy.thanos.id
# }
