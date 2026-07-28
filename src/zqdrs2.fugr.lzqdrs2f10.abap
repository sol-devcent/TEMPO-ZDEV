***INCLUDE LQDRSF10 .
*----------------------------------------------------------------------*
*       FORM ANNAHMEZ_PROZ_BERECHNEN
*----------------------------------------------------------------------*
*       Die Annahmezahl ist ganzzahlig.  /
*       Es wird nur abgerundet: z:B: 5,1 nach 5,
*                                    5,6 nach 5.
*----------------------------------------------------------------------*
*  -->  P_STIPROUMF  Stichprobenumfang
*  -->  P_PROZAZL    Annahmeprozentsatz
*  <--  P_ANNAHMEZ   Annahmezahl(ganzzahlig)
*----------------------------------------------------------------------*
FORM ANNAHMEZ_PROZ_BERECHNEN USING VALUE(P_STIPROUMF)
                                   VALUE(P_PROZAZL)
                             CHANGING    P_ANNAHMEZ.

* P_ANNAHMEZ ist ein Integer-Feld (kaufmaennische Rundung).
* Die Aufloesung ist 1/1000.
  CATCH SYSTEM-EXCEPTIONS CONVERSION_ERRORS = 1
                          ARITHMETIC_ERRORS = 1.
    P_ANNAHMEZ = P_STIPROUMF * P_PROZAZL  - '0.499'.
  ENDCATCH.
  IF SY-SUBRC = 1.
    MESSAGE E003.
  ENDIF.

ENDFORM.
*eject
*----------------------------------------------------------------------*
*       FORM PRUEFSCHAERFE_LESEN
*----------------------------------------------------------------------*
*       Aus der DynamRegel Pruefschaerfe oder Skip-Kz lesen.
*----------------------------------------------------------------------*
*       --> p_dynregel  Dynamisierungsregel
*       --> p_prstufe   Prüfstufe
*----------------------------------------------------------------------*

FORM PRUEFSCHAERFE_LESEN
                        USING VALUE(P_DYNREGEL) LIKE QDDR-DYNREGEL
                              VALUE(P_PRSTUFE)  LIKE QDPS-PRSTUFE.

  CALL FUNCTION 'QDTA_SEVERITY_SKIPFLAG_READ'
       EXPORTING  I_DYNREGEL   = P_DYNREGEL
                  I_PRSTUFE    = P_PRSTUFE
       IMPORTING  E_PRSCHAERFE = G_PRSCHAERFE
                  E_KZSKIP     = G_KZSKIP
       EXCEPTIONS NO_STAGE_FOUND = 1.
* Fehlerbehandlung
  IF SY-SUBRC EQ C_RC_1.
    MESSAGE E703 RAISING SYSTEM_ERROR.
  ENDIF.
ENDFORM.
*eject
*----------------------------------------------------------------------*
*       FORM PRUEFUMF_BERECHNEN
*----------------------------------------------------------------------*
*       Das Feld PRUEFUNMF hat das gleiche Format wie
*       die Losmange.
*       Hier können auch Mengen mit Nachkommastellen abgelegt
*       werden. Die Bezugseinheit ist die Einheit aus dem Los.
*       Die Probemengenfaktoren werden beruecksichtigt.
*----------------------------------------------------------------------*
*  -->  P_STIPROUMF       Stichprobenumfang Probenebene
*  -->  P_SOLLSTPANZ      Stichprobenanzahl Merkmalsebene
*  -->  P_FAKPLANME       Faktor Umrechnung Material-ME in Probe-ME
*  -->  P_FAKPROBME       Faktor Umrechnung Probe-ME in Material-ME
*  -->  P_PROBMGFAK       Vielfaches der Probe-ME
*  <->  P_QAMV_PRUEFUMF   Pruefumfang Merkmalsebene
*  <->  P_QASV_PRUEFUMF   Pruefumfang Probenebene
*----------------------------------------------------------------------*
FORM PRUEFUMF_BERECHNEN USING VALUE(P_STIPROUMF)
                              VALUE(P_SOLLSTPANZ)
                              VALUE(P_FAKPLANME)
                              VALUE(P_FAKPROBME)
                              VALUE(P_PROBMGFAK)
                              VALUE(P_KZRAST)
                        CHANGING    P_QAMV_PRUEFUMF
                                    P_QASV_PRUEFUMF.

* Damit nicht durch null dividiert wird.
  IF P_FAKPLANME IS INITIAL.
    P_FAKPLANME = C_F_1.
  ENDIF.
  IF P_FAKPROBME IS INITIAL.
    P_FAKPROBME = C_F_1.
  ENDIF.
  IF P_PROBMGFAK IS INITIAL.
    P_PROBMGFAK = C_F_1.
  ENDIF.

* Pruefumfang Probenebene berechnen.
  IF P_KZRAST = C_PM.
*    Jede Probe enthält nur eine Auswahleinheit des Loses
     P_QASV_PRUEFUMF =  P_PROBMGFAK
                      * P_FAKPLANME
                      / P_FAKPROBME.
  ELSE.
     P_QASV_PRUEFUMF =    P_STIPROUMF
                        * P_PROBMGFAK
                        * P_FAKPLANME
                        / P_FAKPROBME.
  ENDIF.

