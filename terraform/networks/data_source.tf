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
}
data "meraki_networks" "example" {
  organization_id   = "572081"
  tags              = ["tf_test"]
}
output "meraki_networks_example" {
  value = data.meraki_networks.example
}