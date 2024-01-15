# output "node-id" {
#   value = proxmox_vm_qemu.node.id
# }

# output "name" {
#   value = proxmox_vm_qemu.node.name
# }

output "macaddr" {
  value = macaddress.node.address
}
