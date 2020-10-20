#!/bin/bash -xe
aws ec2 deregister-image --image-id $(<this-ami.txt) --region us-east-1
aws ec2 delete-snapshot --snapshot-id $(<this-snap.txt) --region us-east-1