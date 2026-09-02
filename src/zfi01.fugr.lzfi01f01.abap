*----------------------------------------------------------------------*
***INCLUDE LZFI01F01 .
*----------------------------------------------------------------------*
************************************************************************
*   Include LF017F01 für den Funktionsbaustein SPELL_AMOUNT            *
************************************************************************

*----------------------------------------------------------------------*
*   Umsetzen der einzelnen Ziffern in Worte                            *
*----------------------------------------------------------------------*
FORM ziffern_in_worten.

  FIELD-SYMBOLS:
    <feld>.

  DATA:
    up_feld(11)  TYPE c,
    up_feldnr(2) TYPE n,
*    up_ziffer(1) TYPE n.
    up_ziffer(1) TYPE c.

  t015z_merken-mandt = sy-mandt.
  t015z_merken-spras = int_language.
  up_feld            = 'SPELL-DIG  '.

  CLEAR spell.
  spell-number  = int_zahl.
  spell-decimal = int_decimal(3).
  spell-currdec = tcurx-currdec.
  CHECK int_language NE space.

*  DO 15 TIMES VARYING up_ziffer FROM int_zahl+0 NEXT int_zahl+1.
  DO 15 TIMES VARYING up_ziffer FROM int_zahl(1) NEXT int_zahl+1(1) RANGE int_zahl.

    up_feldnr = 16 - sy-index.
    WRITE up_feldnr TO up_feld+9.
    ASSIGN (up_feld) TO <feld>.
    PERFORM t015z_lesen USING '0' up_ziffer.
    TRANSLATE t015z-wort USING '; '.
    IF t015z-wort+4 EQ space AND int_filler NE space.
      SHIFT t015z-wort RIGHT.
    ENDIF.
    TRANSLATE t015z-wort USING int_filler.
    <feld> = t015z-wort.

  ENDDO.

ENDFORM.


*----------------------------------------------------------------------*
*   Umsetzen des gesamten Betrags in Worte                             *
*----------------------------------------------------------------------*
FORM betrag_in_worten.

  CHECK int_language NE space.

* Umsetzung für Thai
  IF int_language = '2'.

    PERFORM betrag_in_worten_2.

* Umsetzung für Koreanisch
  ELSEIF int_language = '3'.

    PERFORM betrag_in_worten_3 USING spell-number.

* Japanese
  ELSEIF int_language = 'J'.

    PERFORM betrag_in_worten_j USING spell-number.

* Umsetzung für Chinesisch/Chinesisch traditionell (Mandarin)
  ELSEIF '1/M' CS int_language.

    PERFORM betrag_in_worten_1m USING spell-number.

* Umsetzung für die restlichen Sprachen
  ELSE.

    PERFORM betrag_in_worten_rest.

  ENDIF.

* 000,000,000,000,000
  IF int_zahl = 0.
    PERFORM t015z_lesen USING '0' '0'.
    PERFORM schreiben.
  ENDIF.

* Währung ausschreiben (nur für russische Rubel)
  IF int_language EQ 'R'         AND
     'RUR/RUB'    CS tcurc-isocd AND
     tcurc-isocd  NE space.
    PERFORM t015z_lesen_r USING 'R' int_zahl-hun.
    PERFORM schreiben.
  ENDIF.

* Betrag in Worten linksbündig abstellen und füllen
  IF spell-word NE space.
    WHILE spell-word+254 EQ space.
      SHIFT spell-word RIGHT.
    ENDWHILE.
  ENDIF.
  WHILE spell-word(2) EQ space.
    TRANSLATE spell-word(1) USING int_filler.
    SHIFT spell-word CIRCULAR.
  ENDWHILE.
  IF int_language CA 'CQR8'.           "ggf. Kleinschreibung
    SET LOCALE LANGUAGE int_language.
    TRANSLATE spell-word+2 TO LOWER CASE.
    SET LOCALE LANGUAGE space.
  ENDIF.
  IF int_filler EQ space.
    SHIFT spell-word CIRCULAR.
  ELSE.
    TRANSLATE spell-word(1) USING int_filler.
  ENDIF.
  spell-word+254 = space.              "ansonsten TD799 in SAPscript

ENDFORM.


*----------------------------------------------------------------------*
* Portugiesisch: Ein 3-er Päckchen (HUN, TSD etc) wird vom Vorgänger   *
* durch ein 'E' (und) verbunden, wenn alle kleineren 3-er Päckchen     *
*     alle kleineren 3-er Päckchen Null                                *
*     alle größeren 3-er Päckchen ungleich Null                        *
*     das aktuelle 3-er Päckchen zwischen 1 und 99 oder glatter 100er  *
*----------------------------------------------------------------------*
FORM verbinden USING position.

  DATA:
    up_length    LIKE sy-fdpos,
    up_offset    LIKE sy-fdpos,
    up_kleiner   LIKE int_amount,
    up_groesser  LIKE int_amount,
    up_aktuell   LIKE int_zahl-hun.

  IF int_language EQ 'P'.
    up_length    = ( 5 - position ) * 3.
    up_offset    = up_length + 3.
    IF up_offset NE 15.
      up_kleiner = int_zahl+up_offset.
    ELSE.
      up_kleiner = 0.
    ENDIF.
    up_groesser  = int_zahl(up_length).
    up_aktuell   = int_zahl+up_length(3).
    IF up_kleiner    EQ 0 AND
       up_groesser   NE 0 AND
     ( up_aktuell(1) EQ 0 OR up_aktuell+1 EQ 0 ).
      t015z-wort = 'E ;'.
      PERFORM schreiben.
    ENDIF.
  ENDIF.

