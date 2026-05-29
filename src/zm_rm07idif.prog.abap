REPORT zm_rm07idif MESSAGE-ID m7 NO STANDARD PAGE HEADING LINE-SIZE 136.

* wrong display of difference amount  June 10th 2002 MM     "n526509
* bugs fixed who were reported by the ext. program check    "n526509

*----------------------------------------------------------------------*
* the structure of "KOPF_ITAB" does not match the structure
* of table ITAB with the field catalogue
*----------------------------------------------------------------------*


*---- Include-Reports -------------------------------------------------*
INCLUDE mm07mabc.
INCLUDE rm07maut.
*INCLUDE RM07MSQL.
INCLUDE zm_rm07msql.
INCLUDE rm07musr.
INCLUDE rm07mend.

*---- Datendefinition -------------------------------------------------*

*---- Externe Tabellen ------------------------------------------------*
TABLES: iseg,
        rm07i,
        mcha,
        tcurm,
        tcurx,
        vm07i,
        meico, meicr, meprck, eina, eine, mepro,
        t003, t001a, t158, konp.
* Type-pool enthält Feldkatalogstruktur
TYPE-POOLS:  kkblo.

* Konstante für den Transaktionscode der Inventurliste
CONSTANTS: c_inventurliste LIKE sy-tcode VALUE 'MI24'.
DATA: g_pi_list TYPE c.                                     "497534

* Interne Tabelle für Feldkatalog
DATA: itab TYPE slis_t_fieldcat_alv.   " Für Inventurdifferenzen
DATA: itab2 TYPE slis_t_fieldcat_alv.  " Für nicht ausbuchbare Belege

* Kopfzeile zum Feldkatalog
*DATA: KOPF_ITAB TYPE KKBLO_FIELDCAT.
*DATA: KOPF_ITAB2 TYPE KKBLO_FIELDCAT.
* new type for header lines of field catalogue              "XJD
DATA : kopf_itab             TYPE  slis_fieldcat_alv,       "XJD
       kopf_itab2            TYPE  slis_fieldcat_alv.       "XJD

* Layout der Tabelle
DATA: itab_layout TYPE slis_layout_alv." Für Inventurdifferenzen
DATA: itab_layout2 TYPE slis_layout_alv.  " Für nicht ausbuchbare Bele
DATA: is_print TYPE slis_print_alv.    "Druckparameter

DATA: gs_keyinfo TYPE kkblo_keyinfo.
* Special groups
DATA: gruppen TYPE slis_t_sp_group_alv WITH HEADER LINE.

* Anzeigevarianten
DATA: gx_variant LIKE disvariant,
      g_variant  LIKE disvariant,
      g_exit(1) TYPE c,
      g_save(1) TYPE c,
      g_default(1) TYPE c.

* Header für Liste
DATA: xheader TYPE kkblo_t_listheader WITH HEADER LINE.
* Header für Liste der nicht mehr ausbuchbaren Belege
DATA: xheader2 TYPE kkblo_t_listheader WITH HEADER LINE.

*--- Variablen --------------------------------------------------------*
DATA: h_bwkey    LIKE t001w-bwkey,
      h_xvkbw    LIKE t001k-xvkbw,
      h_xruem,
      blank(256) TYPE c VALUE ' ',
      exponent   TYPE i,
      x_intensified TYPE c,
      x_selkz    TYPE c,
      y_selkz    TYPE c,
      v_head(4)  TYPE c,
      v_rest     LIKE sy-linno,
      kenng(5)   TYPE c VALUE 'IIKPF',
      index_l    LIKE sy-tabix,
      index_s    LIKE sy-tabix,
      meins      LIKE iseg-meins,
      waers      LIKE iseg-waers,
      refe1      LIKE rm07i-swert,
      iwert      LIKE rm07i-swert,
      betrag      TYPE f,
      iblnr_old  LIKE iseg-iblnr.
DATA: delorg(1)   TYPE c,
      delwerk     LIKE iseg-werks.
DATA: ekorg      LIKE meico-ekorg,
      mi10       LIKE t158-tcode VALUE 'MI10',
      fw_betrag  TYPE f,
      kurst LIKE t003-kurst.

*--- Interne Tabelle für nicht ausbuchbare Belege ---------------------*
DATA: BEGIN OF bel OCCURS 50,
        iblnr LIKE iseg-iblnr,
        werks LIKE iseg-werks,
        lgort LIKE iseg-lgort,
        gjahr LIKE iseg-gjahr,
        bldat LIKE ikpf-bldat,
        budat LIKE ikpf-budat,
        sperr LIKE ikpf-sperr,
        zstat LIKE ikpf-zstat,
        dstat LIKE ikpf-dstat,
      END OF bel.

DATA: BEGIN OF ywerks OCCURS 0,
        werks LIKE iseg-werks,
        lgort LIKE iseg-lgort,
      END OF ywerks.

DATA: BEGIN OF yiblnr OCCURS 0,
        iblnr LIKE iseg-iblnr,
        werks LIKE iseg-werks,
        lgort LIKE iseg-lgort,
        sobkz LIKE iseg-sobkz,
        buper LIKE am07m-buper,
        invnu LIKE ikpf-invnu,
      END OF yiblnr.

*------- Interne Tabelle für Inventurbelegpositionsdaten --------------*
DATA: BEGIN OF xiseg OCCURS 100.
        INCLUDE STRUCTURE iseg.
DATA: END OF xiseg.

*----- Strukturen fuer KEY's zum direkten Lesen interner Tabellen -----*
DATA: BEGIN OF ikpf_key,
        mandt LIKE sy-mandt,
        iblnr LIKE ikpf-iblnr,
        gjahr LIKE ikpf-gjahr,
      END OF ikpf_key.

DATA: BEGIN OF makt_key,
        mandt LIKE sy-mandt,
        matnr LIKE makt-matnr,
      END OF makt_key.

DATA: BEGIN OF bel_key,
        iblnr LIKE ikpf-iblnr,
        werks LIKE ikpf-werks,
        lgort LIKE ikpf-lgort,
      END OF bel_key.

* Tabelle mit key der ISEG zur Übergabe an die Online-Transaktionen
* (Navigationsreport)
DATA: iseg_sel LIKE STANDARD TABLE OF iseg_sel WITH HEADER LINE.
DATA: g_exit_by_user TYPE slis_exit_by_user.

*------- Tabelle Prefetch Materialstamm                       --------*
DATA: BEGIN OF prefetch03 OCCURS 20.
        INCLUDE STRUCTURE pre03.
DATA: END OF prefetch03.
DATA: BEGIN OF prefetch09 OCCURS 20.
        INCLUDE STRUCTURE pre09.
DATA: END OF prefetch09.
DATA: BEGIN OF prefetch01 OCCURS 20.
        INCLUDE STRUCTURE pre01.
DATA: END OF prefetch01.
DATA: BEGIN OF g_prefetch_mcha OCCURS 10,
        matnr LIKE mcha-matnr,
        werks LIKE mcha-werks,
        charg LIKE mcha-charg,
      END OF g_prefetch_mcha.
DATA: BEGIN OF g_t_mcha_bwtar OCCURS 10,
        matnr LIKE mcha-matnr,
        werks LIKE mcha-werks,
        charg LIKE mcha-charg,
        bwtar LIKE mcha-bwtar.
DATA: END OF g_t_mcha_bwtar.

* Indices fuer haeppchenweise Verarbeitung der XISEG (fuer sehr
* grosse Datenmengen notwendig!)
DATA: g_first_index LIKE sy-tabix.
DATA: g_last_index LIKE sy-tabix.
DATA: g_anzahl TYPE i.
DATA: g_width TYPE i.

*---- Parameter       -------------------------------------------------*
SELECT-OPTIONS sobkz FOR iseg-sobkz.
SELECT-OPTIONS gjahr FOR iseg-gjahr.
SELECT-OPTIONS zldat FOR iseg-zldat.
SELECT-OPTIONS gidat FOR ikpf-gidat.
SELECT-OPTIONS xblni FOR ikpf-xblni.
SELECT-OPTIONS grund FOR iseg-grund.
PARAMETER iiwert LIKE rm07i-swert.
SELECTION-SCREEN SKIP.

* Variante
SELECTION-SCREEN BEGIN OF BLOCK 0 WITH FRAME TITLE text-064.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK 0.

* Teilbild "Listumfang"------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-060.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_leinf RADIOBUTTON GROUP list LIKE am07m-leinf
            DEFAULT 'X'.
SELECTION-SCREEN COMMENT 3(50) text-061 FOR FIELD p_leinf.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_lwerk RADIOBUTTON GROUP list LIKE am07m-leinf.
SELECTION-SCREEN COMMENT 3(50) text-062 FOR FIELD p_lwerk.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_libnr RADIOBUTTON GROUP list LIKE am07m-leinf.
SELECTION-SCREEN COMMENT 3(50) text-063 FOR FIELD p_libnr.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b1.

* Parameter für Transaktionscode bei Varianten     "497534
PARAMETERS: p_tcode LIKE sy-tcode  NO-DISPLAY.              "497534

*--- Feldleiste für Darstellung Buchungsperiode -----------------------*
DATA: BEGIN OF buper,
        monat LIKE ikpf-monat,
        punkt VALUE '.',
        gjahr LIKE ikpf-gjahr,
      END OF buper.

*---- Initialisierung -------------------------------------------------*
INITIALIZATION.
  CLEAR: im_selp1,
         im_selp3,
         im_selp4,
         im_selp5,
         im_selp6.
  im_selb1 = im_selb2 = im_selb3 = x.

* begin insert 497534
  IF sy-tcode = 'ZMI20' OR sy-tcode = c_inventurliste.
    p_tcode = sy-tcode.
  ENDIF.
  CLEAR  g_pi_list.
  IF sy-tcode NE 'ZMI20'.
    IF sy-tcode = c_inventurliste OR p_tcode = c_inventurliste.
      g_pi_list = 'X'.
    ENDIF.
  ENDIF.
* end insert 497534

* Inventurliste: auch nichtgezählte und ausgebuchte zeigen
*  IF sy-tcode = c_inventurliste.              " 497534
  IF g_pi_list = 'X'.                                       " 497534
    im_selp1 = im_selp3 = x.
  ENDIF.

  g_save = 'A'.
* Menütitel in Abhängigkeit vom Transaktionscode setzen (wegen
* Navigationsliste)
*  IF sy-tcode = c_inventurliste.              " 497534
  IF g_pi_list = 'X'.                                       " 497534
    SET TITLEBAR '200'.
  ENDIF.
  PERFORM variant_init.
* Get default variant
  gx_variant = g_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = g_save
    CHANGING
      cs_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    p_vari = gx_variant-variant.
  ENDIF.

* Process on value request
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_for_variant.

* PAI
AT SELECTION-SCREEN.
  PERFORM pai_of_selection_screen.
* Prüfen, ob Selektionskriterien eingeschränkt wurden.

  IF im_matnr IS INITIAL AND
     im_werks IS INITIAL AND
     im_lgort IS INITIAL AND
     im_charg IS INITIAL AND
     im_iblnr IS INITIAL AND
     im_invnu IS INITIAL AND
     sobkz IS INITIAL  AND
     gjahr IS INITIAL  AND
     zldat IS INITIAL  AND
     gidat IS INITIAL  AND
     grund IS INITIAL.
    MESSAGE w689.
  ENDIF.

