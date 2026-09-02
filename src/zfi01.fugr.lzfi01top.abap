FUNCTION-POOL ZFI01 MESSAGE-ID F1.                        "MESSAGE-ID ..
TABLES:
  spell,                               "zur Aufnahme des Ergebnisses
 *spell,                               "zum rekursiven Aufruf
  tcurc,                               "für den ISO-Code
  tcurx,                               "Dezimalstellen der Währungen
  zt015z,
  t015z.                               "Zahlen und Ziffern in Worten

DATA BEGIN OF t015z_merken OCCURS 20.  "merkt sich die bereits gelesenen
  INCLUDE STRUCTURE t015z.             "Einträge der T015Z, um doppeltes
DATA END OF t015z_merken.              "Lesen zu vermeiden

DATA:
  int_amount(20)    TYPE n,            "umzusetzende Zahl
  int_decimal(9)    TYPE n,            "Nachkommastellen
  int_divisor(10)   TYPE n,            "Divisor zur Berechnung
  int_filler(2)     TYPE c,            "Hilfe für die Füllzeichen
  int_genus(1)      TYPE c,            "Geschlecht der Währung
  int_language      LIKE sy-langu,     "Sprache, in der umgesetzt wird

  BEGIN OF int_zahl,                   "umzusetzende Zahl ohne Nachkomma
     bio(3)         TYPE c,            "Billionen
     mia(3)         TYPE c,            "Milliarden
     mio(3)         TYPE c,            "Millionen
     tsd(3)         TYPE c,            "Tausend
     hun(3)         TYPE c,            "Hundert
  END OF int_zahl.

DATA:
  decimals          TYPE p,            "Hilfsfeld für DESCRIBE
  type              TYPE c.            "Hilfsfeld für DESCRIBE
