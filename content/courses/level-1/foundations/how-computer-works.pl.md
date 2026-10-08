---
title: Jak działa komputer?
description: Co robi komputer i jak współpracują jego główne podzespoły.
type: docs
nav_weight: 10
aliases:
  - /pl/courses/foundations/how-computer-works/
---

Komputer może wyglądać na skomplikowany, ale podstawowa zasada jego działania jest prosta:

> **Komputer to maszyna, która bardzo szybko wykonuje instrukcje.**

Niezależnie od tego, czy jest to laptop, smartfon, mały Raspberry Pi, czy ogromny serwer w centrum danych, prawie każdy komputer wykonuje te same cztery podstawowe zadania:

1. **Wejście** — odbieranie informacji.
2. **Przetwarzanie** — ustalanie, co zrobić z tymi informacjami.
3. **Przechowywanie** — zapamiętywanie informacji.
4. **Wyjście** — wyświetlanie lub wysyłanie wyniku.

Na przykład podczas pisania dokumentu:

- klawiatura przekazuje dane **wejściowe**;
- komputer za pomocą procesora oblicza, co powinno wydarzyć się dalej;
- program i zapisany dokument znajdują się w **pamięci masowej**;
- wynik pojawia się na ekranie jako dane **wyjściowe**.

Zajrzyjmy do środka!

---

## Różne rodzaje komputerów

Gdy słyszysz słowo *komputer*, możesz wyobrażać sobie komputer stacjonarny lub laptop.

Komputery mają jednak wiele różnych kształtów i rozmiarów.

### Komputer stacjonarny

Komputer stacjonarny ma zwykle osobny ekran, klawiaturę, mysz i obudowę jednostki centralnej.

Ponieważ wewnątrz obudowy jest więcej miejsca, komputery stacjonarne można zazwyczaj łatwo rozbudować lub naprawić.

### Laptop

Laptop zawiera większość tych samych podzespołów co komputer stacjonarny, ale wszystkie mieszczą się w niewielkiej przenośnej obudowie.

Ekran, klawiatura, bateria, głośniki, kamera i właściwy komputer są ze sobą połączone.

### SBC — komputer jednopłytkowy

**SBC**, czyli **komputer jednopłytkowy** (ang. *Single-Board Computer*), to kompletny komputer zbudowany na jednej niewielkiej płytce drukowanej.

Znanym przykładem jest Raspberry Pi.

Takie komputery przydają się do nauki programowania, robotyki, automatyki domowej i elektroniki.

Mogą być mniejsze od twojej dłoni!

### Serwer

**Serwer** to komputer, który udostępnia usługi innym komputerom lub ich użytkownikom.

Serwer może na przykład:

- przechowywać strony internetowe;
- zapisywać pliki;
- zbierać pomiary z czujników;
- wysyłać wiadomości e-mail;
- udostępniać bazy danych;
- uruchamiać modele sztucznej inteligencji.

Serwer nie musi wyglądać wyjątkowo. Może być małym komputerem albo dużą maszyną; oba mogą świadczyć takie same rodzaje usług.

### Czy smartfon jest komputerem?

Tak!

Smartfon zdecydowanie jest komputerem.

Ma:

- procesor;
- pamięć operacyjną;
- pamięć masową;
- system operacyjny;
- ekran;
- połączenia sieciowe;
- czujniki;
- urządzenia wejścia i wyjścia.

Twój telefon to potężny mały komputer, który mieści się w kieszeni.

> **Zastanów się:**\
> Jakie inne przedmioty wokół ciebie mogą skrywać komputer?

Samochody, telewizory, zegarki, sygnalizacje świetlne, pralki, roboty, a nawet niektóre zabawki zawierają komputery.

## Rodzaje komputerów na zdjęciach

{{< image-carousel
       "medium"
       "images/computer-types/laptop.jpg|Laptop|Laptop"
       "images/computer-types/minipc.jpg|Kompaktowy komputer stacjonarny|Minikomputer"
       "images/computer-types/raspberry-pi.avif|Komputer jednopłytkowy Raspberry Pi|Komputer jednopłytkowy"
       "images/computer-types/server.jpg|Serwer montowany w szafie|Serwer"
       "images/computer-types/rack.webp|Serwery zamontowane w szafach|Serwerownia"
    >}}

---

## Podzespoły komputera

Otwórzmy komputer i zajrzyjmy do środka.