*---- Beginn der Verarbeitung -----------------------------------------*
START-OF-SELECTION.
* begin insert note 497534
  IF sy-tcode NE 'ZMI20'.
    IF sy-tcode = c_inventurliste OR p_tcode = c_inventurliste.
      g_pi_list = 'X'.
    ENDIF.
  ENDIF.
* end insert note 497534

  CLEAR no_chance.
* Menütitel in Abhängigkeit vom Transaktionscode setzen (wegen
* Navigationsliste)
*  IF sy-tcode = c_inventurliste.              " 497534
  IF g_pi_list = 'X'.                                       " 497534
    SET TITLEBAR '200'.
  ELSE.
    SET TITLEBAR '100'.
  ENDIF.
  REFRESH iikpf.
  CLEAR delorg.
  CLEAR delwerk.
  SELECT SINGLE * FROM tcurm.

*---- Beschaffen der Daten --------------------------------------------*
GET iseg.
  PERFORM xiseg_fuellen.

GET ikpf.
  MOVE ikpf TO iikpf.
  COLLECT iikpf.

*---- Ende der Verarbeitung -------------------------------------------*
END-OF-SELECTION.

* Verarbeitungbeginn
* haeppchenweise Verarbeitung der XISEG
  g_width       = 10000.
  g_first_index = 1.
  g_last_index  = g_width.

  PERFORM delete_unused_xisegs.

  DESCRIBE TABLE xiseg LINES g_anzahl.
  IF g_last_index > g_anzahl.
    g_last_index = g_anzahl.
  ENDIF.
  WHILE g_first_index <= g_anzahl.
    PERFORM yiseg_fuellen.
*   compute new indexes
    g_first_index = g_first_index + g_width.
    g_last_index = g_last_index + g_width.
    IF g_last_index > g_anzahl.
      g_last_index = g_anzahl.
    ENDIF.
  ENDWHILE.
  IF NOT no_chance IS INITIAL.
    MESSAGE s124.
  ENDIF.

*  Feldkatalog aufbauen
  PERFORM fieldcat_build.

*4) LAYOUT DER LISTE
  PERFORM layout.

*5)  HEADER
  PERFORM header.

  is_print-no_print_selinfos = x.    "Kein Druck der Selektionskriterien
  is_print-no_print_listinfos = x.     "Kein Druck der Datenstatistik

  IF sy-batch = x.
    is_print-print = x.
  ENDIF.


*6)  LISTAUSGABE
  IF NOT p_leinf IS INITIAL.
    PERFORM listausgabe.
  ELSEIF NOT p_lwerk IS INITIAL.
    PERFORM listausgabe2.
  ELSEIF NOT p_libnr IS INITIAL.
    PERFORM listausgabe3.
  ENDIF.

  IF g_exit_by_user-exit = x.
    LEAVE PROGRAM.
  ENDIF.

  IF sy-batch IS INITIAL.
    PERFORM neustart USING x.
  ENDIF.

*---- Formroutinen ----------------------------------------------------*

*----------------------------------------------------------------------*
*                Fromroutine, die die YISEG fuellt.                    *
*----------------------------------------------------------------------*
FORM yiseg_fuellen.
* sorts nur beim ersten Aufruf machen
  IF g_first_index = 1.
    SORT xiseg BY iblnr zeili.
    SORT iikpf BY mandt iblnr gjahr.
  ENDIF.

  PERFORM prefetch_durchfuehren.       "MARA, MARC, MAKT
  PERFORM prefetch1_durchfuehren.      "MCHA, MBEW
  CLEAR: ikpf_key.

* XISEG schrittweise verarbeiten
  LOOP AT xiseg FROM g_first_index TO g_last_index.
*   wrong display of difference amount                      "n526509
*   clear the flag for calculation using previos period     "n526509
    CLEAR                    h_xruem.                       "n526509

    CLEAR yiseg.
    MOVE-CORRESPONDING xiseg TO yiseg.
    CHECK xiseg-zldat IN zldat.
    IF ikpf_key-mandt NE xiseg-mandt OR
       ikpf_key-iblnr NE xiseg-iblnr OR
       ikpf_key-gjahr NE xiseg-gjahr.
      ikpf_key-mandt = xiseg-mandt.
      ikpf_key-iblnr = xiseg-iblnr.
      ikpf_key-gjahr = xiseg-gjahr.
      READ TABLE iikpf WITH KEY ikpf_key BINARY SEARCH.
    ENDIF.
    CHECK iikpf-gidat IN gidat.
    CHECK iikpf-xblni IN xblni.
    MOVE iikpf-xblni TO yiseg-xblni.
    MOVE iikpf-invnu TO yiseg-invnu.
    ON CHANGE OF xiseg-matnr.
      PERFORM kurztext_lesen USING yiseg-matnr.
    ENDON.
    MOVE makt-maktx TO yiseg-maktx.
    PERFORM t064t_lesen.
    yiseg-stext = t064t-stext.
    ON CHANGE OF iikpf-iblnr.
      MOVE makt-maktx TO yiseg-maktx.
      ON CHANGE OF iikpf-werks.
        CLEAR delwerk.
        PERFORM lesen_werk  USING yiseg-werks.
        IF NOT sy-subrc IS INITIAL.
          IF delorg IS INITIAL.
            MESSAGE s239.
          ENDIF.
          delorg = 'X'.
          MOVE yiseg-werks TO delwerk.
          CONTINUE.
        ENDIF.
        SELECT SINGLE * FROM tcurx WHERE currkey = t001-waers.
        IF sy-subrc = 0.
          exponent = tcurx-currdec.
        ELSE.
          exponent = 2.
        ENDIF.
        exponent = exponent - 2.
        IF exponent NE 0.
          iwert = iiwert * ( EXP( exponent * LOG( 10 ) ) ).
        ELSE.
          iwert = iiwert.
        ENDIF.
        h_bwkey = t001w-bwkey.
        h_xvkbw = t001k-xvkbw.
      ELSE.
        IF delwerk EQ yiseg-werks.
          CONTINUE.
        ENDIF.
      ENDON.
      PERFORM marv_lesen USING t001k-bukrs.

*---- Beleg ist noch nicht komlett ausgebucht aber begonnen zu zählen
*     IF IIKPF-DSTAT NE X AND IIKPF-LSTAT IS INITIAL
*                         AND NOT IIKPF-ZSTAT IS INITIAL.
      IF iikpf-dstat NE x AND NOT iikpf-zstat IS INITIAL."JHM note190378
        IF iikpf-gjahr NE marv-lfgja OR iikpf-monat NE marv-lfmon.
          IF iikpf-gjahr EQ marv-vmgja AND iikpf-monat EQ marv-vmmon.
            h_xruem = x.
          ELSE.
            MOVE-CORRESPONDING yiseg TO bel.
            MOVE-CORRESPONDING iikpf TO bel.
            MOVE-CORRESPONDING t001w TO bel.
            COLLECT bel.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      IF delwerk EQ yiseg-werks.
        CONTINUE.
      ENDIF.
    ENDON.

    yiseg-waers = t001-waers.
    yiseg-monat = iikpf-monat.
    yiseg-bwkey = h_bwkey.
    yiseg-xruem = h_xruem.
    yiseg-xvkbw = h_xvkbw.
    buper-monat = yiseg-monat.
    buper-gjahr = yiseg-gjahr.
    MOVE buper TO yiseg-buper.
    IF yiseg-kwart IS INITIAL.
      PERFORM bstar_lesen USING yiseg-bstar.
    ELSE.
      CLEAR t064b.
    ENDIF.
    yiseg-btext = t064b-btext.
    PERFORM marc_lesen USING yiseg-matnr yiseg-werks.
    IF NOT marc-bwtty IS INITIAL.
      PERFORM mcha_lesen USING yiseg-matnr yiseg-werks yiseg-charg.
      IF sy-subrc EQ 0.
        yiseg-bwtar = mcha-bwtar.
      ENDIF.
    ENDIF.

*-- Prüfung, ob Position gezählt ist. Wenn ja, dann APPEND nur,
*   wenn IM_SELP1 nicht initial!
    IF yiseg-xzael IS INITIAL.
      CHECK NOT im_selp1 IS INITIAL.
    ELSE.
      PERFORM mtart_ermitteln USING yiseg-matnr yiseg-werks yiseg-bwkey.
      IF v134w-wertu = x AND yiseg-xdiff IS INITIAL
         AND yiseg-xnzae IS INITIAL.
        IF iikpf-sobkz NE k AND iikpf-sobkz NE o AND      "note 0452092
           iikpf-sobkz NE v AND iikpf-sobkz NE w.         "note 0452092
          PERFORM mbew_lesen_l                            "note 0188316
            USING yiseg-matnr yiseg-bwkey yiseg-bwtar yiseg-xruem
                  yiseg-sobkz yiseg-kdauf yiseg-kdpos yiseg-ps_psp_pnr.
        ELSE.
          MOVE-CORRESPONDING iikpf TO ikpf.
          PERFORM material_lesen.
        ENDIF.
      ENDIF.
      IF yiseg-kwart IS INITIAL.
        yiseg-difmg = yiseg-menge - yiseg-buchm.
        CLEAR yiseg-difvw.
      ELSE.
        yiseg-difvw = yiseg-exvkw - yiseg-buchw.
        CLEAR yiseg-difmg.
      ENDIF.

*---- Prüfen auf Differenzmenge
      IF NOT yiseg-difmg IS INITIAL  OR  NOT yiseg-kwart IS INITIAL.
        IF yiseg-dmbtr IS INITIAL.
          IF yiseg-xdiff IS INITIAL.
            IF v134w-wertu = x.
              IF iikpf-sobkz = k AND NOT tcurm-konsi IS INITIAL.
                PERFORM wert_aus_infosatz.
              ELSEIF NOT yiseg-kwart IS INITIAL.
                PERFORM wertermittlung_wart USING mbefu-matnr
                                                  mbefu-bwkey
                                                  mbefu-bwtar
                                                  mbefu-salk3
                                                  mbefu-vksal
                                                  yiseg-exvkw
                                                  yiseg-difvw
                                                  mbefu-bwspa
                                         CHANGING yiseg-dmbtr.
              ELSE.
                PERFORM wert_ermitteln.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          IF yiseg-difmg < 0 AND yiseg-dmbtr > 0            " 350889
             AND yiseg-kwart IS INITIAL.                    " 350889
            yiseg-dmbtr = yiseg-dmbtr * -1.                 " 350889
          ENDIF.                                            " 350889
          IF yiseg-difvw < 0 AND yiseg-dmbtr > 0            " 350889
             AND NOT yiseg-kwart IS INITIAL.                " 350889
            yiseg-dmbtr = yiseg-dmbtr * -1.                 " 350889
          ENDIF.                                            " 350889
        ENDIF.
        IF yiseg-dmbtr < 0.
          MOVE yiseg-dmbtr TO yiseg-ndifw.
          refe1 = yiseg-dmbtr * -1.
        ELSE.
          MOVE yiseg-dmbtr TO yiseg-pdifw.
          refe1 = yiseg-dmbtr.
        ENDIF.
*        YISEG-DMBTR = ABS( YISEG-DMBTR ).
      ELSE.
        CLEAR yiseg-dmbtr.
        CLEAR refe1.
      ENDIF.

