terraform {
  required_providers {
    meraki = {
      version = "1.0.5-beta"
      source  = "cisco-open/meraki"
      # "hashicorp.com/edu/meraki" is the local built source, change to "cisco-en-programmability/meraki" to use downloaded version from registry
    }
  }
}

provider "meraki" {
  meraki_debug = "true"
}

variable "cfg" {
  type        = any
  description = "JSON configuration of the CML deployment"
}

# locals {
#   combined_ssid_networks = flatten([
#     for network in data.meraki_networks.this.items : [
#       for ssid in var.cfg.ssids : {
#         network_id = network.id
#         ssid       = ssid
#       }
#     ]
#   ])
# }

locals {
  combined_ssid_networks = flatten([
    for network in data.meraki_networks.this.items : [
      for ssid in var.cfg.ssids : {
        network_id = network.id
        ssid       = ssid
      }
      if !contains(network.product_types, "wirelessController")
    ]
  ])
}

data "meraki_networks" "this" {
  organization_id   = var.cfg.meraki_org_id
  product_types     = ["wireless"]
}

resource "meraki_networks_wireless_ssids" "this" {
  for_each = {
    for item in local.combined_ssid_networks : 
    "${item.network_id}-${item.ssid.number}" => item
  }

  network_id                          = each.value.network_id
  number                              = each.value.ssid.number
  name                                = each.value.ssid.name
  enabled                             = each.value.ssid.enabled
  auth_mode                           = lookup(each.value.ssid, "authMode", null)
  encryption_mode                     = lookup(each.value.ssid, "encryptionMode", null)
  band_selection                      = lookup(each.value.ssid, "bandSelection", null)
  ip_assignment_mode                  = lookup(each.value.ssid, "ipAssignmentMode", null)
  available_on_all_aps                = lookup(each.value.ssid, "availableOnAllAps", null)
  mandatory_dhcp_enabled              = lookup(each.value.ssid, "mandatoryDhcpEnabled", null)
  min_bitrate                         = lookup(each.value.ssid, "minBitrate", null)
  per_client_bandwidth_limit_down     = lookup(each.value.ssid, "perClientBandwidthLimitDown", null)
  per_client_bandwidth_limit_up       = lookup(each.value.ssid, "perClientBandwidthLimitUp", null)
  per_ssid_bandwidth_limit_down       = lookup(each.value.ssid, "perSsidBandwidthLimitDown", null)
  per_ssid_bandwidth_limit_up         = lookup(each.value.ssid, "perSsidBandwidthLimitUp", null)
  radius_accounting_enabled           = lookup(each.value.ssid, "radiusAccountingEnabled", null)
  radius_accounting_servers           = lookup(each.value.ssid, "radiusAccountingServers", null)
  radius_attribute_for_group_policies = lookup(each.value.ssid, "radiusAttributeForGroupPolicies", null)
  # radius_enabled                      = lookup(each.value.ssid, "radius_enabled", null)
  radius_failover_policy              = lookup(each.value.ssid, "radius_failover_policy", null)
  radius_load_balancing_policy        = lookup(each.value.ssid, "radius_load_balancing_policy", null)
  radius_servers                      = lookup(each.value.ssid, "radiusServers", null)
  splash_page                         = lookup(each.value.ssid, "splashPage", null)
  # splash_timeout                      = each.value.ssid.splash_timeout
  # ssid_admin_accessible               = each.value.ssid.ssid_admin_accessible
  use_vlan_tagging                    = lookup(each.value.ssid, "useVlanTagging", null)
  visible                             = lookup(each.value.ssid, "visible", null)
  walled_garden_enabled               = lookup(each.value.ssid, "walledGardenEnabled", null)
  walled_garden_ranges                = lookup(each.value.ssid, "walledGardenRanges", null)
  wpa_encryption_mode                 = lookup(each.value.ssid, "wpa_encryption_mode", null)
}

output "combined_ssid_networks" {
    value = local.combined_ssid_networks
}

output "meraki_networks" {
    value = data.meraki_networks.this
}