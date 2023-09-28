resource "unifi_wlan" "MoviNet" {
  name                 = "MoviNet"
  network_id           = unifi_network.LAN.id
  passphrase           = module.secret_unifi.fields.movinet_password
  security             = "wpapsk"
  fast_roaming_enabled = true
  multicast_enhance    = true
  bss_transition       = true
  no2ghz_oui           = true
  wlan_band            = "both"
  pmf_mode             = "optional"
  wpa3_support         = true
  wpa3_transition      = true

  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = data.unifi_user_group.default.id
}

resource "unifi_wlan" "MoviIOT" {
  name              = "MoviIOT"
  network_id        = unifi_network.IOT.id
  passphrase        = module.secret_unifi.fields.moviiot_password
  security          = "wpapsk"
  multicast_enhance = true
  bss_transition    = true
  no2ghz_oui        = false
  wlan_band         = "both"
  pmf_mode          = "optional"
  wpa3_support      = true
  wpa3_transition   = true

  ap_group_ids  = [data.unifi_ap_group.default.id]
  user_group_id = data.unifi_user_group.default.id
}
