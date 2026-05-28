REPORT zf_konfirmasi_tagihan MESSAGE-ID zf NO STANDARD PAGE HEADING
                                  LINE-COUNT 60
                                  LINE-SIZE  253.

*Declaration
TABLES: knvv, bsid, knb1, zfod, zfos,
        sscrfields.

DATA: BEGIN OF i_giro OCCURS 0.
        INCLUDE STRUCTURE zfbicheck.
DATA  END OF i_giro.

DATA: BEGIN OF i_giro_sfa OCCURS 0.
        INCLUDE STRUCTURE zfbic_sfa.
DATA  END OF i_giro_sfa.

DATA: BEGIN OF it_brcust OCCURS 0,
        vkbur LIKE knvv-vkbur,
        kunnr LIKE bsid-kunnr,
        zuonr LIKE bsid-zuonr,
      END OF it_brcust.

DATA: BEGIN OF itab OCCURS 0.
        INCLUDE STRUCTURE zfod.
DATA:   bezei LIKE tvkbt-bezei,
        due   LIKE zkonv_tagih-due,
        top   LIKE zkonv_tagih-top,
        zterm LIKE zkonv_tagih-zterm,
        sgtxt LIKE zkonv_tagih-sgtxt,
        duedt LIKE zkonv_tagih-duedt,
        zbd1t LIKE zkonv_tagih-zbd1t,
        klimk LIKE zkonv_tagih-klimk,
        norut LIKE zkonv_tagih-norut,
        kunnr1 LIKE kna1-kunnr,
        flag  LIKE zkonv_tagih-flag,
        count TYPE i,
      END OF itab.

DATA: BEGIN OF it_bsid OCCURS 0,
         bukrs LIKE bsid-bukrs,        " Company Code
         bezei LIKE tvkbt-bezei,
         kunnr LIKE bsid-kunnr,        " Cust code
         name1 LIKE kna1-name1,        " Cust Name
         name2 LIKE kna1-name2,
         ort01 LIKE kna1-ort01,
         vkbur LIKE knvv-vkbur,        " Business Area
         gjahr LIKE bsid-gjahr,        " Fiscal Year
         belnr LIKE bsid-belnr,        " Document No
         budat LIKE bsid-budat,        " Posting Date
         augdt LIKE bsid-augdt,        " Clearing date.
         monat LIKE bsid-monat,        " Periode
         bschl LIKE bsid-bschl,        " Posting Key
         dmbtr LIKE bsid-dmbtr,        " Amount in local curr
         shkzg LIKE bsid-shkzg,        " Debit/Credit indicator.
         zfbdt LIKE bsid-zfbdt,        " Baseline Date
         zbd1t LIKE bsid-zbd1t,        " Term of payment
         blart LIKE bsid-blart,        " Document Type
         zuonr LIKE bsid-zuonr,        " Do Number
         xref1 LIKE bsid-xref1,        " Route List
         xref2 LIKE bsid-xref2,        " Salesman Code
         kdgrp LIKE knvv-kdgrp,        " Customer Group
         umskz LIKE bsid-umskz,        " Special G/L Indicator
         sortl LIKE kna1-sortl,
         slcode(6),
         zterm LIKE knb1-zterm,
         bldat LIKE bsid-bldat,
         sgtxt LIKE bsid-sgtxt,
         waers LIKE bsid-waers,
         flag(1),
      END OF it_bsid.

DATA: BEGIN OF i_zfodsum OCCURS 0,
        bukrs  LIKE  zfod-bukrs,
        vkbur  LIKE  zfod-vkbur,
        bezei  LIKE  tvkbt-bezei,
        zfoid  LIKE  zfod-zfoid,
        xref1  LIKE  zfod-xref1,
        zclos  LIKE  zfod-zclos,
        name1  LIKE  kna1-name1,
        total  LIKE  zfod-giro,
        amt1   LIKE  zfod-giro,
        amt2   LIKE  zfod-giro,
        amt3   LIKE  zfod-giro,
        amt4   LIKE  zfod-giro,
        amt5   LIKE  zfod-giro,
        amt6   LIKE  zfod-giro,
        amt7   LIKE  zfod-giro,
        amt8   LIKE  zfod-giro,
        amt9   LIKE  zfod-giro,
        amt10  LIKE  zfod-giro,
        count  TYPE  i,
        keterangan(30),
      END OF i_zfodsum.

DATA: BEGIN OF i_zfoddet OCCURS 0.
        INCLUDE STRUCTURE zfod.
DATA:   bezei LIKE tvkbt-bezei,
        due   LIKE zkonv_tagih-due,
        top   LIKE zkonv_tagih-top,
        zterm LIKE zkonv_tagih-zterm,
        sgtxt LIKE zkonv_tagih-sgtxt,
        duedt LIKE zkonv_tagih-duedt,
        zbd1t LIKE zkonv_tagih-zbd1t,
        klimk LIKE zkonv_tagih-klimk,
        norut LIKE zkonv_tagih-norut,
        kunnr1 LIKE kna1-kunnr,
        flag  LIKE zkonv_tagih-flag,
        count TYPE i,
        total  LIKE  zfod-giro,
        amt1   LIKE  zfod-giro,
        amt2   LIKE  zfod-giro,
        amt3   LIKE  zfod-giro,
        amt4   LIKE  zfod-giro,
        amt5   LIKE  zfod-giro,
        amt6   LIKE  zfod-giro,
        amt7   LIKE  zfod-giro,
        amt8   LIKE  zfod-giro,
        amt9   LIKE  zfod-giro,
        amt10  LIKE  zfod-giro,
      END OF i_zfoddet.

DATA: BEGIN OF i_zfodclos OCCURS 0,
        bukrs  LIKE  zfod-bukrs,
        vkbur  LIKE  zfod-vkbur,
        bezei  LIKE  tvkbt-bezei,
        zfoid  LIKE  zfod-zfoid,
        amt1   LIKE  zfod-giro,
        amt2   LIKE  zfod-giro,
        amt3   LIKE  zfod-giro,
        amt4   LIKE  zfod-giro,
        amt5   LIKE  zfod-giro,
        amt6   LIKE  zfod-giro,
        amt7   LIKE  zfod-giro,
        amt8   LIKE  zfod-giro,
        amt9   LIKE  zfod-giro,
        amt10  LIKE  zfod-giro,
*        status LIKE  zfod-status,
*        keterangan(30),
        flbox(1),
      END OF i_zfodclos.

DATA : BEGIN OF i_status OCCURS 0,
         domname LIKE dd07t-domname,
         domvalue_l LIKE dd07t-domvalue_l,
         ddtext LIKE dd07t-ddtext,
       END OF i_status.

DATA : BEGIN OF i_kna1 OCCURS 0,
         kunnr  LIKE  kna1-kunnr,
         name1  LIKE  kna1-name1,
         name2  LIKE  kna1-name2,
         ort01  LIKE  kna1-ort01,
       END OF i_kna1.

DATA : BEGIN OF i_tvkbt OCCURS 0,
         vkbur  LIKE  tvkbt-vkbur,
         bezei  LIKE  tvkbt-bezei,
       END OF i_tvkbt.

DATA : BEGIN OF i_live OCCURS 0,
         vstel LIKE tvkol-vstel,
         werks LIKE tvkol-werks,
         lgort LIKE tvkol-lgort,
         live  LIKE zplbc-live,
       END OF i_live.

DATA : char4(4),
       char6(6),
       char8(8),
       pa_type(1),
       fl_save(1),
       fl_req(2),
       v_pernr LIKE knb1-pernr,
       v_ucomm LIKE sy-ucomm,
       v_line  TYPE i VALUE 1,
       v_text(100),
       i_popupline LIKE popuptext OCCURS 0 WITH HEADER LINE,
       i_header LIKE itab OCCURS 0 WITH HEADER LINE,
       i_detail LIKE itab OCCURS 0 WITH HEADER LINE,
       i_zfodsumd LIKE i_zfodsum OCCURS 0 WITH HEADER LINE,
       i_zfod LIKE itab OCCURS 0 WITH HEADER LINE,
       wa_zfod LIKE itab,
       i_zfos LIKE zfos OCCURS 0 WITH HEADER LINE.

*Smartforms Parameters
SELECTION-SCREEN BEGIN OF SCREEN 9001 AS WINDOW TITLE text-007.
PARAMETERS: p_tdform    LIKE ssfscreen-fname DEFAULT 'ZGD*F*'
                        NO-DISPLAY,
            p_dest      LIKE tsp03-padest DEFAULT 'BM1*'.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_disp      LIKE ssfctrlop-preview  AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF SCREEN 9001.

*Create FO Selection
SELECTION-SCREEN BEGIN OF SCREEN 9002 AS WINDOW TITLE text-007.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS:
  pa_bukrs LIKE bsid-bukrs DEFAULT '8020' OBLIGATORY,
  pa_vkbur LIKE knvv-vkbur OBLIGATORY.
SELECT-OPTIONS:
*  so_vkbur FOR knvv-vkbur OBLIGATORY,
  so_kdgrp FOR knvv-kdgrp,
*  so_xref1 FOR char4,
  so_xref1 FOR char8,
  so_xref2 FOR char6,
  so_pernr FOR knb1-pernr,
  so_zuonr FOR bsid-zuonr,
  so_kunnr FOR bsid-kunnr.
PARAMETERS:
  pa_budat LIKE bsid-budat DEFAULT sy-datum OBLIGATORY.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-002.
PARAMETERS: x_norm LIKE itemset-xnorm AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS  x_shbv LIKE itemset-xshbv AS CHECKBOX DEFAULT 'X'
                                         USER-COMMAND bud.
SELECTION-SCREEN : COMMENT 4(24) text-014 FOR FIELD x_shbv.
SELECTION-SCREEN:  POSITION 30.
SELECT-OPTIONS: s_bschl FOR bsid-umskz NO INTERVALS.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE text-003.
PARAMETERS: p_vari  LIKE disvariant-variant. " ALV Variant
SELECTION-SCREEN END OF BLOCK block3.

SELECTION-SCREEN END OF SCREEN 9002.

*Input FO Selection
SELECTION-SCREEN BEGIN OF SCREEN 9003 AS WINDOW TITLE text-008.

SELECTION-SCREEN BEGIN OF BLOCK block4 WITH FRAME TITLE text-001.
PARAMETERS:
  p_bukrs1 LIKE bsid-bukrs DEFAULT '8020' OBLIGATORY,
  p_vkbur1 LIKE knvv-vkbur OBLIGATORY.
SELECT-OPTIONS:
*  s_vkbur1 FOR knvv-vkbur OBLIGATORY,
  s_zfoid1 FOR zfod-zfoid OBLIGATORY,
  s_stat1  FOR zfod-status,
  s_kdgrp1 FOR knvv-kdgrp,
*  s_xref11 FOR char4,
  s_xref11 FOR char8,
  s_xref21 FOR char6,
  s_zuonr1 FOR bsid-zuonr,
  s_kunnr1 FOR bsid-kunnr.
SELECTION-SCREEN END OF BLOCK block4.

SELECTION-SCREEN END OF SCREEN 9003.

*Report FO Selection
*SELECTION-SCREEN BEGIN OF SCREEN 9004 AS WINDOW TITLE text-009.
SELECTION-SCREEN BEGIN OF SCREEN 9004 AS WINDOW TITLE va_title.

SELECTION-SCREEN BEGIN OF BLOCK block5 WITH FRAME TITLE text-001.
PARAMETERS:
  p_bukrs2 LIKE bsid-bukrs DEFAULT '8020' OBLIGATORY,
  p_vkbur2 LIKE knvv-vkbur OBLIGATORY.
SELECT-OPTIONS:
*  s_vkbur2 FOR knvv-vkbur OBLIGATORY,
  s_zfoid2 FOR zfod-zfoid OBLIGATORY,
  s_fodat2 FOR zfod-fodat,
  s_stat2  FOR zfod-status,
  s_kdgrp2 FOR knvv-kdgrp MODIF ID bud,
*  s_xref12 FOR char4 MODIF ID bud,
  s_xref12 FOR char8 MODIF ID bud,
  s_xref22 FOR char6 MODIF ID bud,
  s_zuonr2 FOR bsid-zuonr MODIF ID bud,
  s_kunnr2 FOR bsid-kunnr MODIF ID bud.
SELECTION-SCREEN END OF BLOCK block5.

SELECTION-SCREEN BEGIN OF BLOCK block6 WITH FRAME TITLE text-096.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio11 RADIOBUTTON GROUP grp2 DEFAULT 'X'
                                           USER-COMMAND grp2
                                           MODIF ID bud.
SELECTION-SCREEN COMMENT 5(30) text-097 FOR FIELD radio11
                                           MODIF ID bud.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio31 RADIOBUTTON GROUP grp2
                                           MODIF ID bud.
SELECTION-SCREEN COMMENT 5(30) text-099 FOR FIELD radio31
                                           MODIF ID bud.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio21 RADIOBUTTON GROUP grp2
                                           MODIF ID bud.
SELECTION-SCREEN COMMENT 5(30) text-098 FOR FIELD radio21
                                           MODIF ID bud.
SELECTION-SCREEN POSITION 45.
PARAMETERS : p_rekap AS CHECKBOX MODIF ID bd1.
SELECTION-SCREEN COMMENT 48(20) text-012 FOR FIELD p_rekap
                                           MODIF ID bd1.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio41 RADIOBUTTON GROUP grp2
                                           MODIF ID bud.
SELECTION-SCREEN COMMENT 5(30) text-083 FOR FIELD radio41
                                           MODIF ID bud.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio51 RADIOBUTTON GROUP grp2
                                           MODIF ID bud.
SELECTION-SCREEN COMMENT 5(30) text-084 FOR FIELD radio51
                                           MODIF ID bud.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN END OF BLOCK block6.

SELECTION-SCREEN END OF SCREEN 9004.

*Close FO Selection
SELECTION-SCREEN BEGIN OF SCREEN 9005 AS WINDOW TITLE text-010.

SELECTION-SCREEN BEGIN OF BLOCK block8 WITH FRAME TITLE text-010.
PARAMETERS:
  p_bukrs3 LIKE bsid-bukrs DEFAULT '8020' OBLIGATORY,
  p_vkbur3 LIKE knvv-vkbur OBLIGATORY.
SELECT-OPTIONS:
*  s_vkbur3 FOR knvv-vkbur OBLIGATORY,
  s_zfoid3 FOR zfod-zfoid OBLIGATORY.
*  s_fodat3 FOR zfod-fodat,
*  s_kdgrp3 FOR knvv-kdgrp,
*  s_xref13 FOR char4,
*  s_xref23 FOR char6,
*  s_zuonr3 FOR bsid-zuonr,
*  s_kunnr3 FOR bsid-kunnr.
SELECTION-SCREEN END OF BLOCK block8.

SELECTION-SCREEN END OF SCREEN 9005.

*Menu Faktur Opname
SELECTION-SCREEN BEGIN OF BLOCK block9 WITH FRAME TITLE text-090.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio1 RADIOBUTTON GROUP grp1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(30) text-091 FOR FIELD radio1.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(30) text-092 FOR FIELD radio2.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(30) text-093 FOR FIELD radio3.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(30) text-094 FOR FIELD radio4.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(30) text-095 FOR FIELD radio5.
SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN END OF BLOCK block9.

*Include
INCLUDE zghmmalv001.        "ALV
INCLUDE zabp_frm.           "SmartForms
INCLUDE zabp_smartform.     "SmartForms

*
* VALIDATE FOR SELECTION
*------------------------
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF radio3 = 'X'.
      IF radio21 NE 'X' AND
         radio41 NE 'X' AND
         radio51 NE 'X'.
        IF screen-group1 = 'BD1'.
          screen-active = '0'.
        ENDIF.
      ENDIF.
    ELSEIF radio4 = 'X'.
      IF screen-group1 = 'BUD' OR
         screen-group1 = 'BD1'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

*At Selection Screen
AT SELECTION-SCREEN ON s_bschl.
  IF x_shbv = 'X'.
    IF s_bschl IS INITIAL.
      s_bschl-low = 'T'.
      s_bschl-sign = 'I'.
      s_bschl-option = 'EQ'.
      APPEND s_bschl.
*     S_BSCHL-LOW = 'U'.
*     S_BSCHL-SIGN = 'I'.
*     S_BSCHL-OPTION = 'EQ'.
*     APPEND S_BSCHL.
      s_bschl-low = 'V'.
      s_bschl-sign = 'I'.
      s_bschl-option = 'EQ'.
      APPEND s_bschl.
    ENDIF.
  ELSE.
    CLEAR s_bschl. REFRESH s_bschl.
  ENDIF.

* for alv variant
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f_f4_for_variant_alv USING p_vari.

INITIALIZATION.
  DATA: lv_parva(40).

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'BUK'.

  IF sy-subrc EQ 0.
    pa_bukrs  = lv_parva.
    p_bukrs1  = lv_parva.
    p_bukrs2  = lv_parva.
    p_bukrs3  = lv_parva.
  ENDIF.

