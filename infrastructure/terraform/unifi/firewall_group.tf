resource "unifi_firewall_group" "wireguard" {
  name    = "Wireguard"
  type    = "port-group"
  members = ["4510"]
}
