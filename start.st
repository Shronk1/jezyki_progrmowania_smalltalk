"=== GoSmall - plik startowy: wczytuje wszystkie moduly po kolei ===
 Uruchomienie (z katalogu projektu): gst start.st"

FileStream fileIn: 'odcinek.st'.       "Moduly 1, 2, 3 i A"
FileStream fileIn: 'i_poprawnosc.st'.  "Modul I"
FileStream fileIn: 'kaucja.st'.        "Modul K - Kaucja (na koncu: zmienia koszt Pieszo)"
