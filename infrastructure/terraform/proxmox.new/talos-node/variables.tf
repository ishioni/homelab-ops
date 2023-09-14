variable "machine_name" {
  type = string
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "vmid" {
  type    = number
  default = 0
}

variable "target_node" {
  type = string
}

variable "iso_path" {
  type    = string
  default = ""
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

variable "vlan_id" {
  type    = number
  default = 0
}

variable "storage" {
  type    = string
  default = "local-zfs"
}

variable "storage_size" {
  type    = string
  default = 8
}

variable "ip_address" {
  type = string
}

variable "network_id" {
  type = string
}

variable "qemu_agent" {
  type    = bool
  default = false
}

variable "file_format" {
  type    = string
  default = "raw"
}

variable "timeout_stop_vm" {
  type    = number
  default = 600
}

variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "gpu_gvtd" {
  type    = bool
  default = false
}