ENDFORM.


*----------------------------------------------------------------------*
* Umsetzen der Einer-, Zehner- und Hunderterstellen                    *
* USING-Parameter Einheit wird für die Sprachen S, P und R verwendet   *
* USING-Parameter Zahl enthält die umzusetzende Zahl                   *
*----------------------------------------------------------------------*
FORM hundert_umsetzen USING einheit zahl.

  DATA:
    up_zahl(3)    TYPE c,
    up_einheit(1) TYPE c.

  IF int_language CA 'PS'.             "Portugiesisch/Spanisch:
    IF zahl EQ 100.                    "Einheit bestimmt das Geschlecht
      up_einheit = 'H'.                "bzw. (bei 1xx) das Zahlwort
    ELSEIF zahl GT 100 AND zahl LT 200.
      up_einheit = 'X'.
    ELSEIF int_genus EQ 'M'.
      up_einheit = 'Y'.
    ELSEIF einheit EQ 'T'.
      up_einheit = 'H'.
    ELSE.
      up_einheit = einheit.
    ENDIF.
  ELSE.
    up_einheit = 'H'.
  ENDIF.
  up_zahl = zahl.

  IF zahl GE 100.                      "Hunderterstellen
    PERFORM t015z_lesen USING up_einheit up_zahl(1).
    IF int_language EQ 'P' AND         "Portugiesisch:
       up_zahl+1 NE '00'.              "E einfügen, wenn nicht glatt x00
      REPLACE ';' WITH 'E ;' INTO t015z-wort.
    ENDIF.
    IF int_language EQ 'F' AND         "Französisch  und
       up_zahl+1 NE '00'   AND         "kein glatter Hunderter und
       up_zahl(1) NE '1'.              ">= 200
      REPLACE 'S ;' WITH ' ;' INTO t015z-wort.    "Plural-S entfernen
    ENDIF.
    PERFORM schreiben.
  ENDIF.

  IF up_zahl+1 NE '00'.                "Zehner- und Einerstellen
    IF ( int_language EQ 'C' AND       "Tschechisch:
         up_zahl+2 BETWEEN 1 AND 2 AND "weibliche Form für 01,02,21,22,
         einheit CA 'LH' ) OR          "etc. bei Milliarde und Hundert
       ( int_language EQ 'P' AND       "Portugiesisch:
         int_genus EQ 'F' AND          "weibliche Form für 01,02,21,22,
         up_zahl+2 BETWEEN 1 AND 2 AND "etc. bei Hundert und Tausend
         einheit CA 'HT' ) OR
       ( int_language EQ 'Q' AND       "Slowakisch:
         up_zahl+2 BETWEEN 1 AND 2 AND "weibliche Form für 01,02,21,22,
         einheit EQ 'H' ) OR           "etc. bei Hundert
       ( int_language EQ 'Q' AND
         up_zahl+1 BETWEEN 1 AND 2 AND "weibliche Form für 01 und 02
         einheit EQ 'L' ) OR           "bei Milliarde
       ( int_language EQ 'Q' AND       "sowie bei 2 Tausend
         up_zahl EQ 2 AND
         einheit EQ 'T' ) OR
       ( int_language CA 'R8' AND      "Russisch/Ukrainisch:
         up_zahl+2 BETWEEN 1 AND 2 AND "weibliche Form für 01,02,21,22,
         einheit EQ 'T' ) OR           "etc. bei Tausend
       ( int_language CA 'R8' AND      "Russisch/Ukrainisch:
         up_zahl+2 BETWEEN 1 AND 2 AND "weibliche Form für 01,02,21,22,
         einheit EQ 'H' AND            "etc. bei Hundert und
         int_genus EQ 'F' ).           "weiblichem Währungsnamen
      TRANSLATE up_zahl+1(1) USING '0A112B3C4D5E6F7G8I9J'.
    ENDIF.
    PERFORM t015z_lesen USING up_zahl+1(1) up_zahl+2(1).
    IF int_language EQ 'S' AND         "Spanisch:
       up_zahl+1(1) NE '1' AND         "weibliche oder männliche oder
       up_zahl+2(1) EQ '1'.            "neutrale Form bei 01,21,31, etc.
      IF einheit CA 'HT' AND int_genus EQ 'F'.
        REPLACE 'O ;' WITH 'A ;' INTO t015z-wort.
      ELSE.
        REPLACE 'O ;' WITH ' ;' INTO t015z-wort.
      ENDIF.
    ENDIF.
    PERFORM schreiben.
  ENDIF.

ENDFORM.


