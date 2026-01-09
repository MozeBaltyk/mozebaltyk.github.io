---
date: 2023-08-01T21:00:00+08:00
title: Administration
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

### Hosted-engine Administration

* Connect to VM *hosted-engine* with root and password setup during the install:

```bash
# Generate a backup 
engine-backup --scope=all --mode=backup --file=/root/backup --log=/root/backuplog

# Restore from a backup on Fresh install
engine-backup --mode=restore --file=file_name --log=log_file_name --provision-db --restore-permissions
engine-setup

# Restore a backup on existing install
engine-cleanup
engine-backup --mode=restore --file=file_name --log=log_file_name --restore-permissions
engine-setup
```

### host Administration

* Connect in ssh to the Host:

```bash
# Pass a host in maintenance mode manually
hosted-engine --vm-status
hosted-engine --set-maintenance --mode=global
hosted-engine --vm-status

# Remove maintenance mode
hosted-engine --set-maintenance --mode=none
hosted-engine --vm-status

# upgrade hosted-engine
hosted-engine --set-maintenance --mode=none
hosted-engine --vm-status
engine-upgrade-check
dnf update ovirt\*setup\* # update the setup package
engine-setup # launch it to update the engine
```

* /!\ Connect individually to KVM *Virtmanager* does not work OVirt use libvirt but not like KVM do... 

* `Virt-viewer` on windows allow to connect to the console VM in SPICE:

```powershell
# install it in powershell as admin
winget source update
winget install virt-viewer
```

## Certificates / CA

* Following errors - during upload images:

```log
grep -Rn UPLOAD_IMAGE_NETWORK_ERROR /var/log/ovirt-engine
/var/log/ovirt-engine/engine.log:22989:2025-05-14 17:01:56,169+02 ERROR [org.ovirt.engine.core.dal.dbbroker.auditloghandling.AuditLogDirector] (default task-311) [028c1226-ac31-48c4-a3c6-b5b5fa915062] EVENT_ID: UPLOAD_IMAGE_NETWORK_ERROR(1,062), Unable to upload image to disk 3e44e86d-1a9b-4656-a3c2-0486c970b988 due to a network error. Ensure ovirt-engine's CA certificate is registered as a trusted CA in the browser. The certificate can be fetched from https://VIRMA.example.com/ovirt-engine/services/pki-resource?resource=ca-certificate&format=X509-PEM-CA
```

```bash
# From the Hosted-engine vm:
 ovirt-imageio --show-config | jq '.tls'
{
  "ca_file": "/etc/pki/ovirt-engine/apache-ca.pem",
  "cert_file": "/etc/pki/ovirt-engine/certs/apache.cer",
  "enable": true,
  "enable_tls1_1": false,
  "key_file": "/etc/pki/ovirt-engine/keys/apache.key.nopass"
}

# The one in the ovirt-imageio config
cat /etc/pki/ovirt-engine/certs/apache.cer | openssl x509 -noout -fingerprint -sha256 -dates

# The one given by the URL
openssl s_client -connect VIRMA.example.com:443 -showcerts < /dev/null 2>&1 | openssl x509 -noout -dates -fingerprint -sha256
```