* Process Selection
START-OF-SELECTION.

  CASE 'X'.
    WHEN radio1.
      CALL SELECTION-SCREEN 9002.
      IF sy-subrc = 0.
        PERFORM f_cek_authority USING pa_vkbur.
        PERFORM f_create_fo.
      ENDIF.
    WHEN radio2.
      CALL SELECTION-SCREEN 9003.
      IF sy-subrc = 0.
        PERFORM f_cek_authority USING p_vkbur1.
        PERFORM f_input_fo.
      ENDIF.
    WHEN radio3.
      va_title = text-009.
      CALL SELECTION-SCREEN 9004.
      IF sy-subrc = 0.
        PERFORM f_cek_authority USING p_vkbur2.
        PERFORM f_report_fo.
      ENDIF.
    WHEN radio4.
      va_title = text-011.
      CALL SELECTION-SCREEN 9004.
      IF sy-subrc = 0.
        radio11 = 'X'. CLEAR radio21.
        PERFORM f_cek_authority USING p_vkbur2.
        PERFORM f_report_fo.
      ENDIF.
    WHEN radio5.
      AUTHORITY-CHECK OBJECT 'ZGHFOCLOS'
                ID 'ACTVT' FIELD '02'.
      IF sy-subrc <> 0.
        MESSAGE i002(zz) WITH
        'You have no authorization for Close Faktur Opname' pa_vkbur.
        STOP.
      ENDIF.
      CALL SELECTION-SCREEN 9005.
      IF sy-subrc = 0.
        PERFORM f_cek_authority USING p_vkbur3.
        PERFORM f_close_fo.
      ENDIF.
  ENDCASE.

*&---------------------------------------------------------------------*
*&      Form  f_f4_for_variant_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_VARI  text
*----------------------------------------------------------------------*
FORM f_f4_for_variant_alv USING fc_variant.

  DATA: ld_variant LIKE disvariant.
  DATA: ld_repid   LIKE sy-repid.
  ld_repid = sy-repid.
  ld_variant-report   = ld_repid.
  ld_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ld_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ld_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    fc_variant = ld_variant-variant.
  ENDIF.

ENDFORM.                    " f_f4_for_variant_alv

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.

  IF x_norm EQ 'X' AND x_shbv EQ 'X'.
    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers
           b~vkbur b~kdgrp c~zterm d~sortl
    INTO CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                     b~vkorg EQ pa_bukrs
                   JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                     c~bukrs EQ a~bukrs
                   JOIN kna1 AS d ON a~kunnr EQ d~kunnr
    WHERE a~bukrs EQ pa_bukrs AND
          a~kunnr IN so_kunnr AND
          budat LE pa_budat   AND
          a~umskz EQ space    AND
          a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
*          b~vkbur IN so_vkbur AND
          b~vkbur EQ pa_vkbur AND
          b~vtweg EQ '10'     AND
          c~pernr IN so_pernr AND
          b~kdgrp IN so_kdgrp  AND
          a~zuonr IN so_zuonr.

    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers
           b~vkbur b~kdgrp c~zterm d~sortl
    APPENDING  CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsad AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                      b~vkorg EQ pa_bukrs
                   JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                     c~bukrs EQ a~bukrs
                   JOIN kna1 AS d ON a~kunnr EQ d~kunnr
    WHERE a~bukrs EQ pa_bukrs AND
          a~kunnr IN so_kunnr AND
          budat LE pa_budat   AND
          a~augdt GT pa_budat AND
          a~umskz EQ space    AND
          a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
*          b~vkbur IN so_vkbur AND
          b~vkbur EQ pa_vkbur AND
          b~vtweg EQ '10'     AND
          c~pernr IN so_pernr AND
          b~kdgrp IN so_kdgrp AND
          a~zuonr IN so_zuonr.

    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers
           b~vkbur b~kdgrp c~zterm d~sortl
    APPENDING  CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                     b~vkorg EQ pa_bukrs
                   JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                     c~bukrs EQ a~bukrs
                   JOIN kna1 AS d ON a~kunnr EQ d~kunnr
    WHERE a~bukrs EQ pa_bukrs AND
          a~kunnr IN so_kunnr AND
          budat LE pa_budat   AND
          a~umskz IN s_bschl  AND
          a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
*          b~vkbur IN so_vkbur AND
          b~vkbur EQ pa_vkbur AND
          b~vtweg EQ '10'     AND
          c~pernr IN so_pernr AND
          b~kdgrp IN so_kdgrp AND
          a~zuonr IN so_zuonr.

    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers
           b~vkbur b~kdgrp c~zterm d~sortl
    APPENDING  CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                     b~vkorg EQ pa_bukrs
                   JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                     c~bukrs EQ a~bukrs
                   JOIN kna1 AS d ON a~kunnr EQ d~kunnr
    WHERE a~bukrs EQ pa_bukrs AND
          a~kunnr IN so_kunnr AND
          budat LE pa_budat   AND
          a~augdt GT pa_budat  AND
          a~umskz IN s_bschl  AND
          a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
*          b~vkbur IN so_vkbur AND
          b~vkbur EQ pa_vkbur AND
          b~vtweg EQ '10'     AND
          c~pernr IN so_pernr AND
          b~kdgrp IN so_kdgrp AND
          a~zuonr IN so_zuonr.

  ENDIF.

  IF x_norm EQ 'X' AND x_shbv EQ space.
    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers
           b~vkbur b~kdgrp c~zterm d~sortl
    INTO CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsid AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                      b~vkorg EQ pa_bukrs
                   JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                     c~bukrs EQ a~bukrs
                   JOIN kna1 AS d ON a~kunnr EQ d~kunnr
    WHERE a~bukrs EQ pa_bukrs AND
          a~kunnr IN so_kunnr AND
          budat LE pa_budat   AND
          a~umskz EQ space    AND
          a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
*          b~vkbur IN so_vkbur AND
          b~vkbur EQ pa_vkbur AND
          b~vtweg EQ '10'     AND
          c~pernr IN so_pernr AND
          b~kdgrp IN so_kdgrp AND
          a~zuonr IN so_zuonr.

    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers
           b~vkbur b~kdgrp c~zterm d~sortl
    APPENDING CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsad AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                      b~vkorg EQ pa_bukrs
                   JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                     c~bukrs EQ a~bukrs
                   JOIN kna1 AS d ON a~kunnr EQ d~kunnr
    WHERE a~bukrs EQ pa_bukrs AND
          a~kunnr IN so_kunnr AND
          budat LE pa_budat   AND
          a~augdt GT pa_budat AND
          a~umskz EQ space    AND
          a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
*          b~vkbur IN so_vkbur AND
          b~vkbur EQ pa_vkbur AND
          b~vtweg EQ '10'     AND
          c~pernr IN so_pernr AND
          b~kdgrp IN so_kdgrp AND
          a~zuonr IN so_zuonr.

  ENDIF.

  IF x_norm EQ space AND x_shbv EQ 'X'.
    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers
           b~vkbur b~kdgrp c~zterm d~sortl
    INTO CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                     b~vkorg EQ pa_bukrs
                   JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                     c~bukrs EQ a~bukrs
                   JOIN kna1 AS d ON a~kunnr EQ d~kunnr
    WHERE a~bukrs EQ pa_bukrs AND
          a~kunnr IN so_kunnr AND
          budat LE pa_budat   AND
          a~umskz IN s_bschl  AND
          a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
*          b~vkbur IN so_vkbur AND
          b~vkbur EQ pa_vkbur AND
          b~vtweg EQ '10'     AND
          c~pernr IN so_pernr AND
          b~kdgrp IN so_kdgrp AND
          a~zuonr IN so_kunnr.

    SELECT a~bukrs a~kunnr a~gjahr a~belnr a~budat a~monat a~bschl
           a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2
           a~umskz a~bldat a~xref1 a~sgtxt a~waers
           b~vkbur b~kdgrp c~zterm d~sortl
    APPENDING  CORRESPONDING FIELDS OF TABLE it_bsid
    FROM bsad AS a JOIN  knvv AS b ON a~kunnr EQ b~kunnr AND
                                      b~vkorg EQ pa_bukrs
                   JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                     c~bukrs EQ a~bukrs
                   JOIN kna1 AS d ON a~kunnr EQ d~kunnr
    WHERE a~bukrs EQ pa_bukrs AND
          a~kunnr IN so_kunnr AND
          budat LE pa_budat   AND
          a~augdt GT pa_budat AND
          a~umskz IN s_bschl  AND
          a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
*          b~vkbur IN so_vkbur AND
          b~vkbur EQ pa_vkbur AND
          b~vtweg EQ '10'     AND
          c~pernr IN so_pernr AND
          b~kdgrp IN so_kdgrp AND
          a~zuonr IN so_zuonr.
  ENDIF.

  CHECK NOT it_bsid[] IS INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE i_giro
    FROM zfbicheck
    WHERE bukrs EQ pa_bukrs AND
*          vkbur IN so_vkbur AND
          vkbur EQ pa_vkbur AND
          pcair EQ space AND
          kunnr IN so_kunnr
    ORDER BY PRIMARY KEY.

  SELECT *
    APPENDING CORRESPONDING FIELDS OF TABLE i_giro
    FROM zfbicheck
    WHERE bukrs EQ pa_bukrs AND
*          vkbur IN so_vkbur AND
          vkbur EQ pa_vkbur AND
          pcair EQ 'C'      AND
          erdt2 GT pa_budat AND
          kunnr IN so_kunnr
    ORDER BY PRIMARY KEY.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE i_giro_sfa
    FROM zfbic_sfa
    WHERE bukrs EQ pa_bukrs AND
*          vkbur IN so_vkbur AND
          vkbur EQ pa_vkbur AND
          pcair EQ space AND
          kunnr IN so_kunnr
    ORDER BY PRIMARY KEY.

  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE i_giro_sfa
    FROM zfbic_sfa
    WHERE bukrs EQ pa_bukrs AND
*          vkbur IN so_vkbur AND
          vkbur EQ pa_vkbur AND
          pcair EQ 'C'      AND
          erdt2 GT pa_budat AND
          kunnr IN so_kunnr
    ORDER BY PRIMARY KEY.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE i_zfod
    FROM zfod AS a JOIN zfos AS b ON a~bukrs = b~bukrs AND
                                     a~vkbur = b~vkbur AND
                                     a~zfoid = b~zfoid
    WHERE a~bukrs EQ pa_bukrs  AND
*          a~vkbur IN so_vkbur AND
          a~vkbur EQ pa_vkbur AND
          kunnr IN so_kunnr AND
          kdgrp IN so_kdgrp AND
          xref1 IN so_xref1 AND
          xref2 IN so_xref2 AND
          zuonr IN so_zuonr AND
          budat LE pa_budat AND
          b~zclos = space.

  SELECT kunnr name1 name2 ort01
    INTO CORRESPONDING FIELDS OF TABLE i_kna1
    FROM kna1
    FOR ALL ENTRIES IN it_bsid
    WHERE kunnr EQ it_bsid-kunnr
    ORDER BY PRIMARY KEY.

  SELECT vkbur bezei
    INTO CORRESPONDING FIELDS OF TABLE i_tvkbt
    FROM tvkbt
    WHERE spras = sy-langu AND
          vkbur = pa_vkbur.

ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.

  DATA : l_kunnr LIKE vbpa-kunnr,
         l_pernr LIKE vbpa-pernr,
         l_selisih(3)  TYPE n,
         l_mahdt LIKE vbak-mahdt,
         l_audat LIKE vbak-audat,
         l_str TYPE i,
         l_count TYPE i,
         l_tmp(6) TYPE n,
         l_tmp1(4) TYPE n.

  DATA : l_cchek LIKE zfbicheck-cchek,
         l_duedt LIKE zfbicheck-duedt,
*         l_bbeln LIKE zfbicheck-bbeln,
         l_bbeln LIKE zfbic_sfa-bbeln,
         l_belnr LIKE bsid-belnr,
         l_due LIKE bsid-budat,
         l_gjahr LIKE bsid-gjahr,
         l_live LIKE zplbc-live,
         l_amount LIKE bsid-dmbtr,
         l_foid LIKE zfos-zfoid.

  SELECT a~vstel a~werks a~lgort b~live
    INTO CORRESPONDING FIELDS OF TABLE i_live
    FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
                                       a~lgort = b~lgort
    WHERE b~bukrs EQ pa_bukrs   AND
          b~live  EQ space.

*Completed it_bsid
  LOOP AT it_bsid.

    IF it_bsid-blart EQ 'RV'.
      SELECT SINGLE kunnr
        INTO l_kunnr
        FROM vbpa
        WHERE vbeln EQ it_bsid-belnr AND
              parvw EQ 'ZC'.
      IF sy-subrc EQ 0.
        CASE it_bsid-bukrs.
          WHEN '8020'.
            it_bsid-xref1 = l_kunnr+6(4).
          WHEN '8070'.
            it_bsid-xref1 = l_kunnr.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
      SELECT SINGLE pernr
        INTO l_pernr
        FROM vbpa
        WHERE vbeln EQ it_bsid-belnr AND
*              parvw EQ 'ZP'.
              parvw EQ 'VE'.
      IF sy-subrc EQ 0.
        CASE it_bsid-bukrs.
          WHEN '8020'.
            it_bsid-slcode = l_pernr+2(6).
          WHEN '8070'.
            it_bsid-slcode = l_pernr+2(6).
          WHEN OTHERS.
        ENDCASE.
      ELSE.
        it_bsid-slcode = '10000'.
      ENDIF.
    ELSE.
      l_str = STRLEN( it_bsid-xref2 ).
      IF l_str <= 6.
        l_tmp = it_bsid-xref2.
        it_bsid-xref2 = l_tmp.
      ELSE.
        l_count = l_str - 6.
        it_bsid-xref2 = it_bsid-xref2+l_count(6).
      ENDIF.
      l_str = STRLEN( it_bsid-xref1 ).
      IF l_str <= 4.
        l_tmp1 = it_bsid-xref1.
        it_bsid-xref1 = l_tmp1.
      ELSE.
        l_count = l_str - 4.
        it_bsid-xref1 = it_bsid-xref1+l_count(4).
      ENDIF.
      it_bsid-slcode = it_bsid-xref2.
    ENDIF.

*Check ke Route list
*    IF NOT it_bsid-xref1(4) IN so_xref1.
    IF NOT it_bsid-xref1 IN so_xref1.
      DELETE it_bsid.
      CONTINUE.
    ENDIF.

*Check ke Salesman
    IF NOT it_bsid-slcode IN so_xref2.
      DELETE it_bsid.
      CONTINUE.
    ENDIF.

*Check ke table ZFOD
    READ TABLE i_zfod WITH KEY bukrs = it_bsid-bukrs
                               vkbur = it_bsid-vkbur
                               kunnr = it_bsid-kunnr
                               zuonr = it_bsid-zuonr.
    IF sy-subrc = 0.
      DELETE it_bsid.
      CONTINUE.
    ENDIF.

    IF it_bsid-vkbur EQ space.
      it_bsid-vkbur = '0200'.
    ENDIF.

    CLEAR i_kna1.
    READ TABLE i_kna1 WITH KEY kunnr = it_bsid-kunnr.
    it_bsid-name1 = i_kna1-name1.
    it_bsid-name2 = i_kna1-name2.
    it_bsid-ort01 = i_kna1-ort01.

    CLEAR i_tvkbt.
    READ TABLE i_tvkbt WITH KEY vkbur = it_bsid-vkbur.
    it_bsid-bezei = i_tvkbt-bezei.

    MODIFY it_bsid.

    MOVE it_bsid-vkbur TO it_brcust-vkbur.
    MOVE it_bsid-kunnr TO it_brcust-kunnr.
    MOVE it_bsid-zuonr TO it_brcust-zuonr.
    COLLECT it_brcust.

  ENDLOOP.

*Customer Key
  SORT it_brcust BY vkbur kunnr zuonr.

