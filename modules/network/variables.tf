variable "vpc_cidr" {
    type = string
    default = "172.16.0.0/16"
}
variable "project_name" {
    type = string
    default = "Advanced-jenkins"
}
variable "public_subnets" {
    type = number
    default = 2
}
variable "public_cidr" {
    type = list(string)
    default = ["172.16.100.0/24", "172.16.101.0/24"]
}
variable "private_subnets" {
    type = number
    default = 2
}
variable "private_cidr" {
    type = list(string)
    default = [ "172.16.200.0/24", "172.16.201.0/24" ]
}
variable "aws_region" {
    default = "eu-central-1"
}
variable "vpc_endpoints_sg" {}