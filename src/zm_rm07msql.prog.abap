**********************************************************************
*                                                                    *
*     Formroutinenpool für Reports der Bestandsführung, Reservierung *
*     und Inventur.                                                  *
*                                                                    *
**********************************************************************
TABLES: t001,
        t001w,
        t001k,
        t006a,                         "Zuordung externe - interne ME
        t064b,
        t064t,
        v134w,
* #005 begin: Performanceverbesserungen
        t134m,
* #005 end
        t156,
        t156t,
        t418,
        mara,
        marm,                          "Mengeneinheiten zum Material
        marav,
        marv,
        marc,
        mard,
        makt,
        mabdr,
        mbefu,
        mkpf,
        mkol,
        mkop,
        msku,
        mslb,
        mseg,
        ikpf,
        rkpf,
        resb,
        mtcor,
        mtcom,
        ekbe,
        v_mmim_mkp.

* Petra Pfaff: begin: Anpassung Wertartikelinventur 1.2
TABLES: mara_b.
* Petra Pfaff: end

DATA: conv_bud    LIKE mkpf-budat,
      abgang,
      kz_select,
      meins_neu   LIKE mseg-meins,
      index_t     LIKE sy-tabix,
      rmax        LIKE sy-tabix VALUE 20,
      zaehler     LIKE sy-tabix,
      max_zaehler LIKE sy-tabix.

DATA: BEGIN OF dummy OCCURS 1.
DATA:   dummy.
DATA: END OF dummy.

* &005 begin: Performanceverbesserungen
*------- Structur für MARA- Satz
DATA:    BEGIN OF xmara  OCCURS 1.
        INCLUDE STRUCTURE mara.
DATA:    END OF xmara.
* &005 end

* Petra Pfaff: begin: Anpassung Wertartikelinventur 1.2
*--- Interne Tabelle der Einzelartikel zu einem Wertartikel.    ----*
DATA: BEGIN OF t_mara_b OCCURS 5.
        INCLUDE STRUCTURE mara_b.
DATA: END OF t_mara_b.
* Petra Pfaff: end

DATA: BEGIN OF yiseg OCCURS 5.
        INCLUDE STRUCTURE iseg.
DATA: btext LIKE t064b-btext.          "Bestandsartentext
DATA: buper LIKE am07m-bupev.          "Buchungsperiode
DATA: bwkey LIKE vm07i-bwkey.          "Bewertungsebene
DATA: bwtar LIKE vm07i-bwtar.          "Bewertungsart
DATA: difmg LIKE vm07i-difmg.          "Differenzmenge
* pfaffp: neue Differenzenliste
DATA: pdifw LIKE rm07i-pdifw.          "Differenzwert poitiv
DATA: ndifw LIKE rm07i-ndifw.          "Differenzwert negativ
DATA: invnu LIKE ikpf-invnu.           "Inventurnummer
* Pfaffp: end
DATA: dstat LIKE ikpf-dstat.           "Ausbuchstatus
DATA: gidat LIKE ikpf-gidat.           "Geplantes AufDat
DATA: maktx LIKE makt-maktx.           "Materialkurztext
DATA: monat LIKE ikpf-monat.
DATA: stext LIKE t064t-stext.          "Status d. Position
DATA: vgart LIKE ikpf-vgart.           "Vorgangsart
DATA: vgari LIKE ikpf-vgart.           "Vorgangsart
DATA: xruem.
DATA: xdele.
DATA: y_gjahr LIKE iseg-gjahr.         " aktuelles Geschäftsjahr
DATA: difvw LIKE vm07i-difvw.          "Differenzverkaufswert
DATA: xvkbw LIKE t001k-xvkbw.          "Kezi Verkaufspreisbewewertung
DATA: name1 LIKE t001w-name1.          "Werksname
DATA: box   LIKE dm07i-xselz.
DATA: lvsam LIKE am07m-xselk.          "LVS: Aber keine MSEG->Archiviert
DATA: kbetr LIKE konp-kbetr.
DATA: END OF yiseg.
*--------------Neu zu 3.0 E -----------------------------------------*
*- Interne Tabelle mit den zum Material erlaubten Mengeneinh.
DATA: BEGIN OF mengeneinheiten OCCURS 30.
        INCLUDE STRUCTURE rmmme1.
DATA: END OF mengeneinheiten.

*- Interne Tabelle mit den Texten zur den erlaubten Mengeneinh.
DATA: BEGIN OF metexte OCCURS 30,
           meinh LIKE rmmme1-meinh,
           msehl LIKE t006a-msehl,
      END OF metexte.

