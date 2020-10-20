# create a service role for codedeploy
resource "aws_iam_role" "codedeploy_service" {
  name = "codedeploy-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

#code Deploy Service Role Policy
resource "aws_iam_role_policy" "code-deploy-service-policy" {
  name = "code-deploy-service-policy"
  role = aws_iam_role.codedeploy_service.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:CompleteLifecycleAction",
                "autoscaling:DeleteLifecycleHook",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeLifecycleHooks",
                "autoscaling:PutLifecycleHook",
                "autoscaling:RecordLifecycleActionHeartbeat",
                "autoscaling:CreateAutoScalingGroup",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:EnableMetricsCollection",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribePolicies",
                "autoscaling:DescribeScheduledActions",
                "autoscaling:DescribeNotificationConfigurations",
                "autoscaling:DescribeLifecycleHooks",
                "autoscaling:SuspendProcesses",
                "autoscaling:ResumeProcesses",
                "autoscaling:AttachLoadBalancers",
                "autoscaling:AttachLoadBalancerTargetGroups",
                "autoscaling:PutScalingPolicy",
                "autoscaling:PutScheduledUpdateGroupAction",
                "autoscaling:PutNotificationConfiguration",
                "autoscaling:PutLifecycleHook",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DeleteAutoScalingGroup",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:TerminateInstances",
                "tag:GetResources",
                "sns:Publish",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:PutMetricAlarm",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeInstanceHealth",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets",
                "ec2:CreateTags",
                "ec2:RunInstances",
                "iam:PassRole"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

// # Role name and policy attachment
// resource "aws_iam_role_policy_attachment" "codedeploy_service" {
//   role       = aws_iam_role.codedeploy_service.name
//   policy_arn = aws_iam_role_policy.code-deploy-service-policy.arn
// }

# we can also attach AWS managed policy called AWSCodeDeployRole to above creted service role
// resource "aws_iam_role_policy_attachment" "codedeploy_service" {
//   role       = aws_iam_role.codedeploy_service.name
//   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
// }

#IAM Role for EC2
resource "aws_iam_role" "iam-ec2role-for-s3-cd-role" {
  name = "iam-ec2role-for-s3-cd-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}

#IAM Role Policy
resource "aws_iam_role_policy" "iam-ec2role-for-s3-cd-policy" {
  name = "iam-ec2role-for-s3-cd-policy"
  role = aws_iam_role.iam-ec2role-for-s3-cd-role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

// #This role is needed by the CodeDeploy agent on EC2 instances.
// # Role + Policy Attachment
// resource "aws_iam_role_policy_attachment" "instance_profile_codedeploy" {
//   role       = aws_iam_role.iam-ec2role-for-s3-cd-role.name
//   policy_arn = aws_iam_role_policy.iam-ec2role-for-s3-cd-policy.arn
// }


# Final Instance profile
resource "aws_iam_instance_profile" "ec2-instance-profile-for-codedeploy" {
  name = "ec2-instance-profile-for-codedeploy"
  role = aws_iam_role.iam-ec2role-for-s3-cd-role.name
}
