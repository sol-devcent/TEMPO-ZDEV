FUNCTION ZQDRS_FIXED_SAMPLE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_NACHKOMMA) LIKE  QDWL-KZJANEIN
*"     VALUE(I_QALS_LOSMENGE) LIKE  QALS-LOSMENGE
*"     VALUE(I_QALS_MENGENEINH) LIKE  QALS-MENGENEINH
*"     VALUE(I_QASV_FAKPLANME) LIKE  QASV-FAKPLANME
*"     VALUE(I_QASV_FAKPROBME) LIKE  QASV-FAKPROBME
*"     VALUE(I_QASV_PROBEMGEH) LIKE  QASV-PROBEMGEH
*"     VALUE(I_QASV_PROBMGFAK) LIKE  QASV-PROBMGFAK
*"     VALUE(I_QDQL_DYNREGEL) LIKE  QDQL-DYNREGEL DEFAULT SPACE
*"     VALUE(I_QDQL_PRSTUFENAE) LIKE  QDQL-PRSTUFENAE DEFAULT '0000'
*"     VALUE(I_QDSV_ANNAHMEZ) LIKE  QDSV-ANNAHMEZ DEFAULT 0
*"     VALUE(I_QDSV_AQLWERT) LIKE  QDSV-AQLWERT DEFAULT '0.000'
*"     VALUE(I_QDSV_KFAKTOR) LIKE  QDSV-KFAKTOR DEFAULT '0.0'
*"     VALUE(I_QDSV_KFAKTORNI) LIKE  QDSV-KFAKTORNI DEFAULT SPACE
*"     VALUE(I_QDSV_KZOHI) LIKE  QDSV-KZOHI DEFAULT SPACE
*"     VALUE(I_QDSV_KZUMFS) LIKE  QDSV-KZUMFS DEFAULT SPACE
*"     VALUE(I_QDSV_PROZAZL) LIKE  QDSV-PROZAZL DEFAULT '0.0'
*"     VALUE(I_QDSV_PROZAZLNI) LIKE  QDSV-PROZAZLNI DEFAULT SPACE
*"     VALUE(I_QDSV_PROZUMF) LIKE  QDSV-PROZUMF DEFAULT '0.0'
*"     VALUE(I_QDSV_PROZUMFNI) LIKE  QDSV-PROZUMFNI DEFAULT SPACE
*"     VALUE(I_QDSV_PRSCHAERFE) LIKE  QDSV-PRSCHAERFE DEFAULT '000'
*"     VALUE(I_QDSV_STPRANZ) LIKE  QDSV-STPRANZ DEFAULT 0
*"     VALUE(I_QDSV_STPRPLAN) LIKE  QDSV-STPRPLAN DEFAULT SPACE
*"     VALUE(I_QDSV_STPRUMF) LIKE  QDSV-STPRUMF DEFAULT 0
*"     VALUE(I_QDSV_KZRAST) LIKE  QDSV-KZRAST DEFAULT SPACE
*"     VALUE(I_QDSV_KZNOCUT) LIKE  QDSV-KZNOCUT DEFAULT SPACE
*"  EXPORTING
*"     VALUE(E_ANNAHMEZ) LIKE  QASV-ANNAHMEZ
*"     VALUE(E_BEWREGEL) LIKE  QASV-BEWREGEL
*"     VALUE(E_KFAKTOR) LIKE  QASV-KFAKTOR
*"     VALUE(E_KFAKTORNI) LIKE  QASV-KFAKTORNI
*"     VALUE(E_KZHPZ) LIKE  QAMV-HPZ
*"     VALUE(E_QAMV_PRUEFUMF) LIKE  QAMV-PRUEFUMF
*"     VALUE(E_QASV_PRUEFUMF) LIKE  QASV-PRUEFUMF
*"     VALUE(E_PRSCHAERFE) LIKE  QASV-PRSCHAERFE
*"     VALUE(E_RUECKWEZ) LIKE  QASV-RUECKWEZ
*"     VALUE(E_SATZSTATUS) LIKE  QAMV-SATZSTATUS
*"     VALUE(E_SOLLSTPANZ) LIKE  QAMV-SOLLSTPANZ
*"     VALUE(E_SOLLSTPUMF) LIKE  QAMV-SOLLSTPUMF
*"     VALUE(E_STIPROUMF) LIKE  QASV-STIPROUMF
*"  EXCEPTIONS
*"      OTHER_ERROR
*"      SYSTEM_ERROR
*"      USER_ERROR
*"----------------------------------------------------------------------

