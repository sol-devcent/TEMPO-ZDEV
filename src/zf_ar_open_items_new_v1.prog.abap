REPORT zf_ar_open_items MESSAGE-ID zs NO STANDARD PAGE HEADING
                                  LINE-COUNT 60
                                  LINE-SIZE  350.

TABLES : bsid,knb1,tgsb,t001, tvbur,knvv.

DATA: BEGIN OF it_bsid OCCURS 0,
        bukrs     LIKE bsid-bukrs,        " Company Code
        kunnr     LIKE bsid-kunnr,        " Cust code
        vkbur     LIKE knvv-vkbur,        " Business Area
        gjahr     LIKE bsid-gjahr,        " Fiscal Year
        belnr     LIKE bsid-belnr,        " Document No
        budat     LIKE bsid-budat,        " Posting Date
        augdt     LIKE bsid-augdt,        " Clearing date.
        monat     LIKE bsid-monat,        " Periode
        bschl     LIKE bsid-bschl,        " Posting Key
        dmbtr     LIKE bsid-dmbtr,        " Amount in local curr
        shkzg     LIKE bsid-shkzg,        " Debit/Credit indicator.
        zfbdt     LIKE bsid-zfbdt,        " Baseline Date
        zbd1t     LIKE bsid-zbd1t,        " Term of payment
        blart     LIKE bsid-blart,        " Document Type
        zuonr     LIKE bsid-zuonr,        " Do Number
        xref1     LIKE bsid-xref1,        " Route List
        xref2     LIKE bsid-xref2,        " Salesman Code
        kdgrp     LIKE knvv-kdgrp,        " Customer Group
        kvgr3     LIKE knvv-kvgr3,
        umskz     LIKE bsid-umskz,        " Special G/L Indicator
        sortl     LIKE kna1-sortl,
        name1     LIKE kna1-name1,
        slcode(6),
        faktur    LIKE bsid-dmbtr,
        zterm     LIKE knb1-zterm,
        bldat     LIKE bsid-bldat,
        sgtxt     LIKE bsid-sgtxt,
        anln1     LIKE bsid-anln1,
        duedt     LIKE bsid-zfbdt,
        duedt1    LIKE bsid-zfbdt,
        cpudt     LIKE bsid-cpudt,
        kidno     LIKE bsid-kidno,
*         divcod  TYPE zdivcod,
        divcod    TYPE fkarv,
        vbeln     TYPE bsid-vbeln,
        aubel     TYPE vbrp-aubel,
      END OF it_bsid.

DATA : gt_da LIKE it_bsid OCCURS 0 WITH HEADER LINE,
       gt_rv LIKE it_bsid OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_zfbid OCCURS 0,
         bukrs LIKE zfbid-bukrs,
         vkbur LIKE zfbid-vkbur,
         kunnr LIKE zfbid-kunnr,
         zuonr LIKE zfbid-zuonr,
         zfbdt LIKE zfbid-zfbdt,
       END OF gt_zfbid.

DATA : BEGIN OF gt_zfh_kr1at OCCURS 0,
         bukrs  LIKE zfh_kr1at-bukrs,
         gsber  LIKE zfh_kr1at-gsber,
         vkbur  LIKE zfh_kr1at-vkbur,
         noform LIKE zfh_kr1at-noform,
         zuonr  LIKE zfh_kr1at-zuonr,
         kunnr  LIKE zfh_kr1at-kunnr,
         sgtxt1 LIKE zfh_kr1at-sgtxt1,
         sgtxt2 LIKE zfh_kr1at-sgtxt2,
       END OF gt_zfh_kr1at.

DATA: BEGIN OF gt_zplbc OCCURS 0,
        bukrs TYPE bukrs,
        werks TYPE werks_d,
        live  TYPE zlive_indicator,
      END OF gt_zplbc.

DATA: BEGIN OF gt_zssutdt003 OCCURS 0,
        brcod	 TYPE zbrcod,
        seqtyp TYPE zseqtyp,
        seqnr	 TYPE zseqnr,
        spmth	 TYPE zspmth,
        spyear TYPE zspyear,
        divcod TYPE zdivcod,
      END OF gt_zssutdt003.

DATA: BEGIN OF gt_hsales OCCURS 0,
        vkbur  TYPE vkbur,
        gjahr  TYPE gjahr,
        vbeln  TYPE vbeln,
        vbtyp  TYPE vbtyp,
        fkart  TYPE fkart,
        auart  LIKE zscr_control-auart,
        divcod LIKE zscr_control-divcod,
      END OF gt_hsales.

DATA: BEGIN OF gt_likp OCCURS 0,
        vbeln TYPE vbeln_vl,
        fkarv TYPE fkarv,
      END OF gt_likp.

DATA: BEGIN OF gt_lips OCCURS 0,
        vbeln TYPE vbeln,
        vgbel TYPE vgbel,
      END OF gt_lips.

DATA: BEGIN OF gt_vbak OCCURS 0,
        vbeln TYPE vbeln,
        auart TYPE auart,
      END OF gt_vbak.

DATA: BEGIN OF i_tvkol OCCURS 0,
        vstel   LIKE tvkol-vstel,
        werks   LIKE tvkol-werks,
        lgort   LIKE tvkol-lgort,
        live    LIKE zplbc-live,
        mixlive LIKE zplbc-mixlive,
      END OF i_tvkol.

DATA: BEGIN OF t_salesman OCCURS 0.
        INCLUDE STRUCTURE knvp.
      DATA: END OF t_salesman.
DATA: BEGIN OF t_routelist OCCURS 0.
        INCLUDE STRUCTURE knvp.
      DATA: END OF t_routelist.

DATA: BEGIN OF t_zterm OCCURS 0.
DATA: kunnr LIKE knvv-kunnr,
      zterm LIKE knvv-zterm,
      sortl LIKE kna1-sortl.
DATA: END OF t_zterm.

DATA: BEGIN OF t_bsid_temp OCCURS 0.
        INCLUDE STRUCTURE it_bsid.
      DATA: END OF t_bsid_temp.
DATA: BEGIN OF t_bsid_open OCCURS 0.
        INCLUDE STRUCTURE it_bsid.
      DATA: END OF t_bsid_open.

DATA: BEGIN OF t_reclas OCCURS 0.
        INCLUDE STRUCTURE it_bsid.
      DATA: END OF t_reclas.

DATA: BEGIN OF it_gsber OCCURS 0,
        gsber LIKE bsid-gsber,
      END OF it_gsber.

DATA: BEGIN OF it_brcust OCCURS 0,
        kunnr LIKE bsid-kunnr,
        zuonr LIKE bsid-zuonr,
      END OF it_brcust.

DATA: BEGIN OF it_brcustgr OCCURS 0,
        kdgrp LIKE knvv-kdgrp,
      END OF it_brcustgr.

DATA: BEGIN OF it_brsales OCCURS 0,
        xref2 LIKE bsid-xref2,
      END OF it_brsales.

DATA: BEGIN OF it_brroute OCCURS 0,
        xref1 LIKE bsid-xref1,
      END OF it_brroute.

DATA: BEGIN OF itab OCCURS 0,
        gsber        LIKE bsid-gsber,
        name1        LIKE kna1-name1,
        kunnr        LIKE bsid-kunnr,
        zuonr        LIKE bsid-zuonr,
        vbeln        LIKE bsid-vbeln,
        budat        LIKE bsid-budat,
        bldat        LIKE bsid-bldat,
        zfbdt        LIKE bsid-zfbdt,
        zbd1t        LIKE bsid-zbd1t,
*      bbeln  LIKE zfbicheck-bbeln,
        bbeln        LIKE zfbic_sfa-bbeln,
        duedt        LIKE bsid-budat,
        duedt1       LIKE bsid-budat,
        giro         LIKE bsid-dmbtr,
        bill         LIKE bsid-dmbtr,
        ending       LIKE bsid-dmbtr,
        faktur       LIKE bsid-dmbtr,
        sortl        LIKE kna1-sortl,
        due(1),
        zterm        LIKE knb1-zterm,
        slcod(6),
        top(6),
        sgtxt        LIKE bsid-sgtxt,
        anln1        LIKE bsid-anln1,
        kunnr1       LIKE bsid-kunnr,
        auart        TYPE auart,
*      divcod  TYPE zdivcod,
        divcod       TYPE fkarv,
        nottf        LIKE zfbid-nottf,
        tglttf       LIKE zfbid-tglttf,
        tglttf2      LIKE zfbid-tglttf,
        tglttfc(10),
        tglttf2c(10),
        bstnk(50),
      END OF itab.

DATA: BEGIN OF itab1 OCCURS 0,
        gsber  LIKE bsid-gsber,
        zuonr  LIKE bsid-zuonr,
        budat  LIKE bsid-budat,
        bldat  LIKE bsid-bldat,
*      bbeln LIKE zfbicheck-bbeln,
        bbeln  LIKE zfbic_sfa-bbeln,
        duedt  LIKE bsid-budat,
        giro   LIKE bsid-dmbtr,
        bill   LIKE bsid-dmbtr,
        ending LIKE bsid-dmbtr,
        due(1),
      END OF itab1.

DATA: BEGIN OF itab2 OCCURS 0,
        gsber  LIKE bsid-gsber,
        kdgrp  LIKE knvv-kdgrp,
        giro   LIKE bsid-dmbtr,
        bill   LIKE bsid-dmbtr,
        ending LIKE bsid-dmbtr,
      END OF itab2.

DATA: BEGIN OF itab3 OCCURS 0,
        gsber  LIKE bsid-gsber,
        xref2  LIKE bsid-xref2,
        bill   LIKE bsid-dmbtr,
        ending LIKE bsid-dmbtr,
      END OF itab3.

DATA: BEGIN OF itab4 OCCURS 0,
        gsber  LIKE bsid-gsber,
        xref1  LIKE bsid-xref1,
        bill   LIKE bsid-dmbtr,
        ending LIKE bsid-dmbtr,
      END OF itab4.

DATA: BEGIN OF i_giro OCCURS 0.
        INCLUDE STRUCTURE zfbicheck.
      DATA  END OF i_giro.

DATA: BEGIN OF i_giro_sfa OCCURS 0.
        INCLUDE STRUCTURE zfbic_sfa.
      DATA  END OF i_giro_sfa.

DATA : w1      TYPE i,  w2    TYPE i,  w3    TYPE i,  w4    TYPE i,
       w5      TYPE i,  w6    TYPE i,  w7    TYPE i,  w8    TYPE i,
       w9      TYPE i,  w10   TYPE i,  w11   TYPE i,  w12   TYPE i,
       w13     TYPE i,  w14   TYPE i,  w15   TYPE i,  w16   TYPE i,
       c1      TYPE i,  no    TYPE i,n_lines TYPE i,  c3    TYPE i,
       w50     TYPE i,  w18   TYPE i,  w22   TYPE i.
DATA: plant       LIKE bsid-gsber,
      v_bill      LIKE bsid-dmbtr,
      v_saldo     LIKE bsid-dmbtr,
      v_ending    LIKE bsid-dmbtr,
      v_subgiro   LIKE bsid-dmbtr,
      v_subbill   LIKE bsid-dmbtr,
      v_subsaldo  LIKE bsid-dmbtr,
      v_subending LIKE bsid-dmbtr,
      v_giro      LIKE bsid-dmbtr,
      name1       LIKE kna1-name1,no1 TYPE i,
      v_pernr     LIKE knb1-pernr,
      bulan(30),p_gerdat1 LIKE bsid-budat,
      cab         LIKE tgsbt-gtext,
      linesort    TYPE i,srt(1),
      page        TYPE i.

DATA: gtext(60) TYPE c,
      igui      TYPE i,
      va_live   LIKE zplbc-live,
      char4(4),
      char6(6).

DATA : gt_xvbak    TYPE STANDARD TABLE OF vbak,
       gt_xvbrp    TYPE STANDARD TABLE OF vbrp,
       gt_xvbfa    TYPE STANDARD TABLE OF vbfa,
       gt_zfarpotd TYPE STANDARD TABLE OF zfarpotd,
       gt_zfarpoth TYPE STANDARD TABLE OF zfarpoth.

RANGES : r_gerdat FOR bsid-budat.

DATA: BEGIN OF t_bsid_add OCCURS 0.
        INCLUDE STRUCTURE it_bsid.
      DATA: END OF t_bsid_add.

DATA: BEGIN OF t_zfarsoff_dele OCCURS 0.
        INCLUDE STRUCTURE zfarsoff.
      DATA: END OF t_zfarsoff_dele.
DATA: BEGIN OF t_zfarsoff_add OCCURS 0.
        INCLUDE STRUCTURE zfarsoff.
      DATA: END OF t_zfarsoff_add.

DATA gt_zfarsoff LIKE zfarsoff OCCURS 0 WITH HEADER LINE.

FIELD-SYMBOLS: <fs_itab> LIKE itab.

SELECTION-SCREEN: BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-002.
PARAMETERS    : p_bukrs LIKE bkpf-bukrs OBLIGATORY.
SELECT-OPTIONS:
                s_gsber FOR tvbur-vkbur.
SELECT-OPTIONS: p_kdgrp FOR knvv-kdgrp,
                p_kvgr3 FOR knvv-kvgr3 MODIF ID kv3,
                p_route FOR knvv-kunnr,
                p_slcode FOR char6.
*PARAMETERS    : P_KDGRP LIKE KNVV-KDGRP,
*                P_ROUTE(4) TYPE N,
*                P_SLCODE(6),
*PARAMETERS    : p_amount LIKE bsid-dmbtr.
PARAMETERS    : p_amount(13) TYPE i.

SELECT-OPTIONS  s_parnr FOR  knb1-pernr.  "NO INTERVALS.

SELECT-OPTIONS:
                s_do    FOR bsid-zuonr, "NO INTERVALS,
                s_kunnr FOR bsid-kunnr.
PARAMETER       p_gerdat LIKE bsid-budat OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN: BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-003.
PARAMETERS: x_norm LIKE itemset-xnorm AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS  x_shbv LIKE itemset-xshbv AS CHECKBOX.
SELECTION-SCREEN : COMMENT 4(24) TEXT-014 FOR FIELD x_shbv.
SELECTION-SCREEN:  POSITION 30.
SELECT-OPTIONS: s_bschl FOR bsid-umskz NO INTERVALS.
SELECTION-SCREEN END OF LINE.
PARAMETERS x_opdr AS CHECKBOX.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp2 DEFAULT 'X' USER-COMMAND rad.
SELECTION-SCREEN : COMMENT 5(50) TEXT-016 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 5(12) TEXT-017 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block2.

PARAMETERS: p_ord1 TYPE char1 AS CHECKBOX DEFAULT 'X'.
PARAMETERS: p_05t  TYPE char1 AS CHECKBOX USER-COMMAND chk.
PARAMETERS: x_rtv  TYPE char1 AS CHECKBOX MODIF ID rtv.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'KV3'.
      IF p_05t = 'X'.
        screen-input  = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF radio2 IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'RTV'.
        screen-active  = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

AT SELECTION-SCREEN ON p_05t.
  IF p_05t IS INITIAL.
    CLEAR: p_kvgr3,p_kvgr3[].
  ELSE.
    PERFORM f_init_kvgr3.
  ENDIF.

