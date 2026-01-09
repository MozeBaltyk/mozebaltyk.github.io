---
date: 2023-08-01T21:00:00+08:00
title: Inventory
navWeight: 10 # Upper weight gets higher precedence, optional.
series:
  - Devops
categories:
  - Docs
tags:
  - Ansible
  - ConfigManager
---


```bash
ansible-inventory --list | jq -r 'map_values(select(.hosts != null and (.hosts | contains(["myhost"])))) | keys[]'
```

```yaml
kafka_host: "[{{ groups['KAFKA'] | map('extract', hostvars, 'inventory_hostname') | map('regex_replace', '^', '\"') | map('regex_replace', '\\\"', '\"') | map('regex_replace', '$', ':'+ kafka_port +'\"') | join(', ') }}]"

elasticsearch_host: "{{ groups['ELASTICSEARCH'] | map('extract', hostvars, 'inventory_hostname') | map('regex_replace', '^', '\"') | map('regex_replace', '\\\"', '\"') | map('regex_replace', '$', ':'+ elasticsearch_port +'\"') | join(', ') }}"
```