* Pruefumfang Merkmalebene berechnen.
  P_QAMV_PRUEFUMF = P_QASV_PRUEFUMF * P_SOLLSTPANZ.

ENDFORM.
*eject
*----------------------------------------------------------------------*
*       FORM SONDERFALL_A_PRUEFEN
*----------------------------------------------------------------------*
*       Sonderfall A:
*       Bei Einfachproben, wenn der Pruefumfang (zu pruefende Menge
*       in Basismengeneinheit) groesser als der Losumfang ist.
*       Folge:
*       Bei Prüfung des Stichprobenumfangs gegen des Losumfang:
*       100%-Pruefung und manuelle Bewertung.
*       Falls keine Prüfung des Stichprobenumfangs gegen die Losmenge:
*       Stichprobenumfang bleibt wie berechnet
*
*       Die Stichprobenanzahl bleibt 1.
*
*----------------------------------------------------------------------*
*  -->  P_LOSMENGE        Losmenge
*  -->  P_NACHKOMMA       Kz. fuer Nachkommastellen
*  -->  P_FAKPLANME       Faktor Umrechnung Material-ME in Probe-ME
*  -->  P_FAKPROBME       Faktor Umrechnung Probe-ME in Material-ME
*  -->  P_PROBMGFAK       Vielfaches der Probe-ME
*  -->  P_KZRAST          mit Prüfpunkten
*  -->  p_KZNOCUT         kein Abschneiden des Stichprobenumfangs
*  <->  P_SOLLSTPUMF      Stichprobenumfang Merkmalsebene
*  <->  P_STIPROUMF       Stichprobenumfang Probenebene
*  <->  P_BEWREGEL        Bewertungsregel
*  <->  P_KZHPZ           Kz. fuer 100%-Pruefung
*  <->  P_QAMV_PRUEFUMF   Pruefumfang Merkmalsebene
*  <->  P_QASV_PRUEFUMF   Pruefumfang Probenebene
*----------------------------------------------------------------------*
FORM SONDERFALL_A_PRUEFEN USING VALUE(P_LOSMENGE)
                                VALUE(P_NACHKOMMA)
                                VALUE(P_FAKPLANME)
                                VALUE(P_FAKPROBME)
                                VALUE(P_PROBMGFAK)
                                VALUE(P_KZRAST)
                                VALUE(P_KZNOCUT)
                          CHANGING    P_SOLLSTPUMF
                                      P_STIPROUMF
                                      P_BEWREGEL
                                      P_KZHPZ
                                      P_QAMV_PRUEFUMF
                                      P_QASV_PRUEFUMF.

CONSTANTS  CL_100_PROZUMF LIKE QDSV-PROZUMF VALUE '1'. "*-- 100 %"

* Pruefumfang groesser als Losumfang.
  CHECK P_QASV_PRUEFUMF GT P_LOSMENGE.

* 100%-Pruefung.
  P_KZHPZ    = C_KREUZ.
  P_BEWREGEL = 'A1'.
* PRUEFUMF entspricht der Losmenge.
  P_QASV_PRUEFUMF = P_LOSMENGE.
  P_QAMV_PRUEFUMF = P_LOSMENGE.

* Abschneiden des Stichprobenumfangs nur, falls gewünscht
  IF P_KZNOCUT EQ SPACE.
*   Der Stichprobenumfang wird genauso ermittelt, wie bei prozentualer
*   Stichprobe mit Stichprobenprozentsatz 100.

*-- Berechnung Stichprobenumfang
    PERFORM STIPROUMF_PROZ_BERECHNEN USING      P_LOSMENGE
                                                CL_100_PROZUMF
                                                P_FAKPLANME
                                                P_FAKPROBME
                                                P_PROBMGFAK
                                       CHANGING P_STIPROUMF.

     P_SOLLSTPUMF = P_STIPROUMF.
  ENDIF.

