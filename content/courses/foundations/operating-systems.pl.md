---
title: Systemy operacyjne
description: Dowiedz się, jak system operacyjny zarządza komputerem.
type: docs
nav_weight: 20
---

Dowiedz się, czym zajmuje się system operacyjny i jak łączy sprzęt, aplikacje oraz użytkowników.

## Sprzęt i oprogramowanie

Świetnie! Zbudowaliśmy komputer. Mamy procesor, pamięć RAM, pamięć masową i zasilanie. Sprzęt może się uruchomić, ale nadal potrzebuje instrukcji, zanim zrobi coś użytecznego. Brakuje oprogramowania.

### Sprzęt

**Sprzęt** to fizyczne części komputera, których można dotknąć: procesor, płyta główna, klawiatura, ekran, pamięć RAM i dysk SSD.

### Oprogramowanie

**Oprogramowanie** to instrukcje, które mówią sprzętowi, co ma robić: gry, przeglądarki, programy graficzne, narzędzia programistyczne czy odtwarzacze muzyki.

Sprzęt bez oprogramowania nie wie, jakie zadanie wykonać. Oprogramowanie bez sprzętu nie ma gdzie działać. Potrzebują siebie nawzajem.

## System operacyjny

Bardzo ważnym rodzajem oprogramowania jest **system operacyjny**, w skrócie **OS**. Być może znasz już systemy Windows, macOS, Linux, Android i iOS.

System operacyjny pośredniczy między programami a sprzętem. Na przykład gra, która chce odtworzyć dźwięk, nie musi znać każdego modelu głośnika — prosi o to system:

```text
Gra → System operacyjny → Sprzęt dźwiękowy
```

System operacyjny wykonuje kilka ważnych zadań:

- **programy** — uruchamia aplikacje i dzieli między nie czas procesora;
- **pamięć** — przydziela programom miejsce w RAM-ie i oddziela je od siebie;
- **pliki** — porządkuje dane w plikach i folderach;
- **urządzenia** — komunikuje się ze sprzętem za pomocą sterowników;
- **użytkownicy i bezpieczeństwo** — kontroluje konta, uprawnienia i dostęp;
- **sieci** — pomaga aplikacjom komunikować się z innymi komputerami.

System operacyjny można traktować jak **zarządcę komputera**.

> Sprzęt jest ciałem. System operacyjny je budzi. 👻

### Uruchamianie komputera

Po naciśnięciu przycisku zasilania niewielki program zapisany w oprogramowaniu układowym sprawdza sprzęt i szuka systemu do uruchomienia. Następnie **program rozruchowy** ładuje system operacyjny do pamięci RAM. Na końcu system uruchamia swoje usługi i wyświetla ekran logowania lub wiersz poleceń.

```text
Zasilanie → Oprogramowanie układowe → Program rozruchowy → System operacyjny
```

### Jądro i interfejs

**Jądro** jest główną częścią systemu operacyjnego. Zarządza procesorem, pamięcią i urządzeniami, gdy wokół niego działają aplikacje. Linux powstał jako jądro stworzone przez Linusa Torvaldsa w 1991 roku. Pełna dystrybucja Linuksa dodaje do niego narzędzia, aplikacje i interfejs użytkownika.

Z systemu można korzystać przez interfejs graficzny, używając okien i ikon, albo przez interfejs wiersza poleceń, wpisując komendy. Wiele systemów udostępnia oba sposoby.

## Otwarte oprogramowanie

**Oprogramowanie open source** udostępnia kod źródłowy, który zgodnie z jego licencją można analizować, modyfikować i rozpowszechniać. Linux jest dobrze znanym przykładem, natomiast Windows i macOS są głównie oprogramowaniem własnościowym.

Unia Europejska wspiera współpracę sektora publicznego przez [Open Source Observatory (OSOR)](https://interoperable-europe.ec.europa.eu/collection/open-source-observatory-osor). Niektóre europejskie administracje zastępują również systemy własnościowe Linuksem i innymi projektami open source. [Przeczytaj przykład z Francji](https://interoperable-europe.ec.europa.eu/collection/open-source-observatory-osor/news/france-phases-out-proprietary-operating-systems-workstations).

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
