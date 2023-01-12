resource "proxmox_vm_qemu" "vm" {
  name        = var.machine_name
  tags = var.tags
  target_node = var.deploy_node
  full_clone  = true

  bios     = "seabios"
  clone    = var.clonesource
  onboot   = var.onboot
  oncreate = var.oncreate
  boot     = "order=scsi0"
  agent    = 1
  qemu_os  = "l26"
  memory   = var.memory
  balloon  = 0
  sockets  = 1
  cores    = var.max_cpu
  vcpus    = var.cores
  cpu      = var.cputype
  numa     = var.numa
  hotplug  = var.hotplug
  scsihw   = "virtio-scsi-single"
  pool     = var.vm_pool
  os_type  = "cloud-init"

  ciuser  = var.ciuser
  sshkeys = var.sshkeys

  network {
    model  = "virtio"
    bridge = "vmbr0"
    tag    = var.networktag
  }
  ipconfig0    = "ip=dhcp"
  searchdomain = var.domain
  nameserver   = var.nameserver

  disk {
    size     = var.diskconfig.size
    storage  = var.diskconfig.storage
    cache    = var.diskconfig.cache
    ssd      = var.diskconfig.ssd
    discard  = var.diskconfig.discard
    iothread = var.diskconfig.iothread
    type     = "scsi"
    backup   = 1
  }
}
