resource "aws_efs_file_system" "efs" {
    creation_token = "${var.project_name}-efs"
    encrypted = true
    tags = {
      Name = "${var.project_name}-"
    }
}

# Creating EFS mount targets in each private subnet
# and attaching the jenkins-efs security group
resource "aws_efs_mount_target" "jenkins_storage" {
    count = length(var.private_subnetes)
    file_system_id = aws_efs_file_system.efs.id
    subnet_id = var.private_subnetes[count.index].id
    security_groups = [var.jenkins_efs_sg]
}

# This is the EFS access point
resource "aws_efs_access_point" "efs_ap" {
   # Specifying the EFS ID
   file_system_id = aws_efs_file_system.efs.id

   # This is the OS user and group applied to all
   # file system requests made through this access point
   posix_user {
      uid = 0 # POSIX user ID
      gid = 0 # POSIX group ID
   }

   # The directory that this access point points to
   root_directory {
      path = "/var/jenkins_home"
      # POSIX user/group owner of this directory
      creation_info {
        owner_uid    = 1000 # Jenkins user
        owner_gid    = 1000 # Jenkins group
        permissions  = "0755" 
      }
   }
   tags = {
      Name = "${var.project_name}-efs-ap"
   }
}

