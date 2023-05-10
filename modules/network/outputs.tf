output "vpc_id" {
    value = aws_vpc.advanced_jenkins_vpc.id
}

output "public_subnets" {
    value = aws_subnet.public_subnet
}

output "private_subnets" {
    value = aws_subnet.private_subnet
}
output "project_name" {
    value = var.project_name
}
