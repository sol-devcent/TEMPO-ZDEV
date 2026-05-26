************************************************************************
*                                                                      *
*  PROGRAM NAME  :  ZFF_VAT_RETURN ( SAP SCRIPT )                      *
*  PROGRAM DESC  :  VAT RETURN                                         *
*  CREATED BY    :  DIDIK IMAWAN                                       *
*  CREATED ON    :  14/06/2002 (DD/MM/YY)                              *
*  VERSION       :  4.6C                                               *
*                                                                      *
************************************************************************
*                                                                      *
*  MODIFICATION LOG :                                                  *
*                                                                      *
*  DATE        PROGRAMMER   CORRECTION  DESCRIPTION                    *
*  ----------  -----------  ----------  -------------------------      *
*  28/02/2003  BUDI. P         B001     KOREKSI HITUNG COUNTER         *
*                                                                      *
*  28/04/2005  BUDI. P         B002     Tampilkan Tanggal Pengukuhan   *
*                                                                      *
*& CRNO#          DATE         AUTHOR         DESCRIPTION              *
*& DEVK932068     19.08.2013                  Modifikasi untuk SUT     *
*&                                            Project                  *
************************************************************************
REPORT zff_vat_return_new NO STANDARD PAGE HEADING
                      MESSAGE-ID zf
                      LINE-SIZE 121.

TYPE-POOLS: tpit.
TABLES : sscrfields.

INCLUDE zabp_bdc.
INCLUDE zff_vat_return_new_itab.

TYPES: BEGIN OF ty_nr.
        INCLUDE STRUCTURE zfvatin_nr.
TYPES:   budat  TYPE rbkp-budat,
         bldat  TYPE rbkp-bldat,
         name1  TYPE lfa1-name1,
         total  TYPE rbkp-rmwwr,
         dpp    TYPE rbkp-rmwwr,
         ppn    TYPE rbkp-wmwst1,
       END OF ty_nr.

TYPES: BEGIN OF t_itab4,
            bukrs LIKE bsis-bukrs,
            belnr LIKE bsis-belnr,
            gjahr LIKE bsis-gjahr,
       END OF t_itab4.
DATA: i_itab4 TYPE t_itab4 OCCURS 0,
      wa_itab4 TYPE t_itab4.

DATA: gv_gsber    TYPE gsber,
      menge(13),
      hasat(13),
      va_nonr   LIKE zfvatin_nr-nonr.

DATA: gt_nr     TYPE STANDARD TABLE OF ty_nr.
DATA: gt_xitab  TYPE STANDARD TABLE OF ta_itab1.

DATA: gs_header   TYPE zfist001,
      gt_detail   TYPE STANDARD TABLE OF zfist001.

***********************************************************************
* CONSTANTS
***********************************************************************

CONSTANTS :
        c_blart_kg         LIKE bsis-blart VALUE 'KG',
        c_blart_re         LIKE bsis-blart VALUE 'RE',
        c_waers_idr        LIKE bsis-waers VALUE 'IDR',
        c_augtx(35)        VALUE 'VAT - input Reconciliation (RETURN)',
        c_hkont_210        LIKE bsis-hkont VALUE '0142200210',
        c_hkont_200        LIKE bsis-hkont VALUE '0142200200'.

***********************************************************************
* PARAMETERS & SELECT-OPTIONS
***********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK xbclk1 WITH FRAME TITLE text-001.
PARAMETERS:
  p_bukrs LIKE bsis-bukrs OBLIGATORY DEFAULT '8020',
  p_gsber LIKE bsis-gsber OBLIGATORY DEFAULT '0200',
*  p_belnr LIKE bsis-belnr,
  p_gjahr LIKE bsis-gjahr OBLIGATORY DEFAULT sy-datum+0(4).
* Pa_monat like bsis-monat default sy-datum+4(2) obligatory.

SELECT-OPTIONS: s_belnr FOR bsis-belnr MODIF ID sbe,
                s_budat FOR bsis-budat.
PARAMETERS    : sign(24) OBLIGATORY MODIF ID sig.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_new   AS CHECKBOX MODIF ID new DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK xbclk1.

SELECTION-SCREEN BEGIN OF BLOCK xbclk2 WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_type1 RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND rad.
SELECTION-SCREEN : COMMENT 5(30) text-003 FOR FIELD p_type1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_type2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(30) text-004 FOR FIELD p_type2.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_type3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(30) text-005 FOR FIELD p_type3.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_type4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(30) text-006 FOR FIELD p_type4.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_type5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(30) text-007 FOR FIELD p_type5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK xbclk2.

************************************************************************
* AT SELECTION-SCREEN
************************************************************************
DATA: l_gsberx LIKE tgsb-gsber.

