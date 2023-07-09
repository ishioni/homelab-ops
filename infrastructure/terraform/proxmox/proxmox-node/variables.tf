variable "machine_name" {
  type = string
}

variable "tags" {
  type = string
}

variable "vmid" {
  type    = number
  default = 0
}

variable "target_node" {
  type = string
}

variable "iso_path" {
  type = string
}

variable "oncreate" {
  type    = bool
  default = true
}

variable "onboot" {
  type    = bool
  default = true
}

variable "startup" {
  type    = string
  default = ""
}

variable "cpu_cores" {
  type    = number
  default = 1
}

variable "memory" {
  type    = number
  default = 1024
}

variable "network_tag" {
  type    = number
  default = -1
}

variable "storage" {
  type = string
}

variable "storage_size" {
  type    = string
  default = "1G"
}

variable "ip_address" {
  type = string
}

variable "network_id" {
  type = string
}
