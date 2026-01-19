---
date: 2025-03-01T21:00:00+08:00
title: 🚩 Firewalld
navWeight: 530 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Systems
  - Unix-Like
  - Networks
---

### Basic Troubleshooting

```bash
# Get the state
firewall-cmd --state
systemctl status firewalld

# Get infos
firewall-cmd --get-default-zone
firewall-cmd --get-active-zones
firewall-cmd --get-zones
firewall-cmd --set-default-zone=home

firewall-cmd --permanent --zone=FedoraWorkstation --add-source=00:FF:B0:CB:30:0A
firewall-cmd --permanent --zone=FedoraWorkstation --add-service=ssh

firewall-cmd --get-log-denied
firewall-cmd --set-log-denied=<all, unicast, broadcast, multicast, or off>   
```

### Add/Remove/List  Services

```bash
#Remove
firewall-cmd --zone=public --add-service=ftp --permanent
firewall-cmd --zone=public --remove-service=ftp --permanent
firewall-cmd --zone=public --remove-port=53/tcp --permanent
firewall-cmd --zone=public --list-services

# Add
firewall-cmd --zone=public --new-service=portal --permanent
firewall-cmd --zone=public --service=portal --add-port=8080/tcp --permanent
firewall-cmd --zone=public --service=portal --add-port=8443/tcp --permanent
firewall-cmd --zone=public --add-service=portal --permanent
firewall-cmd --reload

firewall-cmd --zone=public --new-service=k3s-server --permanent
firewall-cmd --zone=public --service=k3s-server --add-port=443/tcp --permanent
firewall-cmd --zone=public --service=k3s-server --add-port=6443/tcp --permanent
firewall-cmd --zone=public --service=k3s-server --add-port=8472/udp --permanent
firewall-cmd --zone=public --service=k3s-server --add-port=10250/tcp --permanent
firewall-cmd --zone=public --add-service=k3s-server --permanent
firewall-cmd --reload

firewall-cmd --zone=public --new-service=quay --permanent
firewall-cmd --zone=public --service=quay --add-port=8443/tcp --permanent
firewall-cmd --zone=public --add-service=quay --permanent
firewall-cmd --reload

firewall-cmd --get-services  # It's also possible to add a service from list
firewall-cmd --runtime-to-permanent
```

### Checks and Get infos 

* list open port by services

```bash
for s in `firewall-cmd --list-services`; do echo $s; firewall-cmd --permanent --service "$s" --get-ports; done;

sudo sh -c 'for s in `firewall-cmd --list-services`; do echo $s; firewall-cmd --permanent --service "$s" --get-ports; done;'
ssh
22/tcp
dhcpv6-client
546/udp
```

* Check one service

```bash
firewall-cmd --info-service cfrm-IC
cfrm-IC
  ports: 7780/tcp 8440/tcp 8443/tcp
  protocols:
  source-ports:
  modules:
  destination:
```

* List zones and services associated

```bash
firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: ens192
  sources:
  services: ssh dhcpv6-client https Oracle nimsoft
  ports: 10050/tcp 1521/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

```bash
firewall-cmd --zone=backup --list-all
```

* Get active zones

```bash
firewall-cmd --get-active-zones
backup
  interfaces: ens224
public
  interfaces: ens192
```

* Tree folder

```bash
ls /etc/firewalld/
firewalld.conf    helpers/   icmptypes/  ipsets/    lockdown-whitelist.xml  services/   zones/
```

### IPSET

```bash
firewall-cmd --get-ipset-types
firewall-cmd --permanent --get-ipsets
firewall-cmd --permanent --info-ipset=integration
firewall-cmd --ipset=integration --get-entries

firewall-cmd --permanent --new-ipset=test --type=hash:net
firewall-cmd --ipset=local-blocklist --add-entry=103.133.104.0/23
```