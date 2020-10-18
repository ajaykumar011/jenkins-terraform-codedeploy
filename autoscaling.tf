resource "aws_launch_template" "app-launchtp" {
  name = "app-launchtp"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }

  disable_api_termination = false
  //ebs_optimized = true

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2-instance-profile-for-codedeploy.name
    # iam_instance_profile = "${aws_iam_instance_profile.main.name}"
  }

  image_id = var.APP_AMI
  //instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  key_name = aws_key_pair.mykey.key_name

  // monitoring {
  //   enabled = true
  // }
  // placement {
  //   availability_zone = var.availabilityZone_A
  // }

  vpc_security_group_ids = [aws_security_group.myinstance.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "app-instance"
    }
  }
  //user_data = filebase64("${path.module}/userdata.sh")
  user_data = base64encode(<<EOF
  #!/bin/bash
  apt-get update -y 
  echo "This is userdata"   
  EOF
  )
}
resource "aws_autoscaling_group" "app-launchtp-asg" {
  name                      = "app-launchtp-asg"
  vpc_zone_identifier       = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  //desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  //health_check_grace_period = 300
  //health_check_type         = "EC2"  # this is important to check 
  target_group_arns         = [aws_lb_target_group.app-alb-tg1.arn]
  force_delete              = true
  launch_template {
    id      = aws_launch_template.app-launchtp.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }
}