AT SELECTION-SCREEN ON p_bukrs.

  IF p_bukrs EQ '8020' OR p_bukrs EQ '8010' OR p_bukrs EQ '8030' OR
     p_bukrs EQ '8230' OR p_bukrs EQ '8050' OR p_bukrs EQ '8070'.
  ELSE.
    MESSAGE e000(zf)
      WITH 'CoCd must be entry 8010, 8020, 8030, 8230, 8050, 8070'.
  ENDIF.

AT SELECTION-SCREEN ON p_gsber.
  IF p_bukrs EQ '8020'.
    IF p_gsber NE '0200' AND p_gsber NE '02TM'.
      MESSAGE e000(zf) WITH 'Business Area must be entry 0200/02TM'.
    ENDIF.
  ELSEIF p_bukrs EQ '8030'.
    IF p_gsber EQ 0 OR p_gsber EQ space OR p_gsber+0(2) NE '03'.
      MESSAGE e000(zf) WITH 'Business Area must be entry 03xx'.
    ELSE.
      SELECT SINGLE gsber FROM tgsb INTO l_gsberx
      WHERE gsber EQ p_gsber.
      IF sy-subrc NE 0.
        MESSAGE e000(zf) WITH 'Business Area not found'.
      ENDIF.
    ENDIF.
  ELSEIF p_bukrs EQ '8010'.
    IF p_gsber EQ 0 OR p_gsber EQ space OR p_gsber+0(2) NE '01'.
      MESSAGE e000(zf) WITH 'Business Area must be entry 01xx'.
    ENDIF.
  ELSEIF p_bukrs EQ '8070'.
    IF p_gsber EQ 0 OR p_gsber EQ space OR p_gsber+0(2) NE '07'.
      MESSAGE e000(zf) WITH 'Business Area must be entry 07xx'.
    ENDIF.
  ENDIF.

*INCLUDE PRINT RETUN PARITAL (KG)
  INCLUDE zff_vat_return_new_print_kg.

*INCLUDE PRINT PO RETURN (RE)
  INCLUDE zff_vat_return_new_print_re.

* common report header and other functions
  INCLUDE zabp_header.

* ALV common functions
  INCLUDE zabp_alv_common.

INITIALIZATION.
  DATA: lv_parva(40).

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
    p_gsber  = lv_parva.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  CASE 'X'.
    WHEN p_type1.
      LOOP AT SCREEN.
        IF screen-group1 = 'NEW'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN p_type2.
      LOOP AT SCREEN.
        IF screen-group1 = 'NEW'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN p_type5.
      LOOP AT SCREEN.
        IF screen-group1 = 'SIG' OR
          screen-group1 = 'NEW'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

  DATA: vheader LIKE thead.

  IF p_bukrs EQ '8020'.
    gv_gsber  = '0200'.
  ELSEIF p_bukrs EQ '8070'.
    gv_gsber  = '0700'.
  ELSE.
    gv_gsber  = '0200'.
  ENDIF.

  CASE 'X'.
    WHEN p_type1.
      PERFORM get_header_data.
    WHEN p_type2.
      PERFORM get_header_bsas.
    WHEN p_type3.
      PERFORM get_header_bsas1.
    WHEN p_type4.
      PERFORM f_get_data_nr.
      PERFORM get_header_bsas1.
    WHEN p_type5.
      PERFORM f_get_data_nr.
  ENDCASE.

  IF p_type5 IS NOT INITIAL.
    PERFORM f_print_data.
  ELSE.
    IF i_itab1[] IS INITIAL.
      MESSAGE 'No Data' TYPE 'I'.
      STOP.
    ELSE.
      IF p_type3 IS NOT INITIAL AND
        pa_new IS INITIAL.
        MESSAGE 'No Data' TYPE 'I'.
        STOP.
      ELSE.
        PERFORM f_print_data.
      ENDIF.
    ENDIF.
  ENDIF.

END-OF-SELECTION.

  INCLUDE zff_vat_return_newf01.

