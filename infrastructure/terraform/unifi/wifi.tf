resource "unifi_wlan" "MoviNet" {
  name = "MoviNet"
  network_id = unifi_network.LAN.id
  passphrase = "januszesieci2018"
  security = "wpapsk"
  fast_roaming_enabled = true
  multicast_enhance = true
  bss_transition = true
  no2ghz_oui = true

  ap_group_ids = [data.unifi_ap_group.default.id]
  user_group_id = data.unifi_user_group.default.id
}
