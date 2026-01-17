---
date: 2023-08-01T21:00:00+08:00
title: 🐴 Sed
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Scripting
  - Shell
---

## The Basics

```bash
sed -e '…' -e '…'  # Several execution 
sed -i             # Replace in place 
sed -r             # Play with REGEX

# The most usefull
sed -e '/^[ ]*#/d' -e '/^$/d' <fich.>    #   openfile without empty or commented lines
sed 's/ -/\n -/g'                        #   replace all "-" with new lines
sed 's/my_match.*/ /g'                   #   remove from the match till end of line
sed -i '4048d;3375d' ~/.ssh/known_hosts  #   delete lines Number

# Buffer 
s/.*@(.*)/$1/;                                        #  keep what is after @ put it in buffer ( ) and reuse it with $1.
sed -e '/^;/! s/.*-reserv.*/; Reserved: &/' file.txt  #  resuse search with &

# Search a line
sed -e '/192.168.130/ s/^/#/g' -i /etc/hosts          # Comment a line 
sed -re 's/^;(r|R)eserved:/; Reserved:/g' file.txt    # Search several string

# Insert - add two lines below a match pattern
sed -i '/.*\"description\".*/s/$/ \n  \"after\" : \"network.target\"\,\n  \"requires\" : \"network.target\"\,/g'  my_File  

# Append
sed '/WORD/ a Add this line after every line with WORD'

# if no occurence, then add it after "use_authtok" 
sed -e '/remember=10/!s/use_authtok/& remember=10/' -i /etc/pam.d/system-auth-permanent
```
