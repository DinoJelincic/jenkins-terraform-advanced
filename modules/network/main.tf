data "aws_availability_zones" "available" {
    state = "available"
}

resource "aws_vpc" "advanced_jenkins_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name = "${var.project_name}-VPC"
    }
}

resource "aws_internet_gateway" "advanced_gateway" {
    vpc_id = aws_vpc.advanced_jenkins_vpc.id
    tags = {
      Name = "${var.project_name}-IGW"
    }
}

resource "aws_subnet" "public_subnet" {
    count = var.public_subnets
    vpc_id = aws_vpc.advanced_jenkins_vpc.id
    cidr_block = var.public_cidr[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
      Name = "${format("${var.project_name}-public-subnet-%02d", count.index + 1)}"
   }
}

resource "aws_subnet" "private_subnet" {
    count = var.private_subnets
    vpc_id = aws_vpc.advanced_jenkins_vpc.id
    cidr_block = var.private_cidr[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
      Name ="${format("${var.project_name}-private-subnet-%02d", count.index + 1)}"
    }
}

resource "aws_route_table" "public_route" {
    vpc_id = aws_vpc.advanced_jenkins_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.advanced_gateway.id
    }
    tags = {
        Name = "${var.project_name}-publicRT"
    }
}

resource "aws_route_table_association" "public_association" {
    count = var.public_subnets
    subnet_id = aws_subnet.public_subnet[count.index].id
    route_table_id = aws_route_table.public_route.id
}

resource "aws_eip" "advanced_eip" {
    vpc = true
    tags = {
      Name = "${var.project_name}-advancedEIP"
    }
}

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.advanced_eip.id
    subnet_id = aws_subnet.private_subnet[0].id 
    tags = {
      Name = "${var.project_name}-NATgateway"
    }
}

resource "aws_route_table" "private_route" {
    vpc_id = aws_vpc.advanced_jenkins_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway.id
    }
    tags = {
      Name = "${var.project_name}-privateRT"
    }
}

resource "aws_route_table_association" "private_association" {
    count = var.private_subnets
    subnet_id = aws_subnet.private_subnet[count.index].id 
    route_table_id = aws_route_table.private_route.id
}

resource "aws_vpc_endpoint" "s3" {
    vpc_id = aws_vpc.advanced_jenkins_vpc.id
    service_name = "com.amazonaws.${var.aws_region}.s3"
    vpc_endpoint_type = "Gateway"
    tags = {
      Name = "${var.project_name}-s3-endpoint"
    }
}

resource "aws_vpc_endpoint_route_table_association" "s3_endpoint" {
   route_table_id    = aws_route_table.private_route.id
   vpc_endpoint_id   = aws_vpc_endpoint.s3.id
}

# List of all the interface-type VPC endpoints that we will need
locals {
   endpoints = [
      "com.amazonaws.${var.aws_region}.sts",
      "com.amazonaws.${var.aws_region}.ecr.api",
      "com.amazonaws.${var.aws_region}.ecr.dkr",
      "com.amazonaws.${var.aws_region}.logs",
      "com.amazonaws.${var.aws_region}.ecs"
   ]
}

resource "aws_vpc_endpoint" "endpoint" {
   count          = length(local.endpoints)
   vpc_id         = aws_vpc.advanced_jenkins_vpc.id
   service_name   = local.endpoints[count.index]

   subnet_ids           = [for subnet in aws_subnet.private_subnet : subnet.id]
   security_group_ids   = [var.vpc_endpoints_sg]
   private_dns_enabled  = true
   vpc_endpoint_type    = "Interface"

   # This is going to tag all endpoints based on what they are,
   # for example: PREFIX-sts-endpoint, PREFIX-ecs-endpoint
   tags = {
      Name = "${var.project_name}-${
         try(
            replace(split(local.endpoints[count.index], "${var.aws_region}.")[1]), ".", "-",
            split(local.endpoints[count.index], ".")[3]
         )
      }-endpoint"
   }
}