---
date: 2026-01-01T21:00:00+08:00
title: 🐶 GoDog
nav_weight: 40
categories:
  - Memo
tags:
  - Scripting

---

## What is GoDog

[GoDog](https://github.com/cucumber/godog) is the Cucumber implementation for Go:
Behaviour-Driven Development (BDD).

You write scenarios in Gherkin (`.feature` files), then implement the steps in Go.
`go test` runs the scenarios as normal tests.

## Install

```bash
go get github.com/cucumber/godog/cmd/godog@latest
```

In practice it is a **test dependency** added to your `go.mod`.

## Example

### 1. Feature file

`features/calculator.feature`:

```gherkin
Feature: Calculator

  Scenario: add two numbers
    Given I have a calculator
    When I add 3 and 5
    Then the result should be 8
```

### 2. Step definitions

`main_test.go`:

```go
package main

import (
    "fmt"
    "testing"

    "github.com/cucumber/godog"
)

type calculator struct {
    result int
}

func (c *calculator) iHaveACalculator() error { return nil }

func (c *calculator) iAdd(a, b int) error {
    c.result = a + b
    return nil
}

func (c *calculator) theResultShouldBe(expected int) error {
    if c.result != expected {
        return fmt.Errorf("expected %d, got %d", expected, c.result)
    }
    return nil
}

func InitializeScenario(ctx *godog.ScenarioContext) {
    c := &calculator{}
    ctx.Given(`^I have a calculator$`, c.iHaveACalculator)
    ctx.When(`^I add (\d+) and (\d+)$`, c.iAdd)
    ctx.Then(`^the result should be (\d+)$`, c.theResultShouldBe)
}

func TestFeatures(t *testing.T) {
    suite := godog.TestSuite{
        ScenarioInitializer: InitializeScenario,
        Options: &godog.Options{
            Format:   "pretty",
            Paths:    []string{"features"},
            TestingT: t,
        },
    }

    if suite.Run() != 0 {
        t.Fatal("non-zero status returned, failed to run feature tests")
    }
}
```

### 3. Run

```bash
go test -v
```

## Key notes

- `Given` / `When` / `Then` map to `ctx.Given` / `ctx.When` / `ctx.Then`.
- Regex capture groups `(...)` become arguments of the step function.
- Feature files stay business-readable; the logic stays in Go.
- Useful with `--godog.format=pretty` for human-readable output.