* Initialisierungen.
  CLEAR G_PRSCHAERFE.
  CLEAR G_KZSKIP.

  FIELD-SYMBOLS: <fs_anzgeb> TYPE qals-anzgeb.
  ASSIGN ('(SAPLQPL1)QALS-ANZGEB') TO <fs_anzgeb>.

*-----------------------------------------------------------
* Dragon Glory Project
* RICEF ID: EQM-03
* Desription: Dibutuhkan adanya perhitungan sample dengan formula
* Vn + 1 dari number of container, namun tidak menggunakan sample drawing
* procedure karena user required untuk input result recording dengan
* summarize recording (tidak input per satu physical sample)
* Copied from QDRS_FIXED_SAMPLE and modified

* Modification:

  IF <fs_anzgeb> = 1.
    I_QDSV_STPRUMF = 1.
  ELSEIF <fs_anzgeb> = 2.
    I_QDSV_STPRUMF = 2.
  ELSE.
    I_QDSV_STPRUMF = CEIL( SQRT( <fs_anzgeb> ) ) + 1.
  ENDIF.

*-----------------------------------------------------------

* Dynamisierungsregel vorhanden und Stufenwechsel erlaubt.
  IF NOT I_QDQL_DYNREGEL IS INITIAL
    AND  I_QDSV_KZOHI    EQ SPACE.
*   Pruefschaerfe oder Skip?
    PERFORM PRUEFSCHAERFE_LESEN USING I_QDQL_DYNREGEL
                                      I_QDQL_PRSTUFENAE.
*   Bei Skip Satzstatus 4.
    IF G_KZSKIP EQ C_KREUZ.
      E_SATZSTATUS = C_C_4.
    ENDIF.
  ENDIF.

* Berechnung der Stichprobenparameter:
* ------------------------------------
* Die Berechnung erfolgt auch bei Skip,
* falls doch geprueft werden soll.

* S T I C H P R O B E N U M F A N G
* ---------------------------------

* Der Stichprobenumfang darf bei unabh. Mehrfachstichproben und
* Stichprobenanzahl > 1 oder bei Prüfpunkten den Wert 19999 nicht
* übersteigen. Falls doch, wird der Stichprobenumfang auf den maximal
* möglichen Wert (19999) korrigiert.
  PERFORM CH_STPRUMF_MAX USING    I_QDSV_STPRANZ
                                  I_QDSV_KZRAST
                         CHANGING I_QDSV_STPRUMF.

* Normalfall
* Stichprobenumfang (QASVTAB-STIPROUMF).
  E_STIPROUMF = I_QDSV_STPRUMF.


* S T I C H P R O B E N A N Z A H L  und
* G E S A M T S T I C H P R O B E N U M F A N G (QAMVTAB-SOLLSTPUMF).
* -------------------------------------------------------------------
* in Abhängigkeit von der Ausprägung des KZRAST:
* SPACE -> keine Prüfpunkte
* 'X'   -> freie Prüfpunkte in der Fertigung
* '1'   -> Anzahl Prüfpunkte nach Losmenge
* '2'   -> Anzahl Prüfpunkte nach Probenahmeverfahren

* keine Prüfpunkte
  IF I_QDSV_KZRAST EQ SPACE.
*    Einfachproben.
    IF I_QDSV_KZUMFS EQ SPACE.
*      Die Stichprobenanzahl erhaelt den Wert 1.
      E_SOLLSTPANZ = C_I_1.
      E_SOLLSTPUMF = I_QDSV_STPRUMF.
*    Mehrfachproben.
    ELSE.
      E_SOLLSTPANZ = I_QDSV_STPRANZ.
      E_SOLLSTPUMF = I_QDSV_STPRANZ * E_STIPROUMF.
    ENDIF.
  ENDIF.

* Freie Prüfpunkte in der Fertigung
  IF I_QDSV_KZRAST EQ C_FE.
*    Die Stichprobenanzahl erhaelt den Wert 1.
    E_SOLLSTPANZ = C_I_1.
    E_SOLLSTPUMF = I_QDSV_STPRUMF.
  ENDIF.

* Prüfpunkte nach Losmenge (z.B. alle PM-Wartungsauftragsobjekte)
  IF I_QDSV_KZRAST EQ C_PM.
*    Die Stichprobenanzahl erhaelt den Wert gemäß der Losmenge.
    E_SOLLSTPANZ = I_QALS_LOSMENGE.
    E_SOLLSTPUMF = E_SOLLSTPANZ * I_QDSV_STPRUMF.
  ENDIF.