* -----Allgemeine Materialdaten inkl. Kurztext ------------------------
* Interne Tabelle mit Materialien z.B. für FB-Übergabe
DATA: BEGIN OF pre03_tab OCCURS 10.
        INCLUDE STRUCTURE pre03.
DATA: END OF pre03_tab.
*-----------Ende 3.0 E ------------------------------------------------*




DATA: BEGIN OF imkpf OCCURS 100.
        INCLUDE STRUCTURE mkpf.
DATA: END OF imkpf.

DATA: BEGIN OF xmkpf OCCURS 0.
        INCLUDE STRUCTURE v_mmim_mkp.
DATA: END OF xmkpf.

DATA: BEGIN OF imseg OCCURS 100.
        INCLUDE STRUCTURE mseg.
DATA: END OF imseg.

DATA: BEGIN OF iikpf OCCURS 100.
        INCLUDE STRUCTURE ikpf.
DATA: END OF iikpf.

DATA: BEGIN OF irkpf OCCURS 100.
        INCLUDE STRUCTURE rkpf.
DATA: END OF irkpf.

DATA: BEGIN OF imakt OCCURS 100.
        INCLUDE STRUCTURE makt.
DATA: END OF imakt.

DATA: BEGIN OF imara OCCURS 100.
        INCLUDE STRUCTURE mara.
DATA: END OF imara.

DATA: BEGIN OF imarav OCCURS 100.
        INCLUDE STRUCTURE marav.
DATA: END OF imarav.

DATA: BEGIN OF imarc OCCURS 100.
        INCLUDE STRUCTURE marc.
DATA: END OF imarc.

DATA: BEGIN OF imard OCCURS 100.
        INCLUDE STRUCTURE mard.
DATA: END OF imard.

DATA: BEGIN OF imsku OCCURS 100.
        INCLUDE STRUCTURE msku.
DATA: END OF imsku.

DATA: BEGIN OF imslb OCCURS 100.
        INCLUDE STRUCTURE mslb.
DATA: END OF imslb.

DATA: BEGIN OF imkol OCCURS 100.
        INCLUDE STRUCTURE mkol.
DATA: END OF imkol.

DATA: BEGIN OF imkop OCCURS 100.
        INCLUDE STRUCTURE mkop.
DATA:   waers LIKE mepro-waers.        "4.0konsi
DATA: END OF imkop.

DATA: BEGIN OF iekbe OCCURS 100.
        INCLUDE STRUCTURE ekbe.
DATA: END OF iekbe.

DATA: BEGIN OF xkopf OCCURS 100,
        belnr LIKE mkpf-mblnr,
        high  LIKE mkpf-mblnr,
        mjahr LIKE mseg-mjahr,
      END OF xkopf.

DATA: BEGIN OF xpos  OCCURS 100,
        belnr LIKE mkpf-mblnr,
        high  LIKE mkpf-mblnr,
      END OF xpos.

DATA: BEGIN OF xrkopf OCCURS 100,
        rsnum LIKE rkpf-rsnum,
      END OF xrkopf.

DATA: BEGIN OF xmatn OCCURS 100,
        matnr LIKE mseg-matnr,
      END OF xmatn.
*----Neu zu 3.0E -----------------------
DATA: BEGIN OF xmeins OCCURS 100,
        matnr LIKE mseg-matnr,
        basme LIKE mseg-meins,
      END OF xmeins.
*---Ende 3.0E -------------------------*
DATA:BEGIN OF iresb OCCURS 0.
        INCLUDE STRUCTURE resb.
DATA: END OF iresb.

DATA:    BEGIN OF ydm07i OCCURS 0.
        INCLUDE STRUCTURE dm07i.
DATA:    END OF ydm07i.
DATA:   option(2)       TYPE c.
DATA:   rvgart LIKE mkpf-vgart.
RANGES: imblnr FOR  mkpf-mblnr.
RANGES: imblns FOR  mseg-mblnr.
RANGES: imatnr FOR  mseg-matnr.
RANGES: irsnum FOR  rkpf-rsnum.
RANGES: iebeln FOR  ekbe-ebeln.
RANGES: iebelx FOR  ekbe-ebeln.
RANGES  rvgarx FOR  ikpf-vgart.
RANGES: rmatnr FOR  resb-matnr.
RANGES: rwerks  FOR  resb-matnr.
RANGES: rbdter  FOR  resb-bdter.

