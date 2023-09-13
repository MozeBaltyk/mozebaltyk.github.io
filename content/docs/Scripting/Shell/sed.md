---
date: 2023-08-01T21:00:00+08:00
title: 🐴 Sed
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Shell
categories:
  - Scripting
---

## The Basics
```bash
sed -e '…' -e '…'  # Several execution 
sed -i             # Replace in place 
sed -r             # Play with REGEX

# The most usefull
sed -e '/^[ ]*#/d' -e '/^$/d' <fich.>    #   Ouvrir un fichier sans les lignes vides ou avec commentaires
sed 's/ -/\n -/g'                        #   remplace tous les "-" par un saut de ligne
sed 's/my_match.*/ /g'                   #   depuis le match jusqu'a la fin de ligne
sed -i '4048d;3375d' ~/.ssh/known_hosts  #   supprimer les lignes N 

# Buffer 
s/.*@(.*)/$1/;                           #   garde ce qui a après le @ .  ( ) met dans le buffer $1 et peut etre reutiliser après. 
sed -e '/^;/! s/.*-reserv.*/; Reserved: &/' file.txt  #  Reutilise la recherche avec &

# Recherche une ligne
sed -e '/192.168.130/ s/^/#/g' -i /etc/hosts          # Comment a line 
sed -re 's/^;(r|R)eserved:/; Reserved:/g' file.txt    # Search several string

# Append / Insert
sed -i '/.*\"description\".*/s/$/ \n  \"after\" : \"network.target\"\,\n  \"requires\" : \"network.target\"\,/g'  my_File  
 =>  ajouter deux lignes en dessous d'un match pattern

#!/bin/sh
sed '
/WORD/ a\
Add this line after every line with WORD
'

sed -e '/remember=10/!s/use_authtok/& remember=10/' -i /etc/pam.d/system-auth-permanent : Si l'occurrence n'est pas, l'ajoute apres "use_authtok". 
```
