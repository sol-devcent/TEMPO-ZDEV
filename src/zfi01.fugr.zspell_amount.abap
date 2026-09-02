FUNCTION ZSPELL_AMOUNT.
*"----------------------------------------------------------------------
*"*"Local interface:
*"       IMPORTING
*"             VALUE(AMOUNT) DEFAULT 0
*"             VALUE(CURRENCY) LIKE  SY-WAERS DEFAULT SPACE
*"             VALUE(FILLER) DEFAULT SPACE
*"             VALUE(LANGUAGE) LIKE  SY-LANGU DEFAULT SY-LANGU
*"       EXPORTING
*"             VALUE(IN_WORDS) LIKE  SPELL STRUCTURE  SPELL
*"       EXCEPTIONS
*"              NOT_FOUND
*"              TOO_LARGE
*"----------------------------------------------------------------------

* Analyse und Merken des Übergabeparameters AMOUNT
  DESCRIBE FIELD amount TYPE type DECIMALS decimals.
  IF type EQ 'P'.
    int_amount = amount *  ( 10 ** decimals ).
  ELSE.
    int_amount = amount.
  ENDIF.

* Merken der Importing-Parameter, die in LF017F01 benutzt werden
  int_decimal  = 0.
  int_filler   = space.
  int_filler+1 = filler.
  int_language = language.

* Nach- und Vorkommastellen (falls Währungsbetrag zu bearbeiten ist)
  IF currency NE space.
    IF currency EQ '0'.                "Sicherheitsabfrage (sonst Loop
      tcurx-currdec = 0.               "bei fehlendem Eintrag 0)
    ELSE.
      SELECT SINGLE * FROM tcurx
        WHERE currkey EQ currency.
      IF sy-subrc NE 0.
        tcurx-currdec = 2.
      ENDIF.
    ENDIF.
    int_divisor = 1.
    DO tcurx-currdec TIMES.
      int_divisor = int_divisor * 10.
    ENDDO.
    int_decimal = int_amount MOD int_divisor.
    int_amount  = int_amount DIV int_divisor.
    int_divisor = 1000000000.
    DO tcurx-currdec TIMES.
      int_divisor = int_divisor / 10.
    ENDDO.
    int_decimal = int_decimal * int_divisor.
  ENDIF.

* Geschlecht der Währungsbezeichnung ... (allgemein)
  IF language CA 'PSR8'.
    IF currency EQ space.
      int_genus = 'M'.
    ELSE.
      IF tcurc-waers NE currency.
        CLEAR tcurc.
        SELECT SINGLE * FROM tcurc WHERE waers EQ currency.
      ENDIF.
*     ... in Portugiesisch und Spanisch
      IF ( language CA 'PS' AND
           ( 'ADP/CYL/CZK/DKK/EEK/EGP/ESP/GBL/GBP/IDR' CS tcurc-isocd OR
             'IEP/INR/ITL/LBP/LKR/MTL/MUR/NOK/NPR/PKR' CS tcurc-isocd OR
             'SCR/SDP/SEK/SKK/SYP/TRL' CS tcurc-isocd ) AND
           tcurc-isocd NE space ) OR
*     ... in Russisch und Ukrainisch
         ( language CA 'R8' AND
           ( 'ADP/AON/BDT/BWP/CZK/DEM/DKK/EEK/ESP/FIM' CS tcurc-isocd OR
             'GRD/HRK/INR/ISK/ITL/JPY/PGK/PKR/SCR/SEK' CS tcurc-isocd OR
             'AOR/ERN/IDR/LKR/MOP/MUR/MVR/MWK/NGN/NOK' CS tcurc-isocd OR
             'SKK/STD/TOP/TRL/UAH/WST/ZMK/NPR/PAB' CS tcurc-isocd ) AND
           tcurc-isocd NE space ).
        int_genus = 'F'.
      ELSE.
        int_genus = 'M'.
      ENDIF.
    ENDIF.
  ENDIF.

* ISO-Code der Währung nachlesen bei tschechisch, slowakisch, russisch
* und koreanisch (Südkorea) zur Ausgabe der Währungsbezeichnung
  IF language CA 'CQR3'.
    CLEAR tcurc.
    SELECT SINGLE * FROM tcurc WHERE waers = currency.
  ENDIF.

* Prüfen, ob Betrag zu groß ist
  IF int_amount(5) NE '00000'.
    MESSAGE e074 WITH int_amount RAISING too_large.
  ELSE.
    int_zahl = int_amount+5.
  ENDIF.

* Füllen der Ergebnis-Feldleiste IN_WORDS
  PERFORM ziffern_in_worten.
  PERFORM betrag_in_worten.
  PERFORM nachkomma_in_worten.
  in_words = spell.

ENDFUNCTION.
