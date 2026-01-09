---
date: 2023-08-01T21:00:00+08:00
title: Certificates Authority
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Systems
  - Unix-Like
  - Certificates
---


## Trust a CA on Linux host

```bash
# [RHEL] RootCA from DC need to be installed on host: 
cp my-domain-issuing.crt /etc/pki/ca-trust/source/anchors/my_domain_issuing.crt
cp my-domain-rootca.crt /etc/pki/ca-trust/source/anchors/my_domain_rootca.crt
update-ca-trust extract

# [Ubuntu] 
sudo apt-get install -y ca-certificates
sudo cp local-ca.crt /usr/local/share/ca-certificates
sudo update-ca-certificates
```