AT SELECTION-SCREEN ON s_parnr.
  IF NOT ( s_parnr IS INITIAL ).
    SELECT SINGLE pernr INTO v_pernr FROM knb1
           WHERE bukrs EQ p_bukrs AND
                 pernr IN s_parnr.
    IF sy-subrc NE 0.
      MESSAGE e000(zs) WITH 'No Data Borderel Inkaso Number'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON s_bschl.
  IF x_shbv = 'X' AND s_bschl IS INITIAL.
    s_bschl-low = 'T'.
    s_bschl-sign = 'I'.
    s_bschl-option = 'EQ'.
    APPEND s_bschl.

    s_bschl-low = 'V'.
    s_bschl-sign = 'I'.
    s_bschl-option = 'EQ'.
    APPEND s_bschl.

    s_bschl-low = 'U'.
    s_bschl-sign = 'I'.
    s_bschl-option = 'EQ'.
    APPEND s_bschl.

*   MESSAGE E000(ZS) WITH 'Special G/L Indicator harus diisi'.
  ENDIF.

AT SELECTION-SCREEN ON p_bukrs.
  SELECT SINGLE * FROM t001 WHERE bukrs EQ p_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Company  Not Found'.
  ENDIF.

AT SELECTION-SCREEN ON s_gsber.
  SELECT SINGLE * FROM tvbur
         WHERE vkbur IN s_gsber.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Sales Office Not Found'.
  ENDIF.

INITIALIZATION.

  DATA lv_parva(40).

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'BUK'.

  IF sy-subrc EQ 0.
    p_bukrs  = lv_parva.
  ENDIF.

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'GSB'.

  IF sy-subrc EQ 0.
    s_gsber-low  = lv_parva.
    APPEND s_gsber.
  ENDIF.

START-OF-SELECTION.

  PERFORM cek.
  PERFORM f_mapping_soff.
  PERFORM get_data.
  PERFORM f_hapus_kunnr.
  PERFORM f_tambah_kunnr.

  PERFORM f_reclas.

*  IF p_bukrs EQ '8070'.
  PERFORM f_sut_top.
*  ENDIF.

  IF radio2 IS NOT INITIAL.
    IF x_rtv IS NOT INITIAL.
      PERFORM f_add_po_number_rtv.
    ENDIF.
  ENDIF.

  PERFORM process_data.
  DESCRIBE TABLE it_bsid LINES n_lines.
  IF n_lines LE 0.
    MESSAGE s000(26) WITH 'No items selected'.
    EXIT.
  ELSE.
  ENDIF.

  PERFORM process_sum.
  PERFORM init_print.
  SET PF-STATUS '100'.
  SORT itab BY gsber kunnr zuonr.
  PERFORM write_brcust.

END-OF-SELECTION.

TOP-OF-PAGE.
  FORMAT COLOR COL_NORMAL INTENSIFIED ON.
  FORMAT COLOR 1.
  PERFORM write_header.

END-OF-PAGE.

AT LINE-SELECTION.
  READ CURRENT LINE FIELD VALUE: itab-zuonr,itab-kunnr.

  DATA : ffield(20), fvalue(20).
  GET CURSOR FIELD ffield VALUE fvalue.
  CASE ffield.

    WHEN 'ITAB-ZUONR'.
      READ TABLE  itab WITH KEY  zuonr = itab-zuonr
                                 kunnr = itab-kunnr.
      IF sy-subrc EQ 0.
        PERFORM submit.
      ENDIF.
    WHEN 'ITAB-BUDAT'.
      srt = 'X'.
  ENDCASE.

***********************************************************************

* AT USER-COMMAND.
***********************************************************************

AT USER-COMMAND.
  sy-lsind = 0.
  CASE sy-ucomm.
    WHEN 'SORTA'.
      IF srt EQ 'X'.
        SORT itab BY gsber kunnr budat.
        DESCRIBE TABLE s_kunnr LINES linesort.
        PERFORM write_brcust.
      ENDIF.
    WHEN 'SORTD'.
      IF srt EQ 'X'.
        SORT itab BY gsber kunnr budat DESCENDING.
        DESCRIBE TABLE s_kunnr LINES linesort.
        PERFORM write_brcust.
      ENDIF.
  ENDCASE.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.
  DATA: ld_gerdat LIKE sy-datum,
        ld_flag   TYPE i.

  IF ld_flag IS INITIAL.
    CONCATENATE p_gerdat(6) '01' INTO ld_gerdat.
    ld_flag = 1.
  ELSE.
    CONCATENATE ld_gerdat(6) '01' INTO ld_gerdat.
  ENDIF.
  ld_gerdat = ld_gerdat - 1.
  CONCATENATE ld_gerdat(6) '01' INTO ld_gerdat.

  IF x_norm EQ 'X' AND x_shbv EQ 'X'.
    IF x_opdr IS INITIAL.
      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        INTO CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs AND
              a~kunnr IN s_kunnr AND
              budat LE p_gerdat  AND
              a~umskz EQ space   AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur IN s_gsber AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr AND
              b~kdgrp IN p_kdgrp AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        APPENDING  CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs  AND
              a~kunnr IN s_kunnr  AND
              budat LE p_gerdat   AND
              a~augdt GT ld_gerdat AND
              a~umskz EQ space    AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur IN s_gsber  AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr  AND
              b~kdgrp IN p_kdgrp  AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        APPENDING  CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                    b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs  AND
              a~kunnr IN s_kunnr  AND
              budat LE p_gerdat   AND
              a~umskz IN s_bschl  AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur IN s_gsber  AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr  AND
              b~kdgrp IN p_kdgrp  AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        APPENDING  CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs  AND
              a~kunnr IN s_kunnr  AND
              budat LE p_gerdat   AND
              a~augdt GT ld_gerdat AND
              a~umskz IN s_bschl  AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur IN s_gsber  AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr  AND
              b~kdgrp IN p_kdgrp  AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.
    ELSE.
      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        INTO CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs AND
              a~kunnr IN s_kunnr AND
              budat LE p_gerdat  AND
              a~umskz EQ space   AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              p~vkbur IN s_gsber AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr AND
              b~kdgrp IN p_kdgrp AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        APPENDING  CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs  AND
              a~kunnr IN s_kunnr  AND
              budat LE p_gerdat   AND
              a~augdt GT ld_gerdat AND
              a~umskz EQ space    AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              p~vkbur IN s_gsber  AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr  AND
              b~kdgrp IN p_kdgrp  AND
              b~kvgr3 IN p_kvgr3  AND
              a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        APPENDING  CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                    b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs  AND
              a~kunnr IN s_kunnr  AND
              budat LE p_gerdat   AND
              a~umskz IN s_bschl  AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur IN s_gsber  AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr  AND
              b~kdgrp IN p_kdgrp  AND
              b~kvgr3 IN p_kvgr3  AND
              a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        APPENDING  CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs  AND
              a~kunnr IN s_kunnr  AND
              budat LE p_gerdat   AND
              a~augdt GT ld_gerdat AND
              a~umskz IN s_bschl  AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              p~vkbur IN s_gsber  AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr  AND
              b~kdgrp IN p_kdgrp  AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.
    ENDIF.
  ENDIF.

  IF x_norm EQ 'X' AND x_shbv EQ space.
    IF x_opdr IS INITIAL.
      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        INTO CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs  AND
              a~kunnr IN s_kunnr  AND
              budat LE p_gerdat   AND
              a~umskz EQ space    AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur IN s_gsber  AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr  AND
              b~kdgrp IN p_kdgrp  AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        APPENDING  CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs  AND
              a~kunnr IN s_kunnr  AND
              budat LE p_gerdat   AND
              a~augdt GT ld_gerdat AND
              a~umskz EQ space    AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur IN s_gsber  AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr  AND
              b~kdgrp IN p_kdgrp  AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.
    ELSE.
      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        INTO CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs  AND
              a~kunnr IN s_kunnr  AND
              budat LE p_gerdat   AND
              a~umskz EQ space    AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              p~vkbur IN s_gsber  AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr  AND
              b~kdgrp IN p_kdgrp  AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        APPENDING  CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs  AND
              a~kunnr IN s_kunnr  AND
              budat LE p_gerdat   AND
              a~augdt GT ld_gerdat AND
              a~umskz EQ space    AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              p~vkbur IN s_gsber  AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr  AND
              b~kdgrp IN p_kdgrp  AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.
    ENDIF.
  ENDIF.

  IF x_norm EQ space AND x_shbv EQ 'X'.
    IF x_opdr IS INITIAL.
      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        INTO CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs  AND
              a~kunnr IN s_kunnr  AND
              budat LE p_gerdat   AND
              a~umskz IN s_bschl  AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur IN s_gsber  AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr  AND
              b~kdgrp IN p_kdgrp  AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        APPENDING  CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs  AND
              a~kunnr IN s_kunnr  AND
              budat LE p_gerdat   AND
              a~augdt GT ld_gerdat AND
              a~umskz IN s_bschl  AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur IN s_gsber  AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr  AND
              b~kdgrp IN p_kdgrp  AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.
    ELSE.
      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        INTO CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsid AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs  AND
              a~kunnr IN s_kunnr  AND
              budat LE p_gerdat   AND
              a~umskz IN s_bschl  AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              p~vkbur IN s_gsber  AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr  AND
              b~kdgrp IN p_kdgrp  AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 a~cpudt a~augdt b~kvgr3
             a~sgtxt d~name1 a~kidno a~anln1
        APPENDING  CORRESPONDING FIELDS OF TABLE it_bsid
        FROM bsad AS a JOIN vbrp AS p ON p~vbeln = a~vbeln AND
                                         p~posnr = '000010'
                       JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        WHERE a~bukrs EQ p_bukrs  AND
              a~kunnr IN s_kunnr  AND
              budat LE p_gerdat   AND
              a~augdt GT ld_gerdat AND
              a~umskz IN s_bschl  AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              p~vkbur IN s_gsber  AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr  AND
              b~kdgrp IN p_kdgrp  AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.
    ENDIF.
  ENDIF.

  SORT it_bsid BY kunnr vkbur gjahr belnr budat blart zuonr xref2 kdgrp
                  xref1 kvgr3.
  PERFORM f_get_da_fr_it_bsid.
ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data.
  DATA : l_kunnr      LIKE vbpa-kunnr,
         l_pernr      LIKE vbpa-pernr,
         l_selisih(3) TYPE n,
         l_mahdt      LIKE vbak-mahdt,
         l_audat      LIKE vbak-audat,
         l_str        TYPE i,
         l_count      TYPE i,
         l_tmp(6)     TYPE n,
         l_tmp1(10)   TYPE n.

  DATA: ld_char(12)  VALUE '0000000000',
        ld_char1(50),
        ld_len       TYPE i,
        ld_subrc     LIKE sy-subrc,
        ld_ztag1     LIKE t052-ztag1,
        lv_vbeln     TYPE vbeln_vl,
        lv_brcod(1),
        lv_seqtyp(1),
        lv_seqnr(6),
        lv_spyear    TYPE zspyear,
        lv_spmth     TYPE zspmth.

  DATA : lv_bbeln  LIKE zfbid_sfa-bbeln, "lv_bbeln   LIKE zfbid-bbeln,
         lv_nottf  LIKE zfbid-nottf,
         lv_tglttf LIKE zfbid-tglttf.

  PERFORM f_get_rv.

  PERFORM f_get_da.

  PERFORM f_get_zfbid USING    '' '' '' '' '' 'X'
                      CHANGING lv_bbeln lv_nottf lv_tglttf.

  SORT gt_hsales BY vbeln.
  SORT it_bsid BY kunnr zuonr.
*  SORT t_bsid_temp BY kunnr zuonr cpudt DESCENDING belnr DESCENDING.
  SORT t_bsid_temp BY kunnr zuonr gjahr DESCENDING
                                  cpudt DESCENDING
                                  belnr DESCENDING.
  LOOP AT it_bsid.
    READ TABLE i_tvkol WITH KEY vstel = it_bsid-vkbur.
    IF sy-subrc EQ 0.
      IF i_tvkol-mixlive IS INITIAL.
        IF i_tvkol-live EQ 'X'.
          PERFORM f_read_temp USING 'RV'
                              CHANGING ld_subrc.
        ELSE.
          PERFORM f_read_temp USING 'ZA'
                              CHANGING ld_subrc.
        ENDIF.
      ELSE.
        PERFORM f_read_temp USING 'ZA'
                            CHANGING ld_subrc.
        IF ld_subrc NE 0.
          PERFORM f_read_temp USING 'RV'
                              CHANGING ld_subrc.
          IF ld_subrc NE 0.
            READ TABLE t_bsid_temp WITH KEY kunnr = it_bsid-kunnr
                                            zuonr = it_bsid-zuonr
                                            bschl = '01'.
            IF sy-subrc EQ 0.
              ld_subrc = 0.
              PERFORM f_move_to_it_bsid.
              MODIFY it_bsid TRANSPORTING bschl shkzg dmbtr budat bldat belnr gjahr
                                          faktur zfbdt zbd1t xref1 xref2 umskz.
            ELSE.
              ld_subrc = 1.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      IF ld_subrc NE 0.
        READ TABLE t_bsid_temp WITH KEY kunnr = it_bsid-kunnr
                                        zuonr = it_bsid-zuonr.
        IF sy-subrc EQ 0.
          it_bsid-bschl    = t_bsid_temp-bschl.
          it_bsid-umskz    = t_bsid_temp-umskz.
          it_bsid-budat    = t_bsid_temp-budat.
          it_bsid-bldat    = t_bsid_temp-bldat.
          it_bsid-belnr    = t_bsid_temp-belnr.
          it_bsid-gjahr    = t_bsid_temp-gjahr.
          it_bsid-zbd1t    = t_bsid_temp-zbd1t.
          it_bsid-zfbdt    = t_bsid_temp-zfbdt.
          it_bsid-xref1    = t_bsid_temp-xref1.
          it_bsid-xref2    = t_bsid_temp-xref2.
          it_bsid-zterm    = t_bsid_temp-zterm.
          IF t_bsid_temp-shkzg EQ 'H'.
            it_bsid-faktur   = t_bsid_temp-dmbtr * -1.
          ELSE.
            it_bsid-faktur   = t_bsid_temp-dmbtr.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR: ld_ztag1.
    IF it_bsid-bschl EQ '01' OR
      it_bsid-bschl EQ '12'.
      SELECT SINGLE ztag1
        INTO ld_ztag1
        FROM t052
        WHERE zterm = it_bsid-zterm.

*      IF it_bsid-zuonr(1) = 'C'.
*        it_bsid-duedt1  = it_bsid-budat + ld_ztag1.
*      ELSE.
      it_bsid-duedt1  = it_bsid-zfbdt + ld_ztag1.
