"=== MODUŁ 2: Klasa Trasa (zdefiniowana jako pierwsza, aby OdcinekPodrozy mógł jej używać) ==="
Object subclass: Trasa [
    | odcinki |

    "Konstruktor inicjalizujący pustą OrderedCollection (str. 2 i 3 samouczka)"
    Trasa class >> new [
        | t |
        t := super new.
        t ustawOdcinki: OrderedCollection new.
        ^t
    ]

    "Pomocniczy setter do nadania nowej kolekcji etapów"
    ustawOdcinki: kolekcja [
        odcinki := kolekcja
    ]

    "Getter wymagany przez mini-testy ze str. 5 samouczka"
    odcinki [
        ^odcinki
    ]

    "2, 3, 4, 5, 6. Operator + obsługujący: Trasa + OdcinekPodrozy oraz Trasa + Trasa"
    + drugi [
        | wynik nowaTrasa |
        wynik := OrderedCollection new.
        wynik addAll: odcinki.

        (drugi isKindOf: OdcinekPodrozy)
            ifTrue: [
                wynik add: drugi.
                nowaTrasa := Trasa new.
                nowaTrasa ustawOdcinki: wynik.
                ^nowaTrasa
            ].

        (drugi isKindOf: Trasa)
            ifTrue: [
                wynik addAll: drugi odcinki.
                nowaTrasa := Trasa new.
                nowaTrasa ustawOdcinki: wynik.
                ^nowaTrasa
            ].

        self error: 'Oczekiwano odcinka lub trasy'
    ]
]

"=== MODUŁ 1: Klasa OdcinekPodrozy i podklasy ==="
Object subclass: OdcinekPodrozy [
    | poczatek koniec dystans |

    OdcinekPodrozy class >> new [
        | op |
        op := super new.
        op od: '' do: '' dystans: 0.
        ^op
    ]

    od: p do: k dystans: d [
        poczatek := p.
        koniec := k.
        dystans := d
    ]

    dystans [ ^dystans ]
    czas [ ^0 ]
    koszt [ ^0 ]
    nazwaTransportu [ ^'Odcinek' ]

    opis [
        ^self nazwaTransportu , ': ' , poczatek , ' -> ' , koniec ,
         ' (dystans: ' , self dystans printString , ' km, czas: ' ,
         self czas printString , ' min, koszt: ' , self koszt printString , ' zl)'
    ]

    "2, 3, 4, 5, 6. Operator + obsługujący: OdcinekPodrozy + OdcinekPodrozy (oraz opcjonalnie Odcinek + Trasa)"
    + drugi [
        | wynik nowaTrasa |
        (drugi isKindOf: OdcinekPodrozy)
            ifTrue: [
                wynik := OrderedCollection new.
                wynik add: self.
                wynik add: drugi.
                nowaTrasa := Trasa new.
                nowaTrasa ustawOdcinki: wynik.
                ^nowaTrasa
            ].

        (drugi isKindOf: Trasa)
            ifTrue: [
                wynik := OrderedCollection new.
                wynik add: self.
                wynik addAll: drugi odcinki.
                nowaTrasa := Trasa new.
                nowaTrasa ustawOdcinki: wynik.
                ^nowaTrasa
            ].

        self error: 'Oczekiwano odcinka lub trasy'
    ]
]

OdcinekPodrozy subclass: Pieszo [
    nazwaTransportu [ ^'Pieszo' ]
    czas [ ^self dystans * 12 ]
]

OdcinekPodrozy subclass: Rower [
    nazwaTransportu [ ^'Rower' ]
    czas [ ^self dystans * 4 ]
]

OdcinekPodrozy subclass: Autobus [
    nazwaTransportu [ ^'Autobus' ]
    czas [ ^(self dystans * 2) + 2 ]
    koszt [ ^4 ]
]

"=== TESTY MODUŁU 1 (z Twoimi etapami) ==="
| etapy |
etapy := OrderedCollection new.
etapy add: (Pieszo new od: 'Armata' do: 'Przystanek' dystans: 1).
etapy add: (Autobus new od: 'Przystanek' do: 'Centrum' dystans: 5).
etapy add: (Rower new od: 'Centrum' do: 'Dom' dystans: 3).

Transcript show: '--- Test Modulu 1 ---'; cr.
etapy do: [ :etap |
    Transcript show: etap opis; cr
].

"=== MINI TESTY PLANERA ZE STR. 5 SAMOUCZKA (weryfikacja Modułu 2) ==="
| a b c d lewa prawa dluzsza calosc sprawdz blad |
sprawdz := [ :warunek :opis |
    warunek ifFalse: [ Error signal: opis ] ].

a := Pieszo new od: 'Armata' do: 'Przystanek' dystans: 1.
b := Autobus new od: 'Przystanek' do: 'Centrum' dystans: 5.
c := Rower new od: 'Centrum' do: 'Dom' dystans: 3.
d := Pieszo new od: 'Dom' do: 'Sklep' dystans: 2.

lewa := a + b.
prawa := c + d.
dluzsza := lewa + c.
calosc := lewa + prawa.

sprawdz value: (lewa isKindOf: Trasa) value: 'Typ wyniku'.
sprawdz value: (dluzsza odcinki asArray = (Array with: a with: b with: c))
    value: 'Trasa + odcinek'.
sprawdz value: (calosc odcinki asArray = (Array with: a with: b with: c with: d))
    value: 'Trasa + trasa'.
sprawdz value: (lewa odcinki asArray = (Array with: a with: b))
    value: 'Zmieniona lewa trasa'.
sprawdz value: (prawa odcinki asArray = (Array with: c with: d))
    value: 'Zmieniona prawa trasa'.

blad := false.
[ lewa + 7 ] on: Error do: [ :e | blad := true ].
sprawdz value: blad value: 'Brak bledu dla liczby'.

Transcript show: 'Testy Modulu 2: OK'; cr.