Bez obaw — niczego nie zepsujemy!

Większość komputerów zawiera kilka ważnych podzespołów.

### CPU — procesor

**CPU**, czyli **centralna jednostka przetwarzająca** (ang. *Central Processing Unit*), jest czasem nazywany *mózgiem komputera*.

Jego zadaniem jest wykonywanie instrukcji.

Na przykład:

```text
Dodaj te dwie liczby.
Odczytaj ten czujnik.
Otwórz ten plik.
Wyświetl ten obraz.
Sprawdź, czy hasło jest poprawne.
```

Nowoczesny procesor może wykonywać miliardy operacji na sekundę.

Nie „myśli” jednak jak ludzki mózg. Po prostu wykonuje instrukcje niewiarygodnie szybko.

---

### RAM — pamięć krótkotrwała

**RAM**, czyli **pamięć o dostępie swobodnym** (ang. *Random Access Memory*), jest krótkotrwałą pamięcią roboczą komputera.

Wyobraź sobie, że odrabiasz lekcje przy biurku.

Przedmioty leżące na biurku przypominają pamięć RAM:

- zeszyt;
- ołówek;
- kalkulator;
- czytana książka.

Łatwo po nie sięgnąć, ponieważ właśnie ich używasz.

Po otwarciu strony internetowej lub uruchomieniu programu część potrzebnych informacji jest kopiowana do pamięci RAM, aby procesor miał do nich szybki dostęp.

Pamięć RAM ma jednak ważne ograniczenie:

> Po wyłączeniu komputera informacje przechowywane w pamięci RAM znikają.

---

### Pamięć masowa — pamięć długotrwała

Komputer potrzebuje również miejsca do przechowywania informacji po wyłączeniu.

Służy do tego **pamięć masowa**.

Przechowywane są w niej:

- zdjęcia;
- prace domowe;
- filmy;
- programy;
- system operacyjny.

Nowoczesne komputery zazwyczaj korzystają z **dysku SSD**, czyli dysku półprzewodnikowego (ang. *Solid-State Drive*).

Możesz też spotkać określenie **dysk SSD NVMe**. NVMe umożliwia dyskowi SSD szybką komunikację z komputerem.

W przeciwieństwie do pamięci RAM pamięć masowa zachowuje pliki nawet po wyłączeniu komputera.

---

### GPU — procesor graficzny

**GPU**, czyli **procesor graficzny** (ang. *Graphics Processing Unit*), tworzy obrazy, filmy i grafikę 3D wyświetlane na ekranie.

Potrafi wykonywać wiele podobnych obliczeń jednocześnie. Dzięki temu GPU przydaje się również w nauce i sztucznej inteligencji.

Niektóre komputery mają osobną kartę graficzną, a inne mniejszy układ GPU wewnątrz procesora. Nie każdy komputer potrzebuje wydajnego GPU.

---

### Płyta główna

Wszystkie te podzespoły muszą się ze sobą komunikować.

**Płyta główna** to duża płytka drukowana, która łączy najważniejsze części komputera.

Procesor, pamięć RAM, pamięć masowa, urządzenia sieciowe i inne podzespoły komunikują się przez połączenia na płycie głównej.

Płytę główną można sobie wyobrazić jako małe miasto pełne dróg.

Informacje nieustannie przemieszczają się między różnymi podzespołami.

---

### Zasilacz

Komputery potrzebują energii elektrycznej.

W komputerze stacjonarnym **zasilacz**, czyli **PSU** (ang. *Power Supply Unit*), przekształca prąd z gniazdka na napięcia wymagane przez podzespoły komputera.

Laptop robi coś podobnego, ale ma również baterię.

Bez prądu nawet najszybszy procesor na świecie jest tylko bardzo drogim kawałkiem metalu i krzemu.

---

## Urządzenia peryferyjne

Komputery komunikują się również z otaczającymi je urządzeniami.

Takie urządzenia często nazywamy **urządzeniami peryferyjnymi**.

Przykłady to:

- klawiatura;
- mysz;
- monitor;
- drukarka;
- mikrofon;
- głośniki;
- kamera internetowa;
- czujnik temperatury;
- pamięć USB.

Niektóre urządzenia peryferyjne dostarczają dane **wejściowe**.

Na przykład:

```text
Klawiatura → komputer
Mysz → komputer
Mikrofon → komputer
```