*      ENDIF.
    ELSE.
      it_bsid-duedt1  = it_bsid-zfbdt.
    ENDIF.

    READ TABLE t_routelist WITH KEY kunnr = it_bsid-kunnr
                                    parvw = 'ZC'.
    IF sy-subrc EQ 0.
      CONCATENATE ld_char t_routelist-kunn2 INTO ld_char1.
      ld_len = strlen( ld_char1 ).
      ld_len = ld_len - 10.
      it_bsid-xref1  = ld_char1+ld_len(10).
      READ TABLE t_salesman WITH KEY kunnr = t_routelist-kunn2
                                     parvw = 'ZP'.
      IF sy-subrc EQ 0.
        CONCATENATE ld_char t_salesman-pernr INTO ld_char1.
        ld_len = strlen( ld_char1 ).
        ld_len = ld_len - 6.
        it_bsid-xref2  = ld_char1+ld_len(6).
        it_bsid-slcode = it_bsid-xref2.
      ELSE.
        CLEAR: it_bsid-xref2, it_bsid-slcode.
      ENDIF.
    ELSE.
      CLEAR: it_bsid-xref1.
    ENDIF.

*    IF p_bukrs EQ '8070'.
*    READ TABLE gt_zplbc WITH KEY bukrs = it_bsid-bukrs
*                                 werks = it_bsid-vkbur.
    READ TABLE i_tvkol WITH KEY vstel = it_bsid-vkbur.
    IF sy-subrc EQ 0.
      IF i_tvkol-live IS INITIAL.
        CASE p_bukrs.
          WHEN '8020'.
            READ TABLE gt_hsales WITH KEY vbeln = it_bsid-zuonr
                                          vkbur = it_bsid-vkbur BINARY SEARCH.
*                                          gjahr = it_bsid-gjahr BINARY SEARCH.
            IF sy-subrc EQ 0.
              it_bsid-divcod  = gt_hsales-divcod.
            ENDIF.

          WHEN '8070'.
            IF it_bsid-zuonr(1) EQ 'S'.
              CLEAR: lv_brcod, lv_seqtyp, lv_seqnr, lv_spyear, lv_spmth.
              lv_brcod  = it_bsid-zuonr+1(1).
              lv_seqtyp = it_bsid-zuonr+2(1).
              lv_seqnr  = it_bsid-zuonr+3(6).
              lv_spyear = it_bsid-gjahr.
              lv_spmth  = it_bsid-monat.
              IF it_bsid-monat IS INITIAL.
                READ TABLE gt_zssutdt003 WITH KEY brcod   = lv_brcod
                                                  seqtyp  = lv_seqtyp
                                                  seqnr   = lv_seqnr
                                                  spyear  = lv_spyear.
              ELSE.
                READ TABLE gt_zssutdt003 WITH KEY brcod   = lv_brcod
                                                  seqtyp  = lv_seqtyp
                                                  seqnr   = lv_seqnr
                                                  spmth   = lv_spmth
                                                  spyear  = lv_spyear.
              ENDIF.
              IF sy-subrc EQ 0.
                it_bsid-divcod  = gt_zssutdt003-divcod.
              ENDIF.
            ENDIF.
        ENDCASE.
      ELSE.
        lv_vbeln  = it_bsid-zuonr(10).
        CASE p_bukrs.
          WHEN '8020'.
            READ TABLE gt_lips WITH KEY vbeln = lv_vbeln.
            IF sy-subrc EQ 0.
              READ TABLE gt_vbak WITH KEY vbeln = gt_lips-vgbel.
              IF sy-subrc EQ 0.
                it_bsid-divcod = gt_vbak-auart.
              ENDIF.
            ENDIF.
          WHEN '8070'.
            READ TABLE gt_likp WITH KEY vbeln = lv_vbeln.
            IF sy-subrc EQ 0.
              it_bsid-divcod = gt_likp-fkarv+3(1).
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDIF.
*    ENDIF.

    MODIFY it_bsid.

    IF p_bukrs EQ '8020'.
      IF it_bsid-vkbur EQ space.
        it_bsid-vkbur = '0200'.
        MODIFY it_bsid.
      ENDIF.
    ENDIF.

    IF NOT p_route IS INITIAL.
      IF NOT it_bsid-xref1 IN p_route.
        DELETE it_bsid.
        CONTINUE.
      ELSE.
        IF NOT p_slcode IS INITIAL.
          IF NOT it_bsid-slcode  IN p_slcode.
            DELETE it_bsid.
            CONTINUE.
          ELSE.
            PERFORM gui_progress.
            PERFORM append.
          ENDIF.
        ELSE.
          PERFORM gui_progress.
          PERFORM append.
        ENDIF.
      ENDIF.
    ENDIF.

    IF NOT p_slcode IS INITIAL.
      IF NOT it_bsid-slcode IN p_slcode.
        DELETE it_bsid.
        CONTINUE.
      ELSE.
        PERFORM gui_progress.
        PERFORM append.
      ENDIF.
    ENDIF.

    IF p_route IS INITIAL AND p_slcode IS INITIAL.
      PERFORM append.
      PERFORM gui_progress.
    ENDIF.
  ENDLOOP.

  PERFORM delete_adj.
  DESCRIBE TABLE it_bsid LINES n_lines.
  IF n_lines GT 0.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = TEXT-012.
  ENDIF.
ENDFORM.                    " PROCESS_DATA
*&---------------------------------------------------------------------*
*&      Form  APPEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append.

  MOVE it_bsid-kunnr TO it_brcust-kunnr.
  MOVE it_bsid-zuonr TO it_brcust-zuonr.
  APPEND it_brcust.

  MOVE it_bsid-vkbur TO it_gsber-gsber.
  APPEND it_gsber.
  MOVE it_bsid-kdgrp TO it_brcustgr-kdgrp.
  APPEND it_brcustgr.

  MOVE it_bsid-xref2 TO it_brsales-xref2.
  APPEND it_brsales.

  MOVE it_bsid-xref1 TO it_brroute-xref1.
  APPEND it_brroute.

ENDFORM.                    " APPEND
*&---------------------------------------------------------------------*
*&      Form  DELETE_ADJ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_adj.
  SORT it_brcust BY kunnr zuonr.
  DELETE ADJACENT DUPLICATES FROM it_brcust.

ENDFORM.                    " DELETE_ADJ
*&---------------------------------------------------------------------*
*&      Form  PROCESS_SUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_sum.
  DATA: ld_flag(1).
  PERFORM get_giro.
*  clear: ld_flag.
*  IF ld_flag EQ 'X'.
*    PERFORM sum_brcust_old.
*  ELSE.

  PERFORM sum_brcust.
*  ENDIF.
ENDFORM.                    " PROCESS_SUM
*&---------------------------------------------------------------------*
*&      Form  WRITE_BRCUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_brcust.
  DATA : l_live  LIKE zplbc-live,
         l_limit TYPE p,
         v_limit LIKE knkk-klimk,
         l_ztag1 LIKE t052-ztag1.

*  PERFORM f_modify_itab_sfa.

  CLEAR : v_bill,v_giro,v_ending,no,w16,no1.
  FORMAT COLOR 1.
  LOOP AT itab.
    AT NEW gsber.
      s_gsber-low = itab-gsber.
      NEW-PAGE.
    ENDAT.

    IF  itab-giro EQ 0 AND itab-ending EQ 0.
    ELSE.
      IF no1 = 0.
        SKIP 1.
      ENDIF.
      ON CHANGE OF itab-kunnr.
        no = no + 1.c1 = 0.
        FORMAT COLOR COL_NORMAL INTENSIFIED ON.
        FORMAT COLOR COL_GROUP.

        SELECT SINGLE klimk INTO v_limit FROM knkk
        WHERE kunnr EQ itab-kunnr1.

        l_limit = v_limit * 100.
        IF l_limit >= 99999999999999.
          v_limit = 0.
        ENDIF.

        IF itab-zuonr(1) EQ 'C'.
          READ TABLE t_zterm WITH KEY sortl = itab-kunnr.
          IF sy-subrc EQ 0.
            SELECT SINGLE ztag1
              INTO l_ztag1
              FROM t052
              WHERE zterm = t_zterm-zterm.
            SHIFT l_ztag1 LEFT DELETING LEADING '0'.
          ELSE.
            CLEAR: l_ztag1.
          ENDIF.
        ELSE.
          READ TABLE t_zterm WITH KEY kunnr = itab-kunnr.
          IF sy-subrc EQ 0.
            SELECT SINGLE ztag1
              INTO l_ztag1
              FROM t052
              WHERE zterm = t_zterm-zterm.
            SHIFT l_ztag1 LEFT DELETING LEADING '0'.
          ELSE.
            CLEAR: l_ztag1.
          ENDIF.
        ENDIF.

        WRITE AT /c1(6) no LEFT-JUSTIFIED. c1 = 7.  "C1 = C1 + 7.
        WRITE AT c1(10) itab-kunnr.c1 = c1 + 10.
        WRITE AT c1(40) itab-name1.c1 = c1 + 41.
*        WRITE AT 80(6) 'TOP : '.
        WRITE AT 84(6) 'TOP : '.
*        WRITE AT 87(4) itab-zterm+2(2) LEFT-JUSTIFIED.
*        WRITE AT 87(4) l_ztag1 LEFT-JUSTIFIED.
        WRITE AT 91(4) l_ztag1 LEFT-JUSTIFIED.
        IF radio1 EQ 'X'.
          WRITE AT 125(10) 'PLAFOND : '.
          WRITE AT 136(33) v_limit CURRENCY 'IDR'.
        ELSE.
          WRITE AT 180(10) 'PLAFOND : '.
          WRITE AT 191(33) v_limit CURRENCY 'IDR'.
        ENDIF.
        WRITE (69) space.
      ENDON.
    ENDIF.

    PERFORM f_da_modify USING    itab-kunnr itab-zuonr
                        CHANGING itab-zfbdt itab-duedt1.

    PERFORM f_due_date_modify USING itab-kunnr itab-zuonr
                              CHANGING itab-duedt1.

    PERFORM f_nilai_faktur USING itab-kunnr itab-zuonr
                           CHANGING itab-faktur.

    PERFORM f_text_modify USING itab-kunnr itab-zuonr itab-zfbdt
                          CHANGING itab-sgtxt itab-faktur itab-top.

    v_bill = v_bill + itab-ending.
    v_giro = v_giro + itab-giro.
    v_ending = v_ending + itab-ending.
    v_subbill = v_subbill + itab-ending.
    v_subgiro = v_subgiro + itab-giro.
    v_subending = v_subending + itab-faktur.

    IF  itab-giro EQ 0 AND itab-ending EQ 0.
    ELSE.
      PERFORM zebra.
      PERFORM write_detail_brcust.
    ENDIF.

    AT END OF kunnr.
      IF  v_subgiro EQ 0 AND v_subbill EQ 0.
      ELSE.
        SKIP 1.
        PERFORM subtotal.
        SKIP 2.
        no1 = no1 + 4.
      ENDIF.
      CLEAR : v_subbill,v_subgiro,v_subending,v_subsaldo.

    ENDAT.
    no1 = no1 + 1.
  ENDLOOP.
  PERFORM grand_total.
ENDFORM.                    " WRITE_BRCUST

*&---------------------------------------------------------------------*
*&      Form  WRITE_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_header.
  DATA : due1(14),
         due2(14),
         due3(14),
         due4(14),
         due5(14),
         n1       TYPE i,
         n2       TYPE i,
         text(50),
         l_butxt  LIKE t001-butxt.
  c1 = 0.
  n1 = 178.
  n2 = 168.
  SELECT SINGLE butxt INTO l_butxt FROM t001 WHERE bukrs EQ p_bukrs.
  WRITE :/ l_butxt.
  IF radio1 EQ 'X'.
    WRITE AT 50(n1) 'DAFTAR FAKTUR TERBUKA'.
  ELSE.
    WRITE AT 105(n1) 'DAFTAR FAKTUR TERBUKA'.
  ENDIF.
  WRITE (10) space.
  IF  s_gsber-low NE space.
    IF radio1 EQ 'X'.
      WRITE AT /50(10) 'CABANG : '.
      SELECT SINGLE bezei INTO cab FROM tvkbt
      WHERE spras EQ 'E' AND vkbur EQ s_gsber-low.
      WRITE AT 60(n2) cab.
    ELSE.
      WRITE AT /105(10) 'CABANG : '.
      SELECT SINGLE bezei INTO cab FROM tvkbt
      WHERE spras EQ 'E' AND vkbur EQ s_gsber-low.
      WRITE AT 115(n2) cab.
    ENDIF.
  ENDIF.
  WRITE (10) space.
  PERFORM bulan.
*WRITE AT /50(10) 'BULAN  :'.
  WRITE :/'UserID :', sy-uname, '/', sy-tcode.
  IF radio1 EQ 'X'.
    WRITE AT 50(10) 'BULAN  :'.
    WRITE AT 60(n2) bulan.
  ELSE.
    WRITE AT 105(10) 'BULAN  :'.
    WRITE AT 115(n2) bulan.
  ENDIF.
  WRITE (10) space.
  WRITE :/ 'CETAK  : '.
  WRITE AT 10(10) sy-datum.
  WRITE AT 21(10) sy-uzeit.
  IF p_kdgrp EQ space AND p_route EQ space AND p_slcode EQ space.
    WRITE AT 34(10) 'All'.
  ENDIF.

  IF radio1 EQ 'X'.
    WRITE AT 50(10) 'PROSES :'.
    WRITE AT 60(n2) p_gerdat.
  ELSE.
    WRITE AT 105(10) 'PROSES :'.
    WRITE AT 115(n2) p_gerdat.
  ENDIF.

  IF p_kdgrp NE space AND p_route NE space AND p_slcode NE space.
    WRITE AT 74(50) 'SALES,ROUTE LIST,CUST GROUP'.
  ENDIF.
  IF p_kdgrp NE space AND p_route NE space AND p_slcode EQ space.
    WRITE AT 74(50) 'SALES,ROUTE LIST'.
  ENDIF.
  IF p_kdgrp EQ space AND p_route EQ space AND p_slcode NE space.
    CONCATENATE 'SALES' p_slcode-low '-' p_slcode-high INTO text
      SEPARATED BY space.
    WRITE AT 74(50) text.
  ENDIF.
  IF p_kdgrp EQ space AND p_route NE space AND p_slcode NE space.
    WRITE AT 74(50) 'ROUTE LIST,CUST GROUP'.
  ENDIF.
  IF p_kdgrp NE space AND p_route EQ space AND p_slcode NE space.
    WRITE AT 74(50) 'SALES,CUST GROUP'.
  ENDIF.
  IF p_kdgrp EQ space AND p_route NE space AND p_slcode EQ space.
    CONCATENATE 'ROUTE LIST' p_route-low '-' p_route-high INTO text
      SEPARATED BY space.
    WRITE AT 74(50) text.
  ENDIF.
  IF p_kdgrp NE space AND p_route EQ space AND p_slcode EQ space.
    CONCATENATE 'CUST GROUP' p_kdgrp INTO text SEPARATED BY space.
    WRITE AT 74(50) text.
  ENDIF.

  IF radio1 EQ 'X'.
    WRITE AT 133(8) 'Page : '.
    WRITE AT 151(4) sy-pagno.
  ELSE.
    WRITE AT 182(8) 'Page : '.
    WRITE AT 190(4) sy-pagno.
  ENDIF.
  WRITE (25) space.

  SKIP 1.
  FORMAT COLOR OFF.
  WRITE : / 'DUE DATE'.
  WRITE AT 15(2) '@AG@' AS ICON.
  WRITE AT 18(10) 'Overdue'.
  WRITE AT 30(2) '@1V@' AS ICON.
  WRITE AT 34(10) 'Due'.
  WRITE AT 46(2) '@FR@' AS ICON.
  WRITE AT 50(10) 'Not due'.
  SKIP 1.
  FORMAT COLOR 1.
  WRITE AT /c1(6) 'NO.'.c1 = c1 + 7.