*----  SQL-Routinen fuer Auswertungsreports in der Bestandsfuehrung ---*
*---------------Neu 3.0E  -----------------------------------------*
FORM mengeneinheiten_lesen USING int_tab.

  LOOP AT xmeins.
    REFRESH pre03_tab.
    pre03_tab-matnr = xmeins-matnr.
    APPEND pre03_tab.
    CALL FUNCTION 'MATERIAL_PRE_READ_MARM'
         TABLES
              ipre03 = pre03_tab.
    CALL FUNCTION 'MATERIAL_UNIT_FIND_30'
         EXPORTING
              kzall              = 'X'
              matnr              = xmeins-matnr
              meins              = xmeins-basme
         TABLES
              rmmme1_itab        = mengeneinheiten
         EXCEPTIONS
              material_not_found = 01.
* Einlesen des Textes pro zul. Mengeneinheit.
    LOOP AT mengeneinheiten.
      CLEAR metexte.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
           EXPORTING
                input          = mengeneinheiten-meinh
                language       = sy-langu
           IMPORTING
                long_text      = t006a-msehl
                output         = t006a-mseh3
                short_text     = t006a-mseht
           EXCEPTIONS
                unit_not_found = 01.
      t006a-msehi = mengeneinheiten-meinh.
      metexte-meinh = t006a-msehi.
      metexte-msehl = t006a-msehl.
      APPEND metexte.
    ENDLOOP.
  ENDLOOP.
ENDFORM.
*--------------Ende 3.0E -------------------------------------*
*---------- Lesen Materialkurztext (Massenverarbeitung) --------------*
FORM imakt_fuellen.
  SELECT * FROM makt APPENDING TABLE imakt WHERE matnr IN imatnr
                                           AND   spras EQ sy-langu.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM KURZTEXT_LESEN_ARRAY                                     *
*---------------------------------------------------------------------*
FORM kurztext_lesen_array.
  imatnr-sign = 'I'.
  imatnr-option = 'EQ'.
  DESCRIBE TABLE xmatn LINES index_t.
  LOOP AT xmatn.
    imatnr-low = xmatn-matnr.
    APPEND imatnr.
    zaehler = zaehler + 1.
    max_zaehler = max_zaehler + 1.
    IF zaehler = rmax.
      PERFORM imakt_fuellen.
      REFRESH imatnr.
      CLEAR zaehler.
      IF max_zaehler = index_t.
        CLEAR max_zaehler.
        CLEAR index_t.
        EXIT.
      ENDIF.
    ENDIF.
    IF max_zaehler = index_t.
      PERFORM imakt_fuellen.
      REFRESH imatnr.
      CLEAR zaehler.
      CLEAR max_zaehler.
      CLEAR index_t.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.

*---------- Lesen des Reservierungsbelegkopf (Mengenverarbeitung) ----
FORM irkpf_fuellen.
  SELECT * FROM rkpf APPENDING TABLE irkpf WHERE rsnum IN irsnum
                               ORDER BY PRIMARY KEY.
ENDFORM.
*---------------------------------------------------------------------

FORM rbelegkopf_lesen_array.
  irsnum-sign = 'I'.
  irsnum-option = 'EQ'.
  DESCRIBE TABLE xrkopf LINES index_t.
  LOOP AT xrkopf.
    irsnum-low = xrkopf-rsnum.
    APPEND irsnum.
    zaehler = zaehler + 1.
    max_zaehler = max_zaehler + 1.
    IF zaehler = rmax.
      PERFORM irkpf_fuellen.
      REFRESH irsnum.
      CLEAR zaehler.
      IF max_zaehler = index_t.
        CLEAR max_zaehler.
        CLEAR index_t.
        EXIT.
      ENDIF.
    ENDIF.
    IF max_zaehler = index_t.
      PERFORM irkpf_fuellen.
      REFRESH irsnum.
      CLEAR zaehler.
      CLEAR max_zaehler.
      CLEAR index_t.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.
*---------- Lesen des Materialbelegkopf_Views  -----------------------
FORM vmkpf_fuellen.
  SELECT * FROM v_mmim_mkp APPENDING TABLE xmkpf WHERE mblnr IN imblnr
                               ORDER BY mblnr mjahr.
ENDFORM.

*---------- Lesen des Materialbelegkopf (Mengenverarbeitung)  --------
FORM imkpf_fuellen.
  SELECT * FROM mkpf APPENDING TABLE imkpf WHERE mblnr IN imblnr
                               ORDER BY PRIMARY KEY.
ENDFORM.

