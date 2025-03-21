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
}

locals {
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

resource "iosxe_restconf" "nested_list" {
  path = "Cisco-IOS-XE-wireless-wlan-cfg:wlan-cfg-data/wlan-cfg-entries"
  lists = [{
    name = "wlan-cfg-entry"
    key  = "profile-name"
    items = [
      for idx, ssid in var.cfg.ssids : {
        "profile-name"                  = try(ssid.profile, ssid.name)
        "wlan-id"                       = ssid.number  # Auto-increment WLAN ID starting from 1
        "auth-key-mgmt-psk"             = try(ssid.auth_psk, true)    # Default to true if not specified
        "auth-key-mgmt-dot1x"           = try(ssid.auth_dot1x, false) # Default to false if not specified
        "psk"                           = ssid.psk
        "apf-vap-id-data/ssid"          = ssid.name
        "apf-vap-id-data/wlan-status"   = try(ssid.status, true) # Default to true if not specified
      }
    ]
  }]
}

# resource "iosxe_restconf" "nested_list" {
#   path = "Cisco-IOS-XE-wireless-wlan-cfg:wlan-cfg-data/wlan-cfg-entries"
#   lists = [{
#     name = "wlan-cfg-entry"
#     key  = "profile-name"
#     items = [
#       {
#         "profile-name" = "cpn-test",
#         "wlanå-id" = 1,
#         "auth-key-mgmt-psk" = true,
#         "auth-key-mgmt-dot1x" = false,
#         "psk" = "Cisc0123#"
#         "apf-vap-id-data/ssid" = "cpn-test",
#         "apf-vap-id-data/wlan-status" = true
#       }
#     ]
#   }]
# }

variable "cfg" {
  type        = any
  description = "JSON configuration of the CML deployment"
}