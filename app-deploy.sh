#!/bin/bash

echo "I am current inside $PWD"
cd ${TF_WORKSPACE}
APPLICATION_NAME=`terraform output | grep 'application_name' | cut -d '=' -f2 | xargs`
S3_BUCKET=`terraform output | grep 'bucket_name' | cut -d '=' -f2 | cut -d '.' -f1  | xargs`

# aws --region ${AWS_REGION} --profile ${AWS_PROFILE} deploy push \
# --application-name ${APPLICATION_NAME} \
# --s3-location s3://${S3_BUCKET}/${JOB_BASE_NAME}/Build-${BUILD_NUMBER}.zip --source ../app/.

DEPLOYMENT_COMMAND=`aws \
--region ${AWS_REGION} \
--profile ${AWS_PROFILE} deploy push \
--application-name ${APPLICATION_NAME} \
--s3-location s3://${S3_BUCKET}/${JOB_BASE_NAME}/Build-${BUILD_NUMBER}.zip \
--source ../app/.`

DEPLOYMENT_GROUP_NAME=`terraform show | grep deployment_group_name  | cut -d '=' -f2 | xargs`
DEPLOYMENT_CONFIG_NAME=`terraform show | grep deployment_config_na me | cut -d '=' -f2 | xargs`
DEPLPOYMENT_ETAG=`echo $DEPLOYMENT_COMMAND | awk -F '--' '{print $3}' | cut -d ',' -f4 | cut -d '=' -f2|xargs`

#Command to deploy
aws deploy create-deployment \
--application-name ${APPLICATION_NAME} \
--s3-location bucket=${S3_BUCKET},key=${JOB_BASE_NAME}/Build-${BUILD_NUMBER}.zip,bundleType=zip,eTag=${DEPLPOYMENT_ETAG} \
--deployment-group-name ${DEPLOYMENT_GROUP_NAME} \
--deployment-config-name ${DEPLOYMENT_CONFIG_NAME} \
--description "${APPLICATION_NAME}-Build-${BUILD_NUMBER}"


# aws deploy create-deployment \
# --application-name Web_App \
# --s3-location bucket=codedeploydemo-390,key=jenkins-terraform-codedeploy/Build-17.zip,bundleType=zip,eTag=9ccdb79c0a301ce61b0f3c28191e4699 \
# --deployment-group-name <deployment-group-name> \
# --deployment-config-name <deployment-config-name> \
# --description <description>