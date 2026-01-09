---
date: 2023-08-01T21:00:00+08:00
title: sssd
navWeight: 1000 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Systems
  - RedHat
  - User-Management
---

## Troubleshooting 

```bash
sudo realm list
authselect current
sssctl domain-list
sssctl config-check
getent -s files passwd
getent -s sss   passwd user
getent          passwd
dig -t SRV _ldap._tcp.example.com
sssctl user-checks toto -s sshd -a auth
```

## SSSD process config to link to AD

Prerequisites :

* Need port 369 and 3268

for RHEL8 :

```bash
dnf -y install realmd adcli sssd oddjob oddjob-mkhomedir samba-common-tools krb5-workstation authselect-compat

realm discover example.com
realm join example.com -U svc-sssd --client-software=sssd --os-name=RedHat --os-version=8 

sudo authselect select sssd with-mkhomedir
sudo systemctl enable --now oddjobd.service
```

* inside `/etc/sssd/sssd.conf`

```ini
[sssd]
services = nss, pam, ssh, sudo
domains = example.com
config_file_version = 2
default_domain_suffix = example.com

[domain/example.com]
default_shell = /bin/bash
override_shell = /bin/bash

ad_domain = example.com
krb5_realm = example.com
realmd_tags = manages-system joined-with-adcli
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
ldap_id_mapping = True
ldap_user_objectsid = objectSid
ldap_group_objectsid = objectSid
ldap_user_primary_group = primaryGroupID

use_fully_qualified_names = True
fallback_homedir = /home/%u

access_provider = ad
ldap_access_order=filter,expire
ldap_account_expire_policy = ad
ad_access_filter =  (memberOf=CN=INTERNAL Team,OU=team-platform,OU=test-groups,DC=example,DC=com)


[nss]
homedir_substring = /home

[pam]
pam_pwd_expiration_warning = 7
pam_account_expired_message = Account expired, please contact AD administrator.
pam_account_locked_message = Account locked, please contact AD administrator.
pam_verbosity = 3

[ssh]

[sudo]
```

* Reload config:

```bash
sss_cache -E; systemctl restart sssd ; sss_cache -E
systemctl status sssd
```

* define sudoers rights `/etc/sudoers.d/admin` :

```ini
%EXAMPLE.COM\\internal\ team ALL=(ALL) ALL
```

* reload sudoers rights:

```bash
realm permit -g 'internal team@example.com'
```