*&---------------------------------------------------------------------*
*&      Form  HEADER_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header_text USING fu_ucomm.
  DATA: l_noret(20),
        l_adrnr  LIKE t001-adrnr,
        l_adrnr1 LIKE tvbur-adrnr,
        l_name1  LIKE adrc-name1,
        l_street LIKE adrc-street,
        l_city1  LIKE adrc-city1,
        l_name2  LIKE adrc-name2,
        l_name3  LIKE adrc-name3,
        l_name4  LIKE adrc-name4,
        l_npwp   LIKE zftax-npwp,
        l_pkpname LIKE zgdtxdt0005-pkpname,
        l_pkpaddrs1 LIKE zgdtxdt0005-pkpaddrs1,
        l_pkpaddrs2 LIKE zgdtxdt0005-pkpaddrs2,
        l_pkppostal LIKE zgdtxdt0005-pkppostal,
        l_pkpcity LIKE zgdtxdt0005-pkpcity,
        l_names(70),
        l_streets(100),
        l_street1(100),
        l_cntr  TYPE i,
        l_cntr1 TYPE i VALUE 1,
        l_cntr2 TYPE i VALUE 2,
        l_cntr3 TYPE i VALUE 3,
        l_cntr4 TYPE i VALUE 4,
        l_cntr5 TYPE i VALUE 5,
        l_norut TYPE i.

  DATA : lv_nonr(8),
         lv_view.

  DATA : ls_nr    LIKE LINE OF gt_nr.

  CLEAR: faktur1, faktur2, faktur3, faktur4, faktur5.

  CASE 'X'.
    WHEN p_type3.
      IF fu_ucomm = '&PREV'.
        lv_view = 'X'.
      ELSE.
        CLEAR lv_view.
      ENDIF.
      PERFORM f_next_number USING 'ZNONR' p_bukrs p_gjahr lv_view
                            CHANGING lv_nonr.

      CASE p_bukrs.
        WHEN '8020'.
          CONCATENATE 'PTT/' p_gjahr '/' lv_nonr INTO l_noret.
        WHEN '8070'.
          CONCATENATE 'SUT/' p_gjahr '/' lv_nonr INTO l_noret.
      ENDCASE.
    WHEN p_type4.
      CASE p_bukrs.
        WHEN '8020'.
          READ TABLE gt_nr INTO ls_nr
                           WITH KEY bukrs = va_bukrs
                                    gsber = va_gsber
                                    belnr = va_belnr
                                    gjahr = va_gjahr.
          IF sy-subrc = 0.
            l_noret = ls_nr-nonr.
          ENDIF.
        WHEN '8070'.
          READ TABLE gt_nr INTO ls_nr
                           WITH KEY bukrs = va_bukrs
                                    gsber = p_gsber
                                    belnr = va_belnr
                                    gjahr = va_gjahr.
          IF sy-subrc = 0.
            l_noret = ls_nr-nonr.
          ENDIF.
      ENDCASE.

    WHEN OTHERS.
      CONCATENATE wa_itab1-blart wa_itab1-belnr INTO l_noret
        SEPARATED BY space.
  ENDCASE.

  va_nonr  = l_noret.

  CONCATENATE va_name1 va_name2 INTO l_names
    SEPARATED BY space.
  l_streets  = va_stras.
  l_street1  = va_ort01.
*  CONCATENATE VA_STRAS VA_ORT01 INTO L_STREETS
*    SEPARATED BY SPACE.

***********************************************************************
* GET NAME1 FROM ADRC
***********************************************************************
  SELECT SINGLE adrnr FROM t001
    INTO l_adrnr
    WHERE bukrs = wa_itab1-bukrs.
  SELECT SINGLE name1 FROM adrc
    INTO l_name1
    WHERE addrnumber = l_adrnr.

***********************************************************************
* GET STREET & CITY1 FROM ADRC
***********************************************************************
  IF p_gsber = '02TM'.
    SELECT SINGLE adrnr FROM tvbur
      INTO l_adrnr1
      WHERE vkbur = gv_gsber.
  ELSE.
    SELECT SINGLE adrnr FROM tvbur
      INTO l_adrnr1
      WHERE vkbur = p_gsber.
  ENDIF.
  IF wa_itab1-budat LT '20111101'.
    SELECT SINGLE street city1 FROM adrc
      INTO (l_street, l_city1)
      WHERE addrnumber = l_adrnr1.
  ELSE.
    IF p_gsber = '02TM'.
      SELECT SINGLE pkpname pkpaddrs1 pkpaddrs2 pkppostal pkpcity
        FROM zgdtxdt0005
        INTO (l_pkpname, l_pkpaddrs1, l_pkpaddrs2, l_pkppostal, l_pkpcity)
        WHERE bukrs EQ p_bukrs AND
              brnch EQ gv_gsber.
    ELSE.
      SELECT SINGLE pkpname pkpaddrs1 pkpaddrs2 pkppostal pkpcity
        FROM zgdtxdt0005
        INTO (l_pkpname, l_pkpaddrs1, l_pkpaddrs2, l_pkppostal, l_pkpcity)
        WHERE bukrs EQ p_bukrs AND
              brnch EQ p_gsber.
    ENDIF.
    l_street = l_pkpaddrs1.
    CONCATENATE l_pkpaddrs2 l_pkpcity l_pkppostal INTO l_city1 SEPARATED BY space.
*    SELECT SINGLE NAME2 NAME3 NAME4 FROM ADRC
*      INTO (L_NAME2, L_NAME3, L_NAME4)
*      WHERE ADDRNUMBER = L_ADRNR1.
*    L_STREET = L_NAME2.
*    CONCATENATE L_NAME3 L_NAME4 INTO L_CITY1 SEPARATED BY SPACE.
  ENDIF.

