---
date: 2023-08-01T21:00:00+08:00
title: Terraform
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Devops
categories:
  - Docs
tags:
  - IaC
  - Terraform
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

* Connect to server getting the ip with terraform command:

```bash
ssh root@$(terraform output -json ip_address_workers | jq -r '.[0]') -i .key
```

## Work with yaml in terraform

Two possibilities: 

* Take Terraform variables and yamlencode to pass it to your config, example:

```tf
# non-airgap
locals {
  cloud_init_config = yamlencode({
    packages = [
      "python3.12"
    ]
  })
}

# Convert our cloud-init config to userdata
data "cloudinit_config" "server_config" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/cloud-config"
    content      = local.cloud_init_config
  }
}
```

* Or works with templates (allow to use loops and conditions in the template ):

```tf
# Generate template install-config.yaml
resource "local_file" "install-config" {
  depends_on = [null_resource.download_and_extract_openshift_install]
  content = templatefile("./template/install-config.yaml.tftpl",
    {
        master_details = local.master_details,
        worker_details = local.worker_details,
        public_key = tls_private_key.global_key.public_key_openssh,
        internal_registry_url = var.internal_registry,
        registry_ca_certificate = local.registry_ca_certificate,

    }
  )
  filename = "${var.okub_install_path}/install-config.yaml"
}
```

* Or work with both:

```tf
data "template_file" "user_data" {
  template = file("${path.module}/${local.cloud_init_version}/cloud_init.cfg.tftpl")
  vars = {
    os_name    = local.os_name
    hostname   = var.hostname
    fqdn       = "${var.hostname}.${local.subdomain}"
    master_details = indent(8, yamlencode(local.master_details))
    worker_details   = indent(8, yamlencode(local.worker_details))
    public_key = tls_private_key.global_key.public_key_openssh
  }
}
```

https://plainenglish.io/blog/terraform-yaml


## Terraform in airgap

* So let imagine, you have to package dependencies for below providers:
  
```tf
# versions.tf
terraform {
  required_providers {
    ignition = {
      source = "community-terraform-providers/ignition"
    }
    vsphere = {
      source = "hashicorp/vsphere"
    }
  }
  required_version = ">= 0.13"
}
```

* Refine Terraform config to redirect in known path:

```ini
terraform.tfrc
plugin_cache_dir   = "./.terraform.d/plugin-cache"
```

* Then config terraform to look for plugins locally:

```tf
# terraform-airgap.tfrc
disable_checkpoint = true

provider_installation {
  filesystem_mirror{
    path = "../.terraform.d/plugin-cache"
  }
}
```

* In ansible the logic would be like follow :

```yml
---
# tf providers
- name: Push terraform file at root dir
  template:
    src: "{{ item }}"
    dest: "{{ prepare_airgap_deps_path }}/terraform/{{ item }}"
    mode: u=rw,g=r,o=r
  loop:
    - terraform.tfrc
    - versions.tf

# equivalent to "terraform providers mirror -platform=linux_amd64 .terraform.d/plugin-cache"
- name: Init terraform to pull providers
  command: "{{ prepare_airgap_deps_path }}/bin/terraform init -no-color"
  args:
    chdir: "{{ prepare_airgap_deps_path }}/terraform"
  environment: 
    TF_CLI_CONFIG_FILE: "./terraform.tfrc"

- name: Push terraform file to OCP dir
  template:
    src: "{{ item }}"
    dest: "{{ prepare_airgap_deps_path }}/terraform/ocp/{{ item }}"
    mode: u=rw,g=r,o=r
  loop:
    - terraform-airgap.tfrc
    - versions.tf

- name: Init terraform to test airgap
  command: "{{ prepare_airgap_deps_path }}/bin/terraform init -no-color"
  args:
    chdir: "{{ prepare_airgap_deps_path }}/terraform/ocp"
  environment: 
    TF_CLI_CONFIG_FILE: "./terraform-airgap.tfrc"
```
