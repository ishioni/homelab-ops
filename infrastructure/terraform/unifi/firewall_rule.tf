resource "unifi_firewall_rule" "allow_icmp" {
  name       = "Allow ICMP"
  action     = "accept"
  ruleset    = "WAN_LOCAL"
  rule_index = 2000
  protocol   = "icmp"
}

resource "unifi_firewall_rule" "wireguard_in" {
  name                   = "Wireguard IN"
  action                 = "accept"
  ruleset                = "WAN_LOCAL"
  rule_index             = 4000
  protocol               = "udp"
  dst_firewall_group_ids = [unifi_firewall_group.wireguard.id]
}
