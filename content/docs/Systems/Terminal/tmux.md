---
date: 2023-08-01T21:00:00+08:00
title: 🪟 Tmux
nav_weight: 50 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
  - Shell
---


# Tmux
git clone https://github.com/tmux-plugins/tmux-logging.git

### Command line
 
**`tmux new -s my_session`**       : Create a new session.      
**`tmux attach`**                  : Attach to the last used session.     
**`tmux attach -t X`**             : Attach to the tmux session with number X.   
**`tmux ls`**                      : List active tmux sessions.        
**`tmux split-window -dh "!!"`**   : Run a command in a separate pane.      
**`tmux source-file ~/.tmux.conf`** : Reload config.

### Basic Commands with key-bindings

**`C-b w`**       : List sessions/panes.       
**`C-b x`**       : Close pane or session.       
     
**`C-b d`**       : Detach from the tmux session.  
**`C-b C-z`**     : Hang session.  
**`C-b $`**       : Rename session.  
   
**`C-b c`**       : Open a new window.   
**`C-b n`**       : Switch between windows/sessions.     
**`C-b ,`**       : Rename window.    
**`C-b X`**       : Choose window with number X.     
**`C-b t`**       : Display time in the window.    
       
**`C-b "`**       : Split into top/bottom panes.        
**`C-b %`**       : Split into left/right panes.      
**`C-b o`**       : Switch between panes.  
**`C-b C-o`**     : Change the order of the panes.    
**`C-b arrows`**  : Move between panes.      
**`C-b space`**   : Switch layout.     
**`C-b !`**       : Break a pane into its own window.      
**`C-b z`**       : Zoom on a pane.    
**`C-b &`**       : Close all panes of a window.    
       
**`C-b ?`**       : See all key-bindings.     
       
**`C-b [`**       : Scroll up/down (q or Enter to quit).    
* /!\ or add to your `.tmux.conf` this setting `set -g mouse on`.    

## Useful Changes in your config  
 
  * change the key-binding **`C-b`** to **`C-q`** (closer for AZERTY or QWERTY).     
  * vertical split with `-` instead of `"`.           
  * Add new shortcuts :  
      * **`C-b r`** : reload  
      * **`C-b /`** : look up in `man`  
      * **`C-b s`** : sync between panes. 

## Command your Tmux

  * **`C-b : `**  :  Pass a command to Tmux.  
  * `setw synchronize-panes` :  (de)activate sync between panes.      

```bash
# Put in your .tmux.conf - to bind "l" to open 4 SSH connections and sync between panes
bind l new-window 'ssh server1' \; split-window 'ssh server2' \; split-window 'ssh server3' \; split-window 'ssh server4' \; rename-window LOGS \; select-layout tiled \; setw synchronize-panes
```

`tmux source-file ~/.tmux.conf;`  : reload config.

```bash
# Tmux functions, to put in the .bashrc
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


## My .tmux.conf

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