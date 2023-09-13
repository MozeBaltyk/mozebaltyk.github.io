---
date: 2023-08-01T21:00:00+08:00
title: 🐦 Awk
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Shell
categories:
  - Scripting
---


## The Basics

Si on ne trouve pas awk sur la machine, il se peut qu'il y ait une version plus récente comme nawk ou (pour linux) gawk.
 
3 formats d'execusion de cette commande :
	awk 'schema_recherché' fichier_de_recherche
	awk '{action_a_effectuer}' fichier_de_recherche
	awk 'schema_recherché {action_a_effectuer}' fichier_de_recherche
 
se combine aussi avec des commandes shell : cmd | awk 'recherche'  (exemple : df | nawk '$4 > 75000') 
 
Les expressions recherchées doivent être entre / / ou ; ; 

Le document filtré est organisé comme un tableau où :
	$0  - est la ligne entière
	$1  - la première colonne
	$2  - la deuxième etc.
	
$0=toupper($0)

### Output de Awk 
print :  permet d'imprimer à l'écran ce qu'on souhaite
	exemple : date | nawk '{print "Mois :" $2 "\nAnnée :" $6}'
	Rq : il faut mettre entre guillemets le text et hors des guillements l'appel au variable.

awk '{print $0=toupper($0)}'    :  passer toute la ligne ($0) en uppercase 

Options caracteres speciaux : 
\b  - un espace en arrière
\n  - nouvelle ligne
\t  - tabulation
\c  - n'importe quel autre caractère (continue la ligne)
\r  - saut de page

### Script AWK 
awk -f  : faire appel à un script déjà écrit 
 
### Les variables d'enregistrements
awk '{print NR, $0}'  :  donnera le numero de ligne devant chaque ligne
NF   :  donne le nombre de colonne

awk -v FS="|" -v OFS="*" -v IGNORECASE=1  :   -v defini une variable
	FS="|" /!\ par contre le resultat remplace le | par un espace
	OFS  : le Output Field Separator
	FS=OFS="|" Au final, on peut faire 

### FS Field Separator
awk -F   : choisir les champs séparateurs
awk -F:  : définit les ":" comme séparateur
awk -F'[ :\t]'  :  définit les espaces, ":", et les tabulations comme séparateur.

Autre methode - utiliser les variables FS et OFS. 

/!\ Les Métacaractères restent les mêmes sauf que \<, \>, \(,\), \{,\} ne sont pas utilisable avec awk

### Operators
~  - opérateur de combinaison
!  - exclu 

exemple : awk '$2 !~ /^D|^C/{print $0}' awkdata.txt => les lignes qui commencent par D ou C dans la colonne 2 sont exclu de la recherche, donc resort toutes les autres lignes.

exemple 2 : awk '$2 ~ /^....$/{print $0}' awkdata.txt => va chercher dans la colonne 2 les lignes à 4 caractères.  
 
find . -printf "%u %s\n" | awk '{user[$1]+=$2}; END{ for( i in user) print i " " user[i]}'


## Example

```bash
# Several conditions AND/OR 
lsblk -lnb | awk '/disk/ &&  $4=='380968960' || $4=='2147487744' {print $1}'

# Search for a REGEX and Substitute before to print last column
 curl -Lis https://github.com/ | awk '/<title>.*GitHub<\/title>/ {sub(/<\/title>/,"");print $NF}'

# Find a word after a search
awk '{for (I=1;I<NF;I++) if ($I == "as") print $(I+1)}'

# Similar Output than command id:
# - END is the output display at the end 
# - several if conditions 
awk -F: 'END {print "uid:"u" gid:"g" groups:"gg}{if($1=="Uid"){split($2,a," ");
u=a[1]}if($1=="Gid"){split($2,a," ");
g=a[1]}if($1=="Groups"){gg=$2}}' /proc/self/status
```

## Alternative to AWK

```bash
# Get everything after third delimiter "_"
ps -ef | grep ora_pmon | grep -v grep  | awk '{print $NF}' | cut -d"_" -f3-

# Cut the 2 last characters 
hostname -s | rev | cut -c 3- | rev

# Same thing simplier
echo ${HOSTNAME:: -2}

# Result => 172.16.230
ip -4 -o addr show | grep ${nic_interconnect} | awk '{print $4}'| sed 's/\/30$//' | cut -d'.' -f-3

# Result =>  230.61
ip -4 -o addr show | grep ${nic_interconnect} | awk '{print $4}'| sed 's/\/30$//' | cut -d'.' -f3-
```

* Use case with a small script to backup and push resolv.conf
```bash
#!/bin/bash
for line in `cat expect_dns_no_nm.csv`; do
hostname=`echo $line | cut -d";" -f1`
username=`echo $line | cut -d";" -f2`
password=`echo $line | cut -d";" -f3`
 
./expect.us ssh $hostname $username $password "cp /etc/resolv.conf /etc/resolv.conf.20151103"
./expect.us scp $hostname $username $password source/resolv.conf /etc/resolv.conf
done
```