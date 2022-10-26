variable "machine_name" {
  type = string
}

variable "clonesource" {
  type = string
}

variable "deploy_node" {
  type    = string
  default = "proxmox-1"
}

variable "onboot" {
  type    = bool
  default = false
}

variable "oncreate" {
  type    = bool
  default = false
}

variable "memory" {
  type    = number
  default = 2048
}

variable "cores" {
  type    = number
  default = 1
}

variable "max_cpu" {
  type    = number
  default = 4
}

variable "cputype" {
  type    = string
  default = "host"
}

variable "numa" {
  type    = bool
  default = true
}

variable "hotplug" {
  type    = string
  default = "network,disk,usb"
}

variable "vm_pool" {
  type    = string
  default = ""

}

variable "networktag" {
  type    = number
  default = -1
}

variable "diskconfig" {
  type = object({
    cache    = optional(string)
    discard  = optional(string)
    iothread = optional(number)
    size     = string
    ssd      = optional(number)
    storage  = string
  })
  default = {
    cache    = "none"
    discard  = "on"
    iothread = 1
    size     = "4G"
    ssd      = 1
    storage  = "local"
  }
}

variable "ciuser" {
  type = string
}

variable "sshkeys" {
  type = string
}

variable "nameserver" {
  type = string
}

variable "domain" {
  type = string
}