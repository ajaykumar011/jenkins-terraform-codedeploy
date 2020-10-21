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
  key_name      = aws_key_pair.mykey.key_name

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
      Name = local.instance_name
    }
  }
  //user_data = filebase64("${path.module}/userdata.sh")
  user_data = base64encode(<<EOF
   #!/bin/bash -xe
   #set -e  # disabled this if you enable below exec line
   exec > >(tee /tmp/packer-script.log|logger -t packer-script -s 2>/dev/console) 2>&1
   #https://docs.aws.amazon.com/codedeploy/latest/userguide/codedeploy-agent-operations-install-ubuntu.html
   
   REGION=us-east-1
   AUTOUPDATE=false
   apt-get -y update
   # Installing Code Deploy Agent
   apt-get -y install jq awscli ruby2.0 wget || apt-get -y install jq awscli ruby wget
   
   cd /tmp/
   wget https://aws-codedeploy-${REGION}.s3.amazonaws.com/latest/install
   chmod +x ./install
   sudo ./install auto
   
   service codedeploy-agent start
   service codedeploy-agent status
   
   # Install the Amazon CloudWatch Logs Agent
   cd /tmp/
   sudo apt -y install build-essential libssl-dev libffi-dev libyaml-dev python-dev
   sudo apt-get install python-pip -y
   
   wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
   dpkg -i -E ./amazon-cloudwatch-agent.deb
   
   curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
   chmod +x ./awslogs-agent-setup.py
   
   #configuration part
   wget https://s3.amazonaws.com/aws-codedeploy-us-east-1/cloudwatch/codedeploy_logs.conf
   mkdir -p /var/awslogs/etc/
   cp codedeploy_logs.conf /var/awslogs/etc/
   
   ./awslogs-agent-setup.py -n -r ${REGION} -c /var/awslogs/etc/codedeploy_logs.conf
   sudo service awslogs start
   sudo service awslogs status
   apt-get -y install nginx
   service nginx start
   systemctl enable nginx
EOF
  )
}
resource "aws_autoscaling_group" "app-launchtp-asg" {
  name = "app-launchtp-asg"
  vpc_zone_identifier = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  //desired_capacity          = 1
  min_size = 1
  max_size = 1
  //health_check_grace_period = 300
  //health_check_type         = "EC2"  # this is important to check 
  target_group_arns = [aws_lb_target_group.app-alb-tg1.arn]
  force_delete = true
  launch_template {
    id = aws_launch_template.app-launchtp.id
    version = "$Latest"
  }

  tag {
    key = "Name"
    value = local.instance_name
    propagate_at_launch = true
  }
}


