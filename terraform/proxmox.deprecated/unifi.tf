resource "proxmox_lxc" "unifi-controller" {
  hostname        = "unifi"
  tags            = "ubuntu"
  target_node     = "proxmox-4"
  pool            = "infrastructure"
  ostemplate      = "ISO:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
  cores           = 1
  memory          = 2 * 1024
  swap            = 0
  ssh_public_keys = data.sops_file.proxmox_secrets.data["sshkey"]
  unprivileged    = true
  onboot          = true
  cmode           = "console"
  start           = true
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    hwaddr = "52:54:00:c8:11:0f"
  }
  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }
}
