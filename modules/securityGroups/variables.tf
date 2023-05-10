variable "vpc_id" {}
variable "project_name" {}
variable "jenkins_agent_port" {
    type = number
    default = 8090
}
variable "jenkins_controller_port" {
    type = number
    default = 8080
}