*---- Schwellenwertprüfung
      IF NOT iwert IS INITIAL.
        CHECK refe1 GE iwert.
      ENDIF.
    ENDIF.
    PERFORM lvs_pruefen.

    CLEAR: yiseg-kbetr.
    SELECT SINGLE kbetr INTO yiseg-kbetr
    FROM konp INNER JOIN a510
    ON konp~knumh = a510~knumh AND
       konp~kappl = a510~kappl AND
       konp~kschl = a510~kschl
    WHERE a510~matnr = yiseg-matnr AND
          a510~kappl = 'V'         AND
          a510~kschl = 'ZN01'      AND
          a510~datab <= sy-datum   AND
          a510~datbi >= sy-datum.

    DATA : lv_kbetr   TYPE konp-kbetr.
    CLEAR lv_kbetr.
    SELECT SINGLE kbetr
      FROM konp JOIN a567 ON  konp~knumh = a567~knumh
                          AND konp~kappl = a567~kappl
                          AND konp~kschl = a567~kschl
      INTO lv_kbetr
      WHERE a567~kappl = 'V'
        AND a567~kschl = 'ZN01'
        AND a567~vkbur = yiseg-werks
        AND a567~matnr = yiseg-matnr
        AND a567~datab <= sy-datum
        AND a567~datbi >= sy-datum.

    DATA: l_kbetr TYPE p DECIMALS 2.

    l_kbetr = ( yiseg-menge - yiseg-buchm ) * yiseg-kbetr.

    IF yiseg-kbetr <> 0 AND
      lv_kbetr <> 0.
      l_kbetr = ( yiseg-menge - yiseg-buchm ) * lv_kbetr.
    ENDIF.

    yiseg-kbetr = l_kbetr / 1000.

    APPEND yiseg.
    CLEAR: l_kbetr.
  ENDLOOP.
ENDFORM.                    "YISEG_FUELLEN


*----------------------------------------------------------------------*
* Formroutine, die die in der ISEG selektierten Saetze in die XISEG    *
* schreibt.                                                            *
*----------------------------------------------------------------------*
FORM xiseg_fuellen.
  CLEAR: auth03, auth04.
  PERFORM inventur_db USING actvt03
                            iseg-werks.
  IF no_chance IS INITIAL.
    IF NOT auth03 IS INITIAL.
      no_chance = x.
    ENDIF.
  ENDIF.
  CHECK auth03 IS INITIAL.
  PERFORM inventur_db USING actvt04
                            iseg-werks.
  IF no_chance IS INITIAL.
    IF NOT auth04 IS INITIAL.
      no_chance = x.
    ENDIF.
  ENDIF.
  CHECK auth04 IS INITIAL.
  CHECK iseg-gjahr IN gjahr.
  CHECK iseg-sobkz IN sobkz.
  CHECK iseg-grund IN grund.
* Schwellenwert ne 0 und Differenzmenge=0? Dann Position raus
  IF NOT iiwert IS INITIAL.
    IF iseg-kwart IS INITIAL.
      CHECK iseg-menge NE iseg-buchm.
    ELSE.
      CHECK iseg-exvkw NE iseg-buchw.
    ENDIF.
  ENDIF.
  MOVE-CORRESPONDING iseg TO xiseg.
  ON CHANGE OF iseg-iblnr.
    xkopf-belnr = iseg-iblnr.
    APPEND xkopf.
  ENDON.
  ON CHANGE OF iseg-matnr.
    xmatn-matnr = iseg-matnr.
    APPEND xmatn.
  ENDON.
  APPEND xiseg.
ENDFORM.                    "XISEG_FUELLEN

*-------------------- Ermitteln Materialstamm C-Segment ---------------*
FORM marc_lesen USING matnr werks.
  CLEAR marc.
  CLEAR mtcom.
  mtcom-kenng = 'MARC'.
  mtcom-matnr = matnr.
  mtcom-werks = werks.
  mtcom-nomus = x.
  CALL FUNCTION 'MATERIAL_READ'
    EXPORTING
      schluessel = mtcom
    IMPORTING
      matdaten   = marc
      return     = mtcor
    TABLES
      seqmat01   = dummy
    EXCEPTIONS                                              "491671
      OTHERS     = 4.                                       "491671
* Note 491671
* It seems useless to issue an error message during a list report.
* Errors regarding material should not prevent showing the list.
  IF sy-subrc <> 0.                                         "491671
    sy-subrc = sy-subrc.                                    "491671
  ENDIF.                                                    "491671

ENDFORM.                    "MARC_LESEN

*-------------------- Ermitteln Chargen -------------------------------*
FORM mcha_lesen USING matnr werks charg.
  READ TABLE g_t_mcha_bwtar WITH KEY matnr = matnr
                                     werks = werks
                                     charg = charg
                            BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    CLEAR mcha.
    mcha-matnr = matnr.
    mcha-werks = werks.
    mcha-charg = charg.
    mcha-bwtar = g_t_mcha_bwtar-bwtar.
  ELSE.
    SELECT SINGLE * FROM mcha WHERE matnr = matnr
                                AND werks = werks
                                AND charg = charg.

  ENDIF.
ENDFORM.                    "MCHA_LESEN

*-------------------- Massenzugriffe -------------------------------*
FORM prefetch_durchfuehren.
  CLEAR   prefetch03.
  REFRESH prefetch03.
  CLEAR   prefetch09.
  REFRESH prefetch09.
  CLEAR   prefetch01.
  REFRESH prefetch01.
* xiseg schrittweise verarbeiten
  LOOP AT xiseg FROM g_first_index TO g_last_index.
* Prefetch für Massenzugriff MARA füllen
    MOVE-CORRESPONDING xiseg TO prefetch03.
    COLLECT prefetch03.
* Prefetch für Massenzugriff MAKT füllen
    MOVE-CORRESPONDING xiseg TO prefetch09.
    MOVE sy-langu TO prefetch09-spras.
    COLLECT prefetch09.
* Prefetch für Massenzugriff MARC füllen
    MOVE-CORRESPONDING xiseg TO prefetch01.
    COLLECT prefetch01.
  ENDLOOP.

* Massenzugriff MARA
  READ TABLE prefetch03 INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'MARA_ARRAY_READ'
      EXPORTING
        kzrfb  = 'X'             " delete buffer in each step
      TABLES
        ipre03 = prefetch03.
  ENDIF.

* Massenzugriff MAKT
  READ TABLE prefetch09 INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'MAKT_ARRAY_READ'
      EXPORTING
        kzrfb  = 'X'             " delete buffer in each step
      TABLES
        ipre09 = prefetch09.
  ENDIF.

* Massenzugriff MARC
  READ TABLE prefetch01 INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'MARC_ARRAY_READ'
      EXPORTING
        kzrfb  = 'X'             " delete buffer in each step
      TABLES
        ipre01 = prefetch01.
  ENDIF.
ENDFORM.                    "PREFETCH_DURCHFUEHREN



*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM fieldcat_build.
  CLEAR kopf_itab.
  kopf_itab-fieldname = 'BOX'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'DM07I'.
  kopf_itab-ref_fieldname = 'XSELZ'.
  kopf_itab-col_pos = '1'.
  APPEND kopf_itab TO itab.

  IF NOT p_libnr IS INITIAL.
    CLEAR kopf_itab.
    kopf_itab-fieldname = 'IBLNR'.
    kopf_itab-tabname = 'YIBLNR'.
    kopf_itab-ref_tabname = 'ISEG'.
    kopf_itab-col_pos = '1'.
    APPEND kopf_itab TO itab.
  ELSE.
    CLEAR kopf_itab.
    kopf_itab-fieldname = 'IBLNR'.
    kopf_itab-tabname = 'YISEG'.
    kopf_itab-ref_tabname = 'ISEG'.
    kopf_itab-key = 'X'.
    kopf_itab-col_pos = '1'.
    APPEND kopf_itab TO itab.
  ENDIF.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'ZEILI'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-key = 'X'.
  kopf_itab-col_pos = '2'.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'MATNR'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-col_pos = '3'.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'CHARG'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-col_pos = '4'.
  APPEND kopf_itab TO itab.

  IF NOT p_lwerk IS INITIAL.
    CLEAR kopf_itab.
    kopf_itab-fieldname = 'WERKS'.
    kopf_itab-tabname = 'YWERKS'.
    kopf_itab-ref_tabname = 'ISEG'.
    kopf_itab-col_pos = '5'.
    APPEND kopf_itab TO itab.
  ELSEIF NOT p_leinf IS INITIAL.
    CLEAR kopf_itab.
    kopf_itab-fieldname = 'WERKS'.
    kopf_itab-tabname = 'YISEG'.
    kopf_itab-ref_tabname = 'ISEG'.
    kopf_itab-col_pos = '5'.
    APPEND kopf_itab TO itab.
  ELSEIF NOT p_libnr IS INITIAL.
    CLEAR kopf_itab.
    kopf_itab-fieldname = 'WERKS'.
    kopf_itab-tabname = 'YIBLNR'.
    kopf_itab-ref_tabname = 'ISEG'.
    kopf_itab-col_pos = '2'.
    APPEND kopf_itab TO itab.
  ENDIF.

  IF NOT p_lwerk IS INITIAL.
    CLEAR kopf_itab.
    kopf_itab-fieldname = 'LGORT'.
    kopf_itab-tabname = 'YWERKS'.
    kopf_itab-ref_tabname = 'ISEG'.
    kopf_itab-col_pos = '6'.
    APPEND kopf_itab TO itab.
  ELSEIF NOT p_leinf IS INITIAL.
    CLEAR kopf_itab.
    kopf_itab-fieldname = 'LGORT'.
    kopf_itab-tabname = 'YISEG'.
    kopf_itab-ref_tabname = 'ISEG'.
    kopf_itab-col_pos = '6'.
    APPEND kopf_itab TO itab.
  ELSEIF NOT p_libnr IS INITIAL.
    CLEAR kopf_itab.
    kopf_itab-fieldname = 'LGORT'.
    kopf_itab-tabname = 'YIBLNR'.
    kopf_itab-ref_tabname = 'ISEG'.
    kopf_itab-col_pos = '3'.
    APPEND kopf_itab TO itab.

    CLEAR kopf_itab.
    kopf_itab-fieldname = 'BUPER'.
    kopf_itab-tabname = 'YIBLNR'.
    kopf_itab-ref_tabname = 'AM07M'.
    kopf_itab-col_pos = '4'.
    APPEND kopf_itab TO itab.
  ENDIF.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'BUCHM'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-col_pos = '7'.
* Bei Navigationsliste nicht anzeigen, sondern in Liste aufnehmen
*  IF sy-tcode = c_inventurliste.              " 497534
  IF g_pi_list = 'X'.                                       " 497534
    kopf_itab-sp_group = 'M'.
    kopf_itab-no_out = 'X'.
  ENDIF.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'MENGE'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-seltext_l = text-001.
  kopf_itab-col_pos = '8'.
* Bei Navigationsliste nicht anzeigen, sondern in Liste aufnehmen
*  IF sy-tcode = c_inventurliste.              " 497534
  IF g_pi_list = 'X'.                                       " 497534
    kopf_itab-sp_group = 'M'.
    kopf_itab-no_out = 'X'.
  ENDIF.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'DIFMG'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'VM07I'.
  kopf_itab-col_pos = '9'.
