---
date: 2023-08-01T21:00:00+08:00
title: Bash Shortcut
nav_weight: 10 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Linux
  - Shell
---

## Most usefull shortcuts

`Ctrl + r`              : Reverse search. (ctrl+r to go back through the history).    
`Ctrl + l`              : Clear the screen (instead of using the "clear" command).    
`Ctrl + p`              : Repeat the last command.     
`Ctrl + x + Ctrl + e`   : Edit the current command in an external editor (need to define `export EDITOR=vim`).      
`Ctrl + shift + v`      : Copy / paste in Linux.         
`Ctrl + a`              : Move to the beginning of the line.   
`Ctrl + e`              : Move to the end of the line.   
`Ctrl + xx`             : Move to the opposite end of the line.   
`Ctrl + left`           : Move left one word.    
`Ctrl + right`          : Move right one word.     
    
`Ctrl + u`              : Cut from cursor to beginning of line.     
`Ctrl + k`              : Cut from cursor to end of line.     
`Ctrl + w`              : Cut from cursor to start of word (delete backwards 1 word).      
`Alt  + d`              : Cut from cursor to end of word.    
`Ctrl + y`              : Paste the text cut with the previous commands.        
`Ctrl + /`              : Undo.      
        
`Alt + b`               : move one word backwards.        
`Alt + f`               : go forward one word.      
`Alt + t`               : Transpose the 2 words before or under the cursor.     
`Alt + u`               : UPPERCASE from cursor to end of word.      
`Alt + l`               : Lowercase from cursor to end of word.        
`Alt + .`               : Last word of the previous command.          
      
`Ctrl + s`              : Stop the output (for long verbose commands).      
`Ctrl + q`              : Resume the output (if previously stopped).      
`Ctrl + c`              : Terminate the command.     
`Ctrl + z`              : Suspend/stop the command.     

## Recall from the History
   
`!!`                   : Repeat the last command.      
`!-n`                  : Repeat the command triggered "n" lines back.    
`!str`                 : Repeat the last command starting with "str".      
`!str:2`               : Repeat the last command starting with "str", but take only the second argument.     
`!?str?`               : Repeat the last command containing "str".     
`!*`                   : All arguments of the previous command.     
`!^`                   : First argument of the previous command.        
`!$`                   : Last argument of the previous command.      
`!:x-y`                : Arguments from 'x' until 'y' of the previous command.     
`!:r`                  : Remove the suffix, leaving the basename.    
`!:e`                  : Remove all but the trailing suffix.    
`!:h`                  : Remove a trailing pathname component, leaving only the head. Can be used twice or more.      
`!:t`                  : Remove all leading pathname components, leaving the tail (the name of the file).     
`!$:h`                 : Take the head of the last argument of the last command.    

## Configure your bash history

in your `.bashrc`

```bash
export HISTTIMEFORMAT='%F %T '        # Timestamp in history
export HISTSIZE=450
export HISTFILESIZE=450
export HISTFILE=/root/.commandline_warrior
export HISTCONTROL=ignoredups         # ignore repeated commands consecutively in the history
export HISTCONTROL=erasedups          # ignore repeated commands in the whole history 
export HISTIGNORE="pwd:ls:ls -ltr:"   # ignore some commands

shopt -s histappend                   # history append (instead of being overwritten each time)

# Auto-increment (and not at the end of the session)
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

history -c                            # clear the history
```