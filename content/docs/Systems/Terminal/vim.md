---
date: 2023-08-01T21:00:00+08:00
title: VIM
navWeight: 1200 # Upper weight gets higher precedence, optional.
series:
  - Terminal
categories:
  - Systems
---

## Plugins

```bash
# HCL
mkdir -p ~/.vim/pack/jvirtanen/start
cd ~/.vim/pack/jvirtanen/start
git clone https://github.com/jvirtanen/vim-hcl.git

# Justfile
mkdir -p ~/.vim/pack/vendor/start
cd ~/.vim/pack/vendor/start
git clone https://github.com/NoahTheDuke/vim-just.git
```


## Fun Facts

* trigger a vim tutorial `vimtutor` 

* the most powerfull command:    
  `.`  :  Repeat the last modification repete toutes les dernieres modif realisees.    
  `*`  :  Where the cursor is located, keep in memory the word and goes to next one.    
  `.*` :  together repeat an action on next word.    

* Encrypt a file with VIM, Pasted from [sources](https://www.generation-linux.fr/index.php?post/2017/08/06/Chiffrer-simplement-un-fichier-texte-avec-Vim) 

```bash
:setlocal cm=blowfish2
:X 
>Tapez la cle de chiffrement : 
:wq
```

* aliases - in command mode
`:ab ue université d'économie`   - create an alias `ue`, then in insert mode everytime you will type `eu + Enter` will write for you `université d'éco`.  
`:unab ue`                       - remove alias `ue`         
`:ab rue Mr Dupont rue Dujardin` - ⚠️ Be carefull to the common mistake the alias is in the alias.

## My ~/.vimrc

`vim -u test_vimrc`  : when you want to test first a `vimrc`

```bash
# Coloration Active et Presentation
syntax on 
:colorscheme torte
# OR :colorscheme elflord
set bg=dark
set autoindent 

# YAML tabulations
autocmd FileType yaml setlocal ai ts=2 sw=2 et

# extension .md to be recognized. 
filetype on 
au BufNewFile,BufRead *.{md,mdown,mkd,mkdn,markdown,mdwn} set filetype=markdown  

# set not compatible mode to enable Vim features.
set nocp 
```


## Setter 

* Reload inside vim

```bash 
:so $MYVIMRC  | :source ~/.vimrc 
```

* Set Numbers 
```bash
:set [ nu | number ]
:set [ nu! | nonu | nonumber ]
:set printoptions=number:y
```

* Colors are `ls -l /usr/share/vim/vim*/colors/`

```bash
:colorscheme torte
```

* Know your Runtimepath

```bash
:set runtimepath ?  
runtimepath=~/.vim,[...]/usr/share/vim/vimfiles/after,~/.vim/after 
```

## Uppercase / Lowercase

* Use `~` to toggle case. 

`~   `  Toggle case of the character under the cursor, or all visually-selected characters.    
`3~  `  Toggle case of the next three characters.   
`g~3w`  Toggle case of the next three words.   
`g~iw`  Toggle case of the current word (inner word – cursor anywhere in word).   
`g~$ `  Toggle case of all characters to end of line.   
`g~~ `  Toggle case of the current line (same as V~).    


* Visual mode `Shift + v `, then `u` to convert to lowercase, or with `U` to convert to uppercase. 

`U`     : Uppercase the visually-selected text. 
`gUU`   : Change the current line to uppercase (same as VU).  
`guu`   : Change the current line to lowercase (same as Vu).   
`gUiw`  : Change current word to uppercase. 

* in command mode `u` will undo change

 
##  Usage

* Pour Ouvrir un fichier    

`vi +33 plik`      - ouvre le fichier plik à la ligne 33   
`vi + plik`        - ouvre le fichier à la dernière ligne    
`vi +/research`    - ouvre le fichier a la première ligne où se trouve research   
`vi -R plik`       - ouvre seulement en lecture   
`vi -r plik`       - en cas de panne, récupère le fichier swap   
`vi plik1 plik2`   - pour ouvrir deux documents (on accède au suivant avec :n normalement)    
    
`:vs ~/.vimrc`     - Ouvrir dans une autre fenêtre   
`:sh ~/script.sh`  - Lancer un script    
    
`:e [file]`        - permet d'éditer un autre fichier sans quitter vi. (l'interêt est de garder ce qui est dans l'espace tampon et de naviguer entre plusieurs documents)    
`:n`               - permet de naviguer entre les fichiers ouverts en vi (aussi ctrl ^ mais ça dépend du système)    
`:x`               - va fermer tous les documents ouverts avec vi    
`:sp`              - ouvre un deuxième document sur le même écran    

on navigue entre les deux avec    
`ctrl+w w`     - pour changer    
`ctrl+w j`     - pour monter  
`k`            - pour descendre   
`_`            - pour que le buffer prenne tout l'ecran   
`=`            - pour que les buffers redeviennent egales   
		 
`:sf`              - ouvre un autre doc dans la meme fenetre    
`:read pliku`      - va importer tout ce qui dans pliku à la place du curseur (:r même effet)   
`:r /fichier`      - insert un fichier a partir de la position du curseur   
`:r! commande1`    - insert le resultat d'une commande    

`Ctrl G`           - pour voir les infos du fichier, voit si modifier, etc.   

`Esc + q:`         - donne l'historique des commandes   
`Esc + q\`         - donne l'historique des recherches   
    
* Pour Quitter   

`ZZ`              - quitte et enregistre (raccourci)   
`:w`              - enregistre (w [fichier] enregistre sous le nom donné)   
`:q!`             - quitte   
`:e!`             - annule toutes les modifications   
 
* Manipuler du Text    
`:n,mm j`         - déplace de la ligne "n" à "m" à la ligne "j" (avec /expression au lieu de "j", on va déplacer après la ligne où se trouve "expression")   
`:n,mt j`         - copie de la ligne "n" à "m' à la ligne "j"   
`:n,mw fichier`   - copie de la ligne "n" à "m" dans fichier   
`:n,mw>> fichier` - copie de "n" à "m" à la fin de fichier   
`:'a,'bw fichier` - va copier ce qui a dans le buffer a et b dans fichier   
   
* COMMANDE SHELL    
`:! cmd` - permet de lancer des commandes shell pendant qu'on est dans vi   
ex : `:!df` ou `:!ls -l` ou `:!cat /etc/passwd > ~/hasla.txt`   
Rq : `:!` sont collés a la commande qui suit.   
   
	   
* MODE EDITION      
pour passer en mode edition   
`i`               - écrire a la place ou se trouve le curseur    
`I`               - insertion en début de ligne   
`A`               - insertion en fin de ligne   
`a`               - écrire juste après le curseur   
`C`               - Coupe du curseur jusqu'a la fin puis passe en insertion   
`o`               - ouvre une nouvelle ligne en dessous le curseur   
`O`               - ouvre une nouvelle ligne au-dessus le curseur    
`s`               - supprime sous le curseur et passe en mode écriture   
`S`               - supprime toute la ligne et passe en mode écriture   
`r`               - passe en mode "replace" juste pour un caractère    
`R`               - passe en mode "replace" (Rq: si on efface on retrouve les anciens caractères)   
   

* MODE COMMANDE    

	* Se déplacer       
h(à gauche) j(en bas) k(en haut) l(à droite)    
On peut combiner avec des chiffres 10k 4l 8h etc.

`gg`         - au debut du fichier   
`G `         - a la fin du fichier      
`L `         - va à la fin de l'ecran / M - va au milieu / H - va au debut de l'ecran   
`Z + Enter`  - met le curseur en debut d'ecran / Z.   
`nL`         - va à la n ligne avant la fin de l'écran / nH - va a n ligne du debut d'écran   
`nG`         - va à la ligne numero n / 1G - va tout au debut / G - va tout à la fin    
`+ `         - va au debut de la ligne suivante    
`- `         - va au debut de la ligne precedente   
`$ `         - envoie le curseur à la fin de la ligne   
`( `         - va au debut des phrases     
`)`          - va à la fin des phrases    
`0`          - envoie le curseur au debut de la ligne (ou aussi ^ )   
`w`          - va au mot suivant   
`b`          - va au mot d'avant (2b: 2 mots avant)   
`e`          - va à la fin du mot / E - aussi mais tiens pas compte des accents etc.   
`ctrl+f`     - ecran suivant   
`ctrl+b`     - ecran precedent   
`ctrl+d`     - de moitié d'écran a moitie d'ecran vers le bas  
`ctrl+u`     - de moitié d'écran a moitie d'ecran vers le haut  
`mx`         - met un repère (invisible) qu'on pourra retrouver avec `x (le curseur sera renvoyé sur cette marque)   
`Shift+v`    - Met un curser sur la ligne entiere, on selectionne avec la fleche le nombre de ligne puis on peut "d" ou "y" etc.  
`d\`x`       - efface depuis le repère jusqu'au curseur   
`y\`x`       - copie depuis le repère jusqu'au curseur   

  * effacer
`x`          - efface sous le caractere
`dd`         - efface la ligne (d$ même effet mais depuis le curseur) 
Rq: se combine avec les chiffres et les directions. chiffre + d(ou x) + direction(h,j,k,l,$,0,w,b etc.)

`ddp`        - supprime une ligne et la replace en dessous     
`dd3p`       - colle trois fois la même ligne       
`5dx`        - efface 5 caractères       
`3dw`        - efface 3 mots       
`3dd`        - efface 3 lignes    
`dG`         - efface du curseur jusqu'à la fin; :.,$d supprime tout du debut jusqu'à la fin
`n,md`       - efface de la ligne n à m

Rq: toute suppression est conservé dans le cache pour être recollée.

`D`          - supprime la ligne d'à partir du curseur 
`cw`         - efface le mot et passe en mode insertion
`cc`         - change ligne (efface la ligne et la met dans buffer - p pour paste plus tard) 
`ciW`        - change inside Word 
`ci\"`       - change inside quote "" 
`c`          - se combine avec les curseur de déplacement (ex: c$,c0,c2b,etc.)

  * remplacer, modifier
`J`          - joint la ligne d'après avec celle-ci    
`~`          - change les minuscules en majuscules et inversement   
`u`          - revient à la précédente modification (undo)   
`U`          - revient sur toutes les modifications  
`Ctrl + r`   - redo   
Rq: se combine avec les nombres (ex: 3u) 

`p`         - colle après le curseur   
`P`         - colle avant le curseur  
`y`         - copie 
`yy`        - copie la ligne  
`Y`         - même effet 
`y$`        - copie du curseur jusqu'à la fin    
`yw`        - copie le mot; 3yy - copie les 3 lignes;     
`"`         - permet d'enregistrer dans le buffer (ex: "a3yy copie dans buffer a 3 lignes, on recolle avec "ap)   

  * recherche
`/mot`      - cherche la chaine de caratere "mot" après le curseur    
`?mot`      - cherche la chaine de caratere "mot" avant le curseur   
`*`         - la ou se trouve le curseur, va chercher le meme mot   
Rq : n pour passer au suivant et N pour revenir en arriere    


* MODE DIALOGUE
Le mode dialogue commence toujours par `:` certaines commandes ne peuvent se lancer qu'en mode dialogue.   
(ex :3,7d) car nécessité de les visualiser. Il y a également un historique, on peut rechercher les commandes précédentes avec la flèche.   
	
* Mode et Option  
`:set`            - donne les modes en cours d'utilisations (ceux lancer par EXINIT et .exrc)   
`:set showmode`   - voir le mode dans lequel on se trouve.    
`:set all`        - montre tous les modes possibles de choisir   
`:set OPTION?`    - montre si l'option est activée ou pas   
`:set nu`         - permet de mettre le numero des lignes   
`:set nonu`       - retire cette option (regle general :set no+mode, retire le mode choisi)    
`:set ignorecase` - ignore les majuscules   
`:set magic`      - permet les metacaractères   
`:set list`       - montre la fin des lignes avec un $ et les tabulations avec ^|  
`:set wrapmargin=n`  (wm=n) - deplace la marge de gauche de la valeur n   
`:set autowrite`     (aw)   - enregistre automatiquement avant une recherche, un controle, un shell, etc.  
`:set autoindent`    (ai)   - fournit une indentation automatique lors de l'ecriture.   
`:set showmatch`     (sm)   - montre les correspondances entre () ou {} et [].    

Rq : on peut enregistrer toute la configuration vi qu'on veut dans un fichier et faire appel à celui-ci avec   
":so nom_du fichier" qui mettra en place cette configuration.   

Rq : dans `/etc/virc/.exrc` on parametre le vi de la machine pour lancer des options dès le lancement de vi.  
Sinon creer un fichier `.exrc` dans le repertoire utilisateur.    
 
* substitutions (l'outil sed dans vi)  
`:s/stare/nowe/           `  - va rechercher la chaine "stare" et changer la première occurence dans la phrase par "nowe"   
`:s/stare/nowe/g          `  - g pour qu'il change toutes les occurences dans la phrase  
`:%s/stare/nowe/g         `  - % pour chercher dans tout le texte  
`:n,ms/stare/nowe/g       `  - va chercher entre n et m  
`:s/stare/nowe/gc         `  - c va demander confirmation a chaque changement  
`:g/wzorzec/s/stare/nowe/g`  - g au dedut rechercher "wzorzec" et effectue les modifs seulement dans les phrases où on a "wzorzec". Rq: avec g au debut % n'est plus nécessaire.   
`:m                       `  - déplace l'expression choisi   

* Astuce Sed
`:s                            `  - répète la dernière modification globale   
`:%&g                          `  - répète la dernière modification globale sur tout le texte   
`:%s;/home/student;/home/toor;g`  - ";" remplace "/" donc "/" devient un caractère normal.   
`:g!/ok/s/$/A faire/g          `  - partout où il n'y a pas "ok" dans la phrase mettre à la fin l'expr. "A faire"   
`:%s/[0-9]$//gc                `  - va supprimer s'il y a un chiffre (entre 0 et 9) en fin de phrase   
`:g/^[0-9]/m$                  `  - on va déplacer toutes les lignes commençant par un chiffre, à la fin du document   

* Les metacarateres pour le sed de Vi   
`.`             - équivaut a un caractère (Attention: espace compte comme un caractère)   
`*`             - n'importe quelle chaine de caractère   
`^`             - cherche au début de la ligne     
`$`             - cherche à la fin de la ligne     
`\<mot`         - cherche au début du mot (ex: "moteur" sera pris)   
`mot\>`         - cherche à la fin du mot   
`\`             - annule le metacaractère et est compté comme un caractère normal   
`[ab]`          - a ou b     
`\(mot_A\)`     - enregistre ce mot dans le buffer 1 (on a jusqu'à 9) qu'on ressort avec \1  
`:%s/\(kolwalski\) \(Jan\)/\2 \1/` - va intervertir les deux noms.   
Peut servir à replacer jusqu'à 9 expressions ou placer du text entre deux expressions, etc.    
  