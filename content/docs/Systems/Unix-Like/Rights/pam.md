---
date: 2023-08-15T21:00:00+08:00
title: 🔐 PAM
nav_weight: 30 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
---

## /etc/pam.d

In `/etc/pam.d`, there is one PAM file per service.

Syntax: `module_type  control_flag  path_to_module_agent`

### Module types

* `auth` — authentication.
* `account` — account-based restrictions (validity, time of day, etc.).
* `session` — things that run at login/logout.
* `password` — password updates.

### Control flags

* `required` — success needed; a failure is reported but only after the rest of the stack has run.
* `requisite` — like `required`, but a failure returns immediately without running the rest of the stack.
* `sufficient` — if this module succeeds, it is the last module tested in the stack.
* `optional` — its result is only taken into account if no other module succeeded or failed.
* `[value=action value=action2 ...]` — advanced control: map a module result to a specific action.

Sample:

```bash
account [default=bad \
         success=ok  \
         user_unknown=ignore \
         service_err=ignore  \
         system_err=ignore   \
         authinfo_unavail=ignore] /lib/security/$ISA/pam_ldap.so
```

## pam_faillock — account lockout

```bash
# /etc/pam.d/password-auth
auth        required      pam_env.so
auth        required      pam_faillock.so preauth silent audit deny=5
auth        sufficient    pam_unix.so nullok try_first_pass
auth        [default=die] pam_faillock.so authfail audit deny=5
auth        sufficient    pam_faillock.so authsucc audit deny=5
auth        requisite     pam_succeed_if.so uid >= 1000 quiet_success
auth        required      pam_deny.so

account     required      pam_access.so
account     required      pam_faillock.so
```

```bash
faillock --user <user>          # show the failed-login counter.
faillock --user <user> --reset  # reset it.
```

`pam_faillock` is the modern replacement for the deprecated `pam_tally2`.