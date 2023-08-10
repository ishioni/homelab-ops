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
