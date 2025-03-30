
locals {
  cfg = yamldecode(file("../../mac-data/${terraform.workspace}.yaml"))
  wlan_cfg_entries = [{
    name = "wlan-cfg-entry"
    key  = "profile-name"
    items = [
      for idx, ssid in local.cfg.ssids : {
        "profile-name"        = try(ssid.profile, ssid.name)
        "wlan-id"             = ssid.number
        "auth-key-mgmt-psk"   = try(ssid.auth_psk, true)
        "auth-key-mgmt-dot1x" = try(ssid.auth_dot1x, false)
        "psk"                 = ssid.psk
        "apf-vap-id-data/ssid"         = ssid.name
        "apf-vap-id-data/wlan-status"  = try(ssid.status, true)
      }
    ]
  }]
}

module "meraki" {
    source = "./meraki"
    cfg = local.cfg
}

module "wlc" {
    source = "./wlc"
    # wlan_cfg_entries = local.wlan_cfg_entries
    # meraki_org_id = local.cfg.meraki_org_id
    cfg = local.cfg
}