variable "name" {
  type = string
}

variable "domain" {
  type = string
}

variable "slug" {
  type = string
}

variable "access_token_validity" {
  type    = string
  default = "weeks=8"
}

variable "authorization_flow" {
  type = string
}

variable "newtab" {
  type    = bool
  default = true
}

variable "description" {
  type    = string
  default = ""
}

variable "icon_url" {
  type    = string
  default = ""
}

variable "group" {
  type    = string
  default = ""
}

variable "auth_groups" {
  type = list(string)
}

variable "ignore_paths" {
  type    = string
  default = ""
}
