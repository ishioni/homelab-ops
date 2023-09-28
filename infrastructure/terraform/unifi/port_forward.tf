resource "unifi_port_forward" "http" {
  name                   = "http"
  port_forward_interface = "wan"
  fwd_ip                 = "192.168.3.2"
  fwd_port               = "80"
  dst_port               = "80"
  protocol               = "tcp"
}

resource "unifi_port_forward" "https" {
  name                   = "https"
  port_forward_interface = "wan"
  fwd_ip                 = "192.168.3.2"
  fwd_port               = "443"
  dst_port               = "443"
  protocol               = "tcp"
}

resource "unifi_port_forward" "ssh" {
  name                   = "ssh"
  port_forward_interface = "wan"
  fwd_ip                 = "192.168.1.66"
  fwd_port               = "22"
  dst_port               = "22"
  protocol               = "tcp"
}

resource "unifi_port_forward" "minecraft" {
  name                   = "minecraft"
  port_forward_interface = "wan"
  fwd_ip                 = "192.168.3.10"
  fwd_port               = "25565"
  dst_port               = "25565"
  protocol               = "tcp"
}

resource "unifi_port_forward" "torrent" {
  name                   = "torrent"
  port_forward_interface = "wan"
  fwd_ip                 = "192.168.3.4"
  fwd_port               = "51413"
  dst_port               = "51413"
  protocol               = "tcp"
}