***********************************************************************
* GET NPWP
***********************************************************************
  IF p_gsber = '02TM'.
    SELECT SINGLE npwp FROM zftax
      INTO l_npwp
      WHERE bukrs = p_bukrs AND
            gsber = gv_gsber.
  ELSE.
    SELECT SINGLE npwp FROM zftax
      INTO l_npwp
      WHERE bukrs = p_bukrs AND
            gsber = p_gsber.
  ENDIF.

***********************************************************************
* MOVE PEMBELI & PENJUAL TO FORM
***********************************************************************
  MOVE l_name1   TO name1.
  MOVE l_street  TO street.
  MOVE l_city1   TO city1.
  MOVE l_npwp    TO npwp.
  MOVE l_names   TO names.
  MOVE l_streets TO streets.
  MOVE l_street1 TO street1.
  MOVE va_stceg  TO stceg.
  MOVE va_stenr  TO stenr.

***********************************************************************
* GET KETERANGAN FAKTUR
***********************************************************************
*  DESCRIBE TABLE I_ITAB3 LINES VA_LINES.
*  IF VA_LINES NE 0.

  ADD 1 TO cntr1.
  WRITE l_noret TO noret.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'PAGE'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER1'
      window  = 'HEADER1'
    EXCEPTIONS
      OTHERS  = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER2'
      window  = 'HEADER2'
    EXCEPTIONS
      OTHERS  = 1.

  IF va_bktxt+6(4) GT 2006.
    IF p_type2 EQ 'X'.
      CONCATENATE va_zuonr1(3) '.' va_zuonr1+3(3) '-' va_zuonr1+6(2) '.'
                  va_zuonr1+8(8)
        INTO faktur1.
      CONCATENATE faktur1 '/' va_bktxt INTO faktur1
        SEPARATED BY space.
    ENDIF.
  ELSE.
    IF p_type2 EQ 'X'.
      CONCATENATE va_stcd1 va_zuonr1 INTO faktur1.
      CONCATENATE faktur1 '/' va_bktxt INTO faktur1
        SEPARATED BY space.
    ENDIF.
  ENDIF.

  DATA: ld_len TYPE i.
  IF p_type3 EQ 'X'  OR
     p_type4 EQ 'X'.
    CLEAR: wa_hdr3, faktur1, faktur2, faktur3, faktur4, faktur5.
    CLEAR: l_norut.
    SORT i_hdr3 BY sgtxt.
    READ TABLE i_hdr3 INTO wa_hdr3 WITH KEY belnr = wa_itab1-belnr.
    IF sy-subrc EQ 0.
      ld_len = STRLEN( wa_hdr3-sgtxt ).
      ld_len = ld_len - 4.
      IF ld_len < 0.
        ld_len = 0.
      ENDIF.

      ADD 1 TO l_norut.
      CASE l_norut.
        WHEN 1.
          IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
            faktur1 = wa_hdr3-sgtxt.
          ELSE.
            CONCATENATE va_stcd1 wa_hdr3-sgtxt INTO faktur1.
          ENDIF.
        WHEN 2.
          IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
            faktur2 = wa_hdr3-sgtxt.
          ELSE.
            CONCATENATE va_stcd1 wa_hdr3-sgtxt INTO faktur2.
          ENDIF.
        WHEN 3.
          IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
            faktur3 = wa_hdr3-sgtxt.
          ELSE.
            CONCATENATE va_stcd1 wa_hdr3-sgtxt INTO faktur3.
          ENDIF.
        WHEN 4.
          IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
            faktur4 = wa_hdr3-sgtxt.
          ELSE.
            CONCATENATE va_stcd1 wa_hdr3-sgtxt INTO faktur4.
          ENDIF.
        WHEN 5.
          IF wa_hdr3-sgtxt+ld_len(4) GT 2006.
            faktur5 = wa_hdr3-sgtxt.
          ELSE.
            CONCATENATE va_stcd1 wa_hdr3-sgtxt INTO faktur5.
          ENDIF.
      ENDCASE.
      CLEAR: ld_len.
    ENDIF.

*    LOOP AT i_hdr3 INTO wa_hdr3 WHERE belnr = wa_itab1-belnr.
*      AT NEW sgtxt.
*      ENDAT.
*      CLEAR: ld_len.
*    ENDLOOP.
  ENDIF.

