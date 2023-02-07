locals {
  k3s_clonesource = "ubuntu2004-cloud"
  k3s_storage     = "local-zfs"
  dns_server      = "10.1.4.1"
  dns_domain      = "managment.internal"
  username        = "movi"

  k3s_masters = [
    {
      name = "master-1"
      node = "proxmox-1"
    },
    {
      name = "master-2"
      node = "proxmox-2"
    },
    {
      name = "master-3"
      node = "proxmox-3"
    }
  ]
  k3s_workers = [
    {
      name = "worker-1"
      node = "proxmox-1"
    },
    {
      name = "worker-2"
      node = "proxmox-2"
    },
    {
      name = "worker-3"
      node = "proxmox-3"
    }
  ]
}

module "k3s_masters" {
  source   = "./k3s"
  for_each = { for vm in local.k3s_masters : vm.name => vm }
  tags     = "kube-master;ubuntu"

  clonesource = local.k3s_clonesource

  machine_name = each.value.name
  deploy_node  = each.value.node
  vm_pool      = "k3s-masters"
  cores        = 2
  memory       = 4 * 1024
  numa         = true
  hotplug      = "network,disk,usb,memory,cpu"
  onboot       = true
  diskconfig = {
    size     = "40G"
    storage  = local.k3s_storage
    discard  = "on"
    iothread = 1
    ssd      = 1
  }
  ciuser     = local.username
  sshkeys    = data.sops_file.proxmox_secrets.data["sshkey"]
  nameserver = local.dns_server
  domain     = local.dns_domain
  networktag = 4
}

module "k3s_workers" {
  source   = "./k3s"
  for_each = { for vm in local.k3s_workers : vm.name => vm }
  tags     = "kube-worker;ubuntu"

  clonesource = local.k3s_clonesource

  machine_name = each.value.name
  deploy_node  = each.value.node
  vm_pool      = "k3s-workers"
  cores        = 8
  max_cpu      = 8
  memory       = 16 * 1024
  numa         = true
  hotplug      = "network,disk,usb,memory,cpu"
  onboot       = true

  diskconfig = {
    size     = "40G"
    storage  = local.k3s_storage
    discard  = "on"
    iothread = 1
    ssd      = 1
  }
  ciuser     = local.username
  sshkeys    = data.sops_file.proxmox_secrets.data["sshkey"]
  nameserver = local.dns_server
  domain     = local.dns_domain
  networktag = 4
}
