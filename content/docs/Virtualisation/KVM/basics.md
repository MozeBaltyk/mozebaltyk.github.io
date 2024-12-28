---
date: 2023-08-01T21:00:00+08:00
title: 🐋 KVM
navWeight: 60 # Upper weight gets higher precedence, optional.
series:
  - Virtualisation
categories:
  - Virtualisation
  - Cloud
---

### install KVM on RHEL 

```bash
# pre-checks hardware for intel CPU
grep -e 'vmx' /proc/cpuinfo 
lscpu | grep Virtualization
lsmod | grep kvm

# on RHEL9 Workstation
sudo dnf install virt-install virt-viewer -y
sudo dnf install -y libvirt
sudo dnf install virt-manager -y
sudo dnf install -y virt-top libguestfs-tools
sudo gpasswd -a $USER libvirt

# Start libvirt
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo systemctl status libvirtd
```

### Config a Bridge network

Important note that network are created with root user but VM with current user.

```bash
# Non permanent bridge
sudo ip link add virbr1 type bridge
sudo ip link set eno1 up
sudo ip link set eno1 master virbr1
sudo ip address add dev virbr1 192.168.2.1/24

# Permanent bridge
sudo nmcli con add ifname virbr1 type bridge con-name virbr1
sudo nmcli con add type bridge-slave ifname eno1 master virbr1
sudo nmcli con modify virbr1 bridge.stp no
sudo nmcli con down eno1
sudo nmcli con up virbr1
sudo ip address add dev virbr1 192.168.123.1/24

# KVM - Bridge Network
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

# Give qemu ACL
echo "allow all" | sudo tee /etc/qemu-kvm/${USER}.conf
echo "include /etc/qemu-kvm/${USER}.conf" | sudo tee --append /etc/qemu/bridge.conf
sudo chown root:${USER} /etc/qemu-kvm/${USER}.conf
sudo chmod 640 /etc/qemu-kvm/${USER}.conf

# Check network
sudo nmcli con show --active
sudo virsh net-list --all
sudo virsh net-edit hostbridge
sudo virsh net-info hostbridge
sudo virsh net-dhcp-leases hostbridge

# Create a VM with this bridge
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

# delete network
sudo virsh net-destroy hostbridge
sudo virsh net-undefine hostbridge
sudo nmcli con del virbr1
sudo nmcli con del eno1
```


### install Pfsense VM

* Download from Netgate website (account requested)

* Make network config 

Important note: no need to prepare NetworkManager config, KVM will handle creation of the bridge.
Also note that *dns enable* is set to disables the use of libvirts DHCP server (pfsense is taking over).

```bash
cat > pfsense.xml << EOF
<network>
  <name>pfsense-router</name>
  <uuid></uuid>
  <forward mode='nat'>
  </forward>
  <bridge name='virbr1' stp='on' delay='0'/>
  <dns enable='no'/>
  <ip address='192.168.123.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF

sudo virsh net-define pfsense.xml
sudo virsh net-start pfsense-router
sudo virsh net-autostart pfsense-router

# Give qemu ACL
echo "allow all" | sudo tee /etc/qemu-kvm/${USER}.conf
echo "include /etc/qemu-kvm/${USER}.conf" | sudo tee --append /etc/qemu/bridge.conf
sudo chown root:${USER} /etc/qemu-kvm/${USER}.conf
sudo chmod 640 /etc/qemu-kvm/${USER}.conf

# Check network
nmcli con show --active
sudo virsh net-list --all
sudo virsh net-edit pfsense-router
sudo virsh net-info pfsense-router
sudo virsh net-dhcp-leases pfsense-router
```

* Create and Run Pfsense VM

```bash
# Create pfsense vm
virt-install \
--name pfsense --ram 2048 --vcpus 2 \
--disk $HOME/pfsense/disk0.qcow2,size=12,format=qcow2 \
--cdrom $HOME/pfsense/netgate-installer-amd64.iso \
--network bridge=virbr0,model=e1000 \
--network bridge=virbr1,model=e1000 \
--graphics vnc,listen=0.0.0.0 --noautoconsole \
--osinfo freebsd14.0 \
--autostart \
--debug

virsh start pfsense
```

### Checks Pfsense VM

```bash
# Checks
virsh list
virsh domifaddr pfsense

# Connect to console
virt-viewer --domain-name pfsense
```

### Delete Pfsense VM

```bash
virsh destroy pfsense  
virsh undefine pfsense --remove-all-storage

# disk can be deleted only manually
rm -f ~/pfsense/disk0.qcow2

# delete network
sudo virsh net-destroy pfsense-router
sudo virsh net-undefine pfsense-router
sudo nmcli con del virbr1
sudo nmcli con del eno1
```