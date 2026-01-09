---
date: 2023-08-01T21:00:00+08:00
title: Install
navWeight: 60 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Virtualisation
  - Oracle
  - KVM
---

### Prerequisistes

- Check Compatibilty hardware: [Oracle Linux Hardware Certification List (HCL)](https://linux.oracle.com/ords/f?p=117:1::::::)

- A minimum of two (2) KVM hosts and no more than seven (7).

-	A fully-qualified domain name for your engine and host with forward and reverse lookup records set in the DNS.

-	`/var/tmp` 10 GB space at least

-	Prepared a shared-storage (nfs or iscsi) of at least 74 GB to be used as a data storage domain dedicated to the engine virtual machine. ISCSI need to be discovered before oVirt install.

-	If you are using iSCSI storage, do not use the same iSCSI target for the *self-hosted engine* storage domain and any additional storage domains.

-	The host you are using to deploy a *self-hosted engine*, must be able to access `yum.oracle.com`.

-	Oracle Linux 8.8 (or later Oracle Linux 8 release) for all the Self-hosted and KVM

- NTP configured on each hosts

- Repo configure and update systems

- Some shared storage common to the hosts

### Network configuration

* A bond with VLAN tagging:
  
```bash
# bond with slave interfaces
nmcli connection add type bond con-name bond0 ifname bond0 bond.options "mode=active-backup,miimon=100" ipv4.method disabled ipv6.method ignore 
nmcli connection add type ethernet con-name eno12409np1 ifname eno12409np1 master bond0 slave-type bond
nmcli connection add type ethernet con-name eno8403 ifname eno8403 master bond0 slave-type bond
nmcli con mod bond0 primary eno12409np1

# VLAN ip on bond
nmcli connection add type vlan con-name vlan123  ifname bond0.123 dev bond0 id 123

# Network config on vlan
nmcli con mod vlan123 +ipv4.dns "192.168.123.10,192.168.123.20" +ipv4.addresses 192.168.123.xxx/24 +ipv4.gateway 192.168.123.1 +ipv4.dns-search "example.com" +ipv4.method manual +ipv6.method ignore
```

* Simple interface with VLAN tagging:

```bash
nmcli connection add type vlan con-name vlan3333 ifname eno1239.3333 dev eno12399np0 id 3333 ip4 3.3.3.xxx/24 gw4 3.3.3.1
```

### Install of Self-hosted engine on First host

```bash
dnf install oracle-ovirt-release-45-el8  -y
dnf install ovirt-hosted-engine-setup -y 
dnf install tmux -y
tmux
hosted-engine --deploy --4
```

NB:
- Choose [No] for Keycloak (preview not available on OLVM)
- Choose [Static] at VM network
- Choose [iscsi] for storage (depends on what you have)

### Install KVM on secondary nodes

* After that *Self-hosted engine** is deployed and reachable, start to deploy secondary host:

```bash
dnf config-manager --enable ol8_baseos_latest
dnf install oracle-ovirt-release-45-el8
dnf clean all   
dnf repolist
```

* Then on *Virtmanager console* > *Administration* > *Hosts* > *add a host* 

![VirtManager Add Host](./OLVM/virtmanager-add-hosts.png#center)


* Take and copy the **SSH publickey** from above windows to the secondary hosts:

```bash
mkdir /root/.ssh
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
chown root:root /root/.ssh/authorized_keys
vi /root/.ssh/authorized_keys
```

* Choose deploy engine in *Hosted Engine*:

![Deploy Engine](./OLVM/deploy-engine.png#center)

* Then click **OK** to start install 

* Redefine default route on each hosts after installation:

```bash
nmcli connection modify ovirtmgmt ipv4.routes "0.0.0.0/0 192.168.123.1 400"
nmcli connection up ovirtmgmt
```

NB: this is relevant only when you have several network interfaces configured. Because the install reconfigure *vlan123* to *ovirtmgmt* and the route pass second after the NIC that we configure for iscsi. It need to be back to first position. 


### Troubleshooting or reinstall

* After installation on first node:

```bash
systemctl status -l ovirt-engine
systemctl status -l ovirt-ha-agent

hosted-engine --check-deployed
hosted-engine --vm-status

hosted-engine --connect-storage
```

* Check ovirt services

```bash
systemctl --list-units ovirt*

UNIT                              LOAD   ACTIVE SUB     DESCRIPTION
ovirt-ha-agent.service            loaded active running oVirt Hosted Engine High Availability Monitoring Agent
ovirt-ha-broker.service           loaded active running oVirt Hosted Engine High Availability Communications Broker
ovirt-imageio.service             loaded active running oVirt ImageIO Daemon
ovirt-vmconsole-host-sshd.service loaded active running oVirt VM Console SSH server daemon

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.

4 loaded units listed. Pass --all to see loaded but inactive units, too.
To show all installed unit files use 'systemctl list-unit-files'.
```


* If you need to reinstall - cleanup otherwise the second trial will failed:

```bash
/usr/sbin/ovirt-hosted-engine-cleanup
rm -rf /var/tmp/localvm*
dnf remove cockpit-ovirt-dashboard -y
dnf remove ovirt-hosted-engine-setup -y
# Becarefull to have nothing in your /var/lib/iscsi
# Then restart ovirt install from scratch
```