*Summary Table by Cust & Zuonr
  CLEAR i_popupline. REFRESH i_popupline.
  LOOP AT it_brcust.

    AT FIRST.
      i_popupline-hell = 'X'.
      CONCATENATE 'No FO' 'Cabang'
            INTO i_popupline-text SEPARATED BY '    '.
      APPEND i_popupline. CLEAR i_popupline.
    ENDAT.

    AT NEW vkbur.
      CLEAR: l_foid.
      SELECT SINGLE MAX( zfoid ) INTO l_foid
        FROM zfos
        WHERE bukrs = pa_bukrs AND
              vkbur = it_brcust-vkbur.
      ADD 1 TO l_foid.

      READ TABLE it_bsid WITH KEY vkbur = it_brcust-vkbur.
      CONCATENATE l_foid '/' it_brcust-vkbur it_bsid-bezei
            INTO i_popupline-text SEPARATED BY space.
      APPEND i_popupline. CLEAR i_popupline.

      i_zfos-bukrs = pa_bukrs.
      i_zfos-vkbur = it_brcust-vkbur.
      i_zfos-zfoid = l_foid.
      i_zfos-fodat = sy-datum.
      APPEND i_zfos.
    ENDAT.

    CLEAR : itab, l_duedt, l_bbeln.

    AT NEW zuonr.
      itab-count = 1.
    ENDAT.

    MOVE it_brcust-kunnr TO itab-kunnr.
    MOVE it_brcust-zuonr TO itab-zuonr.
    itab-zfoid = l_foid.

    SORT it_bsid BY kunnr zuonr budat DESCENDING.
    LOOP AT it_bsid WHERE kunnr EQ it_brcust-kunnr AND
                          zuonr EQ it_brcust-zuonr.

      IF it_bsid-shkzg EQ 'H'.
        it_bsid-dmbtr = it_bsid-dmbtr * -1.
      ENDIF.
      itab-bill = itab-bill + it_bsid-dmbtr.
      IF it_bsid-blart NE 'DZ'.
        itab-budat = it_bsid-budat.
        IF it_bsid-bschl EQ '01'.
          IF it_bsid-zuonr(1) = 'C'.
            l_due = it_bsid-budat + it_bsid-zbd1t.
          ELSE.
            l_due = it_bsid-zfbdt + it_bsid-zbd1t.
          ENDIF.

        ELSE.
          l_due = it_bsid-zfbdt.
        ENDIF.
        IF l_due > pa_budat.
          itab-due = '2'.
        ELSEIF l_due EQ pa_budat.
          itab-due = '1'.
        ELSEIF l_due < pa_budat.
          itab-due = '3'.
        ENDIF.
        itab-top = pa_budat - it_bsid-bldat.
      ENDIF.
      MOVE it_bsid-bukrs TO itab-bukrs.
      MOVE it_bsid-vkbur TO itab-vkbur.
      MOVE it_bsid-bezei TO itab-bezei.
      MOVE it_bsid-name1 TO itab-name1.
      MOVE it_bsid-sortl TO itab-sortl.
      MOVE it_bsid-xref1 TO itab-xref1.
      MOVE it_bsid-slcode TO itab-xref2.
      MOVE it_bsid-kdgrp TO itab-kdgrp.
      MOVE it_bsid-belnr TO itab-belnr.
      MOVE it_bsid-zterm TO itab-zterm.
      MOVE it_bsid-gjahr TO itab-gjahr.
      MOVE it_bsid-waers TO itab-waers.
      IF it_bsid-blart NE 'DZ'.
        itab-faktur = it_bsid-dmbtr.
        l_belnr = it_bsid-belnr.
        l_gjahr = it_bsid-gjahr.
      ENDIF.
      MOVE it_bsid-sgtxt TO itab-sgtxt.
    ENDLOOP.

    LOOP AT i_giro WHERE bukrs EQ it_bsid-bukrs AND vkbur EQ itab-vkbur
                         AND gjahr EQ l_gjahr AND
                         kunnr EQ it_brcust-kunnr AND
                         zuonr EQ it_brcust-zuonr.
      itab-giro = itab-giro + i_giro-cchek.
      l_duedt = i_giro-duedt.
      l_bbeln = i_giro-bbeln.
    ENDLOOP.

    LOOP AT i_giro_sfa WHERE bukrs EQ it_bsid-bukrs
                         AND vkbur EQ itab-vkbur
*                         AND tahun EQ l_gjahr
                         AND kunnr EQ it_brcust-kunnr
                         AND zuonr EQ it_brcust-zuonr.
      itab-giro = itab-giro + i_giro_sfa-bank_amt.
      l_duedt = i_giro_sfa-bank_dudat.
      l_bbeln = i_giro_sfa-bbeln.
    ENDLOOP.

    IF l_bbeln EQ space.
      SELECT MAX( bbeln ) INTO l_bbeln FROM zfbid
      WHERE bukrs EQ it_bsid-bukrs AND vkbur EQ itab-vkbur AND
            gjahr EQ l_gjahr AND bflag NE 'D' AND
            kunnr EQ it_brcust-kunnr AND zuonr EQ it_brcust-zuonr.
      IF sy-subrc NE 0.
        SELECT MAX( bbeln ) INTO l_bbeln FROM zfbid_sfa
        WHERE bukrs EQ it_bsid-bukrs AND vkbur EQ itab-vkbur AND
              gjahr EQ l_gjahr AND bflag NE 'D' AND
              kunnr EQ it_brcust-kunnr AND zuonr EQ it_brcust-zuonr.
      ENDIF.
    ENDIF.
    itab-duedt = l_duedt.
    itab-bbeln = l_bbeln.

    IF it_bsid-blart EQ 'DZ' AND itab-due EQ space.
      itab-budat = it_bsid-budat.
      l_due = it_bsid-zfbdt + it_bsid-zbd1t.
      IF l_due > pa_budat.
        itab-due = '2'.
      ELSEIF l_due EQ pa_budat.
        itab-due = '1'.
      ELSEIF l_due < pa_budat.
        itab-due = '3'.
      ENDIF.
    ENDIF.
    itab-zfbdt = l_due.
    itab-zbd1t = it_bsid-zbd1t.
    itab-giro = itab-giro .
    itab-bill = itab-bill - itab-giro.
*    itab-ending = itab-bill - itab-giro.

    SELECT SINGLE klimk INTO itab-klimk FROM knkk
      WHERE kunnr EQ itab-kunnr.

*    SELECT SINGLE b~live
*      FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
*                                         a~lgort = b~lgort
*      INTO l_live
*      WHERE b~bukrs EQ pa_bukrs   AND
*            a~vstel EQ itab-vkbur AND
*            b~live  EQ space.
    READ TABLE i_live WITH KEY vstel = itab-vkbur.
    IF sy-subrc EQ 0.
      MOVE itab-kunnr TO itab-kunnr1.
      MOVE itab-sortl TO itab-kunnr.
    ENDIF.

    itab-gidat = itab-duedt.
    itab-fodat = sy-datum.

    IF itab-giro = 0 AND itab-bill = 0.
      CONTINUE.
    ENDIF.

    APPEND itab. CLEAR itab.

  ENDLOOP.

ENDFORM.                    " f_process_data

*&---------------------------------------------------------------------*
*&      Form  f_gui_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0319   text
*      -->P_0320   text
*----------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "f_gui_message

*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear_alv_data.

  CLEAR:t_alv_fieldcat,
        t_alv_event,
        t_events,
        t_alv_isort,
        t_alv_filter,
        t_event_exit,
        d_alv_isort,
        d_alv_variant,
        d_alv_list_scroll,
        d_alv_sort_postn,
        d_alv_keyinfo,
        d_alv_fieldcat,
        d_alv_formname,
        d_alv_ucomm,
        d_alv_print,
        d_alv_repid,
        d_alv_tabix,
        d_alv_subrc,
        d_alv_screen_start_column,
        d_alv_screen_start_line,
        d_alv_screen_end_column,
        d_alv_screen_end_line,
        d_alv_layout,
        d_layout,
        d_repid,
        d_print.

  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.

ENDFORM.                    " f_clear_alv_data

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FT_REPORT  text
*----------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_header ft_detail.

  DATA: ld_jdl(20).
  REFRESH: t_alv_fieldcat.

  DEFINE mac_header.
    read table i_status index &1.
    if sy-subrc eq 0.
      ld_jdl = i_status-ddtext.
      perform f_fieldcatg using 'I_ZFODSUMD':
      'AMT&1' '' '' '' '20' ld_jdl 'X' '' '' 'IDR' '' '' '' '' '' '' ''
      '' ''.
    endif.
  END-OF-DEFINITION.

*  IF radio1 = 'X'.
*    PERFORM f_fieldcatg USING 'I_HEADER':
*      'VKBUR' '' '' '' '10' 'SlOf' '' '' '' '' '' '' '' '' '' '' ''
*      '' '',
*      'ZFOID' '' '' '' '6' 'FO No' '' '' '' '' '' '' '' '' '' '' ''
*      '' ''.
*    PERFORM f_fieldcatg USING 'I_DETAIL':
*      'VKBUR' '' '' 'X' '10' 'SlOf' '' '' '' '' '' '' '' '' '' '' ''
*      '' '',
*      'ZFOID' '' '' 'X' '6' 'FO No' '' '' '' '' '' '' '' '' '' '' ''
*      '' '',
*      'KUNNR' '' '' '' '13' 'Customer' '' '' '' '' '' '' '' '' 'X' ''
*''
*      '' '',
*      'NAME1' '' '' '' '35' 'Customer Name' '' '' '' '' '' '' '' '' 'X'
*      '' '' '' '',
*      'ZUONR' '' '' '' '13' 'DO Number' '' '' '' '' '' '' '' '' 'X' ''
*      '' '' '',
*      'XREF2' '' '' '' '8' 'Salesman' '' '' '' '' '' '' '' '' '' '' ''
*      '' '',
*      'BUDAT' '' '' '' '10' 'Post Date' '' '' '' '' '' '' '' '' '' ''
*      '' '' '',
*      'ZFBDT' '' '' '' '10' 'Due Date' '' '' '' '' '' '' '' '' '' '' ''
*      '' '',
*      'DUEDT' '' '' '' '10' 'Due Giro' '' '' '' '' '' '' '' '' '' '' ''
*      '' '',
*      'GIRO' '' '' '' '15' 'Giro' 'X' '' '' 'IDR' '' '' '' '' '' '' ''
*      '' '',
*      'BILL' '' '' '' '15' 'Billing' 'X' '' '' 'IDR' '' '' '' '' '' ''
*      '' '' '',
*      'FAKTUR' '' '' '' '15' 'Faktur' 'X' '' '' 'IDR' '' '' '' '' '' ''
*      '' '' '',
*      'STATUS' '' '' '' '10' 'Status' '' '' '' '' '' '' '' '' '' '' ''
*      '' '',
*      'TEXT' '' '' '' '20' 'Keterangan' '' '' '' '' '' '' '' '' '' ''
*      '' '' ''.
*  ELSEIF radio2 = 'X'.
*    PERFORM f_fieldcatg USING ft_report:
*      'VKBUR' '' '' 'X' '6' 'SlOff' '' '' '' '' '' '' '' '' '' '' ''
*      '' '',
*      'ZFOID' '' '' 'X' '6' 'No FO' '' '' '' '' '' '' '' '' '' '' ''
*      '' '',
*      'KUNNR' '' '' '' '13' 'Customer' '' '' '' '' '' '' '' '' 'X' ''
*      '' '' '',
*      'NAME1' '' '' '' '35' 'Customer Name' '' '' '' '' '' '' '' ''
*      'X' '' '' '' '',
*      'ZUONR' '' '' '' '13' 'DO Number' '' '' '' '' '' '' '' '' 'X' ''
*      '' '' '',
*      'XREF2' '' '' '' '8' 'Salesman' '' '' '' '' '' '' '' '' '' '' ''
*      '' '',
*      'BUDAT' '' '' '' '10' 'Post Date' '' '' '' '' '' '' '' '' '' ''
*      '' '' '',
*      'ZFBDT' '' '' '' '10' 'Due Date' '' '' '' '' '' '' '' '' '' ''
*      '' '' '',
*      'DUEDT' '' '' '' '10' 'Due Giro' '' '' '' '' '' '' '' '' '' ''
*      '' '' '',
*      'GIRO' '' '' '' '15' 'Giro' 'X' '' '' 'IDR' '' '' '' '' '' '' ''
*      '' '',
*      'BILL' '' '' '' '15' 'Billing' 'X' '' '' 'IDR' '' '' '' '' '' ''
*      '' '' '',
*      'FAKTUR' '' '' '' '15' 'Faktur' 'X' '' '' 'IDR' '' '' '' '' ''
*      '' '' '' '',
*      'STATUS' 'ZFOD' 'STATUS' '' '6' 'Status' '' '' '' '' '' '' ''
*      '' '' 'X' '' '' 'ZFOSTS',
*      'TEXT' '' '' '' '20' 'Status Text' '' '' '' '' '' '' '' '' '' ''
*      '' '' '',
*      'TEXT2' '' '' '' '50' 'Keterangan' '' '' '' '' '' '' '' '' ''
*      'X' '' '' ''.
*  ELSEIF ( radio3 = 'X' AND v_ucomm NE '&IC1' ) OR
*         ( radio4 = 'X' AND v_ucomm NE '&IC1' ).
*    IF radio11 = 'X'.
*      PERFORM f_fieldcatg USING ft_report:
*        'ZFOID' '' '' '' '6' 'No FO' '' '' '' '' '' '' '' '' 'X' '' ''
*        '' '',
*        'KUNNR' '' '' '' '13' 'Customer' '' '' '' '' '' '' '' '' 'X' ''
*        '' '' '',
*        'NAME1' '' '' '' '35' 'Customer Name' '' '' '' '' '' '' '' ''
*        'X' '' '' '' '',
*        'ZUONR' '' '' '' '13' 'DO Number' '' '' '' '' '' '' '' '' 'X'
*''
*        '' '' '',
*        'XREF2' '' '' '' '8' 'Salesman' '' '' '' '' '' '' '' '' '' ''
*''
*        '' '',
*        'BUDAT' '' '' '' '10' 'Post Date' '' '' '' '' '' '' '' '' '' ''
*        '' '' '',
*        'ZFBDT' '' '' '' '10' 'Due Date' '' '' '' '' '' '' '' '' '' ''
*        '' '' '',
*        'DUEDT' '' '' '' '10' 'Due Giro' '' '' '' '' '' '' '' '' '' ''
*        '' '' '',
*        'GIRO' '' '' '' '15' 'Giro' 'X' '' '' 'IDR' '' '' '' '' '' ''
*''
*        '' '',
*        'BILL' '' '' '' '15' 'Billing' 'X' '' '' 'IDR' '' '' '' '' ''
*''
*        '' '' '',
*        'FAKTUR' '' '' '' '15' 'Faktur' 'X' '' '' 'IDR' '' '' '' '' ''
*        '' '' '' '',
*        'STATUS' 'ZFOD' 'STATUS' '' '10' 'Status' '' '' '' '' '' '' ''
*        '' '' '' '' '' 'ZFOSTS'.
*      IF radio3 = 'X'.
*        PERFORM f_fieldcatg USING ft_report:
*        'TEXT' '' '' '' '20' 'Text Status' '' '' '' '' '' '' '' '' ''
*''
*        '' '' ''.
*      ENDIF.
*      PERFORM f_fieldcatg USING ft_report:
*        'TEXT2' '' '' '' '30' 'Keterangan' '' '' '' '' '' '' '' '' ''
*''
*        '' '' '',
*        'FODAT' '' '' 'X' '10' 'FO Date' '' '' '' '' '' '' '' '' '' ''
*        '' '' '',
*        'KDGRP' '' '' 'X' '5' 'GrpCs' '' '' '' '' '' '' '' '' '' ''
*        '' '' '',
*        'XREF1' '' '' 'X' '6' 'Rayon' '' '' '' '' '' '' '' '' '' ''
*        '' '' '',
*        'BELNR' '' '' 'X' '10' 'Acc Doc.' '' '' '' '' '' '' '' '' '' ''
*        '' '' '',
*        'BBELN' '' '' 'X' '10' 'BI Number' '' '' '' '' '' '' '' '' ''
*''
*        '' '' '',
*        'GIDAT' '' '' 'X' '10' 'Giro Date' '' '' '' '' '' '' '' '' ''
*''
*        '' '' '',
*        'ZCLOS' '' '' '' '5' 'Close' '' '' '' '' '' '' '' '' '' '' ''
*        '' ''.
*    ELSEIF radio21 = 'X'.
  PERFORM f_fieldcatg USING 'I_ZFODSUM':
*      'VKBUR' '' '' '' '10' 'SlOf' '' '' '' '' '' '' '' '' '' '' '' ''
*      '',
  'ZFOID' '' '' '' '6' 'FO No' '' '' '' '' '' '' '' '' '' '' '' ''
  '',
  'XREF1' '' '' '' '10' 'Rayon' '' '' '' '' '' '' '' '' '' '' ''
  '' '',
  'NAME1' '' '' '' '35' 'Rayon Description' '' '' '' '' '' '' '' ''
  '' '' '' '' ''.

  mac_header : 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.

  PERFORM f_fieldcatg USING 'I_ZFODSUMD':
*       'STATUS' 'ZFOD' 'STATUS' 'X' '' '' '' '' '' '' '' '' '' '' ''
*       '' '' '' '',
   'KETERANGAN' '' '' '' '30' 'Keterangan' '' '' '' '' '' '' '' ''
   '' '' '' '' '',
   'ZCLOS' '' '' '' '5' 'Close' '' '' '' '' '' '' '' '' '' '' ''
   '' ''.
