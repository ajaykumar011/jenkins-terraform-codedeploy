#!/bin/bash -xe
set -e
# Packer Log to be stored in file too with -t (tag) and -s to output to console##
exit 0 # Just to skip packer

AWS_REGION="us-east-1"
echo "I am under ${PWD}"
ARTIFACT=`packer build -machine-readable template-ubuntu-static.json | awk -F, '$0 ~/artifact,0,id/ {print $6}'`
if [ -z "$ARTIFACT" ]; then exit 1; fi
echo "packer output:"
#cat template-ubuntu-static.json

AMI_ID=`echo $ARTIFACT | cut -d ':' -f2`
echo "AMI ID: ${AMI_ID}"
echo "${AMI_ID}" > this-ami.txt
aws ec2 describe-images --image-ids $(<this-ami.txt) --region=${AWS_REGION} | grep SnapshotId | tr "/" " " | awk ' {print $2}' | sed -e 's/"//g' | sed -e 's/,$//' > this-snap.txt
echo "writing amivar.tf and uploading it to s3"
echo 'variable "APP_AMI" { default = "'${AMI_ID}'" }' > amivar.tf
#S3_BUCKET=`aws s3 ls --region $AWS_REGION |grep terraform-state |tail -n1 |cut -d ' ' -f3`
S3_BUCKET="cloudzone100"
aws s3 ls s3://${S3_BUCKET}/ --region $AWS_REGION
aws s3 cp amivar.tf s3://${S3_BUCKET}/amivar.tf --region $AWS_REGION
