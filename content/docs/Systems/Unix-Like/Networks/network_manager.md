---
date: 2023-08-27T21:00:00+08:00
title: 🚩 Network Manager
navWeight: 530 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Systems
  - Unix-Like
  - Networks
---


### Basic Troubleshooting

* Checks interfaces

```bash
nmcli con show
NAME    UUID                                  TYPE      DEVICE
ens192  4d0087a0-740a-4356-8d9e-f58b63fd180c  ethernet  ens192
ens224  3dcb022b-62a2-4632-8b69-ab68e1901e3b  ethernet  ens224

nmcli dev status
DEVICE  TYPE      STATE      CONNECTION
ens192  ethernet  connected  ens192
ens224  ethernet  connected  ens224
ens256  ethernet  connected  ens256
lo      loopback  unmanaged  --

# Get interfaces details :
nmcli connection show ens192 
nmcli -p con show ens192

# Get DNS settings in interface
UUID=$(nmcli --get-values connection.uuid c show "cloud-init eth0")
nmcli --get-values ipv4.dns c show $UUID
```

* Changing Interface name

```bash
nmcli connection add type ethernet mac "00:50:56:80:11:ff" ifname "ens224"
nmcli connection add type ethernet mac "00:50:56:80:8a:0b" ifname "ens256"
```

* Create a custom config

```bash
nmcli con load /etc/sysconfig/network-scripts/ifcfg-ens224
nmcli con up ens192
```

* Adding a Virtual IP

```bash
nmcli con mod enp1s0 +ipv4.addresses "192.168.122.11/24"
ip addr del 10.163.148.36/24 dev ens160

nmcli con reload                     # before to reapply
nmcli device reapply ens224
systemctl status network.service
systemctl restart network.service
```

* Add a DNS entry

```bash
UUID=$(nmcli --get-values connection.uuid c show "cloud-init eth0")
DNS_LIST=$(nmcli --get-values ipv4.dns c show $UUID)
nmcli conn modify "$UUID" ipv4.dns  "${DNS_LIST} ${DNS_IP}"

# /etc/resolved is managed by systemd-resolved
sudo systemctl restart systemd-resolved
```
