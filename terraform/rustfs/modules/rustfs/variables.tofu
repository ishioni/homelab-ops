variable "bucket_name" {
  type = string
}

variable "user_name" {
  type      = string
  sensitive = false
  default   = null
}

variable "user_secret_item" {
  type      = string
  sensitive = true
  default   = null
}

variable "vault" {
  type    = string
  default = null
}

variable "acl" {
  type    = string
  default = "private"
}

variable "versioning" {
  type    = bool
  default = false
}

variable "create_user" {
  type    = bool
  default = true
}
