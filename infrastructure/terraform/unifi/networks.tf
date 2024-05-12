resource "unifi_network" "servers" {
  name    = "Servers"
  purpose = "vlan-only"
  vlan_id = 2
}

resource "unifi_network" "iot" {
  name    = "IoT"
  purpose = "vlan-only"
  vlan_id = 3
}

resource "unifi_network" "trusted" {
  name    = "Trusted"
  purpose = "vlan-only"
  vlan_id = 5
}