*  WRITE AT c1(w3) 'DO NUMBER' .c1 = c1 + w3 + 1.
  WRITE AT c1(w18) 'DO NUMBER' .c1 = c1 + w18 + 1.
  WRITE AT c1(w15) 'SL CODE'.c1 = c1 + w15 + 1.
  WRITE AT c1(w4) 'POST DATE' .c1 = c1 + w4 + 1.
  WRITE AT c1(w4) 'DN DATE' .c1 = c1 + w4 + 1.
  WRITE AT c1(w1) 'DUE DATE'.c1 = c1 + w1 + 1.
  WRITE AT c1(1)  'S'.c1 = c1 + 2.
  WRITE AT c1(w10) 'DD' .c1 = c1 + w10 + 1.
  WRITE AT c1(w5) 'BI NO' .c1 = c1 + w5 + 1.
  WRITE AT c1(w6) 'DUE GIRO'.c1 = c1 + w6 + 1.
  WRITE AT c1(w7) 'JUMLAH GIRO' RIGHT-JUSTIFIED.c1 = c1 + w7 + 1.
  WRITE AT c1(w8) 'SALDO FAKTUR' RIGHT-JUSTIFIED.c1 = c1 + w8 + 1.
  WRITE AT c1(w8) 'SALDO AR' RIGHT-JUSTIFIED.c1 = c1 + w8 + 1.
  WRITE AT c1(w9) 'NILAI FAKTUR' RIGHT-JUSTIFIED.c1 = c1 + w9 + 1.
  WRITE AT c1(w14) 'TOP'.c1 = c1 + w14 + 5.
*  IF p_bukrs EQ '8070'.
  WRITE AT c1(w14) 'OrdTyp'.c1 = c1 + w14 + 5.
*  ENDIF.

  IF radio1 EQ 'X'.
  ELSE.
    WRITE AT c1(w50) 'TEXT'. c1 = c1 + w50 + 1.
    WRITE AT c1(w2) 'No. TTF'. c1 = c1 + w2 + 1.
    WRITE AT c1(w4) 'Tgl. TTF'. c1 = c1 + w4 + 1.
    WRITE AT c1(w22) 'Tgl. TTF tdk terdaftar'. c1 = c1 + w22 + 3.
    IF x_rtv IS NOT INITIAL.
      WRITE AT c1(w50) 'No.RTV - AR Potongan'. c1 = c1 + w50 + 1.
    ENDIF.
  ENDIF.
*SKIP 1.

  IF p_05t IS INITIAL.
*    WRITE AT c1(w50) ' '. c1 = c1 + w50 + 1.
  ELSE.
    WRITE AT c1(w8) 'DN principal'. c1 = c1 + w8 + 1.
  ENDIF.

ENDFORM.                    " WRITE_HEADER
*&---------------------------------------------------------------------*
*&      Form  INIT_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_print.
  w1   =  10.      w11 = 14.
  w2   =  26.      w12 = 14.
  w3   =  14.      w13 = 14.
  w4   =  10.      w14 = 6.
  w5   =  10.      w15 = 8.
  w6   =  14.      w50 = 50.
  w7   =  16.      w18 = 18.
  w8   =  16.      w22 = 22.
  w9   =  16.
  w10  =  2.
  c1 = 0.
ENDFORM.                    " INIT_PRINT

*&---------------------------------------------------------------------*
*&      Form  SUBTOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM subtotal.
  DATA text(40).
  c1 = 7.
*  c3 = w3 + w4 + w5 + w1 + w6 .
  c3 = w18 + w4 + w5 + w1 + w6 .
  FORMAT COLOR COL_NORMAL INTENSIFIED ON.
*FORMAT COLOR COL_TOTAL.
  CONCATENATE 'TOTAL' ' ' INTO text SEPARATED BY space.
  IF no1 = 0.
    SKIP 1.
    no1 = 1.
  ENDIF.
*WRITE AT /C1(C3) TEXT.C1 = C1 + C3 + 9 + W10 + W15.
  WRITE AT /7(c3) text.c1 = 7 + c3 + 20 + w10 + w15.
  WRITE AT c1(w7) v_subgiro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
  WRITE AT c1(w8) v_subbill CURRENCY 'IDR'.c1 = c1 + w8 + 1.
  WRITE AT c1(w8) v_subsaldo CURRENCY 'IDR'.c1 = c1 + w8 + 1.
  IF radio1 EQ 'X'.
    c3 = w9 + w14 + 12 + 55.
  ELSE.
    c3 = w9 + w14 + w50 + w2 + w4 + 19.
  ENDIF.
  WRITE AT c1(c3) space.
ENDFORM.                    " SUBTOTAL
*&---------------------------------------------------------------------*
*&      Form  WRITE_GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_gsber.
  no = 0.
  FORMAT COLOR 1.
*PERFORM WRITE_HEADER.
  CLEAR : v_bill,v_giro,v_ending,no,w16.

  SORT itab1 BY gsber.
  LOOP AT itab1.
    PERFORM zebra.
    plant = itab1-gsber.
    no = no + 1.
    PERFORM write_detail_gsber.
    v_bill = v_bill + itab1-bill.
    v_giro = v_giro + itab1-giro.
    v_ending = v_ending + itab1-ending.

  ENDLOOP.
  SKIP 2.
  PERFORM grand_total.
ENDFORM.                    " WRITE_GSBER
*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL_BRCUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail_brcust.
  DATA: saldo  LIKE itab-ending.

  c1 = 7.CLEAR name1.
*  WRITE AT /7(w3) itab-zuonr HOTSPOT.c1 = 7 + w3 + 1. "HIDE ITAB-KUNNR.
  WRITE AT /7(w18) itab-zuonr HOTSPOT.
  c1 = 7 + w18 + 1. HIDE itab-kunnr.
  WRITE AT c1(w15) itab-slcod.c1 = c1 + w15 + 1.
  WRITE AT c1(w4) itab-budat HOTSPOT.c1 = c1 + w4 + 1.
*  WRITE AT c1(w4) itab-bldat.c1 = c1 + w4 + 1.
  WRITE AT c1(w4) itab-zfbdt.c1 = c1 + w4 + 1.
*  WRITE AT c1(w1) itab-zfbdt.c1 = c1 + w4 + 1.
  WRITE AT c1(w1) itab-duedt1.c1 = c1 + w4 + 1.
  WRITE AT c1(1) ' '.c1 = c1 + 2.

  IF itab-duedt1 > p_gerdat.
    itab-due = '2'.
  ELSEIF itab-duedt1 EQ p_gerdat.
    itab-due = '1'.
  ELSEIF itab-duedt1 < p_gerdat.
    itab-due = '3'.
  ENDIF.

  IF itab-due EQ '1'.
    WRITE AT c1(w10) '@1V@' AS ICON.c1 = c1 + w10 + 1.
  ELSEIF itab-due EQ '3'.
    WRITE AT c1(w10) '@AG@' AS ICON.c1 = c1 + w10 + 1.
  ELSE.
    WRITE AT c1(w10) '@FR@' AS ICON.c1 = c1 + w10 + 1.
  ENDIF.

  saldo = itab-giro + itab-ending.
  v_subsaldo = v_subsaldo + saldo.
  v_saldo = v_saldo + saldo.

  WRITE AT c1(w5) itab-bbeln.c1 = c1 + w5 + 1.
  WRITE AT c1(w6) itab-duedt.c1 = c1 + w6 + 1.
  WRITE AT c1(w7) itab-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
  WRITE AT c1(w8) itab-ending CURRENCY 'IDR'.c1 = c1 + w8 + 1.
  WRITE AT c1(w8) saldo CURRENCY 'IDR'.c1 = c1 + w8 + 1.
  WRITE AT c1(w9)  itab-faktur CURRENCY 'IDR'.c1 = c1 + w9 + 1.
  WRITE AT c1(w14) itab-top.c1 = c1 + w14 + 5.
*  IF p_bukrs EQ '8070'.
  WRITE AT c1(w14) itab-divcod.c1 = c1 + w14 + 5.
*  ENDIF.

  IF radio1 EQ 'X'.
  ELSE.
    WRITE AT c1(w50) itab-sgtxt. c1 = c1 + w50 + 1.
    WRITE AT c1(w2) itab-nottf. c1 = c1 + w2 + 1.
*    WRITE AT c1(w4) itab-tglttf. c1 = c1 + w4 + 1.
*    WRITE AT c1(w4) itab-tglttf2. c1 = c1 + w4 + 1.
    WRITE AT c1(w4) itab-tglttfc. c1 = c1 + w4 + 1.
    WRITE AT c1(w22) itab-tglttf2c. c1 = c1 + w22 + 3.
    IF x_rtv IS NOT INITIAL.
      WRITE AT c1(w50) itab-bstnk. c1 = c1 + w50 + 1.
    ENDIF.
  ENDIF.

  IF p_05t = 'X'.
    WRITE AT c1(w8) itab-anln1. c1 = c1 + w8 + 1.
  ENDIF.

ENDFORM.                    " WRITE_DETAIL_BRCUST
*&---------------------------------------------------------------------*
*&      Form  WRITE_DETAIL_GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_detail_gsber.
  DATA cab LIKE tgsbt-gtext.
  SELECT SINGLE gtext INTO cab FROM tgsbt
  WHERE spras EQ 'E' AND gsber EQ plant.
  c1 = 0.
  WRITE AT /(w2) cab.c1 = c1 + w2 + 1.
  WRITE AT c1(w7) itab1-giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
  WRITE AT c1(w8) itab1-bill CURRENCY 'IDR'.c1 = c1 + w8 + 1.
  WRITE AT c1(w9)  itab1-ending CURRENCY 'IDR'.
ENDFORM.                    " WRITE_DETAIL_GSBER

*&---------------------------------------------------------------------*
*&      Form  SUM_BRCUST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sum_brcust.
  DATA : l_duedt  LIKE zfbicheck-duedt,
*         l_bbeln LIKE zfbicheck-bbeln,
         l_bbeln  LIKE zfbic_sfa-bbeln,
         l_belnr  LIKE bsid-belnr,
         l_due    LIKE bsid-budat,
         l_gjahr  LIKE bsid-gjahr,
         l_amount LIKE bsid-dmbtr,
         l_live   LIKE zplbc-live,
         l_nottf  LIKE zfbid-nottf,
         l_tglttf LIKE zfbid-tglttf.

  DATA : lt_bsid     LIKE it_bsid OCCURS 0 WITH HEADER LINE,
         lt_zfkwiout TYPE TABLE OF zfkwiout WITH HEADER LINE.

  IF it_bsid[] IS NOT INITIAL.
    lt_bsid[] = it_bsid[].
    SORT lt_bsid BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_bsid COMPARING kunnr.
    SELECT * INTO TABLE lt_zfkwiout
      FROM zfkwiout FOR ALL ENTRIES IN lt_bsid
      WHERE bukrs = lt_bsid-bukrs
        AND vkbur = lt_bsid-vkbur
        AND kunnr = lt_bsid-kunnr.
  ENDIF.

  SORT it_bsid BY zuonr.
  SORT t_bsid_temp BY zuonr budat DESCENDING.
  SORT t_bsid_open BY zuonr budat DESCENDING belnr DESCENDING .
  LOOP AT it_bsid.
    MOVE it_bsid-kunnr TO itab-kunnr.
    MOVE it_bsid-zuonr TO itab-zuonr.
    MOVE it_bsid-vbeln TO itab-vbeln.

    IF x_rtv IS NOT INITIAL.
      PERFORM f_arpot USING itab-zuonr
                      CHANGING itab-bstnk.
    ENDIF.

    IF it_bsid-shkzg EQ 'H'.
      it_bsid-dmbtr = it_bsid-dmbtr * -1.
      IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
        it_bsid-zbd1t = 0.
      ENDIF.
    ENDIF.
    itab-bill = itab-bill + it_bsid-dmbtr.

    IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA'.
      itab-budat = it_bsid-budat.
      itab-bldat = it_bsid-bldat.
      IF it_bsid-duedt1 > p_gerdat.
        itab-due = '2'.
      ELSEIF it_bsid-duedt1 EQ p_gerdat.
        itab-due = '1'.
      ELSEIF it_bsid-duedt1 < p_gerdat.
        itab-due = '3'.
      ENDIF.

      READ TABLE t_bsid_open WITH KEY zuonr = it_bsid-zuonr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        itab-sgtxt  = t_bsid_open-sgtxt.
      ENDIF.

      READ TABLE t_bsid_open WITH KEY zuonr = it_bsid-zuonr
                                      blart = 'RV'
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        itab-anln1  = t_bsid_open-anln1.
      ENDIF.
*DEVK951695
      itab-top = p_gerdat - it_bsid-zfbdt.

*      READ TABLE t_bsid_temp WITH KEY zuonr = it_bsid-zuonr
*                                      umskz = 'T'.
*      IF sy-subrc NE 0.
*        READ TABLE t_bsid_temp WITH KEY zuonr = it_bsid-zuonr
*                                        umskz = 'U'.
*        IF sy-subrc NE 0.
*          READ TABLE t_bsid_temp WITH KEY zuonr = it_bsid-zuonr
*                                          umskz = 'V'.
**          IF sy-subrc NE 0.
**            itab-top = p_gerdat - it_bsid-zfbdt.
**          ELSE.
**            IF t_bsid_temp-augdt IS INITIAL.
**              it_bsid-umskz  = t_bsid_temp-umskz.
**              CLEAR: itab-top.
**            ELSE.
*          itab-top = p_gerdat - it_bsid-zfbdt.
**            ENDIF.
**          ENDIF.
*        ELSE.
*          IF t_bsid_temp-augdt IS INITIAL.
*            it_bsid-umskz  = t_bsid_temp-umskz.
*            CLEAR: itab-top.
*          ELSE.
*            itab-top = p_gerdat - it_bsid-zfbdt.
*          ENDIF.
*        ENDIF.
*      ELSE.
*        IF t_bsid_temp-augdt IS INITIAL.
*          it_bsid-umskz  = t_bsid_temp-umskz.
*          CLEAR: itab-top.
*        ELSE.
*          itab-top = p_gerdat - it_bsid-zfbdt.
*        ENDIF.
*      ENDIF.
*DEVK951695
    ENDIF.

    MOVE it_bsid-slcode TO itab-slcod.
    MOVE it_bsid-vkbur TO itab-gsber.
    MOVE it_bsid-sortl TO itab-sortl.
    MOVE it_bsid-zterm TO itab-zterm.
    MOVE it_bsid-name1 TO itab-name1.

    IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA'.
      IF it_bsid-umskz IS NOT INITIAL AND it_bsid-umskz NE 'V'.
        itab-faktur = 0.
