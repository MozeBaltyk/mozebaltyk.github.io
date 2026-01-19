---
date: 2023-08-01T21:00:00+08:00
title: 🐋 Digital Ocean
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - Devops
tags:
  - Cloud
  - Providers
---

### Install Client

```bash
# most simple 
arkade get doctl

# normal way
curl -OL https://github.com/digitalocean/doctl/releases/download/v1.104.0/doctl-1.104.0-linux-amd64.tar.gz
tar xf doctl-1.104.0-linux-amd64.tar.gz
mv doctl /usr/local/bin

# Auto-Completion ZSH
 doctl completion zsh > $ZSH/completions/_doctl
```

### Basics 

* find possible droplet 
```bash
doctl compute region list
doctl compute size list
doctl compute image list-distribution
doctl compute image list --public
```

* Auth 
```bash
doctl auth init --context test
doctl auth list
doctl auth switch --context test2
```

* Create Project
```bash
doctl projects create --name rkub --environment staging --purpose "stage rkub with github workflows"
```

* Create VM
```bash
doctl compute ssh-key list
doctl compute droplet create test --region fra1 --image rockylinux-9-x64 --size s-1vcpu-1gb --ssh-keys <fingerprint>
doctl compute droplet delete test -f
```

### with Terraform

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

* Example of terraform:

```tf
###
### Provider part
###
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = "terraform"
}

###
### VPC
###
resource "digitalocean_vpc" "rkub-project-network" {
  name     = "rkub-project-network"
  region   = "fra1"
  ip_range = "10.10.10.0/24"
}

###
### Droplet INSTANCES
###

# Droplet Instance for RKE2 Cluster - Manager
resource "digitalocean_droplet" "controllers" {
    count = 1
    image = var.do_system
    name = "controller${count.index}"
    region = "fra1"
    size = var.do_instance_size
    tags   = [
      "rke2_ansible_test_on_${var.do_system}_${var.GITHUB_RUN_ID}_controllers",
      ]
    vpc_uuid = digitalocean_vpc.rkub-project-network.id
    ssh_keys = [
      data.digitalocean_ssh_key.terraform.id
    ]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(pathexpand(".key"))
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "cat /etc/os-release",
    ]
  }
}

output "ip_address_controllers" {
  value = digitalocean_droplet.controllers[*].ipv4_address
  description = "The public IP address of your rke2 controllers."
}


# Droplet Instance for RKE2 Cluster - Workers
resource "digitalocean_droplet" "workers" {
    count = 2
    image = var.do_system
    name = "worker${count.index}"
    region = "fra1"
    size = var.do_instance_size
    tags   = [
      "rke2_ansible_test_on_${var.do_system}_${var.GITHUB_RUN_ID}_workers",
      ]
    vpc_uuid = digitalocean_vpc.rkub-project-network.id
    ssh_keys = [
      data.digitalocean_ssh_key.terraform.id
    ]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(pathexpand(".key"))
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "cat /etc/os-release",
    ]
  }
}

output "ip_address_workers" {
  value = digitalocean_droplet.workers[*].ipv4_address
  description = "The public IP address of your rke2 workers."
}

###
### Project
###

resource "digitalocean_project" "rkub" {
  name        = "Rkub-${var.GITHUB_RUN_ID}"
  description = "A CI project to test the Rkub development from github."
  purpose     = "Cluster k8s"
  environment = "Staging"
  resources = flatten([digitalocean_droplet.controllers.*.urn, digitalocean_droplet.workers.*.urn])
}
```