*----------------------------------------------------------------------*
* Umsetzen der Tausenderstellen für die Sprache Thai                   *
* USING-Parameter Zahl enthält die umzusetzende Zahl                   *
*----------------------------------------------------------------------*
FORM tausend_umsetzen_thai USING zahl.

  DATA: BEGIN OF up, 3, 2, 1, END OF up.
  up = zahl.

  IF up-3 NE 0.
    PERFORM t015z_lesen USING '0' up-3.
    PERFORM schreiben.
    PERFORM t015z_lesen USING 'Y' '>'.
    PERFORM schreiben.
  ENDIF.
  IF up-2 NE 0.
    PERFORM t015z_lesen USING '0' up-2.
    PERFORM schreiben.
    PERFORM t015z_lesen USING 'X' '>'.
    PERFORM schreiben.
  ENDIF.
  IF up-1 NE 0.
    PERFORM t015z_lesen USING '0' up-1.
    PERFORM schreiben.
    PERFORM t015z_lesen USING 'T' '>'.
    PERFORM schreiben.
  ENDIF.

ENDFORM.


*----------------------------------------------------------------------*
* Schreiben des Inhalts von T015Z-WORT in das Ergebnisfeld SPELL-WORD  *
*----------------------------------------------------------------------*
FORM schreiben.
  if int_language = 'i'.
    IF zt015z-wort NA ';'.
    MESSAGE a076 WITH t015z-spras t015z-einh t015z-ziff.
  ELSE.
    spell-word(30) = zt015z-wort.
    WHILE spell-word(1) NE ';'.
      SHIFT spell-word CIRCULAR.
    ENDWHILE.                          "Betrag in Worten ist nun ohne
    spell-word(30) = space.            "Delimiter rechtsbündig zugefügt
  ENDIF.

  else.
  IF t015z-wort NA ';'.                "Abbruch bei fehlendem Delimiter
    MESSAGE a076 WITH t015z-spras t015z-einh t015z-ziff.
  ELSE.
    spell-word(30) = t015z-wort.
    WHILE spell-word(1) NE ';'.
      SHIFT spell-word CIRCULAR.
    ENDWHILE.                          "Betrag in Worten ist nun ohne
    spell-word(30) = space.            "Delimiter rechtsbündig zugefügt
  ENDIF.
  endif.
ENDFORM.


*----------------------------------------------------------------------*
* Lesen in Tabelle T015Z                                               *
* Gelesene Einträge werden gemerkt und später ggf. wiederverwendet     *
*----------------------------------------------------------------------*
FORM t015z_lesen USING einh ziff.
if int_language = 'i'.
  READ TABLE t015z_merken WITH KEY
    spras = int_language
    einh  = einh
    ziff  = ziff.
  IF sy-subrc EQ 0.
    zt015z = t015z_merken.
  ELSE.
    SELECT SINGLE * FROM zt015z
      WHERE spras EQ int_language
      AND   einh  EQ einh
      AND   ziff  EQ ziff.
    IF sy-subrc NE 0.                  "Mandantendurchgriff
      SELECT SINGLE * FROM zt015z CLIENT SPECIFIED
        WHERE mandt EQ '000'
        AND   spras EQ int_language
        AND   einh  EQ einh
        AND   ziff  EQ ziff.
      IF sy-subrc NE 0.
        MESSAGE e075 WITH int_language einh ziff RAISING not_found.
      ENDIF.
    ENDIF.
    t015z_merken = zt015z.
    APPEND t015z_merken.
  ENDIF.

else.
  READ TABLE t015z_merken WITH KEY
    spras = int_language
    einh  = einh
    ziff  = ziff.
  IF sy-subrc EQ 0.
    t015z = t015z_merken.              "Lesezugriff gespart
  ELSE.
    SELECT SINGLE * FROM t015z
      WHERE spras EQ int_language
      AND   einh  EQ einh
      AND   ziff  EQ ziff.
    IF sy-subrc NE 0.                  "Mandantendurchgriff
      SELECT SINGLE * FROM t015z CLIENT SPECIFIED
        WHERE mandt EQ '000'
        AND   spras EQ int_language
        AND   einh  EQ einh
        AND   ziff  EQ ziff.
      IF sy-subrc NE 0.
        MESSAGE e075 WITH int_language einh ziff RAISING not_found.
      ENDIF.
    ENDIF.
    t015z_merken = t015z.
    APPEND t015z_merken.
  ENDIF.
endif.
ENDFORM.


*----------------------------------------------------------------------*
* Russische Zahlengrammatik                                            *
*----------------------------------------------------------------------*
FORM t015z_lesen_r USING einh zahl.

  DATA: BEGIN OF up, 3, 2, 1, END OF up.
  up = zahl.

  IF up-2 NE 1.
    IF up-1 BETWEEN 2 AND 4.
      PERFORM t015z_lesen USING einh ')'.
    ELSEIF up-1 EQ 1.
      PERFORM t015z_lesen USING einh '='.
    ELSE.
      PERFORM t015z_lesen USING einh '>'.
    ENDIF.
  ELSE.
    PERFORM t015z_lesen USING einh '>'.
  ENDIF.

ENDFORM.


*----------------------------------------------------------------------*
* Umsetzen der Nachkommastellen in Worte                               *
*----------------------------------------------------------------------*
FORM nachkomma_in_worten.

  CHECK int_language <> space AND
        int_divisor <> 1000000000.
  int_decimal = int_decimal / int_divisor.

  IF int_language EQ 'R'         AND
     'RUR/RUB'    CS tcurc-isocd AND
     tcurc-isocd  NE space.

    PERFORM dezimal_in_worte_r USING int_decimal
                                     tcurx-currdec.

  ELSE.

     *spell = spell.
    CALL FUNCTION 'ZSPELL_AMOUNT'
         EXPORTING
              amount    = int_decimal
              currency  = '0'
              filler    = int_filler+1
              language  = int_language
         IMPORTING
              in_words  = spell
         EXCEPTIONS
              not_found = 4.
    IF sy-subrc NE 0.
      MESSAGE e075 WITH sy-msgv1 sy-msgv2 sy-msgv3 RAISING not_found.
    ENDIF.
     *spell-decword = spell-word.
    spell = *spell.

  ENDIF.

