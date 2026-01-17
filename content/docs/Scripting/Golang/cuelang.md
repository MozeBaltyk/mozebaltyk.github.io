---
date: 2023-08-01T21:00:00+08:00
title: 👮 CUE-lang
navWeight: 80 # Upper weight gets higher precedence, optional.
series:
  - Docs
categories:
  - Devops
tags:
  - Scripting
  - Golang
  - Data
---


CUE stands for Configure, Unify, Execute

### Basics

* Installation

```bash
# Install GO
GO_VERSION="1.21.0"
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

go install cuelang.org/go/cmd/cue@latest
sudo cp -pr ./go /usr/local/.

# or use Container
printf "\e[1;34m[INFO]\e[m Install CUElang:\n";    
podman pull docker.io/cuelang/cue:latest
```

* concepts

top -> schema -> constraint -> data -> bottom

* Command

```bash
# import a file 
cue import imageset-config.yaml 

# Validate 
cue vet imageset-config.cue imageset-config.yaml


* Some basics example

```go
// This is a comment
_greeting: "Welcome" // Hidden fields start with "_"
#project:  "CUE"     // Definitions start with "#"

message: "\(_greeting) to \(#project)!" // Regular fields are exported

#Person: {
  age: number            // Mandatory condition and must be a number
  hobbies?: [...string]  // non mandatory but if present must be a list of string
}

// Constrain which call #Person and check if age
#Adult: #Person & {
  age: >=18
}

// =~ match a regular expression
#Phone: string & =~ "[0-9]+"

// Mapping
instanceType: {
    web: "small"
    app: "medium"
    db:  "large"
}

server1: {
    role:     "app"
    instance: instanceType[role]
}

// server1.instance: "medium"
```

* Scripting

```bash 
# executable have extension name "_tool.cue"

# usage
cue cmd prompter
```

```go
package foo

import (
	"tool/cli"
	"tool/exec"
	"tool/file"
)

// moved to the data.cue file to show how we can reference "pure" Cue files
city: "Amsterdam"

// A command named "prompter"
command: prompter: {

	// save transcript to this file
	var: {
		file: *"out.txt" | string @tag(file)
	} // you can use "-t flag=filename.txt" to change the output file, see "cue help injection" for more details

	// prompt the user for some input
	ask: cli.Ask & {
		prompt:   "What is your name?"
		response: string
	}

	// run an external command, starts after ask
	echo: exec.Run & {
		// note the reference to ask and city here
		cmd: ["echo", "Hello", ask.response + "!", "Have you been to", city + "?"]
		stdout: string // capture stdout, don't print to the terminal
	}

	// append to a file, starts after echo
	append: file.Append & {
		filename: var.file
		contents: echo.stdout // because we reference the echo task
	}

	// also starts after echo, and concurrently with append
	print: cli.Print & {
		text: echo.stdout // write the output to the terminal since we captured it previously
	}
}
```

## Sources

[Offical Documentation](https://cuelang.org/docs/concept/the-logic-of-cue/)

[Playground](https://cuelang.org/play/#w=function&i=cue&f=eval&o=cue)