*    CLEAR WA_ITAB3.
*    LOOP AT I_ITAB3 INTO wA_itab3.
*      ADD 1 TO L_CNTR.
*      CASE L_CNTR.
*        WHEN L_CNTR1.
*          MOVE WA_ITAB3-TDLINE TO FAKTUR1.
*        WHEN L_CNTR2.
*          MOVE WA_ITAB3-TDLINE TO FAKTUR2.
*        WHEN L_CNTR3.
*          MOVE WA_ITAB3-TDLINE TO FAKTUR3.
*        WHEN L_CNTR4.
*          MOVE WA_ITAB3-TDLINE TO FAKTUR4.
*        WHEN L_CNTR5.
*          MOVE WA_ITAB3-TDLINE TO FAKTUR5.
*      ENDCASE.
*      CLEAR WA_ITAB3.
*    ENDLOOP.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER3'
      window  = 'HEADER3'
    EXCEPTIONS
      OTHERS  = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'HEADER4'
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window = 'HEADER5'
    EXCEPTIONS
      OTHERS = 1.

  CASE 'X'.
    WHEN p_type3.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          window  = 'HEADER6'
          element = 'HEAD5'
        EXCEPTIONS
          OTHERS  = 1.
    WHEN p_type4.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          window  = 'HEADER6'
          element = 'HEAD5'
        EXCEPTIONS
          OTHERS  = 1.
    WHEN OTHERS.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          window  = 'HEADER6'
          element = 'HEAD3'
        EXCEPTIONS
          OTHERS  = 1.
  ENDCASE.
*  ENDIF.

ENDFORM.                    " HEADER_TEXT
*&---------------------------------------------------------------------*
*&      Form  GET_HEADER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_header_data.
  DATA: l_lifnr LIKE bsik-lifnr,
        l_gsber LIKE bsik-gsber,
        l_zuonr LIKE bsik-zuonr,
        l_anred LIKE lfa1-anred,
        l_name1 LIKE lfa1-name1,
        l_name2 LIKE lfa1-name2,
        l_stras LIKE lfa1-stras,
        l_ort01 LIKE lfa1-ort01,
        l_stceg LIKE lfa1-stceg,
        l_stcd1 LIKE lfa1-stcd1,
        l_stblg LIKE rbkp-stblg.

  SELECT a~bukrs a~hkont a~gjahr a~belnr a~augbl a~budat a~bldat
         a~waers a~xblnr a~blart a~monat a~shkzg a~bschl a~mwskz
         a~dmbtr a~zfbdt a~sgtxt b~belnr b~awkey
    FROM bsis AS a JOIN bkpf AS b
         ON a~bukrs = b~bukrs AND
            a~belnr = b~belnr AND
            a~blart = b~blart AND
            a~gjahr = b~gjahr

    INTO CORRESPONDING FIELDS OF TABLE i_itab11
    WHERE a~bukrs = p_bukrs      AND
          a~hkont = '0142200200' AND
*          a~belnr = p_belnr      AND
          a~belnr IN s_belnr      AND
          a~gjahr = p_gjahr      AND
          a~budat IN s_budat     AND
          a~shkzg = 'H'          AND
*          A~GSBER = P_GSBER      AND
          ( a~blart = 'KG' OR a~blart = 'RE' )
          AND ( b~tcode = 'MIRO' OR b~tcode = 'MIR7' ).

  CLEAR wa_itab1.
  LOOP AT i_itab11 INTO wa_itab1.
    MOVE wa_itab1-awkey+0(10) TO wa_itab1-rbeln.
    CLEAR l_stblg.
    SELECT SINGLE stblg INTO l_stblg FROM rbkp
          WHERE belnr EQ wa_itab1-rbeln AND
                gjahr EQ p_gjahr AND
                ( tcode EQ 'MIRO' OR tcode EQ 'MIR7' ) AND
                bukrs EQ p_bukrs.
    IF l_stblg NE space.
      CONTINUE.
    ENDIF.

***********************************************************************
* GET LIFNR, GSBER, ZUONR FROM BSIK OR BSAK
***********************************************************************
    CLEAR: l_lifnr, l_gsber, l_zuonr.
    SELECT SINGLE lifnr gsber zuonr
      FROM bsik
      INTO (l_lifnr, l_gsber, l_zuonr)
      WHERE belnr = wa_itab1-belnr AND
            ( blart = 'KG' OR blart = 'RE' ) AND
            gjahr EQ p_gjahr AND
            bukrs EQ p_bukrs.
    IF l_gsber = '0' OR
       l_gsber = space.
      SELECT SINGLE lifnr gsber zuonr
        FROM bsak
        INTO (l_lifnr, l_gsber, l_zuonr)
        WHERE belnr = wa_itab1-belnr AND
              bukrs = wa_itab1-bukrs AND
              ( blart = 'KG' OR blart = 'RE' ) AND
            gjahr EQ p_gjahr AND
            bukrs EQ p_bukrs.          " Add by Skd

      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.
      MOVE l_lifnr TO wa_itab1-lifnr.
      MOVE l_gsber TO wa_itab1-gsber.
      CONCATENATE wa_itab1-blart wa_itab1-belnr INTO wa_itab1-zuonr
        SEPARATED BY space.
      MOVE l_zuonr TO wa_itab1-zuonr.
    ELSE.
      MOVE l_lifnr TO wa_itab1-lifnr.
      MOVE l_gsber TO wa_itab1-gsber.
      CONCATENATE wa_itab1-blart wa_itab1-belnr INTO wa_itab1-zuonr
        SEPARATED BY space.
    ENDIF.

