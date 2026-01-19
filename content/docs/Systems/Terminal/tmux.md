---
date: 2023-08-01T21:00:00+08:00
title: TMUX
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


# Tmux
git clone https://github.com/tmux-plugins/tmux-logging.git

### Commandes line 
 
**`tmux new -s ma_session`**        : Create new session.      
**`tmux attach`**                   : Attach to the last used session.     
**`tmux attach -t X`**              : Attach to ymux sessions with X number.   
**`tmux ls`**                       : List active tmux sessions.        
**`tmux split-window -dh "!!"`**    : Run command in separate panel.      
**`tmux source-file ~/.tmux.conf`** : Reload config  

### Base Commandes with key-binding

**`C-b w`**       : List sessions/panels.       
**`C-b x`**       : Close panel or session.       
     
**`C-b d`**       : Se dettacher de la Session tmux  
**`C-b C-z`**     : Hang Session  
**`C-b $`**       : Rename Session  
   
**`C-b c`**       : Open new windows.   
**`C-b n`**       : Switch between window´s session.     
**`C-b ,`**       : Rename windows.    
**`C-b X`**       : Choose windows with number X.     
**`C-b t`**       : Display time in windows.    
      
**`C-b »`**       : Split vertical in terminal -> Panel        
**`C-b %`**       : Split horizontal in terminal -> Panel       
**`C-b o`**       : Switch between panels.  
**`C-b C-o`**     : Change order in panels.    
**`C-b Flêches`** : Move between panels.      
**`C-b espace`**  : Switch Layout.     
**`C-b !`**       : Break panels into windows.      
**`C-b z`**       : Zoom on panel.    
**`C-b &`**       : Close all panels from a window.    
      
**`C-b ?`**       : See all "Bind-key".     
      
**`C-b [`**       : Scroll up/down (q or Enter to quit).    
* /!\ or add to your `.tmux.conf` this setting `set -g mouse on`.    

## Usefull Changes in your config  
 
  * change key-binding **`C-b`** to **`C-q`**  (closer on AZERTY or QWERTY).     
  * vertical split with `-` instaed of `"`.           
  * Add new shorcut :  
      * **`C-b r`** : reload  
      * **`C-b /`** : look for in `man`  
      * **`C-b s`** : Sync between panels. 

## Command your Tmux

  * **`C-b : `**  :  Pass a command to Tmux.  
  * `setw synchronize-panes` :  (de-)acitvate sync between panels.      

```Bash  
# Put in your .tnux.conf - to Bind "l" open 4 SSH connexions and sync between panels 
bind l new-window 'ssh server1' \; split-window 'ssh server2' \; split-window 'ssh server3' \; split-window 'ssh server4' \; rename-window LOGS \; select-layout tiled \; setw synchronize-panes
```

`tmux source-file ~/.tmux.conf;`  : reload config

```Bash
# Fonction Tmux, à mettre dans le .bashrc
function txh {
    tmux split-window -dh "$*"
}
function txv {
    tmux split-window -dv "$*"
}
#$ tmw watch uptime
#$ tmw htop
#$ tmw rsync -arvz source::mnt/location /home/tom/destination

if [ -z "$TMUX" ]; then
    tmux attach -t default || tmux new -s default
fi
```


## My .Tmux.conf

```bash
set-option -g mouse on

# List of plugins
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-logging'
set -g @plugin 'dracula/tmux'

# Config Dracula Theme
set -g @dracula-show-left-icon session
set -g @dracula-plugins "git kubernetes-context cpu-usage ram-usage network-bandwidth"
set -g @dracula-git-colors "green dark_gray"
set -g @dracula-kubernetes-context-colors "cyan dark_gray"
set -g @dracula-cpu-usage-colors "red dark_gray"
set -g @dracula-ram-usage-colors "orange dark_gray"
set -g @dracula-network-bandwidth-colors "yellow dark_gray"
set -g @dracula-show-flags true
set -g @dracula-show-empty-plugins false

# switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Set 256 colors
set -s default-terminal 'tmux-256color'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run -b ~/.tmux/plugins/tpm/tpm
```