---
title: Why IT Matters
description: Discover why information technology matters.
type: docs
nav_weight: 30
aliases:
  - /courses/foundations/stakes-of-it/
---

**Information technology (IT)** means using computers to work with information. IT helps us learn, work, communicate, and understand the world. It can solve useful problems, but it can also cause problems. That is why our choices matter.

---

## What Can We Do With a Computer?

Computers are tools that can do many different jobs. They can solve real-life problems and make everyday tasks easier. We can use them to:

- make information easier to access;
- do repeated tasks for us;
- help people communicate;
- study information from science experiments;
- control a robot;
- monitor energy use in a home;
- run a weather station;
- warn people about poor air quality;
- provide useful services to other computers.

These jobs look different, but computers do the same basic things in each one:

1. **Input** — receive data.
2. **Processing** — follow instructions and work with the data.
3. **Storage** — keep data for later.
4. **Output** — present a result or make something happen.
5. **Communication** — send data to and receive data from other devices.

```text
Input → Processing → Output
           ↕
        Storage
           ↕
     Communication
```

For example, a weather station measures the temperature, saves each measurement, checks how the weather changes, shows a graph, and sends the results to another computer.

## Three Important Ideas

### Collecting Data

A computer needs **input** before it can help us.

Sensors can collect data about the world, such as:

- temperature;
- air quality;
- light;
- movement;
- electricity use.

Computers can store these measurements so we can compare them later. Data can also come from people, for example through a keyboard, button, or form.

Before collecting data, we should ask: **Do we need it, and is it safe to store?**

### Using Data

A computer follows instructions to work with data. This is called **processing**.

For example, it can:

- calculate an average temperature;
- find the highest measurement;
- notice an unusual value;
- create a chart;
- send a warning when something is wrong.

Collecting data is only useful when we know what question we want it to answer.

### Communicating

Computers can help people communicate, but computers also communicate with one another.

For example, a weather sensor can send measurements to another computer that displays them on a dashboard.

The Internet is not the only way devices communicate. They can also use:

- cables;
- Wi-Fi;
- Bluetooth;
- mobile networks;
- **LoRa**, which can send small messages over long distances while using little power.

The best method depends on the distance, available power, amount of data, and whether an Internet connection is available.

<img src="/courses/level-1/foundations/images/networks/LoRa%20and%20Internet.png" class="d-block mw-100 mx-auto" alt="A LoRa sensor sends small messages to a gateway, which forwards them through the Internet.">

---

## From Data to Decisions

Computers become useful when data helps us understand something or take action. We might collect:

- how hard a computer's CPU, memory, and disk are working;
- how much electricity a house uses;
- temperature and air quality every hour;
- the location of buses or planes;
- water levels during heavy rain.

Software can put the measurements in order, calculate averages, spot unusual values, and warn us when something may be wrong. A dashboard shows the results with numbers, colors, and charts.

{{< image-carousel
       "medium"
       "images/dashboards/Dashboard_Computer.png|A dashboard showing computer metrics|Computer monitoring"
       "images/dashboards/Dashboard_Weather.webp|A dashboard showing weather measurements|Weather monitoring"
       "images/dashboards/Dashboard_Planes.png|A dashboard showing aircraft data|Aircraft tracking"
    >}}

Data is not always correct. A broken sensor can give a wrong measurement. A chart can also give us the wrong idea if some information is missing. We must check the data before using it to make a decision.

---

## Why Our Choices Matter

Technology can help people, but it can also cause harm. What happens depends on how we design and use it.

### People

Technology can help people learn, communicate, stay healthy, and take part in activities. It can also distract people, reveal private information, spread information that is not true, or be difficult for some people to use.

Before collecting personal data, ask:

- Do we really need it?
- Did the person agree to share it?
- Who can access it?
- How long will we keep it?
- How will we protect it?

### Society

Hospitals, schools, banks, buses, trains, and governments depend on computers. Systems that work well can make these services faster and safer. Broken systems, computer attacks, unfair decisions, or a lack of access can affect many people at once.

