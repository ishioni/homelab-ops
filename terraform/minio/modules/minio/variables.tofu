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
}

variable "vault" {
  type = string
}

variable "versioning" {
  type    = bool
  default = false
}
