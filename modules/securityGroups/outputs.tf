output "jenkins_alb_sg" {
    value = aws_security_group.jenkins_alb.id
}

output "jenkins_agents_sg" {
    value = aws_security_group.jenkins_agents.id
}

output "jenkins_controller_sg" {
    value = aws_security_group.jenkins_controller.id
}

output "jenkins_efs_sg" {
    value = aws_security_group.jenkins_efs.id
}

output "vpc_endpoints_sg" {
    value = aws_security_group.vpc_endpoints.id
}

