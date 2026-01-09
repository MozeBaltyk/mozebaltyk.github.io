---
date: 2023-08-01T21:00:00+08:00
title: 🐦 Awk
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Scripting
  - Shell
---


## The Basics
    
`awk` is treat each line as a table, by default space are separators of columns.    
     
General syntax is `awk 'search {action}' file_to_parse`.    
    
```bash
# Give the value higher than 75000 in column $4
df | awk '$4 > 75000'   

# Print the all line when column $4 is higher than 75000
df | awk '$4 > 75000 {print $0}' 
```
           
But if you look for a string, the search need to be included in `/search/` or `;search;`.       
When you print `$0` represent the all line, `$1` first column, `$2` second column etc.     
    
Alternative to `awk` can be `nawk` or `gawk`.           
     
## Awk Output 

In General, as an action you want to `{ print }` as this example:   

```bash
# Print different columns
date | awk '{print "Month :" $2 "\nYear :" $6}'   

# Pass the all line in uppercase
awk '{print $0=toupper($0)}'

# Call awk script
awk -f file

# print the all lines with line number in front of.
awk '{print NR, $0}'
```   

When you print:    
* `$0` represent the all line 
* `$1` first column
* `$2` second column etc. 
* `NR` print Line number
* `NF` number of columns

## Field Seperator 

```bash
awk -v FS="|" -v OFS="*" -v IGNORECASE=1  
# -v          =  define a variable
# FS="|"      =  Field Separator
# OFS         =  Output Field Separator
# FS=OFS="|"  =  set both with same value

# Another way to define FS is with argument "-F"
awk -F';'      

# Define several FS ("space" + ":" and "tabs") 
awk -F'[ :\t]' 
```

## Example

```bash
# look in column 2 for lines with 4 caracters
awk '$2 ~ /^....$/{print $0}' awkdata.txt 

# Operator and REGEX - exclude lines which start with D or C in cloumn 2, so you get all the rest. 
awk '$2 !~ /^D|^C/{print $0}' awkdata.txt

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