* Bei Navigationsliste nicht anzeigen, sondern in Liste aufnehmen
*  IF sy-tcode = c_inventurliste.              " 497534
  IF g_pi_list = 'X'.                                       " 497534
    kopf_itab-sp_group = 'M'.
    kopf_itab-no_out = 'X'.
  ENDIF.
  APPEND kopf_itab TO itab.


  CLEAR kopf_itab.
  kopf_itab-fieldname = 'MEINS'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-col_pos = '10'.
* Bei Navigationsliste nicht anzeigen, sondern in Liste aufnehmen
*  IF sy-tcode = c_inventurliste.              " 497534
  IF g_pi_list = 'X'.                                       " 497534
    kopf_itab-sp_group = 'M'.
    kopf_itab-no_out = 'X'.
  ENDIF.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'DMBTR'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-col_pos = '11'.
  kopf_itab-cfieldname = 'WAERS'.                           " 114324
* Bei Navigationsliste nicht anzeigen, sondern in Liste aufnehmen
*  IF sy-tcode = c_inventurliste.              " 497534
  IF g_pi_list = 'X'.                                       " 497534
    kopf_itab-sp_group = 'B'.
    kopf_itab-no_out = 'X'.
  ENDIF.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'KBETR'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-reptext_ddic = '  Difference NSP'.
  kopf_itab-col_pos = '12'.
  kopf_itab-cfieldname = 'WAERS'.                           " 114324
  IF g_pi_list = 'X'.                                       " 497534
    kopf_itab-sp_group = 'B'.
    kopf_itab-no_out = 'X'.
  ENDIF.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'WAERS'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-col_pos = '13'.
* Bei Navigationsliste nicht anzeigen, sondern in Liste aufnehmen
*  IF sy-tcode = c_inventurliste.              " 497534
  IF g_pi_list = 'X'.                                       " 497534
    kopf_itab-sp_group = 'V'.
    kopf_itab-no_out = 'X'.
  ENDIF.
  APPEND kopf_itab TO itab.

  IF NOT p_libnr IS INITIAL.
    CLEAR kopf_itab.
    kopf_itab-fieldname = 'SOBKZ'.
    kopf_itab-tabname = 'YIBLNR'.
    kopf_itab-ref_tabname = 'ISEG'.
    kopf_itab-col_pos = '5'.
    APPEND kopf_itab TO itab.
  ELSE.
    CLEAR kopf_itab.
    kopf_itab-fieldname = 'SOBKZ'.
    kopf_itab-tabname = 'YISEG'.
    kopf_itab-ref_tabname = 'ISEG'.
    kopf_itab-col_pos = '14'.
    APPEND kopf_itab TO itab.
  ENDIF.


* Die folgend Felder sind über Button Anzeigevariante hinzufügbar zur
* bestehenden Liste.

* Spezialgruppe Verkaufswerte
  CLEAR kopf_itab.
  kopf_itab-fieldname = 'VKWRT'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'V'.
  kopf_itab-cfieldname = 'WAERS'.                           " 114324
  kopf_itab-no_out = 'X'.              " In der Liste enthalten.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'EXVKW'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'V'.
  kopf_itab-cfieldname = 'WAERS'.                           " 114324
  kopf_itab-no_out = 'X'.              " In der Liste enthalten.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'BUCHW'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-cfieldname = 'WAERS'.                           " 114324
  kopf_itab-sp_group = 'V'.
  kopf_itab-no_out = 'X'.              " In der Liste enthalten.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'DIFVW'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'VM07I'.
  kopf_itab-sp_group = 'V'.
  kopf_itab-cfieldname = 'WAERS'.                           " 114324
  kopf_itab-no_out = 'X'.              " In der Liste enthalten.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'KWART'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'V'.
  kopf_itab-no_out = 'X'.              " In der Liste enthalten.
  APPEND kopf_itab TO itab.

* Spezialgruppe Texte
  CLEAR kopf_itab.
  kopf_itab-fieldname = 'MAKTX'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'MAKT'.
  kopf_itab-sp_group = 'T'.            " In der Special Group T.
  kopf_itab-no_out = 'X'.              " Nicht in der Liste enthalten.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'BTEXT'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'T064B'.
* Bei Navigationsliste anzeigen, sonst nicht
*  IF sy-tcode = c_inventurliste.              " 497534
  IF g_pi_list = 'X'.                                       " 497534
    kopf_itab-col_pos = '15'.
  ELSE.
    kopf_itab-sp_group = 'T'.          " In der Special Group T.
    kopf_itab-no_out = 'X'.            " Nicht in der Liste enthalten.
  ENDIF.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'STEXT'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'T064T'.
* Bei Navigationsliste anzeigen, sonst nicht
*  IF sy-tcode = c_inventurliste.              " 497534
  IF g_pi_list = 'X'.                                       " 497534
    kopf_itab-col_pos = '13'.
  ELSE.
    kopf_itab-sp_group = 'T'.          " In der Special Group T.
    kopf_itab-no_out = 'X'.            " Nicht in der Liste enthalten.
  ENDIF.
  APPEND kopf_itab TO itab.



* Special Group Sonderbestand
  CLEAR kopf_itab.
  kopf_itab-fieldname = 'KDAUF'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'S'.            " In der Special Group S.
  kopf_itab-no_out = 'X'.              " Nicht in der Liste enthalten.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'KDPOS'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'S'.            " In der Special Group S.
  kopf_itab-no_out = 'X'.              " Nicht in der Liste enthalten.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'KDEIN'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'S'.            " In der Special Group S.
  kopf_itab-no_out = 'X'.              " Nicht in der Liste enthalten.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'LIFNR'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'S'.            " In der Special Group S.
  kopf_itab-no_out = 'X'.              " Nicht in der Liste enthalten.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'KUNNR'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'S'.            " In der Special Group S.
  kopf_itab-no_out = 'X'.              " Nicht in der Liste enthalten.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'PLPLA'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'S'.            " In der Special Group S.
  kopf_itab-no_out = 'X'.              " Nicht in der Liste enthalten.
  APPEND kopf_itab TO itab.






* Gruppe Sonstiges
* Special Group 'B'
  CLEAR kopf_itab.
  kopf_itab-fieldname = 'GRUND'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'B'.
  kopf_itab-no_out = 'X'.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'XNULL'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'B'.
  kopf_itab-no_out = 'X'.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'MBLNR'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'B'.
  kopf_itab-no_out = 'X'.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'MJAHR'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'B'.
  kopf_itab-no_out = 'X'.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'ZEILE'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-seltext_l = text-002.
  kopf_itab-sp_group = 'B'.
  kopf_itab-no_out = 'X'.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'NBLNR'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'B'.
  kopf_itab-no_out = 'X'.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'PDIFW'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'RM07I'.
  kopf_itab-sp_group = 'B'.
  kopf_itab-cfieldname = 'WAERS'.                           " 114324
  kopf_itab-no_out = 'X'.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'NDIFW'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'RM07I'.
  kopf_itab-sp_group = 'B'.
  kopf_itab-cfieldname = 'WAERS'.                           " 114324
  kopf_itab-no_out = 'X'.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'XBLNI'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'B'.
  kopf_itab-no_out = 'X'.
  APPEND kopf_itab TO itab.

  IF NOT p_libnr IS INITIAL.
    CLEAR kopf_itab.
    kopf_itab-fieldname = 'INVNU'.
    kopf_itab-tabname = 'YIBLNR'.
    kopf_itab-ref_tabname = 'IKPF'.
    kopf_itab-col_pos = '6'.
    APPEND kopf_itab TO itab.
  ELSE.
    CLEAR kopf_itab.
    kopf_itab-fieldname = 'INVNU'.
    kopf_itab-tabname = 'YISEG'.
    kopf_itab-ref_tabname = 'IKPF'.
    kopf_itab-sp_group = 'B'.
    kopf_itab-no_out = 'X'.
    APPEND kopf_itab TO itab.
  ENDIF.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'XLOEK'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'B'.
  kopf_itab-no_out = 'X'.
  APPEND kopf_itab TO itab.

  IF p_libnr IS INITIAL.
    CLEAR kopf_itab.
    kopf_itab-fieldname = 'BUPER'.
    kopf_itab-tabname = 'YISEG'.
    kopf_itab-ref_tabname = 'AM07M'.
    kopf_itab-sp_group = 'B'.          " In der Special Sonstiges
    kopf_itab-no_out = 'X'.            " Nicht in der Liste enthalten.
    APPEND kopf_itab TO itab.
  ENDIF.

* Gruppe Änderungsfelder
  CLEAR kopf_itab.
  kopf_itab-fieldname = 'USNAM'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'A'.            " In der Special Group A.
  kopf_itab-no_out = 'X'.              " Nicht in der Liste enthalten.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'AEDAT'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'A'.
  kopf_itab-no_out = 'X'.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'USNAZ'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'A'.            " In der Special Group A.
  kopf_itab-no_out = 'X'.              " Nicht in der Liste enthalten.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'ZLDAT'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'A'.
  kopf_itab-no_out = 'X'.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'USNAD'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'A'.            " In der Special Group A.
  kopf_itab-no_out = 'X'.              " Nicht in der Liste enthalten.
  kopf_itab-ddictxt = 'M'.
  APPEND kopf_itab TO itab.

  CLEAR kopf_itab.
  kopf_itab-fieldname = 'BUDAT'.
  kopf_itab-tabname = 'YISEG'.
  kopf_itab-ref_tabname = 'ISEG'.
  kopf_itab-sp_group = 'A'.
  kopf_itab-no_out = 'X'.
  APPEND kopf_itab TO itab.




* Gruppendefinition
*  'Sonderbestand'.
  gruppen-sp_group = 'S'.
  gruppen-text = text-003.
  APPEND gruppen.
* 'Verkaufswerte'.
  gruppen-sp_group = 'V'.
  gruppen-text = text-004.
  APPEND gruppen.
* 'Texte'.
  gruppen-sp_group = 'T'.
  gruppen-text = text-005.
  APPEND gruppen.
* 'Änderungsfelder'.
  gruppen-sp_group = 'A'.
  gruppen-text = text-008.
  APPEND gruppen.
* GRUPPEN-TEXT = 'Sonstige'.
  gruppen-sp_group = 'B'.
  gruppen-text = text-007.
  APPEND gruppen.
* GRUPPEN-TEXT = 'Mengenfelder'.
  gruppen-sp_group = 'M'.
  gruppen-text = text-019.
  APPEND gruppen.

  itab_layout-group_buttons = ' '.

