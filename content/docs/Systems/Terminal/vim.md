---
date: 2023-08-01T21:00:00+08:00
title: ✍️ Vim
nav_weight: 70 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
  - Shell
---

## Tutorials

https://vimvalley.com/
https://vim-adventures.com/
https://www.vimgolf.com/


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

* the most powerful commands:    
  `.`  :  Repeat the last modification.    
  `*`  :  Where the cursor is located, keeps the word in memory and goes to the next occurrence.    
  `.*` :  together, repeat an action on the next word.    

* Encrypt a file with VIM, pasted from [sources](https://www.generation-linux.fr/index.php?post/2017/08/06/Chiffrer-simplement-un-fichier-texte-avec-Vim) 

```bash
:setlocal cm=blowfish2
:X 
>Enter the encryption key:
:wq
```

* aliases - in command mode
`:ab ue University of Economics`   - creates an alias `ue`, then in insert mode every time you type `ue + Enter` it will write `University of Economics` for you.
`:unab ue`                       - removes the alias `ue`
`:ab rue Mr Smith main street`    - ⚠️ Be careful of the common mistake where the alias is contained in the alias.

## My ~/.vimrc

`vim -u test_vimrc`  : when you want to test a `vimrc` first

```bash
# Active coloring and presentation
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


## Setters 

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


* Visual mode `Shift + v `, then `u` to convert to lowercase, or `U` to convert to uppercase. 

`U`     : Uppercase the visually-selected text. 
`gUU`   : Change the current line to uppercase (same as VU).  
`guu`   : Change the current line to lowercase (same as Vu).   
`gUiw`  : Change current word to uppercase. 

* in command mode `u` will undo change

 
##  Usage

* To open a file    

`vi +33 file`      - opens the file at line 33   
`vi + file`        - opens the file at the last line    
`vi +/research`    - opens the file at the first line where "research" is found   
`vi -R file`       - opens read-only   
`vi -r file`       - after a crash, recovers the swap file   
`vi file1 file2`   - to open two documents (access the next one with `:n`)    
     
`:vs ~/.vimrc`     - open in another window   
`:sh ~/script.sh`  - run a script    
     
`:e [file]`        - edit another file without leaving vi (the benefit is keeping what is in the buffer and navigating between several documents)    
`:n`               - navigate between the files open in vi (also `ctrl ^`, but it depends on the system)    
`:x`               - closes all the documents opened with vi    
`:sp`              - opens a second document on the same screen    

navigate between the two with    
`ctrl+w w`     - to switch    
`ctrl+w j`     - to go down  
`k`            - to go up   
`_`            - to make the buffer take the whole screen   
`=`            - to make the buffers equal again   
	 
`:sf`              - opens another document in the same window    
`:read pliku`      - imports everything from "pliku" at the cursor position (:r same effect)   
`:r /file`         - inserts a file from the cursor position   
`:r! command`      - inserts the result of a command    

`Ctrl G`           - to see the file information, whether it is modified, etc.   

`Esc + q:`         - gives the command history   
`Esc + q\`         - gives the search history   
    
* To quit   

`ZZ`              - quits and saves (shortcut)   
`:w`              - saves (w [file] saves under the given name)   
`:q!`             - quits   
`:e!`             - discards all modifications   
 
* Manipulate text    
`:n,mm j`         - moves from line "n" to "m" to line "j" (with /expression instead of "j", moves after the line containing "expression")   
`:n,mt j`         - copies from line "n" to "m" to line "j"   
`:n,mw file`      - copies lines "n" to "m" into file   
`:n,mw>> file`    - copies "n" to "m" at the end of file   
`:'a,'bw file`    - copies what is in buffers a and b into file   
    
* SHELL COMMAND    
`:! cmd` - runs shell commands while in vi   
e.g. `:!df`, `:!ls -l`, or `:!cat /etc/passwd > ~/hasla.txt`   
Note: `:!` is glued to the command that follows.   
    
	   
* INSERT MODE      
to enter insert mode   
`i`               - write where the cursor is    
`I`               - insert at the beginning of the line   
`A`               - insert at the end of the line   
`a`               - write just after the cursor   
`C`               - cuts from the cursor to the end of the line, then enters insert   
`o`               - opens a new line below the cursor   
`O`               - opens a new line above the cursor    
`s`               - deletes under the cursor and enters insert mode   
`S`               - deletes the whole line and enters insert mode   
`r`               - enters "replace" mode for a single character    
`R`               - enters "replace" mode (note: if you erase, you get the old characters back)   
    
NOTE: `R` in replace mode, if you erase, you get the old characters back.

* COMMAND MODE    

	* Move around       
h(left) j(down) k(up) l(right)    
Can combine with numbers: 10k 4l 8h etc.

`gg`         - to the beginning of the file   
`G `         - to the end of the file      
`L `         - to the end of the screen / M - to the middle / H - to the top of the screen   
`Z + Enter`  - puts the cursor at the top of the screen / Z.   
`nL`         - to n lines before the end of the screen / nH - to n lines from the top of the screen   
`nG`         - to line number n / 1G - to the very beginning / G - to the very end    
`+ `         - to the beginning of the next line    
`- `         - to the beginning of the previous line   
`$ `         - sends the cursor to the end of the line   
`( `         - to the beginning of the sentence     
`)`          - to the end of the sentence    
`0`          - sends the cursor to the beginning of the line (or also ^)   
`w`          - to the next word   
`b`          - to the previous word (2b: 2 words back)   
`e`          - to the end of the word / E - also, but does not account for accents.   
`ctrl+f`     - next screen   
`ctrl+b`     - previous screen   
`ctrl+d`     - half a screen down  
`ctrl+u`     - half a screen up  
`mx`         - sets a (invisible) mark that can be found with `` `x `` (the cursor is sent back to that mark)   
`Shift+v`    - puts a cursor on the entire line, select the number of lines with the arrow then "d" or "y" etc.  
`` d`x ``    - erases from the mark to the cursor   
`` y`x ``    - copies from the mark to the cursor   

  * delete
`x`          - deletes under the character
`dd`         - deletes the line (d$ same effect but from the cursor) 
Note: combines with numbers and directions. number + d (or x) + direction (h,j,k,l,$,0,w,b etc.)

`ddp`        - deletes a line and re-inserts it below     
`dd3p`       - pastes the same line three times       
`5dx`        - erases 5 characters       
`3dw`        - erases 3 words       
`3dd`        - erases 3 lines    
`dG`         - erases from the cursor to the end; :.,$d deletes everything from the beginning to the end
`n,md`       - erases from line n to m

Note: any deletion is kept in the buffer for pasting.

`D`          - deletes the line from the cursor 
`cw`         - erases the word and enters insert mode
`cc`         - changes the line (erases the line and puts it in the buffer - p to paste later) 
`ciW`        - change inside Word 
`ci"`        - change inside quotes "" 
`c`          - combines with the movement cursor (e.g. c$, c0, c2b, etc.)

  * replace, modify
`J`          - joins the next line with this one    
`~`          - swaps lowercase to uppercase and vice versa   
`u`          - returns to the previous modification (undo)   
`U`          - returns over all modifications  
`Ctrl + r`   - redo   
Note: combines with numbers (e.g. 3u) 

`p`         - pastes after the cursor   
`P`         - pastes before the cursor  
`y`         - copy 
`yy`        - copies the line  
`Y`         - same effect 
`y$`        - copies from the cursor to the end    
`yw`        - copies the word; 3yy - copies 3 lines;     
`"`         - lets you save into a buffer (e.g. "a3yy copies 3 lines into buffer a, re-paste with "ap)   

  * search
`/word`     - searches for the string "word" after the cursor    
`?word`     - searches for the string "word" before the cursor   
`*`         - where the cursor is, searches for the same word   
Note: n to go to the next, N to go back    

* COMMAND-LINE MODE (:)
Command-line mode always starts with `:`. Some commands can only be run in command-line mode.   
(e.g. :3,7d) because they need to be visualized. There is also a history; you can search previous commands with the arrow.   
	
* Modes and Options  
`:set`            - gives the modes in use (those launched by EXINIT and .exrc)   
`:set showmode`   - see the mode you are in.    
`:set all`        - shows all possible modes to choose from   
`:set OPTION?`    - shows whether the option is enabled or not   
`:set nu`         - displays the line numbers   
`:set nonu`       - removes this option (general rule: :set no+mode removes the chosen mode)    
`:set ignorecase` - ignores uppercase   
`:set magic`      - enables meta-characters   
`:set list`       - shows the end of lines with a `$` and the tabulations with `^|`  
`:set wrapmargin=n`  (wm=n) - moves the left margin by value n   
`:set autowrite`     (aw)   - saves automatically before a search, a check, a shell, etc.  
`:set autoindent`    (ai)   - provides automatic indentation when writing.   
`:set showmatch`     (sm)   - shows the matches between () or {} and [].    

Note: you can save all the vi configuration into a file and call it with `:so file_name`, which loads that configuration. 

Note: in `/etc/virc/.exrc` you configure the machine's vi to launch options as soon as vi starts.  
Otherwise create a `.exrc` file in the user directory.    
 
* substitutions (the sed tool inside vi)  
`:s/stare/nowe/           `  - searches for the string "stare" and changes the first occurrence in the sentence to "nowe"   
`:s/stare/nowe/g          `  - g to change all occurrences in the sentence  
`:%s/stare/nowe/g         `  - % to search through the whole text  
`:n,ms/stare/nowe/g       `  - searches between n and m  
`:s/stare/nowe/gc         `  - c asks for confirmation at each change  
`:g/wzorzec/s/stare/nowe/g`  - g at the start searches for "wzorzec" and only applies the changes in the sentences containing "wzorzec". Note: with g at the start, % is no longer necessary.   
`:m                       `  - moves the selected expression   

* Sed tip
`:s                            `  - repeats the last global modification   
`:%&g                          `  - repeats the last global modification on the whole text   
`:%s;/home/student;/home/toor;g`  - ";" replaces "/", so "/" becomes a normal character.   
`:g!/ok/s/$/TODO/g          `  - wherever there is no "ok" in the sentence, put "TODO" at the end   
`:%s/[0-9]$//gc                `  - deletes if there is a digit (between 0 and 9) at the end of the sentence   
`:g/^[0-9]/m$                  `  - moves all lines starting with a digit to the end of the document   

* The meta-characters for vi's sed   
`.`             - equivalent to a character (careful: space counts as a character)   
`*`             - any string   
`^`             - searches at the beginning of the line     
`$`             - searches at the end of the line     
`\<word`        - searches at the beginning of the word (e.g. "moteur" will be taken)   
`word\>`        - searches at the end of the word   
`\`             - cancels the meta-character and counts it as a normal character   
`[ab]`          - a or b     
`\(word_A\)`    - saves this word into buffer 1 (up to 9), retrieved with \1  
`:%s/\(kolwalski\) \(Jan\)/\2 \1/` - swaps the two names.   
Can serve to replace up to 9 expressions, or to place text between two expressions, etc.