*    ENDIF.
*
*  ELSEIF radio5 = 'X' AND v_ucomm NE '&IC1'.
*    PERFORM f_fieldcatg USING ft_report:
*     'VKBUR' '' '' 'X' '4' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
*     'ZFOID' '' '' '' '6' 'FO No' '' '' '' '' '' '' '' '' 'X' '' '' ''
*     ''.
*
*    mac_header : 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
*
*  ELSE.
*    PERFORM f_fieldcatg USING ft_report:
*      'XREF1' '' '' '' '8' 'Rayon' '' '' '' '' '' '' '' '' 'X' '' ''
*      '' '',
*      'ZFOID' '' '' '' '6' 'No FO' '' '' '' '' '' '' '' '' 'X' '' ''
*      '' '',
*      'KUNNR' '' '' '' '13' 'Customer' '' '' '' '' '' '' '' '' 'X' ''
*      '' '' '',
*      'NAME1' '' '' '' '35' 'Customer Name' '' '' '' '' '' '' '' '' 'X'
*      '' '' '' '',
*      'ZUONR' '' '' '' '13' 'DO Number' '' '' '' '' '' '' '' '' 'X' ''
*      '' '' '',
*      'XREF2' '' '' '' '8' 'Salesman' '' '' '' '' '' '' '' '' '' '' ''
*      '' '',
*      'BUDAT' '' '' '' '10' 'Post Date' '' '' '' '' '' '' '' '' '' ''
*      '' '' '',
*      'ZFBDT' '' '' '' '10' 'Due Date' '' '' '' '' '' '' '' '' '' ''
*      '' '' '',
*      'DUEDT' '' '' '' '10' 'Due Giro' '' '' '' '' '' '' '' '' '' ''
*      '' '' '',
*      'GIRO' '' '' '' '15' 'Giro' 'X' '' '' 'IDR' '' '' '' '' '' '' ''
*      '' '',
*      'BILL' '' '' '' '15' 'Billing' 'X' '' '' 'IDR' '' '' '' '' '' ''
*      '' '' '',
*      'FAKTUR' '' '' '' '15' 'Faktur' 'X' '' '' 'IDR' '' '' '' '' ''
*      '' '' '' '',
*      'STATUS' '' '' '' '10' 'Status' '' '' '' '' '' '' '' '' '' '' ''
*      '' '',
*      'TEXT' '' '' '' '20' 'Text Status' '' '' '' '' '' '' '' '' '' ''
*      '' '' '',
*      'TEXT2' '' '' '' '30' 'Keterangan' '' '' '' '' '' '' '' '' '' ''
*      '' '' ''.

*  ENDIF.

*  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*       EXPORTING
*            i_internal_tabname     = 'I_ZFODSUM'
*       CHANGING
*            ct_fieldcat            = t_alv_fieldcat[]
*       EXCEPTIONS
*            inconsistent_interface = 1
*            program_error          = 2
*            OTHERS                 = 3.

ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FT_REPORT  text
*----------------------------------------------------------------------*
FORM f_build_fieldcat1 TABLES ft_report.

  DATA: ld_jdl(20),
        ld_text1(20),
        ld_text2(20).

  REFRESH: t_alv_fieldcat.

  DEFINE mac_header.
    read table i_status index &1.
    if sy-subrc eq 0.
      ld_jdl = i_status-ddtext.
      perform f_fieldcatg using ft_report:
      'AMT&1' '' '' '' '15' ld_jdl 'X' '' '' 'IDR' '' '' '' '' '' '' ''
      '' ''.
    endif.
  END-OF-DEFINITION.

  IF radio1 = 'X'.
    PERFORM f_fieldcatg USING ft_report:
*      'VKBUR' '' '' 'X' '4' 'SlOf' '' '' '' '' '' '' '' '' 'X' '' ''
*      '' '',
      'ZFOID' '' '' 'X' '6' 'FO No' '' '' '' '' '' '' '' '' '' '' ''
      '' '',
      'KUNNR' '' '' '' '13' 'Customer' '' '' '' '' '' '' '' '' 'X' '' ''
      '' '',
      'NAME1' '' '' '' '35' 'Customer Name' '' '' '' '' '' '' '' '' 'X'
      '' '' '' '',
      'ZUONR' '' '' '' '18' 'DO Number' '' '' '' '' '' '' '' '' 'X' ''
      '' '' '',
      'COUNT' '' '' '' '6' 'Count' 'X' '' '' '' '' '' '' '' '' ''
      '' '' '',
      'XREF2' '' '' '' '8' 'Salesman' '' '' '' '' '' '' '' '' '' '' ''
      '' '',
      'BUDAT' '' '' '' '10' 'Post Date' '' '' '' '' '' '' '' '' '' ''
      '' '' '',
      'ZFBDT' '' '' '' '10' 'Due Date' '' '' '' '' '' '' '' '' '' '' ''
      '' '',
      'DUEDT' '' '' '' '10' 'Due Giro' '' '' '' '' '' '' '' '' '' '' ''
      '' '',
      'GIRO' '' '' '' '15' 'Giro' 'X' '' '' 'IDR' '' '' '' '' '' '' ''
      '' '',
      'BILL' '' '' '' '15' 'Billing' 'X' '' '' 'IDR' '' '' '' '' '' ''
      '' '' '',
      'FAKTUR' '' '' '' '15' 'Faktur' 'X' '' '' 'IDR' '' '' '' '' '' ''
      '' '' '',
      'STATUS' '' '' '' '10' 'Status' '' '' '' '' '' '' '' '' '' '' ''
      '' '',
      'TEXT' '' '' '' '20' 'Keterangan' '' '' '' '' '' '' '' '' '' ''
      '' '' ''.

  ELSEIF radio2 = 'X'.
    PERFORM f_fieldcatg USING ft_report:
      'VKBUR' '' '' 'X' '6' 'SlOff' '' '' '' '' '' '' '' '' '' '' ''
      '' '',
      'ZFOID' '' '' 'X' '6' 'No FO' '' '' '' '' '' '' '' '' '' '' ''
      '' '',
      'KUNNR' '' '' '' '13' 'Customer' '' '' '' '' '' '' '' '' 'X' ''
      '' '' '',
      'NAME1' '' '' '' '35' 'Customer Name' '' '' '' '' '' '' '' ''
      'X' '' '' '' '',
      'ZUONR' '' '' '' '18' 'DO Number' '' '' '' '' '' '' '' '' 'X' ''
      '' '' '',
      'XREF2' '' '' '' '8' 'Salesman' '' '' '' '' '' '' '' '' '' '' ''
      '' '',
      'BUDAT' '' '' '' '10' 'Post Date' '' '' '' '' '' '' '' '' '' ''
      '' '' '',
      'ZFBDT' '' '' '' '10' 'Due Date' '' '' '' '' '' '' '' '' '' ''
      '' '' '',
      'DUEDT' '' '' '' '10' 'Due Giro' '' '' '' '' '' '' '' '' '' ''
      '' '' '',
      'GIRO' '' '' '' '15' 'Giro' 'X' '' '' 'IDR' '' '' '' '' '' '' ''
      '' '',
      'BILL' '' '' '' '15' 'Billing' 'X' '' '' 'IDR' '' '' '' '' '' ''
      '' '' '',
      'FAKTUR' '' '' '' '15' 'Faktur' 'X' '' '' 'IDR' '' '' '' '' ''
      '' '' '' '',
      'STATUS' 'ZFOD' 'STATUS' '' '6' 'Status' '' '' '' '' '' '' ''
      '' '' 'X' '' '' 'ZFOSTS',
      'TEXT' '' '' '' '20' 'Status Text' '' '' '' '' '' '' '' '' '' ''
      '' '' '',
      'TEXT2' '' '' '' '50' 'Keterangan' '' '' '' '' '' '' '' '' ''
      'X' '' '' ''.

  ELSEIF ( radio3 = 'X' AND v_ucomm NE '&IC1' ) OR
         ( radio4 = 'X' AND v_ucomm NE '&IC1' ).

    IF radio11 = 'X'.
      PERFORM f_fieldcatg USING ft_report:
        'ZFOID' '' '' '' '6' 'No FO' '' '' '' '' '' '' '' '' 'X' '' ''
        '' '',
        'KUNNR' '' '' '' '13' 'Customer' '' '' '' '' '' '' '' '' 'X' ''
        '' '' '',
        'NAME1' '' '' '' '35' 'Customer Name' '' '' '' '' '' '' '' ''
        'X' '' '' '' '',
        'ZUONR' '' '' '' '18' 'DO Number' '' '' '' '' '' '' '' '' 'X' ''
        '' '' '',
        'COUNT' '' '' '' '6' 'Count' 'X' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'XREF2' '' '' '' '8' 'Salesman' '' '' '' '' '' '' '' '' '' '' ''
        '' '',
        'BUDAT' '' '' '' '10' 'Post Date' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'ZFBDT' '' '' '' '10' 'Due Date' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'DUEDT' '' '' '' '10' 'Due Giro' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'GIRO' '' '' '' '15' 'Giro' 'X' '' '' 'IDR' '' '' '' '' '' '' ''
        '' '',
        'BILL' '' '' '' '15' 'Billing' 'X' '' '' 'IDR' '' '' '' '' '' ''
        '' '' '',
        'FAKTUR' '' '' '' '15' 'Faktur' 'X' '' '' 'IDR' '' '' '' '' ''
        '' '' '' '',
        'STATUS' 'ZFOD' 'STATUS' '' '10' 'Status' '' '' '' '' '' '' ''
        '' '' '' '' '' 'ZFOSTS'.

      IF radio3 = 'X'.
        PERFORM f_fieldcatg USING ft_report:
        'TEXT' '' '' '' '20' 'Text Status' '' '' '' '' '' '' '' '' '' ''
        '' '' ''.
      ENDIF.

      PERFORM f_fieldcatg USING ft_report:
        'TEXT2' '' '' '' '30' 'Keterangan' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'FODAT' '' '' 'X' '10' 'FO Date' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'KDGRP' '' '' 'X' '5' 'GrpCs' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'XREF1' '' '' 'X' '6' 'Rayon' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'BELNR' '' '' 'X' '10' 'Acc Doc.' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'BBELN' '' '' 'X' '10' 'BI Number' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'GIDAT' '' '' 'X' '10' 'Giro Date' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'ZCLOS' '' '' '' '5' 'Close' '' '' '' '' '' '' '' '' '' '' ''
        '' ''.

    ELSEIF radio21 = 'X' OR radio41 = 'X' OR radio51 = 'X'.
      CLEAR ld_text1.
      CASE 'X'.
        WHEN radio21.
          ld_text1 = 'Rayon'.
          ld_text2 = 'Rayon Description'.
        WHEN radio41.
          ld_text1 = 'Salesman'.
          ld_text2 = 'Salesman Name'.
        WHEN radio51.
          ld_text1 = 'Customer'.
          ld_text2 = 'Cust Description'.
      ENDCASE.

      IF p_rekap IS INITIAL.
        PERFORM f_fieldcatg USING ft_report:
        'ZFOID' '' '' '' '6' 'FO No' '' '' '' '' '' '' '' '' 'X' '' ''
        '' '',
        'XREF1' '' '' '' '10' ld_text1 '' '' '' '' '' '' '' '' 'X' '' ''
        '' '',
        'NAME1' '' '' '' '35' ld_text2 '' '' '' '' '' '' '' '' 'X' '' ''
        '' '',
        'COUNT' '' '' '' '6' 'Count' 'X' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'TOTAL' '' '' '' '15' 'Total' 'X' '' '' 'IDR' '' '' '' '' '' ''
        '' '' ''.

        mac_header : 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.

        PERFORM f_fieldcatg USING ft_report:
         'STATUS' 'ZFOD' 'STATUS' 'X' '' '' '' '' '' '' '' '' '' '' ''
         '' '' '' '',
         'KETERANGAN' '' '' 'X' '30' 'Keterangan' '' '' '' '' '' '' ''
         '' '' '' '' '' '',
         'ZCLOS' '' '' '' '5' 'Close' '' '' '' '' '' '' '' '' '' '' ''
         '' ''.

      ELSE.
        PERFORM f_fieldcatg USING ft_report:
        'XREF1' '' '' '' '10' ld_text1 '' '' '' '' '' '' '' '' 'X' '' ''
        '' '',
        'NAME1' '' '' '' '35' ld_text2 '' '' '' '' '' '' '' '' 'X' '' ''
        '' '',
        'ZFOID' '' '' '' '6' 'FO No' '' '' '' '' '' '' '' '' 'X' '' ''
        '' '',
        'COUNT' '' '' '' '6' 'Count' 'X' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'TOTAL' '' '' '' '15' 'Total' 'X' '' '' 'IDR' '' '' '' '' '' ''
        '' '' ''.

        mac_header : 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.

        PERFORM f_fieldcatg USING ft_report:
         'STATUS' 'ZFOD' 'STATUS' 'X' '' '' '' '' '' '' '' '' '' '' ''
         '' '' '' '',
         'KETERANGAN' '' '' 'X' '30' 'Keterangan' '' '' '' '' '' '' ''
         '' '' '' '' '' '',
         'ZCLOS' '' '' '' '5' 'Close' '' '' '' '' '' '' '' '' '' '' ''
         '' ''.
      ENDIF.

    ELSEIF radio31 = 'X'.
      PERFORM f_fieldcatg USING ft_report:
        'ZFOID' '' '' '' '6' 'No FO' '' '' '' '' '' '' '' '' 'X' '' ''
        '' '',
        'KUNNR' '' '' '' '13' 'Customer' '' '' '' '' '' '' '' '' 'X' ''
        '' '' '',
        'NAME1' '' '' '' '35' 'Customer Name' '' '' '' '' '' '' '' ''
        'X' '' '' '' '',
        'ZUONR' '' '' '' '18' 'DO Number' '' '' '' '' '' '' '' '' 'X' ''
        '' '' '',
        'COUNT' '' '' '' '6' 'Count' 'X' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'XREF2' '' '' '' '8' 'Salesman' '' '' '' '' '' '' '' '' '' '' ''
        '' '',
        'BUDAT' '' '' '' '10' 'Post Date' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'ZFBDT' '' '' '' '10' 'Due Date' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'DUEDT' '' '' 'X' '10' 'Due Giro' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'GIRO' '' '' 'X' '15' 'Giro' 'X' '' '' 'IDR' '' '' '' '' '' ''
        '' '' '',
        'BILL' '' '' 'X' '15' 'Billing' 'X' '' '' 'IDR' '' '' '' '' ''
        '' '' '' '',
        'FAKTUR' '' '' 'X' '15' 'Faktur' 'X' '' '' 'IDR' '' '' '' '' ''
        '' '' '' '',
        'STATUS' 'ZFOD' 'STATUS' 'X' '10' 'Status' '' '' '' '' '' '' ''
        '' '' '' '' '' 'ZFOSTS',
        'TEXT' '' '' 'X' '20' 'Text Status' '' '' '' '' '' '' '' '' ''
        '' '' '' '',
        'TEXT2' '' '' 'X' '30' 'Keterangan' '' '' '' '' '' '' '' '' ''
        '' '' '' '',
        'FODAT' '' '' 'X' '10' 'FO Date' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'KDGRP' '' '' 'X' '5' 'GrpCs' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'XREF1' '' '' 'X' '6' 'Rayon' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'BELNR' '' '' 'X' '10' 'Acc Doc.' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'BBELN' '' '' 'X' '10' 'BI Number' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'GIDAT' '' '' 'X' '10' 'Giro Date' '' '' '' '' '' '' '' '' '' ''
        '' '' '',
        'TOTAL' '' '' '' '15' 'Total' 'X' '' '' 'IDR' '' '' '' '' '' ''
        '' '' ''.

      mac_header : 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.

      PERFORM f_fieldcatg USING ft_report:
        'ZCLOS' '' '' '' '5' 'Close' '' '' '' '' '' '' '' '' '' '' ''
        '' ''.
    ENDIF.

  ELSEIF radio5 = 'X' AND v_ucomm NE '&IC1'.
    PERFORM f_fieldcatg USING ft_report:
     'VKBUR' '' '' 'X' '4' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
     'ZFOID' '' '' '' '6' 'FO No' '' '' '' '' '' '' '' '' 'X' '' '' ''
     ''.

    mac_header : 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.

  ELSE.
    PERFORM f_fieldcatg USING ft_report:
      'XREF1' '' '' '' '8' 'Rayon' '' '' '' '' '' '' '' '' 'X' '' ''
      '' '',
      'ZFOID' '' '' '' '6' 'No FO' '' '' '' '' '' '' '' '' 'X' '' ''
      '' '',
      'KUNNR' '' '' '' '13' 'Customer' '' '' '' '' '' '' '' '' 'X' ''
      '' '' '',
      'NAME1' '' '' '' '35' 'Customer Name' '' '' '' '' '' '' '' '' 'X'
      '' '' '' '',
      'ZUONR' '' '' '' '18' 'DO Number' '' '' '' '' '' '' '' '' 'X' ''
      '' '' '',
      'XREF2' '' '' '' '8' 'Salesman' '' '' '' '' '' '' '' '' '' '' ''
      '' '',
      'BUDAT' '' '' '' '10' 'Post Date' '' '' '' '' '' '' '' '' '' ''
      '' '' '',
      'ZFBDT' '' '' '' '10' 'Due Date' '' '' '' '' '' '' '' '' '' ''
      '' '' '',
      'DUEDT' '' '' '' '10' 'Due Giro' '' '' '' '' '' '' '' '' '' ''
      '' '' '',
      'GIRO' '' '' '' '15' 'Giro' 'X' '' '' 'IDR' '' '' '' '' '' '' ''
      '' '',
      'BILL' '' '' '' '15' 'Billing' 'X' '' '' 'IDR' '' '' '' '' '' ''
      '' '' '',
      'FAKTUR' '' '' '' '15' 'Faktur' 'X' '' '' 'IDR' '' '' '' '' ''
      '' '' '' '',
      'STATUS' '' '' '' '10' 'Status' '' '' '' '' '' '' '' '' '' '' ''
      '' '',
      'TEXT' '' '' '' '20' 'Text Status' '' '' '' '' '' '' '' '' '' ''
      '' '' '',
      'TEXT2' '' '' '' '30' 'Keterangan' '' '' '' '' '' '' '' '' '' ''
      '' '' ''.

  ENDIF.

