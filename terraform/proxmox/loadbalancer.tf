resource "macaddress" "api-lb" {
}

resource "unifi_user" "api-lb" {
  mac              = macaddress.api-lb.address
  name             = "talos-api"
  local_dns_record = "talos.k3s.internal"
  fixed_ip         = "10.1.4.100"
  network_id       = data.unifi_network.kubernetes.id
}

resource "time_sleep" "api-lb" {
  create_duration = "180s"
  depends_on      = [unifi_user.api-lb]
}

resource "proxmox_lxc" "api-lb" {
  hostname        = "talos-api"
  tags            = "talos"
  target_node     = "proxmox-4"
  pool            = "infrastructure"
  ostemplate      = "ISO:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  cores           = 1
  memory          = 512
  ssh_public_keys = data.sops_file.proxmox_secrets.data["sshkey"]
  unprivileged    = true
  onboot          = true
  cmode           = "console"
  start           = true
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    tag = 4
    hwaddr = macaddress.api-lb.address
  }
  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }
  depends_on = [ time_sleep.api-lb ]
}