*        itab-top    = 0.  DEVK951695
      ELSE.
        itab-faktur = it_bsid-faktur.
      ENDIF.
      l_belnr     = it_bsid-belnr.
      l_gjahr     = it_bsid-gjahr.
    ENDIF.

    IF itab-top EQ 0.
      IF it_bsid-umskz IS NOT INITIAL.
        CLEAR: itab-top.
      ENDIF.
    ENDIF.

    LOOP AT i_giro WHERE kunnr EQ it_bsid-kunnr AND
                         zuonr EQ it_bsid-zuonr.
      itab-giro = itab-giro + i_giro-cchek.
      l_duedt = i_giro-duedt.
    ENDLOOP.

    LOOP AT i_giro_sfa WHERE kunnr EQ it_bsid-kunnr AND
                             zuonr EQ it_bsid-zuonr.
      itab-giro = itab-giro + i_giro_sfa-bank_amt.
      l_duedt = i_giro_sfa-bank_dudat.
    ENDLOOP.

    IF l_bbeln EQ space.
      PERFORM f_get_zfbid USING    it_bsid-bukrs itab-gsber l_gjahr
                                   it_bsid-kunnr it_bsid-zuonr ''
                          CHANGING l_bbeln l_nottf l_tglttf.

*      SELECT MAX( bbeln )
*        FROM zfbid
*        INTO l_bbeln
*        WHERE bukrs EQ it_bsid-bukrs AND
*              vkbur EQ itab-gsber AND
*              gjahr EQ l_gjahr AND
*              bflag IN lr_bflag AND
*              kunnr EQ it_bsid-kunnr AND
*              zuonr EQ it_bsid-zuonr.
    ENDIF.

    itab-duedt   = l_duedt.
    itab-bbeln   = l_bbeln.
    itab-nottf   = l_nottf.
    itab-tglttf  = l_tglttf.
    IF ( it_bsid-blart EQ 'DZ' OR it_bsid-blart EQ 'DA' ) AND
         itab-due EQ space.
      itab-budat = it_bsid-budat.
      itab-bldat = it_bsid-bldat.

      l_due = it_bsid-zfbdt + it_bsid-zbd1t.
      l_due = it_bsid-duedt1.
      IF l_due > p_gerdat.
        itab-due = '2'.
      ELSEIF l_due EQ p_gerdat.
        itab-due = '1'.
      ELSEIF l_due < p_gerdat.
        itab-due = '3'.
      ENDIF.
    ENDIF.

    itab-zfbdt   = it_bsid-zfbdt.
    itab-zbd1t   = it_bsid-zbd1t.
    itab-giro    = itab-giro .
    itab-bill    = itab-bill.
    itab-ending  = itab-bill - itab-giro.
    itab-duedt1  = it_bsid-duedt1.

    MOVE itab-kunnr TO itab-kunnr1.
    READ TABLE i_tvkol WITH KEY vstel = itab-gsber.
    IF sy-subrc EQ 0.
      IF i_tvkol-live IS INITIAL.
        MOVE itab-sortl TO itab-kunnr.
      ENDIF.
    ENDIF.

    itab-divcod = it_bsid-divcod.

    IF it_bsid-umskz = 'V'.
      itab-zfbdt = itab-duedt1 = itab-budat.
    ENDIF.

    CLEAR: itab-tglttfc,itab-tglttf2c.

    READ TABLE lt_zfkwiout WITH KEY bukrs = it_bsid-bukrs
                                    vkbur = it_bsid-vkbur
                                    kunnr = it_bsid-kunnr
                                    TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      IF itab-tglttf IS NOT INITIAL.
        WRITE itab-tglttf TO itab-tglttfc.
        CLEAR: itab-tglttf2.
      ENDIF.
    ELSE.
      IF itab-tglttf IS NOT INITIAL.
        itab-tglttf2 = itab-tglttf.
        WRITE itab-tglttf2 TO itab-tglttf2c.
        CLEAR: itab-tglttf.
      ENDIF.
    ENDIF.

    IF p_amount IS INITIAL.
      COLLECT itab.
    ELSE.
      l_amount = abs( itab-ending ) * 100.
      IF l_amount < p_amount.
        COLLECT itab.
      ENDIF.
    ENDIF.
    CLEAR: l_bbeln, l_duedt, itab-giro, itab-bill, itab-sgtxt.
  ENDLOOP.
ENDFORM.                    " SUM_BRCUST

*&---------------------------------------------------------------------*
*&      Form  GUI_PROGRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gui_progress.
  igui = sy-tabix MOD 100.
  IF igui = 0.
    WRITE sy-tabix TO gtext+0.
    CONDENSE gtext.
    WRITE TEXT-001 TO gtext+20.
    CONDENSE gtext.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = gtext.
  ENDIF.
ENDFORM.                    " GUI_PROGRESS

*&---------------------------------------------------------------------*
*&      Form  GRAND_TOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM grand_total.
  DATA text(40).
  FORMAT COLOR COL_NORMAL INTENSIFIED ON.
  c1 = 7.
*  c3 = w3 + w4 + w5 + w1 + w6.
  c3 = w18 + w4 + w5 + w1 + w6.
  CONCATENATE  'GRAND' 'TOTAL'  INTO text SEPARATED BY space.
  WRITE AT /7(c3) text.
  c1 = 7 + c3 + 20 + w10 + w15.
  WRITE AT c1(w7) v_giro CURRENCY 'IDR'.c1 = c1 + w7 + 1.
  WRITE AT c1(w8) v_bill CURRENCY 'IDR'.c1 = c1 + w8 + 1.
  WRITE AT c1(w8) v_saldo CURRENCY 'IDR'.c1 = c1 + w8 + 1.
  IF radio1 EQ 'X'.
    c3 = w9 + w14 + 12 + 55.
  ELSE.
    c3 = w9 + w14 + w50 + w2 + w4 + 19.
  ENDIF.
  WRITE AT c1(c3)  space.c1 = c1 + w9 + 1.
ENDFORM.                    " GRAND_TOTAL

*&---------------------------------------------------------------------*
*&      Form  ZEBRA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zebra.
  IF w16 = 1.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    w16 = 0.
  ELSE.
    FORMAT COLOR COL_NORMAL INTENSIFIED ON.
    w16 = 1.
  ENDIF.

ENDFORM.                    " ZEBRA
*&---------------------------------------------------------------------*
*&      Form  BULAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bulan.
  IF p_gerdat+4(2) EQ '01'.
    CONCATENATE 'JANUARI' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '02'.
    CONCATENATE 'FEBRUARI' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '03'.
    CONCATENATE 'MARET' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '04'.
    CONCATENATE 'APRIL' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '05'.
    CONCATENATE 'MEI' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '06'.
    CONCATENATE 'JUNI' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '07'.
    CONCATENATE 'JULI' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '08'.
    CONCATENATE 'AGUSTUS' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '09'.
    CONCATENATE 'SEPTEMBER' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '10'.
    CONCATENATE 'OKTOBER' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '11'.
    CONCATENATE 'NOVEMBER' p_gerdat(4) INTO bulan SEPARATED BY space.
  ELSEIF p_gerdat+4(2) EQ '12'.
    CONCATENATE 'DESEMBER' p_gerdat(4) INTO bulan SEPARATED BY space.
  ENDIF.
ENDFORM.                    " BULAN

*&---------------------------------------------------------------------*
*&      Form  CEK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek.
  DATA l_gsber LIKE bsid-gsber.

  l_gsber = s_gsber-low.

  IF l_gsber EQ space AND s_gsber-high EQ space.
    l_gsber = '*'.
  ELSEIF l_gsber NE space AND s_gsber-high NE space.
    l_gsber = '*'.
  ENDIF.

  AUTHORITY-CHECK OBJECT  'F_BKPF_GSB'
      ID 'GSBER' FIELD l_gsber
      ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH
    'You have no authorization for Sales Office' l_gsber.
  ENDIF.
ENDFORM.                    " CEK

*&---------------------------------------------------------------------*
*&      Form  SUBMIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM submit.
  SUBMIT aqzzzfi=========ar_branch_03==
  WITH dd_kunnr-low EQ itab-kunnr
  WITH dd_bukrs-low EQ p_bukrs
  WITH sp$00002-low EQ itab-zuonr
  AND RETURN.
ENDFORM.                    " SUBMIT

*&---------------------------------------------------------------------*
*&      Form  GET_GIRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_giro.
  SELECT *
    FROM zfbicheck
    INTO CORRESPONDING FIELDS OF TABLE i_giro
    WHERE bukrs EQ p_bukrs AND
          vkbur IN s_gsber AND
          pcair EQ space   AND
          kunnr IN s_kunnr.

  IF it_bsid[] IS NOT INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE i_giro_sfa
      FROM zfbic_sfa FOR ALL ENTRIES IN it_bsid
      WHERE bukrs EQ it_bsid-bukrs AND
            vkbur EQ it_bsid-vkbur AND
            zuonr EQ it_bsid-zuonr AND
            kunnr EQ it_bsid-kunnr AND
            pcair EQ space.
  ENDIF.

** tambahan untuk SUT
*  LOOP AT i_giro.
*    READ TABLE it_bsid WITH KEY vkbur = i_giro-vkbur
*                                kunnr = i_giro-kunnr
*                                zuonr = i_giro-zuonr.
*    IF sy-subrc EQ 0.
*      CONTINUE.
*    ELSE.
*      it_bsid-vkbur    = i_giro-vkbur.
*      it_bsid-kunnr    = i_giro-kunnr.
*      it_bsid-zuonr    = i_giro-zuonr.
*      APPEND it_bsid.
*    ENDIF.
*  ENDLOOP.

*  SELECT *
*    FROM zfbicheck
*    APPENDING CORRESPONDING FIELDS OF TABLE i_giro
*    WHERE bukrs EQ p_bukrs  AND
*          vkbur IN s_gsber  AND
*          pcair EQ 'C'      AND
*          erdt2 GT p_gerdat AND
*          kunnr IN s_kunnr.
ENDFORM.                    " GET_GIRO

*&---------------------------------------------------------------------*
*&      Form  f_mapping_soff
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_mapping_soff .
  IF s_kunnr IS NOT INITIAL.
    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_dele
      WHERE kunnr    IN s_kunnr AND
            zvkbur1  IN s_gsber AND
            budat    GE p_gerdat.

    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_add
      WHERE kunnr  IN s_kunnr AND
            budat  GE p_gerdat.
  ELSE.
    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_dele
      WHERE zvkbur1  IN s_gsber AND
            budat    GE p_gerdat.

    SELECT kunnr zvkbur budat zvkbur1
      FROM zfarsoff
      INTO CORRESPONDING FIELDS OF TABLE t_zfarsoff_add
      WHERE budat  GE p_gerdat.
  ENDIF.

  SELECT *
    FROM zfarsoff
    INTO CORRESPONDING FIELDS OF TABLE gt_zfarsoff
    WHERE zvkbur1 IN s_gsber.
ENDFORM.                    " f_mapping_soff

*&---------------------------------------------------------------------*
*&      Form  f_hapus_kunnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hapus_kunnr .
  IF t_zfarsoff_dele[] IS NOT INITIAL.
    SORT it_bsid BY kunnr.
    SORT t_zfarsoff_dele BY kunnr.
    LOOP AT it_bsid.
      READ TABLE t_zfarsoff_dele WITH KEY kunnr = it_bsid-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        DELETE it_bsid.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_hapus_kunnr

*&---------------------------------------------------------------------*
*&      Form  f_tambah_kunnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_tambah_kunnr .
  DATA: ld_gerdat LIKE sy-datum,
        ld_flag   TYPE i.

  IF t_zfarsoff_add[] IS NOT INITIAL.
    IF ld_flag IS INITIAL.
      CONCATENATE p_gerdat(6) '01' INTO ld_gerdat.
      ld_flag = 1.
    ELSE.
      CONCATENATE ld_gerdat(6) '01' INTO ld_gerdat.
    ENDIF.
    ld_gerdat = ld_gerdat - 1.
    CONCATENATE ld_gerdat(6) '01' INTO ld_gerdat.

    IF x_norm EQ 'X' AND x_shbv EQ 'X'.
      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 b~kvgr3
             a~sgtxt d~name1 a~cpudt a~augdt a~kidno a~anln1
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                    b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ p_bukrs AND
              a~kunnr EQ t_zfarsoff_add-kunnr AND
              budat LE p_gerdat AND
              a~umskz EQ space AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr AND
              b~kdgrp IN p_kdgrp AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 b~kvgr3
             a~sgtxt d~name1 a~cpudt a~augdt a~kidno a~anln1
      FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                       b~vkorg EQ p_bukrs
                     JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                       c~bukrs EQ a~bukrs
                     JOIN kna1 AS d ON a~kunnr EQ d~kunnr
      APPENDING  CORRESPONDING FIELDS OF TABLE t_bsid_add
      FOR ALL ENTRIES IN t_zfarsoff_add
      WHERE a~bukrs EQ p_bukrs AND
            a~kunnr EQ t_zfarsoff_add-kunnr AND
            budat LE p_gerdat AND
            a~augdt GT ld_gerdat AND
            a~umskz EQ space AND
            a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
            b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
            b~vtweg BETWEEN '10' AND '20'      AND
            c~pernr IN s_parnr AND
            b~kdgrp IN p_kdgrp AND
            b~kvgr3 IN p_kvgr3 AND
            a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 b~kvgr3
             a~sgtxt d~name1 a~cpudt a~augdt a~kidno a~anln1
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        APPENDING  CORRESPONDING FIELDS OF TABLE t_bsid_add
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ p_bukrs AND
              a~kunnr EQ t_zfarsoff_add-kunnr AND
              budat LE p_gerdat AND
              a~umskz IN s_bschl AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr AND
              b~kdgrp IN p_kdgrp AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart  a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 b~kvgr3
             a~sgtxt d~name1 a~cpudt a~augdt a~kidno a~anln1
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        APPENDING  CORRESPONDING FIELDS OF TABLE t_bsid_add
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ p_bukrs AND
              a~kunnr EQ t_zfarsoff_add-kunnr AND
              budat LE p_gerdat AND
              a~augdt GT ld_gerdat AND
              a~umskz IN s_bschl AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr AND
              b~kdgrp IN p_kdgrp AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.
    ENDIF.

    IF x_norm EQ 'X' AND x_shbv EQ space.
      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 b~kvgr3
             a~sgtxt d~name1 a~cpudt a~augdt a~kidno a~anln1
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ p_bukrs AND
              a~kunnr EQ t_zfarsoff_add-kunnr AND
              budat LE p_gerdat AND
              a~umskz EQ space AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr AND
              b~kdgrp IN p_kdgrp AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             d~sortl a~zterm a~bldat a~xref1 b~kvgr3
             a~sgtxt d~name1 a~cpudt a~augdt a~kidno a~anln1
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        APPENDING CORRESPONDING FIELDS OF TABLE t_bsid_add
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ p_bukrs AND
              a~kunnr EQ t_zfarsoff_add-kunnr AND
              budat LE p_gerdat AND
              a~augdt GT ld_gerdat AND
              a~umskz EQ space AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr AND
              b~kdgrp IN p_kdgrp AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.
    ENDIF.

    IF x_norm EQ space AND x_shbv EQ 'X'.
      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 b~kvgr3
             a~sgtxt d~name1 a~cpudt a~augdt a~kidno a~anln1
        FROM bsid AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        INTO CORRESPONDING FIELDS OF TABLE t_bsid_add
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ p_bukrs AND
              a~kunnr EQ t_zfarsoff_add-kunnr AND
              budat LE p_gerdat AND
              a~umskz IN s_bschl AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr AND
              b~kdgrp IN p_kdgrp AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.

      SELECT a~bukrs a~kunnr b~vkbur a~gjahr a~belnr a~budat a~monat a~bschl
             a~dmbtr a~shkzg a~zfbdt a~zbd1t a~blart  a~zuonr a~xref2 b~kdgrp
             a~umskz d~sortl a~zterm a~bldat a~xref1 b~kvgr3
             a~sgtxt d~name1 a~cpudt a~augdt a~kidno a~anln1
        FROM bsad AS a JOIN knvv AS b ON a~kunnr EQ b~kunnr AND
                                         b~vkorg EQ p_bukrs
                       JOIN knb1 AS c ON c~kunnr EQ a~kunnr AND
                                         c~bukrs EQ a~bukrs
                       JOIN kna1 AS d ON a~kunnr EQ d~kunnr
        APPENDING  CORRESPONDING FIELDS OF TABLE t_bsid_add
        FOR ALL ENTRIES IN t_zfarsoff_add
        WHERE a~bukrs EQ p_bukrs AND
              a~kunnr EQ t_zfarsoff_add-kunnr AND
              budat LE p_gerdat AND
              a~augdt GT p_gerdat AND
              a~umskz IN s_bschl AND
              a~blart IN ('RV','DR','ZA','DA','DZ','AB') AND
              b~vkbur EQ t_zfarsoff_add-zvkbur1 AND
              b~vtweg BETWEEN '10' AND '20'      AND
              c~pernr IN s_parnr AND
              b~kdgrp IN p_kdgrp AND
              b~kvgr3 IN p_kvgr3 AND
              a~zuonr IN s_do.
    ENDIF.

    SORT t_bsid_add BY kunnr vkbur gjahr belnr budat blart zuonr xref2 kdgrp
                       xref1 kvgr3.

    SORT t_bsid_add BY kunnr.
    SORT t_zfarsoff_add BY kunnr.
    LOOP AT t_bsid_add.
      READ TABLE t_zfarsoff_add WITH KEY kunnr = t_bsid_add-kunnr
      BINARY SEARCH.
      IF sy-subrc EQ 0.
        IF p_gerdat LT t_zfarsoff_add-budat.
          IF t_zfarsoff_add-zvkbur IN s_gsber.
            t_bsid_add-vkbur = t_zfarsoff_add-zvkbur.
            MODIFY t_bsid_add TRANSPORTING vkbur.
            it_bsid = t_bsid_add.
            APPEND it_bsid.
          ENDIF.
        ELSE.
          IF t_zfarsoff_add-zvkbur1 IN s_gsber.
            t_bsid_add-vkbur = t_zfarsoff_add-zvkbur.
            MODIFY t_bsid_add TRANSPORTING vkbur.
            it_bsid = t_bsid_add.
            APPEND it_bsid.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_tambah_kunnr

