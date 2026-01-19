---
date: 2023-08-01T21:00:00+08:00
title: 🐋 KVM
navWeight: 60 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Virtualisation
  - KVM
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
sudo dnf install -y virt-top libguestfs-tools guestfs-tools
sudo gpasswd -a $USER libvirt

# Helper
sudo dnf -y install bridge-utils

# Start libvirt
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo systemctl status libvirtd
```

### Basic Checks

```bash
virsh nodeinfo
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

# Check with a small script 
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

# Due to bridge-utils package
brctl show

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

* Create OKD vm

```bash
virt-install \
--name okd --ram 2048 --vcpus 2 \
--disk $HOME/okd-latest/disk0.qcow2,size=50,format=qcow2 \
--autostart \
--cdrom $HOME/okd-latest/rhcos-live.iso \
--network bridge=virbr0,model=e1000 \
--network bridge=virbr1,model=e1000 \
--graphics vnc,listen=0.0.0.0 --noautoconsole \
--osinfo detect=on,require=off \
--debug
```

```bash
sudo virt-install -n master01 \
  --description "Master01 OKD Cluster" \
  --ram=8192 \
  --cdrom "$HOME/okd-latest/rhcos-live.iso" \
  --vcpus=2 \
  --disk pool=default,bus=virtio,size=10 \
  --graphics none \
  --osinfo detect=on,require=off \
  --serial pty \
  --console pty \
  --network network=openshift4,mac=52:54:00:36:14:e5
```

```bash
sudo cp {{OKUB_INSTALL_PATH}}/rhcos-live.iso /var/lib/libvirt/images/rhcos-live-{{PRODUCT}}-{{RELEASE_VERSION}}.iso
export COREOS_INSTALLER="podman run --privileged --pull always --rm -v /dev:/dev -v /var/lib/libvirt/images:/data -w /data quay.io/coreos/coreos-installer:release"
sudo ${COREOS_INSTALLER} iso kargs modify -a "ip={{IP_MASTERS}}::{{GATEWAY}}:{{NETMASK}}:okub-sno:{{INTERFACE}}:none:{{DNS_SERVER}}" "rhcos-live-{{PRODUCT}}-{{RELEASE_VERSION}}.iso"
sudo virt-install --name="openshift-sno" \
 --vcpus=4 \
 --ram=8192 \
 --disk path=/var/lib/libvirt/images/sno-{{PRODUCT}}-{{RELEASE_VERSION}}.qcow2,bus=sata,size=120 \
 --network network=sno,model=virtio \
 --boot menu=on \
 --graphics vnc --console pty,target_type=serial --noautoconsole \
 --cpu host-passthrough \
 --osinfo detect=on,require=off \
 --cdrom /var/lib/libvirt/images/rhcos-live-{{PRODUCT}}-{{RELEASE_VERSION}}.iso
```


### Checks Pfsense VM

```bash
# Checks
virsh list
virsh domifaddr pfsense
virsh domiflist pfsense

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

### Create a worker 

```bash
# Generate a MAC address
date +%s | md5sum | head -c 6 | sed -e 's/\([0-9A-Fa-f]\{2\}\)/\1:/g' -e 's/\(.*\):$/\1/' | sed -e 's/^/52:54:00:/';echo

sudo virt-install -n worker03.ocp4.example.com \
  --description "Worker03 Machine for Openshift 4 Cluster" \
  --ram=8192 \
  --vcpus=4 \
  --os-type=Linux \
  --os-variant=rhel8.0 \
  --noreboot \
  --disk pool=default,bus=virtio,size=50 \
  --graphics none \
  --serial pty \
  --console pty \
  --pxe \
  --network bridge=openshift4,mac=52:54:00:95:d4:ed
  ```


## Sources

[Blog redhat](https://developers.redhat.com/articles/2024/12/18/rootless-virtual-machines-kvm-and-qemu?sc_cid=RHCTG0250000436140#connectivity_between_vms)