ENDFORM.                    " F_FIELDCAT1

*---------------------------------------------------------------------*
*       FORM f_fieldcats                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_FNAME                                                      *
*  -->  FU_OUTLEN                                                     *
*  -->  FU_NOSIGN                                                     *
*  -->  FU_NOOUT                                                      *
*  -->  FU_TEXT                                                       *
*  -->  FU_REFTB                                                      *
*  -->  FU_REFFNAME                                                   *
*  -->  FU_DECIMALS                                                   *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_dec)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_key)
                          value(fu_input)
                          value(fu_no_zero)
                          value(fu_no_sign)
                          value(fu_rollname).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.
  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname       = fu_types.
  ld_fieldcat-fieldname     = fu_fname.
  ld_fieldcat-ref_tabname   = fu_reftb.
  ld_fieldcat-ref_fieldname = fu_refld.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-outputlen     = fu_outln.
  ld_fieldcat-seltext_l     = fu_fltxt.
  ld_fieldcat-seltext_m     = fu_fltxt.
  ld_fieldcat-seltext_s     = fu_fltxt.
  ld_fieldcat-reptext_ddic  = fu_fltxt.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-do_sum        = fu_dosum.
  ld_fieldcat-hotspot       = fu_hotsp.
  ld_fieldcat-decimals_out  = fu_dec.
  ld_fieldcat-currency      = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
  ld_fieldcat-key           = fu_key.
  ld_fieldcat-input         = fu_input.
  ld_fieldcat-no_zero       = fu_no_zero.
  ld_fieldcat-no_sign       = fu_no_sign.
  ld_fieldcat-rollname      = fu_rollname.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.

ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
*  fu_layout-f2code             = '&ETA'.
*  fu_layout-box_fieldname      = 'FLAG'.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
*  fu_layout-info_fieldname     = 'ERRFL'.

  IF radio5 = 'X' AND v_ucomm NE '&IC1'.
    fu_layout-box_fieldname      = 'FLBOX'.
  ENDIF.

  IF radio3 = 'X'.
    IF radio21 = 'X' OR radio41 = 'X' OR radio51 = 'X'.
      IF p_rekap = 'X'.
        fu_layout-totals_only = 'X'.
*        fu_layout-totals_before_items = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_keyinfo                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_KEYINFO                                                    *
*---------------------------------------------------------------------*
FORM f_build_keyinfo USING fu_keyinfo TYPE slis_keyinfo_alv.

  fu_keyinfo-header01 = 'VKBUR'.
  fu_keyinfo-item01   = 'VKBUR'.
  fu_keyinfo-header02 = 'ZFOID'.
  fu_keyinfo-item02   = 'ZFOID'.

ENDFORM.                    " f_build_keyinfo

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  IF radio1 = 'X'.

    CLEAR ld_sort.
    ld_sort-fieldname = 'VKBUR'.
    ld_sort-up        = 'X'.
*    ld_sort-group     = '*'.
*    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-fieldname = 'ZFOID'.
    ld_sort-up        = 'X'.
    ld_sort-group     = 'UL'.
    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-fieldname = 'KUNNR'.
    ld_sort-up        = 'X'.
*    ld_sort-group     = 'UL'.
*    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-fieldname = 'ZUONR'.
    ld_sort-up        = 'X'.
*    ld_sort-group     = 'UL'.
*    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.

  ELSEIF radio2 = 'X'.

    CLEAR ld_sort.
    ld_sort-spos      = '10'.
    ld_sort-fieldname = 'VKBUR'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-spos      = '20'.
    ld_sort-fieldname = 'ZFOID'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-spos      = '30'.
    ld_sort-fieldname = 'KUNNR'.
    ld_sort-up        = 'X'.
    ld_sort-group     = 'UL'.
    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-spos      = '30'.
    ld_sort-fieldname = 'NAME1'.
    ld_sort-up        = 'X'.
*      ld_sort-group     = 'UL'.
*      ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-spos      = '40'.
    ld_sort-fieldname = 'ZUONR'.
    ld_sort-up        = 'X'.
*    ld_sort-group     = 'UL'.
*    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.

  ELSEIF ( radio3 = 'X' AND v_ucomm NE '&IC1' ) OR
         ( radio4 = 'X' AND v_ucomm NE '&IC1' ).

    IF radio11 = 'X'.

      CLEAR ld_sort.
      ld_sort-fieldname = 'VKBUR'.
      ld_sort-up        = 'X'.
*      ld_sort-group     = '*'.
*      ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.

      CLEAR ld_sort.
      ld_sort-fieldname = 'ZFOID'.
      ld_sort-up        = 'X'.
      ld_sort-group     = 'UL'.
      ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.

      CLEAR ld_sort.
      ld_sort-fieldname = 'KUNNR'.
      ld_sort-up        = 'X'.
*      ld_sort-group     = 'UL'.
*      ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.

      CLEAR ld_sort.
      ld_sort-fieldname = 'ZUONR'.
      ld_sort-up        = 'X'.
*    ld_sort-group     = 'UL'.
*    ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.

    ELSEIF radio21 = 'X' OR radio41 = 'X' OR radio51 = 'X'.

      IF p_rekap IS INITIAL.
        CLEAR ld_sort.
        ld_sort-fieldname = 'ZFOID'.
        ld_sort-up        = 'X'.
        ld_sort-group     = 'UL'.
        ld_sort-subtot    = 'X'.
        APPEND ld_sort TO fu_sort.

        CLEAR ld_sort.
        ld_sort-fieldname = 'XREF1'.
        ld_sort-up        = 'X'.
*        ld_sort-group     = 'UL'.
*        ld_sort-subtot    = 'X'.
        APPEND ld_sort TO fu_sort.

      ELSE.
        CLEAR ld_sort.
        ld_sort-fieldname = 'XREF1'.
        ld_sort-up        = 'X'.
*        ld_sort-group     = 'UL'.
*        ld_sort-subtot    = 'X'.
        APPEND ld_sort TO fu_sort.

        CLEAR ld_sort.
        ld_sort-fieldname = 'NAME1'.
        ld_sort-up        = 'X'.
*        ld_sort-group     = 'UL'.
        ld_sort-subtot    = 'X'.
        APPEND ld_sort TO fu_sort.

        CLEAR ld_sort.
        ld_sort-fieldname = 'ZFOID'.
        ld_sort-up        = 'X'.
*        ld_sort-group     = 'UL'.
*        ld_sort-subtot    = 'X'.
        APPEND ld_sort TO fu_sort.

      ENDIF.

    ELSEIF radio31 = 'X'.

      CLEAR ld_sort.
      ld_sort-fieldname = 'VKBUR'.
      ld_sort-up        = 'X'.
*      ld_sort-group     = '*'.
*      ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.

      CLEAR ld_sort.
      ld_sort-fieldname = 'ZFOID'.
      ld_sort-up        = 'X'.
      ld_sort-group     = 'UL'.
      ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.

      CLEAR ld_sort.
      ld_sort-fieldname = 'KUNNR'.
      ld_sort-up        = 'X'.
*      ld_sort-group     = 'UL'.
*      ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.

      CLEAR ld_sort.
      ld_sort-fieldname = 'ZUONR'.
      ld_sort-up        = 'X'.
*    ld_sort-group     = 'UL'.
*    ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.

    ENDIF.

  ELSEIF radio5 = 'X' AND v_ucomm NE '&IC1'.

    CLEAR ld_sort.
    ld_sort-fieldname = 'VKBUR'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-fieldname = 'ZFOID'.
    ld_sort-up        = 'X'.
*    ld_sort-group     = 'UL'.
*    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.

  ELSE.

    CLEAR ld_sort.
    ld_sort-spos      = '10'.
    ld_sort-fieldname = 'VKBUR'.
    ld_sort-up        = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-spos      = '20'.
    ld_sort-fieldname = 'XREF1'.
    ld_sort-up        = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-spos      = '30'.
    ld_sort-fieldname = 'ZFOID'.
    ld_sort-up        = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-spos      = '40'.
    ld_sort-fieldname = 'KUNNR'.
    ld_sort-up        = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-spos      = '50'.
    ld_sort-fieldname = 'ZUONR'.
    ld_sort-up        = 'X'.
    APPEND ld_sort TO fu_sort.

  ENDIF.

ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_build_event                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.

  CLEAR ft_events.
  ft_events-name = slis_ev_end_of_list.
  ft_events-form = 'F_END_OF_LIST'.
  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_page.
*  ft_events-form = 'F_END_OF_PAGE'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_before_line_output.
*  ft_events-form = 'F_BEFORE_LINE_OUTPUT'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_after_line_output.
*  ft_events-form = 'F_AFTER_LINE_OUTPUT'.
*  APPEND ft_events.
*
*  CLEAR ft_events.
*  ft_events-name = slis_ev_subtotal_text.
*  ft_events-form = 'F_SUBTOTAL'.
*  APPEND ft_events.

ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

ENDFORM.                    "f_build_event_exit

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos = 'X'.
  fu_print-no_print_selinfos  = 'X'.
  fu_print-no_coverpage       = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.

  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
    fc_alv_variant-report = d_repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = fc_alv_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      IF NOT sy-msgid IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR fc_alv_variant.
    fc_alv_variant-report = sy-repid.
  ENDIF.


ENDFORM.                    " F_ALV_VARIANT_EXIST

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  DATA: l_text1(50),
        l_text2(50),
        l_text3(50),
        l_date(10).

  WRITE pa_budat TO l_date.

  IF radio1 = 'X'.
    IF fl_save IS INITIAL.
      sy-title = 'Create Faktur Opname'.
    ELSE.
      sy-title = 'Listing Faktur Opname'.
    ENDIF.
    CONCATENATE 'Cabang:' itab-vkbur '-' itab-bezei
        INTO l_text1 SEPARATED BY space.
    CONCATENATE 'Proses:' l_date
        INTO l_text2 SEPARATED BY space.
    CONCATENATE 'No FO:' itab-zfoid
        INTO l_text3 SEPARATED BY space.
*    CONCATENATE 'Cabang:' i_header-vkbur '-' i_header-bezei
*        INTO l_text1 SEPARATED BY space.
*    CONCATENATE 'Proses:' l_date
*        INTO l_text2 SEPARATED BY space.
*    CONCATENATE 'No FO:' i_header-zfoid
*        INTO l_text3 SEPARATED BY space.
  ENDIF.

  IF radio2 = 'X'.
    sy-title = 'Input Faktur Opname'.
    CONCATENATE 'Cabang:' itab-vkbur '-' itab-bezei
        INTO l_text1 SEPARATED BY space.
    CONCATENATE 'No FO:' itab-zfoid
        INTO l_text2 SEPARATED BY space.
  ENDIF.

  IF radio3 = 'X' OR radio4 = 'X'.
    IF radio3 = 'X'.
      sy-title = 'Report Faktur Opname'.
    ELSE.
      sy-title = 'Reprint Faktur Opname'.
    ENDIF.
    IF radio11 = 'X'.
      CONCATENATE 'Cabang:' itab-vkbur '-' itab-bezei
          INTO l_text1 SEPARATED BY space.
    ELSEIF radio21 = 'X' OR radio41 = 'X' OR radio51 = 'X'.
      CONCATENATE 'Cabang:' i_zfodsum-vkbur '-' i_zfodsum-bezei
          INTO l_text1 SEPARATED BY space.
    ELSEIF radio31 = 'X'.
      CONCATENATE 'Cabang:' i_zfoddet-vkbur '-' i_zfoddet-bezei
          INTO l_text1 SEPARATED BY space.
    ENDIF.
  ELSEIF radio5 = 'X'.
    sy-title = 'Close Status Faktur Opname'.
    CONCATENATE 'Cabang:' i_zfodclos-vkbur '-' i_zfodclos-bezei
        INTO l_text1 SEPARATED BY space.
  ELSE.
  ENDIF.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING l_text1.
  PERFORM f_hdr_line3 USING l_text2 l_text3.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page

*---------------------------------------------------------------------*
*       FORM f_end_of_list                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_end_of_list.

  CHECK v_ucomm NE '&IC1'.
  CASE 'X'.
    WHEN radio1.
      IF fl_save = 'X'.
        SKIP 1.
        PERFORM f_ftr_line1_1 USING ''.
      ENDIF.
    WHEN radio11.
      SKIP 1.
      PERFORM f_ftr_line1_1 USING ''.
    WHEN radio21.
      SKIP 1.
      PERFORM f_ftr_line2_1 USING ''.
  ENDCASE.

ENDFORM.                    "f_end_of_list

*&---------------------------------------------------------------------*
*&      Form  F_HDR_ULINE
*&---------------------------------------------------------------------*
*       Draw underline if flag set
*----------------------------------------------------------------------*
FORM f_hdr_uline.
  IF d_hdr_rpt_lines = 'X'.
    ULINE.
  ENDIF.
ENDFORM.                    " F_HDR_ULINE

*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE1
*&---------------------------------------------------------------------*
*       Header line with report, title and page
*----------------------------------------------------------------------*
FORM f_hdr_line1 USING fu_company.
  DATA:
    page_number(10) VALUE 'Page: nnnn',
    progname(42) VALUE 'Program: xx',
    ld_progname(20),
    page(4).

*--- Page number
  page = sy-pagno.
  REPLACE 'nnnn' WITH page INTO page_number.
  IF sy-cprog EQ sy-repid.
    REPLACE 'xx' WITH sy-repid INTO progname.
  ELSE.
    CONCATENATE sy-repid '(' sy-cprog ')' INTO ld_progname.
    REPLACE 'xx' WITH ld_progname INTO progname.
  ENDIF.

*--- Output line
  PERFORM f_hdr_pad_title USING progname fu_company page_number.
ENDFORM.                    " F_HDR_LINE1


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE2
*&---------------------------------------------------------------------*
*       Client, User text 1, Date and time
*----------------------------------------------------------------------*
FORM f_hdr_line2 USING fu_title.
  DATA:
    ld_sysid(18) VALUE 'Client : XXX(YYY)',
*  ld_datum(18) value 'Date: AA/BB/CCCC'.
    ld_datum(10).

*--- system info
  REPLACE 'XXX' WITH sy-sysid(3) INTO ld_sysid.
  REPLACE 'YYY' WITH sy-mandt INTO ld_sysid.

*--- date
*  replace 'AA' with sy-datum+6(2) into ld_datum.
*  replace 'BB' with sy-datum+4(2) into ld_datum.
*  replace 'CCCC' with sy-datum+0(4) into ld_datum.
  WRITE sy-datum TO ld_datum.

*--- output line
  PERFORM f_hdr_pad_title USING ld_sysid fu_title ld_datum.
ENDFORM.                    " F_HDR_LINE2


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE3
*&---------------------------------------------------------------------*
*       User name, text 2, time
*----------------------------------------------------------------------*
FORM f_hdr_line3 USING fu_title fu_nofo.
  DATA:
    ld_uzeit(5) VALUE 'hh:mm',
    ld_uname(21) VALUE 'User   : xx'.

*--- time
  REPLACE 'hh' WITH sy-uzeit(2) INTO ld_uzeit.     " hour
  REPLACE 'mm' WITH sy-uzeit+2(2) INTO ld_uzeit.   " minute

*--- user
  REPLACE 'xx' WITH sy-uname INTO ld_uname.

*--- output line
*  PERFORM f_hdr_pad_title USING ld_uname fu_title ld_uzeit.
  PERFORM f_hdr_pad_title USING ld_uname fu_title fu_nofo.

ENDFORM.                    " F_HDR_LINE3

*&---------------------------------------------------------------------*
*&      Form  F_HDR_PAD_TITLE
*&---------------------------------------------------------------------*
*       Prepare the variable with the title text spaced correctly
*----------------------------------------------------------------------*
FORM f_hdr_pad_title USING v_left_text v_middle_text v_right_text.

  DATA:
      page_width TYPE i,       " Width of page
      middle_length TYPE i,    " Length of title text
      left_length TYPE i,      " Length of left text
      right_length TYPE i,     " Length of right text
      left_start TYPE i,       " Position on line for start of left tex
      middle_start TYPE i,     " Position on line for start of middl tex
      right_start TYPE i.      " Position on line for start of right tex

*--- Start with a blank title
  CLEAR d_hdr_title.
  page_width = sy-linsz - 1.

*--- Compute space on either side of title allowing vertical border
  COMPUTE middle_length = STRLEN( v_middle_text ).
  COMPUTE left_length = STRLEN( v_left_text ).
  COMPUTE right_length = STRLEN( v_right_text ).

  COMPUTE middle_start = ( sy-linsz - middle_length ) / 2.