ENDFORM.


*----------------------------------------------------------------------*
* Umsetzen des Betrages in Worte für Koreanisch/Japanisch              *
*----------------------------------------------------------------------*
FORM betrag_in_worten_3 USING char_amount.

  DATA: BEGIN OF i_zahl,               "Zahlengrammatik mit Wörtern für
          cho(3) TYPE n,               "  -> 1.000.000.000.000 ...
          okk(4) TYPE n,               "  -> 100.000.000 ...
          man(4) TYPE n,               "  -> 10.000 ...
          tsd(4) TYPE n,               "  -> Tausend ...
        END OF i_zahl,
*        i_ziffer(1) TYPE c,
        i_ziffer(1) TYPE n,
        i_first(1) TYPE c VALUE 'X'.

  i_zahl = char_amount.

* Umwandeln der Stellen xxx.000.000.000.000
*  DO 3 TIMES VARYING i_ziffer FROM i_zahl-cho+0 NEXT i_zahl-cho+1.
  DO 3 TIMES VARYING i_ziffer FROM i_zahl-cho(1) NEXT i_zahl-cho+1(1).
    IF i_ziffer <> 0.
      IF i_ziffer <> 1 OR sy-index = 3 OR i_first = 'X'.
        PERFORM: t015z_lesen USING '0' i_ziffer,
                 schreiben.
      ENDIF.
      CASE sy-index.
        WHEN 1.  PERFORM t015z_lesen USING 'H' '>'.
        WHEN 2.  PERFORM t015z_lesen USING '1' '0'.
        WHEN 3.  PERFORM t015z_lesen USING 'K' '>'.
      ENDCASE.
      PERFORM schreiben.
      CLEAR i_first.
    ELSEIF sy-index = 3 AND i_zahl-cho > 0.
      PERFORM: t015z_lesen USING 'K' '>',
               schreiben.
    ENDIF.
  ENDDO.

* Umwandeln der Stellen 000.xxx.x00.000.000
*  DO 4 TIMES VARYING i_ziffer FROM i_zahl-okk+0 NEXT i_zahl-okk+1.
  DO 4 TIMES VARYING i_ziffer FROM i_zahl-okk(1) NEXT i_zahl-okk+1(1).
    IF i_ziffer <> 0.
      IF i_ziffer <> 1 OR sy-index = 4 OR i_first = 'X'.
        PERFORM: t015z_lesen USING '0' i_ziffer,
                 schreiben.
      ENDIF.
      CASE sy-index.
        WHEN 1.  PERFORM t015z_lesen USING 'T' '='.
        WHEN 2.  PERFORM t015z_lesen USING 'H' '>'.
        WHEN 3.  PERFORM t015z_lesen USING '1' '0'.
        WHEN 4.  PERFORM t015z_lesen USING 'M' '>'.
      ENDCASE.
      PERFORM schreiben.
      CLEAR i_first.
    ELSEIF sy-index = 4 AND i_zahl-okk > 0.
      PERFORM: t015z_lesen USING 'M' '>',
               schreiben.
    ENDIF.
  ENDDO.

* Umwandeln der Stellen 000.000.0xx.xx0.000
*  DO 4 TIMES VARYING i_ziffer FROM i_zahl-man+0 NEXT i_zahl-man+1.
  DO 4 TIMES VARYING i_ziffer FROM i_zahl-man(1) NEXT i_zahl-man+1(1).
    IF i_ziffer <> 0.
      IF i_ziffer <> 1 OR sy-index = 4 OR i_first = 'X'.
        PERFORM: t015z_lesen USING '0' i_ziffer,
                 schreiben.
      ENDIF.
      CASE sy-index.
        WHEN 1.  PERFORM t015z_lesen USING 'T' '='.
        WHEN 2.  PERFORM t015z_lesen USING 'H' '>'.
        WHEN 3.  PERFORM t015z_lesen USING '1' '0'.
        WHEN 4.  PERFORM t015z_lesen USING 'T' '>'.
      ENDCASE.
      PERFORM schreiben.
      CLEAR i_first.
    ELSEIF sy-index = 4 AND i_zahl-man > 0.
      PERFORM: t015z_lesen USING 'T' '>',
               schreiben.
    ENDIF.
  ENDDO.

* Umwandeln der Stellen 000.000.000.00x.xxx
*  DO 4 TIMES VARYING i_ziffer FROM i_zahl-tsd+0 NEXT i_zahl-tsd+1.
  DO 4 TIMES VARYING i_ziffer FROM i_zahl-tsd(1) NEXT i_zahl-tsd+1(1).
    IF i_ziffer <> 0.
      IF i_ziffer <> 1 OR sy-index = 4 OR i_first = 'X'.
        PERFORM: t015z_lesen USING '0' i_ziffer,
                 schreiben.
      ENDIF.
      CASE sy-index.
        WHEN 1.
          PERFORM: t015z_lesen USING 'T' '=',
                   schreiben.
        WHEN 2.
          PERFORM: t015z_lesen USING 'H' '>',
                   schreiben.
        WHEN 3.
          PERFORM: t015z_lesen USING '1' '0',
                   schreiben.
      ENDCASE.
      CLEAR i_first.
    ENDIF.
  ENDDO.

