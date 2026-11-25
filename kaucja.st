"=== MODUŁ 4: Kaucja (osobny plik: kaucja.st) ==="

Object subclass: Kaucja [
    | stawka |
    Instancja := nil.

    "Konstruktor wzorowany na samouczku - losuje stawkę (1..3 zł/km)"
    Kaucja class >> new [
        | k |
        k := super new.
        k losujStawke.
        ^k
    ]

    "Wspólna instancja - gwarantuje jedno losowanie i spójność w Trasa >> drukuj"
    Kaucja class >> domyslna [
        Instancja isNil ifTrue: [ Instancja := self new ].
        ^Instancja
    ]

    losujStawke [
        stawka := Random between: 1 and: 3
    ]

    stawka [ ^stawka ]

    "Zarobek to ujemny koszt: -(dystans * stawka)"
    dlaDystansu: km [
        ^0 - (km * stawka)
    ]
]

"Rozszerzenie istniejącej klasy Pieszo o użycie klasy Kaucja"
Pieszo extend [
    koszt [
        ^Kaucja domyslna dlaDystansu: self dystans
    ]
]

"=== TEST MODUŁU 4 ==="
| a b c trasa stawka sprawdz |
sprawdz := [ :warunek :opis |
    warunek ifFalse: [ Error signal: opis ] ].

a := Pieszo new od: 'Armata' do: 'Przystanek' dystans: 2.
b := Autobus new od: 'Przystanek' do: 'Centrum' dystans: 5.
c := Rower new od: 'Centrum' do: 'Dom' dystans: 3.

trasa := a + b + c.
stawka := Kaucja domyslna stawka.

sprawdz value: ((stawka >= 1) and: [ stawka <= 3 ]) value: 'Stawka spoza zakresu 1..3'.
sprawdz value: (a koszt = (0 - (2 * stawka))) value: 'Bledna kaucja dla Pieszo'.
sprawdz value: (trasa koszt = (6 - (2 * stawka))) value: 'Bledny laczny koszt trasy'.

Transcript cr; show: 'Testy Modulu 4 (Kaucja): OK'; cr.
Transcript show: 'Wylosowana stawka kaucji: ' , stawka printString , ' zl/km'; cr; cr.
trasa drukuj.