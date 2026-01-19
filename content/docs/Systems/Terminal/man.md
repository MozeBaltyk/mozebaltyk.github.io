---
date: 2023-08-01T21:00:00+08:00
title: Manual
navWeight: 900 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - SysAdmin
tags:
  - Systems
  - Terminal
  - Produtivity
---

## Manuals for commands

`man <cmd>`    : Open man page of command.   
  * `space`    : go ahead page by page.     
  * `b`        : go back page by page.   
  * `q`        : quit.   
  * `Enter`    : go line by line.    
  * `/<word>`  : search a word in man.    
  * `n`        : go to the next expression that you search.   
  * `N`        : go back to search expression.     

`man -k <key word>`         : look for in all man for your key words.   
`man -k <word1>.*<word2>`   : ".*" allow to search several words.    
`whatis <cmd>`              : give short explaination about the command.    

## Man Sections

`man -a`                    : look in all sections.    
`man -s`                    : to specify which sections.    
	
NB: by default the search is done in section 1 but in fact there is 3 sections.
  * Section 1 : user´s commands 
  * Section 2 : system calls
  * Section 3 : Library fonctions  
      * 3c : Library C
      * 3m : Library math 
      * 3n : Library network

## Change Manual language

```bash
yum install man-pages-fr 
locale 
LANG = fr_FR_UTF-8
locale
```