* Anhängen der Währung, beim koreanischen Won
  IF tcurc-isocd = 'KRW' AND i_zahl > 0.
    PERFORM: t015z_lesen USING 'C' ' ',
             schreiben.
  ENDIF.

ENDFORM.


*----------------------------------------------------------------------*
* Umsetzen des Betrages in Worte für Chinesisch                        *
*----------------------------------------------------------------------*
FORM betrag_in_worten_1m USING char_amount.

  DATA: BEGIN OF i_zahl,               "Zahlengrammatik mit Wörtern für
          cho(3)    TYPE n,            "  -> 1.000.000.000.000 ...
          okk(4)    TYPE n,            "  -> 100.000.000 ...
          man(4)    TYPE n,            "  -> 10.000 ...
          tsd(4)    TYPE n,            "  -> Tausend ...
        END OF i_zahl,
*        i_ziffer(1) TYPE c,
        i_ziffer(1) TYPE n,
        i_first(1)  TYPE c VALUE 'X',
        i_zero_loaded TYPE c.

  i_zahl = char_amount.

* Umwandeln der Stellen xxx.000.000.000.000
*  DO 3 TIMES VARYING i_ziffer FROM i_zahl-cho+0 NEXT i_zahl-cho+1.
  DO 3 TIMES VARYING i_ziffer FROM i_zahl-cho(1) NEXT i_zahl-cho+1(1).
    IF i_ziffer NE 0.

*--   zero should only appear once, even if there are more than '0'
*     in a row. When the next digit <> 0 shows up, the word zero is
*     written down ---
      IF i_zero_loaded = 'X'.
        PERFORM schreiben.
        CLEAR i_zero_loaded.
      ENDIF.

      PERFORM: t015z_lesen USING '0' i_ziffer,
                 schreiben.

      CASE sy-index.
        WHEN 1.  PERFORM t015z_lesen USING 'H' '>'.
        WHEN 2.  PERFORM t015z_lesen USING '1' '0'.
        WHEN 3.  PERFORM t015z_lesen USING 'K' '>'.
      ENDCASE.
      PERFORM schreiben.
      CLEAR i_first.
    ELSE.
      IF i_first       IS INITIAL AND
         i_zero_loaded IS INITIAL.
        PERFORM t015z_lesen USING '0' '0'.
*--     don't write the zero down yet, but wait, if there is a digit
*       <> zero behind it ---
        i_zero_loaded = 'X'.
      ENDIF.
    ENDIF.
  ENDDO.

*-- the billion-block is finished, but the unit billion may have not
*   been written down because there was zero-digit(s) at its end --
  IF i_zero_loaded = 'X'.
    PERFORM t015z_lesen USING 'K' '>'.
    PERFORM schreiben.
    CLEAR i_zero_loaded.
  ENDIF.

* Umwandeln der Stellen 000.xxx.x00.000.000
*  DO 4 TIMES VARYING i_ziffer FROM i_zahl-okk+0 NEXT i_zahl-okk+1.
  DO 4 TIMES VARYING i_ziffer FROM i_zahl-okk(1) NEXT i_zahl-okk+1(1).
    IF i_ziffer NE 0.

*--   zero should only appear once, even if there are more than '0'
*     in a row. When the next digit <> 0 shows up, the word zero is
*     written down ---
      IF i_zero_loaded = 'X'.
        PERFORM schreiben.
        CLEAR i_zero_loaded.
      ENDIF.

      PERFORM: t015z_lesen USING '0' i_ziffer,
                 schreiben.

      CASE sy-index.
        WHEN 1.  PERFORM t015z_lesen USING 'T' '='.
        WHEN 2.  PERFORM t015z_lesen USING 'H' '>'.
        WHEN 3.  PERFORM t015z_lesen USING '1' '0'.
        WHEN 4.  PERFORM t015z_lesen USING 'M' '>'.
      ENDCASE.
      PERFORM schreiben.
      CLEAR i_first.
    ELSE.
      IF i_first       IS INITIAL AND
         i_zero_loaded IS INITIAL.
        PERFORM t015z_lesen USING '0' '0'.
*--     don't write the zero down yet, but wait, if there is a digit
*       <> zero behind it ---
        i_zero_loaded = 'X'.
      ENDIF.
    ENDIF.
  ENDDO.

*-- the 100-Million-block is finished, but the unit billion may have not
*   been written down because there was zero-digit(s) at its end --
  IF i_zero_loaded = 'X' AND NOT i_zahl-okk IS INITIAL.
    PERFORM t015z_lesen USING 'M' '>'.
    PERFORM schreiben.
    CLEAR i_zero_loaded.
  ENDIF.

* Umwandeln der Stellen 000.000.0xx.xx0.000
*  DO 4 TIMES VARYING i_ziffer FROM i_zahl-man+0 NEXT i_zahl-man+1.
  DO 4 TIMES VARYING i_ziffer FROM i_zahl-man(1) NEXT i_zahl-man+1(1).
    IF i_ziffer NE 0.