ENDFORM.                               " FIELDCAT_BUILD

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD2
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM fieldcat_build2.
  REFRESH itab2.

  CLEAR kopf_itab2.
  kopf_itab2-fieldname = 'WERKS'.
  kopf_itab2-tabname = 'BEL'.
  kopf_itab2-ref_tabname = 'ISEG'.
  kopf_itab2-col_pos = '1'.
  APPEND kopf_itab2 TO itab2.

  CLEAR kopf_itab2.
  kopf_itab2-fieldname = 'LGORT'.
  kopf_itab2-tabname = 'BEL'.
  kopf_itab2-ref_tabname = 'ISEG'.
  kopf_itab2-col_pos = '2'.
  APPEND kopf_itab2 TO itab2.

  CLEAR kopf_itab2.
  kopf_itab2-fieldname = 'IBLNR'.
  kopf_itab2-tabname = 'BEL'.
  kopf_itab2-ref_tabname = 'ISEG'.
  kopf_itab2-col_pos = '3'.
  APPEND kopf_itab2 TO itab2.

  CLEAR kopf_itab2.
  kopf_itab2-fieldname = 'BLDAT'.
  kopf_itab2-tabname = 'BEL'.
  kopf_itab2-ref_tabname = 'IKPF'.
  kopf_itab2-col_pos = '4'.
  APPEND kopf_itab2 TO itab2.

  CLEAR kopf_itab2.
  kopf_itab2-fieldname = 'BUDAT'.
  kopf_itab2-tabname = 'BEL'.
  kopf_itab2-ref_tabname = 'IKPF'.
  kopf_itab2-col_pos = '5'.
  APPEND kopf_itab2 TO itab2.

  CLEAR kopf_itab2.
  kopf_itab2-fieldname = 'SPERR'.
  kopf_itab2-tabname = 'BEL'.
  kopf_itab2-ref_tabname = 'IKPF'.
  kopf_itab2-col_pos = '6'.
  APPEND kopf_itab2 TO itab2.

  CLEAR kopf_itab2.
  kopf_itab2-fieldname = 'ZSTAT'.
  kopf_itab2-tabname = 'BEL'.
  kopf_itab2-ref_tabname = 'IKPF'.
  kopf_itab2-col_pos = '7'.
  APPEND kopf_itab2 TO itab2.

  CLEAR kopf_itab2.
  kopf_itab2-fieldname = 'DSTAT'.
  kopf_itab2-tabname = 'BEL'.
  kopf_itab2-ref_tabname = 'IKPF'.
  kopf_itab2-col_pos = '8'.
  APPEND kopf_itab2 TO itab2.
ENDFORM.                    "FIELDCAT_BUILD2


*&---------------------------------------------------------------------
*&      Form  LAYOUT
*&---------------------------------------------------------------------
FORM layout.

*  ITAB_LAYOUT-GROUP_BUTTONS = SPBUTTO.
*  ITAB_LAYOUT-ROWNO_CHANGE = ROWNO.

  itab_layout-key_hotspot = 'X'.       " Key-Felder als Hotspot
  itab_layout-no_keyfix = ' '.         " Key-Felder sind nicht scrollbar
  " (DEFAULT)
* ITAB_LAYOUT-NO_ZEBRA = 'X'.          " Keine Zebra-Muster in Liste
* ITAB_LAYOUT-ROWNO_CHANGE = 'X'.      "mehrzeilige listen möglich
* ITAB_LAYOUT-GROUP_BUTTONS = 'X'.
  itab_layout-box_fieldname = 'BOX'.
  itab_layout-box_tabname = 'YISEG'.
* itab_layout-colors-heacolfir-col = '3'.
* itab_layout-colors-heacolfir-int = '0'.
* itab_layout-colors-lisbodfir-col = '3'.
* itab_layout-colors-higsumhig-col = '1'.
* itab_layout-colors-higsumlow-col = '2'.
  itab_layout-group_change_edit = x.

ENDFORM.                               " LAYOUT

*&---------------------------------------------------------------------
*&      Form  LAYOUT2
*& Für nicht ausbuchbare Belege
*&---------------------------------------------------------------------
FORM layout2.


  itab_layout-key_hotspot = 'X'.       " Key-Felder als Hotspot
  itab_layout-no_keyfix = ' '.         " Key-Felder sind nicht scrollbar
  " (DEFAULT)


ENDFORM.                               " LAYOUT
*&---------------------------------------------------------------------*
*&      Form  HEADER
*&---------------------------------------------------------------------*

FORM header.
  REFRESH xheader.
  CLEAR xheader.

* Listenüberschrift: Typ H
  xheader-typ = 'H'.
  xheader-info = text-065.
  APPEND xheader.
  xheader-info = '  '  .
  APPEND xheader.
  CLEAR xheader.

ENDFORM.                    "HEADER

*&---------------------------------------------------------------------*
*&      Form  HEADER2
*&---------------------------------------------------------------------*

FORM header2.
  REFRESH xheader2.
  CLEAR xheader2.

* Listenüberschrift: Typ H
  xheader2-typ = 'H'.
  xheader2-info = text-066.
  APPEND xheader2.
  xheader2-info = '  '  .
  APPEND xheader2.
  CLEAR xheader2.

ENDFORM.                    "HEADER2
*______________________________________________________________________
* UNTERPROGRAMM: VERARBEITUNG VON USER-COMMANDS
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE kkblo_selfield.

  DATA: l_yiseg LIKE STANDARD TABLE OF yiseg WITH HEADER LINE.
  DATA: l_all_pos_selected TYPE c.
* lokale Tabelle mit markierten Positionen aufbauen
  LOOP AT yiseg WHERE box EQ 'X'.
    l_yiseg = yiseg.
    APPEND l_yiseg.
  ENDLOOP.

  CASE r_ucomm.
    WHEN '&IC1'.
      READ TABLE yiseg INDEX rs_selfield-tabindex.
      IF sy-subrc IS INITIAL.
        SET PARAMETER ID 'IBN' FIELD yiseg-iblnr.
        SET PARAMETER ID 'GJR' FIELD yiseg-gjahr.
        CALL TRANSACTION 'MI03' AND SKIP FIRST SCREEN.
      ENDIF.
    WHEN '9DIF'.
      CLEAR iblnr_old.
      SORT l_yiseg BY iblnr.
      LOOP AT l_yiseg WHERE box EQ 'X'.
        IF l_yiseg-iblnr NE iblnr_old.
*         export der Positionen
          PERFORM build_iseg_sel TABLES l_yiseg
                                        iseg_sel
                                  USING l_yiseg-iblnr.
          EXPORT iseg_sel TO MEMORY ID 'INVENTORY_ITEMS'.

          SET PARAMETER ID 'IBN' FIELD l_yiseg-iblnr.
          SET PARAMETER ID 'GJR' FIELD l_yiseg-gjahr.
*       CALL TRANSACTION 'MI07' AND SKIP FIRST SCREEN.
          CALL TRANSACTION 'MI07'.
        ENDIF.
        iblnr_old = l_yiseg-iblnr.
      ENDLOOP.
      IF sy-subrc NE 0.
        MESSAGE s744 WITH 0.
      ENDIF.
    WHEN '9ZAE'.
      CLEAR iblnr_old.
      SORT l_yiseg BY iblnr.
      LOOP AT l_yiseg WHERE box EQ 'X'.
        IF l_yiseg-iblnr NE iblnr_old.
*         export der Positionen
          PERFORM build_iseg_sel TABLES l_yiseg
                                        iseg_sel
                                  USING l_yiseg-iblnr.
          EXPORT iseg_sel TO MEMORY ID 'INVENTORY_ITEMS'.

          SET PARAMETER ID 'IBN' FIELD l_yiseg-iblnr.
          SET PARAMETER ID 'GJR' FIELD l_yiseg-gjahr.
          CALL TRANSACTION 'MI05' AND SKIP FIRST SCREEN.
        ENDIF.
        iblnr_old = l_yiseg-iblnr.
      ENDLOOP.
      IF sy-subrc NE 0.
        MESSAGE s744 WITH 0.
      ENDIF.
    WHEN '9BAN'.
      CLEAR iblnr_old.
      SORT l_yiseg BY iblnr.
      LOOP AT l_yiseg WHERE box EQ 'X'.
        IF l_yiseg-iblnr NE iblnr_old.
*         export der Positionen
          PERFORM build_iseg_sel TABLES l_yiseg
                                        iseg_sel
                                  USING l_yiseg-iblnr.
          EXPORT iseg_sel TO MEMORY ID 'INVENTORY_ITEMS'.

          SET PARAMETER ID 'IBN' FIELD l_yiseg-iblnr.
          SET PARAMETER ID 'GJR' FIELD l_yiseg-gjahr.
          CALL TRANSACTION 'MI03' AND SKIP FIRST SCREEN.
        ENDIF.
        iblnr_old = l_yiseg-iblnr.
      ENDLOOP.
      IF sy-subrc NE 0.
        MESSAGE s744 WITH 0.
      ENDIF.
    WHEN '9BAE'.
      CLEAR iblnr_old.
      SORT l_yiseg BY iblnr.
      LOOP AT l_yiseg WHERE box EQ 'X'.
        IF l_yiseg-iblnr NE iblnr_old.
*         export der Positionen
          PERFORM build_iseg_sel TABLES l_yiseg
                                        iseg_sel
                                  USING l_yiseg-iblnr.
*         check, wether all positions of document are selected
          PERFORM check_all_pos_selected TABLES yiseg
                                                iseg_sel
                                          USING l_yiseg-iblnr
                                       CHANGING l_all_pos_selected.

          EXPORT iseg_sel TO MEMORY ID 'INVENTORY_ITEMS'.

          SET PARAMETER ID 'IBN' FIELD l_yiseg-iblnr.
          SET PARAMETER ID 'GJR' FIELD l_yiseg-gjahr.
          IF NOT l_all_pos_selected IS INITIAL.
            CALL TRANSACTION 'MI02'.
          ELSE.
            CALL TRANSACTION 'MI02' AND SKIP FIRST SCREEN.
          ENDIF.
        ENDIF.
        iblnr_old = l_yiseg-iblnr.
      ENDLOOP.
      IF sy-subrc NE 0.
        MESSAGE s744 WITH 0.
      ENDIF.
    WHEN '9NAB'.
* Liste nicht ausbuchbarer Belege anzeigen
      PERFORM list_not_post_docs.
*   neue Funktionscodes: Erweiterung wegen Navigationsreport
    WHEN '9BNZ'.
*     Beleg nachzählen
      CLEAR iblnr_old.
      SORT l_yiseg BY iblnr.
      LOOP AT l_yiseg WHERE box EQ 'X'.
        IF l_yiseg-iblnr NE iblnr_old.
          PERFORM build_iseg_sel TABLES l_yiseg
                                        iseg_sel
                                  USING l_yiseg-iblnr.
          EXPORT iseg_sel TO MEMORY ID 'INVENTORY_ITEMS'.

          SET PARAMETER ID 'IBN' FIELD l_yiseg-iblnr.
          SET PARAMETER ID 'GJR' FIELD l_yiseg-gjahr.
          CALL TRANSACTION 'MI11'.              "note 374962
        ENDIF.
        iblnr_old = l_yiseg-iblnr.
      ENDLOOP.
      IF sy-subrc NE 0.
        MESSAGE s744 WITH 0.
      ENDIF.
    WHEN '9ZER'.
*     Zählung erfassen
      CLEAR iblnr_old.
      SORT l_yiseg BY iblnr.
      LOOP AT l_yiseg WHERE box EQ 'X'.
        IF l_yiseg-iblnr NE iblnr_old.
          PERFORM build_iseg_sel TABLES l_yiseg
                                        iseg_sel
                                  USING l_yiseg-iblnr.
          EXPORT iseg_sel TO MEMORY ID 'INVENTORY_ITEMS'.

          SET PARAMETER ID 'IBN' FIELD l_yiseg-iblnr.
          SET PARAMETER ID 'GJR' FIELD l_yiseg-gjahr.
          CALL TRANSACTION 'MI04' AND SKIP FIRST SCREEN.
        ENDIF.
        iblnr_old = l_yiseg-iblnr.
      ENDLOOP.
      IF sy-subrc NE 0.
        MESSAGE s744 WITH 0.
      ENDIF.
    WHEN '9ZAN'.