*--- Allow for vertical lines
  left_start = 0.
  IF d_hdr_rpt_lines = 'X'.
    d_hdr_title(1) = sy-vline.
    d_hdr_title+page_width(1) = sy-vline.
    left_start = 1.
  ENDIF.
  right_start = sy-linsz - left_start - right_length - 1.
  WRITE:/ sy-vline.
*--- Insert texts
  IF left_length <> 0.
*    d_hdr_title+left_start(left_length) = v_left_text.
    WRITE AT (left_length) v_left_text.
  ENDIF.
  IF middle_length <> 0.
    WRITE AT middle_start(middle_length) v_middle_text.
*    d_hdr_title+middle_start(middle_length) = v_middle_text.
  ENDIF.
  IF right_length <> 0.
    WRITE AT right_start(right_length) v_right_text.
*    d_hdr_title+right_start(right_length) = v_right_text.
  ENDIF.
  WRITE AT sy-linsz sy-vline.
ENDFORM.                    " F_HDR_PAD_TITLE

*&---------------------------------------------------------------------*
*&      Form  f_ftr_line1_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1442   text
*----------------------------------------------------------------------*
FORM f_ftr_line1_1 USING    value(p_1442).

  PERFORM f_write_selscreen.

ENDFORM.                    " f_ftr_line2_1

*&---------------------------------------------------------------------*
*&      Form  f_ftr_line2_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1442   text
*----------------------------------------------------------------------*
FORM f_ftr_line2_1 USING    value(p_1442).

  WRITE: /5   'Mengetahui',
          23  ': .........................',
          55  'Jabatan',
          65  ': BM',
          85  'TTD',
          93  ': .........................'.

  SKIP 1.
  WRITE: /5   'Menyetujui',
          23  ': .........................',
          55  'Jabatan',
          65  ': BOM / BOS',
          85  'TTD',
          93  ': .........................'.

  SKIP 1.
  WRITE: /23  ': .........................',
          65  ': Fin Spv',
          85  'TTD',
          93  ': .........................'.

  SKIP 1.
  WRITE: /5   'Yang Mengopname',
          23  ': .........................',
          55  'Jabatan',
          65  ': A/R Control',
          85  'TTD',
          93  ': .........................'.

  SKIP 1.
  WRITE: /5   'Yang Diopname',
          23  ': .........................',
          55  'Jabatan',
          65  ': Inkaso',
          85  'TTD',
          93  ': .........................'.

ENDFORM.                    " f_ftr_line2_1

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.

  sy-lsind = 0.
  IF fl_save IS INITIAL.
    SET PF-STATUS 'STANDARD'.
  ELSE.
    SET PF-STATUS 'STATUS_001'.
  ENDIF.

ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  DATA: ffield(20), fvalue(20), fline(20), lline(20), lvalue(100),
        ld_xref1 LIKE zfod-xref1,
        lt_dynpread LIKE dynpread OCCURS 0 WITH HEADER LINE,
        lt_zfod LIKE zfod OCCURS 0 WITH HEADER LINE,
        lt_itab LIKE itab OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread, lt_zfod.

  CASE fu_ucomm.

    WHEN '&IC1'.
      v_ucomm = fu_ucomm.
      GET CURSOR FIELD ffield VALUE fvalue.
      GET CURSOR LINE lline VALUE lvalue.

      CASE ffield.
        WHEN 'I_ZFODCLOS-ZFOID'.
          lt_zfod[] = i_zfod[].
          DELETE lt_zfod WHERE zfoid NE fvalue.
          PERFORM f_print_data1 TABLES lt_zfod.

        WHEN 'I_ZFODSUM-ZFOID'.
          ld_xref1 = lvalue+10(4).
          lt_itab[] = itab[].
          DELETE lt_itab WHERE zfoid NE fvalue OR
                               xref1 NE ld_xref1.
          PERFORM f_print_data1 TABLES lt_itab.
      ENDCASE.

    WHEN '&SAV'.
      IF v_ucomm NE '&IC1'.
        IF radio1 = 'X'.
          PERFORM f_save_fo.
        ELSEIF radio2 = 'X'.
          PERFORM f_save_input_fo.
        ELSEIF radio5 = 'X'.
          PERFORM f_save_close_fo.
        ENDIF.
      ENDIF.

    WHEN '&REFRESH'.
      IF radio2 = 'X'.
        LOOP AT itab.
          CLEAR i_status.
          READ TABLE i_status WITH KEY domvalue_l = itab-status.
          itab-text = i_status-ddtext.
          MODIFY itab.
        ENDLOOP.
      ENDIF.

  ENDCASE.

ENDFORM.                    "f_user_command

*&---------------------------------------------------------------------*
*&      Form  f_cek_authority
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cek_authority USING fu_vkbur.

*  DATA: BEGIN OF lt_vkbur OCCURS 0,
*          vkbur  LIKE  tvbur-vkbur,
*        END OF lt_vkbur.

*  SELECT vkbur INTO TABLE lt_vkbur FROM tvbur
*    WHERE vkbur IN so_vkbur.

*  LOOP AT lt_vkbur.
  AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
      ID 'GSBER' FIELD fu_vkbur
      ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    MESSAGE i002(zz) WITH
    'You have no authorization for Sales Office' fu_vkbur.
    STOP.
  ENDIF.
*  ENDLOOP.

ENDFORM.                    " f_cek_authority

*&---------------------------------------------------------------------*
*&      Form  f_create_fo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_fo.

  PERFORM f_get_data.
  PERFORM f_process_data.

  IF itab[] IS INITIAL.
    MESSAGE s000(26) WITH 'No items selected'.
    STOP.
  ENDIF.

* Hirearchi ALV
*  REFRESH: i_header, i_detail.
*  CLEAR: i_header, i_detail.
*  i_header[] = itab[].
*  i_detail[] = itab[].
*  SORT i_header BY vkbur.
*  DELETE ADJACENT DUPLICATES FROM i_header COMPARING vkbur zfoid.
*  PERFORM f_print_data TABLES i_header i_detail.

  PERFORM f_print_data1 TABLES itab.

ENDFORM.                    " f_create_fo

*&---------------------------------------------------------------------*
*&      Form  f_save_FO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_fo.

  DATA: l_answer(1).
  DATA: lt_zfod LIKE zfod OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'DD_POPUP_WITH_INFOTEXT'
    EXPORTING
      titel              = 'Save Faktur Opname Confirm'
      start_column       = '30'
      start_row          = '3'
      end_column         = '70'
      end_row            = '7'
*          INFOFLAG           = ' '
    IMPORTING
      answer             = l_answer
    TABLES
      lines              = i_popupline.

  IF l_answer = 'Y'.

*    lt_zfod[] = itab[].
    LOOP AT itab.
      MOVE-CORRESPONDING itab TO lt_zfod.
      IF NOT itab-kunnr1 IS INITIAL.
        lt_zfod-kunnr = itab-kunnr1.
      ENDIF.
      APPEND lt_zfod.
    ENDLOOP.

    CLEAR lt_zfod.
    lt_zfod-chusr = sy-uname.
    lt_zfod-chdat = sy-datum.
    lt_zfod-chtim = sy-uzeit.
    MODIFY lt_zfod TRANSPORTING chusr chdat chtim
        WHERE chusr IS INITIAL AND
              chdat IS INITIAL AND
              chtim IS INITIAL.

    CLEAR i_zfos.
    i_zfos-crusr = sy-uname.
    i_zfos-crdat = sy-datum.
    i_zfos-crtim = sy-uzeit.
    i_zfos-chusr = sy-uname.
    i_zfos-chdat = sy-datum.
    i_zfos-chtim = sy-uzeit.
    MODIFY i_zfos TRANSPORTING crusr crdat crtim
                               chusr chdat chtim
        WHERE chusr IS INITIAL AND
              chdat IS INITIAL AND
              chtim IS INITIAL.

* Save Selection screen
    PERFORM f_save_selscr.

* Update Tables
    MODIFY zfod FROM TABLE lt_zfod.
    IF sy-subrc = 0.
      MODIFY zfos FROM TABLE i_zfos.
    ENDIF.

* Listing Data
    fl_save = 'X'.
    PERFORM f_print_data1 TABLES itab.

    LEAVE TO SCREEN 0.

  ENDIF.

ENDFORM.                    " f_save_FO

*&---------------------------------------------------------------------*
*&      Form  f_input_fo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_input_fo.

  SELECT domname domvalue_l ddtext
    INTO CORRESPONDING FIELDS OF TABLE i_status
    FROM dd07t WHERE domname = 'ZFOSTS' AND
                     ddlanguage = sy-langu.

  SELECT a~vstel a~werks a~lgort b~live
    INTO CORRESPONDING FIELDS OF TABLE i_live
    FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
                                       a~lgort = b~lgort
    WHERE b~bukrs EQ pa_bukrs   AND
          b~live  EQ space.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF itab
    FROM zfod
    WHERE bukrs EQ p_bukrs1  AND
*          vkbur IN s_vkbur1  AND
          vkbur EQ p_vkbur1  AND
          zfoid IN s_zfoid1  AND
          status IN s_stat1  AND
          kunnr IN s_kunnr1  AND
          kdgrp IN s_kdgrp1  AND
          xref1 IN s_xref11  AND
          xref2 IN s_xref21  AND
          zuonr IN s_zuonr1  AND
          zclos = space.

  IF sy-subrc = 0.
    CALL SCREEN 500.
  ELSE.
    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF itab
      FROM zfod
      WHERE bukrs EQ p_bukrs1  AND
*            vkbur IN s_vkbur1  AND
            vkbur EQ p_vkbur1  AND
            zfoid IN s_zfoid1  AND
            status IN s_stat1  AND
            kunnr IN s_kunnr1  AND
            kdgrp IN s_kdgrp1  AND
            xref1 IN s_xref11  AND
            xref2 IN s_xref21  AND
            zuonr IN s_zuonr1  AND
            zclos NE space.
    IF sy-subrc = 0.
      MESSAGE s000(26) WITH 'FO Number Already Closed'.
    ELSE.
      MESSAGE s000(26) WITH 'No items selected'.
    ENDIF.
    STOP.
  ENDIF.

ENDFORM.                    " f_input_fo

*&---------------------------------------------------------------------*
*&      Form  f_report_fo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_report_fo.

  DATA: ld_row LIKE sy-tabix,
        ld_ref1 LIKE kna1-kunnr,
        l_sortl LIKE kna1-sortl,
        ld_count TYPE i.

  DEFINE mac_trans.
  when '&1'.
    i_zfodsum-amt&1 = itab-giro + itab-bill.
  END-OF-DEFINITION.

  DEFINE mac_trans2.
  when '&1'.
    i_zfoddet-amt&1 = itab-giro + itab-bill.
  END-OF-DEFINITION.

  SELECT a~vstel a~werks a~lgort b~live
    INTO CORRESPONDING FIELDS OF TABLE i_live
    FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
                                       a~lgort = b~lgort
    WHERE b~bukrs EQ pa_bukrs   AND
          b~live  EQ space.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE itab
    FROM zfod
    WHERE bukrs EQ p_bukrs2 AND
          vkbur EQ p_vkbur2 AND
          zfoid IN s_zfoid2 AND
          fodat IN s_fodat2 AND
          status IN s_stat2 AND
          kunnr IN s_kunnr2 AND
          zuonr IN s_zuonr2 AND
          kdgrp IN s_kdgrp2 AND
          xref1 IN s_xref12 AND
          xref2 IN s_xref22.

  IF sy-subrc = 0.
    SORT itab BY vkbur kunnr zuonr.

    IF radio11 ='X'.
      LOOP AT itab.
        AT NEW zuonr.
          ld_count = 1.
        ENDAT.
        SELECT SINGLE bezei INTO itab-bezei
          FROM tvkbt WHERE spras = sy-langu AND
                           vkbur = itab-vkbur.
        SELECT SINGLE name1 sortl
          INTO (itab-name1, l_sortl)
          FROM kna1 WHERE kunnr EQ itab-kunnr.
        IF radio4 = 'X'.
          CLEAR : itab-status, itab-text2.
        ENDIF.
        READ TABLE i_live WITH KEY vstel = itab-vkbur.
        IF sy-subrc = 0.
          itab-kunnr = l_sortl.
        ENDIF.
        itab-count = ld_count.
        MODIFY itab. CLEAR: itab,ld_count.
      ENDLOOP.
      PERFORM f_print_data1 TABLES itab.

    ELSEIF radio21 ='X' OR radio41 ='X' OR radio51 = 'X'.
      SELECT domname domvalue_l ddtext
        INTO CORRESPONDING FIELDS OF TABLE i_status
        FROM dd07t WHERE domname = 'ZFOSTS' AND
                         ddlanguage = sy-langu.
      CLEAR i_status.
      i_status-domname = 'ZFOSTS'.
      i_status-domvalue_l = space.
      i_status-ddtext = 'Selisih'.
      APPEND i_status.

      LOOP AT i_status.
        CASE i_status-ddtext.
          WHEN 'Pembayaran Tunai'.
            i_status-ddtext = 'Pemb. Tunai'.
          WHEN 'Pembayaran Cheque'.
            i_status-ddtext = 'Pemb. Cheque'.
        ENDCASE.
        MODIFY i_status.
      ENDLOOP.

      LOOP AT itab.

        AT NEW zuonr.
          ld_count = 1.
        ENDAT.

        i_zfodsum-bukrs = itab-bukrs.
        i_zfodsum-vkbur = itab-vkbur.
        i_zfodsum-count = ld_count.
        i_zfodsum-total = itab-giro + itab-bill.
        i_zfodsum-zfoid = itab-zfoid.
        i_zfodsum-zclos = itab-zclos.

        CASE 'X'.
          WHEN radio21.
            i_zfodsum-xref1 = itab-xref1.
            CONCATENATE '000000' i_zfodsum-xref1(4) INTO ld_ref1.
            SELECT SINGLE name1 INTO i_zfodsum-name1
              FROM kna1 WHERE kunnr = ld_ref1.
          WHEN radio41.
            i_zfodsum-xref1 = itab-xref2.
            SELECT SINGLE ename INTO i_zfodsum-name1 FROM pa0001
            WHERE pernr EQ itab-xref2.
          WHEN radio51.
            i_zfodsum-xref1 = itab-kunnr.
            i_zfodsum-name1 = itab-name1.
        ENDCASE.

        SELECT SINGLE bezei INTO i_zfodsum-bezei
          FROM tvkbt WHERE spras = sy-langu AND
                           vkbur = i_zfodsum-vkbur.

        READ TABLE i_status WITH KEY domvalue_l = itab-status.
        ld_row = sy-tabix.
        CASE ld_row.
            mac_trans: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
        ENDCASE.

        COLLECT i_zfodsum. CLEAR i_zfodsum.

        itab-bezei = i_zfodsum-bezei.
        itab-name1 = i_zfodsum-name1.
        MODIFY itab. CLEAR: itab,ld_count.

      ENDLOOP.

* Hirearchi ALV
*      i_zfodsumd[] = i_zfodsum[].
*      PERFORM f_print_data TABLES i_zfodsum i_zfodsumd.

      PERFORM f_print_data1 TABLES i_zfodsum.

    ELSEIF radio31 ='X'.
      SELECT domname domvalue_l ddtext
        INTO CORRESPONDING FIELDS OF TABLE i_status
        FROM dd07t WHERE domname = 'ZFOSTS' AND
                         ddlanguage = sy-langu.
      CLEAR i_status.
      i_status-domname = 'ZFOSTS'.
      i_status-domvalue_l = space.
      i_status-ddtext = 'Selisih'.
      APPEND i_status.

      LOOP AT itab.
        AT NEW zuonr.
          ld_count = 1.
        ENDAT.
        MOVE-CORRESPONDING itab TO i_zfoddet.
        i_zfoddet-count = ld_count.
        i_zfoddet-total = itab-giro + itab-bill.
        SELECT SINGLE bezei INTO i_zfoddet-bezei
          FROM tvkbt WHERE spras = sy-langu AND
                           vkbur = i_zfoddet-vkbur.
        SELECT SINGLE name1 sortl
          INTO (i_zfoddet-name1, l_sortl)
          FROM kna1 WHERE kunnr EQ i_zfoddet-kunnr.
        READ TABLE i_live WITH KEY vstel = i_zfoddet-vkbur.
        IF sy-subrc = 0.
          i_zfoddet-kunnr = l_sortl.
        ENDIF.
        READ TABLE i_status WITH KEY domvalue_l = i_zfoddet-status.
        ld_row = sy-tabix.
        CASE ld_row.
            mac_trans2: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
        ENDCASE.
        APPEND i_zfoddet. CLEAR: i_zfoddet,ld_count.
      ENDLOOP.
      PERFORM f_print_data1 TABLES i_zfoddet.

    ENDIF.

  ELSE.
    MESSAGE s000(26) WITH 'No items selected'.
    STOP.
  ENDIF.

ENDFORM.                    " f_report_fo