*---------- Lesen des Materialbelegkopf mit Vorgangsart      ---------
FORM rmkpf_fuellen.
  SELECT * FROM mkpf APPENDING TABLE imkpf WHERE mblnr IN imblnr
                                             AND vgart IN rvgarx
                               ORDER BY PRIMARY KEY.
ENDFORM.

*---------- Lesen des Inventurbelegkopf (Mengenverarbeitung) ---------
FORM iikpf_fuellen.
  SELECT * FROM ikpf APPENDING TABLE iikpf WHERE iblnr IN imblnr
                               ORDER BY PRIMARY KEY.
ENDFORM.

*-------- Rangetabelle zum Lesen der Belegkoepfe fuellen -------------
FORM belegkopf_lesen_array USING int_tab.
  imblnr-sign = 'I'.
  IF int_tab = 'RMKPF' OR int_tab = 'XMKPF'.
    imblnr-option = option.
  ELSE.
    imblnr-option = 'EQ'.
  ENDIF.
  DESCRIBE TABLE xkopf LINES index_t.
  LOOP AT xkopf.
    imblnr-low = xkopf-belnr.
    IF int_tab = 'RMKPF' OR int_tab = 'XMKPF'.
      imblnr-high = xkopf-high.
    ENDIF.
    APPEND imblnr.
    zaehler = zaehler + 1.
    max_zaehler = max_zaehler + 1.
    IF zaehler = rmax.
      CASE int_tab.
        WHEN 'IMKPF'.
          PERFORM imkpf_fuellen.
        WHEN 'RMKPF'.
          PERFORM rmkpf_fuellen.
        WHEN 'IIKPF'.
          PERFORM iikpf_fuellen.
        WHEN 'VMKPF'.
          PERFORM vmkpf_fuellen.
        WHEN 'XMKPF'.
          PERFORM vmkpf_fuellen.
      ENDCASE.
      REFRESH imblnr.
      CLEAR zaehler.
      IF max_zaehler = index_t.
        CLEAR max_zaehler.
        CLEAR index_t.
        EXIT.
      ENDIF.
    ENDIF.
    IF max_zaehler = index_t.
      CASE int_tab.
        WHEN 'IMKPF'.
          PERFORM imkpf_fuellen.
        WHEN 'RMKPF'.
          PERFORM rmkpf_fuellen.
        WHEN 'IIKPF'.
          PERFORM iikpf_fuellen.
        WHEN 'VMKPF'.
          PERFORM vmkpf_fuellen.
        WHEN 'XMKPF'.
          PERFORM vmkpf_fuellen.
      ENDCASE.
      REFRESH imblnr.
      CLEAR zaehler.
      CLEAR max_zaehler.
      CLEAR index_t.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.

*----  Lesen des Textes zur Bewegungsart                            ---*
FORM bwart_text USING lsb_bwart
                      lsb_sobkz
                      lsb_kzbew
                      lsb_kzzug
                      lsb_kzvbr.
  SELECT SINGLE * FROM t156 WHERE bwart = lsb_bwart.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001 WITH '156' lsb_bwart space space.
  ENDIF.
  SELECT SINGLE * FROM t156t WHERE spras = sy-langu
                             AND   bwart = lsb_bwart
                             AND   sobkz = lsb_sobkz
                             AND   kzbew = lsb_kzbew
                             AND   kzzug = lsb_kzzug
                             AND   kzvbr = lsb_kzvbr.
ENDFORM.

*----  Lesen des Bestandsartentextes für die Inventurpositionen     ---*
FORM bstar_lesen USING l_bstar.
  SELECT SINGLE * FROM t064b WHERE spras = sy-langu
                             AND   bstar = l_bstar.
  IF NOT sy-subrc IS INITIAL.
    clear T064B.                                               " 331888
*   MESSAGE e001 WITH '064B' l_bstar space space.              " 331888
  ENDIF.
ENDFORM.

*----  Lesen des Inventurstatustextes für die Inventurpositionen    ---*
FORM t064t_lesen.
  SELECT SINGLE * FROM t064t WHERE spras = sy-langu
                             AND   xzael = yiseg-xzael
                             AND   xdiff = yiseg-xdiff
                             AND   xnzae = yiseg-xnzae
                             AND   xloek = yiseg-xloek.
ENDFORM.

