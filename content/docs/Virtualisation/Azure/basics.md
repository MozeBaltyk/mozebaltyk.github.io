---
date: 2023-08-01T21:00:00+08:00
title: 🐋 Azure
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Devops
categories:
  - Docs
tags:
  - Cloud
  - Providers
---

### Create a small infra for kubernetes

```bash
  #On your Azure CLI
  az --version                                     # Version expected 2.1.0 or higher 

  az group delete --name kubernetes -y

  az group create -n kubernetes -l westeurope

  az network vnet create -g kubernetes \
    -n kubernetes-vnet \
    --address-prefix 10.240.0.0/24 \
    --subnet-name kubernetes-subnet

  az network nsg create -g kubernetes -n kubernetes-nsg

  az network vnet subnet update -g kubernetes \
    -n kubernetes-subnet \
    --vnet-name kubernetes-vnet \
    --network-security-group kubernetes-nsg

  az network nsg rule create -g kubernetes \
    -n kubernetes-allow-ssh \
    --access allow \
    --destination-address-prefix '*' \
    --destination-port-range 22 \
    --direction inbound \
    --nsg-name kubernetes-nsg \
    --protocol tcp \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --priority 1000

  az network nsg rule create -g kubernetes \
    -n kubernetes-allow-api-server \
    --access allow \
    --destination-address-prefix '*' \
    --destination-port-range 6443 \
    --direction inbound \
    --nsg-name kubernetes-nsg \
    --protocol tcp \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --priority 1001

  az network nsg rule list -g kubernetes --nsg-name kubernetes-nsg --query "[].{Name:name,  Direction:direction, Priority:priority, Port:destinationPortRange}" -o table

  az network lb create -g kubernetes --sku Standard \
    -n kubernetes-lb \
    --backend-pool-name kubernetes-lb-pool \
    --public-ip-address kubernetes-pip \
    --public-ip-address-allocation static

  az network public-ip list --query="[?name=='kubernetes-pip'].{ResourceGroup:resourceGroup,   Region:location,Allocation:publicIpAllocationMethod,IP:ipAddress}" -o table
  #For Ubuntu 
  # az vm image list --location westeurope --publisher Canonical --offer UbuntuServer --sku 18.04-LTS --all -o table
  # For Redhat 
  # az vm image list --location westeurope --publisher RedHat --offer RHEL  --sku 8 --all -o table
  # => choosen one : 8-lvm-gen2
  WHICHOS="RedHat:RHEL:8-lvm-gen2:8.5.2022032206"

  # K8s Controller 
  az vm availability-set create -g kubernetes -n controller-as

  for i in 0 1 2; do
	  echo "[Controller ${i}] Creating public IP..."
	  az network public-ip create -n controller-${i}-pip -g kubernetes --sku Standard > /dev/null
	  echo "[Controller ${i}] Creating NIC..."
	  az network nic create -g kubernetes \
	  -n controller-${i}-nic \
	  --private-ip-address 10.240.0.1${i} \
	  --public-ip-address controller-${i}-pip \
	  --vnet kubernetes-vnet \
	  --subnet kubernetes-subnet \
	  --ip-forwarding \
	  --lb-name kubernetes-lb \
	  --lb-address-pools kubernetes-lb-pool >/dev/null

	  echo "[Controller ${i}] Creating VM..."
	  az vm create -g kubernetes \
	  -n controller-${i} \
	  --image ${WHICHOS} \
	  --nics controller-${i}-nic \
	  --availability-set controller-as \
	  --nsg '' \
	  --admin-username 'kuberoot' \
	  --admin-password 'Changeme!' \
	  --size Standard_B2s \
	  --storage-sku StandardSSD_LRS 
	  #--generate-ssh-keys > /dev/null
  done

  #K8s Worker 
  az vm availability-set create -g kubernetes -n worker-as
  for i in 0 1; do
  echo "[Worker ${i}] Creating public IP..."
  az network public-ip create -n worker-${i}-pip -g kubernetes --sku Standard > /dev/null
  echo "[Worker ${i}] Creating NIC..."
  az network nic create -g kubernetes \
  -n worker-${i}-nic \
  --private-ip-address 10.240.0.2${i} \
  --public-ip-address worker-${i}-pip \
  --vnet kubernetes-vnet \
  --subnet kubernetes-subnet \
  --ip-forwarding > /dev/null
  echo "[Worker ${i}] Creating VM..."
  az vm create -g kubernetes \
  -n worker-${i} \
  --image ${WHICHOS} \
  --nics worker-${i}-nic \
  --tags pod-cidr=10.200.${i}.0/24 \
  --availability-set worker-as \
  --nsg '' \
  --generate-ssh-keys \
  --size Standard_B2s \
  --storage-sku StandardSSD_LRS \
  --admin-username 'kuberoot'> /dev/null \
  --admin-password 'Changeme!' \
  done

  #Summarize
  az vm list -d -g kubernetes -o table
```