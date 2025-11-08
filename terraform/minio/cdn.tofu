resource "minio_s3_bucket" "cdn" {
  bucket = "cdn"
  acl    = "public"
}
