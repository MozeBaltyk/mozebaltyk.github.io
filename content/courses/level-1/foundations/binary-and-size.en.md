---
title: Binary and Data Size
description: Learn how computers represent information with bits and measure it in bytes.
type: docs
nav_weight: 40
---

Computers work with text, pictures, music, and video, but underneath they represent all of this information using only two values: **0** and **1**.

## Why Computers Use Binary

Inside a computer are billions of tiny electronic switches. A switch can be in one of two states: off or on. We write those states as:

- `0` — off;
- `1` — on.

One binary value is called a **bit**. The word *bit* comes from **binary digit**.

Binary numbers use powers of two. Each position is worth twice as much as the position to its right:

| Binary | Decimal |
|---:|---:|
| `0000` | 0 |
| `0001` | 1 |
| `0010` | 2 |
| `0011` | 3 |
| `0100` | 4 |
| `1000` | 8 |
| `1111` | 15 |

For example, `1101` means **8 + 4 + 0 + 1 = 13**.

## From Bits to Bytes

Eight bits form one **byte**:

> **8 bits = 1 byte**

A byte has 256 possible patterns, from `00000000` to `11111111`. That is enough to represent a number from 0 to 255.

Computers assign patterns to information. In ASCII, for example, the capital letter `A` has the value 65, which is `01000001` in binary. Modern text uses Unicode so that computers can represent characters from many languages, including `ą`, `é`, and `中`.

## Measuring Data

Bytes are grouped into larger units:

| Unit | Decimal size | Example |
|---|---:|---|
| byte (B) | 1 byte | one simple text character |
| kilobyte (KB) | 1,000 bytes | a short text file |
| megabyte (MB) | 1,000 KB | a photo or a song |
| gigabyte (GB) | 1,000 MB | a film or many applications |
| terabyte (TB) | 1,000 GB | a large drive or backup |

You may also see **KiB**, **MiB**, and **GiB**. These are binary units:

- 1 KiB = 1,024 bytes;
- 1 MiB = 1,024 KiB;
- 1 GiB = 1,024 MiB.

Storage manufacturers usually use decimal units, while operating systems may display binary units. This is why a drive can appear slightly smaller after it is connected to a computer.

## Byte Calculator

Choose a value and unit to see the same amount of data expressed in bits, bytes, and larger decimal and binary units.

{{< byte-calculator >}}

## Small Computers Can Do Important Work

NASA's Voyager program consists of two twin space probes, Voyager 1 and Voyager 2, launched in 1977 to explore the giant planets of our Solar System. They still communicate with Earth. Their onboard computers work with memory measured in **tens of kilobytes**, rather than the gigabytes found in modern phones.

A modern car key fob also contains a small computer. Its exact capacity depends on the model, but its memory is commonly measured in kilobytes. Some key fobs now have more memory than the Voyager probes sent into space.

<div class="row g-3 my-4">
  <div class="col-md-6">
    <figure class="h-100 mb-0">
      <div class="ratio ratio-16x9 bg-body-tertiary rounded overflow-hidden">
        <img src="/courses/level-1/foundations/images/key.webp" class="w-100 h-100 object-fit-contain" alt="A modern electronic car key fob">
      </div>
      <figcaption class="small text-body-secondary text-center mt-2">A car key fob contains a small, specialised computer.</figcaption>
    </figure>
  </div>
  <div class="col-md-6">
    <figure class="h-100 mb-0">
      <div class="ratio ratio-16x9 bg-body-tertiary rounded overflow-hidden">
        <img src="/courses/level-1/foundations/images/voyager.webp" class="w-100 h-100 object-fit-contain" alt="The Voyager space probe travelling through space">
      </div>
      <figcaption class="small text-body-secondary text-center mt-2">Voyager shows how much carefully written software can achieve with little memory.</figcaption>
    </figure>
  </div>
</div>

The lesson is simple: a computer does not need a huge amount of memory when it has one focused job and carefully written software.

## Try It

1. How many bits are in 10 bytes?
2. Use the calculator to convert 5 MB into bytes.
3. Convert the decimal number 13 into binary.
4. Find a file on your computer and check its size. Which unit does the operating system use?
