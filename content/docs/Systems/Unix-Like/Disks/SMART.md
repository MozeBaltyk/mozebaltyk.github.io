---
date: 2023-08-29T21:00:00+08:00
title: 🧪 SMART
navWeight: 510 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Systems
  - Unix-Like
  - Disks
  - Storage
---

S.M.A.R.T. is a technology that allows you to monitor and analyze the health and performance of your hard drives. It provides valuable information about the status of your storage devices. Here are some useful commands and tips for using S.M.A.R.T. with `smartctl`:

## Display S.M.A.R.T. Information

To display S.M.A.R.T. information for a specific drive, you can use the following command:

```shell
smartctl -a /dev/sda
```

This command will show all available S.M.A.R.T. data for the `/dev/sda` drive.

## Check if a Disk Supports S.M.A.R.T.

Before running S.M.A.R.T. tests, you should check if your disk supports S.M.A.R.T. Use the following commands:

For IDE disks:

```shell
smartctl -i /dev/hda
```

For SATA disks:

```shell
smartctl -i -d ata /dev/sda
```

If SMART support is available, you'll see the message: "SMART support is: Available – device has SMART capability." To enable SMART if it's not already enabled, use:

For IDE disks:

```shell
smartctl -s on /dev/hda
```

For SATA disks:

```shell
smartctl -s on -d ata /dev/sda
```

To get all SMART details of your drive:

For IDE disks:

```shell
smartctl -a /dev/hda
```

For SATA disks:

```shell
smartctl -a -d ata /dev/sda
```

## Run S.M.A.R.T. Tests

To run various S.M.A.R.T. tests on your hard drive, you can use the following commands:

- Short test:

```shell
smartctl -t short /dev/sda
```

- Long test:

```shell
smartctl -t long /dev/sda
```

## Health Check

To perform a health check on your hard drive, use:

```shell
smartctl -H /dev/sda
```

If the hard drive status is healthy, it will return "PASSED." If there are issues, consider running additional tests.

## Viewing Error Logs

To view the SMART Error Log, use:

```shell
smartctl -l error /dev/sda
```

If "No Errors Logged" is printed, your hard drive is likely healthy. Investigate further if there are errors.

## Automatically Monitor Your Drives

You can set up automatic monitoring of your drives using the `smartd` daemon. Edit the configuration in `/etc/smartd.conf`. Here's a sample configuration to get you started:

```shell
DEVICESCAN -H -l error -l selftest -t -m myuser@gmail.com -M exec /bin/mail -s (S/../.././02|L/../../6/03)
```

This configuration checks attributes and sends an email notification to `myuser@gmail.com` if issues are detected.

To start the `smartd` daemon:

```shell
/etc/rc.d/smartd restart
```

Remember to remove the `-M test` option from the configuration after testing.


These commands will provide comprehensive information about your drive's SMART attributes.

For more information and advanced options, refer to the `man smartctl` command.

---

## Sources 

Some [blog](https://dineshjadhav.wordpress.com/smartctl/) on the topic.