ENDFORM.
*eject
*----------------------------------------------------------------------*
*       FORM SONDERFALL_B_PRUEFEN
*----------------------------------------------------------------------*
*       Sonderfall B:
*       Bei Mehrfachproben ist der Pruefumfang (zu pruefende
*       Menge in Basismengeneinheit) einer Probe zwar kleiner
*       als der Losumfang, aber der Gesamtpruefumfang aller Proben
*       ist groesser oder gleich.
*       Folge:
*       Es handelt sich nicht um eine 100%-Pruefung!
*       Der Ergebniserfassung wird fuer die einzelne Probe der
*       Stichprobenumfang n aus dem Verfahren uebergeben.
*       Die Stichprobenanzahl wird derart korrigiert, dass mit
*       der letzten Probe der Losumfang erreicht wird.
*       Die letzte Probe erhaelt in der Ergebniserfassung manuelle
*       Bewertung, wenn deren Umfang kleiner dem vorgegebenen
*       Stichprobenumfang ist.
*       Der Gesamtstichprobenumfang (n) deckt den Losumfang ab.
*       Falls keine Prüfung des Stichprobenumfangs gegen die Losmenge:
*       Stichprobenumfang bleibt wie berechnet.
*----------------------------------------------------------------------*
*  -->  P_LOSMENGE        Losmenge
*  -->  P_NACHKOMMA       Kz. fuer Nachkommastellen
*  -->  P_FAKPLANME       Faktor Umrechnung Material-ME in Probe-ME
*  -->  P_FAKPROBME       Faktor Umrechnung Probe-ME in Material-ME
*  -->  P_PROBMGFAK       Vielfaches der Probe-ME
*  -->  P_KZRAST          mit Prüfpunkten
*  -->  p_KZNOCUT         kein Abschneiden des Stichprobenumfangs
*  <->  P_SOLLSTPUMF      Stichprobenumfang Merkmalsebene
*  <->  P_STIPROUMF       Stichprobenumfang Probenebene
*  <->  P_SOLLSTPANZ      Stichprobenanzahl Merkmalsebene
*  <->  P_QAMV_PRUEFUMF   Pruefumfang Merkmalsebene
*  <->  P_QASV_PRUEFUMF   Pruefumfang Probenebene
*----------------------------------------------------------------------*
FORM SONDERFALL_B_PRUEFEN USING VALUE(P_LOSMENGE)
                                VALUE(P_NACHKOMMA)
                                VALUE(P_FAKPLANME)
                                VALUE(P_FAKPROBME)
                                VALUE(P_PROBMGFAK)
                                VALUE(P_KZRAST)
                                VALUE(P_KZNOCUT)
                          CHANGING    P_SOLLSTPUMF
                                      P_STIPROUMF
                                      P_SOLLSTPANZ
                                      P_QAMV_PRUEFUMF
                                      P_QASV_PRUEFUMF.

  CHECK P_QASV_PRUEFUMF LT P_LOSMENGE
    AND P_QAMV_PRUEFUMF GE P_LOSMENGE.

* Initialisierungen.
  CLEAR G_MOD_F.
  CLEAR G_LOSMENGE_F.

* Fuer die nachfolgenden Rechnungen wird QALS-LOSMENGE (Type P)
* in G_LOSMENGE_F (Type F) konvertiert.
* Mit G_LOSMENGE_F wird gerechnet.
  G_LOSMENGE_F = P_LOSMENGE.

* Der Gesamtpruefumfang entspricht der Losmenge.
  P_QAMV_PRUEFUMF = P_LOSMENGE.
* Gesamtstichprobenumfang (n) und Stichprobenanzahl neu ermitteln.
* Stichprobenumfang und Bewertungsregel bleiben unveraendert.
* Fuer diesen Sonderfall ist der nachfolgende Algorithmus unabhaengig
* davon, ob die Bezugseinheit Nachhkommastellen hat oder nicht.

*-- Division durch 0 verhindern
  IF P_FAKPLANME IS INITIAL.
     P_FAKPLANME = C_F_1.
  ENDIF.

* Damit als Stichprobenumfang nicht 0 berechnet wird
  IF P_FAKPROBME IS INITIAL.
     P_FAKPROBME = C_F_1.
  ENDIF.

* Gesamtstichprobenumfang in Probenmengeneinheiten wird aufgerundet
  P_SOLLSTPUMF =  CEIL( ( P_LOSMENGE * P_FAKPROBME ) / P_FAKPLANME ).

* Stichprobenanzahl korrigieren.
  P_SOLLSTPANZ = P_SOLLSTPUMF DIV P_STIPROUMF.
  G_MOD_F      = P_SOLLSTPUMF MOD P_STIPROUMF.
  IF G_MOD_F GT C_F_0.
    ADD C_I_1 TO P_SOLLSTPANZ.
  ENDIF.
ENDFORM.
*eject
*----------------------------------------------------------------------*
*       FORM SONDERFALL_B1_PRUEFEN
*----------------------------------------------------------------------*
*       Sonderfall B1:
*       Wie Sonderfall B
*       Jedoch wird der Gesamtstichprobenumfang nicht angeglichen
*----------------------------------------------------------------------*
*  -->  P_LOSMENGE        Losmenge
*  -->  P_NACHKOMMA       Kz. fuer Nachkommastellen
*  -->  P_FAKPLANME       Faktor Umrechnung Material-ME in Probe-ME
*  -->  P_FAKPROBME       Faktor Umrechnung Probe-ME in Material-ME
*  -->  P_PROBMGFAK       Vielfaches der Probe-ME
*  -->  P_KZRAST          mit Prüfpunkten
*  -->  p_KZNOCUT         kein Abschneiden des Stichprobenumfangs
*  <->  P_SOLLSTPUMF      Stichprobenumfang Merkmalsebene
*  <->  P_STIPROUMF       Stichprobenumfang Probenebene
*  <->  P_SOLLSTPANZ      Stichprobenanzahl Merkmalsebene
*  <->  P_QAMV_PRUEFUMF   Pruefumfang Merkmalsebene
*  <->  P_QASV_PRUEFUMF   Pruefumfang Probenebene
*----------------------------------------------------------------------*
FORM SONDERFALL_B1_PRUEFEN USING VALUE(P_LOSMENGE)
                                VALUE(P_NACHKOMMA)
                                VALUE(P_FAKPLANME)
                                VALUE(P_FAKPROBME)
                                VALUE(P_PROBMGFAK)
                                VALUE(P_KZRAST)
                                VALUE(P_KZNOCUT)
                          CHANGING    P_SOLLSTPUMF
                                      P_STIPROUMF
                                      P_SOLLSTPANZ
                                      P_QAMV_PRUEFUMF
                                      P_QASV_PRUEFUMF.

  CHECK P_QASV_PRUEFUMF LT P_LOSMENGE
    AND P_QAMV_PRUEFUMF GE P_LOSMENGE.

