# resource "proxmox_virtual_environment_container" "unifi" {
#     description = "Unifi controller managed by terraform"

#     node_name = "proxmox-4"
#     vm_id = 102

#     tags = [ "ubuntu" ]

#     cpu {
#         cores = 1
#     }

#     memory {
#         dedicated = 2
#     }

#     disk {
#         datastore_id = "local-zfs"
#         size = 8
#     }
# }

# Import broken for lxc :()