Inne przekazują dane **wyjściowe**:

```text
Komputer → ekran
Komputer → głośniki
Komputer → drukarka
```

Niektóre urządzenia potrafią robić jedno i drugie.

Na przykład karta sieciowa może zarówno wysyłać, jak i odbierać informacje.

---

## Czym jest sterownik?

Czasami komputer potrzebuje niewielkiego programu, aby wiedzieć, jak komunikować się z urządzeniem.

Taki program nazywamy **sterownikiem**.

Sterownik można sobie wyobrazić jako tłumacza.

System operacyjny mówi:

> „Wydrukuj ten obraz”.

Sterownik drukarki wie, jak przełożyć tę prośbę na instrukcje zrozumiałe dla drukarki.

Nowoczesne systemy operacyjne zawierają już wiele popularnych sterowników, więc możesz nawet nie zauważyć ich działania.

---

## Podzespoły na zdjęciach

{{< image-carousel
       "medium"
       "images/computers/CPU.jpg|Procesor|Procesor"
       "images/computers/RAM.png|Moduły pamięci RAM|Pamięć krótkotrwała"
       "images/computers/SSD.jpg|Dysk SSD NVMe|Pamięć długotrwała"
       "images/computers/GPU.jpg|Karta graficzna|Procesor graficzny"
       "images/computers/Motherboard.jpg|Płyta główna komputera|Płyta główna"
       "images/computers/PSU.jpg|Zasilacz komputerowy|Zasilacz"
    >}}

---

## Zbuduj własny papierowy komputer

Zbudujmy teraz komputer — bez kupowania drogich podzespołów!

### Czego potrzebujesz

Przygotuj kawałki kolorowego papieru:

- czarny kwadrat → **CPU**
- zielone prostokąty → **RAM**
- szary prostokąt → **SSD**
- duży prostokąt → **płyta główna**
- kolejny element → **zasilacz**

Potrzebne będą również:

- biała kartka papieru;
- nożyczki;
- klej;
- kredki.

### Twoje zadanie

Przyklej podzespoły do kartki papieru.

Następnie narysuj linie pokazujące, jak poszczególne podzespoły się komunikują.

Zastanów się:

- Gdzie powinien znaleźć się procesor?
- Gdzie powinna znaleźć się pamięć RAM?
- Co trzeba podłączyć do płyty głównej?
- Skąd pochodzi energia elektryczna?
- Gdzie podłączysz klawiaturę?
- Gdzie podłączysz ekran?

Możesz nawet dodać własne podzespoły.

Być może twój komputer potrzebuje:

- karty Wi-Fi;
- czujnika temperatury;
- trzech dysków SSD;
- ogromnego wentylatora chłodzącego!

Nie musi być idealny. Chodzi o zrozumienie, jak poszczególne części łączą się w całość.

---

## Ile prądu zużywa komputer?

Nie każdy komputer potrzebuje tyle samo energii elektrycznej.

Mały komputer może zużywać zaledwie kilka watów.

Laptop może zużywać kilkadziesiąt watów.

Wydajna stacja robocza lub serwer AI może zużywać setki, a nawet tysiące watów.

Moc elektryczną mierzymy w **watach**, oznaczanych literą **W**.

Aby oszacować ilość energii zużywanej przez komputer:

```text
Energia = moc × czas
```

Na rachunkach za prąd zwykle używa się **kilowatogodzin**, czyli **kWh**.

Wyobraź sobie na przykład komputer zużywający **100 watów** przez 10 godzin. Zużyje on:

```text
100 × 10 = 1000 watogodzin = 1 kWh
```

{{< energy-calculator >}}

### Ćwiczenie: zasilanie małego domowego laboratorium

Napoleon chce zbudować domowe laboratorium. Szukał serwera i zapisywał jego pobór mocy. Który serwer powinien wybrać do swojego domowego laboratorium?

| Urządzenie | Moc |
|---|---:|
| Raspberry Pi 5 | 12 W |
| Minikomputer Intel NUC 13 Pro | 30 W |
| Serwer HPE ProLiant DL360 Gen11 | 300 W |
| Serwer AI Dell PowerEdge XE9680 | 1500 W |

Załóż, że wszystkie cztery komputery działają bez przerwy przez rok:

1. Użyj kalkulatora, aby obliczyć roczny koszt w złotych i euro.

