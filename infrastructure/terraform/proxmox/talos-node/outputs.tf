# output "node-id" {
#   value = proxmox_vm_qemu.node.id
# }

output "macaddr" {
  value = "${proxmox_virtual_environment_vm.node.name}: ${macaddress.node.address}"
}