*     Zählung anzeigen
      CLEAR iblnr_old.
      SORT l_yiseg BY iblnr.
      LOOP AT l_yiseg WHERE box EQ 'X'.
        IF l_yiseg-iblnr NE iblnr_old.
          PERFORM build_iseg_sel TABLES l_yiseg
                                        iseg_sel
                                  USING l_yiseg-iblnr.
          EXPORT iseg_sel TO MEMORY ID 'INVENTORY_ITEMS'.

          SET PARAMETER ID 'IBN' FIELD l_yiseg-iblnr.
          SET PARAMETER ID 'GJR' FIELD l_yiseg-gjahr.
          CALL TRANSACTION 'MI06' AND SKIP FIRST SCREEN.
        ENDIF.
        iblnr_old = l_yiseg-iblnr.
      ENDLOOP.
      IF sy-subrc NE 0.
        MESSAGE s744 WITH 0.
      ENDIF.
    WHEN '9AKT'.
*     Liste wird aktualisiert
      PERFORM neustart USING space.
  ENDCASE.
ENDFORM.                    "USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  PF_STATUS_SET
*&---------------------------------------------------------------------*
FORM pf_status_set USING extab TYPE kkblo_t_extab.

* SET PF-STATUS 'STDD_DIF' EXCLUDING EXTAB.
  SET PF-STATUS 'STANDARD' EXCLUDING extab.

ENDFORM.                    "PF_STATUS_SET

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM top_of_page.

  CALL FUNCTION 'K_KKB_TOP_OF_PAGE_HEADER'
    EXPORTING
      it_header = xheader[]
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                               " SELSAVE

*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE2                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM top_of_page2.

  CALL FUNCTION 'K_KKB_TOP_OF_PAGE_HEADER'
    EXPORTING
      it_header = xheader2[]
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                               " SELSAVE



*&---------------------------------------------------------------------*
*&      Form  LISTAUSGABE
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM listausgabe.


  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
       EXPORTING
            i_callback_program       = 'ZM_RM07IDIF'
            i_callback_pf_status_set = 'PF_STATUS_SET'
            i_callback_user_command  = 'USER_COMMAND'
            i_structure_name         = 'YISEG'
            is_layout                = itab_layout
            it_fieldcat              = itab
*         IT_EXCLUDING             =
            it_special_groups        = gruppen[]
*         IT_SORT                  =
*         IT_FILTER                =
*         IS_SEL_HIDE              =
*         I_DEFAULT                = ' '
            i_save                   = 'A'
            is_variant               = g_variant
*         IT_EVENTS                =
*         IT_EVENT_EXIT            =
          is_print                 = is_print
*         I_SCREEN_START_COLUMN    = 0
*         I_SCREEN_START_LINE      = 0
*         I_SCREEN_END_COLUMN      = 0
*         I_SCREEN_END_LINE        = 0
     IMPORTING
*         E_EXIT_CAUSED_BY_CALLER  =
          es_exit_caused_by_user    = g_exit_by_user
       TABLES
            t_outtab                 = yiseg
       EXCEPTIONS
            program_error            = 1
            OTHERS                   = 2.











ENDFORM.                               " LISTAUSGABE

*&---------------------------------------------------------------------*
*&      Form  LISTAUSGABE2
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM listausgabe2.

  SORT yiseg BY werks lgort gjahr matnr.
  REFRESH ywerks.


  LOOP AT yiseg.
    ON CHANGE OF yiseg-werks OR
                 yiseg-lgort.
      MOVE yiseg-werks TO ywerks-werks.
      MOVE yiseg-lgort TO ywerks-lgort.
      APPEND ywerks.
    ENDON.
  ENDLOOP.

  gs_keyinfo-master01 = 'WERKS'.
  gs_keyinfo-master02 = 'LGORT'.

* fuer richtige Sortierung notwendig
  gs_keyinfo-slave01 = 'WERKS'.
  gs_keyinfo-slave02 = 'LGORT'.
  gs_keyinfo-slave03 = 'IBLNR'.
  gs_keyinfo-slave04 = 'GJAHR'.
  gs_keyinfo-slave05 = 'ZEILI'.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
       EXPORTING
            i_callback_program       = 'ZM_RM07IDIF'
            i_callback_pf_status_set = 'PF_STATUS_SET'
            i_callback_user_command  = 'USER_COMMAND'
            is_layout                = itab_layout
            it_fieldcat              = itab
*         IT_EXCLUDING             =
            it_special_groups        = gruppen[]
*         IT_SORT                  =
*         IT_FILTER                =
*         IS_SEL_HIDE              =
*         I_SCREEN_START_COLUMN    = 0
*         I_SCREEN_START_LINE      = 0
*         I_SCREEN_END_COLUMN      = 0
*         I_SCREEN_END_LINE        = 0
*         I_DEFAULT                = ' '
            i_save                   = 'A'
          is_variant               = g_variant
*         IT_EVENTS                =
*         IT_EVENT_EXIT            =
            i_tabname_header         = 'YWERKS'
            i_tabname_item           = 'YISEG'
            is_keyinfo               = gs_keyinfo
          is_print                 = is_print
     IMPORTING
*         E_EXIT_CAUSED_BY_CALLER  =
          es_exit_caused_by_user    = g_exit_by_user
       TABLES
            t_outtab_header          = ywerks
            t_outtab_item            = yiseg
       EXCEPTIONS
            program_error            = 1
            OTHERS                   = 2.


ENDFORM.                               " LISTAUSGABE


*&---------------------------------------------------------------------*
*&      Form  LISTAUSGABE3
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM listausgabe3.

* sort yiseg by iblnr matnr charg.
  SORT yiseg BY iblnr gjahr zeili ASCENDING matnr charg.
  REFRESH yiblnr.


  LOOP AT yiseg.
    ON CHANGE OF yiseg-iblnr.
      MOVE yiseg-iblnr TO yiblnr-iblnr.
      MOVE yiseg-werks TO yiblnr-werks.
      MOVE yiseg-lgort TO yiblnr-lgort.
      MOVE yiseg-sobkz TO yiblnr-sobkz.
      MOVE yiseg-buper TO yiblnr-buper.
      MOVE yiseg-invnu TO yiblnr-invnu.
      APPEND yiblnr.
    ENDON.
  ENDLOOP.

  gs_keyinfo-master01 = 'IBLNR'.
* für richtige Sortierung notwendig
  gs_keyinfo-slave01 = 'IBLNR'.
  gs_keyinfo-slave02 = 'GJAHR'.
  gs_keyinfo-slave03 = 'ZEILI'.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
       EXPORTING
            i_callback_program       = 'ZM_RM07IDIF'
            i_callback_pf_status_set = 'PF_STATUS_SET'
            i_callback_user_command  = 'USER_COMMAND'
            is_layout                = itab_layout
            it_fieldcat              = itab
*         IT_EXCLUDING             =
            it_special_groups        = gruppen[]
*         IT_SORT                  =
*         IT_FILTER                =
*         IS_SEL_HIDE              =
*         I_SCREEN_START_COLUMN    = 0
*         I_SCREEN_START_LINE      = 0
*         I_SCREEN_END_COLUMN      = 0
*         I_SCREEN_END_LINE        = 0
*         I_DEFAULT                = ' '
            i_save                   = 'A'
          is_variant               = g_variant
*         IT_EVENTS                =
*         IT_EVENT_EXIT            =
            i_tabname_header         = 'YIBLNR'
            i_tabname_item           = 'YISEG'
            is_keyinfo               = gs_keyinfo
          is_print                 = is_print
     IMPORTING
*         E_EXIT_CAUSED_BY_CALLER  =
          es_exit_caused_by_user    = g_exit_by_user
       TABLES
            t_outtab_header          = yiblnr
            t_outtab_item            = yiseg
       EXCEPTIONS
            program_error            = 1
            OTHERS                   = 2.


ENDFORM.                               " LISTAUSGABE


*----------------------------------------------------------------------
*
* UNTERPROGRAMM: Liste nicht ausbuchbarer Belege ausgeben.
*
*----------------------------------------------------------------------

FORM list_not_post_docs.

*  Feldkatalog aufbauen
  PERFORM fieldcat_build2.

* LAYOUT DER LISTE
  PERFORM layout2.

*  HEADER
  PERFORM header2.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
       EXPORTING
            i_callback_program     = 'ZM_RM07IDIF'
*           i_callback_top_of_page = 'TOP_OF_PAGE2'
*           i_tabname              = 'BEL'
            it_fieldcat            = itab2
*           i_fctype               = 'R'
            is_layout              = itab_layout2  "Layoutdaten-Übergab
       TABLES
            t_outtab               = bel
       EXCEPTIONS
            OTHERS                 = 1.


ENDFORM.                    "LIST_NOT_POST_DOCS

*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
FORM variant_init.
*
  CLEAR g_variant.
  g_variant-report = sy-repid.
* bei Navigationsliste handle = c_inventurliste setzen
*  IF sy-tcode = c_inventurliste.              " 497534
  IF g_pi_list = 'X'.                                       " 497534
    g_variant-handle = c_inventurliste.
  ENDIF.
ENDFORM.                               " VARIANT_INIT

*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*----------------------------------------------------------------------*
FORM f4_for_variant.
*
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
       EXPORTING
            is_variant          = g_variant
            i_save              = g_save
*           it_default_fieldcat =
       IMPORTING
            e_exit              = g_exit
            es_variant          = gx_variant
       EXCEPTIONS
            not_found = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF g_exit = space.
      p_vari = gx_variant-variant.
    ENDIF.
  ENDIF.

ENDFORM.                               " F4_FOR_VARIANT

*&---------------------------------------------------------------------*
*&      Form  PAI_OF_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM pai_of_selection_screen.
*
  IF NOT p_vari IS INITIAL.
    MOVE g_variant TO gx_variant.
    MOVE p_vari TO gx_variant-variant.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = g_save
      CHANGING
        cs_variant = gx_variant.
    g_variant = gx_variant.
  ELSE.
    PERFORM variant_init.
  ENDIF.
ENDFORM.                               " PAI_OF_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*&      Form  WERT_AUS_INFOSATZ
*&---------------------------------------------------------------------*
*       Wert aus Konsignationsinfosatz wenn TCURM-KONSI = X
*----------------------------------------------------------------------*
FORM wert_aus_infosatz.
  IF meico-werks NE iikpf-werks.
    CALL FUNCTION 'ME_SELECT_EKORG_FOR_PLANT'
      EXPORTING
        i_werks                    = iikpf-werks
        i_konsi                    = x
      IMPORTING
        e_ekorg                    = ekorg
      EXCEPTIONS
        more_than_one_organization = 01
        no_entry_found             = 02
        no_default_found           = 03.

    IF NOT sy-subrc IS INITIAL.
      DATA: l_rc LIKE sy-subrc.
*     perform nachrichtencode_ermitteln(sapfm07m) using 'M7' '169'.
      CALL FUNCTION 'MB_CHECK_T160M'
        EXPORTING
          i_msgnr = '169'
        IMPORTING
          rc      = l_rc.

      IF l_rc NE 0.
