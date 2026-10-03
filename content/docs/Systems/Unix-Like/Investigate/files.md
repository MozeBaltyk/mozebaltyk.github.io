---
date: 2023-08-27T21:00:00+08:00
title: 🚩 Files
nav_weight: 30 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
---

## Find a process blocking a file 

* with `fuser`:
```bash
fuser  -m  </dir or /files>  # Find process blocking/using this directory or files. 
fuser -cu  </dir or /files>  # Same as above but add the user  
fuser -kcu </dir or /files>  # Kill process      
fuser -v  -k -HUP -i ./      # Send HUP signal to process
			
# Output will send you <PID + letter>, here is the meaning:
#   c  current directory.
#   e  executable being run.
#   f  open file.  (omitted in default display mode).
#   F  open file for writing. (omitted in default display mode).
#   r  root directory.
#   m  mmap'ed file or shared library.
```    

* with `lsof` ( = list open file):
```bash
lsof +D /var/log          # Find all files blocked with the process and user.
lsof -a +L1 <mountpoint>  # Process blocking a FS.
lsof -c ssh -c init       # Find files open by thoses processes.
lsof -p 1753              # Find files open by PID process.
lsof -u root              # Find files open by user.
lsof -u ^user             # Find files open by user except this one.
kill -9 `lsof -t -u toto` # kill user's processes.  (option -t output only PID).
```	

* MacGyver method:
```bash
#When you have no fuser or lsof: 
find /proc/*/fd -type f -links 0 -exec ls -lrt {} \;
```		
 
## AIX specifics (`fuser`)

```bash
fuser -d /tmp                 # see the processes using the /tmp directory (AIX)
fuser -c /your_FS             # all processes with an open file in the filesystem (AIX)
fuser -cu /dev/vg01/lvol5     # also search with a filesystem or an LV
```

* `-c` == `-m` ; `-u` also shows the process user.
* to *kill* the processes: `fuser -kcu`.

## File deleted but space still held

For detecting deleted-but-still-open files (`lsof +L1`) and freeing the held space, see the **Disk Cleanup** page.
