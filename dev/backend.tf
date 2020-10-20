terraform {
  backend "s3" {
    bucket               = "cloudzone100"
    key                  = "terraform.tfstate"
    workspace_key_prefix = "workspace"
    region               = "us-east-1"
  }
}


#terraform init -input=false -force-copy -lock=true -upgrade -verify-plugins=true \
#-backend=true -backend-config="profile=$AWS_PROFILE" -backend-config="region=$REGION" -backend-config="bucket=$S3_BUCKET" \
#-backend-config="key=terraform-state/$ENV/terraform.tfstate" -backend-config="acl=private" && terraform workspace new prod