It is not enough to ask whether a system *works*. We should also ask whether it is fair, safe, dependable, and easy to understand.

### The Environment

Computers need materials and energy. Making them uses metals, water, and electricity. Servers and networks need power to run. Throwing away old devices creates electronic waste, or **e-waste**.

We can reduce the impact by:

- choosing the smallest computer that can do the job;
- making software that does not waste computer power;
- switching off equipment that is not needed;
- repairing or upgrading devices instead of replacing them;
- reusing equipment;
- taking e-waste to a proper recycling point.

The newest or most powerful computer is not always the best choice.

---

## Projects That Help Us Learn

A small project can connect all these ideas. You might build a weather station, an air-quality monitor, or an LED sign that shows a useful message. Each project receives input, works with or stores data, and produces output.

{{< image-carousel
       "medium"
       "images/projects/diy-weather-station.jpg|A homemade weather station|Weather station"
       "images/projects/air_quality_monitor.webp|An air-quality monitor|Air-quality monitor"
       "images/projects/air_quality_monitor2.jpg|Electronics used to monitor air quality|Air-quality electronics"
       "images/projects/LED_project.webp|A colorful LED project|LED project"
    >}}

While planning a project, think beyond the electronics:

- What problem does it solve?
- What data does it collect?
- Could that data reveal anything private?
- How much energy will it use?
- What happens if it gives a wrong answer?
- Can it be repaired and reused?

Good technology starts with a clear purpose. We should think about how it may help or harm people before we build it.

---

## Mini Challenge

Look around you and find **three computers**. Remember that they do not have to look like laptops.

For each one, identify:

1. What data does it receive as **input**?
2. What does it **process**?
3. What information does it **store**?
4. What **output** does it produce?
5. Does it **communicate** with another device?
6. How does it help, and what problem might it cause?

Example:

```text
Smart thermostat

Input: room temperature and the desired temperature
Processing: decides when to turn the heating on or off
Storage: saves the schedule and previous measurements
Output: controls the heating and displays the temperature
Communication: can send information to a phone
Benefit: keeps the home comfortable while reducing energy use
Possible problem: a wrong reading could waste energy or make the room too cold
```

Can you find a computer that another person might not immediately recognize as one?

---

## What You Learned

You now know that:

- computers receive, process, store, output, and communicate data;
- data can help people understand problems and make decisions;
- technology can create both benefits and harm;
- technology should protect private information and be safe, fair, dependable, and usable by everyone;
- making, using, and throwing away computers affects the environment;
- responsible technology begins with asking the right questions.

> The goal is not to use the most technology. It is to use the right technology responsibly.

{{< quiz title="Test your knowledge" >}}
questions:
  - question: "What can a computer do with data?"
    answers:
      - text: "Receive, process, store, output, and communicate it"
        correct: true
      - text: "Only store it"
        correct: false
      - text: "Only display it"
        correct: false
  - question: "Why should measurements be checked?"
    answers:
      - text: "Sensors and data can be wrong or misleading"
        correct: true
      - text: "Computers never store measurements"
        correct: false
      - text: "Charts cannot show data"
        correct: false
  - question: "Which question should be asked before collecting personal data?"
    answers:
      - text: "Do we need it, and how will we protect it?"
        correct: true
      - text: "Can we collect as much as possible?"
        correct: false
      - text: "Can we keep it forever?"
        correct: false
  - question: "Which choice can reduce harm to the environment?"
    answers:
      - text: "Repairing and reusing devices"
        correct: true
      - text: "Replacing every device each year"
        correct: false
      - text: "Leaving unused equipment switched on"
        correct: false
  - question: "What is a responsible way to choose a computer?"
    answers:
      - text: "Choose the smallest system that can do the job well"
        correct: true
      - text: "Always choose the most powerful system"
        correct: false
      - text: "Ignore energy use and whether it can be repaired"
        correct: false
{{< /quiz >}}
