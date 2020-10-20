locals {
  project_name     = "${var.project_name}-${terraform.workspace}"
  instance_name    = "${terraform.workspace}-instance"
  platform_name    = "${terraform.workspace}"
  environment_name = "${terraform.workspace}-env"
  provisioner_name = "${terraform.workspace}-terraform"
  team_name        = "${terraform.workspace}-team"
  os_name          = "${var.os_name}"
  creater_name     = "${var.creater_name}"
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Project     = local.project_name
    Creater     = local.creater_name
    Provisioner = local.provisioner_name
    Environment = local.environment_name
    OS          = local.os_name
    Team        = local.team_name
  }
}

#Merging of tags is possible here.
// tags = "${merge(
//     local.common_tags,
//     map(
//       "Name", "awesome-app-server",
//       "Role", "server"
//     )
//   )}"

#to use this
#tags = local.common_tags

# A computed default name prefix, this conflicts with name, hence not very useful
locals {
  default_name_prefix = "${var.project_name}-"
  name_prefix         = "${var.name_prefix != "" ? var.name_prefix : local.default_name_prefix}"
}
