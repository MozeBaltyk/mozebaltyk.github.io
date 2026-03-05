---
date: 2023-08-01T21:00:00+08:00
title: 😏 The Basics of KVM
navWeight: 30 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Virtualisation
  - KVM
---

### Basic Checks

```bash
virsh nodeinfo
```

### Config a Bridge network

Important note that network are created with root user but VM with current user.

* Non permanent bridge:

```bash
sudo ip link add virbr1 type bridge
sudo ip link set eno1 up
sudo ip link set eno1 master virbr1
sudo ip address add dev virbr1 192.168.2.1/24
```

* Permanent bridge
```bash
sudo nmcli con add ifname virbr1 type bridge con-name virbr1
sudo nmcli con add type bridge-slave ifname eno1 master virbr1
sudo nmcli con modify virbr1 bridge.stp no
sudo nmcli con down eno1
sudo nmcli con up virbr1
sudo ip address add dev virbr1 192.168.123.1/24
```

* KVM - Bridge Network
```bash
cat > hostbridge.xml << EOF
<network>
  <name>hostbridge</name>
  <forward mode='bridge'/>
  <bridge name='virbr1'/>
</network> 
EOF

sudo virsh net-define hostbridge.xml
sudo virsh net-start hostbridge
sudo virsh net-autostart hostbridge
```

* Give qemu ACL
```bash
echo "allow all" | sudo tee /etc/qemu-kvm/${USER}.conf
echo "include /etc/qemu-kvm/${USER}.conf" | sudo tee --append /etc/qemu/bridge.conf
sudo chown root:${USER} /etc/qemu-kvm/${USER}.conf
sudo chmod 640 /etc/qemu-kvm/${USER}.conf
```

* Check network
```bash
sudo nmcli con show --active
sudo virsh net-list --all
sudo virsh net-edit hostbridge
sudo virsh net-info hostbridge
sudo virsh net-dhcp-leases hostbridge
```

* Check with a small script 
```bash
echo -e "\n##### KVM networks #####\n"
kvm_system_networks_all=$(sudo virsh net-list --all)
echo -e "Available KVM networks in qemu:///system :\n$kvm_system_networks_all"
for net in $(sudo virsh net-list --name); do
    bridge_name=$(sudo virsh net-info --network ${net} | grep Bridge | cut -d":" -f2 | sed 's/^[[:space:]]*//')
    for br in ${bridge_name}; do
        br_info=$(ip -br -c address show dev ${br} || echo "No IP address assigned to bridge ${br}")
    done
    echo -e "\n\033[1;34m${net}\033[0m have the Bridge: $br_info"
done
echo -e "\n"
```

* thanks to `bridge-utils` package installed ealier:
```bash
brctl show
```

* Create a VM with this bridge
```bash
virt-install \
--name pfsense --ram 2048 --vcpus 2 \
--disk $HOME/pfsense/disk0.qcow2,size=12,format=qcow2 \
--autostart \
--cdrom $HOME/pfsense/netgate-installer-amd64.iso \
--network bridge=virbr0,model=e1000 \
--network network=hostbridge,model=e1000 \
--graphics vnc,listen=0.0.0.0 --noautoconsole \
--osinfo freebsd14.0 \
--debug
```

* Delete network
```bash
sudo virsh net-destroy hostbridge
sudo virsh net-undefine hostbridge
sudo nmcli con del virbr1
sudo nmcli con del eno1
```

## Sources

[Blog redhat](https://developers.redhat.com/articles/2024/12/18/rootless-virtual-machines-kvm-and-qemu?sc_cid=RHCTG0250000436140#connectivity_between_vms)