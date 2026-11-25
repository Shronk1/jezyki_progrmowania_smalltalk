"=== MODUŁ I: Poprawność trasy (komunikat sprawdz) ===
 Uruchomienie: gst i_poprawnosc.st LUB gst odcinek.st i_poprawnosc.st"
(Smalltalk includesKey: #Trasa) ifFalse: [ FileStream fileIn: 'odcinek.st' ].

"Pojedyncza wykryta nieciągłość: para sąsiednich odcinków, które się nie łączą"
Object subclass: Nieciaglosc [
    | numer poprzedni nastepny |

    "Konstruktor z 3 argumentami: numer pierwszego odcinka pary i oba odcinki"
    Nieciaglosc class >> numer: n poprzedni: p nastepny: k [
        ^self new ustawNumer: n poprzedni: p nastepny: k
    ]

    ustawNumer: n poprzedni: p nastepny: k [
        numer := n.
        poprzedni := p.
        nastepny := k
    ]

    numer [ ^numer ]
    poprzedni [ ^poprzedni ]
    nastepny [ ^nastepny ]

    opis [
        ^'Koniec odcinka ' , numer printString , ' (' , poprzedni koniec ,
         ') nie jest poczatkiem odcinka ' , (numer + 1) printString ,
         ' (' , nastepny poczatek , ')'
    ]
]

OdcinekPodrozy extend [
    "Czy po tym odcinku można kontynuować podróż obiektem cos?
     Przyjmuje dowolny obiekt i rozpoznaje jego klasę."
    laczySieZ: cos [
        (cos isKindOf: OdcinekPodrozy)
            ifTrue: [ ^self koniec = cos poczatek ].
        (cos isKindOf: Trasa)
            ifTrue: [
                cos odcinki isEmpty ifTrue: [ ^true ].
                ^self laczySieZ: cos odcinki first ].
        ^self error: 'Oczekiwano odcinka lub trasy'
    ]
]

Trasa extend [
    "Wszystkie miejsca, w których koniec odcinka nie jest początkiem kolejnego"
    nieciaglosci [
        | numery |
        numery := (1 to: odcinki size - 1) reject: [ :i |
            (odcinki at: i) laczySieZ: (odcinki at: i + 1) ].
        ^numery collect: [ :i |
            Nieciaglosc
                numer: i
                poprzedni: (odcinki at: i)
                nastepny: (odcinki at: i + 1) ]
    ]

    jestCiagla [
        ^self nieciaglosci isEmpty
    ]

    "Moduł I: weryfikuje ciągłość, drukuje raport i zwraca true/false"
    sprawdz [
        | bledy |
        Transcript show: '------ SPRAWDZENIE ------'; cr.
        odcinki isEmpty ifTrue: [
            Transcript show: 'Trasa jest pusta - brak odcinkow do sprawdzenia'; cr.
            Transcript show: '-------------------------'; cr.
            ^true ].

        bledy := self nieciaglosci.
        bledy isEmpty
            ifTrue: [
                Transcript show: 'Trasa poprawna: ' , odcinki first poczatek ,
                    ' -> ' , odcinki last koniec ,
                    ' (liczba odcinkow: ' , odcinki size printString , ')'; cr ]
            ifFalse: [
                Transcript show: 'Trasa NIEPOPRAWNA - liczba nieciaglosci: ' ,
                    bledy size printString; cr.
                bledy do: [ :blad |
                    Transcript show: ' * ' , blad opis; cr.
                    Transcript show: '     ' , blad numer printString , '. ' ,
                        blad poprzedni opis; cr.
                    Transcript show: '     ' , (blad numer + 1) printString , '. ' ,
                        blad nastepny opis; cr ] ].
        Transcript show: '-------------------------'; cr.
        ^bledy isEmpty
    ]
]

"=== TESTY I DEMO MODUŁU I ==="
| a b c d x y z poprawna niepoprawna pojedyncza bledy wynik blad sprawdzWarunek |
sprawdzWarunek := [ :warunek :opis |
    warunek ifFalse: [ Error signal: opis ] ].

[
    a := Pieszo new od: 'Armata' do: 'Przystanek' dystans: 1.
    b := Autobus new od: 'Przystanek' do: 'Centrum' dystans: 5.
    c := Rower new od: 'Centrum' do: 'Dom' dystans: 3.
    d := Pieszo new od: 'Dom' do: 'Sklep' dystans: 2.

    x := Pieszo new od: 'Armata' do: 'Przystanek' dystans: 1.
    y := Rower new od: 'Centrum' do: 'Park' dystans: 4.
    z := Autobus new od: 'Dom' do: 'Sklep' dystans: 2.

    poprawna := a + b + c + d.
    niepoprawna := x + y + z.
    pojedyncza := Trasa new + a.

    "laczySieZ: - rozpoznawanie klasy argumentu"
    sprawdzWarunek value: (a laczySieZ: b) value: 'Odcinki a i b powinny sie laczyc'.
    sprawdzWarunek value: (a laczySieZ: c) not value: 'Odcinki a i c nie powinny sie laczyc'.
    sprawdzWarunek value: (a laczySieZ: (b + c)) value: 'Odcinek a powinien laczyc sie z trasa b+c'.
    sprawdzWarunek value: (a laczySieZ: (c + d)) not value: 'Odcinek a nie powinien laczyc sie z trasa c+d'.
    sprawdzWarunek value: (a laczySieZ: Trasa new) value: 'Pusta trasa zawsze pasuje'.
    blad := false.
    [ a laczySieZ: 'Centrum' ] on: Error do: [ :e | blad := true. e return: nil ].
    sprawdzWarunek value: blad value: 'Brak bledu dla napisu w laczySieZ:'.

    "Trasa poprawna"
    sprawdzWarunek value: poprawna jestCiagla value: 'Poprawna trasa uznana za nieciagla'.
    sprawdzWarunek value: poprawna nieciaglosci isEmpty value: 'Poprawna trasa ma nieciaglosci'.

    "Trasa niepoprawna: dwie nieciągłości, między odcinkami 1-2 i 2-3"
    bledy := niepoprawna nieciaglosci.
    sprawdzWarunek value: niepoprawna jestCiagla not value: 'Niepoprawna trasa uznana za ciagla'.
    sprawdzWarunek value: bledy size = 2 value: 'Zla liczba nieciaglosci'.
    sprawdzWarunek value: ((bledy collect: [ :n | n numer ]) asArray = #(1 2))
        value: 'Zle numery nieciaglosci'.
    sprawdzWarunek value: (bledy first poprzedni == x and: [ bledy first nastepny == y ])
        value: 'Zle odcinki pierwszej nieciaglosci'.
    sprawdzWarunek value: (bledy last poprzedni == y and: [ bledy last nastepny == z ])
        value: 'Zle odcinki drugiej nieciaglosci'.

    "Przypadki brzegowe: trasa pusta i jednoodcinkowa"
    sprawdzWarunek value: Trasa new jestCiagla value: 'Pusta trasa powinna byc ciagla'.
    sprawdzWarunek value: pojedyncza jestCiagla value: 'Trasa z 1 odcinkiem powinna byc ciagla'.

    "Sprawdzenie nie zmienia trasy"
    sprawdzWarunek value: (niepoprawna odcinki asArray = (Array with: x with: y with: z))
        value: 'Sprawdzenie zmienilo trase'.
    Transcript showCr: 'Testy Modulu I: OK'; cr.

    "Demo: trasa poprawna"
    poprawna drukuj.
    wynik := poprawna sprawdz.
    sprawdzWarunek value: wynik value: 'sprawdz zwrocil false dla poprawnej trasy'.
    Transcript cr.

    "Demo: trasa niepoprawna"
    niepoprawna drukuj.
    wynik := niepoprawna sprawdz.
    sprawdzWarunek value: wynik not value: 'sprawdz zwrocil true dla niepoprawnej trasy'.
    Transcript cr.

    "Demo: trasa pusta"
    Trasa new sprawdz.
    Transcript flush
] on: Error do: [ :e |
    Transcript flush.
    Transcript showCr: 'BLAD: ' , (e messageText ifNil: [ e description ]).
    Transcript flush.
    ObjectMemory quit: 1 ].
