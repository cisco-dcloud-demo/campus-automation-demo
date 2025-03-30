terraform {
  required_providers {
    meraki = {
      version = "1.0.5-beta"
      source  = "cisco-open/meraki"
      # "hashicorp.com/edu/meraki" is the local built source, change to "cisco-en-programmability/meraki" to use downloaded version from registry
    }
    iosxe = {
      version = "0.5.6"
      source  = "CiscoDevNet/iosxe"
    }
  }
}
provider "meraki" {
  meraki_debug = "true"
#   meraki_base_url = var.cfg.meraki_base_url
}

data "meraki_devices" "wlcs" {
  organization_id   = var.cfg.meraki_org_id
  product_types     = ["wirelessController"]
}

variable "interface_name" {
  description = "Interface name to filter for IPv4 address"
  type        = string
  default     = "GigabitEthernet0"
}

data "meraki_organizations_wireless_controller_devices_interfaces_l3_by_device" "example" {
  organization_id = var.cfg.meraki_org_id
}

locals {
  device_info = [
    for device in data.meraki_organizations_wireless_controller_devices_interfaces_l3_by_device.example.item.items : {
      serial      = device.serial
      ipv4_address = flatten([
        for iface in device.interfaces : (
          iface.name == var.interface_name ? [
            for addr in iface.addresses : addr.address if addr.protocol == "ipv4"
          ] : []
        )
      ])[0]
    }
  ]
  wlcs_devices = [
    for device in local.device_info : {
      name = device.serial
      url  = "https://${device.ipv4_address}"
    }
  ]
}

provider "iosxe" {
  username = "admin"
  password = "C1sco12345"
  devices  = local.wlcs_devices
}

locals {
  wlan_cfg_entries = [{
    name = "wlan-cfg-entry"
    key  = "profile-name"
    items = [
      for idx, ssid in var.cfg.ssids : {
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

resource "iosxe_restconf" "nested_list" {
  path = "Cisco-IOS-XE-wireless-wlan-cfg:wlan-cfg-data/wlan-cfg-entries"
  attributes = {}
  lists = local.wlan_cfg_entries
}

output "wlan_cfg_entries" {
  value = local.wlan_cfg_entries
}

variable "cfg" {
  type        = any
  description = "JSON configuration of the CML deployment"
}
