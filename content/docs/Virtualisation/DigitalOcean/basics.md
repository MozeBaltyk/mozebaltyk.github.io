---
date: 2023-08-01T21:00:00+08:00
title: 🐋 Digital Ocean
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Virtualisation
categories:
  - Virtualisation
  - Cloud
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

# Control
terraform show terraform.tfstate

# Destroy
terraform plan -destroy -out=terraform.tfplan -var "do_token=${DO_PAT}"
terraform apply terraform.tfplan
```

```tf
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = "terraform"
}


###
### VPC
###
resource "digitalocean_vpc" "fra1-vpc-01" {
  name     = "rkub-project-network"
  region   = "fra1"
  ip_range = "10.10.10.0/24"
}

###
### Droplet INSTANCES
###
resource "digitalocean_tag" "rke2" {
  name = "rke2"
}

resource "digitalocean_tag" "rkub" {
  name = "rkub"
}

# Droplet Instance for RKE2 Cluster - Manager
resource "digitalocean_droplet" "rkub01" {
    image = "rockylinux-8-x64"
    name = "rkub01"
    region = "fra1"
    size = "s-2vcpu-4gb"
    tags   = [digitalocean_tag.rke2.id, digitalocean_tag.rkub.id]
    vpc_uuid = digitalocean_vpc.fra1-vpc-01.id
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

# Droplet Instance for RKE2 Cluster - Worker
resource "digitalocean_droplet" "rkub02" {
    image = "rockylinux-8-x64"
    name = "rkub02"
    region = "fra1"
    size = "s-2vcpu-4gb"
    tags   = [digitalocean_tag.rke2.id, digitalocean_tag.rkub.id]
    vpc_uuid = digitalocean_vpc.fra1-vpc-01.id
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

resource "digitalocean_droplet" "rkub03" {
    image = "rockylinux-8-x64"
    name = "rkub03"
    region = "fra1"
    size = "s-2vcpu-4gb"
    tags   = [digitalocean_tag.rke2.id, digitalocean_tag.rkub.id]
    vpc_uuid = digitalocean_vpc.fra1-vpc-01.id
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

###
### Project
###

resource "digitalocean_project" "rkub" {
  name        = "Rkub"
  description = "A CI project to test the Rkub development from github."
  purpose     = "Cluster k8s"
  environment = "Staging"
  resources   = [
    digitalocean_droplet.rkub01.urn,
    digitalocean_droplet.rkub02.urn,
    digitalocean_droplet.rkub03.urn
  ]
}
```