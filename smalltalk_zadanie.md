# Języki programowania – Smalltalk – zadanie projektowe

**Politechnika Gdańska**  
Wydział Elektroniki, Telekomunikacji i Informatyki  
**Prowadząca:** Magdalena Godlewska  
**Rok akademicki:** 2026/27

---

## Projekt: GoSmall – planer podróży

Należy opracować uproszczony system planowania podróży wykorzystujących różne środki transportu. Można wymyślić dowolny scenariusz podróży (na uczelnię, na wakacje, w kosmosie, coś innego).

Najważniejszym elementem projektu jest zastosowanie:
- dziedziczenia i hierarchii klas,
- polimorfizmu i redefiniowania komunikatów,
- komunikatów z różną liczbą argumentów,
- agregacji obiektów różnych klas,
- dynamicznego rozpoznawania typu obiektu.

Program nie wymaga interfejsu graficznego, bazy danych, komunikacji sieciowej ani API.  
Wyniki działania programu powinny być prezentowane tekstowo.

---

## Ogólny scenariusz

Użytkownik planuje podróż składającą się z kilku odcinków.

**Przykładowa podróż:**

```text
Dom
  │  Pieszo: 0,8 km
  ▼
Przystanek
  │  Autobus: 6,5 km
  ▼
Dworzec
  │  Rower: 2,1 km
  ▼
Uczelnia
```

System powinien umożliwiać tworzenie odcinków, łączenie ich w trasy oraz obliczanie łącznego dystansu, czasu i kosztu podróży.

Do podstawowego scenariusza każdy zespół wybiera dodatkowe moduły spośród zaproponowanych w dalszej części zadania *(uwaga: w opisie ogólnym wspomniano o 4 modułach, natomiast w dalszej części i tabeli punktacji o 3 modułach dodatkowych)*.

---

## Moduły podstawowe
*(takie same dla wszystkich zespołów)*

### MODUŁ 1. Środki transportu i dziedziczenie (2 pkt)

1. Należy utworzyć klasę nadrzędną `OdcinekPodrozy`.
2. Należy utworzyć przynajmniej 3 klasy potomne:
   - `Pieszo`,
   - `Rower`,
   - `Autobus`.
3. Każdy odcinek powinien przechowywać punkt początkowy, punkt końcowy oraz dystans.
4. Każdy odcinek musi obsługiwać komunikaty: `dystans`, `czas`, `koszt`, `opis`.
5. Komunikaty `czas` i `koszt` powinny być implementowane odpowiednio do rodzaju transportu.
6. Nie należy powielać wspólnego kodu w klasach potomnych.

#### Przykład polimorfizmu

Ten sam komunikat wysłany do obiektów różnych klas może dawać różne wyniki:

```smalltalk
pieszo czas.   "Pieszo:  72 min"
rower czas.    "Rower:   24 min"
autobus czas.  "Autobus: 15 min"
```

> **Ważne:** O tym, która implementacja komunikatu `czas` zostanie wykonana, decyduje rzeczywista klasa odbiorcy.

---

### MODUŁ 2. Łączenie odcinków – komunikat `+` (2 pkt)

1. Należy utworzyć klasę `Trasa`, przechowującą uporządkowaną kolekcję odcinków podróży.
2. Należy zdefiniować komunikat (operator) `+`, umożliwiający:
   - połączenie dwóch odcinków w nową trasę,
   - dołączenie odcinka do istniejącej trasy,
   - połączenie dwóch tras.
3. Wynikiem każdej operacji powinien być obiekt klasy `Trasa`.
4. Implementacja powinna wykorzystywać redefiniowanie komunikatu `+` w różnych klasach oraz dynamiczne rozpoznawanie typu argumentu.
5. Próba połączenia obiektów nieobsługiwanych klas powinna powodować zgłoszenie błędu.
6. Operacje nie powinny modyfikować istniejących tras – wynikiem powinien być nowy obiekt.

