---
date: 2023-08-01T21:00:00+08:00
title: Unicode
navWeight: 900 # Upper weight gets higher precedence, optional.
series:
  - SysAdmin
categories:
  - Docs
tags:
  - Systems
  - Terminal
  - Produtivity
---


## Unicode with With echo 

echo $'\xae'    =    "®"


## Digraphs in VIM

Vim has a special shorthand for entering characters with diacritical marks. If you need some familiar variant of a Latin alphabet character you’ll be able to input it with the digraph system.    

Digraph input is started in insert or command mode (but not normal mode) by pressing Ctrl-k, then two printable characters in succession.     
The first is often the “base” form of the letter, and the second denotes the appropriate embellishment.      

Some basic examples: 
  * `Ctrl-k c ,` -> ç   
  * `Ctrl-k e '` -> é     
  * `Ctrl-k o ^` -> ô    
  * `Ctrl-k a !` -> à     
  * `Ctrl-k u :` -> ü    
  * `Ctrl-k = e` -> €    

Also type within Vim:  `:digraphs` --> get a **complete** list of digraphs.    
 

## Unicode characters

In VIM, for characters not covered in the digraph set, you can also enter unicode characters by referring to their code page number.    
In insert or command mode (but not normal mode) this is done by `Ctrl-v` then `u` followed by the hexadecimal number.    

Some examples:
  * `Ctrl-v u 2018`  -> ‘,   a LEFT SINGLE QUOTATION MARK    
  * `Ctrl-v u 2019`  -> ’,   a RIGHT SINGLE QUOTATION MARK   
  * `Ctrl-v u 2014`  -> —,   an EM DASH    
  * `Ctrl-v u 00a9`  -> ©,   a COPYRIGHT SIGN    

Handy when writing HTML documents, as an alternative to using HTML entities like &mdash; or &copy;. The full list is available on Unicode website.
