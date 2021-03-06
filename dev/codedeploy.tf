#Disable codedeploy-bluegreen.tf and enable elb-classitc.tf to use this.
# create a CodeDeploy application
resource "aws_codedeploy_app" "main" {
  name = "Web_App"
}

# create a deployment group
resource "aws_codedeploy_deployment_group" "main" {
  app_name               = aws_codedeploy_app.main.name
  deployment_group_name  = "Web_DepGroup"
  service_role_arn       = aws_iam_role.codedeploy_service.arn
  deployment_config_name = "CodeDeployDefault.OneAtATime" # AWS defined deployment config
  autoscaling_groups     = [aws_autoscaling_group.app-launchtp-asg.name]
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.app-alb-tg1.name
    }
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "OS"
      type  = "KEY_AND_VALUE"
      value = local.os_name
    }

    ec2_tag_filter {
      key   = "Platform"
      type  = "KEY_AND_VALUE"
      value = local.platform_name
    }

    ec2_tag_filter {
      key   = "Provisioner"
      type  = "KEY_AND_VALUE"
      value = local.creater_name
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
