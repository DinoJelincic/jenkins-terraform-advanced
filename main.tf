module "network" {
    source = "./modules/network"
}
module "securityGroup" {
    source = "./modules/securityGroups"
    vpc_id = module.network.vpc_id
    project_name = module.network.project_name
}