---
title: How Does a Computer Work?
description: What a computer does and how its main components work together.
type: docs
nav_weight: 10
---

A computer may look complicated, but the basic idea is simple:

> **A computer is a machine that follows instructions very quickly.**

Whether it is a laptop, a smartphone, a tiny Raspberry Pi, or a huge server in a data center, almost every computer performs the same four basic jobs:

1. **Input** — receiving information.
2. **Processing** — working out what to do with that information.
3. **Storage** — remembering information.
4. **Output** — showing or sending the result.

For example, when you write a document:

- your keyboard sends **input**;
- the computer calculates what happens next using its processor;
- the program and your saved document are kept in **storage**;
- the result appears on your screen as **output**.

Let's look inside!

---

## Different Types of Computers

When you hear the word *computer*, you may imagine a desktop PC or a laptop.

But computers come in many shapes and sizes.

### Desktop Computer

A desktop computer normally has a separate screen, keyboard, mouse, and computer case.

Because there is more space inside the case, desktop computers are usually easy to upgrade or repair.

### Laptop

A laptop contains most of the same components as a desktop computer, but everything is packed into a small portable case.

The screen, keyboard, battery, speakers, camera, and computer are all connected together.

### SBC — Single-Board Computer

An **SBC**, or **Single-Board Computer**, is a complete computer built on one small circuit board.

One famous example is the Raspberry Pi.

These computers are useful for learning programming, robotics, home automation, and electronics.

They can be smaller than your hand!

### Server

A **server** is a computer that provides services to other computers or their users.

For example, a server might:

- store websites;
- save files;
- run online games;
- send emails;
- host databases;
- run artificial intelligence models.

A server does not need to look special. It can be a tiny computer or a large machine; either can provide the same kinds of services.

### Is a Smartphone a Computer?

Yes!

A smartphone is definitely a computer.

It has:

- a processor;
- memory;
- storage;
- an operating system;
- a screen;
- network connections;
- sensors;
- input and output devices.

Your phone is a powerful little computer that fits in your pocket.

> **Think about it:**\
> What other objects around you might secretly contain a computer?

Cars, televisions, watches, game consoles, washing machines, robots, and even some toys contain computers.

<illustration: desktop, laptop, smartphone, SBC and server side by side>

---

## The Components of a Computer

Let's open the computer and look inside.

Don't worry — we are not going to break anything!

Most computers contain a few important components.

### CPU — The Processor

The **CPU**, or **Central Processing Unit**, is sometimes called the *brain of the computer*.

Its job is to execute instructions.

For example:

```text
Add these two numbers.
Move this character.
Open this file.
Display this image.
Check whether the password is correct.
```

A modern CPU can perform billions of operations every second.

It does not actually "think" like a human brain. It simply follows instructions incredibly quickly.

---

### RAM — Short-Term Memory

**RAM**, or **Random Access Memory**, is the computer's short-term working memory.

Imagine that you are doing homework at a desk.

The things currently on your desk are like RAM:

- your notebook;
- your pencil;
- your calculator;
- the book you are reading.

They are easy to reach because you are using them right now.

When you open a game, a website, or a program, some of its information is copied into RAM so the CPU can access it quickly.

But RAM has an important limitation:

> When the computer turns off, the information stored in RAM disappears.

---

### Storage — Long-Term Memory

The computer also needs somewhere to keep information when it is turned off.

This is called **storage**.

Your:

- photos;
- homework;
- videos;
- programs;
- operating system

are stored there.

Modern computers usually use an **SSD**, or Solid-State Drive.

You may also hear the term **NVMe SSD**. NVMe allows an SSD to communicate with the computer at high speed.

Unlike RAM, storage remembers your files even when the computer is switched off.

---

### Motherboard — The Main Board

All these components need to communicate with each other.

The **motherboard** is the large circuit board that connects the main parts of the computer.

The CPU, RAM, storage, network devices, and other components communicate through connections on the motherboard.

You can imagine the motherboard as a tiny city full of roads.

Information is constantly travelling between different components.

---

### Power Supply

Computers need electricity.

In a desktop computer, the **power supply unit**, or **PSU**, converts electricity from the wall into the different voltages required by the computer's components.

A laptop does something similar but also includes a battery.

Without electricity, even the fastest processor in the world is just a very expensive piece of metal and silicon.

---

## Peripherals

Computers also communicate with devices around them.

These devices are often called **peripherals**.

Examples include:

- keyboard;
- mouse;
- monitor;
- printer;
- microphone;
- speakers;
- webcam;
- game controller;
- USB drive.

Some peripherals provide **input**.

For example:

```text
Keyboard → Computer
Mouse → Computer
Microphone → Computer
```

Others provide **output**:

```text
Computer → Screen
Computer → Speakers
Computer → Printer
```

Some devices can do both.

A network card, for example, can both send and receive information.

---

## What Is a Driver?

Sometimes the computer needs a small piece of software to understand how to communicate with a device.

This software is called a **driver**.

You can imagine a driver as a translator.

The operating system says:

> "Please print this picture."

The printer driver knows how to translate that request into instructions that the printer understands.

Many common drivers are already included with modern operating systems, so you may never even notice them.

---

## Some More Advanced Components