*--   zero should only appear once, even if there are more than '0'
*     in a row. When the next digit <> 0 shows up, the word zero is
*     written down ---
      IF i_zero_loaded = 'X'.
        PERFORM schreiben.
        CLEAR i_zero_loaded.
      ENDIF.

      PERFORM: t015z_lesen USING '0' i_ziffer,
                 schreiben.

      CASE sy-index.
        WHEN 1.  PERFORM t015z_lesen USING 'T' '='.
        WHEN 2.  PERFORM t015z_lesen USING 'H' '>'.
        WHEN 3.  PERFORM t015z_lesen USING '1' '0'.
        WHEN 4.  PERFORM t015z_lesen USING 'T' '>'.
      ENDCASE.
      PERFORM schreiben.
      CLEAR i_first.
    ELSE.
      IF i_first       IS INITIAL AND
         i_zero_loaded IS INITIAL.
        PERFORM t015z_lesen USING '0' '0'.
*--     don't write the zero down yet, but wait, if there is a digit
*       <> zero behind it ---
        i_zero_loaded = 'X'.
      ENDIF.
    ENDIF.
  ENDDO.

*-- the 10thousend-block is finished, but the unit billion may have not
*   been written down because there was zero-digit(s) at its end --
  IF i_zero_loaded = 'X' AND NOT i_zahl-man IS INITIAL.
    PERFORM t015z_lesen USING 'T' '>'.
    PERFORM schreiben.
    CLEAR i_zero_loaded.
  ENDIF.

* Umwandeln der Stellen 000.000.000.00x.xxx
*  DO 4 TIMES VARYING i_ziffer FROM i_zahl-tsd+0 NEXT i_zahl-tsd+1.
  DO 4 TIMES VARYING i_ziffer FROM i_zahl-tsd(1) NEXT i_zahl-tsd+1(1).
    IF i_ziffer NE 0.

*--   zero should only appear once, even if there are more than '0'
*     in a row. When the next digit <> 0 shows up, the word zero is
*     written down ---
      IF i_zero_loaded = 'X'.
        PERFORM schreiben.
        CLEAR i_zero_loaded.
      ENDIF.

      PERFORM: t015z_lesen USING '0' i_ziffer,
                 schreiben.

      CASE sy-index.
        WHEN 1.
          PERFORM: t015z_lesen USING 'T' '=',
                   schreiben.
        WHEN 2.
          PERFORM: t015z_lesen USING 'H' '>',
                   schreiben.
        WHEN 3.
          PERFORM: t015z_lesen USING '1' '0',
                   schreiben.
      ENDCASE.
      CLEAR i_first.

    ELSE.
      IF i_first       IS INITIAL AND
         i_zero_loaded IS INITIAL.
        PERFORM t015z_lesen USING '0' '0'.
*--     don't write the zero down yet, but wait, if there is a digit
*       <> zero behind it ---
        i_zero_loaded = 'X'.
      ENDIF.
    ENDIF.
  ENDDO.

ENDFORM.


*----------------------------------------------------------------------*
* Umsetzen des Betrages in Worte für Thai                              *
*----------------------------------------------------------------------*
FORM betrag_in_worten_2.

* xxx,000,000,000,000
  IF int_zahl-bio NE 0.
    PERFORM hundert_umsetzen USING 'H' int_zahl-bio.
    PERFORM t015z_lesen USING 'M' '>'.
    PERFORM schreiben.
    IF int_zahl+3 EQ 0.
      PERFORM schreiben.
    ENDIF.
  ENDIF.

* 000,xxx,000,000,000
  PERFORM tausend_umsetzen_thai USING int_zahl-mia.

* 000,000,xxx,000,000
  IF int_zahl-mio NE 0.
    PERFORM hundert_umsetzen USING 'Y' int_zahl-mio.
  ENDIF.
  IF int_zahl+3(6) NE 0.
    PERFORM t015z_lesen USING 'M' '>'.
    PERFORM schreiben.
  ENDIF.

* 000,000,000,xxx,000
  PERFORM tausend_umsetzen_thai USING int_zahl-tsd.

* 000,000,000,000,xxx
  IF int_zahl-hun <> 0.
    PERFORM hundert_umsetzen USING 'H' int_zahl-hun.
  ENDIF.

ENDFORM.


*----------------------------------------------------------------------*
* Umsetzen des Betrages in Worte für restliche Sprachen                *
*----------------------------------------------------------------------*
FORM betrag_in_worten_rest.

* xxx,000,000,000,000
  IF int_zahl-bio <> 0.
    IF int_zahl-bio = 1 AND
       int_language NE 'I'.
      PERFORM t015z_lesen USING 'K' '1'.
    ELSEIF int_language NE 'I'.
      PERFORM hundert_umsetzen USING 'Y' int_zahl-bio.
      IF int_language NA 'R8C' AND
         NOT ( int_language EQ 'Q' AND int_zahl-bio LE 4 ).
        PERFORM t015z_lesen USING 'K' '>'.
      ELSE.
        PERFORM t015z_lesen_r USING 'K' int_zahl-bio.
      ENDIF.
    ELSE.
      IF int_zahl-bio = 1.
        PERFORM t015z_lesen USING 'T' '1'.
      ELSE.
        PERFORM hundert_umsetzen USING 'T' int_zahl-bio.
        PERFORM t015z_lesen USING 'T' '>'.
      ENDIF.
      IF int_zahl-mia EQ 0.
        PERFORM schreiben.
        PERFORM t015z_lesen USING 'L' '>'.
      ENDIF.
    ENDIF.
    PERFORM schreiben.
  ENDIF.

