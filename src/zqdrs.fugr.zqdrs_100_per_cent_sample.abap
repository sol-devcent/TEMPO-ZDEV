FUNCTION ZQDRS_100_PER_CENT_SAMPLE.
*"----------------------------------------------------------------------
*"*"Global Interface:
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

* Bei 100%-Pruefung gibt es nur eine Probe.
* Die Bewertungsregel wird NICHT wie sonst bei 100%-Prüfung auf
* A1 gesetzt, sondern bleibt so, wie im Verfahren hinterlegt.
  E_KZHPZ      = C_KREUZ.
  E_SOLLSTPANZ = C_I_1.
* PRUEFUMF entspricht der Losmenge.
  E_QASV_PRUEFUMF = I_QALS_LOSMENGE.
  E_QAMV_PRUEFUMF = I_QALS_LOSMENGE.

* Stichprobenumfang:
* Der Stichprobenumfang wird genauso ermittelt, wie bei der Stichproben-
* art 'Prozentuale Stichprobe' mit 100%.

* Vorbesetzung des Stichprobenprozentsatz mit 1 (100%)
  I_QDSV_PROZUMF = 1.

* Berechnung Stichprobenumfang
  PERFORM STIPROUMF_PROZ_BERECHNEN USING      I_QALS_LOSMENGE
                                              I_QDSV_PROZUMF
                                              I_QASV_FAKPLANME
                                              I_QASV_FAKPROBME
                                              I_QASV_PROBMGFAK
                                     CHANGING E_STIPROUMF.

* Kebutuhkan adanya dasar pengambilan jumlah sample adalah
* dari 100% dari semua No of Container yang ada dan tidak dari
* jumlah Inspection Lot, Juga tidak menggunakan Sampling Drawing
E_STIPROUMF = <fs_anzgeb>.

* Der Stichprobenumfang darf bei unabh. Mehrfachstichproben und
* Stichprobenanzahl > 1 oder bei Prüfpunkten den Wert 19999 nicht
* übersteigen. Falls doch, wird der Stichprobenumfang den maximal
* möglichen Wert (19999) korrigiert.
  PERFORM CH_STPRUMF_MAX USING    I_QDSV_STPRANZ
                                  I_QDSV_KZRAST
                         CHANGING E_STIPROUMF.

* Kebutuhkan adanya dasar pengambilan jumlah sample adalah
* dari 100% dari semua No of Container yang ada dan tidak dari
* jumlah Inspection Lot, Juga tidak menggunakan Sampling Drawing
  E_STIPROUMF = <fs_anzgeb>.

  E_SOLLSTPUMF = E_STIPROUMF.


* Annahmezahl wird auf 0 und Ruechweisezahl auf 1 gesetzt,
* damit ggf. automatisch bewertet werden kann (attributiv nach
* fehlerhaften Einheiten).
  E_ANNAHMEZ = C_I_0.
  E_RUECKWEZ = C_I_1.

ENDFUNCTION.