* Initialisierungen.
  CLEAR G_MOD_F.
  CLEAR G_LOSMENGE_F.

* Fuer die nachfolgenden Rechnungen wird QALS-LOSMENGE (Type P)
* in G_LOSMENGE_F (Type F) konvertiert.
* Mit G_LOSMENGE_F wird gerechnet.
  G_LOSMENGE_F = P_LOSMENGE.

* Der Gesamtpruefumfang entspricht der Losmenge.
  P_QAMV_PRUEFUMF = P_LOSMENGE.
* Gesamtstichprobenumfang (n) und Stichprobenanzahl neu ermitteln.
* Stichprobenumfang und Bewertungsregel bleiben unveraendert.
* Fuer diesen Sonderfall ist der nachfolgende Algorithmus unabhaengig
* davon, ob die Bezugseinheit Nachhkommastellen hat oder nicht.

*-- Division durch 0 verhindern
  IF P_FAKPLANME IS INITIAL.
     P_FAKPLANME = C_F_1.
  ENDIF.

* Damit als Stichprobenumfang nicht 0 berechnet wird
  IF P_FAKPROBME IS INITIAL.
     P_FAKPROBME = C_F_1.
  ENDIF.

* Stichprobenanzahl korrigieren.
  P_SOLLSTPANZ = P_LOSMENGE   DIV P_STIPROUMF.
  G_MOD_F      = P_LOSMENGE   MOD P_STIPROUMF.
  IF G_MOD_F GT C_F_0.
    ADD C_I_1 TO P_SOLLSTPANZ.
  ENDIF.
ENDFORM.
*eject
*----------------------------------------------------------------------*
*       FORM SONDERFALL_C_PRUEFEN
*----------------------------------------------------------------------*
*       Sonderfall C:
*       Bei Mehrfachproben ist schon der Pruefumfang einer Probe
*       groesser als der Losumfang.
*       Folge:
*       100%-Pruefung und manuelle Bewertung.
*       Falls keine Prüfung des Stichprobenumfangs gegen die Losmenge:
*       Stichprobenumfang bleibt wie berechnet.
*----------------------------------------------------------------------*
*  -->  P_LOSMENGE        Losmenge
*  -->  P_NACHKOMMA       Kz. fuer Nachkommastellen
*  -->  P_FAKPLANME       Faktor Umrechnung Material-ME in Probe-ME
*  -->  P_FAKPROBME       Faktor Umrechnung Probe-ME in Material-ME
*  -->  P_PROBMGFAK       Vielfaches der Probe-ME
*  -->  P_KZRAST          mit Prüfpunkten
*  -->  p_KZNOCUT         kein Abschneiden des Stichprobenumfangs
*  <->  P_SOLLSTPUMF      Stichprobenumfang Merkmalsebene
*  <->  P_STIPROUMF       Stichprobenumfang Probenebene
*  <->  P_SOLLSTPANZ      Stichprobenanzahl Merkmalsebene
*  <->  P_BEWREGEL        Bewertungsregel
*  <->  P_KZHPZ           Kz. fuer 100%-Pruefung
*  <->  P_QAMV_PRUEFUMF   Pruefumfang Merkmalsebene
*  <->  P_QASV_PRUEFUMF   Pruefumfang Probenebene
*----------------------------------------------------------------------*
FORM SONDERFALL_C_PRUEFEN USING VALUE(P_LOSMENGE)
                                VALUE(P_NACHKOMMA)
                                VALUE(P_FAKPLANME)
                                VALUE(P_FAKPROBME)
                                VALUE(P_PROBMGFAK)
                                VALUE(P_KZRAST)
                                VALUE(P_KZNOCUT)
                          CHANGING    P_SOLLSTPUMF
                                      P_STIPROUMF
                                      P_SOLLSTPANZ
                                      P_BEWREGEL
                                      P_KZHPZ
                                      P_QAMV_PRUEFUMF
                                      P_QASV_PRUEFUMF.

CONSTANTS  CL_100_PROZUMF LIKE QDSV-PROZUMF VALUE '1'. "*-- 100 %"

* Pruefumfang einer Probe groesser als Losumfang.
  CHECK P_QASV_PRUEFUMF GT P_LOSMENGE.

* 100%-Pruefung.
  P_KZHPZ = C_KREUZ.
  P_BEWREGEL = 'A1'.
* Stichprobenanzahl auf den Wert 1 zuruecksetzen.
  P_SOLLSTPANZ = C_I_1.