*       bugs fixed who were reported by the extended        "n526509
*       program check / message has no variables            "n526509
        MESSAGE i169.  "Vendor is determined automatically  "n526509
      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR: meico, meicr, meprck.
  meico-esokz  = zwei.
  meico-ekorg  = ekorg.
  meico-matnr  = yiseg-matnr.
  meico-werks  = iikpf-werks.
  meico-lifnr  = yiseg-lifnr.

  IF yiseg-attyp = '02'.                                   "note 528443
    meico-satnr = yiseg-samat.                             "note 528443
    meico-attyp = yiseg-attyp.                             "note 528443
  ENDIF.                                                   "note 528443

  meprck-simng = ABS( yiseg-difmg ).
  meprck-simme = yiseg-meins.
  meprck-sidat = iikpf-zldat.
  meprck-bwsv1 = '3'.
  CALL FUNCTION 'ME_READ_INFORECORD'
    EXPORTING
      incom         = meico
      inpreissim    = meprck
    IMPORTING
      einadaten     = eina
      einedaten     = eine
      excom         = meicr
      expreissim    = mepro
    EXCEPTIONS
      error_message = 04.

* display a negative value for konsignment mat.
  IF yiseg-difmg LT 0.
    mepro-netwr = -1 * mepro-netwr.
  ENDIF.

  CHECK sy-subrc IS INITIAL.
  IF mepro-waers IS INITIAL.
    mepro-waers = eine-waers.
  ENDIF.
  IF mepro-waers = yiseg-waers.
    yiseg-dmbtr = mepro-netwr.
  ELSE.
    IF t003-blart IS INITIAL.
      SELECT SINGLE * FROM t158 WHERE tcode = mi10.
      IF NOT sy-subrc IS INITIAL.
        SELECT SINGLE * FROM t003 WHERE blart = t158-blart.
      ENDIF.
    ENDIF.
    IF t003-kurst IS INITIAL.
      kurst = 'M   '.
    ELSE.
      kurst = t003-kurst.
    ENDIF.
    IF NOT t001a-bukrs = t001-bukrs.
      SELECT SINGLE * FROM t001a WHERE bukrs = t001-bukrs.
    ENDIF.
    DATA: datum LIKE sy-datum.
    IF t001a-curdt = eins.
      datum = iikpf-bldat.
    ELSE.
      datum = iikpf-zldat.
    ENDIF.
    CALL FUNCTION 'FI_TYPE_OF_RATE_CHECK'
      EXPORTING
        i_blart = t158-blart
        i_kurst = kurst
        i_waers = mepro-waers
        i_hwaer = t001-waers.
    fw_betrag = mepro-netwr.
    CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
      EXPORTING
        foreign_currency = mepro-waers
        local_currency   = t001-waers
        foreign_amount   = fw_betrag
        date             = datum
        type_of_rate     = kurst
      IMPORTING
        local_amount     = betrag.

    yiseg-dmbtr = betrag.
  ENDIF.
ENDFORM.                               " WERT_AUS_INFOSATZ
*&---------------------------------------------------------------------*
*&      Form  BUILD_ISEG_SEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->YISEG  text
*      -->P_T_ISEG_SEL  text
*      -->P_YISEG_IBLNR  text
*----------------------------------------------------------------------*
FORM build_iseg_sel TABLES p_yiseg STRUCTURE yiseg
                           p_t_iseg_sel STRUCTURE iseg_sel
                     USING p_yiseg_iblnr.

  CLEAR p_t_iseg_sel.
  REFRESH p_t_iseg_sel.

  LOOP AT p_yiseg WHERE iblnr = p_yiseg_iblnr
                    AND box = 'X'.
    MOVE-CORRESPONDING p_yiseg TO p_t_iseg_sel.
    APPEND p_t_iseg_sel.
  ENDLOOP.
  SORT p_t_iseg_sel BY iblnr gjahr zeili.
ENDFORM.                               " BUILD_ISEG_SEL
*&---------------------------------------------------------------------*
*&      Form  NEUSTART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM neustart USING x_selection_screen TYPE c.

  DATA: l_rsparams LIKE STANDARD TABLE OF rsparams WITH HEADER LINE.

  CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
    EXPORTING
      curr_report     = 'ZM_RM07IDIF'
    TABLES
      selection_table = l_rsparams
    EXCEPTIONS
      not_found       = 1
      no_report       = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
*   Programm neu starten mit den vorhandenen Selektionskriterien
    IF x_selection_screen IS INITIAL.
      SUBMIT zm_rm07idif WITH SELECTION-TABLE l_rsparams.
    ELSE.
      SUBMIT zm_rm07idif VIA SELECTION-SCREEN
                      WITH SELECTION-TABLE l_rsparams.
    ENDIF.
  ENDIF.
ENDFORM.                               " NEUSTART
*&---------------------------------------------------------------------*
*&      Form  CHECK_ALL_POS_SELECTED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_YISEG  text
*      -->P_t_ISEG_SEL  text
*      <--P_ALL_POS_SELECTED  text
*----------------------------------------------------------------------*
FORM check_all_pos_selected TABLES p_yiseg STRUCTURE yiseg
                                   p_t_iseg_sel STRUCTURE iseg_sel
                             USING p_iblnr LIKE iseg-iblnr
                          CHANGING p_all_pos_selected TYPE c.

  p_all_pos_selected = 'X'.
  LOOP AT p_yiseg WHERE iblnr = p_iblnr
                    AND box IS INITIAL.
    CLEAR p_all_pos_selected.
    EXIT.
  ENDLOOP.

ENDFORM.                               " CHECK_ALL_POS_SELECTED
*&---------------------------------------------------------------------*
*&      Form  LVS_PRUEFEN
*&---------------------------------------------------------------------*
*       Bei Inv.belegen, die mit über LVS oder MB11 erzeugt wurden,    *
*       muß zur Bestimmung des Vorzeichens der Differenz der           *
*       Materialbeleg gelesen werden.                                  *
*----------------------------------------------------------------------*
FORM lvs_pruefen.
  TABLES: t320.

  IF NOT yiseg-lgort = t320-lgort OR NOT yiseg-werks = t320-werks.
    SELECT SINGLE * FROM t320 WHERE werks = yiseg-werks AND
                                    lgort = yiseg-lgort AND
                                     obest = space.
  ENDIF.

  CHECK ( yiseg-lgort = t320-lgort AND yiseg-werks = t320-werks
          AND sy-subrc IS INITIAL )
          OR iikpf-vgart = 'WV'.
  SELECT SINGLE * FROM mseg WHERE mblnr = yiseg-mblnr
                              AND mjahr = yiseg-mjahr
                              AND zeile = yiseg-zeile.
  IF sy-subrc IS INITIAL.
    IF mseg-shkzg = h AND yiseg-difmg GT 0.
      yiseg-difmg = 0 - yiseg-difmg.
      yiseg-ndifw = yiseg-dmbtr * -1.
      CLEAR yiseg-pdifw.
    ELSE.
      yiseg-pdifw = yiseg-dmbtr.
      CLEAR yiseg-ndifw.
    ENDIF.
  ENDIF.

ENDFORM.                               " LVS_PRUEFEN
*&---------------------------------------------------------------------*
*&      Form  WERTERMITTLUNG_WART
*&---------------------------------------------------------------------*
*       Wertermittlung für Wertartikel (ähnlich SAPMM07I).
*       Kapselung vollständig bis auf Feld MAXIMUM.
*----------------------------------------------------------------------*
FORM wertermittlung_wart USING was_matnr
                               was_bwkey
                               was_bwtar
                               was_salk3      "Buchwert (Salk3)
                               was_buchw      "Buchwert (Vksal)
                               was_exvkw      "ext. eingeb. Vkwert
                               was_difvw      "Differenz VK-Wert
                               was_bwspa      "Bewertungsspanne
                      CHANGING was_betra.     "Differenz EP-Wert

  DATA: pi_mbew LIKE vmbew,
        pi_pvf  LIKE pipvf.
  DATA pe_dmbtr LIKE mseg-dmbtr.

*  IF NOT WAS_BUCHW = WAS_EXVKW.         " 410710
  IF NOT was_difvw IS INITIAL.                              " 410710
* Füllen der Struktur PI_PVF
    pi_pvf-bumat = was_matnr.
    pi_pvf-bwkey = was_bwkey.
    pi_pvf-bwtar = was_bwtar.
    pi_pvf-vkwrt = was_difvw.

* Füllen der Struktur PI_MBEW
    pi_mbew-mandt  = sy-mandt.
    pi_mbew-matnr  = was_matnr.
    pi_mbew-bwkey  = was_bwkey.
    pi_mbew-bwtar  = was_bwtar.
    pi_mbew-salk3  = was_salk3.
    pi_mbew-vksal  = was_buchw.
    pi_mbew-bwspa  = was_bwspa.

* Ermittlung des Einkaufswertes über Funktionsbaustein.
    CALL FUNCTION 'PURCHASING_VALUE_FIND'
      EXPORTING
        pi_i_pvf   = pi_pvf
        pi_i_vmbew = pi_mbew
      IMPORTING
        pe_dmbtr   = pe_dmbtr
      EXCEPTIONS
        OTHERS     = 01.

    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    MOVE pe_dmbtr TO was_betra.
  ENDIF.

* bugs fixed who were reported by the ext. program check    "n526509
  DATA : l_message           LIKE      sy-msgv1.            "n526509

  IF was_betra > maximum.
    CONCATENATE 'WERTERMITTLUNG_WART' 'WAS_BETRA'           "n526509
                             INTO l_message                 "n526509
                             SEPARATED BY space.            "n526509
                                                            "n526509
*   Select another function, & is not supported here        "n526509
    MESSAGE e002 WITH l_message.                            "n526509
  ENDIF.

  IF was_difvw > maximum.
    CONCATENATE 'WERTERMITTLUNG_WART' 'WAS_BETRA'           "n526509
                             INTO l_message                 "n526509
                             SEPARATED BY space.            "n526509
                                                            "n526509
*   Select another function, & is not supported here        "n526509
    MESSAGE e002 WITH l_message.                            "n526509
  ENDIF.
ENDFORM.                               "WERTERMITTLUNG_WART
*&---------------------------------------------------------------------*
*&      Form  PREFETCH1_DURCHFUEHREN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prefetch1_durchfuehren.
  DATA: BEGIN OF l_prefetch04 OCCURS 20.
          INCLUDE STRUCTURE pre04.
  DATA: END OF l_prefetch04.
  DATA: BEGIN OF l_prefetch04_xvper OCCURS 20.
          INCLUDE STRUCTURE pre04.
  DATA: END OF l_prefetch04_xvper.
  DATA: l_bwkey LIKE t001w-bwkey.
  DATA: l_bwtar LIKE mbew-bwtar.
  DATA: l_xvper TYPE c.
  DATA: l_werks LIKE ikpf-werks.
  DATA: l_delwerk TYPE c.

  FIELD-SYMBOLS: <xiseg> LIKE xiseg.

  CLEAR   l_prefetch04.
  REFRESH l_prefetch04.
  CLEAR   l_prefetch04_xvper.
  REFRESH l_prefetch04_xvper.
  CLEAR g_prefetch_mcha.
  REFRESH g_prefetch_mcha.

* prefetch für Massenzugriff auf MCHA fuellen
  LOOP AT xiseg FROM g_first_index TO g_last_index
       ASSIGNING <xiseg>.
*   array read for MARC done already
    PERFORM marc_lesen USING <xiseg>-matnr <xiseg>-werks.
    IF NOT marc-bwtty IS INITIAL.
      g_prefetch_mcha-matnr = <xiseg>-matnr.
      g_prefetch_mcha-werks = <xiseg>-werks.
      g_prefetch_mcha-charg = <xiseg>-charg.
      COLLECT g_prefetch_mcha.
    ENDIF.
  ENDLOOP.