***********************************************************************
* GET ANRED, NAME1, NAME2, STRAS, ORT01, STCEG, STCD1
***********************************************************************
    CLEAR: l_anred, l_name1, l_name2, l_stras, l_ort01, l_stceg.
    SELECT SINGLE anred name1 name2 stras ort01 stceg  stcd1 FROM lfa1
      INTO (l_anred, l_name1, l_name2, l_stras, l_ort01, l_stceg,
            l_stcd1)
      WHERE lifnr = wa_itab1-lifnr.

    MOVE l_name1 TO wa_itab1-name1.
    MOVE l_name2 TO wa_itab1-name2.
    MOVE l_stras TO wa_itab1-stras.
    MOVE l_ort01 TO wa_itab1-ort01.
    MOVE l_stceg TO wa_itab1-stceg.
    MOVE l_stcd1 TO wa_itab1-stcd1.

    CONCATENATE l_name1 l_name2 INTO wa_itab1-sgtxt
      SEPARATED BY space.
    CONCATENATE wa_itab1-blart wa_itab1-belnr INTO wa_itab1-xblnr
      SEPARATED BY space.
    APPEND wa_itab1 TO i_itab1.
*    MODIFY I_ITAB1 FROM WA_ITAB1.
    CLEAR wa_itab1.
  ENDLOOP.
ENDFORM.                    " GET_HEADER_DATA

*&---------------------------------------------------------------------*
*&      Form  CETAK_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_form.
  PERFORM header_text USING ''.
  PERFORM get_detail_bsas.
ENDFORM.                    " CETAK_FORM

*&---------------------------------------------------------------------*
*&      Form  CETAK_FORM1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_form1 USING fu_ucomm.
  PERFORM header_text USING fu_ucomm.
  PERFORM get_detail_bsas1.
ENDFORM.                    " CETAK_FORM1

*&---------------------------------------------------------------------*
*&      Form  CETAK_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_detail USING fu_menge fu_hasat.
  DATA: l_amnt  LIKE rseg-wrbtr,
        l_amnt1 LIKE rseg-wrbtr,
        l_amnt_out LIKE rseg-wrbtr.

  CLEAR: l_amnt_out.
  l_amnt  = wa_itab2-amnt * 100. "/ WA_ITAB2-QUANT * 100.
*  L_AMNT1 = WA_ITAB2-AMNT * 100.
  l_amnt1 = va_amnt2 * 100.

*  WRITE WA_ITAB2-EBELP TO EBELP.
*  IF EBELP = 0.
*    WRITE WA_ITAB2-BUZEI TO EBELP.
*  ENDIF.
*  WRITE WA_ITAB2-MAKTX TO MAKTX.
*  WRITE WA_ITAB2-QUANT TO QUANT DECIMALS 2.
  WRITE l_amnt         TO wrbtr DECIMALS 0.
  WRITE l_amnt1        TO amnt DECIMALS 0.

  CASE 'X'.
    WHEN p_type3.
      menge = fu_menge.
      hasat = fu_hasat.
    WHEN p_type4.
      menge = fu_menge.
      hasat = fu_hasat.
    WHEN OTHERS.
  ENDCASE.

*---------- B001 ----------
*  IF COUNTER LE 20.
  IF counter LE 18.
*--------------------------
    CASE 'X'.
      WHEN p_type3.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'DETAIL1'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.
      WHEN p_type4.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'DETAIL1'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.
      WHEN OTHERS.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'DETAIL'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.
    ENDCASE.

    CLEAR: amnt3.

*---------- B001 ----------
*    IF COUNTER EQ 20.
    IF counter EQ 18.
*--------------------------
      l_amnt_out = va_amnt1 * 100.
      WRITE l_amnt_out TO amnt2 DECIMALS 0.
*      VA_AMNT1  = VA_AMNT1  * 100.
*      WRITE VA_AMNT1  TO AMNT2 DECIMALS 0.

*---------- B001 ----------
*      IF COUNTER1 LT 20.
      IF counter1 LT 18.
*--------------------------
        DO 25 TIMES.
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'KOSONG'
              window  = 'MAIN'
            EXCEPTIONS
              OTHERS  = 1.
        ENDDO.
      ENDIF.
      IF counter LT ln_itab2tmp.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'DIPINDAHKAN'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.
        WRITE amnt2 TO amnt3 DECIMALS 0.
        CLEAR: l_amnt_out.
      ENDIF.
    ENDIF.
  ELSE.
    ADD 1 TO page1.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'SKIP'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.

    CLEAR amnt2.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'PINDAHAN'
        window  = 'MAIN'
      EXCEPTIONS
        OTHERS  = 1.

    CASE 'X'.
      WHEN p_type3.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'DETAIL1'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.
      WHEN p_type4.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'DETAIL1'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.
      WHEN OTHERS.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'DETAIL'
            window  = 'MAIN'
          EXCEPTIONS
            OTHERS  = 1.
    ENDCASE.