*&---------------------------------------------------------------------*
*&      Form  f_reclas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_reclas .
  DATA: BEGIN OF lt_kunnr OCCURS 0,
          kunnr LIKE bsid-kunnr.
  DATA: END OF lt_kunnr.
  DATA: l_length TYPE i.

  SELECT a~vstel a~werks a~lgort
         b~live b~mixlive
    FROM tvkol AS a JOIN zplbc AS b ON b~werks EQ a~werks AND
                                       b~lgort EQ a~lgort
    INTO TABLE i_tvkol
    WHERE a~vstel IN s_gsber.

  LOOP AT it_bsid.
    lt_kunnr-kunnr  = it_bsid-kunnr.
    APPEND lt_kunnr.

    IF it_bsid-zuonr IS NOT INITIAL.
      l_length = strlen( it_bsid-zuonr ).
      l_length = l_length - 1.
      IF it_bsid-zuonr+l_length(1) EQ 'R'.
        it_bsid-zuonr  = it_bsid-zuonr(l_length).
      ENDIF.
    ENDIF.

    t_bsid_temp    = it_bsid.
    APPEND t_bsid_temp.

    IF it_bsid-augdt IS INITIAL OR
      it_bsid-augdt GT p_gerdat.
      t_bsid_open    = it_bsid.
      APPEND t_bsid_open.
    ENDIF.

    MODIFY it_bsid TRANSPORTING zuonr.

    t_reclas-bukrs  = it_bsid-bukrs.
    t_reclas-kunnr  = it_bsid-kunnr.
    t_reclas-name1  = it_bsid-name1.
    t_reclas-vkbur  = it_bsid-vkbur.
    IF it_bsid-shkzg EQ 'H'.
      t_reclas-dmbtr  = it_bsid-dmbtr * -1.
    ELSE.
      t_reclas-dmbtr  = it_bsid-dmbtr.
    ENDIF.
    t_reclas-kdgrp  = it_bsid-kdgrp.
    t_reclas-sortl  = it_bsid-sortl.
    t_reclas-zuonr  = it_bsid-zuonr.
    t_reclas-vbeln  = it_bsid-vbeln.
    COLLECT t_reclas.
  ENDLOOP.

  REFRESH: it_bsid.
  CLEAR: it_bsid.
  it_bsid[]  = t_reclas[].

  SORT lt_kunnr BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_kunnr COMPARING kunnr.

  IF lt_kunnr[] IS NOT INITIAL.
    SELECT a~kunnr a~zterm
           b~sortl
      FROM knb1 AS a JOIN kna1 AS b ON a~kunnr EQ b~kunnr
      INTO CORRESPONDING FIELDS OF TABLE t_zterm
      FOR ALL ENTRIES IN lt_kunnr
      WHERE a~kunnr EQ lt_kunnr-kunnr AND
            a~bukrs EQ p_bukrs.

    SORT t_zterm BY kunnr zterm sortl.

    SELECT kunnr vkorg vtweg spart parvw parza kunn2 pernr
    FROM knvp
    INTO CORRESPONDING FIELDS OF TABLE t_routelist
    FOR ALL ENTRIES IN lt_kunnr
    WHERE kunnr EQ lt_kunnr-kunnr AND
          parvw EQ 'ZC'
      ORDER BY PRIMARY KEY.

*    SORT t_routelist BY kunnr vkorg vtweg spart parvw kunn2 pernr.

    IF t_routelist[] IS NOT INITIAL.
      SELECT kunnr vkorg vtweg spart parvw parza kunn2 pernr
      FROM knvp
      INTO CORRESPONDING FIELDS OF TABLE t_salesman
      FOR ALL ENTRIES IN t_routelist
      WHERE kunnr EQ t_routelist-kunn2 AND
            parvw EQ 'ZP'
        ORDER BY PRIMARY KEY.

*      SORT t_salesman BY kunnr vkorg vtweg spart parvw kunn2 pernr.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_reclas

*&---------------------------------------------------------------------*
*&      Form  f_read_temp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_7583   text
*----------------------------------------------------------------------*
FORM f_read_temp  USING    fu_blart
                  CHANGING fc_subrc.
  READ TABLE t_bsid_temp WITH KEY kunnr = it_bsid-kunnr
                                  zuonr = it_bsid-zuonr
                                  blart = fu_blart.
  IF sy-subrc EQ 0.
    fc_subrc = 0.
    PERFORM f_move_to_it_bsid.
  ELSE.
    fc_subrc = 1.
  ENDIF.

  MODIFY it_bsid TRANSPORTING bschl shkzg dmbtr budat bldat belnr gjahr
                              faktur zfbdt zbd1t xref1 xref2 umskz.
ENDFORM.                    " f_read_temp

*&---------------------------------------------------------------------*
*&      Form  sum_brcust_old
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM sum_brcust_old .
*  DATA : l_cchek LIKE zfbicheck-cchek,
*         l_duedt LIKE zfbicheck-duedt,
*         l_bbeln LIKE zfbicheck-bbeln,
*         l_belnr LIKE bsid-belnr,
*         l_due LIKE bsid-budat,
*         l_gjahr LIKE bsid-gjahr,
*         l_amount LIKE bsid-dmbtr,
*         l_live LIKE zplbc-live,
*         l_nottf    LIKE zfbid-nottf,
*         l_tglttf   LIKE zfbid-tglttf.
*
*  SORT it_brcust BY zuonr.
*  LOOP AT it_brcust.
*    CLEAR : itab, l_duedt, l_bbeln, l_nottf, l_tglttf.
*    MOVE it_brcust-kunnr TO itab-kunnr.
*    MOVE it_brcust-zuonr TO itab-zuonr.
*
*    SORT it_bsid BY zuonr.
*    SORT t_bsid_temp BY zuonr.
*    LOOP AT it_bsid WHERE kunnr EQ it_brcust-kunnr AND
*                          zuonr EQ it_brcust-zuonr.
*
*      IF it_bsid-shkzg EQ 'H'.
*        it_bsid-dmbtr = it_bsid-dmbtr * -1.
*        IF it_bsid-blart EQ 'RV' AND it_bsid-augdt EQ '00000000' AND it_bsid-kidno EQ space.
*          it_bsid-zbd1t = 0.
*        ENDIF.
*      ENDIF.
*      itab-bill = itab-bill + it_bsid-dmbtr.
*
*      IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA'.
*        itab-budat = it_bsid-budat.
*        itab-bldat = it_bsid-bldat.
*        IF it_bsid-duedt1 > p_gerdat.
*          itab-due = '2'.
*        ELSEIF it_bsid-duedt1 EQ p_gerdat.
*          itab-due = '1'.
*        ELSEIF it_bsid-duedt1 < p_gerdat.
*          itab-due = '3'.
*        ENDIF.
*
*        READ TABLE t_bsid_temp WITH KEY zuonr = it_bsid-zuonr
*                                        umskz = 'T'.
*        IF sy-subrc NE 0.
*          READ TABLE t_bsid_temp WITH KEY zuonr = it_bsid-zuonr
*                                          umskz = 'U'.
*          IF sy-subrc NE 0.
*            itab-top = p_gerdat - it_bsid-zfbdt.
*          ELSE.
*            IF t_bsid_temp-augdt IS INITIAL.
*              it_bsid-umskz  = t_bsid_temp-umskz.
*              CLEAR: itab-top.
*            ELSE.
*              itab-top = p_gerdat - it_bsid-zfbdt.
*            ENDIF.
*          ENDIF.
*        ELSE.
*          IF t_bsid_temp-augdt IS INITIAL.
*            it_bsid-umskz  = t_bsid_temp-umskz.
*            CLEAR: itab-top.
*          ELSE.
*            itab-top = p_gerdat - it_bsid-zfbdt.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*
*      MOVE it_bsid-slcode TO itab-slcod.
*      MOVE it_bsid-vkbur TO itab-gsber.
*      MOVE it_bsid-sortl TO itab-sortl.
*      MOVE it_bsid-zterm TO itab-zterm.
*      MOVE it_bsid-name1 TO itab-name1.
*
*      IF it_bsid-blart NE 'DZ' AND it_bsid-blart NE 'DA'.
*        IF it_bsid-umskz IS NOT INITIAL.
*          itab-faktur = 0.
*          itab-top    = 0.
*        ELSE.
*          itab-faktur = it_bsid-faktur.
*        ENDIF.
*        l_belnr     = it_bsid-belnr.
*        l_gjahr     = it_bsid-gjahr.
*      ENDIF.
*
**      MOVE it_bsid-sgtxt TO itab-sgtxt.
*
*      IF itab-top EQ 0.
*        IF it_bsid-umskz IS NOT INITIAL.
*          CLEAR: itab-top.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*
*    LOOP AT i_giro WHERE kunnr EQ it_brcust-kunnr AND
*                         zuonr EQ it_brcust-zuonr.
*      itab-giro = itab-giro + i_giro-cchek.
*      l_duedt = i_giro-duedt.
*    ENDLOOP.
*
*    IF l_bbeln EQ space.
*      PERFORM f_get_zfbid USING    it_bsid-bukrs itab-gsber l_gjahr
*                                   it_brcust-kunnr it_brcust-zuonr ''
*                          CHANGING l_bbeln l_nottf l_tglttf.
*
**      SELECT MAX( bbeln )
**        FROM zfbid
**        INTO l_bbeln
**        WHERE bukrs EQ it_bsid-bukrs AND
**              vkbur EQ itab-gsber AND
**              gjahr EQ l_gjahr AND
**              bflag IN lr_bflag AND
**              kunnr EQ it_brcust-kunnr
**              AND zuonr EQ it_brcust-zuonr.
*    ENDIF.
*    itab-duedt   = l_duedt.
*    itab-bbeln   = l_bbeln.
*    itab-nottf   = l_nottf.
*    itab-tglttf  = l_tglttf.
*
*    IF ( it_bsid-blart EQ 'DZ' OR it_bsid-blart EQ 'DA' ) AND
*         itab-due EQ space.
*      itab-budat = it_bsid-budat.
*      itab-bldat = it_bsid-bldat.
*
*      l_due = it_bsid-zfbdt + it_bsid-zbd1t.
*      l_due = it_bsid-duedt1.
*      IF l_due > p_gerdat.
*        itab-due = '2'.
*      ELSEIF l_due EQ p_gerdat.
*        itab-due = '1'.
*      ELSEIF l_due < p_gerdat.
*        itab-due = '3'.
*      ENDIF.
*    ENDIF.
*
*    itab-zfbdt   = it_bsid-zfbdt.
*    itab-zbd1t   = it_bsid-zbd1t.
*    itab-giro    = itab-giro .
*    itab-bill    = itab-bill.
*    itab-ending  = itab-bill - itab-giro.
*    itab-duedt1  = it_bsid-duedt1.
*
*    MOVE itab-kunnr TO itab-kunnr1.
*    SELECT SINGLE b~live
*      FROM tvkol AS a JOIN zplbc AS b ON a~werks = b~werks AND
*                                         a~lgort = b~lgort
*      INTO l_live
*      WHERE b~bukrs EQ p_bukrs    AND
*            a~vstel EQ itab-gsber AND
*            b~live  EQ space.
*    IF sy-subrc EQ 0.
*      MOVE itab-sortl TO itab-kunnr.
*    ENDIF.
*
*    IF p_amount IS INITIAL.
*      APPEND itab.
*    ELSE.
*      l_amount = ABS( itab-ending ) * 100.
*      IF l_amount < p_amount.
*        APPEND itab.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.                    " sum_brcust_old

