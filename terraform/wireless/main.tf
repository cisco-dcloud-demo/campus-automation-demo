terraform {
  required_providers {
    meraki = {
      version = "0.2.12-alpha"
      source  = "cisco-open/meraki"
      # "hashicorp.com/edu/meraki" is the local built source, change to "cisco-en-programmability/meraki" to use downloaded version from registry
    }
  }
}
provider "meraki" {
  meraki_debug = "true"
  meraki_base_url = var.cfg.meraki_base_url
}

locals {
  combined_ssid_networks = flatten([
    for network in data.meraki_networks.this.items : [
      for ssid in var.cfg.ssids : {
        network_id = network.id
        ssid       = ssid
      }
    ]
  ])
}

variable "cfg" {
  type        = any
  description = "JSON configuration of the CML deployment"
}

data "meraki_networks" "this" {
    organization_id   = var.cfg.meraki_org_id
    tags              = var.cfg.meraki_network_tags
}

output "combined_ssid_networks" {
    value = local.combined_ssid_networks
}

output "meraki_networks" {
    value = data.meraki_networks.this
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
  auth_mode                           = each.value.ssid.authMode
  encryption_mode                     = each.value.ssid.encryptionMode
  band_selection                      = each.value.ssid.bandSelection
  ip_assignment_mode                  = each.value.ssid.ipAssignmentMode
  available_on_all_aps                = each.value.ssid.availableOnAllAps
  mandatory_dhcp_enabled              = each.value.ssid.mandatoryDhcpEnabled
  min_bitrate                         = each.value.ssid.minBitrate
  per_client_bandwidth_limit_down     = each.value.ssid.perClientBandwidthLimitDown
  per_client_bandwidth_limit_up       = each.value.ssid.perClientBandwidthLimitUp
  per_ssid_bandwidth_limit_down       = each.value.ssid.perSsidBandwidthLimitDown
  per_ssid_bandwidth_limit_up         = each.value.ssid.perSsidBandwidthLimitUp
  radius_accounting_enabled           = each.value.ssid.radiusAccountingEnabled
  radius_accounting_servers           = each.value.ssid.radiusAccountingServers
  radius_attribute_for_group_policies = each.value.ssid.radiusAttributeForGroupPolicies
  # radius_enabled                      = each.value.ssid.radius_enabled
  # radius_failover_policy              = lookup(each.value.ssid, "radius_failover_policy", "Deny access")
  # radius_load_balancing_policy        = lookup(each.value.ssid, "radius_load_balancing_policy", "Round robin")
  radius_servers                      = each.value.ssid.radiusServers
  splash_page                         = each.value.ssid.splashPage
  # splash_timeout                      = each.value.ssid.splash_timeout
  # ssid_admin_accessible               = each.value.ssid.ssid_admin_accessible
  use_vlan_tagging                    = each.value.ssid.useVlanTagging
  visible                             = each.value.ssid.visible
  walled_garden_enabled               = each.value.ssid.walledGardenEnabled
  walled_garden_ranges                = each.value.ssid.walledGardenRanges
  wpa_encryption_mode                 = lookup(each.value.ssid, "wpa_encryption_mode", "WPA2 only")
}