*----  Lesen des Materialkurztextes                                 ---*
FORM kurztext_lesen USING lsk_matnr.
  CLEAR mtcom.
  mtcom-kenng = 'MAKT'.
  mtcom-matnr = lsk_matnr.
  mtcom-spras = sy-langu.
  mtcom-nomus = 'X'.
  CALL FUNCTION 'MATERIAL_READ'
       EXPORTING
            schluessel = mtcom
       IMPORTING
            matdaten   = makt
            return     = mtcor
       TABLES
            seqmat01   = dummy.
ENDFORM.

*---- Lesen d. Matktxt. u. d. Lagerplzbeschr. f.Invzählbelegdruck   ---*
FORM materialinfo_lesen USING lsk_matnr lsk_werks lsk_lgort.
  CLEAR mtcom.
  mtcom-kenng = 'MABDR'.
  mtcom-matnr = lsk_matnr.
  mtcom-werks = lsk_werks.
  mtcom-lgort = lsk_lgort.
  mtcom-spras = sy-langu.
  mtcom-nomus = 'X'.
  CALL FUNCTION 'MATERIAL_READ'
       EXPORTING
            schluessel = mtcom
       IMPORTING
            matdaten   = mabdr
            return     = mtcor
       TABLES
            seqmat01   = dummy.
ENDFORM.

* Petra Pfaff: begin Anpassung Wertartikelinventur 1.2
*---- Lesen d. Matktxt. u. d. Lagerplzbeschr. f.Invzählbelegdruck   ---*
FORM wertmaterial_aufloesen USING lsk_matnr LIKE mara-matnr
                                  lsk_werks LIKE mard-werks
                                  lsk_lgort LIKE mard-lgort.

  CALL FUNCTION 'MATERIAL_TO_VALUE_MATERIAL'
       EXPORTING
            i_werks               = lsk_werks
            i_matnr               = lsk_matnr
*         I_DATAB               =
*         I_DATBI               =
       TABLES
            marab                 = t_mara_b
       EXCEPTIONS
            eingabe_nicht_erlaubt = 1
            error_found           = 2
            OTHERS                = 3.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM READ_UNIT                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  L_MATNR                                                       *
*  -->  L_WERKS                                                       *
*  -->  L_XAMEI                                                       *
*  -->  L_MEINS                                                       *
*---------------------------------------------------------------------*
FORM read_unit USING  l_matnr l_werks l_xamei l_meins.
  IF l_xamei IS INITIAL.
* Basismengeneinheit in Mara lesen
    REFRESH  xmara.
    CLEAR xmara.

*   Das lesen der MARA geschieht mittels Funktionsbaustein
*   MARA_single_read
    CALL FUNCTION 'MARA_SINGLE_READ'
         EXPORTING
              matnr  = l_matnr
         IMPORTING
              wmara  = xmara
         EXCEPTIONS
              OTHERS = 5.

    IF sy-subrc IS INITIAL.
      MOVE xmara-meins TO l_meins.
    ENDIF.
  ELSE.
* Ausgabemengeneinheit in Marc lesen.
    CLEAR mtcom.
    mtcom-kenng = 'MARC'.
    mtcom-matnr = l_matnr.
    mtcom-werks = l_werks.
    mtcom-spras = sy-langu.
    mtcom-nomus = 'X'.
    CALL FUNCTION 'MATERIAL_READ'
         EXPORTING
              schluessel = mtcom
         IMPORTING
              matdaten   = marc
              return     = mtcor
         TABLES
              seqmat01   = dummy
         EXCEPTIONS
              OTHERS     = 1.
    IF         sy-subrc IS INITIAL
       AND NOT marc-ausme IS INITIAL.
      MOVE marc-ausme TO l_meins.
    ELSE.
* Basismengeneinheit in Mara lesen
      REFRESH xmara.
      CLEAR   xmara.
*   Das lesen der MARA geschieht mittels Funktionsbaustein
*   MARA_single_read
      CALL FUNCTION 'MARA_SINGLE_READ'
           EXPORTING
                matnr  = l_matnr
           IMPORTING
                wmara  = xmara
           EXCEPTIONS
                OTHERS = 5.

      IF sy-subrc IS INITIAL.
        MOVE xmara-meins TO l_meins.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
* Petra Pfaff: end

*----  Lesen der Werkstabelle zum ermitteln des Werkstextes         ---*
FORM werk_lesen USING lsw_werks.
  SELECT SINGLE * FROM t001w WHERE werks = lsw_werks.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001 WITH '001W' lsw_werks space space.
  ENDIF.
  PERFORM bwkey_lesen USING lsw_werks.
ENDFORM.

