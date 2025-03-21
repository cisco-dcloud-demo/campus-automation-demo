
locals {
  cfg = yamldecode(file("../../mac-data/${terraform.workspace}.yaml"))
}

module "meraki" {
    source = "./meraki"
    cfg = local.cfg
}

module "wlc" {
    source = "./wlc"
    cfg = local.cfg
}