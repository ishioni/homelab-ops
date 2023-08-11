## Can't set vlan, disable
# resource "unifi_network" "WAN" {
#   name = "Orange"
#   purpose = "wan"
#   wan_type = "pppoe"
#   wan_vlan_enabled = true
#   wan_vlan = 35
#   wan_username = module.secret_unifi.fields.pppoe_username
#   x_wan_password = module.secret_unifi.fields.pppoe_password
#   wan_dns = ["94.140.14.14","94.140.14.15"]
#   wan_type_v6 = "disabled"
#   network_group = ""
#   wan_networkgroup = "WAN"
# }

resource "unifi_network" "Management" {
  name = "Management"
  purpose = "corporate"

  subnet = "192.168.1.0/24"
  dhcp_start = "192.168.1.32"
  dhcp_stop = "192.168.1.63"
  dhcp_lease = var.lease_time
  dhcp_enabled = true
  domain_name = "managment.internal"
  network_group = "LAN"
}

resource "unifi_network" "LAN" {
  name = "LAN"
  purpose = "corporate"

  subnet = "10.1.2.0/24"
  vlan_id = 2
  dhcp_start = "10.1.2.6"
  dhcp_stop = "10.1.2.63"
  dhcp_lease = var.lease_time
  dhcp_enabled = true
  igmp_snooping = true
  domain_name = "lan.internal"
  network_group = "LAN"
}

resource "unifi_network" "IOT" {
  name = "IOT"
  purpose = "corporate"

  subnet = "10.1.3.0/24"
  vlan_id = 3
  dhcp_start = "10.1.3.24"
  dhcp_stop = "10.1.3.63"
  dhcp_lease = var.lease_time
  dhcp_enabled = true
  igmp_snooping = true
  domain_name = "iot.internal"
  network_group = "LAN"
}

resource "unifi_network" "Kubernetes" {
  name = "Kubernetes"
  purpose = "corporate"

  subnet = "10.1.4.0/24"
  vlan_id = 4
  dhcp_start = "10.1.4.2"
  dhcp_stop = "10.1.4.63"
  dhcp_lease = var.lease_time
  dhcp_enabled = true
  igmp_snooping = true
  domain_name = "k3s.internal"
  network_group = "LAN"
}