*----  Lesen des Bewertungs- und Buchungskreises                    ---*
FORM bwkey_lesen USING lsw_werks.
  SELECT SINGLE * FROM t001k WHERE bwkey = t001w-bwkey.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001 WITH '001K' t001w-bwkey space space.
  ENDIF.
  SELECT SINGLE * FROM t001 WHERE bukrs = t001k-bukrs.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001 WITH '001' t001k-bwkey space space.
  ENDIF.
ENDFORM.

*----  Lesen des Materialverwaltungssatzes                          ---*
FORM marv_lesen USING marvls_bukrs.
    CALL FUNCTION 'MARV_SINGLE_READ'
         EXPORTING
              bukrs      = marvls_bukrs
         IMPORTING
              wmarv      = marv
         EXCEPTIONS
              not_found  = 1
              wrong_call = 2
              OTHERS     = 3.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001 WITH 'MARV' marvls_bukrs space space.
  ENDIF.
ENDFORM.

*----  Lesen des Materialbewertungssatzes                           ---*
FORM mbew_lesen USING l_matnr l_bwkey l_bwtar.
  CLEAR mtcom.
  mtcom-kenng = 'MBEFU'.
  mtcom-matnr = l_matnr.
  mtcom-bwkey = l_bwkey.
  mtcom-bwtar = l_bwtar.
  mtcom-nomus = x.
  CALL FUNCTION 'MATERIAL_READ'
       EXPORTING
            schluessel = mtcom
       IMPORTING
            matdaten   = mbefu
            return     = mtcor
       TABLES
            seqmat01   = dummy.
  IF mtcor-rmbew NE space.
    MESSAGE e001 WITH 'MBEW' l_matnr l_bwkey space.
  ENDIF.
ENDFORM.

*--------------- Lesen Materialbewertungssatz mit Messagehandling --*
FORM mbew_lesen_rc USING l_matnr l_bwkey l_bwtar l_rc.
  CLEAR mtcom.
  mtcom-kenng = 'MBEFU'.
  mtcom-matnr = l_matnr.
  mtcom-bwkey = l_bwkey.
  mtcom-bwtar = l_bwtar.
  mtcom-nomus = x.
  CALL FUNCTION 'MATERIAL_READ'
       EXPORTING
            schluessel = mtcom
       IMPORTING
            matdaten   = mbefu
            return     = mtcor
       TABLES
            seqmat01   = dummy.
  IF mtcor-rmbew NE space.
    l_rc = 4.
  ENDIF.
ENDFORM.

*----  Ermitteln des Inventurdifferenzwertes über SAPLMBGB          ---*
FORM wert_ermitteln.
  DATA: betrag TYPE f.
* &006 begin: fehler bei Lieferantenkonsi
  IF iikpf-sobkz NE k.
* &006 end
    CASE mbefu-vprsv.
      WHEN s.
        IF yiseg-menge < yiseg-buchm.
          IF yiseg-xruem IS INITIAL.
            PERFORM wertermittlung_s_abgang(saplmbgb) USING
                                                      mbefu-salk3
                                                      mbefu-stprs
                                                      mbefu-lbkum
                                                      mbefu-peinh
                                                      yiseg-difmg
                                                      betrag.
          ELSE.
            PERFORM wertermittlung_s_abgang(saplmbgb) USING
                                                          mbefu-vmsal
                                                          mbefu-vmstp
                                                          mbefu-vmkum
                                                          mbefu-vmpei
                                                          yiseg-difmg
                                                          betrag.
          ENDIF.
        ELSE.
          IF yiseg-xruem IS INITIAL.
            PERFORM wertermittlung_s_zugang(saplmbgb) USING
                                                      mbefu-stprs
                                                      mbefu-peinh
                                                      yiseg-difmg
                                                      betrag.
          ELSE.
            PERFORM wertermittlung_s_zugang(saplmbgb) USING
                                                      mbefu-vmstp
                                                      mbefu-vmpei
                                                      yiseg-difmg
                                                      betrag.
          ENDIF.
        ENDIF.
      WHEN v.
        IF yiseg-xruem IS INITIAL.
          PERFORM wa_v_errechnen(saplmbgb) USING mbefu-salk3
                                                 mbefu-verpr
                                                 mbefu-lbkum
                                                 mbefu-peinh
                                                 yiseg-difmg
                                                 betrag.
        ELSE.
          PERFORM wa_v_errechnen(saplmbgb) USING mbefu-vmsal
                                                 mbefu-vmver
                                                 mbefu-vmkum
                                                 mbefu-vmpei
                                                 yiseg-difmg
                                                 betrag.
        ENDIF.
    ENDCASE.
  ELSE.
    PERFORM wertermittlung_s_zugang USING
                                    mbefu-konpr
                                    mbefu-kopei
                                    yiseg-difmg
                                    betrag.
  ENDIF.
  yiseg-dmbtr = betrag.
