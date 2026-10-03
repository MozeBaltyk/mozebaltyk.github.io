---
date: 2023-08-08T21:00:00+08:00
title: 🔏 ISO Checksum
nav_weight: 70 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
---

## Verify an ISO image

To verify that an ISO image is good: compute its checksum with a `sha1` or `sha256` key, then compare it with the key published on the official website.

```bash
sha256sum image.iso
sha1sum image.iso
```