---
date: 2023-08-01T21:00:00+08:00
title: Cloud-Init
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Systems
  - Unix-Like
  - Cloud-Init
---


## Troubleshooting

* `cloud-init status --wait` usefull for scripting, waiting cloud-init to finish before going to next step. 

* `cloud-init status --long`

```bash
status: done
extended_status: done
boot_status_code: enabled-by-generator
last_update: Thu, 01 Jan 1970 00:00:55 +0000
detail: DataSourceNoCloud [seed=/dev/sr0]
errors: []
recoverable_errors: {}
```

* `sudo cloud-init analyze show`

```bash
-- Boot Record 01 --
The total time elapsed since completing an event is printed after the "@" character.
The time the event takes is printed after the "+" character.

Starting stage: init-local
|`->no cache found @00.00600s +00.00000s
|`->found local data from DataSourceNoCloud @00.01500s +00.12600s
Finished stage: (init-local) 00.75400 seconds

Starting stage: init-network
|`->restored from cache with run check: DataSourceNoCloud [seed=/dev/sr0] @04.21100s +00.00200s
|`->setting up datasource @04.22800s +00.00000s
|`->reading and applying user-data @04.23400s +00.00500s
|`->reading and applying vendor-data @04.23900s +00.00000s
|`->reading and applying vendor-data2 @04.23900s +00.00000s
|`->activating datasource @04.27100s +00.00100s
|`->config-seed_random ran successfully and took 0.000 seconds @04.29500s +00.00100s
|`->config-write_files ran successfully and took 0.001 seconds @04.29600s +00.00100s
|`->config-growpart ran successfully and took 0.562 seconds @04.29700s +00.56200s
|`->config-resizefs ran successfully and took 0.193 seconds @04.86000s +00.19200s
|`->config-mounts ran successfully and took 0.001 seconds @05.05200s +00.00100s
|`->config-set_hostname ran successfully and took 0.004 seconds @05.05300s +00.00500s
|`->config-update_hostname ran successfully and took 0.001 seconds @05.05800s +00.00100s
|`->config-update_etc_hosts ran successfully and took 0.005 seconds @05.05900s +00.00500s
|`->config-users_groups ran successfully and took 0.216 seconds @05.06400s +00.21600s
|`->config-ssh ran successfully and took 0.404 seconds @05.28100s +00.40400s
|`->config-set_passwords ran successfully and took 0.001 seconds @05.68500s +00.00200s
Finished stage: (init-network) 01.50000 seconds

Starting stage: modules-config
|`->config-ssh_import_id ran successfully and took 0.001 seconds @07.43300s +00.00100s
|`->config-locale ran successfully and took 0.003 seconds @07.43400s +00.00300s
|`->config-grub_dpkg ran successfully and took 0.352 seconds @07.43700s +00.35200s
|`->config-apt_configure ran successfully and took 0.049 seconds @07.79000s +00.04800s
|`->config-timezone ran successfully and took 0.007 seconds @07.83900s +00.00700s
|`->config-runcmd ran successfully and took 0.001 seconds @07.84600s +00.00100s
|`->config-byobu ran successfully and took 0.000 seconds @07.84700s +00.00100s
Finished stage: (modules-config) 00.45400 seconds

Starting stage: modules-final
|`->config-package_update_upgrade_install ran successfully and took 26.632 seconds @20.56700s +26.63300s
|`->config-write_files_deferred ran successfully and took 0.001 seconds @47.20000s +00.00200s
|`->config-reset_rmc ran successfully and took 0.000 seconds @47.20200s +00.00100s
|`->config-scripts_vendor ran successfully and took 0.001 seconds @47.20300s +00.00000s
|`->config-scripts_per_once ran successfully and took 0.000 seconds @47.20300s +00.00100s
|`->config-scripts_per_boot ran successfully and took 0.000 seconds @47.20400s +00.00000s
|`->config-scripts_per_instance ran successfully and took 0.000 seconds @47.20400s +00.00100s
|`->config-scripts_user ran successfully and took 0.558 seconds @47.20500s +00.55800s
|`->config-ssh_authkey_fingerprints ran successfully and took 0.005 seconds @47.76400s +00.00500s
|`->config-keys_to_console ran successfully and took 0.054 seconds @47.76900s +00.05500s
|`->config-install_hotplug ran successfully and took 0.001 seconds @47.82400s +00.00100s
|`->config-final_message ran successfully and took 0.001 seconds @47.82500s +00.00100s
Finished stage: (modules-final) 27.29600 seconds
```

* Check the logs: `sudo tail -n 50 /var/log/cloud-init-output.log`

* The Render of the cloud-init config: `sudo cat /var/lib/cloud/instance/cloud-config.txt`