ENDFORM.

* &006 begin: fehler bei Lieferantenkonsi
FORM wertermittlung_s_zugang USING wsz_stprs
                                   wsz_peinh
                                   wsz_menge
                                   wsz_betra.
  wsz_betra = ( wsz_menge * wsz_stprs / 1000 ) / wsz_peinh.
  IF wsz_betra > maximum.
*   MESSAGE e002 WITH 'WERTERMITTLUNG_S_ZUGANG' 'WSZ_BETRA'. "wg. TODO
    MESSAGE e002 WITH 'WERTERMITTLUNG_S_ZUGANG'.
  ENDIF.
ENDFORM.



* &006 end
*----------------- Ermitteln Bestandswerte ---------------------------*
FORM wert_ermitteln1 USING x_best
                           x_wert.
  CASE mbefu-vprsv.
    WHEN s.
      PERFORM wertermittlung_s_abgang(saplmbgb) USING
                                                mbefu-salk3
                                                mbefu-stprs
                                                mbefu-lbkum
                                                mbefu-peinh
                                                     x_best
                                                     x_wert.
    WHEN v.
      PERFORM wa_v_errechnen(saplmbgb) USING mbefu-salk3
                                             mbefu-verpr
                                             mbefu-lbkum
                                             mbefu-peinh
                                                  x_best
                                                  x_wert.
  ENDCASE.
ENDFORM.

*-------------------- Ermitteln Materialart ---------------------------*
* #005 begin: Performanceverbesserung
*FORM MTART_ERMITTELN USING MATNR WERKS .
FORM mtart_ermitteln USING matnr werks bwkey.
* SELECT SINGLE * FROM MARA WHERE MATNR = MATNR.
  REFRESH  xmara.
  CLEAR mtcom.
  MOVE: matnr        TO mtcom-matnr,
        'MARA'       TO mtcom-kenng,
        sy-langu     TO mtcom-spras.
  CALL FUNCTION 'MATERIAL_READ'
       EXPORTING
            schluessel = mtcom
       IMPORTING
            matdaten   = xmara
       TABLES
            seqmat01   = dummy
       EXCEPTIONS
            OTHERS     = 01.
* #005 end
* #004 begin: CSP-Meldung: auch bei gelöschten Materialien soll eine
*             Weiterverarbeitung funktionieren
  IF sy-subrc EQ 0.
* #004 end
* #005 begin: Performanceverbesserung
* SELECT SINGLE * FROM V134W WHERE WERKS = WERKS
*                            AND   MTART = MARA-MTART.
    SELECT SINGLE * FROM t134m WHERE bwkey = bwkey
                               AND   mtart = xmara-mtart.
* #005 end
* #004 begin
    IF sy-subrc NE 0.
      CLEAR t134m.
    ENDIF.
  ELSE.
    CLEAR mara.
    CLEAR t134m.
  ENDIF.
* #004 end
* #005 begin: Performanceverbesserung
  MOVE werks TO v134w.
  MOVE-CORRESPONDING t134m TO v134w.
* #005 begin: Performanceverbesserung
ENDFORM.

*-------------------- Positionstyp in Reservierungsposition prüfen ----*
FORM res_postyp_pruefen USING postp
                              kzbsf.
  SELECT SINGLE * FROM t418 WHERE postp = postp.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001 WITH 'T418' postp space space.
*   Bitte Tabelle & prüfen: Eintrag & & & ist nicht vorhanden
  ENDIF.
  kzbsf = t418-kzbsf.
ENDFORM.

*eject

* &002 Begin:  CSP.Meldung bearbeitet: Datum der letzen Inventur wurde
*              nicht gefüllt. Material muß gelesen werden


