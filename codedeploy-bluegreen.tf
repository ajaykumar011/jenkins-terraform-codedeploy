#Disable codedeploy-inplace.tf and enable alb.tf to use this.
# create a CodeDeploy application
resource "aws_codedeploy_app" "main" {
  name = "Nginx_Web_App"
}

# create a deployment group
resource "aws_codedeploy_deployment_group" "main" {
  app_name              = aws_codedeploy_app.main.name
  deployment_group_name = "Nginx_Web_DepGroup"
  service_role_arn      = aws_iam_role.codedeploy_service.arn
  //deployment_config_name = "CodeDeployDefault.OneAtATime" # AWS defined deployment config
 // autoscaling_groups     = [aws_autoscaling_group.app-launchtp-asg.name]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type = "BLUE_GREEN"
  }

  load_balancer_info {
    elb_info {
      name = aws_lb_target_group.app-alb-tg1.name-------------
    }
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 60
    }

    green_fleet_provisioning_option {
      action = "DISCOVER_EXISTING"
    }

    terminate_blue_instances_on_deployment_success {
      action = "KEEP_ALIVE"
    }
  }
  
  ec2_tag_set {
    ec2_tag_filter {
      key   = "OS"
      type  = "KEY_AND_VALUE"
      value = "Ubuntu"
    }

    ec2_tag_filter {
      key   = "Platform"
      type  = "KEY_AND_VALUE"
      value = "Dev"
    }

    ec2_tag_filter {
      key   = "Provisioner"
      type  = "KEY_AND_VALUE"
      value = "Terraform"
    }
  }

    trigger_configuration {
    trigger_events     = ["DeploymentFailure"]
    trigger_name       = "app-trigger"
    trigger_target_arn = "arn:aws:sns:us-east-1:143787628822:EmailNotify" 
  }


  # trigger a rollback on deployment failure event
  auto_rollback_configuration {
    enabled = true
    events = [
      "DEPLOYMENT_FAILURE",
    ]
  }
}
