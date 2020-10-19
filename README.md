# jenkins-terraform-packer-demo2
Jenkins- Terraform- Packer with ASG-ELB-EC2 + PHP Testing (not Ansible here)

This example does not use packer and its scripts under this directory.


Setting up AWS named profiles
To be able to apply the changes, we’ll create a named profile for each environment (Workspace).

Note: Terraform developers decided to use the word Workspace instead of Environment due to the overuse of this word,


terraform graph
terraform graph | dot -Tpng > graph.png
terraform state list | grep aws_lb_target_group
terraform destroy -target module.pilot1.aws_lb_target_group.target_es

terraform state push

# We created before our tfstate file so we need to convert local state to remote state (and store our state in the s3 bucket we created):


Ensure this is a clean environment with no .terraform directory in the module root path
configure two backend.tfvars files
run terraform init -backend-config=./backend-prod.tfvars
you will see a successful initialization
run terraform init -backend-config=./backend-dev.tfvars
you will see the migrate all workspaces to s3? message





# hands on
- disable the backend (s3)
terraform workpace list
terraform workspace new dev || true
terraform workspace new prod || true
terraform workspace list 

terraform select dev && terraform init
terraform select prod && terraform init
terraform show