*---------------------------------------------------------------------*
*       FORM MATERIAL_LESEN                                           *
*---------------------------------------------------------------------*
*       Der Materialstamm wird gelesen mit allen abhängigen Segmenten.*
*---------------------------------------------------------------------*
FORM material_lesen .

  CLEAR mtcom.
  MOVE: yiseg-matnr TO mtcom-matnr,
        'MBEFU'    TO mtcom-kenng,
        sy-langu   TO mtcom-spras,
        ikpf-werks TO mtcom-werks,
        ikpf-lgort TO mtcom-lgort.
  IF NOT yiseg-charg IS INITIAL.
    MOVE yiseg-charg TO mtcom-charg.
  ENDIF.
  CASE ikpf-sobkz.
    WHEN e.
      mtcom-sobkz = ikpf-sobkz.
      mtcom-vbeln = yiseg-kdauf.
      mtcom-posnr = yiseg-kdpos.
    WHEN k.
      mtcom-sobkz = ikpf-sobkz.
      mtcom-lifnr = yiseg-lifnr.
    WHEN m.
      mtcom-sobkz = ikpf-sobkz.
      mtcom-lifnr = yiseg-lifnr.
    WHEN o.
      mtcom-sobkz = ikpf-sobkz.
      mtcom-lifnr = yiseg-lifnr.
    WHEN q.
      mtcom-sobkz = ikpf-sobkz.
      mtcom-pspnr = yiseg-ps_psp_pnr.
    WHEN v.
      mtcom-sobkz = ikpf-sobkz.
      mtcom-kunnr = yiseg-kunnr.
    WHEN w.
      mtcom-sobkz = ikpf-sobkz.
      mtcom-kunnr = yiseg-kunnr.
  ENDCASE.
  mtcom-xvkbw = t001k-xvkbw.


  CALL FUNCTION 'MATERIAL_READ'
       EXPORTING
            schluessel = mtcom
       IMPORTING
            matdaten   = mbefu
            return     = mtcor
       TABLES
            seqmat01   = dummy.

ENDFORM.

* PFAFFP: begin - Bei gelöschtem werk keinen Abbruch
*----  Lesen der Werkstabelle zum ermitteln des Werkstextes
FORM lesen_werk USING lsw_werks.
  SELECT SINGLE * FROM t001w WHERE werks = lsw_werks.
  IF NOT sy-subrc IS INITIAL.
    EXIT.
  ELSE.
    PERFORM lesen_bwkey USING lsw_werks.
  ENDIF.
ENDFORM.

*----  Lesen des Bewertungs- und Buchungskreises
FORM lesen_bwkey USING lsw_werks.
  SELECT SINGLE * FROM t001k WHERE bwkey = t001w-bwkey.
  IF NOT sy-subrc IS INITIAL.
    EXIT.
  ELSE.
    SELECT SINGLE * FROM t001 WHERE bukrs = t001k-bukrs.
    IF NOT sy-subrc IS INITIAL.
      EXIT.
    ENDIF.
  ENDIF.
ENDFORM.
* end






*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  DATUM_LETZTE_INV
*&---------------------------------------------------------------------*
FORM datum_letzte_inv.
  CASE ikpf-sobkz.
    WHEN e.
      IF NOT mbefu-kadll IS INITIAL AND
         mbefu-kadll NE space.
        ydm07i-dlinl = mbefu-kadll.
      ENDIF.
    WHEN k.
      IF NOT mbefu-kodll IS INITIAL AND
         mbefu-kodll NE space.
        ydm07i-dlinl = mbefu-kodll.
      ENDIF.
    WHEN m.
      IF NOT mbefu-kodll IS INITIAL AND
         mbefu-kodll NE space.
        ydm07i-dlinl = mbefu-kodll.
      ENDIF.
    WHEN o.
      IF NOT mbefu-lbdll IS INITIAL AND
         mbefu-lbdll NE space.
        ydm07i-dlinl = mbefu-lbdll.
      ENDIF.
    WHEN q.
      IF NOT mbefu-prdll IS INITIAL AND
         mbefu-prdll NE space.
        ydm07i-dlinl = mbefu-prdll.
      ENDIF.
    WHEN v.
      IF NOT mbefu-kudll IS INITIAL AND
         mbefu-kudll NE space.
        ydm07i-dlinl = mbefu-kudll.
      ENDIF.
    WHEN w.
      IF NOT mbefu-kudll IS INITIAL AND
         mbefu-kudll NE space.
        ydm07i-dlinl = mbefu-kudll.
      ENDIF.
    WHEN OTHERS.
      IF yiseg-charg IS INITIAL.
        IF NOT mbefu-dlinl IS INITIAL AND
           mbefu-dlinl NE space.
          ydm07i-dlinl = mbefu-dlinl.
        ENDIF.
      ELSE.
        IF NOT mbefu-chdll IS INITIAL AND
           mbefu-chdll NE space.
          ydm07i-dlinl = mbefu-chdll.
        ENDIF.
      ENDIF.
  ENDCASE.

ENDFORM.                               " DATUM_LETZTE_INV
* &002 end
