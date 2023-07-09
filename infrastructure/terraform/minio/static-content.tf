resource "minio_s3_bucket" "static-contect" {
  bucket = "static-content"
  acl    = "public"
}
