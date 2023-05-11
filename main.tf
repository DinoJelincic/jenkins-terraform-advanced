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

 module "efs" {
   source = "./modules/efs"
   project_name = module.network.project_name
   jenkins_efs_sg = module.securityGroup.jenkins_efs_sg
   private_subnetes = module.network.private_subnets
 }