* 000,xxx,000,000,000
  IF int_zahl-mia NE 0.
    PERFORM verbinden USING 4.
    IF int_zahl-mia EQ 1.
      PERFORM t015z_lesen USING 'L' '1'.
    ELSE.
      IF NOT int_language EQ 'C' AND
         NOT ( int_language EQ 'Q' AND int_zahl-mia LE 2 ).
        PERFORM hundert_umsetzen USING 'Y' int_zahl-mia.
      ELSE.
        PERFORM hundert_umsetzen USING 'L' int_zahl-mia.
      ENDIF.
      IF int_language NA 'R8CL' AND
         NOT ( int_language EQ 'Q' AND int_zahl-mia LE 4 ).
        PERFORM t015z_lesen USING 'L' '>'.
      ELSE.
        PERFORM t015z_lesen_r USING 'L' int_zahl-mia.
      ENDIF.
    ENDIF.
    PERFORM schreiben.
  ENDIF.

* 000,000,xxx,000,000
  IF int_zahl-mio NE 0.
    PERFORM verbinden USING 3.
    IF int_zahl-mio EQ 1.
      PERFORM t015z_lesen USING 'M' '1'.
    ELSE.
      PERFORM hundert_umsetzen USING 'Y' int_zahl-mio.
      IF int_language NA 'R8CL' AND
         NOT ( int_language EQ 'Q' AND int_zahl-mio LE 4 ).
        PERFORM t015z_lesen USING 'M' '>'.
      ELSE.
        PERFORM t015z_lesen_r USING 'M' int_zahl-mio.
      ENDIF.
    ENDIF.
    PERFORM schreiben.
  ELSE.
    IF int_language EQ 'S'.
      IF int_zahl-mia NE 0.
        PERFORM t015z_lesen USING 'M' '>'.
        PERFORM schreiben.
      ENDIF.
    ENDIF.
  ENDIF.

* 000,000,000,xxx,000
  IF int_zahl-tsd NE 0.
    PERFORM verbinden USING 2.
    IF int_zahl-tsd EQ 1.
      PERFORM t015z_lesen USING 'T' '1'.
    ELSE.
      PERFORM hundert_umsetzen USING 'T' int_zahl-tsd.
      IF int_language NA 'R8CL' AND
         NOT ( int_language EQ 'Q' AND int_zahl-mia LE 4 ).
        PERFORM t015z_lesen USING 'T' '>'.
      ELSE.
        PERFORM t015z_lesen_r USING 'T' int_zahl-tsd.
      ENDIF.
    ENDIF.
    PERFORM schreiben.
  ENDIF.

* 000,000,000,000,xxx
  IF int_zahl-hun <> 0.
    PERFORM verbinden USING 1.
    PERFORM hundert_umsetzen USING 'H' int_zahl-hun.
  ENDIF.

ENDFORM.


*---------------------------------------------------------------------*
*       FORM dezimal_in_worte_r                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IMP_DECIMAL                                                   *
*  -->  IMP_CURRDEC                                                   *
*---------------------------------------------------------------------*
FORM dezimal_in_worte_r USING imp_decimal
                              imp_currdec.

* Deklaration interner Variablen
  DATA: i_decword(9)  TYPE c,
        i_numword(25) TYPE c,
        i_digit       TYPE c,
        i_len         TYPE i,
        i_off         TYPE i,
        i_decimal(9)  TYPE n.

* Lesen der Importparameter
  i_len     = imp_currdec.
  i_decimal = imp_decimal.

* Auslesend der Dezimalstellen des Betrages
  i_off     = strlen( i_decimal ) - i_len.
  MOVE i_decimal+i_off(i_len) TO i_decword.
  i_off     = i_off + 1.
  MOVE i_decimal+i_off(1) TO i_digit.

* Ausgabe des Nachkommabetrages und KOPEJEK
  IF i_decimal = 0.
    PERFORM t015z_lesen USING 'N' '5'.

* Ausgabe des Nachkommabetrages und KOPEKA
  ELSEIF i_digit = '1' AND
     i_decimal <> 11.
    PERFORM t015z_lesen USING 'N' '1'.

* Ausgabe des Nachkommabetrages und KOPEKI
  ELSEIF i_decimal < 5 OR
         i_decimal > 20 AND
         i_digit = '2' OR
         i_digit = '3' OR
         i_digit = '4'.
    PERFORM t015z_lesen USING 'N' '2'.

* Ausgabe des Nachkommabetrages und KOPEJEK
  ELSE.
    PERFORM t015z_lesen USING 'N' '5'.
  ENDIF.

* Ausgabe des Wortes für den Dezimalbetrag in die Struktur SPELL
  i_numword = t015z-wort.
  i_off     = strlen( i_numword ).