* PRUEFUMF entspricht der Losmenge.
  P_QASV_PRUEFUMF = P_LOSMENGE.
  P_QAMV_PRUEFUMF = P_LOSMENGE.


* Abschneiden des Stichprobenumfangs nur, falls gewünscht
  IF P_KZNOCUT EQ SPACE.
*   Der Stichprobenumfang wird genauso ermittelt, wie bei prozentualer
*   Stichprobe mit Stichprobenprozentsatz 100.

*-- Berechnung Stichprobenumfang
    PERFORM STIPROUMF_PROZ_BERECHNEN USING      P_LOSMENGE
                                                CL_100_PROZUMF
                                                P_FAKPLANME
                                                P_FAKPROBME
                                                P_PROBMGFAK
                                       CHANGING P_STIPROUMF.

     P_SOLLSTPUMF = P_STIPROUMF.
  ENDIF.

ENDFORM.
*eject
*----------------------------------------------------------------------*
*       FORM STICHPROBENPLAN_LESEN
*----------------------------------------------------------------------*
*       Stichprobenanweisung aus dem Stichprobenplan lesen.
*       Ggf. Grundgesamtheit berechnen:
*       Die Grundgesamtheit bezueglich des Stichprobenumfangs
*       bezieht sich auf die Probemengeneinheit.
*       Der Faktor der Stichprobeneinheit wird beruecksichtigt.
*       Beispiel:
*       Geliefert werden 20 kg (kg ist die Lagermengeneinheit).
*       Die Probemengeneinheit ist g.
*       -) Faktor der Stichprobeneinheit ist 1. (Probe: 1g)
*          Die Grundgesamtheit ist dann 20.000 g.
*       -) Faktor der Stichprobeneinheit ist 5. (Probe: 5g)
*          Die Grundgesamtheit ist dann 4.000 g.
*----------------------------------------------------------------------*
*  -->  P_LOSMENGE     Losmenge
*  -->  P_FAKPLANME    Faktor Umrechnung Material-ME in Probe-ME
*  -->  P_FAKPROBME    Faktor Umrechnung Probe-ME in Material-ME
*  -->  P_PROBMGFAK    Vielfaches der Probe-ME
*  -->  P_STPRPLAN     Stichprobenplan
*  -->  P_AQLWERT      AQL-Wert
*  -->  P_PRSCHAERFE   Pruefschaerfe
*  <--  P_STIPROUMF    Stichprobenumfang Probenebene
*  <--  P_ANNAHMEZ     Annahmezahl
*  <--  P_RUECKWEZ     Rueckweisezahl
*  <--  P_KFAKTORE     k-Kaktor
*  <--  P_KFAKTORNI    Kz. k-Kaktor nicht initial
*  <--  P_STPRANZ      Stichprobenanzahl bei abhängigen Mehrfachproben
*----------------------------------------------------------------------*
FORM STICHPROBENPLAN_LESEN USING VALUE(P_LOSMENGE)
                                 VALUE(P_FAKPLANME)
                                 VALUE(P_FAKPROBME)
                                 VALUE(P_PROBMGFAK)
                                 VALUE(P_STPRPLAN)
                                 VALUE(P_AQLWERT)
                                 VALUE(P_PRSCHAERFE)
                           CHANGING    P_STIPROUMF
                                       P_ANNAHMEZ
                                       P_RUECKWEZ
                                       P_KFAKTOR
                                       P_KFAKTORNI
                                       P_STPRANZ.

* Lokale Datenvereinbarungen.
  DATA:
  L_GRUNDGESAMTHEIT    TYPE F,
  L_GRUNDGESAMTHEIT_C(20).

* Initialisierungen.
* Damit nicht durch null dividiert wird.
  IF P_FAKPLANME IS INITIAL.
    P_FAKPLANME = C_F_1.
  ENDIF.
  IF P_FAKPROBME IS INITIAL.
    P_FAKPROBME = C_F_1.
  ENDIF.
  IF P_PROBMGFAK IS INITIAL.
    P_PROBMGFAK = C_F_1.
  ENDIF.

* L_GRUNDGESAMTHEIT ist FLTP-Feld, da die berechnete Menge
* groesser als die Losmenge werden kann.
  L_GRUNDGESAMTHEIT =   ( P_LOSMENGE  * P_FAKPROBME )
                      / ( P_PROBMGFAK * P_FAKPLANME ).

* L_GRUNDGESAMTHEIT darf nicht groesser als 10.000.000.000 werden,
* da dies der maximale Losumfang im Stichprobenplan ist.
  IF L_GRUNDGESAMTHEIT GT C_LOSUMF_MAX.
    L_GRUNDGESAMTHEIT = C_LOSUMF_MAX.
  ENDIF.

* Zum AQL-Wert den Positionszaehler (ZAEHLPOS) ermitteln,
* aber nur, wenn nicht gerade vorher gelesen.
  IF   G_AQL_TAB-STPRPLAN NE P_STPRPLAN
    OR G_AQL_TAB-AQLWERT  NE P_AQLWERT.

    LOOP AT G_AQL_TAB
         WHERE STPRPLAN EQ P_STPRPLAN
         AND   AQLWERT  EQ P_AQLWERT.
      MOVE G_AQL_TAB-ZAEHLPOS TO G_ZAEHLPOS.
      EXIT.
    ENDLOOP.
