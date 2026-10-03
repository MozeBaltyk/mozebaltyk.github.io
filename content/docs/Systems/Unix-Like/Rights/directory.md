---
date: 2023-08-15T21:00:00+08:00
title: 📖 LDAP & Kerberos
nav_weight: 40 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
---

## Kerberos

```bash
kinit <user>   # obtain a ticket.
klist          # list the tickets in the cache.
```

## Services

```bash
systemctl status slapd   # OpenLDAP server.
systemctl status sssd    # System Security Services Daemon.
```

## LDAP - search

```bash
ldapsearch -x -h <ldap-host> -b "ou=People,dc=example,dc=com" uid=<user>
```

DN components:

* `cn` : common name
* `ou` : organizational unit
* `o` : organization
* `c` : country
* `dc` : domain component

## LDAP - add / modify

```bash
# LDIF = the commands between EOF
# -W prompts for the LDAP admin password
# -w passes the password (put it in a variable)
# bind_dn : the DN that acts as the LDAP bind user

export bind_dn="CN=directory manager,DC=example,DC=org"

# Modify an entry
ldapadd -W -D "$bind_dn" -h $ldap_server -p 389 <<EOT
dn: cn=user,ou=wiki,dc=example,dc=com
changetype: modify
add: memberUid
memberUid: $login
EOT

# Create a new entry
ldapadd -w $LDAPpwd -D "$bind_dn" -h $ldap_server -p 389 <<EOT
dn: uid=${login},ou=People,dc=example,dc=org
uid: ${login}
loginShell: /bin/bash
uidNumber: ${uid}
gidNumber: 47110
homeDirectory: /home/${login}
shadowLastChange: 0
shadowMax: -1
objectClass: account
objectClass: posixaccount
objectClass: shadowaccount
objectClass: top
gecos: ${gecos}
cn: ${gecos}
userPassword: {CRYPT}`perl -e 'print crypt("${login}", "${login}")'`
EOT
```