*&---------------------------------------------------------------------*
*&      Form  f_print_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data TABLES ft_header ft_detail.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_header ft_detail.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_keyinfo     USING   d_alv_keyinfo.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK              = ' '
      i_callback_program             = d_repid
      i_callback_pf_status_set       = 'F_SET_PF_STATUS'
      i_callback_user_command        = 'F_USER_COMMAND'
      is_layout                      = d_layout
      it_fieldcat                    = t_alv_fieldcat[]
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
      it_sort                        = t_alv_isort[]
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
      i_default                      = 'X'
      i_save                         = 'A'
*     IS_VARIANT                     =
      it_events                      = t_alv_event[]
*     IT_EVENT_EXIT                  =
      i_tabname_header               = 'I_ZFODSUM'
      i_tabname_item                 = 'I_ZFODSUMD'
*     I_STRUCTURE_NAME_HEADER        =
*     I_STRUCTURE_NAME_ITEM          =
      is_keyinfo                     = d_alv_keyinfo
*     IS_PRINT                       =
*     IS_REPREP_ID                   =
*     I_BUFFER_ACTIVE                =
*     I_BYPASSING_BUFFER             =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab_header                = ft_header
      t_outtab_item                  = ft_detail
*   EXCEPTIONS
*     PROGRAM_ERROR                  = 1
*     OTHERS                         = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CASE sy-xcode.
    WHEN '&F03'.
      CLEAR v_ucomm.
    WHEN '&F15'.
      CLEAR v_ucomm.
    WHEN '&F12'.
      CLEAR v_ucomm.
  ENDCASE.

ENDFORM.                    " f_print_data

*&---------------------------------------------------------------------*
*&      Form  f_print_data1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data1 TABLES ft_itab.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat1   TABLES  ft_itab.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK              = ' '
*     I_BYPASSING_BUFFER             = 'X'
*     I_BUFFER_ACTIVE                = ' '
      i_callback_program             = d_repid
      i_callback_pf_status_set       = 'F_SET_PF_STATUS'
      i_callback_user_command        = 'F_USER_COMMAND'
*     I_STRUCTURE_NAME               =
      is_layout                      = d_layout
      it_fieldcat                    = t_alv_fieldcat[]
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
      it_sort                        = t_alv_isort[]
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
      i_default                      = 'X'
      i_save                         = 'A'
      is_variant                     = d_alv_variant
      it_events                      = t_alv_event[]
      it_event_exit                  = t_event_exit[]
      is_print                       = d_print
*     IS_REPREP_ID                   =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab                       = ft_itab
    EXCEPTIONS
      program_error                  = 1
      OTHERS                         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CASE sy-xcode.
    WHEN '&F03'.
      CLEAR v_ucomm.
    WHEN '&F15'.
      CLEAR v_ucomm.
    WHEN '&F12'.
      CLEAR v_ucomm.
  ENDCASE.

ENDFORM.                    " f_print_data1

*&---------------------------------------------------------------------*
*&      Form  f_close_fo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_close_fo.

  DATA : ld_row LIKE sy-tabix,
         l_sortl LIKE kna1-sortl.

  DEFINE mac_trans.
  when '&1'.
    i_zfodclos-amt&1 = i_zfod-giro + i_zfod-bill.
  END-OF-DEFINITION.

  SELECT a~vstel a~werks a~lgort b~live
    INTO CORRESPONDING FIELDS OF TABLE i_live
    FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
                                       a~lgort = b~lgort
    WHERE b~bukrs EQ pa_bukrs   AND
          b~live  EQ space.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE i_zfod
    FROM zfod
    WHERE bukrs EQ p_bukrs3 AND
*          vkbur IN s_vkbur3 AND
          vkbur EQ p_vkbur3 AND
          zfoid IN s_zfoid3 AND
*          kunnr IN s_kunnr3 AND
*          zuonr IN s_zuonr3 AND
*          kdgrp IN s_kdgrp3 AND
*          xref1 IN s_xref13 AND
*          xref2 IN s_xref23 AND
          zclos = space.

  IF sy-subrc = 0.

    SELECT domname domvalue_l ddtext
      INTO CORRESPONDING FIELDS OF TABLE i_status
      FROM dd07t WHERE domname = 'ZFOSTS' AND
                       ddlanguage = sy-langu.
    CLEAR i_status.
    i_status-domname = 'ZFOSTS'.
    i_status-domvalue_l = space.
    i_status-ddtext = 'Selisih'.
    APPEND i_status.

    LOOP AT i_status.
      CASE i_status-ddtext.
        WHEN 'Pembayaran Tunai'.
          i_status-ddtext = 'Pemb. Tunai'.
        WHEN 'Pembayaran Cheque'.
          i_status-ddtext = 'Pemb. Cheque'.
      ENDCASE.
      MODIFY i_status.
    ENDLOOP.

    LOOP AT i_zfod.
      i_zfodclos-bukrs = i_zfod-bukrs.
      i_zfodclos-vkbur = i_zfod-vkbur.
      i_zfodclos-zfoid = i_zfod-zfoid.
*      i_zfodclos-status = i_zfod-status.
      SELECT SINGLE bezei INTO i_zfodclos-bezei
        FROM tvkbt WHERE spras = sy-langu AND
                         vkbur = i_zfodclos-vkbur.
      READ TABLE i_status WITH KEY domvalue_l = i_zfod-status.
      ld_row = sy-tabix.
      CASE ld_row.
          mac_trans: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.
      ENDCASE.
      COLLECT i_zfodclos. CLEAR i_zfodclos.
    ENDLOOP.

    PERFORM f_print_data1 TABLES i_zfodclos.

  ELSE.
    SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF i_zfod
    FROM zfod
    WHERE bukrs EQ p_bukrs3 AND
*          vkbur IN s_vkbur3 AND
          vkbur EQ p_vkbur3 AND
          zfoid IN s_zfoid3 AND
*          kunnr IN s_kunnr3 AND
*          zuonr IN s_zuonr3 AND
*          kdgrp IN s_kdgrp3 AND
*          xref1 IN s_xref13 AND
*          xref2 IN s_xref23 AND
          zclos NE space.
    IF sy-subrc = 0.
      MESSAGE s000(26) WITH 'FO Number Already Closed'.
    ELSE.
      MESSAGE s000(26) WITH 'No items selected'.
    ENDIF.
    STOP.
  ENDIF.

ENDFORM.                    " f_close_fo

*&---------------------------------------------------------------------*
*&      Form  f_save_close_fo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_close_fo.

  DATA: l_answer(1),
        ld_date(10).
  DATA: lt_zfos LIKE zfos OCCURS 0 WITH HEADER LINE,
        lt_zfod LIKE zfod OCCURS 0 WITH HEADER LINE,
        lt_zfodclos LIKE i_zfodclos OCCURS 0 WITH HEADER LINE,
        lt_popupline LIKE popuptext OCCURS 0 WITH HEADER LINE.

  WRITE sy-datum TO ld_date.
  lt_zfodclos[] = i_zfodclos[].
  DELETE lt_zfodclos WHERE flbox IS INITIAL.

  IF lt_zfodclos[] IS INITIAL.
    MESSAGE i000(26) WITH 'No items selected'.
  ELSE.
    lt_popupline-hell = 'X'.
    CONCATENATE 'No FO' 'Cabang'
          INTO lt_popupline-text SEPARATED BY '    '.
    APPEND lt_popupline. CLEAR lt_popupline.

    LOOP AT lt_zfodclos.
      CONCATENATE lt_zfodclos-zfoid '/' lt_zfodclos-vkbur
        lt_zfodclos-bezei INTO lt_popupline-text SEPARATED BY space.
      APPEND lt_popupline. CLEAR lt_popupline.
    ENDLOOP.

    CALL FUNCTION 'DD_POPUP_WITH_INFOTEXT'
      EXPORTING
        titel              = 'Close Faktur Opname Confirm'
        start_column       = '30'
        start_row          = '3'
        end_column         = '70'
        end_row            = '7'
*          INFOFLAG           = ' '
      IMPORTING
        answer             = l_answer
      TABLES
        lines              = lt_popupline.

    IF l_answer = 'Y'.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zfos
        FROM zfos
        FOR ALL ENTRIES IN lt_zfodclos
        WHERE bukrs = lt_zfodclos-bukrs  AND
              vkbur = lt_zfodclos-vkbur  AND
              zfoid = lt_zfodclos-zfoid.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zfod
        FROM zfod
        FOR ALL ENTRIES IN lt_zfodclos
        WHERE bukrs = lt_zfodclos-bukrs  AND
              vkbur = lt_zfodclos-vkbur  AND
              zfoid = lt_zfodclos-zfoid.

      CLEAR lt_zfos.
      lt_zfos-zclos = 'C'.
      lt_zfos-chusr = sy-uname.
      lt_zfos-chdat = sy-datum.
      lt_zfos-chtim = sy-uzeit.
      lt_zfos-clusr = sy-uname.
      lt_zfos-cldat = sy-datum.
      lt_zfos-cltim = sy-uzeit.
      MODIFY lt_zfos TRANSPORTING zclos chusr chdat chtim
                                  clusr cldat cltim
                     WHERE zclos NE 'C'.
      CLEAR lt_zfod.
      lt_zfod-zclos = 'C'.
      lt_zfod-chusr = sy-uname.
      lt_zfod-chdat = sy-datum.
      lt_zfod-chtim = sy-uzeit.
      MODIFY lt_zfod TRANSPORTING zclos chusr chdat chtim
                     WHERE zclos NE 'C'.

* Update Tables
      MODIFY zfod FROM TABLE lt_zfod.
      MODIFY zfos FROM TABLE lt_zfos.

      CLEAR lt_popupline. APPEND lt_popupline.
      lt_popupline-text = 'Sudah Terclose'.
      APPEND lt_popupline. CLEAR lt_popupline.
      CONCATENATE 'Oleh User' sy-uname '/' ld_date
          INTO lt_popupline-text SEPARATED BY space.
      APPEND lt_popupline. CLEAR lt_popupline.

      CALL FUNCTION 'DD_POPUP_WITH_INFOTEXT'
        EXPORTING
          titel              = 'Close Faktur Opname Info'
          start_column       = '30'
          start_row          = '3'
          end_column         = '70'
          end_row            = '7'
*          INFOFLAG           = ' '
        IMPORTING
          answer             = l_answer
        TABLES
          lines              = lt_popupline.

      LEAVE TO SCREEN 0.

    ENDIF.
  ENDIF.

ENDFORM.                    " f_save_close_fo

*&---------------------------------------------------------------------*
*&      Form  f_save_input_fo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_input_fo.

  DATA: lt_zfod LIKE zfod OCCURS 0 WITH HEADER LINE.

  lt_zfod[] = itab[].

  MODIFY zfod FROM TABLE lt_zfod.

  LEAVE TO SCREEN 0.

ENDFORM.                    " f_save_input_fo

*-------------------------------------------------------
* TYPE FOR THE DATA OF TABLECONTROL 'TC_0500'
*TYPES: BEGIN OF T_TC_0500,
*         VKBUR LIKE ZFOD-VKBUR,
*         KUNNR LIKE ZFOD-KUNNR,
*         ZUONR LIKE ZFOD-ZUONR,
*         XREF2 LIKE ZFOD-XREF2,
*         BUDAT LIKE ZFOD-BUDAT,
*         ZFBDT LIKE ZFOD-ZFBDT,
*         GIDAT LIKE ZFOD-GIDAT,
*         GIRO LIKE ZFOD-GIRO,
*         BILL LIKE ZFOD-BILL,
*         FAKTUR LIKE ZFOD-FAKTUR,
*         STATUS LIKE ZFOD-STATUS,
*         NAME1 LIKE ZFOD-NAME1,
*         TEXT LIKE ZFOD-TEXT,
*         TEXT2 LIKE ZFOD-TEXT2,
*         WAERS LIKE ZFOD-WAERS,
*       END OF T_TC_0500.
TYPES: BEGIN OF t_tc_0500.
        INCLUDE STRUCTURE zfod.
TYPES: END OF t_tc_0500.

* INTERNAL TABLE FOR TABLECONTROL 'TC_0500'
DATA:     g_tc_0500_itab   TYPE t_tc_0500 OCCURS 0,
          g_tc_0500_wa     TYPE t_tc_0500, "work area
          g_tc_0500_copied.           "copy flag

* DECLARATION OF TABLECONTROL 'TC_0500' ITSELF
CONTROLS: tc_0500 TYPE TABLEVIEW USING SCREEN 0500.

* LINES OF TABLECONTROL 'TC_0500'
DATA:     g_tc_0500_lines  LIKE sy-loopc.

DATA:     ok_code LIKE sy-ucomm.

* OUTPUT MODULE FOR TABLECONTROL 'TC_0500':
* COPY DDIC-TABLE TO ITAB
MODULE tc_0500_init OUTPUT.

  DATA : l_sortl LIKE kna1-sortl,
         l_lines TYPE i.

  IF g_tc_0500_copied IS INITIAL.
* COPY DDIC-TABLE 'ZFOD'
* INTO INTERNAL TABLE 'g_TC_0500_itab'
*    SELECT vkbur kunnr zuonr xref2 budat zfbdt
*           gidat giro bill faktur status name1
*           text text2 waers
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE g_tc_0500_itab
      FROM zfod
      WHERE bukrs EQ p_bukrs1  AND
*            vkbur IN s_vkbur1  AND
            vkbur EQ p_vkbur1  AND
            zfoid IN s_zfoid1  AND
            status IN s_stat1  AND
            kunnr IN s_kunnr1  AND
            kdgrp IN s_kdgrp1  AND
            xref1 IN s_xref11  AND
            xref2 IN s_xref21  AND
            zuonr IN s_zuonr1  AND
            zclos = space
      ORDER BY PRIMARY KEY.

    LOOP AT g_tc_0500_itab INTO g_tc_0500_wa.
      SELECT SINGLE name1 sortl
        INTO (g_tc_0500_wa-name1, l_sortl)
        FROM kna1 WHERE kunnr EQ g_tc_0500_wa-kunnr.
      READ TABLE i_live WITH KEY vstel = g_tc_0500_wa-vkbur.
      IF sy-subrc = 0.
        g_tc_0500_wa-sortl = g_tc_0500_wa-kunnr.
        g_tc_0500_wa-kunnr = l_sortl.
      ENDIF.
      MODIFY g_tc_0500_itab FROM g_tc_0500_wa.
    ENDLOOP.

    g_tc_0500_copied = 'X'.
    REFRESH CONTROL 'TC_0500' FROM SCREEN '0500'.

    DESCRIBE TABLE g_tc_0500_itab LINES l_lines.
    MESSAGE s000(zf) WITH l_lines 'Record'.
  ENDIF.

ENDMODULE.                    "tc_0500_init OUTPUT

* OUTPUT MODULE FOR TABLECONTROL 'TC_0500':
* MOVE ITAB TO DYNPRO
MODULE tc_0500_move OUTPUT.
  MOVE-CORRESPONDING g_tc_0500_wa TO zfod.
ENDMODULE.                    "tc_0500_move OUTPUT

* OUTPUT MODULE FOR TABLECONTROL 'TC_0500':
* GET LINES OF TABLECONTROL
MODULE tc_0500_get_lines OUTPUT.
  g_tc_0500_lines = sy-loopc.
ENDMODULE.                    "tc_0500_get_lines OUTPUT

* INPUT MODULE FOR TABLECONTROL 'TC_0500': MODIFY TABLE
MODULE tc_0500_modify INPUT.
  DATA: ld_sortl LIKE g_tc_0500_wa-sortl.
  ld_sortl = g_tc_0500_wa-sortl.
  MOVE-CORRESPONDING zfod TO g_tc_0500_wa.
  g_tc_0500_wa-sortl = ld_sortl.
  g_tc_0500_wa-giro = g_tc_0500_wa-giro / 100.
  g_tc_0500_wa-bill = g_tc_0500_wa-bill / 100.
  g_tc_0500_wa-faktur = g_tc_0500_wa-faktur / 100.
  g_tc_0500_wa-chusr = sy-uname.
  g_tc_0500_wa-chdat = sy-datum.
  g_tc_0500_wa-chtim = sy-uzeit.
  CLEAR i_status.
  READ TABLE i_status WITH KEY domvalue_l = g_tc_0500_wa-status.
  g_tc_0500_wa-text = i_status-ddtext.

  MODIFY g_tc_0500_itab
    FROM g_tc_0500_wa
    INDEX tc_0500-current_line.
ENDMODULE.                    "tc_0500_modify INPUT

* INPUT MODULE FOR TABLECONTROL 'TC_0500': PROCESS USER COMMAND
MODULE tc_0500_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_0500'
                              'G_TC_0500_ITAB'
                              'FLAG'
                     CHANGING ok_code.
ENDMODULE.                    "tc_0500_user_command INPUT

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                         p_table_name
                         p_mark_name
                CHANGING p_ok      LIKE sy-ucomm.

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA: l_ok              TYPE sy-ucomm,
        l_offset          TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

