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
variable "cfg" {
  type        = any
  description = "JSON configuration of the CML deployment"
}
data "meraki_networks" "example" {
#   organization_id   = "572081"
  organization_id   = var.cfg.meraki_org_id
#   tags              = ["tf_test"]
}
output "meraki_networks_debug" {
  value = data.meraki_networks.example
}
output "env_example_debug" {
  value = var.cfg
}