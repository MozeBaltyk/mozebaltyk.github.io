---
date: 2023-08-01T21:00:00+08:00
title: Sessions
navWeight: 900 # Upper weight gets higher precedence, optional.
series:
  - Terminal
categories:
  - Systems
---

## Register your session

Usefull to keep a track or document and share what have been done.

`script`     : save all commandes and result in a "typescript" file.        
`script -a`  : append to an existing "typescript" file (otherwise erase previous one).  
`exit`       : to stop session. 

`asciinema`  :  save the terminal session in video.  

For RHEL - something like Tlog exists and can be configure and centralised with Rsyslog.


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
 
## Set your stty (for raccourci clavier)  
/!\ definir le stty => surtout quand on est en Ksh ou rien n'est mappe .

stty -a    : pour lister les stty possible
stty erase [la touche backspace] [Enter]   : definit la touche Erase
stty –echo : tous ce que tu tapes, n'est plus visible dans le terminal
stty echo : remet la visibilite dans le terminal

## Les Profiles 
	Ø profile https://doc.ubuntu-fr.org/variables_d_environnement
	
/etc/profile  :  Script de demarrage commun a tous les utilisateurs
~/.profile  : Fichier profile prope a l'utilisateur (il est execute si le .bash_profile n'existe pas)
/etc/bash.bashrc  ou  ~/.bashrc. : interactif non-login Shells. ( si déjà connecté et ouvres un nouveau terminal ou tapes la cmd "bash")
/etc/.bash_profile ou ~/.bash_profile : executé lors d'un login au Shell ( par console ou ssh, exec premier fois )

Pour que le .bashrc se lance tout le temps ( à mettre dans le .bash_profile ):
	if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

Variables dans Profiles
TMOUT=300 :   variable du Time Out de la Session

sources .bashrc  :  Rafraichir un Bash avec son .bashrc


## Parametrage du Terminal 
printenv               :  Voir toutes les variables d'environnement   
setenv    VAR=valeur   :  definir une variable et la passer dans les variables d'environnement.    
export PS1="\[\033[36m\]\u\[\033[0m\]@\[\033[36m\]\h:\[\033[0m\]\$PWD#>"  
(prompt utilisateur sympa,  a mettre dans   ~/.bash_profile   ou   ~/.bashrc  )

set -o vi           : active    
set +o vi           : desactive 
set -o <vi|emacs>   : definir le mode vi ou emacs pour le terminal 
(Au début d'une ligne on est en mode insertion, pour passer en mode commande il faut appuyer sur la touche échap.)

 
Couleurs Terminaux des repertoires et fichiers 
Modifier les couleurs des répertoires  =>  /etc/DIR_COLORS.xterm  (Linux)
 => dircolors    :    commande pour modifer les couleurs du "ls" 
 => voir dans l'Onglet : SHELL > [Bash] les prompts


## Sources

[Blog](https://angristan.fr/asciinema-enregistrer-partager-sessions-terminal/)