*---------- B001 ----------
*    COUNTER = 0.
    counter = 1.
*--------------------------
  ENDIF.
ENDFORM.                    " CETAK_DETAIL

*&---------------------------------------------------------------------*
*&      Form  HITUNG_RECORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hitung_record.
  DATA: lt_itab   TYPE ta_itab1 OCCURS 0.
  DATA: l_fname   LIKE thead-tdname.
  DATA: t_itab1   LIKE tline OCCURS 2 WITH HEADER LINE.

  CLEAR: wa_itab1,l_fname,cntr,cntr1.
  lt_itab[] = i_itab1[].
  DELETE lt_itab WHERE check = space.

  SORT lt_itab BY belnr rbeln DESCENDING.
  LOOP AT lt_itab INTO wa_itab1.
    CONCATENATE wa_itab1-bukrs wa_itab1-belnr wa_itab1-gjahr INTO l_fname.
    AT NEW rbeln.
      CALL FUNCTION 'READ_TEXT_INLINE'
        EXPORTING
          id             = '0004'
          inline_count   = 5
          language       = 'E'
          name           = l_fname
          object         = 'BELEG'
        TABLES
          inlines        = t_itab1
          lines          = i_itab3
        EXCEPTIONS
          id             = 1
          language       = 2
          name           = 3
          not_found      = 4
          object         = 5
          refrence_check = 6
          OTHERS         = 7.

      DESCRIBE TABLE i_itab3 LINES va_lines.
      IF va_lines NE 0.
        ADD 1 TO cntr.
      ENDIF.
    ENDAT.
  ENDLOOP.

  CLEAR: wa_itab1,l_fname, va_lines.
  REFRESH: t_itab1, i_itab3.
ENDFORM.                    " HITUNG_RECORD

*&---------------------------------------------------------------------*
*&      Form  PRINT_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_update USING va_belnr.

  DATA: v_nast LIKE nast.

  SELECT SINGLE *
  FROM   nast
  WHERE  kappl = 'V1'
  AND    objky = va_belnr
  AND    kschl = 'FI00'
  AND    spras = sy-langu
  AND    vstat = '1'.

  IF sy-subrc NE 0. "AND VA_TDSPOOLID ne 0.
    "-- belum ada --> insert
    CLEAR v_nast.
    v_nast-erdat = sy-datum.
    v_nast-eruhr = sy-uzeit.
    v_nast-mandt = sy-mandt.
    v_nast-kappl = 'V1'.
    v_nast-objky = va_belnr.
    v_nast-kschl = 'FI00'.
    v_nast-spras = sy-langu.
    v_nast-parnr = va_lifnr.
    v_nast-parvw = va_blart.
    v_nast-datvr = sy-datum.
    v_nast-datvr = sy-datum.

    v_nast-vstat = '1'.
    v_nast-tdarmod = 1.
    v_nast-optarcnr = 0.
*     v_NAST-OBJTYPE = 'VBRK'.
    v_nast-nacha = 1.
    v_nast-anzal = 0.
    v_nast-vsztp = 3.
    v_nast-usnam = sy-uname.
    INSERT INTO nast VALUES v_nast.
  ENDIF.
  CLEAR: va_lifnr, va_blart.
ENDFORM.                    " PRINT_UPDATE

*&---------------------------------------------------------------------*
*&      Form  CEK_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek_print.
  SELECT SINGLE *
    FROM   nast
      WHERE  kappl EQ 'V1'
                   AND    objky = wa_itab1-belnr
                   AND    kschl = 'FI00'
                   AND    spras = sy-langu
                   AND    vstat = '1'.
ENDFORM.                    " CEK_PRINT