* Table control specific operations                                    *
*   evaluate TC name and operations                                    *
  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  l_offset = STRLEN( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.

* execute general and TC specific operations                           *
  CASE l_ok.
    WHEN 'INSR'.                      "insert row
      PERFORM fcode_insert_row USING    p_tc_name
                                        p_table_name.
      CLEAR p_ok.

    WHEN 'DELE'.                      "delete row
      PERFORM fcode_delete_row USING    p_tc_name
                                        p_table_name
                                        p_mark_name.
      CLEAR p_ok.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM compute_scrolling_in_tc USING p_tc_name
                                            l_ok.
      CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM fcode_tc_mark_lines USING p_tc_name
                                        p_table_name
                                        p_mark_name   .
      CLEAR p_ok.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM fcode_tc_demark_lines USING p_tc_name
                                          p_table_name
                                          p_mark_name .
      CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

    WHEN 'SC' OR                     "Search Text
         'SC+'.                      "Search Next Text
      PERFORM search_text_in_tc USING p_tc_name
                                      p_table_name
                                      l_ok.
      CLEAR p_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_insert_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name             .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_lines_name       LIKE feld-name.
  DATA l_selline          LIKE sy-stepl.
  DATA l_lastline         TYPE i.
  DATA l_line             TYPE i.
  DATA l_table_name       LIKE feld-name.
  FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
  FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lines>              TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* get looplines of TableControl
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
  ASSIGN (l_lines_name) TO <lines>.

* get current line
  GET CURSOR LINE l_selline.
  IF sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
*   set top line and new cursor line                                   *
    IF l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
      l_line = 1.
    ELSE.
      <tc>-top_line = 1.
      l_line = l_selline.
    ENDIF.
  ELSE.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
*   set top line and new cursor line                                   *
    l_lastline = l_selline + <lines> - 1.
    IF l_lastline <= <tc>-lines.
      <tc>-top_line = l_selline.
      l_line = 1.
    ELSEIF <lines> > <tc>-lines.
      <tc>-top_line = 1.
      l_line = l_selline.
    ELSE.
      <tc>-top_line = <tc>-lines - <lines> + 2 .
      l_line = l_selline - <tc>-top_line + 1.
    ENDIF.
  ENDIF.
* insert initial line
  INSERT INITIAL LINE INTO <table> INDEX l_selline.
  <tc>-lines = <tc>-lines + 1.
* set cursor
  SET CURSOR LINE l_line.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* delete marked lines                                                  *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      IF sy-subrc = 0.
        <tc>-lines = <tc>-lines - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM compute_scrolling_in_tc USING    p_tc_name
                                      p_ok.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_tc_new_top_line     TYPE i.
  DATA l_tc_name             LIKE feld-name.
  DATA l_tc_lines_name       LIKE feld-name.
  DATA l_tc_field_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <lines>      TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.
* get looplines of TableControl
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
  ASSIGN (l_tc_lines_name) TO <lines>.


* is no line filled?                                                   *
  IF <tc>-lines = 0.
*   yes, ...                                                           *
    l_tc_new_top_line = 1.
  ELSE.
*   no, ...                                                            *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
         EXPORTING
              entry_act             = <tc>-top_line
              entry_from            = 1
              entry_to              = <tc>-lines
              last_page_full        = 'X'
              loops                 = <lines>
              ok_code               = p_ok
              overlapping           = 'X'
         IMPORTING
              entry_new             = l_tc_new_top_line
         EXCEPTIONS
*              NO_ENTRY_OR_PAGE_ACT  = 01
*              NO_ENTRY_TO           = 02
*              NO_OK_CODE_OR_PAGE_GO = 03
              OTHERS                = 0.
  ENDIF.

* get actual tc and column                                             *
  GET CURSOR FIELD l_tc_field_name
             AREA  l_tc_name.

  IF syst-subrc = 0.
    IF l_tc_name = p_tc_name.
*     set actual column                                                *
      SET CURSOR FIELD l_tc_field_name LINE 1.
    ENDIF.
  ENDIF.

* set the new top line                                                 *
  <tc>-top_line = l_tc_new_top_line.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
                               p_table_name
                               p_mark_name.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* mark all filled lines                                                *
  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
                                 p_table_name
                                 p_mark_name .
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* demark all filled lines                                              *
  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = space.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0500 OUTPUT.

  SET PF-STATUS 'STATUS_500'.
  SET TITLEBAR 'TITLE_500'.

ENDMODULE.                 " STATUS_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0500 INPUT.

  CASE ok_code.
    WHEN 'SAVE'.
      LOOP AT g_tc_0500_itab INTO g_tc_0500_wa.
        READ TABLE i_live WITH KEY vstel = g_tc_0500_wa-vkbur.
        IF sy-subrc = 0.
          g_tc_0500_wa-kunnr = g_tc_0500_wa-sortl.
        ENDIF.
        MODIFY g_tc_0500_itab FROM g_tc_0500_wa.
      ENDLOOP.
      MODIFY zfod FROM TABLE g_tc_0500_itab.
      LEAVE TO SCREEN 0.

    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCL'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0500  INPUT

*&---------------------------------------------------------------------*
*&      Form  f_save_selscr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_selscr.

  DATA: ld_no TYPE i,
        ld_date(10),
        ld_head LIKE thead,
        ld_hname LIKE ld_head-tdname,
        lt_sels1 TYPE tline OCCURS 0 WITH HEADER LINE.

  WRITE pa_budat TO ld_date.
  REFRESH lt_sels1.
*  APPEND INITIAL LINE TO lt_sels1.
  ADD 1 TO ld_no.
  lt_sels1-tdformat = ld_no.
  lt_sels1-tdline = 'Parameters :'.
  APPEND lt_sels1.

  ADD 1 TO ld_no.
  lt_sels1-tdformat = ld_no.
  CONCATENATE 'Company Code           :' pa_bukrs INTO lt_sels1-tdline
        SEPARATED BY space.
  APPEND lt_sels1.

  ADD 1 TO ld_no.
  lt_sels1-tdformat = ld_no.
  CONCATENATE 'Sales Office           :' pa_vkbur INTO lt_sels1-tdline
        SEPARATED BY space.
  APPEND lt_sels1.

  ADD 1 TO ld_no.
  lt_sels1-tdformat = ld_no.
  CONCATENATE 'Open Items at key date :' ld_date INTO lt_sels1-tdline
        SEPARATED BY space.
  APPEND lt_sels1.

  ADD 1 TO ld_no.
  lt_sels1-tdformat = ld_no.
  CONCATENATE 'Normal Item            :' x_norm INTO lt_sels1-tdline
        SEPARATED BY space.
  APPEND lt_sels1.

  ADD 1 TO ld_no.
  lt_sels1-tdformat = ld_no.
  CONCATENATE 'Special G/L            :' x_shbv INTO lt_sels1-tdline
        SEPARATED BY space.
  APPEND lt_sels1.

  ADD 1 TO ld_no.
  lt_sels1-tdformat = ld_no.
  CONCATENATE 'Output Variant         :' p_vari INTO lt_sels1-tdline
        SEPARATED BY space.
  APPEND lt_sels1.

  APPEND INITIAL LINE TO lt_sels1.
  ADD 1 TO ld_no.
  lt_sels1-tdformat = ld_no.
  lt_sels1-tdline = 'Select Option :'.
  APPEND lt_sels1.

*  IF NOT so_vkbur[] IS INITIAL.
*    LOOP AT so_vkbur.
*      ADD 1 TO ld_no.
*      lt_sels1-tdformat = ld_no.
*      CONCATENATE 'Sales Office   :' so_vkbur-sign so_vkbur-option
*            so_vkbur-low so_vkbur-high INTO lt_sels1-tdline
*            SEPARATED BY space.
*      APPEND lt_sels1.
*    ENDLOOP.
*  ENDIF.

  IF NOT so_kdgrp[] IS INITIAL.
    APPEND INITIAL LINE TO lt_sels1.
    LOOP AT so_kdgrp.
      ADD 1 TO ld_no.
      lt_sels1-tdformat = ld_no.
      CONCATENATE 'Customer Group :' so_kdgrp-sign so_kdgrp-option
            so_kdgrp-low so_kdgrp-high INTO lt_sels1-tdline
            SEPARATED BY space.
      APPEND lt_sels1.
    ENDLOOP.
  ENDIF.

  IF NOT so_xref1[] IS INITIAL.
    APPEND INITIAL LINE TO lt_sels1.
    LOOP AT so_xref1.
      ADD 1 TO ld_no.
      lt_sels1-tdformat = ld_no.
      CONCATENATE 'Route List     :' so_xref1-sign so_xref1-option
            so_xref1-low so_xref1-high INTO lt_sels1-tdline
            SEPARATED BY space.
      APPEND lt_sels1.
    ENDLOOP.
  ENDIF.

  IF NOT so_xref2[] IS INITIAL.
    APPEND INITIAL LINE TO lt_sels1.
    LOOP AT so_xref2.
      ADD 1 TO ld_no.
      lt_sels1-tdformat = ld_no.
      CONCATENATE 'Salesman Code  :' so_xref2-sign so_xref2-option
            so_xref2-low so_xref2-high INTO lt_sels1-tdline
            SEPARATED BY space.
      APPEND lt_sels1.
    ENDLOOP.
  ENDIF.

  IF NOT so_pernr[] IS INITIAL.
    APPEND INITIAL LINE TO lt_sels1.
    LOOP AT so_pernr.
      ADD 1 TO ld_no.
      lt_sels1-tdformat = ld_no.
      CONCATENATE 'Borderel Inkaso Code :' so_pernr-sign so_pernr-option
                         so_pernr-low so_pernr-high INTO lt_sels1-tdline
                                                      SEPARATED BY space.
      APPEND lt_sels1.
    ENDLOOP.
  ENDIF.

  IF NOT so_zuonr[] IS INITIAL.
    APPEND INITIAL LINE TO lt_sels1.
    LOOP AT so_zuonr.
      ADD 1 TO ld_no.
      lt_sels1-tdformat = ld_no.
      CONCATENATE 'Document number DO / CN :' so_zuonr-sign
            so_zuonr-option so_zuonr-low so_zuonr-high
            INTO lt_sels1-tdline SEPARATED BY space.
      APPEND lt_sels1.
    ENDLOOP.
  ENDIF.

  IF NOT so_kunnr[] IS INITIAL.
    APPEND INITIAL LINE TO lt_sels1.
    LOOP AT so_kunnr.
      ADD 1 TO ld_no.
      lt_sels1-tdformat = ld_no.
      CONCATENATE 'Customer Number :' so_kunnr-sign so_kunnr-option
            so_kunnr-low so_kunnr-high INTO lt_sels1-tdline
            SEPARATED BY space.
      APPEND lt_sels1.
    ENDLOOP.
  ENDIF.

  ld_head-tdobject = 'FEATURE'.
  ld_head-tdid     = 'HEAD'.
  ld_head-tdspras  = 'E'.

  LOOP AT i_zfos.

    CONCATENATE i_zfos-bukrs i_zfos-vkbur i_zfos-zfoid
          INTO  ld_hname.
    ld_head-tdname   = ld_hname.

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
*       CLIENT                = SY-MANDT
        header                = ld_head
*        INSERT                = 'X'
        savemode_direct       = 'X'
*       OWNER_SPECIFIED       = ' '
*       LOCAL_CAT             = ' '
*     IMPORTING
*       FUNCTION              =
*       NEWHEADER             =
      TABLES
        lines                 = lt_sels1
     EXCEPTIONS
       id                    = 1
       language              = 2
       name                  = 3
       object                = 4
       OTHERS                = 5.

    CASE sy-subrc.
      WHEN 1.
        MESSAGE i000(zf) WITH 'Text ID in text header invalid'.
      WHEN 2.
        MESSAGE i000(zf) WITH 'Language in text header invalid'.
      WHEN 3.
        MESSAGE i000(zf) WITH 'Text name in text header invalid'.
      WHEN 4.
        MESSAGE i000(zf) WITH 'Text object in text header invalid'.
    ENDCASE.

  ENDLOOP.

ENDFORM.                    " f_save_selscr

*&---------------------------------------------------------------------*
*&      Form  f_write_selscreen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_selscreen.

  DATA: ld_head LIKE thead,
        ld_hname LIKE ld_head-tdname,
        lt_sels1 TYPE tline OCCURS 0 WITH HEADER LINE,
        lt_sels2 TYPE tline OCCURS 0 WITH HEADER LINE.

  IF radio1 = 'X'.
    READ TABLE i_zfos INDEX 1.
  ELSE.
    READ TABLE itab INDEX 1.
  ENDIF.

  IF sy-subrc = 0.
    IF radio1 = 'X'.
      CONCATENATE i_zfos-bukrs i_zfos-vkbur i_zfos-zfoid
            INTO  ld_hname.
    ELSE.
      CONCATENATE itab-bukrs itab-vkbur itab-zfoid
            INTO  ld_hname.
    ENDIF.

    CALL FUNCTION 'READ_TEXT_INLINE'
      EXPORTING
        id                    = 'HEAD'
        inline_count          = 15
        language              = 'E'
        name                  = ld_hname
        object                = 'FEATURE'
*        LOCAL_CAT             = ' '
*      IMPORTING
*        HEADER                =
      TABLES
        inlines               = lt_sels1
        lines                 = lt_sels2
      EXCEPTIONS
        id                    = 1
        language              = 2
        name                  = 3
        not_found             = 4
        object                = 5
        reference_check       = 6
        OTHERS                = 7
              .
    IF sy-subrc = 0.
      LOOP AT lt_sels1.
        IF lt_sels1-tdline IS INITIAL.
          SKIP 1.
        ELSE.
          WRITE: /5 lt_sels1-tdline.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " f_write_selscreen

*&---------------------------------------------------------------------*
*&      Form  search_text_in_tc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  text
*      -->P_TABLE_NAME  text
*      -->P_OK  text
*----------------------------------------------------------------------*
FORM search_text_in_tc USING    p_tc_name
                                p_table_name
                                p_ok.
  DATA: l_cancel(1),
        l_search_order(1),
        l_table_name LIKE feld-name.

  FIELD-SYMBOLS: <tc>    TYPE cxtab_control,
                 <table> TYPE STANDARD TABLE,
                 <lines> TYPE ANY,
                 <fs>    TYPE ANY.

  DATA : lv_str   TYPE string,
         lv_exit,
         lv_field(20).

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

  CASE p_ok.
    WHEN 'SC'.
      CALL FUNCTION 'ALV_POPUP_TO_SEARCH'
*       EXPORTING
*         I_DISABLE_SEARCH_SEQUENCE       = ' '
        IMPORTING
          e_cancelled                     = l_cancel
        CHANGING
          c_string                        = v_text
          c_search_order                  = l_search_order.

      IF l_cancel IS INITIAL.
        CLEAR : lv_exit, v_line.
        LOOP AT <table> ASSIGNING <lines>.
          v_line = sy-tabix.
          DO.
            ASSIGN COMPONENT sy-index OF STRUCTURE <lines> TO <fs>.
            IF sy-subrc = 0.
              lv_str = <fs>.
              IF v_text = lv_str.
                <tc>-top_line = v_line.
                lv_exit = 'X'.
                EXIT.
              ENDIF.
            ELSE.
              EXIT.
            ENDIF.
          ENDDO.
          IF lv_exit IS NOT INITIAL.
            CONCATENATE p_tc_name '-ZUONR' INTO lv_field.
            SET CURSOR FIELD lv_field LINE v_line.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF lv_exit IS INITIAL.
          MESSAGE i000(zf)
            WITH 'Search unsuccessful - no hits found for:' v_text.
        ENDIF.

*        v_line = 1.
*        SEARCH <table> FOR v_text STARTING AT v_line.
*        IF sy-subrc = 0.
*          <tc>-top_line = sy-tabix.
*          v_line = sy-tabix.
**          SET CURSOR FIELD 'ZFOD-STATUS' LINE 1.
*        ELSE.
*          MESSAGE i000(zf)
*            WITH 'Search unsuccessful - no hits found for:' v_text.
*        ENDIF.
      ENDIF.

    WHEN 'SC+'.
        CLEAR : lv_exit, v_line.
        LOOP AT <table> ASSIGNING <lines>.
          v_line = sy-tabix.
          DO.
            ASSIGN COMPONENT sy-index OF STRUCTURE <lines> TO <fs>.
            IF sy-subrc = 0.
              lv_str = <fs>.
              IF v_text = lv_str.
                <tc>-top_line = v_line.
                lv_exit = 'X'.
                EXIT.
              ENDIF.
            ELSE.
              EXIT.
            ENDIF.
          ENDDO.
          IF lv_exit IS NOT INITIAL.
            CONCATENATE p_tc_name '-ZUONR' INTO lv_field.
            SET CURSOR FIELD lv_field LINE v_line.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF lv_exit IS INITIAL.
          MESSAGE i000(zf)
            WITH 'Search unsuccessful - no hits found for:' v_text.
        ENDIF.

*      ADD 1 TO v_line.
*      SEARCH <table> FOR v_text STARTING AT v_line.
*      IF sy-subrc = 0.
*        <tc>-top_line = sy-tabix.
*        v_line = sy-tabix.
**        SET CURSOR FIELD 'ZFOD-STATUS' LINE 1.
*      ELSE.
*        MESSAGE i000(zf)
*          WITH 'Search unsuccessful - no hits found for:' v_text.
*      ENDIF.

  ENDCASE.

ENDFORM.                    " search_text_in_tc
