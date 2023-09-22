---
date: 2023-08-01T21:00:00+08:00
title: 👮 Justfile
navWeight: 50 # Upper weight gets higher precedence, optional.
series:
  - Command-Liner
categories:
  - Scripting
---


Interesting example from justfile documentation:  where it create mktemp and set it in variable then by concatenation you get a full path to the tar.gz.  
Then the Recipe "publish" create the artifact again and push it to a server.

```makefile
tmpdir  := `mktemp`  # Create a tmp file
version := "0.2.7"   
tardir  := tmpdir / "awesomesauce-" + version
tarball := tardir + ".tar.gz"  # use tmpfile path to create a tarball

publish:
  rm -f {{tarball}}
  mkdir {{tardir}}
  cp README.md *.c {{tardir}}
  tar zcvf {{tarball}} {{tardir}}
  scp {{tarball}} me@server.com:release/
  rm -rf {{tarball}} {{tardir}}
```


## Sources

[Offical Documentation](https://just.systems/man/en/)

[Blog](https://developerlife.com/2023/08/28/justfile/)