*  DO i_off TIMES VARYING i_digit FROM i_numword+0 NEXT i_numword+1.
  DO i_off TIMES VARYING i_digit FROM i_numword(1) NEXT i_numword+1(1) RANGE i_numword.
    IF i_digit = ';'.
      i_len = sy-index - 1.
      EXIT.
    ENDIF.
  ENDDO.
  MOVE i_numword+0(i_len) TO i_numword.
  SET LOCALE LANGUAGE int_language.
  TRANSLATE i_numword TO LOWER CASE.
  SET LOCALE LANGUAGE space.
  CONCATENATE i_decword i_numword
              INTO spell-decword
              SEPARATED BY space.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  betrag_in_worten_j
*&---------------------------------------------------------------------*
FORM betrag_in_worten_j
       USING
         char_amount.

  DATA: BEGIN OF i_zahl,               "Zahlengrammatik mit Wörtern für
          cho(3) TYPE n,               "  -> 1.000.000.000.000 ...
          okk(4) TYPE n,               "  -> 100.000.000 ...
          man(4) TYPE n,               "  -> 10.000 ...
          tsd(4) TYPE n,               "  -> Tausend ...
        END OF i_zahl,
*        i_ziffer(1) TYPE c.
        i_ziffer(1) TYPE n.

  i_zahl = char_amount.

* Umwandeln der Stellen xxx.000.000.000.000
*  DO 3 TIMES VARYING i_ziffer FROM i_zahl-cho+0 NEXT i_zahl-cho+1.
  DO 3 TIMES VARYING i_ziffer FROM i_zahl-cho(1) NEXT i_zahl-cho+1(1).
    IF i_ziffer <> 0.
      IF i_ziffer <> 1 OR sy-index = 3.
        PERFORM: t015z_lesen USING '0' i_ziffer,
                 schreiben.
      ENDIF.
      CASE sy-index.
        WHEN 1.  PERFORM t015z_lesen USING 'H' '>'.
        WHEN 2.  PERFORM t015z_lesen USING '1' '0'.
        WHEN 3.  PERFORM t015z_lesen USING 'K' '>'.
      ENDCASE.
      PERFORM schreiben.
    ELSEIF sy-index = 3 AND i_zahl-cho > 0.
      PERFORM: t015z_lesen USING 'K' '>',
               schreiben.
    ENDIF.
  ENDDO.

* Umwandeln der Stellen 000.xxx.x00.000.000
*  DO 4 TIMES VARYING i_ziffer FROM i_zahl-okk+0 NEXT i_zahl-okk+1.
  DO 4 TIMES VARYING i_ziffer FROM i_zahl-okk(1) NEXT i_zahl-okk+1(1).
    IF i_ziffer <> 0.
      IF i_ziffer <> 1 OR sy-index = 1 OR sy-index = 4.
        PERFORM: t015z_lesen USING '0' i_ziffer,
                 schreiben.
      ENDIF.
      CASE sy-index.
        WHEN 1.  PERFORM t015z_lesen USING 'T' '='.
        WHEN 2.  PERFORM t015z_lesen USING 'H' '>'.
        WHEN 3.  PERFORM t015z_lesen USING '1' '0'.
        WHEN 4.  PERFORM t015z_lesen USING 'M' '>'.
      ENDCASE.
      PERFORM schreiben.
    ELSEIF sy-index = 4 AND i_zahl-okk > 0.
      PERFORM: t015z_lesen USING 'M' '>',
               schreiben.
    ENDIF.
  ENDDO.

* Umwandeln der Stellen 000.000.0xx.xx0.000
*  DO 4 TIMES VARYING i_ziffer FROM i_zahl-man+0 NEXT i_zahl-man+1.
  DO 4 TIMES VARYING i_ziffer FROM i_zahl-man(1) NEXT i_zahl-man+1(1).
    IF i_ziffer <> 0.
      IF i_ziffer <> 1 OR sy-index = 1 OR sy-index = 4.
        PERFORM: t015z_lesen USING '0' i_ziffer,
                 schreiben.
      ENDIF.
      CASE sy-index.
        WHEN 1.  PERFORM t015z_lesen USING 'T' '='.
        WHEN 2.  PERFORM t015z_lesen USING 'H' '>'.
        WHEN 3.  PERFORM t015z_lesen USING '1' '0'.
        WHEN 4.  PERFORM t015z_lesen USING 'T' '>'.
      ENDCASE.
      PERFORM schreiben.
    ELSEIF sy-index = 4 AND i_zahl-man > 0.
      PERFORM: t015z_lesen USING 'T' '>',
               schreiben.
    ENDIF.
  ENDDO.

* Umwandeln der Stellen 000.000.000.00x.xxx
*  DO 4 TIMES VARYING i_ziffer FROM i_zahl-tsd+0 NEXT i_zahl-tsd+1.
  DO 4 TIMES VARYING i_ziffer FROM i_zahl-tsd(1) NEXT i_zahl-tsd+1(1).
    IF i_ziffer <> 0.
      IF i_ziffer <> 1 OR sy-index = 1 OR sy-index = 4.
        PERFORM: t015z_lesen USING '0' i_ziffer,
                 schreiben.
      ENDIF.

      CASE sy-index.
        WHEN 1.
          PERFORM: t015z_lesen USING 'T' '=',
                   schreiben.
        WHEN 2.
          PERFORM: t015z_lesen USING 'H' '>',
                   schreiben.
        WHEN 3.
          PERFORM: t015z_lesen USING '1' '0',
                   schreiben.
      ENDCASE.
    ENDIF.
  ENDDO.

ENDFORM.                               " betrag_in_worten_j