#### Przykład

```smalltalk
trasa1 := pieszo + autobus.
trasa2 := rower + pociag.
trasa3 := trasa1 + trasa2.
trasa4 := trasa3 + pieszo2.
trasa5 := trasa4 + "taki sobie tekst"   "=> błąd"
```

---

### MODUŁ 3. Trasa jako agregator (2 pkt)

1. Klasa `Trasa` powinna przechowywać kolekcję odcinków różnych klas.
2. Powinna obsługiwać komunikaty:
   - `dystans`,
   - `czas`,
   - `koszt`,
   - `drukuj`.
3. Łączne wartości powinny być obliczane przez wysyłanie odpowiednich komunikatów do odcinków.
4. Nie wolno tworzyć osobnych kolekcji dla różnych rodzajów transportu.
5. Nie wolno obliczać czasu i kosztu przez rozpoznawanie klasy każdego odcinka. Wymagane jest wykorzystanie polimorfizmu.

#### Przykładowy wynik

```text
TRASA

1. Pieszo
   Dom -> Przystanek
   0,8 km | 10 min | 0 zł

2. Autobus
   Przystanek -> Dworzec
   6,5 km | 18 min | 4,80 zł

3. Rower
   Dworzec -> Uczelnia
   2,1 km | 9 min | 1 zł

Dystans: 9,4 km
Czas:    37 min
Koszt:   5,80 zł
```

---

## Moduły dodatkowe
*(należy wybrać 3 dowolne, pasujące do wybranego scenariusza)*

### MODUŁ A. Opóźnienia
- Wybrane środki transportu mogą otrzymywać opóźnienia.
- Należy zaimplementować komunikat `opoznienie: minuty`.
- Opóźnienie powinno wpływać na czas podróży.
- Zmiana opóźnienia jednego odcinka powinna automatycznie wpływać na czas całej trasy.

### MODUŁ B. Przesiadki
- Należy wprowadzić czas oczekiwania między odcinkami.
- Czas oczekiwania powinien być uwzględniany w łącznym czasie podróży.
- Dla odcinków realizowanych bezpośrednio po sobie oczekiwanie może wynosić zero.
- Program powinien prezentować czas przejazdu i czas oczekiwania oddzielnie.

### MODUŁ C. Najszybsza trasa
- Należy utworzyć klasę `PlanerPodrozy`.
- Planer powinien przechowywać kilka alternatywnych tras.
- Należy zaimplementować komunikat `najszybsza`.
- Wynikiem powinien być obiekt reprezentujący trasę o najkrótszym czasie podróży.
- Porównywanie tras powinno wykorzystywać ich komunikaty `czas`.

### MODUŁ D. Najtańsza trasa
- Planer podróży powinien umożliwiać przechowywanie alternatywnych tras.
- Należy zaimplementować komunikat `najtansza`.
- Wynikiem powinien być obiekt reprezentujący trasę o najniższym koszcie.
- Należy uwzględnić wszystkie koszty odcinków.
- Należy zaprezentować porównanie kosztów przynajmniej 3 tras.

### MODUŁ E. Ekologia
- Każdy rodzaj transportu powinien obsługiwać komunikat `emisjaCO2`.
- Emisja powinna zależeć od dystansu i rodzaju transportu.
- Trasa powinna obliczać łączną emisję $CO_{2}$.
- Należy umożliwić porównanie tras pod względem emisji.
- Wartości współczynników emisji mogą być przyjęte w uproszczeniu ;)

### MODUŁ F. Pasażerowie i ulgi
- Należy utworzyć klasę `Pasazer` oraz przynajmniej 2 klasy potomne reprezentujące rodzaje pasażerów.
- Różne rodzaje pasażerów powinny mieć różne zasady naliczania ulg.
- Należy zaimplementować komunikat `kosztDla: pasazer`.
- Ten sam odcinek może mieć różny koszt dla różnych pasażerów.
- Trasa powinna umożliwiać obliczenie całkowitego kosztu dla wskazanego pasażera.