*   Wenn kein Eintrag in G_AQL_TAB, dann SELECT.
    IF SY-SUBRC NE C_RC_0.
      SELECT * FROM QDPP
             WHERE STPRPLAN EQ P_STPRPLAN
             AND   AQLWERT  EQ P_AQLWERT.
        MOVE QDPP-ZAEHLPOS TO G_ZAEHLPOS.
      ENDSELECT.
*     G_AQL_TAB auffuellen.
      MOVE P_STPRPLAN TO G_AQL_TAB-STPRPLAN.
      MOVE P_AQLWERT  TO G_AQL_TAB-AQLWERT.
      MOVE G_ZAEHLPOS TO G_AQL_TAB-ZAEHLPOS.
      APPEND G_AQL_TAB.
    ENDIF.

  ENDIF.

* Jetzt die Stichprobenanweisung lesen,
* aber nur, wenn nicht gerade vorher gelesen.
  IF   G_ANW_TAB-STPRPLAN        NE P_STPRPLAN
    OR G_ANW_TAB-ZAEHLPOS        NE G_ZAEHLPOS
    OR G_ANW_TAB-PRSCHAERFE      NE P_PRSCHAERFE
    OR G_ANW_TAB-GRUNDGESAMTHEIT NE L_GRUNDGESAMTHEIT.

    LOOP AT G_ANW_TAB
         WHERE GRUNDGESAMTHEIT EQ L_GRUNDGESAMTHEIT
         AND   STPRPLAN        EQ P_STPRPLAN
         AND   ZAEHLPOS        EQ G_ZAEHLPOS
         AND   PRSCHAERFE      EQ P_PRSCHAERFE.
      MOVE G_ANW_TAB-STPRUMF   TO P_STIPROUMF.
      MOVE G_ANW_TAB-ANNAHMEZ  TO P_ANNAHMEZ.
      MOVE G_ANW_TAB-RUECKWEZ  TO P_RUECKWEZ.
      MOVE G_ANW_TAB-KFAKTOR   TO P_KFAKTOR.
      MOVE G_ANW_TAB-KFAKTORNI TO P_KFAKTORNI.
      MOVE G_ANW_TAB-STPRANZ   TO P_STPRANZ.
      EXIT.
    ENDLOOP.
*   Wenn kein Eintrag in G_ANW_TAB, dann SELECT.
    IF SY-SUBRC NE C_RC_0.
      SELECT * FROM QDPA UP TO 1 ROWS
             WHERE STPRPLAN   EQ P_STPRPLAN
             AND   ZAEHLPOS   EQ G_ZAEHLPOS
             AND   PRSCHAERFE EQ P_PRSCHAERFE
             AND   LOSUMF     GE L_GRUNDGESAMTHEIT
             ORDER BY LOSUMF.
        MOVE QDPA-STPRUMF   TO P_STIPROUMF.
        MOVE QDPA-ANNAHMEZ  TO P_ANNAHMEZ.
        MOVE QDPA-RUECKWEZ  TO P_RUECKWEZ.
        MOVE QDPA-KFAKTOR   TO P_KFAKTOR.
        MOVE QDPA-KFAKTORNI TO P_KFAKTORNI.
        MOVE QDPA-STPRANZ   TO P_STPRANZ.
      ENDSELECT.

*     Fehlermeldung, wenn kein Eintrag im StPrPlan gefunden wurde.
      IF SY-SUBRC NE C_RC_0.
*       Float-Feld ausgeben in Meldung
        WRITE L_GRUNDGESAMTHEIT TO L_GRUNDGESAMTHEIT_C
              DECIMALS 0 EXPONENT 0 LEFT-JUSTIFIED.
*
        MESSAGE E092 WITH P_STPRPLAN
                          P_PRSCHAERFE
                          P_AQLWERT
                          L_GRUNDGESAMTHEIT_C.

      ENDIF.

*     G_ANW_TAB auffuellen.
      MOVE P_STPRPLAN        TO G_ANW_TAB-STPRPLAN.
      MOVE G_ZAEHLPOS        TO G_ANW_TAB-ZAEHLPOS.
      MOVE P_PRSCHAERFE      TO G_ANW_TAB-PRSCHAERFE.
      MOVE L_GRUNDGESAMTHEIT TO G_ANW_TAB-GRUNDGESAMTHEIT.
      MOVE P_STIPROUMF       TO G_ANW_TAB-STPRUMF.
      MOVE P_ANNAHMEZ        TO G_ANW_TAB-ANNAHMEZ.
      MOVE P_RUECKWEZ        TO G_ANW_TAB-RUECKWEZ.
      MOVE P_KFAKTOR         TO G_ANW_TAB-KFAKTOR.
      MOVE P_KFAKTORNI       TO G_ANW_TAB-KFAKTORNI.
      MOVE P_STPRANZ         TO G_ANW_TAB-STPRANZ.
      APPEND G_ANW_TAB.
    ENDIF.