*&---------------------------------------------------------------------*
*&      Form  F_SUT_TOP
*&---------------------------------------------------------------------*
FORM f_sut_top .
  DATA: BEGIN OF lt_bsid OCCURS 0,
          vbeln TYPE vbeln_vl,
        END OF lt_bsid.
  DATA: BEGIN OF lt_bsid1 OCCURS 0,
          flag(1),
          brcod(1),
          seqtyp(1),
          seqnr(6),
          spmth     TYPE zspmth,
          year      TYPE zspyear,
        END OF lt_bsid1.
  DATA: BEGIN OF lt_bsid2 OCCURS 0,
          vbeln TYPE vbeln,
          vkbur TYPE vkbur,
          year  TYPE gjahr,
        END OF lt_bsid2.

  SELECT bukrs werks live
    FROM zplbc
    INTO TABLE gt_zplbc
    WHERE bukrs EQ p_bukrs
      AND werks IN s_gsber.

  LOOP AT it_bsid.
    lt_bsid-vbeln = it_bsid-zuonr(10).
    APPEND lt_bsid.

    CASE p_bukrs.
      WHEN '8020'.
        lt_bsid2-vbeln = it_bsid-zuonr.
        lt_bsid2-vkbur = it_bsid-vkbur.
        lt_bsid2-year  = it_bsid-gjahr.
        APPEND lt_bsid2.

      WHEN '8070'.
        lt_bsid1-flag    = it_bsid-zuonr(1).
        lt_bsid1-brcod   = it_bsid-zuonr+1(1).
        lt_bsid1-seqtyp  = it_bsid-zuonr+2(1).
        lt_bsid1-seqnr   = it_bsid-zuonr+3(6).
        lt_bsid1-spmth   = it_bsid-monat.
        lt_bsid1-year    = it_bsid-gjahr.
        APPEND lt_bsid1.
    ENDCASE.
  ENDLOOP.

  SORT lt_bsid BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_bsid COMPARING vbeln.
  SORT lt_bsid1 BY flag brcod seqtyp seqnr spmth year.
  DELETE ADJACENT DUPLICATES FROM lt_bsid1 COMPARING ALL FIELDS.
  SORT lt_bsid2 BY vbeln vkbur year.
  DELETE ADJACENT DUPLICATES FROM lt_bsid2 COMPARING ALL FIELDS.

  IF lt_bsid[] IS NOT INITIAL.
    CASE p_bukrs.
      WHEN '8020'.
        IF p_ord1 IS NOT INITIAL.
          SELECT DISTINCT vbeln vgbel
            INTO TABLE gt_lips
            FROM lips FOR ALL ENTRIES IN lt_bsid
            WHERE vbeln EQ lt_bsid-vbeln.
          IF sy-subrc = 0.
            SELECT vbeln auart
              INTO TABLE gt_vbak
              FROM vbak FOR ALL ENTRIES IN gt_lips
              WHERE vbeln EQ gt_lips-vgbel.
          ENDIF.
        ENDIF.

      WHEN '8070'.
        SELECT vbeln fkarv
          FROM likp
          INTO TABLE gt_likp
          FOR ALL ENTRIES IN lt_bsid
          WHERE vbeln EQ lt_bsid-vbeln.
    ENDCASE.
  ENDIF.

  IF lt_bsid1[] IS NOT INITIAL.
    READ TABLE lt_bsid1 INDEX 1.
    IF sy-subrc EQ 0.
      IF lt_bsid1-spmth IS INITIAL AND
        lt_bsid1-year IS INITIAL.
        SELECT brcod seqtyp seqnr spmth spyear divcod
          FROM zssutdt003
          INTO TABLE gt_zssutdt003
          FOR ALL ENTRIES IN lt_bsid1
          WHERE fltyp    EQ 'DO'
            AND zprogram IN ('DO', 'CN')
            AND brcod    EQ lt_bsid1-brcod
            AND seqtyp   EQ lt_bsid1-seqtyp
            AND seqnr    EQ lt_bsid1-seqnr.
      ELSE.
        SELECT brcod seqtyp seqnr spmth spyear divcod
          FROM zssutdt003
          INTO TABLE gt_zssutdt003
          FOR ALL ENTRIES IN lt_bsid1
          WHERE fltyp    EQ 'DO'
            AND zprogram IN ('DO', 'CN')
            AND brcod    EQ lt_bsid1-brcod
            AND seqtyp   EQ lt_bsid1-seqtyp
            AND seqnr    EQ lt_bsid1-seqnr
            AND spyear   EQ lt_bsid1-year
            AND spmth    EQ lt_bsid1-spmth.
      ENDIF.
    ENDIF.
  ENDIF.

  SORT gt_zssutdt003 BY brcod seqtyp seqnr spmth spyear divcod.

  IF lt_bsid2[] IS NOT INITIAL.
    SELECT vkbur gjahr vbeln vbtyp a~fkart auart divcod
      INTO TABLE gt_hsales
      FROM zsl_hsales AS a JOIN zscr_control AS b ON b~fkart = a~fkart
      FOR ALL ENTRIES IN lt_bsid2
      WHERE vbeln = lt_bsid2-vbeln
        AND vkbur = lt_bsid2-vkbur
        AND vkorg = p_bukrs
        AND divcod NE space.
*        AND gjahr = lt_bsid2-year.

    SORT gt_hsales BY vkbur gjahr vbeln vbtyp fkart auart divcod.
  ENDIF.
ENDFORM.                    " F_SUT_TOP

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_TO_IT_BSID
*&---------------------------------------------------------------------*
FORM f_move_to_it_bsid .
  it_bsid-bschl    = t_bsid_temp-bschl.
  it_bsid-umskz    = t_bsid_temp-umskz.
  it_bsid-budat    = t_bsid_temp-budat.
  it_bsid-bldat    = t_bsid_temp-bldat.
  it_bsid-belnr    = t_bsid_temp-belnr.
  it_bsid-gjahr    = t_bsid_temp-gjahr.
  it_bsid-zbd1t    = t_bsid_temp-zbd1t.
  it_bsid-zfbdt    = t_bsid_temp-zfbdt.
  it_bsid-xref1    = t_bsid_temp-xref1.
  it_bsid-xref2    = t_bsid_temp-xref2.
  it_bsid-zterm    = t_bsid_temp-zterm.
  IF t_bsid_temp-shkzg EQ 'H'.
    it_bsid-faktur   = t_bsid_temp-dmbtr * -1.
  ELSE.
    it_bsid-faktur   = t_bsid_temp-dmbtr.
  ENDIF.
  IF it_bsid-dmbtr LT 0.
    it_bsid-shkzg  = 'H'.
  ELSE.
    it_bsid-shkzg  = 'S'.
  ENDIF.
  it_bsid-dmbtr  = abs( it_bsid-dmbtr ).
ENDFORM.                    " F_MOVE_TO_IT_BSID

*&---------------------------------------------------------------------*
*&      Form  F_GET_ZFBID
*&---------------------------------------------------------------------*
FORM f_get_zfbid  USING    fu_bukrs fu_gsber fu_gjahr fu_kunnr fu_zuonr
                           fu_flag
                  CHANGING fc_bbeln fc_nottf fc_tglttf.

  DATA : BEGIN OF lt_zfbid OCCURS 0,
           bukrs  LIKE zfbid-bukrs,
           vkbur  LIKE zfbid-vkbur,
*           bbeln  LIKE zfbid-bbeln,
           bbeln  LIKE zfbid_sfa-bbeln,
           ebelp  LIKE zfbid-ebelp,
           vbeln  LIKE zfbid-vbeln,
           bflag  LIKE zfbid-bflag,
           nottf  LIKE zfbid-nottf,
           tglttf LIKE zfbid-tglttf,
         END OF lt_zfbid.

  DATA : lt_zfbid_sfa LIKE lt_zfbid OCCURS 0 WITH HEADER LINE.
  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  RANGES: lr_bflag FOR zfbid-bflag.

  lr_bflag-low    = 'D'.
  lr_bflag-sign   = 'E'.
  lr_bflag-option = 'EQ'.
  APPEND lr_bflag.
  lr_bflag-low    = 'P'.
  lr_bflag-sign   = 'E'.
  lr_bflag-option = 'EQ'.
  APPEND lr_bflag.
  lr_bflag-low    = 'E'.
  lr_bflag-sign   = 'E'.
  lr_bflag-option = 'EQ'.
  APPEND lr_bflag.

  IF fu_flag IS INITIAL.
    SELECT bukrs vkbur bbeln ebelp vbeln bflag nottf tglttf
      FROM zfbid
      INTO TABLE lt_zfbid
      WHERE bukrs EQ fu_bukrs
        AND vkbur EQ fu_gsber
*        AND gjahr EQ fu_gjahr
*        AND bflag IN lr_bflag
        AND kunnr EQ fu_kunnr
        AND zuonr EQ fu_zuonr
      ORDER BY PRIMARY KEY.

    SELECT bukrs vkbur bbeln ebelp vbeln bflag nottf tglttf
      FROM zfbid_sfa
      INTO CORRESPONDING FIELDS OF TABLE lt_zfbid_sfa
      WHERE bukrs EQ fu_bukrs
        AND vkbur EQ fu_gsber
*        AND gjahr EQ fu_gjahr
*        AND bflag IN lr_bflag
        AND kunnr EQ fu_kunnr
        AND zuonr EQ fu_zuonr
      ORDER BY PRIMARY KEY.

    CLEAR : fc_bbeln, fc_nottf, fc_tglttf.

    SORT lt_zfbid BY bbeln DESCENDING.
    SORT lt_zfbid_sfa BY bflag.

    READ TABLE lt_zfbid INDEX 1.
    IF sy-subrc = 0.
      IF lt_zfbid-bflag IN lr_bflag.
        fc_bbeln  = lt_zfbid-bbeln.
      ENDIF.

      DELETE lt_zfbid WHERE nottf IS INITIAL
                        AND ( tglttf IS INITIAL OR tglttf = space ).
      SORT lt_zfbid BY tglttf.
      READ TABLE lt_zfbid INDEX 1.
      IF sy-subrc = 0.
        fc_nottf  = lt_zfbid-nottf.
        fc_tglttf = lt_zfbid-tglttf.
      ENDIF.
    ENDIF.

    IF fc_bbeln IS INITIAL.
      READ TABLE lt_zfbid_sfa INDEX 1.
      IF sy-subrc = 0.
        IF lt_zfbid_sfa-bflag IN lr_bflag.
          fc_bbeln  = lt_zfbid_sfa-bbeln.
        ENDIF.

        DELETE lt_zfbid_sfa WHERE nottf IS INITIAL
                              AND ( tglttf IS INITIAL OR tglttf = space ).
        SORT lt_zfbid_sfa BY tglttf.
        READ TABLE lt_zfbid_sfa INDEX 1.
        IF sy-subrc = 0.
          fc_nottf  = lt_zfbid_sfa-nottf.
          fc_tglttf = lt_zfbid_sfa-tglttf.
        ENDIF.
      ENDIF.
    ENDIF..
  ELSE.
    LOOP AT it_bsid.
      lt_bsid = it_bsid.
      APPEND lt_bsid.
      CLEAR lt_bsid.

      READ TABLE gt_zfarsoff WITH KEY kunnr   = it_bsid-kunnr
                                      zvkbur1 = it_bsid-vkbur.
      IF sy-subrc = 0.
        lt_bsid = it_bsid.
        lt_bsid-vkbur = gt_zfarsoff-zvkbur.
        APPEND lt_bsid.
        CLEAR lt_bsid.
      ENDIF.
    ENDLOOP.

    SORT lt_bsid BY bukrs vkbur kunnr zuonr.
    DELETE ADJACENT DUPLICATES FROM lt_bsid COMPARING bukrs vkbur kunnr
                                                      zuonr.

    CHECK lt_bsid[] IS NOT INITIAL.

    SELECT bukrs vkbur kunnr zuonr zfbdt
      FROM zfbid
      INTO TABLE gt_zfbid
      FOR ALL ENTRIES IN lt_bsid
      WHERE bukrs = lt_bsid-bukrs
        AND vkbur = lt_bsid-vkbur
        AND kunnr = lt_bsid-kunnr
        AND zuonr = lt_bsid-zuonr.

    SORT gt_zfbid BY bukrs vkbur kunnr zuonr zfbdt.
  ENDIF.
ENDFORM.                    " F_GET_ZFBID

*&---------------------------------------------------------------------*
*&      Form  F_DA_MODIFY
*&---------------------------------------------------------------------*
FORM f_da_modify  USING    fu_kunnr fu_zuonr
                  CHANGING fc_zfbdt fc_duedt.
  DATA : lv_index TYPE sy-tabix,
         lv_count TYPE int4.

  CLEAR : lv_index, lv_count.

*  SORT gt_da BY zuonr belnr.
  SORT gt_da BY zuonr gjahr belnr.
  LOOP AT gt_da WHERE kunnr = fu_kunnr
                  AND zuonr = fu_zuonr.
    IF lv_index IS INITIAL.
      lv_index  = sy-tabix.
    ENDIF.
    ADD 1 TO lv_count.
  ENDLOOP.

  IF lv_count > 1.
    READ TABLE gt_da INDEX lv_index.
    IF sy-subrc = 0.
      fc_zfbdt    = gt_da-zfbdt.
      fc_duedt    = gt_da-zfbdt.
      IF gt_da-umskz = 'V'.
        fc_zfbdt    = gt_da-budat.
        fc_duedt    = gt_da-budat.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DA_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_GET_RV
*&---------------------------------------------------------------------*
FORM f_get_rv .
  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  lt_bsid[] = it_bsid[].
  SORT lt_bsid BY bukrs kunnr zuonr.
  DELETE ADJACENT DUPLICATES FROM lt_bsid COMPARING bukrs kunnr zuonr.

  CHECK lt_bsid[] IS NOT INITIAL.

  SELECT bukrs kunnr umsks umskz augdt augbl zuonr gjahr belnr buzei
    blart shkzg dmbtr zfbdt zbd1t
    FROM bsid
    INTO CORRESPONDING FIELDS OF TABLE gt_rv
    FOR ALL ENTRIES IN lt_bsid
    WHERE bukrs = lt_bsid-bukrs
      AND kunnr = lt_bsid-kunnr
      AND zuonr = lt_bsid-zuonr
      AND blart IN ('RV', 'ZA')
      ORDER BY PRIMARY KEY.

  SELECT bukrs kunnr umsks umskz augdt augbl zuonr gjahr belnr buzei
    blart shkzg dmbtr zfbdt zbd1t
    FROM bsad
    APPENDING CORRESPONDING FIELDS OF TABLE gt_rv
    FOR ALL ENTRIES IN lt_bsid
    WHERE bukrs = lt_bsid-bukrs
      AND kunnr = lt_bsid-kunnr
      AND zuonr = lt_bsid-zuonr
      AND blart IN ('RV', 'ZA')
      ORDER BY PRIMARY KEY.
ENDFORM.                    " F_GET_RV

