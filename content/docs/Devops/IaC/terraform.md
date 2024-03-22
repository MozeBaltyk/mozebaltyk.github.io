---
date: 2023-08-01T21:00:00+08:00
title: 🐢 Terraform
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - IaC
  - Terraform
categories:
  - Devops
---


### Validate Terraform code

```bash
dirs -c
for DIR in $(find ./examples -type d); do
   pushd $DIR
   terraform init
   terraform fmt -check
   terraform validate
   popd
 done
```

### Execute Terraform

```bash
export DO_PAT="dop_v1_xxxxxxxxxxxxxxxx"
doctl auth init --context rkub

# inside a dir with a tf file 
terraform init
terraform validate
terraform plan -var "do_token=${DO_PAT}"
terraform apply -var "do_token=${DO_PAT}" -auto-approve

# clean apply
terraform plan -out=infra.tfplan -var "do_token=${DO_PAT}"
terraform apply infra.tfplan

# Control
terraform show terraform.tfstate

# Destroy
terraform plan -destroy -out=terraform.tfplan -var "do_token=${DO_PAT}"
terraform apply terraform.tfplan
```

* Connect to Droplet with private ssh key
ssh root@$(terraform output -json ip_address_workers | jq -r '.[0]') -i .key