* Prüfpunkte nach Probenahmeverfahren =>
* die Anzahl der zu entnehmenden Proben wird erst später ermittelt
  IF I_QDSV_KZRAST EQ C_PROB.
*    Die Stichprobenanzahl erhaelt den Wert 1.
    E_SOLLSTPANZ = C_I_1.
    E_SOLLSTPUMF = I_QDSV_STPRUMF.
  ENDIF.


* P R U E F U M F A N G   (QAMV, QASV)
* (zu pruefende Menge in Basismengeneinheit) berechnen.
* -----------------------------------------------------------------
  PERFORM PRUEFUMF_BERECHNEN USING    E_STIPROUMF
                                      E_SOLLSTPANZ
                                      I_QASV_FAKPLANME
                                      I_QASV_FAKPROBME
                                      I_QASV_PROBMGFAK
                                      I_QDSV_KZRAST
                             CHANGING E_QAMV_PRUEFUMF
                                      E_QASV_PRUEFUMF.


* S O N D E R F A E L L E

*    Einfachproben.
  IF I_QDSV_KZUMFS EQ SPACE.
*      Sonderfall A:
*      Pruefumfang groesser Losmenge.
    PERFORM SONDERFALL_A_PRUEFEN USING    I_QALS_LOSMENGE
                                          I_NACHKOMMA
                                          I_QASV_FAKPLANME
                                          I_QASV_FAKPROBME
                                          I_QASV_PROBMGFAK
                                          I_QDSV_KZRAST
                                          I_QDSV_KZNOCUT
                                 CHANGING E_SOLLSTPUMF
                                          E_STIPROUMF
                                          E_BEWREGEL
                                          E_KZHPZ
                                          E_QAMV_PRUEFUMF
                                          E_QASV_PRUEFUMF.

*    Mehrfachproben.
  ELSE.
*      Sonderfall B:
*      Pruefumfang einer Probe kleiner Losmenge, aber Gesamtpruefumfang
*      groesser Losmenge.
    PERFORM SONDERFALL_B_PRUEFEN USING    I_QALS_LOSMENGE
                                          I_NACHKOMMA
                                          I_QASV_FAKPLANME
                                          I_QASV_FAKPROBME
                                          I_QASV_PROBMGFAK
                                          I_QDSV_KZRAST
                                          I_QDSV_KZNOCUT
                                 CHANGING E_SOLLSTPUMF
                                          E_STIPROUMF
                                          E_SOLLSTPANZ
                                          E_QAMV_PRUEFUMF
                                          E_QASV_PRUEFUMF.

*      Sonderfall C:
*      Pruefumfang einer Probe groesser als die Losmenge.
    PERFORM SONDERFALL_C_PRUEFEN USING    I_QALS_LOSMENGE
                                          I_NACHKOMMA
                                          I_QASV_FAKPLANME
                                          I_QASV_FAKPROBME
                                          I_QASV_PROBMGFAK
                                          I_QDSV_KZRAST
                                          I_QDSV_KZNOCUT
                                 CHANGING E_SOLLSTPUMF
                                          E_STIPROUMF
                                          E_SOLLSTPANZ
                                          E_BEWREGEL
                                          E_KZHPZ
                                          E_QAMV_PRUEFUMF
                                          E_QASV_PRUEFUMF.

  ENDIF.

* Annahme- / Rueckweisebedingungen
* --------------------------------
* Bei Sonderfaellen mit 100%-Pruefung nicht relevant.
  IF E_KZHPZ EQ SPACE.
*   A t t r i b u t p r u e f u n g  (k-Faktor initial)
    IF I_QDSV_KFAKTORNI EQ SPACE.
*     Annahmezahl
      E_ANNAHMEZ = I_QDSV_ANNAHMEZ.
*     Rueckweisezahl = Annahmezahl + 1
      E_RUECKWEZ = I_QDSV_ANNAHMEZ + C_I_1.
*   V a r i a b l e n p r u e f u n g  (k-Faktor nicht initial)
    ELSE.
*     K-Faktor
      E_KFAKTOR   = I_QDSV_KFAKTOR.
      E_KFAKTORNI = I_QDSV_KFAKTORNI.
    ENDIF.
  ELSE.
* Annahmezahl wird auf 0 und Ruechweisezahl auf 1 gesetzt,
* damit ggf. automatisch bewertet werden kann (attributiv nach
* fehlerhaften Einheiten).
    E_ANNAHMEZ = C_I_0.
    E_RUECKWEZ = C_I_1.
  ENDIF.

ENDFUNCTION.
