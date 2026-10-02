---
date: 2023-08-01T21:00:00+08:00
title: 🐍 Cobra
navWeight: 90
series:
  - Docs
categories:
  - Devops
tags:
  - Scripting
---

## A Command Builder for Go

[Cobra](https://github.com/spf13/cobra) is a Go library for building command-line applications.

It is used by many well-known tools from the Go ecosystem because it gives us a convenient structure for:

- commands
- subcommands
- arguments
- flags
- validation
- help
- shell completion
- error handling

A Cobra application usually reads naturally:

```bash
app command argument --flag value
```

For example:

```bash
git clone repository --bare
kubectl get pods --namespace production
```

A useful introduction is also available here:

[How to use Cobra in Go](https://www.digitalocean.com/community/tutorials/how-to-use-the-cobra-package-in-go)

---

## Installation

```bash
go install github.com/spf13/cobra-cli@latest
# Add it to the `PATH` if necessary:
export PATH="$(go env GOPATH)/bin:$PATH"
# Check:
cobra-cli --help
```

There are actually two different things involved here. `cobra-cli` helps create files. The application itself depends on the `cobra` library.

---

# 1. Start with a Go project

Let's create a small CLI called `clock`.

Its goal will eventually be to work with time zones:

```bash
clock timezone Europe/Warsaw
clock timezone America/New_York
```

Init the project:

```bash
mkdir clock
cd clock
go mod init example.com/clock
cobra-cli init
```

The generated project will look approximately like:

```text
clock/
├── cmd/
│   └── root.go
├── go.mod
├── go.sum
└── main.go
```

---

# 2. Understand the Cobra model

Before adding code, it is important to understand Cobra's vocabulary:

```bash
#"root command" "command" "argument" "flag"
clock timezone Europe/Warsaw --format "15:04"
```

A command is represented by:

```go
cmd := &cobra.Command{
    Use:   "timezone <zone>",
    Short: "Display the current time in a timezone",
}
```

---

# 3. The root command

The top-level command is called the **root command**. So in our example `clock` is the root.

A simplified root command could look like this:

```go
package cmd

import "github.com/spf13/cobra"

func NewRootCommand() *cobra.Command {
    return &cobra.Command{
        Use:   "clock",
        Short: "A small CLI for working with time",
    }
}
```

---

# 4. Add the first command

The generator can create a command:

```bash
cobra-cli add timezone
```

We now have something similar to:

```text
clock/
├── cmd/
│   ├── root.go
│   └── timezone.go
├── main.go
└── go.mod
```

Our first version can simply print something:

```go
var timezoneCmd = &cobra.Command{
    Use:   "timezone",
    Short: "Display timezone information",
    Run: func(cmd *cobra.Command, args []string) {
        fmt.Println("timezone command")
    },
}
```

Test it: `go run . timezone`

---

# 5. Arguments

The zone is an **argument**: `clock timezone Europe/Warsaw`

```go
func newTimezoneCommand() *cobra.Command {
    return &cobra.Command{
        Use:   "timezone <zone>",
        Short: "Display the current time in a timezone",
        Args:  cobra.ExactArgs(1),

        RunE: func(cmd *cobra.Command, args []string) error {
            zone := args[0]

            location, err := time.LoadLocation(zone)
            if err != nil {
                return err
            }

            now := time.Now().In(location)

            fmt.Fprintln(cmd.OutOrStdout(), now.Format(time.RFC3339))

            return nil
        },
    }
}
```

test it:

```bash
go run . timezone Europe/Warsaw
go run . timezone Asia/Tokyo
```

---

# 6. Validate arguments with Cobra

This line means that Cobra checks the number of arguments before executing the command :

```go
Args: cobra.ExactArgs(1),
```

Cobra checks the number of arguments before executing the command.

For example:

```bash
# Fails because an argument is missing
clock timezone
# Fails because too many arguments
clock timezone Europe/Warsaw Asia/Tokyo
```

Other useful validators include:

```go
cobra.NoArgs
cobra.ExactArgs(1)
cobra.MinimumNArgs(1)
cobra.MaximumNArgs(2)
cobra.RangeArgs(1, 3)
cobra.ArbitraryArgs
```

{{< bs/alert info >}}
{{< markdownify >}}
Commands using cobra can declare their argument contracts directly at the Cobra layer.
{{< /markdownify >}}
{{< /bs/alert >}}

---

# 7. `Run` versus `RunE`

Instead of:

```go
Run: func(cmd *cobra.Command, args []string) {
    if err != nil {
        fmt.Println(err)
        os.Exit(1)
    }
}
```

we can return the error:

```go
RunE: func(cmd *cobra.Command, args []string) error {
    result, err := doSomething()
    if err != nil {
        return err
    }

    fmt.Fprintln(cmd.OutOrStdout(), result)

    return nil
}
```

The error then travels upward:

```text
business code
     │
     │ return error
     ▼
RunE
     │
     │ return error
     ▼
Cobra
     │
     ▼
main()
```

This gives us one place at the top of the application where exit codes and error printing can be controlled.

---

# 8. Add flags

Arguments identify the thing we are operating on. Flags modify **how** the operation behaves.


```go
func newTimezoneCommand() *cobra.Command {
    format := time.RFC3339

    cmd := &cobra.Command{
        Use:   "timezone <zone>",
        Short: "Display the current time in a timezone",
        Args:  cobra.ExactArgs(1),

        RunE: func(cmd *cobra.Command, args []string) error {
            location, err := time.LoadLocation(args[0])
            if err != nil {
                return err
            }

            now := time.Now().In(location)

            fmt.Fprintln(cmd.OutOrStdout(), now.Format(format))

            return nil
        },
    }

    cmd.Flags().StringVarP(
        &format,
        "format",
        "f",
        time.RFC3339,
        "Go time format",
    )

    return cmd
}
```

Now both work:

```bash
clock timezone Europe/Warsaw
```

and:

```bash
clock timezone Europe/Warsaw --format "15:04"
```

Short flags work too:

```bash
clock timezone Europe/Warsaw -f "15:04"
```

The CLI grammar is now:

```text
clock timezone <zone> --format <format>
       │          │          │
       command    argument   flag
```

---

# 9. Local flags and persistent flags

There are two particularly important kinds of flags.

## Local flags

A normal flag belongs only to a command:

```go
cmd.Flags().String(...)
```

## Persistent flags

A persistent flag is inherited by child commands:

```go
root.PersistentFlags().BoolP(
    "verbose",
    "v",
    false,
    "enable verbose output",
)
```

For a larger CLI this is useful for global concerns such as:

```text
--verbose
--config
--debug
--noninteractive
```

---

# 10. Keep `main.go` boring

An important design principle for CLI applications is:

> `main.go` should be boring.

A simple version is:

```go
package main

import (
    "fmt"
    "os"

    "example.com/clock/cmd"
)

func main() {
    root := cmd.NewRootCommand()

    if err := root.Execute(); err != nil {
        fmt.Fprintln(os.Stderr, err)
        os.Exit(1)
    }
}
```

The important code should live somewhere else.

```text
main.go
   │
   └── construct application
           │
           └── construct root command
                   │
                   └── execute
```

---

# 11. Context and Ctrl+C

CLI commands often perform operations that can take time:

- HTTP requests
- Git clones
- deployments
- database queries
- backups
- API calls

Users expect Ctrl+C to stop them.

Go's `context.Context` fits naturally with Cobra.

At startup:

```go
ctx, stop := signal.NotifyContext(
    context.Background(),
    os.Interrupt,
    syscall.SIGTERM,
)
defer stop()
```

Execute Cobra with the context:

```go
root.ExecuteContext(ctx)
```

Inside a command:

```go
RunE: func(cmd *cobra.Command, args []string) error {
    return service.DoSomething(cmd.Context())
}
```

The context flow becomes **OS signal > context cancelled > Cobra command > cmd.Context() >HTTP / Git / DB operation**. This is a very useful pattern for production CLI tools.

---

# 12. Don't put the entire application inside `RunE`

This is where Cobra tutorials often stop too early.

You can technically write:

```go
RunE: func(cmd *cobra.Command, args []string) error {
    // read config

    // authenticate

    // call HTTP API

    // clone repository

    // create files

    // update database

    // print output

    return nil
}
```

But eventually `RunE` becomes hundreds of lines long.

A better mental model is:

```text
Cobra
  │
  │ parse input
  ▼
Application
  │
  │ perform use case
  ▼
Infrastructure
```

Cobra's responsibility should mostly be:
- parse command
- parse arguments
- parse flags
- validate basic CLI input
- call application code
- display result

But not implement your entire business logic.

---

# 13. Introduce an application service

inside `internal/timezone/service.go`:

```go
package timezone

import "time"

type Service struct{}

func (Service) Current(zone string, format string) (string, error) {
    location, err := time.LoadLocation(zone)
    if err != nil {
        return "", err
    }

    now := time.Now().In(location)

    return now.Format(format), nil
}
```

Now Cobra only connects CLI input to our application:

```go
func newTimezoneCommand(service timezone.Service) *cobra.Command {
    format := time.RFC3339

    cmd := &cobra.Command{
        Use:   "timezone <zone>",
        Short: "Display the current time in a timezone",
        Args:  cobra.ExactArgs(1),

        RunE: func(cmd *cobra.Command, args []string) error {
            result, err := service.Current(args[0], format)
            if err != nil {
                return err
            }

            fmt.Fprintln(cmd.OutOrStdout(), result)

            return nil
        },
    }

    cmd.Flags().StringVarP(
        &format,
        "format",
        "f",
        time.RFC3339,
        "Go time format",
    )

    return cmd
}
```

Now our architecture is:

```text
terminal
   │
   ▼
Cobra
   │
   │ zone + format
   ▼
timezone.Service
   │
   ▼
time package
```

This distinction becomes extremely valuable when the application grows.

---

# 14. Dependency injection without a framework

Go does not need a dependency injection framework for most CLI applications.

We can simply create an application struct:

```go
type App struct {
    Timezone timezone.Service
}
```

Create its dependencies:

```go
func New() *App {
    return &App{
        Timezone: timezone.Service{},
    }
}
```

And let it build the Cobra tree:

```go
func (a *App) Root() *cobra.Command {
    root := &cobra.Command{
        Use:   "clock",
        Short: "A CLI for working with time",
    }

    root.AddCommand(
        newTimezoneCommand(a.Timezone),
    )

    return root
}
```

Startup becomes:

```text
main()
  │
  ▼
app.New()
  │
  ├── construct services
  │
  ▼
App.Root()
  │
  ├── construct Cobra commands
  │
  ▼
ExecuteContext()
```

This is very close to the pattern used by Colt.
