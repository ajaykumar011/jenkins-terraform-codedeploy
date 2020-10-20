#!/bin/bash -xe

## Terraform Log to be stored in file too ##

#If you want to log the script output
#exec > >(tee /tmp/terraform-script.log|logger -t terraform-script -s 2>/dev/console) 2>&1

AWS_REGION="us-east-1"
#cd jenkins-packer-demo
S3_BUCKET="cloudzone100"
aws s3 ls s3://${S3_BUCKET}/amivar.tf --region $AWS_REGION
aws s3 cp s3://${S3_BUCKET}/amivar.tf amivar.tf --region $AWS_REGION
terraform init
#terraform apply -auto-approve -var APP_INSTANCE_COUNT=1 -target aws_instance.app-instance
terraform apply -auto-approve