* StprAnweisung vorher gelesen, dann ExpParameter fuellen.
  ELSE.
    MOVE G_ANW_TAB-STPRUMF   TO P_STIPROUMF.
    MOVE G_ANW_TAB-ANNAHMEZ  TO P_ANNAHMEZ.
    MOVE G_ANW_TAB-RUECKWEZ  TO P_RUECKWEZ.
    MOVE G_ANW_TAB-KFAKTOR   TO P_KFAKTOR.
    MOVE G_ANW_TAB-KFAKTORNI TO P_KFAKTORNI.
    MOVE G_ANW_TAB-STPRANZ   TO P_STPRANZ.
  ENDIF.
* Es kann sein, daß der Zähler bei nur einer Paarung c/d die Werte
* 1 und auch 0 hat. Bei 0 wird er jetzt auf 1 gesetzt
  IF P_STPRANZ EQ 0.
    P_STPRANZ = 1.
  ENDIF.

ENDFORM.
*eject
*----------------------------------------------------------------------*
*       FORM STIPROUMF_PROZ_BERECHNEN
*----------------------------------------------------------------------*
*       Der Stichprobenumfang ist ganzzahlig.
*       Es wird nur aufgerundet: z:B: 5,1 nach 6,
*                                     5,6 nach 6.
*----------------------------------------------------------------------*
*  -->  P_LOSMENGE   Losmenge
*  -->  P_PROZUMF    Stichprobenprozentsatz
*  <--  P_STIPROUMF  Stichprobenumfang Probenebene
*----------------------------------------------------------------------*
FORM STIPROUMF_PROZ_BERECHNEN USING VALUE(P_LOSMENGE)
                                    VALUE(P_PROZUMF)
                                    VALUE(P_FAKPLANME)
                                    VALUE(P_FAKPROBME)
                                    VALUE(P_PROBMGFAK)
                              CHANGING    P_STIPROUMF.

