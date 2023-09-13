---
date: 2023-08-01T21:00:00+08:00
title: 🐦 Awk
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Shell
categories:
  - Scripting
---


## Example

```bash
# Several conditions AND/OR 
lsblk -lnb | awk '/disk/ &&  $4=='380968960' || $4=='2147487744' {print $1}'

# Search for a REGEX and Substitute before to print last column
 curl -Lis https://github.com/ | awk '/<title>.*GitHub<\/title>/ {sub(/<\/title>/,"");print $NF}'

# Find a word after a search
awk '{for (I=1;I<NF;I++) if ($I == "as") print $(I+1)}'

# Similar Output than command id:
# - END is the output display at the end 
# - several if conditions 
awk -F: 'END {print "uid:"u" gid:"g" groups:"gg}{if($1=="Uid"){split($2,a," ");
u=a[1]}if($1=="Gid"){split($2,a," ");
g=a[1]}if($1=="Groups"){gg=$2}}' /proc/self/status
```

## Alternative to AWK

```bash
# Get everything after third delimiter "_"
ps -ef | grep ora_pmon | grep -v grep  | awk '{print $NF}' | cut -d"_" -f3-

# Cut the 2 last characters 
hostname -s | rev | cut -c 3- | rev

# Same thing simplier
echo ${HOSTNAME:: -2}

# Result => 172.16.230
ip -4 -o addr show | grep ${nic_interconnect} | awk '{print $4}'| sed 's/\/30$//' | cut -d'.' -f-3

# Result =>  230.61
ip -4 -o addr show | grep ${nic_interconnect} | awk '{print $4}'| sed 's/\/30$//' | cut -d'.' -f3-
```

* Use case with a small script to backup and push resolv.conf
```bash
#!/bin/bash
for line in `cat expect_dns_no_nm.csv`; do
hostname=`echo $line | cut -d";" -f1`
username=`echo $line | cut -d";" -f2`
password=`echo $line | cut -d";" -f3`
 
./expect.us ssh $hostname $username $password "cp /etc/resolv.conf /etc/resolv.conf.20151103"
./expect.us scp $hostname $username $password source/resolv.conf /etc/resolv.conf
done
```