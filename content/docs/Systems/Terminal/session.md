---
date: 2023-08-01T21:00:00+08:00
title: 🗒️ Sessions
nav_weight: 40 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
  - Shell
---

## Register your session

Useful to keep a trace, or to document and share what has been done.

`script`     : save all commands and results in a "typescript" file.        
`script -a`  : append to an existing "typescript" file (otherwise erase the previous one).  
`exit`       : to stop the session. 

`asciinema`  :  save the terminal session as a video.  

For RHEL - something like Tlog exists and can be configured and centralised with Rsyslog.

## Terminal 

`/etc/DIR_COLORS.xterm` defines the terminal colors.
`dircolors` changes the colors in the `ls` output.

Define the terminal:
```bash
# Activate vi
set -o vi

# Deactivate vi
set +o vi           

# Activate emacs
set -o emacs 
```

## Communicate with other sessions

* Send a message to all people connected to the server:

```bash
wall    
< write your message >   
Ctrl + d
```   

* Send a message to a specific user (ttyp2 or pts/1 or getty): 

```bash
write <user> ttyp2   
<type your message>  
Ctrl + d 
```    

* Accept messages or not on your terminal: `mesg <y or n>`. `finger` - if there is a `*`, it means the user refuses to receive messages. 

* by mail
```bash
uuencode test.txt test.txt | mailx -s "test" toto@example.com                           # mail with attached file (mailx > 12.x)
uuencode test.txt test.txt; mailx -a test.txt -s "test" toto@example.com < /dev/null    # mail with attached file (mailx < 12.x)
```

## TTY / STTY
  
when you are on ksh on some old systems, nothing is defined. So you need to map it yourself:

```bash
# list all possible stty settings
stty -a    

# make Backspace erase 
stty erase [the backspace key] [Enter]   

# everything you type is not visible
stty -echo

# get the visibility back
stty echo 
```

## Profiles 
	
`/etc/profile`     - common to all users.      
`~/.profile`       - user's profile, executed if `.bash_profile` does not exist.      
`/etc/bash.bashrc` or `~/.bashrc` - interactive non-login shells (when a terminal is opened or the `bash` command).     
`~/.bash_profile`  - executed at login to the shell.      
`TMOUT=300`        - session timeout.    
`source .bashrc`  - reload `.bashrc`.    

when you want `.bashrc` to trigger all the time, put this in `.bash_profile`:
```bash
if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi
```

## Alias definition 

```bash
# define an alias
alias  ll=`ls -lrt`;  

# chained command
alias  my_script=`cd /the/dir/of/my/script; ./my_script;  cd -`; 

alias                  # List all aliases ongoing
type <alias_name>      # give some info on an alias
alias <alias_name>     # give the content of an alias
unalias <alias_name>   # delete an alias
```

---

## Sources

[Blog](https://angristan.fr/asciinema-enregistrer-partager-sessions-terminal/)