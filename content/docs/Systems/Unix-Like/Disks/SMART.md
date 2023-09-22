---
date: 2023-08-29T21:00:00+08:00
title: 🧪 SMART
navWeight: 510 # Upper weight gets higher precedence, optional.
series:
  - Unix-Like
  - Disk
categories:
  - Systems
---


## S.M.A.R.T 

smartctl      :     smartctl permet d’afficher les informations smart d’un disque. 
smartctl -a /dev/sda   :  affiche toutes les informations à propos de sda.

La fiche Wikipedia à propos du SMART fournit de bonnes explications sur les différentes données et leur interprétation.

sudo smartctl -i /dev/sda
sudo smartctl -d TYPE -i /dev/sda
sudo smartctl -s on -o on -S on /dev/sda   :   if smartctl is not enable.
sudo smartctl -H /dev/sda   :   health check.
sudo smartctl -c /dev/sda    :   ofline
sudo smartctl -t short /dev/sda
sudo smartctl -l selftest /dev/sda
sudo smartctl -t long /dev/sda
# smartctl –test=short /dev/sda
# smartctl –test=long /dev/sda
# smartctl -a /dev/sda
# smartctl -A /dev/sda

SATA Health Check Disk Syntax
# smartctl -d sat –all /dev/sda
# smartctl -d sat –all /dev/sda

Run test:
# smartctl -d sat –all /dev/sg1 -H

For SAS disk use the following syntax:
# smartctl -d scsi –all /dev/sgX
# smartctl -d scsi –all /dev/sg1
# smartctl -d scsi –all /dev/sg1 -H

Disk support
Check if your disk(s) support SMART.
IDE-disks:   # smartctl -i /dev/hda
SATA-disks:  # smartctl -i -d ata /dev/sda

If it is, you will see:
“SMART support is: Available – device has SMART capability.”
“SMART support is: Enabled”

If SMART is not enabled you can enable it by:
IDE-disks:  # smartctl -s on /dev/hda
SATA-discs:  # smartctl -s on -d ata /dev/sda

Test the hard drive
Your SMART hard disk may have built-in self-tests that do some checks to record the state of the hard disk and may optionally protect it from common problems (i.e. bad blocks). If you do not know for certain, have smartctl run tests to update the SMART Attributes on your hard disk.

To know first which tests the device supports:  # smartctl -c /dev/
To run the test:  # smartctl -t offline /dev/

smartctl will tell you how long the test will take. When it is finished you can check the health status to see if there are any problems.
Note: Most smartctl commands require the -d ata or -d sat options to identify drives that are not IDE.

Health status check
SMART hard disks keep a record of the hard disks health status that can be checked with:    # smartctl -H /dev/sda

If the hard drive status is healthy it will return the status as: ‘PASSED’.
If the device reports a failing health status, it means that the device has either already failed, or is predicting its own failure within the next 24 
hours. Append the “-a” option to get more information.

To see if the SMART sensor has detected any errors, look at the SMART Error Log:   # smartctl -l error /dev/sda

If “No Errors Logged” is printed, your hard drive is likely healthy. If there are a few errors this may or may not indicate a problem and you should investigate the matter further. Generally when a drive starts to fail it is best practice to backup its data and replace the hard drive.
Note: See man smartctl for other tests and more information.

Automatically monitor your drives
smartmontools includes a daemon that will check and update your hard disks status and can optionally mail you of any potential problems. The smart daemon can be edited for more exact configuration in /etc/smartd.conf.
If the configuration is not edited, smartd will run tests periodically on all possible SMART Attributes on all devices it detects. The first non-commented entry in the configuration file (DEVICESCAN) will have smartd ignore the remaining lines in the configuration file, and will scan for devices. For devices with an ATA Attachment, if no options are configured, the daemon will use the ‘-a’ option by default (monitor all SMART properties) on all hard drives.

In order to have the drives checked only when they are not in standby (hence avoid them to spin up unnecessarily), you may add the following options:    DEVICESCAN -n standby,q -a

To make a configuration for individual devices, you have to comment the line with DEVICESCAN and add a configuration line for every device. It is recommended to reference devices by the ID (which is derived from the device’s model and serial number) rather than a udev name, since the latter is not guaranteed to refer to the same physical device across reboots. Here is an example:
DEVICESCAN /dev/disk/by-id/scsi-SATA_Hitachi_HTS5432090609FB22015CCNRD6A -a -m root@localhost


DEVICESCAN -H -l error -l selftest -t -m chris@gmail.com -M exec /bin/mail -s (S/../.././02|L/../../6/03)
	=> fait un test cours tous les jours a 2h (S/../.././02) ou un test long le samedi a 03h (L/../../6/03)
	
This will monitor all attributes and send an email to root@localhost if a failure or new error occurs. To be able to send internal mail, you need a mail sender (like SSMTP or Msmtp) installed, or a mail server (MTA Message Transfer Agent) like sendmail or Postfix Local Mail. More examples are given in the configuration file.
Once you can send mails out, you can change the root@localhost by your actual email address:       DEVICESCAN -n standby,q -a -m myuser@gmail.com

Start the smartd daemon and add smartd to your DAEMONS array so it starts automatically on boot.
Last but not least, if you used the -m option to get mail notifications, you should test that the mail alert works fine. To do so, simply add the ‘-M test’ option to the configuration line and restart smartd daemon:    DEVICESCAN -n standby,q -a -m myuser@gmail.com -M test

To restart the daemon:   # /etc/rc.d/smartd restart

The mail test result can be seen in your mailbox (be a bit patient) but also in /var/log/daemon.log :
Feb 1 20:07:11 localhost smartd[2306]: Monitoring 3 ATA and 0 SCSI devices
Feb 1 20:07:11 localhost smartd[2306]: Executing test of mail to myuser@gmail.com …
Feb 1 20:07:14 localhost smartd[2306]: Test of mail to myuser@gmail.com: successful

Once the test succeeded, do not forget to remove the ‘-M test’ option.
Smartd uses “mail” (mailx) to send messages, which expects sendmail to be installed. If you use Msmtp, tell mail to use it:
/etc/mail.rc
set sendmail=/usr/bin/msmtp

Other tips
You can get all SMART details of your drive with:
IDE-disks:    # smartctl -a /dev/hda
SATA-discs:    # smartctl -a -d ata /dev/sda

Pasted from <https://dineshjadhav.wordpress.com/smartctl/> 
