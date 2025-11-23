variable "bucket_name" {
  type = string
}

variable "user_name" {
  type      = string
  sensitive = false
  default   = null
}

variable "access_key" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type = string
  sensitive = true
}

variable "vault" {
  type = string
}

variable "acl" {
  type    = string
  default = "private"
}

variable "versioning" {
  type    = bool
  default = false
}
