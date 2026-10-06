---
title: Operating Systems
description: Learn how an operating system manages a computer.
type: docs
nav_weight: 20
---

Learn what an operating system does and how it connects hardware, applications, and users.

## Hardware + Software

Great! Now we have built a computer. We have a CPU, RAM, storage, and electricity. The hardware can power on, but it still needs instructions before it can do anything useful. Something is missing: software.

### Hardware

**Hardware** means the physical parts of the computer — things you can touch: CPU, motherboard, keyboard, screen, RAM, SSD.

### Software

**Software** means the instructions that tell the hardware what to do: games, browsers, drawing programs, programming tools, music players.

Hardware without software doesn't know what job to perform. Software without hardware has nowhere to run. They need each other.

## The Operating System

One very important piece of software is the **Operating System**, or **OS**. You may already know some: Windows, macOS, Linux, Android, iOS.

The OS sits between your programs and the hardware. For example, a game that wants to play sound doesn't need to understand every speaker — it asks the OS:

```text
Game → Operating System → Sound Hardware
```

The OS performs several important jobs:

- **programs** — starts applications and shares CPU time between them;
- **memory** — gives programs space in RAM and keeps them separated;
- **files** — organizes data into files and folders;
- **devices** — communicates with hardware through drivers;
- **users and security** — controls accounts, permissions, and access;
- **networks** — helps applications communicate with other computers.

Think of the OS as the **manager of the computer**.

> The hardware is the body. The operating system wakes it up. 👻

### Starting the Computer

When you press the power button, a small program in the computer's firmware checks the hardware and finds something it can boot. A **bootloader** then loads the operating system into RAM. Finally, the OS starts its services and presents a login screen or command prompt.

```text
Power on → Firmware → Bootloader → Operating System
```

### Kernel and Interface

The **kernel** is the core of an operating system. It manages the CPU, memory, and devices while applications run around it. Linux began as a kernel created by Linus Torvalds in 1991. A complete Linux distribution adds tools, applications, and a user interface around that kernel.

People can interact with an OS through a graphical interface, using windows and icons, or through a command-line interface, using typed commands. Many operating systems provide both.

## Open Source

**Open-source software** makes its source code available for people to inspect, modify, and share under its licence. Linux is a well-known example, while Windows and macOS are mainly proprietary.

The European Union supports public-sector collaboration through its [Open Source Observatory (OSOR)](https://interoperable-europe.ec.europa.eu/collection/open-source-observatory-osor). Some European administrations are also replacing proprietary systems with Linux and other open-source projects. [Read an example from France](https://interoperable-europe.ec.europa.eu/collection/open-source-observatory-osor/news/france-phases-out-proprietary-operating-systems-workstations).

{{< quiz title="Test your knowledge" >}}
questions:
  - question: "What is an operating system?"
    answers:
      - text: "Software that manages hardware and runs applications"
        correct: true
      - text: "A type of computer memory"
        correct: false
      - text: "A programming language"
        correct: false
      - text: "A web browser"
        correct: false
  - question: "Which group contains only operating systems?"
    answers:
      - text: "Chrome, Firefox, Safari"
        correct: false
      - text: "Windows, macOS, Linux"
        correct: true
      - text: "Python, Go, Rust"
        correct: false
  - question: "What does an operating system manage?"
    answers:
      - text: "Only files"
        correct: false
      - text: "Files, programs, memory, hardware, users, networks, and security"
        correct: true
      - text: "Only hardware"
        correct: false
  - question: "What is open-source software?"
    answers:
      - text: "Software whose source code is available to use and modify"
        correct: true
      - text: "Software that only runs on Linux"
        correct: false
      - text: "Any software that costs money"
        correct: false
  - question: "Who created the Linux kernel?"
    answers:
      - text: "Bill Gates"
        correct: false
      - text: "Linus Torvalds"
        correct: true
      - text: "Richard Stallman"
        correct: false
{{< /quiz >}}
