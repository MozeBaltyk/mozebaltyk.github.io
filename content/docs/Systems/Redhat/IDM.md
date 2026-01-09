---
date: 2023-08-01T21:00:00+08:00
title: Idm
navWeight: 900 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Systems
  - RedHat
  - User-Management
---

## Server Idm - Identity Manager 

* prerequisites :

  * [ ] repository configured
  * [ ] NTP synchronize
  * [ ] check config DHCP/DNS 
  * [ ] `hostname -f` == `hostname` 
  * [ ] acces to webui IDM : https://idm01.idm.ad-support.local/ipa/ui/

```bash
yum install -y ipa-server ipa-server-dns

ipa-server-install \
    --domain=example.com \
    --realm=EXAMPLE.COM \
    --ds-password=password \
    --admin-password=password \
    --hostname=classroom.example.com \
    --ip-address=172.25.0.254 \
    --reverse-zone=0.25.172.in-addr.arpa. \
    --forwarder=208.67.222.222 \
    --allow-zone-overlap \
    --setup-dns \
    --unattended
```

## Client link to IDM

```bash
yum install -y ipa-client 

ipa-client-install --mkhomedir --enable-dns-updates --force-ntpd -p admin@EXAMPLE.COM --password='password' --force-join -U

# Test login
echo -n 'password' | kinit admin
```

## Script if DNS config is right for a IDM server

```bash
sudo sh -c "cat <<EOF > ~/IdmZoneCheck.sh
#!/bin/bash
### IdM zone check ###
# Check if the zone name is provided as a parameter #
if [ -z "$1" ];
then
        echo -e "Provide the zone name to be checked as a parameter!\n(ex: IdmZoneCheck.sh domain.local)"
        exit
fi
clear
echo -e "### IDM / TCP ###\n\n"
echo -e "TCP / kerberos-master (SRV)"
dig +short _kerberos-master._tcp.$1. SRV
echo -e "_TCP / kerberos (SRV)"
dig +short _kerberos._tcp.$1. SRV
echo -e "_TCP / kpasswd (SRV)"
dig +short _kpasswd._tcp.$1. SRV
echo -e "_TCP / ldap (SRV)"
dig +short _ldap._tcp.$1. SRV
echo -e "\n### IDM / UDP ###\n\n"
echo -e "_UDP / kerberos-master (SRV)"
dig +short _kerberos-master._udp.$1. SRV
echo -e "_UDP / kerberos (SRV)"
dig +short _kerberos._udp.$1. SRV
echo -e "_UCP / kpasswd (SRV)"
dig +short _kpasswd._udp.$1. SRV
echo -e "\n### IDM / MSDCS DC TCP ###\n\n"
echo -e "_MSDCS / TCP / kerberos (SRV)"
dig +short _kerberos._tcp.dc._msdcs.$1. SRV
echo -e "_MSDCS / TCP / ldap (SRV)"
dig +short _ldap._tcp.dc._msdcs.$1. SRV
echo -e "\n### IDM / MSDCS DC UDP ###\n\n"
echo -e "_MSDCS / UDP / kerberos (SRV)"
dig +short _kerberos._udp.dc._msdcs.$1. SRV
echo -e "\n### IDM / REALM ###\n\n"
echo -e "REALM (TXT)"
dig +short _kerberos.$1. TXT
echo -e "\n### IDM / CA ###\n\n"
echo -e "A / ipa-ca"
dig +short ipa-ca.$1. A
echo -e "\n### IDM / A ###\n\n"
echo -e "A / $HOSTNAME"
dig +short $HOSTNAME. A
EOF
```

* Script usage :

```bash
./IdmZoneCheck.sh idm.ad-support.local
```