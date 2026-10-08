---
title: Systemy operacyjne
description: Dowiedz się, jak system operacyjny zarządza komputerem.
type: docs
nav_weight: 20
aliases:
  - /pl/courses/foundations/operating-systems/
---

Dowiedz się, czym zajmuje się system operacyjny i jak łączy sprzęt, aplikacje oraz użytkowników.

## Sprzęt i oprogramowanie

Świetnie! Zbudowaliśmy komputer. Mamy procesor, pamięć RAM, pamięć masową i zasilanie. Sprzęt może się uruchomić, ale nadal potrzebuje instrukcji, zanim zrobi coś użytecznego. Brakuje oprogramowania.

### Sprzęt

**Sprzęt** to fizyczne części komputera, których można dotknąć: procesor, płyta główna, klawiatura, ekran, pamięć RAM i dysk SSD.

### Oprogramowanie

**Oprogramowanie** to instrukcje, które mówią sprzętowi, co ma robić. Przeglądarki, edytory tekstu, programy graficzne, kalkulatory i programy do śledzenia pogody są oprogramowaniem.

Sprzęt bez oprogramowania nie wie, jakie zadanie wykonać. Oprogramowanie bez sprzętu nie ma gdzie działać. Potrzebują siebie nawzajem.

## System operacyjny

Bardzo ważnym rodzajem oprogramowania jest **system operacyjny**, w skrócie **OS**. Być może znasz już systemy Windows, macOS, systemy oparte na Linuksie, Android i iOS.

System operacyjny pośredniczy między programami a sprzętem. Na przykład program pogodowy nie musi wiedzieć, jak działa każdy czujnik temperatury. Prosi system operacyjny o komunikację z czujnikiem:

```text
Program pogodowy → System operacyjny → Czujnik temperatury
```

### Różne systemy operacyjne

Różne urządzenia mogą korzystać z różnych systemów operacyjnych:

- **Windows** działa na wielu komputerach stacjonarnych i laptopach;
- **macOS** działa na komputerach Apple Mac;
- **systemy oparte na Linuksie**, takie jak Ubuntu i Raspberry Pi OS, mogą działać na dużych i małych komputerach;
- **Android** i **iOS** działają na telefonach i tabletach;
- **OpenBSD** został zaprojektowany ze szczególnym naciskiem na bezpieczeństwo i poprawność działania.

Mogą wyglądać inaczej i uruchamiać różne aplikacje, ale wszystkie wykonują to samo ważne zadanie: zarządzają komputerem.

{{< image-carousel
       "small"
       "images/os/Linux.png|Tux, maskotka Linuksa|Linux"
       "images/os/apple.png|Logo firmy Apple|macOS jest tworzony przez Apple"
       "images/os/OpenBSD.png|Puffy, maskotka OpenBSD|OpenBSD"
    >}}

System operacyjny wykonuje kilka ważnych zadań:

- **programy** — uruchamia aplikacje i dzieli między nie czas procesora;
- **pamięć** — przydziela programom miejsce w RAM-ie i oddziela je od siebie;
- **pliki** — porządkuje dane w plikach i folderach;
- **urządzenia** — komunikuje się ze sprzętem za pomocą sterowników;
- **użytkownicy i bezpieczeństwo** — kontroluje konta, uprawnienia i dostęp;
- **sieci** — pomaga aplikacjom komunikować się z innymi komputerami.

System operacyjny można traktować jak **zarządcę komputera**. Pomaga wszystkim częściom współpracować.

### Uruchamianie komputera

Po naciśnięciu przycisku zasilania niewielki program zapisany w oprogramowaniu układowym sprawdza sprzęt i szuka systemu do uruchomienia. Następnie **program rozruchowy** ładuje system operacyjny do pamięci RAM. Na końcu system uruchamia swoje usługi i wyświetla ekran logowania lub wiersz poleceń.

```text
Zasilanie → Oprogramowanie układowe → Program rozruchowy → System operacyjny
```

### Jądro i interfejs

**Jądro** jest główną częścią systemu operacyjnego. Zarządza procesorem, pamięcią i urządzeniami, gdy wokół niego działają aplikacje. Linux powstał jako jądro stworzone przez Linusa Torvaldsa w 1991 roku. Pełna dystrybucja Linuksa dodaje do niego narzędzia, aplikacje i interfejs użytkownika.

Z systemu można korzystać przez interfejs graficzny, używając okien i ikon, albo przez interfejs wiersza poleceń, wpisując komendy. Wiele systemów udostępnia oba sposoby.

## Otwarte oprogramowanie

**Oprogramowanie open source** udostępnia kod źródłowy, który zgodnie z jego licencją można analizować, ulepszać i rozpowszechniać. Systemy oparte na Linuksie oraz OpenBSD są dobrze znanymi przykładami. Windows i macOS są głównie oprogramowaniem własnościowym, co oznacza, że ich kod źródłowy jest kontrolowany przez firmę.

Systemy open source są przydatne w nauce i budowaniu projektów, ponieważ można sprawdzić, jak działają, i dostosować je do nowych zadań. Na przykład Raspberry Pi OS jest systemem opartym na Linuksie, często używanym w stacjach pogodowych, robotach i automatyce domowej.

## Małe wyzwanie

Sprawdź, jaki system operacyjny działa na komputerze, tablecie lub telefonie w twoim otoczeniu.

Następnie odpowiedz:

1. Jak nazywa się ten system operacyjny?
2. Jakie przydatne programy uruchamia?
3. Jakim sprzętem zarządza, na przykład ekranem, kamerą, czujnikiem lub drukarką?
4. Czy potrafisz znaleźć miejsce, w którym przechowuje pliki i ustawienia?

{{< quiz title="Sprawdź swoją wiedzę" >}}
questions:
  - question: "Czym jest system operacyjny?"
    answers:
      - text: "Oprogramowaniem, które zarządza sprzętem i uruchamia aplikacje"
        correct: true
      - text: "Rodzajem pamięci komputera"
        correct: false
      - text: "Językiem programowania"
        correct: false
      - text: "Przeglądarką internetową"
        correct: false
  - question: "Która grupa zawiera wyłącznie systemy operacyjne?"
    answers:
      - text: "Chrome, Firefox, Safari"
        correct: false
      - text: "Windows, macOS, Linux"
        correct: true
      - text: "Python, Go, Rust"
        correct: false
  - question: "Czym zarządza system operacyjny?"
    answers:
      - text: "Wyłącznie plikami"
        correct: false
      - text: "Plikami, programami, pamięcią, sprzętem, użytkownikami, siecią i bezpieczeństwem"
        correct: true
      - text: "Wyłącznie sprzętem"
        correct: false
  - question: "Czym jest oprogramowanie open source?"
    answers:
      - text: "Oprogramowaniem, którego kod źródłowy można analizować i modyfikować zgodnie z licencją"
        correct: true
      - text: "Oprogramowaniem działającym wyłącznie w Linuksie"
        correct: false
      - text: "Każdym płatnym oprogramowaniem"
        correct: false
  - question: "Kto stworzył jądro Linux?"
    answers:
      - text: "Bill Gates"
        correct: false
      - text: "Linus Torvalds"
        correct: true
      - text: "Richard Stallman"
        correct: false
{{< /quiz >}}
