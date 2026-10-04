---
date: 2026-01-01T21:00:00+08:00
title: 🐹 Golang
nav_weight: 10
categories:
  - Memo
tags:
  - Scripting

---

## Installation

Install Go:

```bash
GO_VERSION="1.21.0"

wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz

export PATH="/usr/local/go/bin:$PATH"

go version
```

To keep Go available after reboot:

```bash
echo 'export PATH="/usr/local/go/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Create a project

```bash
mkdir myapp
cd myapp

go mod init myapp
```

A `go.mod` file is created:

```txt
myapp/
└── go.mod
```

It describes the Go module and its dependencies.

## Hello World

Create `main.go`:

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello World")
}
```

```bash
go run .
go build
```

This creates a binary: `./myapp`

## Variables

```go
package main

import "fmt"

func main() {
    name := "Gopher"
    age := 10

    fmt.Println(name, age)
}
```

Variables can also be declared explicitly:

```go
var name string = "Gopher"
var age int = 10
```

The short syntax is commonly used inside functions:

```go
name := "Gopher"
```

## Functions

Functions are declared with `func`:

```go
func hello(name string) string {
    return "Hello " + name
}
```

Use it:

```go
func main() {
    message := hello("Gopher")
    fmt.Println(message)
}
```

A function can return several values:

```go
func divide(a, b int) (int, error) {
    if b == 0 {
        return 0, fmt.Errorf("division by zero")
    }

    return a / b, nil
}
```

## Conditions

```go
if age >= 18 {
    fmt.Println("adult")
} else {
    fmt.Println("minor")
}
```

Go does not require parentheses around conditions.

## Loops

Go uses `for` for loops:

```go
for i := 0; i < 5; i++ {
    fmt.Println(i)
}
```

It can also behave like a `while` loop:

```go
i := 0

for i < 5 {
    fmt.Println(i)
    i++
}
```

## Slices

Slices are commonly used instead of arrays:

```go
names := []string{
    "Alice",
    "Bob",
    "Charlie",
}

for _, name := range names {
    fmt.Println(name)
}
```

Add an element:

```go
names = append(names, "Dave")
```

## Maps

Maps store key/value pairs:

```go
ports := map[string]int{
    "http":  80,
    "https": 443,
}

fmt.Println(ports["https"])
```

Loop over a map:

```go
for name, port := range ports {
    fmt.Println(name, port)
}
```

## Structs

Structs group related data:

```go
type Server struct {
    Name string
    Port int
}
```

Create one:

```go
server := Server{
    Name: "web",
    Port: 8080,
}

fmt.Println(server.Name)
```

## Methods

Methods are functions attached to a type:

```go
type Server struct {
    Name string
}

func (s Server) Start() {
    fmt.Println("Starting", s.Name)
}
```

Usage:

```go
server := Server{Name: "web"}
server.Start()
```

## Error handling

Go usually returns errors explicitly:

```go
file, err := os.Open("config.yaml")
if err != nil {
    return err
}

defer file.Close()
```

A very common pattern is:

```go
result, err := doSomething()
if err != nil {
    return err
}
```

Go does not use exceptions for normal error handling.

## Packages

Code can be split into packages.

Example:

```txt
myapp/
├── main.go
└── greeting/
    └── greeting.go
```

`greeting/greeting.go`:

```go
package greeting

func Hello(name string) string {
    return "Hello " + name
}
```

Use it from `main.go`:

```go
package main

import (
    "fmt"

    "myapp/greeting"
)

func main() {
    fmt.Println(greeting.Hello("Gopher"))
}
```

Names beginning with an uppercase letter are exported:

```go
func Hello() {}
```

Names beginning with lowercase are private to the package:

```go
func hello() {}
```

## Common structure

A small application can simply use:

```txt
myapp/
├── go.mod
├── go.sum
└── main.go
```

As the project grows, a common structure is:

```txt
myapp/
├── cmd/
│   └── myapp/
│       └── main.go
│
├── internal/
│   ├── app/
│   ├── config/
│   └── service/
│
├── go.mod
└── go.sum
```

Typical responsibilities:

```txt
cmd/
    application entry points

internal/
    private application packages

go.mod
    module and dependency definition

go.sum
    dependency checksums
```

`main.go` should generally stay small:

```go
package main

import "myapp/internal/app"

func main() {
    app.Run()
}
```

The application logic can then live under `internal/`.

## Useful commands

```bash
go run .
go build
go test ./...
go fmt ./...
go vet ./... #Static analysis:
go mod download
go mod tidy
go install .
```

## Basic workflow

A typical Go workflow is:

```txt
create module
    ↓
write packages
    ↓
go fmt
    ↓
go test
    ↓
go vet
    ↓
go build
```

The main ideas to remember are:

```txt
package     groups Go code
func        defines behavior
struct      groups data
interface   describes behavior
error       represents failures
go.mod      defines the module
```

## Sources