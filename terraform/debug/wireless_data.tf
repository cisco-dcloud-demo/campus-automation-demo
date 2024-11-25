terraform {
  required_providers {
    meraki = {
      version = "0.2.12-alpha"
      source  = "cisco-open/meraki"
    }
  }
}
provider "meraki" {
  meraki_debug = "true"
}
data "meraki_networks_wireless_ssids" "example" {
  network_id = "L_627126248111381672"
}