*&---------------------------------------------------------------------*
*&      Form  F_GET_DA
*&---------------------------------------------------------------------*
FORM f_get_da.
  DATA : lt_bsid  LIKE it_bsid OCCURS 0 WITH HEADER LINE.

  lt_bsid[] = it_bsid[].
  SORT lt_bsid BY bukrs kunnr zuonr.
  DELETE ADJACENT DUPLICATES FROM lt_bsid COMPARING bukrs kunnr zuonr.

  CHECK lt_bsid[] IS NOT INITIAL.

  SELECT bukrs kunnr umsks umskz augdt augbl zuonr gjahr belnr buzei
    blart shkzg dmbtr zfbdt budat
    FROM bsid
    INTO CORRESPONDING FIELDS OF TABLE gt_da
    FOR ALL ENTRIES IN lt_bsid
    WHERE bukrs = lt_bsid-bukrs
      AND kunnr = lt_bsid-kunnr
      AND zuonr = lt_bsid-zuonr
      AND blart = 'DA'
      ORDER BY PRIMARY KEY.

  SELECT bukrs kunnr umsks umskz augdt augbl zuonr gjahr belnr buzei
    blart shkzg dmbtr zfbdt budat
    FROM bsad
    APPENDING CORRESPONDING FIELDS OF TABLE gt_da
    FOR ALL ENTRIES IN lt_bsid
    WHERE bukrs = lt_bsid-bukrs
      AND kunnr = lt_bsid-kunnr
      AND zuonr = lt_bsid-zuonr
      AND blart = 'DA'
      ORDER BY PRIMARY KEY.
ENDFORM.                    " F_GET_DA

*&---------------------------------------------------------------------*
*&      Form  F_NILAI_FAKTUR
*&---------------------------------------------------------------------*
FORM f_nilai_faktur  USING    fu_kunnr fu_zuonr
                     CHANGING fc_faktur.

*  CHECK fc_faktur IS NOT INITIAL.

  READ TABLE gt_rv WITH KEY kunnr = fu_kunnr
                            zuonr = fu_zuonr
                            blart = 'ZA'.
  IF sy-subrc = 0.
    IF gt_rv-shkzg = 'H'.
      fc_faktur = gt_rv-dmbtr * -1.
    ELSE.
      fc_faktur = gt_rv-dmbtr.
    ENDIF.
  ELSE.
    READ TABLE gt_rv WITH KEY kunnr = fu_kunnr
                              zuonr = fu_zuonr
                              blart = 'RV'.
    IF sy-subrc = 0.
      IF gt_rv-shkzg = 'H'.
        fc_faktur = gt_rv-dmbtr * -1.
      ELSE.
        fc_faktur = gt_rv-dmbtr.
      ENDIF.
    ELSE.
      READ TABLE gt_da WITH KEY kunnr = fu_kunnr
                                zuonr = fu_zuonr.
      IF sy-subrc = 0.
        IF gt_da-shkzg = 'H'.
          fc_faktur = gt_da-dmbtr * -1.
        ELSE.
          fc_faktur = gt_da-dmbtr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_NILAI_FAKTUR

*&---------------------------------------------------------------------*
*&      Form  F_GET_DA_FR_IT_BSID
*&---------------------------------------------------------------------*
FORM f_get_da_fr_it_bsid .
  DATA : lt_da  LIKE it_bsid OCCURS 0 WITH HEADER LINE.
  DATA : lt_zfh_kr1at  LIKE gt_zfh_kr1at OCCURS 0 WITH HEADER LINE.

  LOOP AT it_bsid WHERE blart = 'DA'.
    lt_da  = it_bsid.
    APPEND lt_da.
    CLEAR lt_da.
  ENDLOOP.

  CHECK lt_da[] IS NOT INITIAL.

  SELECT bukrs gsber vkbur noform zuonr kunnr sgtxt1 sgtxt2
    FROM zfh_kr1at
    INTO CORRESPONDING FIELDS OF TABLE gt_zfh_kr1at
    FOR ALL ENTRIES IN lt_da
    WHERE bukrs = lt_da-bukrs
      AND vkbur = lt_da-vkbur
      AND zuonr = lt_da-zuonr
      AND kunnr = lt_da-kunnr
   ORDER BY PRIMARY KEY.
ENDFORM.                    " F_GET_DA_FR_IT_BSID

*&---------------------------------------------------------------------*
*&      Form  F_DUE_DATE_MODIFY
*&---------------------------------------------------------------------*
FORM f_due_date_modify  USING    fu_kunnr
                                 fu_zuonr
                        CHANGING fc_duedt.
  DATA : i_faede LIKE faede,
         e_faede LIKE faede.

*  READ TABLE gt_zfbid WITH KEY kunnr = fu_kunnr
*                               zuonr = fu_zuonr.
*  IF sy-subrc = 0.
*    fc_duedt  = gt_zfbid-zfbdt.
*  ELSE.
  SORT gt_rv BY kunnr zuonr zfbdt DESCENDING.
  READ TABLE gt_rv WITH KEY kunnr = fu_kunnr
                            zuonr = fu_zuonr.
  IF sy-subrc = 0.
    i_faede-koart = 'D'.
    i_faede-zfbdt = gt_rv-zfbdt.
    i_faede-zbd1t = gt_rv-zbd1t.

    CALL FUNCTION 'DETERMINE_DUE_DATE'
      EXPORTING
        i_faede                    = i_faede
      IMPORTING
        e_faede                    = e_faede
      EXCEPTIONS
        account_type_not_supported = 1
        OTHERS                     = 2.
    IF sy-subrc = 0.
      fc_duedt  = e_faede-netdt.
    ENDIF.
  ENDIF.
*  ENDIF.
ENDFORM.                    " F_DUE_DATE_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_TEXT_MODIFY
*&---------------------------------------------------------------------*
FORM f_text_modify  USING    fu_kunnr fu_zuonr fu_zfbdt
                    CHANGING fc_sgtxt fc_faktur fc_top.
  LOOP AT gt_zfh_kr1at WHERE kunnr = fu_kunnr
                         AND zuonr = fu_zuonr.
    IF gt_zfh_kr1at-sgtxt2 IS INITIAL.
      fc_sgtxt  = gt_zfh_kr1at-sgtxt1.
      CLEAR fc_faktur.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF fc_faktur IS INITIAL.
*    CLEAR : fc_top.
  ELSE.
    fc_top = p_gerdat - fu_zfbdt.
  ENDIF.
ENDFORM.                    " F_TEXT_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_CALC_TOP
*&---------------------------------------------------------------------*
*FORM f_calc_top .
*  CLEAR itab-top.
*  IF it_bsid-umskz = 'U'.
*  ELSE.
*    itab-top = p_gerdat - it_bsid-zfbdt.
*  ENDIF.
*ENDFORM.                    " F_CALC_TOP

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ITAB_SFA
*&---------------------------------------------------------------------*
FORM f_modify_itab_sfa .
  DATA: lt_zfbid_sfa TYPE TABLE OF zfbid_sfa WITH HEADER LINE.

  IF itab[] IS NOT INITIAL.
    SELECT * INTO TABLE lt_zfbid_sfa
      FROM zfbid_sfa FOR ALL ENTRIES IN itab
      WHERE bukrs = p_bukrs
        AND vkbur = itab-gsber
        AND zuonr = itab-zuonr
        AND kunnr = itab-kunnr.

    LOOP AT itab ASSIGNING <fs_itab>.
      IF <fs_itab>-bbeln IS INITIAL.
        CLEAR lt_zfbid_sfa.
        READ TABLE lt_zfbid_sfa WITH KEY zuonr = itab-zuonr
                                         kunnr = itab-kunnr.
        <fs_itab>-bbeln = lt_zfbid_sfa-bbeln.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_ITAB_SFA

*&---------------------------------------------------------------------*
*&      Form  F_INIT_KVGR3
*&---------------------------------------------------------------------*
FORM f_init_kvgr3 .
  CLEAR p_kvgr3.
  p_kvgr3-sign = 'I'.
  p_kvgr3-option = 'EQ'.
  p_kvgr3-low = '05T'.
  APPEND p_kvgr3. CLEAR p_kvgr3.
ENDFORM.                    " F_INIT_KVGR3

*&---------------------------------------------------------------------*
*&      Form  F_ADD_PO_NUMBER_RTV
*&---------------------------------------------------------------------*
FORM f_add_po_number_rtv .
  DATA : lt_bsid     LIKE it_bsid OCCURS 0,
         ls_bsid     LIKE LINE OF lt_bsid,
         lt_xvbrp    TYPE STANDARD TABLE OF vbrp,
         lt_xfarpotd TYPE STANDARD TABLE OF zfarpotd,
         ls_xvbak    LIKE LINE OF gt_xvbak,
         ls_xfarpotd LIKE LINE OF lt_xfarpotd.

  DATA : ls_xvbfa LIKE LINE OF gt_xvbfa,
         lt_vbfa  TYPE STANDARD TABLE OF vbfa,
         ls_vbfa  LIKE LINE OF lt_vbfa.

  lt_bsid[] = it_bsid[].
  SORT lt_bsid BY zuonr.
  DELETE ADJACENT DUPLICATES FROM lt_bsid COMPARING zuonr.
  IF lt_bsid[] IS NOT INITIAL.
    LOOP AT lt_bsid INTO ls_bsid.
      ls_xvbfa-vbelv = ls_bsid-zuonr.
      APPEND ls_xvbfa TO gt_xvbfa.
      CLEAR ls_xvbfa.
    ENDLOOP.
  ENDIF.

******  IF gt_xvbfa[] IS NOT INITIAL.
******    SELECT *
******      FROM vbfa
******      INTO CORRESPONDING FIELDS OF TABLE lt_vbfa
******      FOR ALL ENTRIES IN gt_xvbfa
******      WHERE vbelv   = gt_xvbfa-vbelv
******        AND vbtyp_n = 'M'.
******  ENDIF.
******
******  LOOP AT gt_xvbfa INTO ls_xvbfa.
******    CLEAR ls_vbfa.
******    READ TABLE lt_vbfa INTO ls_vbfa
******                       WITH KEY vbelv = ls_xvbfa-vbelv.
******    IF sy-subrc = 0.
******      ls_xvbfa-vbeln = ls_vbfa-vbeln.
******    ELSE.
******      ls_xvbfa-vbeln = ls_xvbfa-vbelv.
******    ENDIF.
******    MODIFY gt_xvbfa FROM ls_xvbfa TRANSPORTING vbeln.
******    CLEAR ls_xvbfa.
******  ENDLOOP.

  IF gt_xvbfa[] IS NOT INITIAL.
    SELECT *
      FROM vbrp
      INTO CORRESPONDING FIELDS OF TABLE gt_xvbrp
      FOR ALL ENTRIES IN gt_xvbfa
      WHERE vbeln = gt_xvbfa-vbelv
      ORDER BY PRIMARY KEY.

    lt_xvbrp[] = gt_xvbrp[].
    SORT lt_xvbrp BY aubel.
    DELETE ADJACENT DUPLICATES FROM lt_xvbrp COMPARING aubel.
    IF lt_xvbrp[] IS NOT INITIAL.
      SELECT *
        FROM vbak
        INTO CORRESPONDING FIELDS OF TABLE gt_xvbak
        FOR ALL ENTRIES IN lt_xvbrp
        WHERE vbeln = lt_xvbrp-aubel
        ORDER BY PRIMARY KEY.

      LOOP AT gt_xvbak INTO ls_xvbak.
        ls_xfarpotd-bukrs = p_bukrs.
        ls_xfarpotd-vkbur = ls_xvbak-vkbur.
        ls_xfarpotd-rtvnr = ls_xvbak-bstnk.
        IF ls_xvbak-bstnk IS NOT INITIAL.
          APPEND ls_xfarpotd TO lt_xfarpotd.
        ENDIF.
        CLEAR ls_xfarpotd.
      ENDLOOP.
    ENDIF.

    SORT lt_xfarpotd BY bukrs vkbur rtvnr.
    DELETE ADJACENT DUPLICATES FROM lt_xfarpotd COMPARING bukrs vkbur rtvnr.
    IF lt_xfarpotd[] IS NOT INITIAL.
      SELECT *
        FROM zfarpotd
        INTO CORRESPONDING FIELDS OF TABLE gt_zfarpotd
        FOR ALL ENTRIES IN lt_xfarpotd
        WHERE bukrs = lt_xfarpotd-bukrs
          AND vkbur = lt_xfarpotd-vkbur
          AND rtvnr = lt_xfarpotd-rtvnr
          ORDER BY PRIMARY KEY.
    ENDIF.

    lt_xfarpotd[] = gt_zfarpotd[].
    SORT lt_xfarpotd BY bukrs gsber vkbur noarp mjahr.
    DELETE ADJACENT DUPLICATES FROM lt_xfarpotd COMPARING bukrs gsber vkbur noarp mjahr.
    IF lt_xfarpotd[] IS NOT INITIAL.
      SELECT *
        FROM zfarpoth
        INTO CORRESPONDING FIELDS OF TABLE gt_zfarpoth
        FOR ALL ENTRIES IN lt_xfarpotd
        WHERE bukrs = lt_xfarpotd-bukrs
          AND gsber = lt_xfarpotd-gsber
          AND vkbur = lt_xfarpotd-vkbur
          AND noarp = lt_xfarpotd-noarp
          AND mjahr = lt_xfarpotd-mjahr
          ORDER BY PRIMARY KEY.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ADD_PO_NUMBER_RTV

*&---------------------------------------------------------------------*
*&      Form  F_ARPOT
*&---------------------------------------------------------------------*
FORM f_arpot  USING    fu_zuonr
              CHANGING fc_bstnk.
  DATA : ls_xvbrp    LIKE LINE OF gt_xvbrp,
         ls_xvbak    LIKE LINE OF gt_xvbak,
         ls_zfarpotd LIKE LINE OF gt_zfarpotd,
         ls_zfarpoth LIKE LINE OF gt_zfarpoth,
         ls_xvbfa    LIKE LINE OF gt_xvbfa.

*  CLEAR : ls_xvbfa, fc_bstnk.
*  READ TABLE gt_xvbfa INTO ls_xvbfa
*                      WITH KEY vbelv = fu_zuonr.
*  IF sy-subrc = 0.
  CLEAR : ls_xvbrp, fc_bstnk.
  READ TABLE gt_xvbrp INTO ls_xvbrp
                      WITH KEY vbeln = fu_zuonr.
  IF sy-subrc = 0.
    CLEAR ls_xvbak.
    READ TABLE gt_xvbak INTO ls_xvbak
                        WITH KEY vbeln = ls_xvbrp-aubel.
    IF sy-subrc = 0.
      CLEAR ls_zfarpotd.
      SORT gt_zfarpotd BY rtvnr noarp DESCENDING.
      READ TABLE gt_zfarpotd INTO ls_zfarpotd
                             WITH KEY rtvnr = ls_xvbak-bstnk
                                      kunnr = ls_xvbak-kunnr.
      IF sy-subrc = 0.
        CLEAR ls_zfarpoth.
        READ TABLE gt_zfarpoth INTO ls_zfarpoth
                               WITH KEY bukrs = ls_zfarpotd-bukrs
                                        gsber = ls_zfarpotd-gsber
                                        vkbur = ls_zfarpotd-vkbur
                                        noarp = ls_zfarpotd-noarp
                                        mjahr = ls_zfarpotd-mjahr.
        IF sy-subrc = 0.
          IF ls_zfarpoth-belnrrev IS INITIAL.
            CONCATENATE ls_zfarpotd-rtvnr '-' ls_zfarpotd-noarp INTO fc_bstnk
            SEPARATED BY space.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
*  ENDIF.
ENDFORM.                    " F_ARPOT
