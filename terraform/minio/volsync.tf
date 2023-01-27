module "s3_volsync" {
  source      = "./modules/minio"
  vault       = "Homelab"
  bucket_name = "volsync"
  # The OP provider converts the fields with toLower!
  user_secret_item = "s3_secret_key"
}

# resource "minio_iam_user" "volsync" {
#   name   = "volsync"
#   secret = data.sops_file.minio_secrets.data["minio_volsync_password"]
# }

# resource "minio_s3_bucket" "volsync" {
#   bucket = "volsync"
#   acl    = "private"
#   force_destroy = true
# }

# data "minio_iam_policy_document" "volsync" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "s3:DeleteObject",
#       "s3:GetObject",
#       "s3:PutObject"
#     ]

#     resources = [
#       "${minio_s3_bucket.volsync.arn}/*",
#     ]
#   }
#   statement {
#     effect = "Allow"
#     actions = [
#       "s3:GetBucketLocation",
#       "s3:ListBucket"
#     ]

#     resources = [
#       "${minio_s3_bucket.volsync.arn}"
#     ]
#   }
# }

# resource "minio_iam_policy" "volsync" {
#   name   = "volsync"
#   policy = data.minio_iam_policy_document.volsync.json
# }

# resource "minio_iam_user_policy_attachment" "volsync" {
#   user_name   = minio_iam_user.volsync.id
#   policy_name = minio_iam_policy.volsync.id
# }
