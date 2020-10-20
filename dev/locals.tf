locals {
    project_name = "Cloudzone-web"
    instance_name = "${terraform.workspace}-instance"
    platform_name = "${terraform.workspace}"
    environment_name = "${terraform.workspace}-env"
    provisioner_name = "${terraform.workspace}-tf"
    team_name = "${terraform.workspace}-team"
    os_name = "ubuntu"
    creater_name = "Ajay Kumar"
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Project = local.project_name
    Creater   = local.owner
    Provisioner = local.provisioner_name
    Environment = local.environment_name
    OS = local.os_name
  }
}

#to use this
#tags = local.common_tags