Once you start exploring computers, you may discover some strange abbreviations.

Don't worry if you don't understand all of them yet.

### GPU

A **GPU**, or Graphics Processing Unit, is very good at performing many calculations at the same time.

GPUs were originally designed mainly for graphics and video games.

Today they are also heavily used for:

- artificial intelligence;
- scientific calculations;
- 3D graphics;
- video processing.

### NPU

An **NPU**, or Neural Processing Unit, is a processor designed especially for artificial intelligence calculations.

Some modern phones and laptops already contain NPUs.

### TPU

A **TPU**, or Tensor Processing Unit, is a specialised processor designed for machine-learning calculations.

### ECC Memory

Some servers use **ECC memory**.

ECC stands for **Error-Correcting Code**.

It can detect and correct certain memory errors automatically.

This is useful for computers that need to run reliably for a very long time.

> You don't need to memorize these names now.\
> The important idea is that computers can contain **specialized components designed for special jobs**.


{{< image-carousel
       "images/computers/cpu.jpg|A processor|The processor"
       "images/computers/RAM.png|RAM modules|Short-term memory"
       "images/computers/ssd.svg|An NVMe solid-state drive|Long-term storage"
       "images/computers/motherboard.svg|A computer motherboard|The main board"
       "images/computers/psu.svg|A computer power supply unit|The power supply"
       "images/computers/gpu.svg|A graphics card|The GPU"
    >}}

---

## Build Your Own Paper Computer

Now let's build a computer — without buying any expensive components!

### What You Need

Prepare some pieces of colored paper:

- black square → **CPU**
- green rectangles → **RAM**
- grey rectangle → **SSD**
- large rectangle → **Motherboard**
- another block → **Power Supply**
- optional large card → **GPU**

You will also need:

- a white sheet of paper;
- scissors;
- glue;
- colored pencils.

### Your Mission

Glue the components onto your sheet of paper.

Then draw lines showing how the different components communicate.

Ask yourself:

- Where should the CPU go?
- Where should the RAM go?
- What needs to connect to the motherboard?
- Where does electricity come from?
- Where would you connect a keyboard?
- Where would you connect a screen?

You can even add your own components.

Maybe your computer needs:

- a Wi-Fi card;
- a GPU;
- three SSDs;
- a giant cooling fan!

There is no need to make it perfect. The goal is to understand how the pieces fit together.

<illustration: example paper computer>

---

## How Much Electricity Does a Computer Use?

Not every computer needs the same amount of electricity.

A tiny computer might use only a few watts.

A laptop may use a few dozen watts.

A powerful gaming computer or AI server can use hundreds or even thousands of watts.

We measure electrical power in **watts**, written as **W**.

To estimate how much energy a computer uses:

```text
Energy = Power × Time
```

For electricity bills, we usually use **kilowatt-hours**, or **kWh**.

For example, imagine a computer using **100 watts** for 10 hours, so it uses:

```text
100 × 10 = 1000 watt-hours = 1 kWh
```

{{< energy-calculator >}}

### Exercise: Power a Small Home Lab

Napoleon wants to build a homelab. He was searching for a server and writing down its power consumption. Which server should Napoleon choose for his homelab?

| Device | Power |
|---|---:|
| Raspberry Pi 5 | 12 W |
| Intel NUC 13 Pro mini PC | 30 W |
| HPE ProLiant DL360 Gen11 server | 300 W |
| Dell PowerEdge XE9680 AI server | 1500 W |

Assume that all four computers run continuously for one year:

1. Use the calculator to find the annual cost in PLN and euros.

{{% bs/collapse "Show the answer" success %}}

There is no single correct answer because the exercise does not say what workload he will need. Any of those servers could be suitable for him. Nonetheless, the Dell PowerEdge's power consumption is so high that Napoleon would have a bill of 1.5 kW × 365 × 24 × €0.2709/kWh = €3,559.63.

{{% /bs/collapse %}}

---

## The Right Computer for the Right Job

Bigger is not always better.

Imagine that you want to collect the temperature outside once every hour.

Do you need a huge server?

Probably not!

A tiny low-power computer or microcontroller may be able to do the job.

It might even run from a battery and a small solar panel.

But imagine that you want to train a giant artificial intelligence model.

Now you may need many powerful computers working together.

<illustration: tiny low-power LoRa/SBC device with solar panel vs large AI server rack>

Choosing a computer is about choosing the **right tool for the job**.

A useful engineer asks:

> "What is the smallest and simplest system that can solve my problem?"

Using less electricity can mean:

- smaller batteries;
- less heat;
- lower electricity bills;
- less cooling;
- less waste.

And remember:

> **With great computing power comes great responsibility.**

<GIF or illustration>

---

## What You Learned

You now know that:

- a computer is a machine that follows instructions;
- computers come in many shapes and sizes;
- the CPU executes instructions;
- RAM is fast, temporary memory;
- storage keeps information for a long time;
- the motherboard connects the components;
- peripherals allow computers to interact with the outside world;
- different computers use very different amounts of electricity.

And most importantly:

> A computer is not magic.

It is a collection of simple parts doing simple things **extremely quickly**.

In the next lesson, we can start discovering how computers represent information using only **0s and 1s**.
