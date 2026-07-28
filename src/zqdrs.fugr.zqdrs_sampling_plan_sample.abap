FUNCTION ZQDRS_SAMPLING_PLAN_SAMPLE.
*"----------------------------------------------------------------------
*"*"Global Interface:
*"  IMPORTING
*"     VALUE(I_NACHKOMMA) LIKE  QDWL-KZJANEIN
*"     VALUE(I_QALS_ANZGEB) LIKE  QALS-LOSMENGE
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

  DATA:
  L_STPRANZ   LIKE QDPA-STPRANZ.

* Initialisierungen.
  CLEAR G_PRSCHAERFE.
  CLEAR G_KZSKIP.

* Dynamisierungsregel vorhanden und Stufenwechsel erlaubt.
  IF NOT I_QDQL_DYNREGEL IS INITIAL
    AND  I_QDSV_KZOHI    EQ SPACE.
*   Pruefschaerfe oder Skip?
    PERFORM PRUEFSCHAERFE_LESEN USING I_QDQL_DYNREGEL
                                      I_QDQL_PRSTUFENAE.
*   Bei Skip Satzstatus 4.
    IF G_KZSKIP EQ C_KREUZ.
      E_SATZSTATUS = C_C_4.
*     Falls doch geprueft wird.
      G_PRSCHAERFE = I_QDSV_PRSCHAERFE.
    ENDIF.
* Keine Dynamisierungsregel bzw.Stufenwechsel nicht erlaubt
* -> Pruefschaerfe aus dem Verfahren nehmen.
  ELSE.
    G_PRSCHAERFE = I_QDSV_PRSCHAERFE.
  ENDIF.

* Berechnung der Stichprobenparameter:
* ------------------------------------
* Die Berechnung erfolgt auch bei Skip,
* falls doch geprueft werden soll.

* N O R M A L F A L L
* Stichprobenanweisung aus dem Stichprobenplan lesen.
  CALL FUNCTION 'QDRS_SAMPLING_PLAN_READ'
       EXPORTING
*            I_LOSMENGE    = I_QALS_LOSMENGE
            I_LOSMENGE    = I_QALS_ANZGEB
            I_STPRPLAN    = I_QDSV_STPRPLAN
            I_FAKPLANME   = I_QASV_FAKPLANME
            I_FAKPROBME   = I_QASV_FAKPROBME
            I_PROBMGFAK   = I_QASV_PROBMGFAK
            I_PRSCHAERFE  = G_PRSCHAERFE
            I_AQLWERT     = I_QDSV_AQLWERT
       IMPORTING
            E_STIPROUMF   = E_STIPROUMF
            E_ANNAHMEZ    = E_ANNAHMEZ
            E_RUECKWEZ    = E_RUECKWEZ
            E_KFAKTOR     = E_KFAKTOR
            E_KFAKTORNI   = E_KFAKTORNI
            E_STPRANZ     = L_STPRANZ
       EXCEPTIONS
            ERROR_MESSAGE = 1.

  IF SY-SUBRC NE 0.
    IF G_PRSCHAERFE EQ I_QDSV_PRSCHAERFE.
*     Fehlermeldung ausgeben
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

    ELSE.
*     nochmals mit der Default-Prüfschärfe des Stichprobenverfahrens
*     lesen;
*     Errormessage wird nicht abgefangen, sondern innerhalb des FB
*     ausgegeben
      CALL FUNCTION 'QDRS_SAMPLING_PLAN_READ'
           EXPORTING
*                I_LOSMENGE   = I_QALS_LOSMENGE
                I_LOSMENGE    = I_QALS_ANZGEB
                I_STPRPLAN   = I_QDSV_STPRPLAN
                I_FAKPLANME  = I_QASV_FAKPLANME
                I_FAKPROBME  = I_QASV_FAKPROBME
                I_PROBMGFAK  = I_QASV_PROBMGFAK
                I_PRSCHAERFE = I_QDSV_PRSCHAERFE
                I_AQLWERT    = I_QDSV_AQLWERT
           IMPORTING
                E_STIPROUMF  = E_STIPROUMF
                E_ANNAHMEZ   = E_ANNAHMEZ
                E_RUECKWEZ   = E_RUECKWEZ
                E_KFAKTOR    = E_KFAKTOR
                E_KFAKTORNI  = E_KFAKTORNI
                E_STPRANZ    = L_STPRANZ.

