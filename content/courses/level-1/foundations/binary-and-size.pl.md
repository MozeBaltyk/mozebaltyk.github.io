---
title: System binarny i rozmiar danych
description: Dowiedz się, jak komputery zapisują informacje za pomocą bitów i mierzą je w bajtach.
type: docs
nav_weight: 40
---

Komputery pracują z tekstem, obrazami, muzyką i filmami, ale wszystkie te informacje zapisują za pomocą tylko dwóch wartości: **0** i **1**.

## Dlaczego komputery używają systemu binarnego

Wewnątrz komputera znajdują się miliardy niewielkich elektronicznych przełączników. Każdy z nich może być w jednym z dwóch stanów: wyłączonym lub włączonym. Zapisujemy je jako:

- `0` — wyłączony;
- `1` — włączony.

Pojedynczą wartość binarną nazywamy **bitem**. Słowo *bit* pochodzi od angielskiego wyrażenia **binary digit**, czyli cyfra binarna.

Liczby binarne wykorzystują potęgi liczby dwa. Każda pozycja ma wartość dwa razy większą od pozycji znajdującej się po jej prawej stronie:

| Liczba binarna | Liczba dziesiętna |
|---:|---:|
| `0000` | 0 |
| `0001` | 1 |
| `0010` | 2 |
| `0011` | 3 |
| `0100` | 4 |
| `1000` | 8 |
| `1111` | 15 |

Na przykład `1101` oznacza **8 + 4 + 0 + 1 = 13**.

## Od bitów do bajtów

Osiem bitów tworzy jeden **bajt**:

> **8 bitów = 1 bajt**

Bajt może przyjąć 256 różnych wzorców — od `00000000` do `11111111`. To wystarcza do zapisania liczby od 0 do 255.

Komputery przypisują wzorce do informacji. Na przykład w ASCII wielka litera `A` ma wartość 65, czyli `01000001` w systemie binarnym. Współczesny tekst korzysta z Unicode, dzięki czemu komputery mogą zapisywać znaki z wielu języków, między innymi `ą`, `é` i `中`.

## Mierzenie ilości danych

Bajty łączymy w większe jednostki:

| Jednostka | Rozmiar dziesiętny | Przykład |
|---|---:|---|
| bajt (B) | 1 bajt | jeden prosty znak tekstowy |
| kilobajt (KB) | 1000 bajtów | krótki plik tekstowy |
| megabajt (MB) | 1000 KB | zdjęcie lub piosenka |
| gigabajt (GB) | 1000 MB | film lub wiele aplikacji |
| terabajt (TB) | 1000 GB | duży dysk lub kopia zapasowa |

Możesz również spotkać jednostki **KiB**, **MiB** i **GiB**. Są to jednostki binarne:

- 1 KiB = 1024 bajty;
- 1 MiB = 1024 KiB;
- 1 GiB = 1024 MiB.

Producenci pamięci masowych zwykle używają jednostek dziesiętnych, natomiast systemy operacyjne mogą wyświetlać jednostki binarne. Dlatego po podłączeniu dysku do komputera może się wydawać, że jest on nieco mniejszy.

## Kalkulator bajtów

Wybierz wartość i jednostkę, aby zobaczyć tę samą ilość danych wyrażoną w bitach, bajtach oraz większych jednostkach dziesiętnych i binarnych.

{{< byte-calculator >}}

## Małe komputery mogą wykonywać ważne zadania

Program Voyager NASA obejmuje dwie bliźniacze sondy kosmiczne, Voyager 1 i Voyager 2, wystrzelone w 1977 roku w celu zbadania olbrzymich planet Układu Słonecznego. Nadal komunikują się z Ziemią. Pamięć ich komputerów pokładowych mierzy się w **dziesiątkach kilobajtów**, a nie w gigabajtach spotykanych we współczesnych telefonach.

Nowoczesny kluczyk samochodowy również zawiera mały komputer. Jego dokładne możliwości zależą od modelu, ale ilość pamięci zwykle mierzy się w kilobajtach. Niektóre kluczyki mają dziś więcej pamięci niż sondy Voyager wysłane w przestrzeń kosmiczną.

<div class="row g-3 my-4">
  <div class="col-md-6">
    <figure class="h-100 mb-0">
      <div class="ratio ratio-16x9 bg-body-tertiary rounded overflow-hidden">
        <img src="/courses/level-1/foundations/images/key.webp" class="w-100 h-100 object-fit-contain" alt="Nowoczesny elektroniczny kluczyk samochodowy">
      </div>
      <figcaption class="small text-body-secondary text-center mt-2">Kluczyk samochodowy zawiera mały, wyspecjalizowany komputer.</figcaption>
    </figure>
  </div>
  <div class="col-md-6">
    <figure class="h-100 mb-0">
      <div class="ratio ratio-16x9 bg-body-tertiary rounded overflow-hidden">
        <img src="/courses/level-1/foundations/images/voyager.webp" class="w-100 h-100 object-fit-contain" alt="Sonda kosmiczna Voyager podróżująca przez przestrzeń kosmiczną">
      </div>
      <figcaption class="small text-body-secondary text-center mt-2">Voyager pokazuje, jak wiele można osiągnąć dzięki starannie napisanemu oprogramowaniu i niewielkiej pamięci.</figcaption>
    </figure>
  </div>
</div>

Wniosek jest prosty: komputer nie potrzebuje ogromnej ilości pamięci, jeżeli ma jedno konkretne zadanie i starannie napisane oprogramowanie.

## Spróbuj samodzielnie

1. Ile bitów znajduje się w 10 bajtach?
2. Użyj kalkulatora, aby przeliczyć 5 MB na bajty.
3. Zamień liczbę dziesiętną 13 na liczbę binarną.
4. Znajdź plik na swoim komputerze i sprawdź jego rozmiar. Jakiej jednostki używa system operacyjny?
