resource "aws_security_group" "jenkins_alb" {
    name = "jenkins-alb"
    vpc_id = var.vpc_id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    tags = {
      Name = "${var.project_name}-jenkins-alb"
    }
}

resource "aws_security_group" "jenkins_agents" {
   name        = "jenkins-agents"
   vpc_id      = var.vpc_id

   egress {
      description = "Allow all outbound traffic"
      from_port   = "0"
      to_port     = "0"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
   tags = {
      Name = "${var.project_name}-jenkins-agents"
   }
}

# This is the SG for the Jenkins controller
# - Allows traffic from ALB on Jenkins controller port
# - Allows traffic from Jenkins agents on the 
#       Jenkins agents port and Jenkins controller port
# - Allows traffic from the VPC endpoints on 443
# - Allows all outbound traffic
resource "aws_security_group" "jenkins_controller" {
   name        = "jenkins-controller"
   description = "Security group for the Jenkins master"
   vpc_id      = var.vpc_id

   ingress {
      description       = "Allow traffic from the ALB"
      from_port         = "${var.jenkins_controller_port}"
      to_port           = "${var.jenkins_controller_port}"
      protocol          = "tcp"
      security_groups   = [aws_security_group.jenkins_alb.id]
   }

   ingress {
      description       = "Allow traffic from the Jenkins agents over JNLP"
      from_port         = "${var.jenkins_agent_port}"
      to_port           = "${var.jenkins_agent_port}"
      protocol          = "tcp"
      security_groups   = [aws_security_group.jenkins_agents.id]
   }

   ingress {
      description       = "Allow traffic from the Jenkins agents"
      from_port         = "${var.jenkins_controller_port}"
      to_port           = "${var.jenkins_controller_port}"
      protocol          = "tcp"
      security_groups   = [aws_security_group.jenkins_agents.id]
   }

   ingress {
      description       = "Allow traffic from VPC endpoints"
      from_port         = "443"
      to_port           = "443"
      protocol          = "tcp"
      security_groups   = [aws_security_group.vpc_endpoints.id]
   }

   egress {
      description = "Allow all outbound traffic"
      from_port   = "0"
      to_port     = "0"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "${var.prefix}-jenkins-controller"
   }
}