*&---------------------------------------------------------------------*
*&      Form  f_post_f04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_f04.
  DATA:  l_value(15),
        l_date(10),
        l_date1(10),
        l_mess(50),
        l_monat(2),
        l_year(4).

  va_mode = 'N'.    " MODE = 'N' (Running BackGroud); 'A' (Running ForeGroud)

  WRITE sy-datum+4(2) TO l_monat.
  WRITE wa_itab1-zfbdt TO l_date.
  WRITE wa_itab1-budat TO l_date1.
  l_value = wa_itab1-dmbtr * 100.
  IF wa_itab1-zfbdt+4(2) < wa_itab1-budat+4(2).
    va_xref3 = '43'.
  ELSE.
    va_xref3 = '44'.
  ENDIF.

  CLEAR i_bdc.
  PERFORM f_dynpro USING:
        'X'  'SAPMF05A'     '0122',
        ' '  'BDC_OKCODE'    '=SL',
        ' '  'BKPF-BLDAT'   l_date,
        ' '  'BKPF-BUDAT'   l_date1,
        ' '  'BKPF-XBLNR'   wa_itab1-xblnr,
        ' '  'BKPF-BLART'   'NR',
        ' '  'BKPF-MONAT'    l_monat,
        ' '  'BKPF-BUKRS'   p_bukrs,
        ' '  'BKPF-WAERS'   'IDR',
        ' '  'BKPF-BKTXT'   wa_itab1-stceg,
        ' '  'RF05A-AUGTX'   c_augtx,
        ' '  'RF05A-NEWBS'  wa_itab1-bschl,
        ' '  'RF05A-NEWKO'  c_hkont_210,   " '0142200210',

        'X'  'SAPMF05A'     '0300',
        ' '  'BDC_OKCODE'    '=SL',
        ' '  'BSEG-WRBTR'   l_value,
        ' '  'BSEG-ZFBDT'   l_date,
        ' '  'BSEG-ZUONR'   wa_itab1-zuonr,
        ' '  'BSEG-SGTXT'   wa_itab1-sgtxt,
        ' '  'BDC_OKCODE'   '=ZK',

        'X'  'SAPLKACB'     '0002',
        ' '  'BDC_OKCODE'   '=ENTE',
        ' '  'COBL-GSBER'   wa_itab1-gsber,

        'X'  'SAPMF05A'     '0330',
        ' '  'BDC_OKCODE'   '/00',
        ' '  'BSEG-XREF3'   va_xref3,
        ' '  'BDC_OKCODE'   '=PA',

        'X'  'SAPMF05A'     '0710',
        ' '  'BDC_OKCODE'   '/5',
        ' '  'RF05A-AGBUK'  p_bukrs,
        ' '  'RF05A-AGKON'  c_hkont_200,  "'0142200200',
        ' '  'RF05A-AGKOA'     'S',
        ' '  'RF05A-XAUTS'     'X',

        'X'  'SAPMF05A'       '0733',
        ' '  'RF05A-FELDN(1)' 'BELNR',
        ' '  'RF05A-SEL01(1)' wa_itab1-belnr,
        ' '  'BDC_OKCODE'     '=BU'.
  CALL TRANSACTION 'F-04' USING i_bdc MODE va_mode UPDATE 'S'
                     MESSAGES INTO i_messtab.
  IF sy-subrc NE 0.
    READ TABLE i_messtab INTO wa_messtab INDEX 1.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id   = wa_messtab-msgid
        lang = wa_messtab-msgspra
        no   = wa_messtab-msgnr
        v1   = wa_messtab-msgv1
        v2   = wa_messtab-msgv2
        v3   = wa_messtab-msgv3
        v4   = wa_messtab-msgv4
      IMPORTING
        msg  = wa_log_error-msg.

    wa_log_error-hkont =   va_hkont2.
    wa_log_error-bukrs = p_bukrs.
    wa_log_error-gjahr = wa_itab1-gjahr.
    wa_log_error-belnr = wa_itab1-belnr.
    APPEND wa_log_error TO i_log_error.
  ENDIF.

ENDFORM.                    " f_post_clearing_vatin

*************************************************************
FORM f_dynpro USING dynbegin name value.
*************************************************************
  IF dynbegin =  'X'.
    CLEAR:  wa_bdc.
    MOVE: name  TO wa_bdc-program,
          value TO wa_bdc-dynpro ,
          'X'   TO wa_bdc-dynbegin.
    APPEND wa_bdc TO i_bdc.
  ELSE.
    CLEAR:  wa_bdc.
    MOVE: name    TO wa_bdc-fnam,
          value   TO wa_bdc-fval.
    APPEND wa_bdc TO i_bdc.
  ENDIF.
ENDFORM.                               " F_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_FI_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_change_fi_document USING fu_belnr.
  DATA : lv_mode,
         lv_update.

  lv_mode   = 'N'.
  lv_update = 'S'.

  CLEAR: t_bdcdata,t_bdcmsg.
  REFRESH: t_bdcdata, t_bdcmsg.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPMF05L'      '0102',
       ' '  'BDC_OKCODE'    '/00',
       ' '  'RF05L-BELNR'   fu_belnr,
       ' '  'RF05L-BUKRS'   p_bukrs,
       ' '  'RF05L-GJAHR'   p_gjahr,
       ' '  'RF05L-XKKRE'   'X'.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPMF05L'      '0302',
       ' '  'BDC_OKCODE'    '=ZK'.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPMF05L'      '1302',
       ' '  'BDC_OKCODE'    '=ENTR',
       ' '  'BSEG-XREF3'    va_nonr.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPMF05L'      '0302',
       ' '  'BDC_OKCODE'    '=AE'.

  CALL TRANSACTION 'FB09' USING t_bdcdata
                          MODE lv_mode
                          UPDATE lv_update
                          MESSAGES INTO t_bdcmsg.
ENDFORM.                    " F_CHANGE_FI_DOCUMENT
