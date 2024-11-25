locals {
  cfg = yamldecode(file("../mac-data/${terraform.workspace}.yaml"))
}

module "wireless" {
    source = "./wireless"
    cfg = local.cfg
}

# module "debug" {
#     source = "./debug"
#     cfg = local.cfg
# }

# module "firewall" {
#   source = "./firewall"
#   env = local.config
# }