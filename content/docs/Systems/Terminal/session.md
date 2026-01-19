---
date: 2023-08-01T21:00:00+08:00
title: Sessions
navWeight: 900 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Systems
  - Terminal
  - Produtivity
---

## Register your session

Usefull to keep a track or document and share what have been done.

`script`     : save all commandes and result in a "typescript" file.        
`script -a`  : append to an existing "typescript" file (otherwise erase previous one).  
`exit`       : to stop session. 

`asciinema`  :  save the terminal session in video.  

For RHEL - something like Tlog exists and can be configure and centralised with Rsyslog.

## Terminal 

`/etc/DIR_COLORS.xterm` define terminal colors
`dircolors` change colors in the `ls` output

Define terminal:
```bash
# Activate vi
set -o vi

# Desactive vi
set +o vi           

# Activate emacs
set -o emacs 
```

## Communicate with other sessions

* Send a message to all connected people to the server:

```bash
wall    
< write your message >   
Ctrl +d
```   

* Send a message to a specific user (ttyp2 or pts/1 or getty): 

```bash
write <user> ttyp2   
<taper son message>  
Ctrl +d 
```    

* Accept message or not on your terminal `mesg <y or n>`. `finger` if there is a `*` mean the user refuse to receive message. 

* by mail
```bash
uuencode test.txt test.txt | mailx -s "test" toto@example.com                           # mail with attach file (mailx > 12.x)
uuencode test.txt test.txt; mailx -a test.txt -s "test" toto@example.com < /dev/null    # mail with attach file (mailx < 12.x)
```

## TTY / STTY
  
when you are in ksh on some old system nothing is define. So you need to map by yourself:

```bash
# list all stty possible
stty -a    

# make Backspace touch erase 
stty erase [la touche backspace] [Enter]   

# everything what you type is not visible
stty –echo

# get the visibilty back
stty echo 
```

## Les Profiles 
	
`/etc/profile`     - common to all users.      
`~/.profile`       - user´s profile execute if .bash_profile does not exist.      
`/etc/bash.bashrc` or `~/.bashrc ` - interactif non-login Shells. ( when terminal is open or `bash` cmd).     
`~/.bash_profile`  - executed when login to Shell.      
`TMOUT=300`        - session TimeOut.    
`sources .bashrc`  - Reload `.bashrc`.    

when you want `.bashrc` to trigger all the time, to put in `.bash_profile`:
```bash
if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi
```

## Definition des Alias 

```bash
# define an alias
alias  ll=`ls -lrt`;  

# cumule command
alias  mon_script=`cd /le/repertoire/de/mon/script; ./mon_script;  cd -`; 

alias                  # List all aliases ongoing
type <alias_name>      # give some info on alias
alias <alias_name>     # give content of an alias
unalias <alias_name>   # delete an alias
```

---

## Sources

[Blog](https://angristan.fr/asciinema-enregistrer-partager-sessions-terminal/)