* Beispiel
* Basismengeneinheit: ST
* Mengeneinheiten im Materialstamm: ( p_fakprobme  <=> p_fakplanme  )
*                                    20 G <=> 1 ST
*                                    1 KA <=> 12 ST
* Merkmal 1 im Prüfplan           :  Probenmengeneinheit: G
*                                    Basisprobemenge    : 1 (p_probmgfak
* Merkmal 2 im Prüfplan           :  Probenmengeneinheit: KA
*                                    Basisprobemenge    : 1
*
* Für beide Merkmale sollen jeweils 10% des Losumfangs geprüft werden.
*
* Losumfang = 100 ST  (p_losmenge)
* =>
* Stichprobenumfang = kleinster ganzzahliger Wert, der nicht kleiner als
* 1. Merkmal          ( ( 100 * 0,1 * 20) / (1 * 1) )

* Lokale Datenvereinbarung
DATA: C_F_CONST LIKE QDSV-PROZUMF VALUE '5E-9'.


* Damit nicht durch null dividiert wird.
  IF P_FAKPLANME IS INITIAL.
    P_FAKPLANME = C_F_1.
  ENDIF.
  IF P_PROBMGFAK IS INITIAL.
    P_PROBMGFAK = C_F_1.
  ENDIF.

* Damit als Stichprobenumfang nicht 0 berechnet wird
  IF P_FAKPROBME IS INITIAL.
     P_FAKPROBME = C_F_1.
  ENDIF.

* Damit durch die Floating-Point Ungenauigkeit kein größerer Wert, als
* der gewünschte, errechnet werden kann, wird 5E-09 abgezogen.
  CATCH SYSTEM-EXCEPTIONS CONVERSION_ERRORS = 1
                          ARITHMETIC_ERRORS = 1.
    P_STIPROUMF
    = CEIL( ( P_LOSMENGE *  P_PROZUMF * P_FAKPROBME )
            / ( P_FAKPLANME * P_PROBMGFAK ) - C_F_CONST ).
  ENDCATCH.
  IF SY-SUBRC = 1.
    MESSAGE E003.
  ENDIF.

ENDFORM.
*eject
*----------------------------------------------------------------------*
*       FORM STPRUMFANG_KORRIGIEREN
*----------------------------------------------------------------------*
*       Bei 100%-Pruefung und einer Einheit mit Nachkommastellen
*       wird 1 als Stichprobenumfang vorgeschlagen.
*       Dies ist nicht richtig, wenn im Pruefplan eine Probe-
*       mengeneinheit gewaehlt wurde, die "kleiner" ist als
*       die Basismengeneinheit (Umrechnungsfaktor < 1).
*----------------------------------------------------------------------*
*  -->  P_QASV_PRUEFUMF   Pruefumfang Probenebene
*  -->  P_FAKPLANME       Faktor Umrechnung Material-ME in Probe-ME
*  -->  P_FAKPROBME       Faktor Umrechnung Probe-ME in Material-ME
*  -->  P_PROBMGFAK       Vielfaches der Probe-ME
*  <->  P_SOLLSTPUMF      Stichprobenumfang Merkmalsebene
*  <->  P_STIPROUMF       Stichprobenumfang Probenebene
*----------------------------------------------------------------------*
FORM STPRUMFANG_KORRIGIEREN USING VALUE(P_QASV_PRUEFUMF)
                                  VALUE(P_FAKPLANME)
                                  VALUE(P_FAKPROBME)
                                  VALUE(P_PROBMGFAK)
                            CHANGING    P_SOLLSTPUMF
                                        P_STIPROUMF.
  CHECK P_FAKPROBME GT P_FAKPLANME.

* Lokale Datenvereinbarungen
  DATA:
  L_PRUEFUMF   TYPE F.

* Fuer nachfolgende Rechnungen Konvertierung in FLTP-Feld.
  L_PRUEFUMF = P_QASV_PRUEFUMF.

* Stichprobenumfang Probenebene berechnen.
  P_STIPROUMF =       L_PRUEFUMF
                DIV ( P_PROBMGFAK
                    * P_FAKPLANME
                    / P_FAKPROBME ) .

* Stichprobenumfang Merkmalsebene berechnen.
  P_SOLLSTPUMF = P_STIPROUMF.

ENDFORM.
*eject
*----------------------------------------------------------------------*
*       FORM STPRUMFANG_RUNDEN
*----------------------------------------------------------------------*
*       Stichprobenumfang ggf. korrigieren (aufrunden).
*       Interessant bei 100%-Pruefung und
*       Einheit ohne Nachkommastellen.
*       Beispiel:
*       Wenn Losmenge = 62,4 St, dann n = 63.
*----------------------------------------------------------------------*
*  -->  P_LOSMENGE     Losmenge
*  -->  P_FAKPLANME    Faktor Umrechnung Material-ME in Probe-ME
*  -->  P_FAKPROBME    Faktor Umrechnung Probe-ME in Material-ME
*  -->  P_PROBMGFAK    Vielfaches der Probe-ME
*  <->  P_SOLLSTPUMF   Stichprobenumfang Merkmalsebene
*  <->  P_STIPROUMF    Stichprobenumfang Probenebene
*----------------------------------------------------------------------*
FORM STPRUMFANG_RUNDEN USING VALUE(P_LOSMENGE)
                             VALUE(P_FAKPLANME)
                             VALUE(P_FAKPROBME)
                             VALUE(P_PROBMGFAK)
                       CHANGING    P_SOLLSTPUMF
                                   P_STIPROUMF.

* Initialisierungen.
  CLEAR G_MOD_F.
  CLEAR G_LOSMENGE_F.

* Damit nicht durch null dividiert wird.
  IF P_FAKPLANME IS INITIAL.
    P_FAKPLANME = C_F_1.
  ENDIF.
  IF P_FAKPROBME IS INITIAL.
    P_FAKPROBME = C_F_1.
  ENDIF.
  IF P_PROBMGFAK IS INITIAL.
    P_PROBMGFAK = C_F_1.
  ENDIF.

* Fuer die nachfolgenden Rechnungen wird QALS-LOSMENGE (Type P)
* in G_LOSMENGE_F (Type F) konvertiert.
* Mit G_LOSMENGE_F wird gerechnet.
  G_LOSMENGE_F = P_LOSMENGE.

* Stichprobenumfang Probenebene berechnen.
  P_STIPROUMF =       G_LOSMENGE_F
                DIV ( P_PROBMGFAK
                    * P_FAKPLANME
                    / P_FAKPROBME ) .

  G_MOD_F     =       G_LOSMENGE_F
                MOD ( P_PROBMGFAK
                    * P_FAKPLANME
                    / P_FAKPROBME ) .

  IF G_MOD_F GT C_F_0.
    ADD C_I_1 TO P_STIPROUMF.
  ENDIF.

* Stichprobenumfang Merkmalsebene berechnen.
  P_SOLLSTPUMF = P_STIPROUMF.

ENDFORM.
*eject
*&---------------------------------------------------------------------*
*&      Form  CH_STPRUMF_MAX
*&---------------------------------------------------------------------*
*       Bei Stichprobenanzahl > 1 oder Prüfpunkten darf der
*       Stichprobenumfang den Wert 19999 nicht übersteigen
*----------------------------------------------------------------------*
*      -->P_I_QDSV_STPRUMF  Stichprobenumfang aus Stichprobenverfahren *
*      -->P_I_QDSV_STPRANZ  Stichprobenanzahl                          *
*      -->P_I_QDSV_KZRAST   Prüfpunkte                                 *
*      <--P_I_QDSV_STPRUMF  STichprobenumfang                          *
*----------------------------------------------------------------------*
FORM CH_STPRUMF_MAX USING VALUE(P_STPRANZ) LIKE QDSV-STPRANZ
                          VALUE(P_KZRAST)  LIKE QDSV-KZRAST
                    CHANGING STPRUMF       LIKE QDSV-STPRUMF.


* Nur bei unabh. Mehrfachproben und Prüfpunkten
  IF ( NOT P_KZRAST IS INITIAL
       OR  P_STPRANZ > 1 )
  AND STPRUMF > C_ANZ_PROBEN2.
*     Stichprobenumfang überschreitet max. mögl. Wert und wird auf
*     max. möglichen Wert reduziert (19999).
      STPRUMF = C_ANZ_PROBEN2.
  ENDIF.

ENDFORM.