{{% bs/collapse "Pokaż odpowiedź" success %}}

| Urządzenie | Energia na rok | Koszt w PLN | Koszt w euro |
|---|---:|---:|---:|
| Raspberry Pi 5 | 105,12 kWh | 120,94 PLN | 28,48 EUR |
| Minikomputer Intel NUC 13 Pro | 262,8 kWh | 302,35 PLN | 71,19 EUR |
| Serwer HPE ProLiant DL360 Gen11 | 2628 kWh | 3023,51 PLN | 711,93 EUR |
| Serwer AI Dell PowerEdge XE9680 | 13 140 kWh | 15 117,57 PLN | 3559,63 EUR |

Nie ma jednego poprawnego wyboru, ponieważ nie wiemy, jakie zadania komputer ma wykonywać. Napoleon powinien wybrać najmniejszy komputer, który niezawodnie poradzi sobie z jego zadaniami.

{{% /bs/collapse %}}

---

## Właściwy komputer do właściwego zadania

Większy nie zawsze znaczy lepszy.

Wyobraź sobie, że chcesz mierzyć temperaturę na zewnątrz raz na godzinę.

Czy potrzebujesz ogromnego serwera?

Prawdopodobnie nie!

Mały, energooszczędny komputer lub mikrokontroler może sobie z tym poradzić.

Może nawet działać na baterii i niewielkim panelu słonecznym.

Wyobraź sobie jednak, że chcesz wytrenować ogromny model sztucznej inteligencji.

Wtedy możesz potrzebować wielu wydajnych komputerów pracujących razem.

Wybór komputera polega na dobraniu **właściwego narzędzia do zadania**.

Dobry inżynier pyta:

> „Jaki jest najmniejszy i najprostszy system, który może rozwiązać mój problem?”

Mniejsze zużycie energii może oznaczać:

- mniejsze baterie;
- mniej ciepła;
- niższe rachunki za prąd;
- mniej chłodzenia;
- mniej odpadów.

I pamiętaj:

> **Wielka moc obliczeniowa wiąże się z wielką odpowiedzialnością.**

---

## Czego się nauczyłeś

Wiesz już, że:

- komputer to maszyna, która wykonuje instrukcje;
- komputery mają wiele kształtów i rozmiarów;
- procesor wykonuje instrukcje;
- RAM jest szybką pamięcią tymczasową;
- pamięć masowa przechowuje informacje przez długi czas;
- płyta główna łączy podzespoły;
- urządzenia peryferyjne umożliwiają komputerom kontakt ze światem zewnętrznym;
- różne komputery zużywają bardzo różne ilości energii elektrycznej.

A co najważniejsze:

> Komputer to nie magia.

To zbiór prostych części, które wykonują proste zadania **niezwykle szybko**.

{{< quiz title="Sprawdź swoją wiedzę" >}}
questions:
  - question: "Która lista zawiera cztery podstawowe zadania komputera?"
    answers:
      - text: "Wejście, przetwarzanie, przechowywanie i wyjście"
        correct: true
      - text: "Pisanie, drukowanie, przeglądanie i obliczanie"
        correct: false
      - text: "CPU, RAM, SSD i GPU"
        correct: false
  - question: "Co robi procesor?"
    answers:
      - text: "Przechowuje pliki po wyłączeniu komputera"
        correct: false
      - text: "Wykonuje instrukcje"
        correct: true
      - text: "Dostarcza energię elektryczną"
        correct: false
  - question: "Który podzespół traci swoją zawartość po wyłączeniu zasilania?"
    answers:
      - text: "Dysk SSD"
        correct: false
      - text: "Płyta główna"
        correct: false
      - text: "Pamięć RAM"
        correct: true
      - text: "Zasilacz"
        correct: false
  - question: "Co łączy główne podzespoły komputera?"
    answers:
      - text: "Płyta główna"
        correct: true
      - text: "Monitor"
        correct: false
      - text: "System operacyjny"
        correct: false
  - question: "Które urządzenie zużywa najmniej energii w przykładzie z lekcji?"
    answers:
      - text: "Raspberry Pi 5"
        correct: true
      - text: "HPE ProLiant DL360 Gen11"
        correct: false
      - text: "Dell PowerEdge XE9680"
        correct: false
{{< /quiz >}}

W następnej lekcji dowiesz się, jak system operacyjny pomaga programom korzystać ze sprzętu komputera.
