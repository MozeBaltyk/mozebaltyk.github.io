---
date: 2023-08-01T21:00:00+08:00
title: 🔱 K3S
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Infrastructure
categories:
  - Kubernetes
---




* Specific to RHEL 

```bash
# Create a trust zone for the two interconnect
sudo firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16 #pods
sudo firewall-cmd --permanent --zone=trusted --add-source=10.43.0.0/16 #services 
sudo firewall-cmd --reload
sudo firewall-cmd --list-all-zones

# on Master
sudo rm -f /var/lib/cni/networks/cbr0/lock
sudo /usr/local/bin/k3s-killall.sh
sudo systemctl restart k3s
sudo systemctl status k3s

# on Worker
sudo rm -f /var/lib/cni/networks/cbr0/lock
sudo /usr/local/bin/k3s-killall.sh
sudo systemctl restart k3s-agent
sudo systemctl status k3s-agent
```

## Rancher 

```bash
# Rancher local install - for example on WSL 
sudo podman run --privileged -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher
sudo podman ps 
sudo podman logs 74533d50d991  2>&1 | grep "Bootstrap Password:"
```