"=== MODUŁ 2 i 3: Klasa Trasa (łączenie + agregacja i drukowanie) ==="
Object subclass: Trasa [
    | odcinki |

    Trasa class >> new [
        | t |
        t := super new.
        t ustawOdcinki: OrderedCollection new.
        ^t
    ]

    ustawOdcinki: kolekcja [
        odcinki := kolekcja
    ]

    odcinki [
        ^odcinki
    ]

    "Moduł 2: Polimorficzny operator +"
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

    "Moduł 3: Agregacja wartości przez polimorficzne wysyłanie komunikatów do odcinków"
    dystans [
        ^odcinki inject: 0 into: [ :suma :etap | suma + etap dystans ]
    ]

    czas [
        ^odcinki inject: 0 into: [ :suma :etap | suma + etap czas ]
    ]

    koszt [
        ^odcinki inject: 0 into: [ :suma :etap | suma + etap koszt ]
    ]

    "Moduł 3: Drukowanie trasy w formacie z przykładowego wyniku"
    drukuj [
        | nr |
        Transcript show: '--------- TRASA ---------'; cr.
        nr := 1.
        odcinki do: [ :etap |
            Transcript show: nr printString , '. ' , etap nazwaTransportu; cr.
            Transcript show: '   ' , etap poczatek , ' -> ' , etap koniec; cr.
            Transcript show: '   ' , etap dystans printString , ' km | ' ,
                etap czas printString , ' min | ' ,
                etap koszt printString , ' zl'; cr.
            nr := nr + 1
        ].
        Transcript show: '-------------------------'; cr.
        Transcript show: 'Dystans: ' , self dystans printString , ' km'; cr.
        Transcript show: 'Czas:    ' , self czas printString , ' min'; cr.
        Transcript show: 'Koszt:   ' , self koszt printString , ' zl'; cr.
        Transcript show: '-------------------------'; cr
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

    poczatek [ ^poczatek ]
    koniec [ ^koniec ]
    dystans [ ^dystans ]
    czas [ ^0 ]
    koszt [ ^0 ]
    nazwaTransportu [ ^'Odcinek' ]

    opis [
        ^self nazwaTransportu , ': ' , poczatek , ' -> ' , koniec ,
         ' (dystans: ' , self dystans printString , ' km, czas: ' ,
         self czas printString , ' min, koszt: ' , self koszt printString , ' zl)'
    ]

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

"=== TESTY MODUŁÓW 1, 2 i 3 ==="
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

"Weryfikacja Modułu 2"
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

"Weryfikacja Modułu 3 (agregacja na Twojej trasie Armata -> Przystanek -> Centrum -> Dom)"
sprawdz value: (dluzsza dystans = 9) value: 'Bledny laczny dystans'.
sprawdz value: (dluzsza czas = 36) value: 'Bledny laczny czas'.
sprawdz value: (dluzsza koszt = 4) value: 'Bledny laczny koszt'.
Transcript show: 'Testy Modulu 3: OK'; cr; cr.

"Wydruk całej trasy"
dluzsza drukuj.