* do prefetch for MCHA
  PERFORM array_read_mcha.

  CLEAR ikpf_key.
  CLEAR l_werks.
* prefetch für Massenzugriff auf MBEW fuellen
  LOOP AT xiseg FROM g_first_index TO g_last_index
       ASSIGNING <xiseg>.
    IF l_werks NE <xiseg>-werks.
      l_werks = <xiseg>-werks.
      PERFORM lesen_werk USING <xiseg>-werks.

      IF sy-subrc IS INITIAL.
        CLEAR l_delwerk.
        PERFORM marv_lesen USING t001k-bukrs.
        l_bwkey = t001w-bwkey.
      ELSE.
        l_delwerk = 'X'.
      ENDIF.
    ENDIF.
    IF l_delwerk = 'X'.
      CONTINUE.
    ENDIF.

    CLEAR l_bwtar.
    PERFORM marc_lesen USING <xiseg>-matnr <xiseg>-werks.
    IF NOT marc-bwtty IS INITIAL.
      PERFORM mcha_lesen USING <xiseg>-matnr
                               <xiseg>-werks
                               <xiseg>-charg.
      IF sy-subrc EQ 0.
        l_bwtar = mcha-bwtar.
      ENDIF.
    ENDIF.

    PERFORM mtart_ermitteln USING <xiseg>-matnr <xiseg>-werks l_bwkey.
    IF v134w-wertu = x              AND
       NOT <xiseg>-xzael IS INITIAL AND
       <xiseg>-xdiff IS INITIAL     AND
       <xiseg>-xnzae IS INITIAL.

      IF ikpf_key-mandt NE <xiseg>-mandt OR
         ikpf_key-iblnr NE <xiseg>-iblnr OR
         ikpf_key-gjahr NE <xiseg>-gjahr.
        ikpf_key-mandt = <xiseg>-mandt.
        ikpf_key-iblnr = <xiseg>-iblnr.
        ikpf_key-gjahr = <xiseg>-gjahr.
        READ TABLE iikpf WITH KEY ikpf_key BINARY SEARCH.

        CLEAR l_xvper.
*       decide whether document is in previous period
        IF iikpf-gjahr NE marv-lfgja OR iikpf-monat NE marv-lfmon.
          IF iikpf-gjahr EQ marv-vmgja AND iikpf-monat EQ marv-vmmon.
            l_xvper = x.
          ENDIF.
        ENDIF.
      ENDIF.

      IF l_xvper = x.
*       read values of previous period too
        l_prefetch04_xvper-matnr = <xiseg>-matnr.
        l_prefetch04_xvper-bwkey = l_bwkey.
        l_prefetch04_xvper-bwtar = l_bwtar.
        COLLECT l_prefetch04_xvper.
        IF NOT l_bwtar IS INITIAL.
*         Kopfsatz mit BWTAR=initial prefetchen
          l_prefetch04_xvper-matnr = <xiseg>-matnr.
          l_prefetch04_xvper-bwkey = l_bwkey.
          CLEAR: l_prefetch04_xvper-bwtar.
          COLLECT l_prefetch04_xvper.
        ENDIF.
      ELSE.
        l_prefetch04-matnr = <xiseg>-matnr.
        l_prefetch04-bwkey = l_bwkey.
        l_prefetch04-bwtar = l_bwtar.
        COLLECT l_prefetch04.
        IF NOT l_bwtar IS INITIAL.
*         Kopfsatz mit BWTAR=initial prefetchen
          l_prefetch04-matnr = <xiseg>-matnr.
          l_prefetch04-bwkey = l_bwkey.
          CLEAR: l_prefetch04-bwtar.
          COLLECT l_prefetch04.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Massenzugriff MBEW ohne Vorperiode
  READ TABLE l_prefetch04 INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'MATERIAL_PRE_READ_MBEW'
      EXPORTING
        kzrfb       = 'X'
        xvper       = ' '
        xvvpr       = ' '
        xvjah       = ' '
        xvvja       = ' '
      TABLES
        mbew_keytab = l_prefetch04.
  ENDIF.

* Massenzugriff MBEW mit Vorperiode
  READ TABLE l_prefetch04_xvper INDEX 1.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'MATERIAL_PRE_READ_MBEW'
      EXPORTING
        kzrfb       = ' '        "no refresh!
        xvper       = 'X'
        xvvpr       = ' '
        xvjah       = ' '
        xvvja       = ' '
      TABLES
        mbew_keytab = l_prefetch04_xvper.
  ENDIF.
ENDFORM.                               " PREFETCH1_DURCHFUEHREN

*&---------------------------------------------------------------------*
*&      Form  ARRAY_READ_MCHA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_MCHA  text
*----------------------------------------------------------------------*
FORM array_read_mcha.

  DATA l_anz TYPE i.

  CLEAR g_t_mcha_bwtar.
  REFRESH g_t_mcha_bwtar.

  DESCRIBE TABLE g_prefetch_mcha LINES l_anz.
  IF l_anz > 0.
    SELECT matnr werks charg bwtar FROM mcha
           APPENDING TABLE g_t_mcha_bwtar
       FOR ALL ENTRIES IN  g_prefetch_mcha
                      WHERE matnr = g_prefetch_mcha-matnr
                      AND   werks = g_prefetch_mcha-werks
                      AND   charg = g_prefetch_mcha-charg.

    SORT g_t_mcha_bwtar BY matnr werks charg.

  ENDIF.
ENDFORM.                               " ARRAY_READ_MCHA
*----------------------------------------------------------------------*
*   Form MBEW_LESEN_L                                                  *
*----------------------------------------------------------------------*
* Hinweis 0188316                                                      *
* Korrektur zum MBEW_LESEN in RM07MSQL um die Vorperiode in den MBEWH  *
* Sätzen korrekt zu lesen (MTCOM-XVPER = X).                           *
*----------------------------------------------------------------------*
FORM mbew_lesen_l USING l_matnr l_bwkey l_bwtar l_xvper
                        l_sobkz l_vbeln l_posnr l_pspnr. "note 364886
  CLEAR mtcom.
  IF l_sobkz IS INITIAL.                                  "note 428901
    mtcom-kenng = 'MBEFU'.
    mtcom-matnr = l_matnr.
    mtcom-bwkey = l_bwkey.
    mtcom-bwtar = l_bwtar.
    mtcom-nomus = x.
    IF NOT l_xvper IS INITIAL.
      mtcom-xvper = x.
    ENDIF.
    CALL FUNCTION 'MATERIAL_READ'
      EXPORTING
        schluessel = mtcom
      IMPORTING
        matdaten   = mbefu
        return     = mtcor
      TABLES
        seqmat01   = dummy.
  ELSE.                                                    "note 428901
* first check with KZBWS = 'M'
    mtcom-kenng = 'MBEFU'.
    mtcom-matnr = l_matnr.
    mtcom-bwkey = l_bwkey.
    mtcom-bwtar = l_bwtar.
    mtcom-nomus = x.
    mtcom-sobkz = l_sobkz.
    mtcom-vbeln = l_vbeln.
    mtcom-posnr = l_posnr.
    mtcom-pspnr = l_pspnr.
    mtcom-kzbws = 'M'.
    IF NOT l_xvper IS INITIAL.
      mtcom-xvper = x.
    ENDIF.
    CALL FUNCTION 'MATERIAL_READ'
      EXPORTING
        schluessel = mtcom
      IMPORTING
        matdaten   = mbefu
        return     = mtcor
      TABLES
        seqmat01   = dummy.
    IF ( mtcom-sobkz = 'E' AND NOT mtcor-rebew IS INITIAL ) OR
       ( mtcom-sobkz = 'Q' AND NOT mtcor-rqbew IS INITIAL ).
* second check without kzbws --> no EBEW/QBEW so there must be
* a MBEW if not 'Einzelchargenbewertet'!
      CLEAR: mtcom-kzbws,
             mtcom-sobkz,
             mtcom-vbeln,
             mtcom-posnr,
             mtcom-pspnr.
      CALL FUNCTION 'MATERIAL_READ'
        EXPORTING
          schluessel = mtcom
        IMPORTING
          matdaten   = mbefu
          return     = mtcor
        TABLES
          seqmat01   = dummy.
    ENDIF.
  ENDIF.                                                   "note 428901
  IF mtcor-rmbew NE space.
* note 364886 (check if 'Einzelchargenbewertet' and special stock)
    TABLES: t149.
    DATA: l_bwtty LIKE mbew-bwtty.
    SELECT SINGLE bwtty FROM mbew INTO l_bwtty
                                  WHERE bwkey = mtcom-bwkey
                                    AND matnr = mtcom-matnr
                                    AND bwtar = space.
    SELECT SINGLE * FROM t149 WHERE bwkey = mtcom-bwkey    "note 374810
                              AND   bwtty = l_bwtty.
    IF NOT sy-subrc IS INITIAL.
*    bugs fixed who were reported by the ext. program check "n526509
*    Check table &: entry & & & does not exist              "n526509
      MESSAGE e001 WITH '149' mtcom-bwkey l_bwtty space.    "n526509
    ENDIF.
    CLEAR mtcom-bwtar.
    CALL FUNCTION 'MATERIAL_READ'
      EXPORTING
        schluessel = mtcom
      IMPORTING
        matdaten   = mbefu
        return     = mtcor
      TABLES
        seqmat01   = dummy.
    IF mtcor-rmbew NE space.
*    bugs fixed who were reported by the ext. program check "n526509
*    Check table &: entry & & & does not exist              "n526509
      MESSAGE e001 WITH 'MBEW' l_matnr l_bwkey space.       "n526509
    ENDIF.
* end of note 364886
  ENDIF.
ENDFORM.                    "MBEW_LESEN_L
*&---------------------------------------------------------------------*
*&      Form  DELETE_UNUSED_XISEGS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_unused_xisegs.

  DATA: i1 TYPE i.
  DATA: i2 TYPE i.
  DATA: i3 TYPE i.

  FIELD-SYMBOLS: <xiseg> LIKE xiseg.

* are there select-options for xiseg?
  DESCRIBE TABLE gidat LINES i1.
  DESCRIBE TABLE xblni LINES i2.
  DESCRIBE TABLE zldat LINES i3.
  IF i1 = 0 AND i2 = 0 AND i3 = 0.
    EXIT.
  ENDIF.

  CLEAR: ikpf_key.

  SORT xiseg BY iblnr gjahr zeili.
  SORT iikpf BY mandt iblnr gjahr.

  LOOP AT xiseg ASSIGNING <xiseg>.

    IF ikpf_key-mandt NE <xiseg>-mandt OR
       ikpf_key-iblnr NE <xiseg>-iblnr OR
       ikpf_key-gjahr NE <xiseg>-gjahr.
      ikpf_key-mandt = <xiseg>-mandt.
      ikpf_key-iblnr = <xiseg>-iblnr.
      ikpf_key-gjahr = <xiseg>-gjahr.
      READ TABLE iikpf WITH KEY ikpf_key BINARY SEARCH.
    ENDIF.

    IF NOT iikpf-gidat IN gidat OR
       NOT iikpf-xblni IN xblni OR
       NOT <xiseg>-zldat IN zldat.
      DELETE xiseg.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " DELETE_UNUSED_XISEGS
