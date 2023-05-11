module "network" {
    source = "./modules/network"
    vpc_endpoints_sg = module.securityGroup.vpc_endpoints_sg
}
module "securityGroup" {
    source = "./modules/securityGroups"
    vpc_id = module.network.vpc_id
    project_name = module.network.project_name
}

module "iam" {
    source = "./modules/iam"
  
}