---
date: 2023-08-01T21:00:00+08:00
title: Bash Shortcurt
navWeight: 1200 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Systems
  - Terminal
  - Produtivity
---

## Most usefull shortcut

`Ctrl + r`              : Search and reverse. (ctrl+r pour remonter l'history).    
`Ctrl + l`              : Clear the screen (instead to use “clear” command).    
`Ctrl + p`              : Repeat last command.     
`Ctrl + x + Ctrl + e`   : Edit the current command on an external editor. (Need to define export EDITOR=vim ).      
`Ctrl + shift + v`      : Copy / paste in linux.         
`Ctrl + a`              : Move to the begin of the line.   
`Ctrl + e`              : Move to the end of the line.   
`Ctrl + xx`             : Move to the opposite end of the line.   
`Ctrl + left`           : Move to left one word.    
`Ctrl + right`          : Move to right one word.     
    
`Ctrl + u`              : Cut from cursor to begin of line.     
`Ctrl + k`              : Cut from cursor to end of line.     
`Ctrl + w`              : Cut from cursor to start of word (delete backwards 1 word).      
`Alt  + d`              : Cut from cursor to end of word.    
`Ctrl + y`              : Paste text cut using previous commands.        
`Ctrl + /`              : Undo.      
        
`Alt + b`               : move one word behind.        
`Alt + f`               : go ahead one word.      
`Alt + t`               : Transposes the 2 words before or under the cursor.     
`Alt + u`               : UPPERCASE from cursor to end of word.      
`Alt + l`               : Lowercase from cursor to end of word.        
`Alt + .`               : Last word of the previous command.          
      
`Ctrl + s`              : Stop the output (for long verbosing commands).      
`Ctrl + q`              : Allow the output (if previously stopped).      
`Ctrl + c`              : Terminate the command.     
`Ctrl + z`              : Suspend/stop the command.     

## Rappel in the History
   
`!!`                   : Repeat last command.      
`!-n`                  : Repeat the command triggered "n" lines back.    
`!str`                 : Repeat last command starting with "str".      
`!str:2`               : Repeat Last command starting with "str" but take only the second arguments.     
`!?str?`               : Repeat last command containing "str".     
`!*`                   : All arguments of the previous command.     
`!^`                   : First argument of the previous command.        
`!$`                   : Last argument of the previous command.      
`!:x-y`                : Argument from 'x' until 'y' of the previous command.     
`!:r`                  : Remove the suffix leaving the basename.    
`!:e`                  : Remove all but the trailing suffix.    
`!:h`                  : Remove a trailing pathname component, leaving only the head. Can be used twice or more.      
`!:t`                  : Remove all leading pathname components, leaving the tail (the name of the file).     
`!$:h`                 : Take the head of the last argument of the last command.    

## Configure your bash history

in your `.bashrc`

```bash
export HISTTIMEFORMAT='%F %T '        # Horodatage in history
export HISTSIZE=450
export HISTFILESIZE=450
export HISTFILE=/root/.commandline_warrior
export HISTCONTROL=ignoredups         # ignore repeated commandes consecutively in the history
export HISTCONTROL=erasedups          # ignore repeated commandes in the all history 
export HISTIGNORE="pwd:ls:ls -ltr:"   # ignorer somes commandes

shopt -s histappend                   # history Append (au lieu d'etre eccrasse a chaque fois)

# Auto-increment (and not at the end of the session)
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

history -c                            # clear le history
```