*     neue QASV Prüfschärfe zurückgeben
      MOVE I_QDSV_PRSCHAERFE TO E_PRSCHAERFE.
    ENDIF.
  ENDIF.


* Der Stichprobenumfang darf bei unabh. Mehrfachstichproben und
* Stichprobenanzahl > 1 oder bei Prüfpunkten den Wert 19999 nicht
* übersteigen. Falls doch, wird der Stichprobenumfang auf den maximal
* möglichen Wert (19999) korrigiert.
  PERFORM CH_STPRUMF_MAX USING    I_QDSV_STPRANZ
                                  I_QDSV_KZRAST
                         CHANGING E_STIPROUMF.

* Stichprobenanzahl und Gesamtstichprobenumfang (QAMVTAB-SOLLSTPUMF).

  CASE I_QDSV_KZUMFS.
* Einfachproben.
    WHEN SPACE.
*     Die Stichprobenanzahl erhaelt den Wert 1.
      E_SOLLSTPANZ = C_I_1.
      E_SOLLSTPUMF = E_STIPROUMF.
*   unabhängige Mehrfachproben
    WHEN C_KREUZ.
      E_SOLLSTPANZ = I_QDSV_STPRANZ.
      E_SOLLSTPUMF = I_QDSV_STPRANZ * E_STIPROUMF.
*   abhängige Mehrfachproben
    WHEN 1.
      E_SOLLSTPANZ = L_STPRANZ.
      E_SOLLSTPUMF = E_STIPROUMF.

  ENDCASE.

* Pruefumfang (zu pruefende Menge in Basismengeneinheit) berechnen.
  PERFORM PRUEFUMF_BERECHNEN USING    E_STIPROUMF
                                      E_SOLLSTPANZ
                                      I_QASV_FAKPLANME
                                      I_QASV_FAKPROBME
                                      I_QASV_PROBMGFAK
                                      I_QDSV_KZRAST
                             CHANGING E_QAMV_PRUEFUMF
                                      E_QASV_PRUEFUMF.

* S O N D E R F A E L L E
  CASE I_QDSV_KZUMFS.
*   Einfachproben.
    WHEN SPACE.
*     Sonderfall A:
*     Pruefumfang groesser Losmenge.
      PERFORM SONDERFALL_A_PRUEFEN
              USING    I_QALS_ANZGEB    "I_QALS_LOSMENGE
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

*   unabhängige Mehrfachproben
    WHEN C_KREUZ.
*     Sonderfall B:
*     Pruefumfang einer Probe kleiner Losmenge, aber Gesamtpruefumfang
*     groesser Losmenge.
      PERFORM SONDERFALL_B_PRUEFEN
              USING    I_QALS_ANZGEB    "I_QALS_LOSMENGE
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

*     Sonderfall C:
*     Pruefumfang einer Probe groesser als die Losmenge.
      PERFORM SONDERFALL_C_PRUEFEN
              USING    I_QALS_ANZGEB    "I_QALS_LOSMENGE
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

*   abhängige Mehrfachproben
    WHEN 1.
*     Sonderfall B1:
*     Pruefumfang einer Probe kleiner Losmenge, aber Gesamtpruefumfang
*     groesser Losmenge.
      PERFORM SONDERFALL_B1_PRUEFEN
              USING    I_QALS_ANZGEB    "I_QALS_LOSMENGE
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

*     Sonderfall C1:
*     Pruefumfang einer Probe groesser als die Losmenge.
      PERFORM SONDERFALL_C_PRUEFEN
              USING    I_QALS_ANZGEB    "I_QALS_LOSMENGE
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

  ENDCASE.

* Bei Sonderfaellen mit 100%-Pruefung werden die
* Bewertungsparameter initialisiert.
* Annahmezahl wird auf 0 und Ruechweisezahl auf 1 gesetzt,
* damit ggf. automatisch bewertet werden kann (attributiv nach
* fehlerhaften Einheiten).
  IF E_KZHPZ NE SPACE.
    CLEAR E_KFAKTOR.
    CLEAR E_KFAKTORNI.
    E_ANNAHMEZ = C_I_0.
    E_RUECKWEZ = C_I_1.
  ENDIF.
ENDFUNCTION.