### MODUŁ G. Warunki podróży
- Należy utworzyć klasę `Warunki` opisującą warunki podróży, np. pogodę i natężenie ruchu.
- Należy zaimplementować komunikat `czasDla: warunki`.
- Warunki powinny wpływać różnie na poszczególne środki transportu.
- Należy umożliwić obliczenie czasu całej trasy dla wskazanych warunków.
- **Przykład:** deszcz może spowolnić rowerzystę, a korek autobus.

### MODUŁ H. Upraszczanie trasy
- Należy zaimplementować komunikat `uprość`.
- Sąsiadujące odcinki tego samego rodzaju transportu mogą zostać połączone.
- Łączenie jest możliwe wyłącznie wtedy, gdy odcinki są ciągłe (`przystanekA -> przystanekB`; `przystanekB -> przystanekC`).
- Uproszczenie nie powinno zmieniać łącznego dystansu; czas lub koszt mogą się zmienić, jeśli zaimplementowana została do tego zasadna funkcjonalność, np. przesiadki.
- Należy zaprezentować trasę przed uproszczeniem i po nim.

### MODUŁ I. Poprawność trasy
- Należy zaimplementować komunikat `sprawdz`.
- Program powinien weryfikować, czy koniec jednego odcinka jest początkiem kolejnego.
- W przypadku wykrycia nieciągłości należy wskazać problematyczne odcinki.
- Należy zaprezentować przykład trasy poprawnej i niepoprawnej.

### MODUŁ J. Plan alternatywny
- Należy umożliwić zastąpienie wybranego odcinka innym.
- Nowy odcinek może reprezentować inny rodzaj transportu.
- Należy zaimplementować komunikat `zastap: staryOdcinek przez: nowyOdcinek`.
- Zmiana powinna automatycznie wpływać na parametry trasy.
- Należy zaprezentować trasę przed zmianą i po zmianie.

### MODUŁ K. Wymyślony przez grupę
1. Można opracować własną funkcjonalność, która będzie pasowała do scenariusza.
2. Musi wiązać się z definicją nowej klasy lub komunikatu i być wykorzystana w chociaż jednej klasie już istniejącej lub być agregatorem istniejących obiektów.
3. W razie wątpliwości można omówić propozycję z prowadzącą.

---

## Wymagania

1. Tematyka scenariusza ma być ogólnie związana z podróżowaniem i spójna.
2. Program powinien wykorzystywać sensowną hierarchię klas i dziedziczenie.
3. Należy zastosować polimorfizm – ten sam komunikat powinien mieć różne implementacje w zależności od klasy odbiorcy.
4. Należy zdefiniować i wykorzystać komunikat `+`.
5. Należy wykorzystać kolekcję zawierającą obiekty różnych klas.
6. Należy zaimplementować komunikat przyjmujący obiekt dowolnego typu i rozpoznający jego klasę.
7. Należy wykorzystywać mechanizmy kolekcji i iteracji dostępne w Smalltalku.
8. Nie jest wymagany interfejs graficzny.
9. Program powinien poprawnie obsługiwać błędne dane i nieprawidłowe operacje.
10. Należy przygotować przykłady demonstrujące działanie wszystkich wybranych modułów.

---

## Punktacja

| Element | Punkty |
| :--- | :---: |
| Moduł 1: Środki transportu i dziedziczenie | 2 |
| Moduł 2: Łączenie odcinków – komunikat `+` | 2 |
| Moduł 3: Trasa jako agregator | 2 |
| 3 wybrane moduły dodatkowe | 4,5 |
| Wykorzystanie kolekcji i iteracji | 1 |
| Prawidłowe zastosowanie polimorfizmu | 1 |
| Podział odpowiedzialności klas i dziedziczenie | 1 |
| Jakość programu, testy, obsługa błędów i prezentacja | 1,5 |
| **Razem** | **15** |