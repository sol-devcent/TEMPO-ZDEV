************************************************************************
*                  REPORT                                              *
*----------------------------------------------------------------------*
* ABAP Name   : ZFAR_AGING_TSP                                         *
* Created by  : Didik Imawan                                           *
* Created on  : 08/01/2003                                             *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description                          *
*                                                                      *
* 02/05/2005  Budi Pramono  Tambah Radiobutton Customer ,              *
*                           Industry Sector & Account ( HKONT )        *
* 01/10/2020  sol_jonhar    Modify sorting at end statement            *
*                           and binary search syntax                   *                                                                    *
************************************************************************
REPORT zfar_aging_tsp MESSAGE-ID zf
                      LINE-SIZE  232
                      LINE-COUNT 60
                      NO STANDARD PAGE HEADING.

INCLUDE zfar_aging_tsp_top.

INCLUDE zabp_atz.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS : pa_bukrs LIKE t001t-bukrs OBLIGATORY DEFAULT '8010'.
*                                          MODIF ID XXX.
SELECT-OPTIONS: so_gsber FOR bsid-gsber.
*                 SO_KUNNR FOR BSID-KUNNR.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio3 RADIOBUTTON GROUP grp2 DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 6(26) text-010 FOR FIELD radio3.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS : so_kunnr FOR bsid-kunnr MODIF ID zzz.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio4 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 6(26) text-011 FOR FIELD radio4.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS : so_brsch FOR kna1-brsch NO INTERVALS.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio5 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 6(26) text-012 FOR FIELD radio5.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS : so_hkont FOR bsid-hkont.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.

PARAMETERS:  pa_gstid LIKE bsid-budat OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(10) text-002.
SELECTION-SCREEN:  POSITION 33.
PARAMETERS:int1low(3)  DEFAULT 30,
           int2low(3)  DEFAULT 60,
           int3low(3)  DEFAULT 90,
           int4low(3)  DEFAULT 120.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-003.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp1
             USER-COMMAND dik DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(22) text-004 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(22) text-005 FOR FIELD radio2.
SELECTION-SCREEN POSITION 28.
PARAMETERS : pa_waers LIKE bsis-waers MODIF ID yyy.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE text-006.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: x_norm LIKE itemset-xnorm AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 4(24) text-007 FOR FIELD x_norm.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: x_shbv LIKE itemset-xshbv AS CHECKBOX.
SELECTION-SCREEN : COMMENT 4(24) text-008 FOR FIELD x_shbv.
SELECTION-SCREEN:  POSITION 30.
SELECT-OPTIONS: so_umskz FOR bsid-umskz NO INTERVALS.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block3.

*&---------------------------------------------------------------------*
*&      VALIDATE FOR SELECTION SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON pa_bukrs.
  macro_atz_single_bukrs pa_bukrs c_atz_display.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'XXX'.
      screen-input  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  IF radio1 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'YYY'.
        screen-input  = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    CLEAR: pa_waers.
  ELSEIF radio2 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'YYY'.
        screen-input  = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  CLEAR: radio1.

*&---------------------------------------------------------------------*
*&      START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  SET PF-STATUS '100'.

  va_monat1 = pa_gstid+4(2).
  va_monat2 = pa_gstid+4(2) + 1.

  IF va_monat2 > 12.
    va_monat2 = va_monat2 - 12.
    va_gjahr  = pa_gstid(4) + 1.
  ENDIF.

  CONCATENATE pa_gstid(4) va_monat1 '01' INTO va_gerdat1.
  CONCATENATE va_gjahr va_monat2 '01' INTO va_gerdat2.
  CONCATENATE pa_gstid(6) '01' INTO va_gerdat3.
*  DO 3 TIMES.
  DO 24 TIMES.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = va_gerdat3
      IMPORTING
        last_day_of_month = va_gerdat3
      EXCEPTIONS
        day_in_no_date    = 1
        OTHERS            = 2.
    va_gerdat3 = va_gerdat3 + 1.
  ENDDO.

  REFRESH: s_blart.
  m_range: 'RV','ZA','DR','DA','DZ','SA','DG','AB', 'D1', 'ZC', 'ZI','ZK'.
*  Perform f_initial_blart.
  IF radio1 EQ 'X'.
    PERFORM get_data_radio1.
    va_currency = 'IDR'.
  ELSE.
    PERFORM get_data_radio2.
    CLEAR: wa_itab.
    LOOP AT i_itab INTO wa_itab.
      wa_itab-dmbtr = wa_itab-wrbtr.
      MODIFY i_itab FROM wa_itab.
      CLEAR: wa_itab.
    ENDLOOP.
    CLEAR: wa_begbal.
    LOOP AT i_begbal INTO wa_begbal.
      IF wa_begbal-dmbtr NE 0.
        wa_begbal-dmbtr = wa_begbal-wrbtr.
        MODIFY i_begbal FROM wa_begbal.
      ENDIF.
      CLEAR: wa_begbal.
    ENDLOOP.
    va_currency = pa_waers.
  ENDIF.
  PERFORM process_data.
  PERFORM cetak_gsber.

END-OF-SELECTION.

**&---------------------------------------------------------------------
*
**&        AT LINE-SELECTION
**&---------------------------------------------------------------------
*
*  AT LINE-SELECTION.
*    READ CURRENT LINE FIELD VALUE: VA_GTEXT, VA_KUNNR, VA_BEGBAL1.
*    DATA : FFIELD(20), FVALUE(20).
*    GET CURSOR FIELD FFIELD VALUE FVALUE.
*    CASE FFIELD.
*       WHEN 'VA_GTEXT'.
*          SELECT SINGLE *
*             FROM TGSBT
*             WHERE GTEXT EQ VA_GTEXT.
*                PERFORM KUNNR_PROCESS.
*                PERFORM CETAK_DETAIL_KUNNR.
*
*       WHEN 'VA_KUNNR'.
*         PERFORM ZUONR_PROCESS.
*         PERFORM CETAK_DETAIL_ZUONR.
*    ENDCASE.

*&---------------------------------------------------------------------*
*&        AT USER-COMMAND
*&---------------------------------------------------------------------*
AT USER-COMMAND.
  CASE sy-ucomm.
    WHEN 'CHOOSE'.
      READ CURRENT LINE FIELD VALUE: va_gtext, va_kunnr, va_begbal1,
                                     va_belnr, va_gjahr1, va_zuonr,
                                     va_brsch, va_brtxt, va_hkont,
                                     va_txt20, va_name1.
      DATA : ffield(20), fvalue(20).
      GET CURSOR FIELD ffield VALUE fvalue.
      CASE ffield.
        WHEN 'VA_GTEXT'.
          va_count = 0.
          SELECT SINGLE *
             FROM tgsbt
             WHERE gtext EQ va_gtext.
          IF radio3 EQ 'X'.
            PERFORM kunnr_process.
            PERFORM cetak_detail_kunnr USING '1'.
          ENDIF.
          IF radio4 EQ 'X'.
            PERFORM brsch_process.
            PERFORM cetak_detail_brsch.
          ENDIF.
          IF radio5 EQ 'X'.
            PERFORM hkont_process.
            PERFORM cetak_detail_hkont.
          ENDIF.

        WHEN 'VA_KUNNR'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = va_kunnr
            IMPORTING
              output = va_kunnr.
          IF va_count = 0.
            PERFORM zuonr_process.
            PERFORM cetak_detail_zuonr.
          ELSE.
            PERFORM zuonr_process1.
            PERFORM cetak_detail_zuonr1.
          ENDIF.

        WHEN 'VA_BRSCH'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = va_brsch
            IMPORTING
              output = va_brsch.
          IF va_count = 0.
            PERFORM process_brsch.
            PERFORM cetak_detail_kunnr USING '2'.
          ELSE.
            PERFORM process1_brsch.
            PERFORM cetak_detail_kunnr USING '2'.
          ENDIF.

        WHEN 'VA_HKONT'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = va_hkont
            IMPORTING
              output = va_hkont.
          IF va_count = 0.
            PERFORM process_hkont.
            PERFORM cetak_detail_kunnr USING '2'.
          ELSE.
            PERFORM process1_hkont.
            PERFORM cetak_detail_kunnr USING '2'.
          ENDIF.

        WHEN 'VA_ZUONR'.
          SET PARAMETER ID 'BLN' FIELD va_belnr.
          SET PARAMETER ID 'BUK' FIELD pa_bukrs.
          SET PARAMETER ID 'GJR' FIELD va_gjahr1.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDCASE.

    WHEN 'BUSINESS'.
      PERFORM cetak_gsber.
*** Modify By Budi 10/03/2006
      va_ucomm = sy-ucomm.
*** End Modify

    WHEN 'ALL'.
      IF radio3 EQ 'X'.
        PERFORM proses_all.
        PERFORM cetak_detail_all.
      ELSEIF radio4 EQ 'X'.
        PERFORM proses_all1.
        PERFORM cetak_detail_all1.
      ELSEIF radio5 EQ 'X'.
        PERFORM proses_all2.
        PERFORM cetak_detail_all2.
      ENDIF.
*** Modify By Budi 10/03/2006
      va_ucomm = sy-ucomm.
*** End Modify

    WHEN 'BACK' OR 'EXIT' OR 'CANCL'.
*** Modify By Budi 10/03/2006
      CLEAR va_ucomm.
*** End Modify
      LEAVE TO SCREEN 0.
  ENDCASE.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_RADIO1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_radio1.

  IF x_norm EQ 'X' AND
     x_shbv EQ 'X'.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            kunnr IN so_kunnr AND
            gsber IN so_gsber AND
            umskz IN so_umskz AND
            budat LE pa_gstid AND
*            bldat LE pa_gstid AND
            blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              umskz IN so_umskz   AND
              budat LE pa_gstid   AND
*              augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              umskz IN so_umskz   AND
              budat LE pa_gstid   AND
*            bldat LE pa_gstid   AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.
  ENDIF.

  IF x_norm EQ 'X' AND
     x_shbv EQ space.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            umskz EQ space    AND
            kunnr IN so_kunnr AND
            gsber IN so_gsber AND
            budat LE pa_gstid AND
*            bldat LE pa_gstid AND
            blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz EQ space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LE pa_gstid   AND
*              augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz EQ space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LE pa_gstid   AND
*            bldat LE pa_gstid   AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.
  ENDIF.

  IF x_norm EQ space AND
     x_shbv EQ 'X'   AND
     so_umskz EQ space.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            umskz NE space    AND
            kunnr IN so_kunnr AND
            gsber IN so_gsber AND
            budat LE pa_gstid AND
*            bldat LE pa_gstid AND
             blart IN s_blart.
*           blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz NE space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LE pa_gstid   AND
*              augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz NE space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LE pa_gstid   AND
*            bldat LE pa_gstid   AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.
  ENDIF.

  IF x_norm EQ space AND
     x_shbv EQ 'X'   AND
     so_umskz NE space.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            kunnr IN so_kunnr AND
            gsber IN so_gsber AND
            umskz IN so_umskz AND
            budat LE pa_gstid AND
*            bldat LE pa_gstid AND
            blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              umskz IN so_umskz   AND
              budat LE pa_gstid   AND
*              augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              umskz IN so_umskz   AND
              budat LE pa_gstid   AND
*            bldat LE pa_gstid   AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.
  ENDIF.

* GETTING DATA FOR BEGINNING BALANCE
  IF x_norm EQ 'X' AND
     x_shbv EQ 'X'.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_begbal
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            kunnr IN so_kunnr   AND
            gsber IN so_gsber   AND
            umskz IN so_umskz   AND
            budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
            blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              umskz IN so_umskz   AND
              budat LT va_gerdat1 AND
*              augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              umskz IN so_umskz   AND
              budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.

    IF sy-subrc NE 0.
      LOOP AT i_itab INTO wa_itab.
        wa_itab-dmbtr  = 0.
        wa_itab-dmbtr1 = 0.
        wa_itab-dmbtr2 = 0.
        wa_itab-dmbtr3 = 0.
        wa_itab-dmbtr4 = 0.
        wa_itab-dmbtr5 = 0.
        APPEND wa_itab TO i_begbal.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF x_norm EQ 'X' AND
     x_shbv EQ space.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_begbal
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            umskz EQ space      AND
            kunnr IN so_kunnr   AND
            gsber IN so_gsber   AND
            budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
            blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz EQ space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LT va_gerdat1 AND
*              augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz EQ space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.

    IF sy-subrc NE 0.
      LOOP AT i_itab INTO wa_itab.
        wa_itab-dmbtr  = 0.
        wa_itab-dmbtr1 = 0.
        wa_itab-dmbtr2 = 0.
        wa_itab-dmbtr3 = 0.
        wa_itab-dmbtr4 = 0.
        wa_itab-dmbtr5 = 0.
        APPEND wa_itab TO i_begbal.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF x_norm EQ space AND
     x_shbv EQ 'X'   AND
     so_umskz EQ space.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_begbal
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            umskz NE space      AND
            kunnr IN so_kunnr   AND
            gsber IN so_gsber   AND
            budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
            blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz NE space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LT va_gerdat1 AND
*              augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz NE space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.

    IF sy-subrc NE 0.
      LOOP AT i_itab INTO wa_itab.
        wa_itab-dmbtr  = 0.
        wa_itab-dmbtr1 = 0.
        wa_itab-dmbtr2 = 0.
        wa_itab-dmbtr3 = 0.
        wa_itab-dmbtr4 = 0.
        wa_itab-dmbtr5 = 0.
        APPEND wa_itab TO i_begbal.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF x_norm EQ space AND
     x_shbv EQ 'X'   AND
     so_umskz NE space.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_begbal
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            kunnr IN so_kunnr   AND
            umskz IN so_umskz   AND
            gsber IN so_gsber   AND
            budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
            blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              umskz IN so_umskz   AND
              gsber IN so_gsber   AND
              budat LT va_gerdat1 AND
*              augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              umskz IN so_umskz   AND
              gsber IN so_gsber   AND
              budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.

    IF sy-subrc NE 0.
      LOOP AT i_itab INTO wa_itab.
        wa_itab-dmbtr  = 0.
        wa_itab-dmbtr1 = 0.
        wa_itab-dmbtr2 = 0.
        wa_itab-dmbtr3 = 0.
        wa_itab-dmbtr4 = 0.
        wa_itab-dmbtr5 = 0.
        APPEND wa_itab TO i_begbal.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_RADIO2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_radio2.
  IF x_norm EQ 'X' AND
     x_shbv EQ 'X'.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            kunnr IN so_kunnr AND
            gsber IN so_gsber AND
            umskz IN so_umskz AND
            budat LE pa_gstid AND
*            bldat LE pa_gstid AND
            waers EQ pa_waers AND
            blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              umskz IN so_umskz   AND
              budat LE pa_gstid   AND
*              augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              umskz IN so_umskz   AND
              budat LE pa_gstid   AND
*            bldat LE pa_gstid   AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.
  ENDIF.

  IF x_norm EQ 'X' AND
     x_shbv EQ space.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            umskz EQ space    AND
            kunnr IN so_kunnr AND
            gsber IN so_gsber AND
            budat LE pa_gstid AND
*            bldat LE pa_gstid AND
            waers EQ pa_waers AND
            blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz EQ space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LE pa_gstid   AND
*              augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz EQ space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LE pa_gstid   AND
*            bldat LE pa_gstid   AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.
  ENDIF.

  IF x_norm EQ space AND
     x_shbv EQ 'X'   AND
     so_umskz EQ space.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            umskz NE space    AND
            kunnr IN so_kunnr AND
            gsber IN so_gsber AND
            budat LE pa_gstid AND
*            bldat LE pa_gstid AND
            waers EQ pa_waers AND
             blart IN s_blart.
*           blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz NE space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LE pa_gstid   AND
*                augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz NE space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LE pa_gstid   AND
*            bldat LE pa_gstid   AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.
  ENDIF.

  IF x_norm EQ space AND
     x_shbv EQ 'X'   AND
     so_umskz NE space.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            kunnr IN so_kunnr AND
            gsber IN so_gsber AND
            umskz IN so_umskz AND
            budat LE pa_gstid AND
*            bldat LE pa_gstid AND
            waers EQ pa_waers AND
            blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              umskz IN so_umskz   AND
              budat LE pa_gstid   AND
*                augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_itab
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              umskz IN so_umskz   AND
              budat LE pa_gstid   AND
*            bldat LE pa_gstid   AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.
  ENDIF.

* GETTING DATA FOR BEGINNING BALANCE
  IF x_norm EQ 'X' AND
     x_shbv EQ 'X'.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_begbal
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            kunnr IN so_kunnr   AND
            gsber IN so_gsber   AND
            umskz IN so_umskz   AND
            budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
            waers EQ pa_waers   AND
            blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              umskz IN so_umskz   AND
              budat LT va_gerdat1 AND
*                augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              umskz IN so_umskz   AND
              budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.
  ENDIF.

  IF x_norm EQ 'X' AND
     x_shbv EQ space.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_begbal
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            umskz EQ space      AND
            kunnr IN so_kunnr   AND
            gsber IN so_gsber   AND
            budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
            waers EQ pa_waers   AND
            blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz EQ space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LT va_gerdat1 AND
*                augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz EQ space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.

    IF sy-subrc NE 0.
      LOOP AT i_itab INTO wa_itab.
        wa_itab-dmbtr  = 0.
        wa_itab-dmbtr1 = 0.
        wa_itab-dmbtr2 = 0.
        wa_itab-dmbtr3 = 0.
        wa_itab-dmbtr4 = 0.
        wa_itab-dmbtr5 = 0.
        APPEND wa_itab TO i_begbal.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF x_norm EQ space AND
     x_shbv EQ 'X'   AND
     so_umskz EQ space.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_begbal
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            umskz NE space      AND
            kunnr IN so_kunnr   AND
            gsber IN so_gsber   AND
            budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
            waers EQ pa_waers   AND
            blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz NE space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LT va_gerdat1 AND
*                augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              umskz NE space      AND
              kunnr IN so_kunnr   AND
              gsber IN so_gsber   AND
              budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.

    IF sy-subrc NE 0.
      LOOP AT i_itab INTO wa_itab.
        wa_itab-dmbtr  = 0.
        wa_itab-dmbtr1 = 0.
        wa_itab-dmbtr2 = 0.
        wa_itab-dmbtr3 = 0.
        wa_itab-dmbtr4 = 0.
        wa_itab-dmbtr5 = 0.
        APPEND wa_itab TO i_begbal.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF x_norm EQ space AND
     x_shbv EQ 'X'   AND
     so_umskz NE space.
    SELECT *
      FROM bsid
      INTO CORRESPONDING FIELDS OF TABLE i_begbal
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            kunnr IN so_kunnr   AND
            umskz IN so_umskz   AND
            gsber IN so_gsber   AND
            budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
            waers EQ pa_waers   AND
            blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').

    IF pa_bukrs = '8220'.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              umskz IN so_umskz   AND
              gsber IN so_gsber   AND
              budat LT va_gerdat1 AND
*                augdt LE va_gerdat3 AND
              augdt BETWEEN va_gerdat1 AND va_gerdat3 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
    ELSE.
      SELECT *
        FROM bsad
        APPENDING CORRESPONDING FIELDS OF TABLE i_begbal
        WHERE bukrs EQ pa_bukrs   AND
              hkont IN so_hkont   AND
              kunnr IN so_kunnr   AND
              umskz IN so_umskz   AND
              gsber IN so_gsber   AND
              budat LT va_gerdat1 AND
*            bldat LT va_gerdat1 AND
              augdt GE va_gerdat1 AND
*            AUGDT LT VA_GERDAT2 AND
              waers EQ pa_waers   AND
              blart IN s_blart.
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC').
    ENDIF.

    IF sy-subrc NE 0.
      LOOP AT i_itab INTO wa_itab.
        wa_itab-dmbtr  = 0.
        wa_itab-dmbtr1 = 0.
        wa_itab-dmbtr2 = 0.
        wa_itab-dmbtr3 = 0.
        wa_itab-dmbtr4 = 0.
        wa_itab-dmbtr5 = 0.
        APPEND wa_itab TO i_begbal.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_DATA_RADIO2

*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data.
  DATA: jatuh_tempo TYPE i,
        l_gstid(6).

  APPEND LINES OF i_itab TO i_itab_ab.
  DELETE i_itab_ab WHERE blart NE 'AB'.
  SORT i_itab_ab BY augbl gsber kunnr.

  APPEND LINES OF i_itab TO i_itab_rv.
  DELETE i_itab_rv WHERE blart NE 'RV'.
  SORT i_itab_rv BY augbl gsber kunnr.

  APPEND LINES OF i_itab TO i_itab_dr.
  DELETE i_itab_dr WHERE blart NE 'DR'.
  SORT i_itab_dr BY augbl gsber kunnr.

  APPEND LINES OF i_itab TO i_itab_da.
  DELETE i_itab_da WHERE blart NE 'DA'.
  SORT i_itab_da BY augbl gsber kunnr.

  APPEND LINES OF i_itab TO i_itab_za.
  DELETE i_itab_za WHERE blart NE 'ZA'.
  SORT i_itab_za BY augbl gsber kunnr.

  APPEND LINES OF i_itab TO i_itab_sa.
  DELETE i_itab_sa WHERE blart NE 'SA'.
  SORT i_itab_sa BY augbl gsber kunnr.

  APPEND LINES OF i_itab TO i_itab_dg.
  DELETE i_itab_dg WHERE blart NE 'DG'.
  SORT i_itab_dg BY augbl gsber kunnr.

*** Modify By Budi 10/03/2006
  APPEND LINES OF i_itab TO i_itab_d1.
  DELETE i_itab_d1 WHERE blart NE 'D1'.
  SORT i_itab_d1 BY augbl gsber kunnr.

  APPEND LINES OF i_itab TO i_itab_dz.
  DELETE i_itab_dz WHERE blart NE 'DZ'.
  SORT i_itab_dz BY augbl gsber kunnr.
*** End Modify

  APPEND LINES OF i_itab TO i_itab_zc.
  DELETE i_itab_zc WHERE blart NE 'ZC'.
  SORT i_itab_zc BY augbl gsber kunnr.

  APPEND LINES OF i_itab TO i_itab_zi.
  DELETE i_itab_zi WHERE blart NE 'ZI'.
  SORT i_itab_zi BY augbl gsber kunnr.

  APPEND LINES OF i_itab TO i_itab_zk.
  DELETE i_itab_zk WHERE blart NE 'ZK'.
  SORT i_itab_zk BY augbl gsber kunnr.

  CLEAR: wa_itab.
*  SORT i_itab BY gsber kunnr augbl.
  SORT i_itab. "BY gsber kunnr augbl. "Modify By sol_jonhar 01/10/2020
  DESCRIBE TABLE i_itab LINES jatuh_tempo.
  LOOP AT i_itab INTO wa_itab.
    SELECT SINGLE name1 brsch
      FROM kna1
      INTO (wa_itab-name1, wa_itab-brsch)
      WHERE kunnr EQ wa_itab-kunnr.

* Kondisi khusus di ER
    IF pa_bukrs = '8220'.
* cuma ada pembayaran dan kelebihan bayar
      IF sy-tabix = 1 AND jatuh_tempo = 1 AND
         wa_itab-blart = 'DZ'.
        wa_itab-blart = 'RV'.
        CLEAR wa_itab-dmbtr.
      ENDIF.
      IF wa_itab-hkont <> '0121150104' AND
        wa_itab-hkont <> '0121150102' AND
        wa_itab-hkont <> '0122350602' AND
        wa_itab-hkont <> '0122350603'.
        IF wa_itab-blart = 'DZ' OR ( wa_itab-augbl <> '' AND  wa_itab-augdt <= pa_gstid ).
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.

    PERFORM get_date_dz.

    IF wa_itab-augbl NE space.
      wa_itab-zfbdt = wa_itab-augdt.
      PERFORM f_collect_clearing USING wa_itab.
    ENDIF.

    IF pa_bukrs = '8220'.
      jatuh_tempo = pa_gstid - wa_itab-zfbdt.
    ELSE.
*** Modify By Budi 10/03/2006
*      JATUH_TEMPO = PA_GSTID - WA_ITAB-ZFBDT.
      jatuh_tempo = pa_gstid - wa_itab-bldat.
*** End Modify
    ENDIF.
    jatuh_tempo = jatuh_tempo - wa_itab-zbd1t.

    IF jatuh_tempo > int4low.
      MOVE space         TO wa_itab-current.
      MOVE space         TO wa_itab-dmbtr1.
      MOVE space         TO wa_itab-dmbtr2.
      MOVE space         TO wa_itab-dmbtr3.
      MOVE space         TO wa_itab-dmbtr4.
      MOVE wa_itab-dmbtr TO wa_itab-dmbtr5.
*** Modify By Budi 10/03/2006
      wa_itab-dmbtr5 = wa_itab-dmbtr5 - va_dmbtr.
*** End Modify
    ENDIF.
    IF jatuh_tempo > int3low AND
       jatuh_tempo <= int4low.
      MOVE space         TO wa_itab-current.
      MOVE space         TO wa_itab-dmbtr1.
      MOVE space         TO wa_itab-dmbtr2.
      MOVE space         TO wa_itab-dmbtr3.
      MOVE wa_itab-dmbtr TO wa_itab-dmbtr4.
      MOVE space         TO wa_itab-dmbtr5.
*** Modify By Budi 10/03/2006
      wa_itab-dmbtr4 = wa_itab-dmbtr4 - va_dmbtr.
*** End Modify
    ENDIF.
    IF jatuh_tempo > int2low AND
       jatuh_tempo <= int3low.
      MOVE space         TO wa_itab-current.
      MOVE space         TO wa_itab-dmbtr1.
      MOVE space         TO wa_itab-dmbtr2.
      MOVE wa_itab-dmbtr TO wa_itab-dmbtr3.
      MOVE space         TO wa_itab-dmbtr4.
      MOVE space         TO wa_itab-dmbtr5.
*** Modify By Budi 10/03/2006
      wa_itab-dmbtr3 = wa_itab-dmbtr3 - va_dmbtr.
*** End Modify
    ENDIF.
    IF jatuh_tempo > int1low AND
       jatuh_tempo <= int2low.
      MOVE space         TO wa_itab-current.
      MOVE space         TO wa_itab-dmbtr1.
      MOVE wa_itab-dmbtr TO wa_itab-dmbtr2.
      MOVE space         TO wa_itab-dmbtr3.
      MOVE space         TO wa_itab-dmbtr4.
      MOVE space         TO wa_itab-dmbtr5.
*** Modify By Budi 10/03/2006
      wa_itab-dmbtr2 = wa_itab-dmbtr2 - va_dmbtr.
*** End Modify
    ENDIF.
    IF jatuh_tempo >= 1 AND
       jatuh_tempo <= int1low.
      MOVE space         TO wa_itab-current.
      MOVE wa_itab-dmbtr TO wa_itab-dmbtr1.
      MOVE space         TO wa_itab-dmbtr2.
      MOVE space         TO wa_itab-dmbtr3.
      MOVE space         TO wa_itab-dmbtr4.
      MOVE space         TO wa_itab-dmbtr5.
*** Modify By Budi 10/03/2006
      wa_itab-dmbtr1 = wa_itab-dmbtr1 - va_dmbtr.
*** End Modify
    ENDIF.
    IF jatuh_tempo < 1.
      MOVE wa_itab-dmbtr TO wa_itab-current.
      MOVE space         TO wa_itab-dmbtr1.
      MOVE space         TO wa_itab-dmbtr2.
      MOVE space         TO wa_itab-dmbtr3.
      MOVE space         TO wa_itab-dmbtr4.
      MOVE space         TO wa_itab-dmbtr5.
*** Modify By Budi 10/03/2006
      wa_itab-current = wa_itab-current - va_dmbtr.
*** End Modify
    ENDIF.

*** Modify By Budi 10/03/2006
    IF NOT va_clear IS INITIAL AND wa_itab-blart = 'DZ'.
      MOVE space TO wa_itab-current.
      MOVE space TO wa_itab-dmbtr1.
      MOVE space TO wa_itab-dmbtr2.
      MOVE space TO wa_itab-dmbtr3.
      MOVE space TO wa_itab-dmbtr4.
      MOVE space TO wa_itab-dmbtr5.
    ENDIF.
*** End Modify

    MOVE wa_itab-zbd1t TO wa_itab-zbd1tx.

    MODIFY i_itab FROM wa_itab.
    CLEAR: wa_itab.
  ENDLOOP.

  SORT i_augbl BY augbl.

  CLEAR: wa_begbal.
*  SORT i_begbal BY gsber.
  SORT i_begbal." BY gsber. "Modify By sol_jonhar 01/10/2020
  LOOP AT i_begbal INTO wa_begbal.

    SELECT SINGLE name1 brsch
      FROM kna1
      INTO (wa_begbal-name1, wa_begbal-brsch)
      WHERE kunnr EQ wa_begbal-kunnr.

    IF wa_begbal-brsch IN so_brsch.
      MODIFY i_begbal FROM wa_begbal TRANSPORTING name1 brsch.
      IF wa_begbal-shkzg EQ 'S'.
        ADD wa_begbal-dmbtr TO wa_gsber-begbal.
      ELSE.
        wa_gsber-begbal = wa_gsber-begbal - wa_begbal-dmbtr.
      ENDIF.
    ENDIF.

    AT END OF gsber.
      SELECT SINGLE gtext
        FROM tgsbt
        INTO wa_gsber-gtext
        WHERE gsber EQ wa_begbal-gsber.
      MOVE wa_begbal-gsber TO wa_gsber-gsber.
      APPEND wa_gsber TO i_gsber.
      CLEAR: wa_gsber-begbal.
    ENDAT.
    CLEAR: wa_begbal.
  ENDLOOP.

  DELETE i_itab WHERE NOT brsch IN so_brsch.
  DELETE i_begbal WHERE NOT brsch IN so_brsch.

  CLEAR: wa_itab.
*  SORT i_itab BY gsber.
  SORT i_itab." BY gsber. "Modify By sol_jonhar 01/10/2020
  LOOP AT i_itab INTO wa_itab.

    IF wa_itab-shkzg EQ 'S'.
      ADD wa_itab-current TO va_current.
      ADD wa_itab-dmbtr1 TO va_dmbtr1.
      ADD wa_itab-dmbtr2 TO va_dmbtr2.
      ADD wa_itab-dmbtr3 TO va_dmbtr3.
      ADD wa_itab-dmbtr4 TO va_dmbtr4.
      ADD wa_itab-dmbtr5 TO va_dmbtr5.
    ELSE.
      va_current = va_current - wa_itab-current.
      va_dmbtr1 = va_dmbtr1 - wa_itab-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_itab-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_itab-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_itab-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_itab-dmbtr5.
    ENDIF.

    CONCATENATE wa_itab-gjahr wa_itab-monat INTO l_gstid.

*    IF WA_ITAB-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_itab-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_itab-blart NE 'DZ'.
      IF wa_itab-shkzg EQ 'S'.
        ADD wa_itab-dmbtr TO va_netsales.
      ELSE.
        va_netsales = va_netsales - wa_itab-dmbtr.
      ENDIF.
    ENDIF.

*    IF WA_ITAB-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_itab-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_itab-blart EQ 'DZ'.
      IF wa_itab-shkzg EQ 'S'.
        ADD wa_itab-dmbtr TO va_payment.
      ELSE.
        va_payment = va_payment - wa_itab-dmbtr.
      ENDIF.
    ENDIF.

    AT END OF gsber.
      CLEAR: wa_gsber.
*      SORT i_gsber BY gsber.
      SORT i_gsber." BY gsber. "Modify By sol_jonhar 01/10/2020
      LOOP AT i_gsber INTO wa_gsber
        WHERE gsber EQ wa_itab-gsber.
        wa_gsber-endbal = wa_gsber-begbal + va_netsales + va_payment.
        MOVE va_netsales TO wa_gsber-netsales.
        MOVE va_payment  TO wa_gsber-payment.
        MOVE va_current  TO wa_gsber-current.
        MOVE va_dmbtr1   TO wa_gsber-dmbtr1.
        MOVE va_dmbtr2   TO wa_gsber-dmbtr2.
        MOVE va_dmbtr3   TO wa_gsber-dmbtr3.
        MOVE va_dmbtr4   TO wa_gsber-dmbtr4.
        MOVE va_dmbtr5   TO wa_gsber-dmbtr5.
        MODIFY i_gsber FROM wa_gsber.
        CLEAR: wa_gsber, va_netsales, va_payment, va_current,
               va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
      ENDLOOP.

      IF sy-subrc NE 0.
        wa_gsber-endbal = wa_gsber-begbal + va_netsales + va_payment.
        SELECT SINGLE gtext
          FROM tgsbt
          INTO wa_gsber-gtext
          WHERE gsber EQ wa_itab-gsber.
        MOVE wa_itab-gsber TO wa_gsber-gsber.
        MOVE va_netsales   TO wa_gsber-netsales.
        MOVE va_payment    TO wa_gsber-payment.
        MOVE va_current    TO wa_gsber-current.
        MOVE va_dmbtr1     TO wa_gsber-dmbtr1.
        MOVE va_dmbtr2     TO wa_gsber-dmbtr2.
        MOVE va_dmbtr3     TO wa_gsber-dmbtr3.
        MOVE va_dmbtr4     TO wa_gsber-dmbtr4.
        MOVE va_dmbtr5     TO wa_gsber-dmbtr5.
        APPEND wa_gsber TO i_gsber.
      ENDIF.
      CLEAR: wa_gsber-netsales.
*** Modify By Budi 10/03/2006
      CLEAR: va_netsales, va_payment, va_current, va_dmbtr1,
             va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
*** End Modify
    ENDAT.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  KUNNR_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM kunnr_process.
  CLEAR: wa_begbal.
  REFRESH i_kunnr.
  LOOP AT i_begbal INTO wa_begbal
    WHERE gsber EQ tgsbt-gsber  AND
          kunnr IN so_kunnr.
    MOVE wa_begbal-belnr  TO wa_kunnr-belnr.
    MOVE wa_begbal-gjahr  TO wa_kunnr-gjahr.
    MOVE wa_begbal-gsber  TO wa_kunnr-gsber.
    MOVE wa_begbal-kunnr  TO wa_kunnr-kunnr.
    MOVE wa_begbal-shkzg  TO wa_kunnr-shkzg.
    MOVE wa_begbal-monat  TO wa_kunnr-monat.
    MOVE wa_begbal-blart  TO wa_kunnr-blart.
    MOVE wa_begbal-dmbtr  TO wa_kunnr-begbal.
*** Modify By Budi 10/03/2006
    MOVE wa_begbal-budat  TO wa_kunnr-budat.
*** End Modify
    PERFORM f_get_modify USING wa_kunnr-kunnr wa_kunnr-gjahr wa_kunnr-belnr 'PROC'
                         CHANGING wa_kunnr-objkey.

    APPEND wa_kunnr TO i_kunnr.
    CLEAR: wa_begbal.
  ENDLOOP.

  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE gsber EQ tgsbt-gsber AND
          kunnr IN so_kunnr.
    MOVE wa_itab-belnr    TO wa_kunnr-belnr.
    MOVE wa_itab-gjahr    TO wa_kunnr-gjahr.
    MOVE wa_itab-gsber    TO wa_kunnr-gsber.
    MOVE wa_itab-kunnr    TO wa_kunnr-kunnr.
    MOVE wa_itab-shkzg    TO wa_kunnr-shkzg.
    MOVE wa_itab-gjahr    TO wa_kunnr-gjahr.
    MOVE wa_itab-monat    TO wa_kunnr-monat.
    MOVE wa_itab-blart    TO wa_kunnr-blart.
    MOVE wa_itab-current  TO wa_kunnr-current.
    MOVE wa_itab-dmbtr    TO wa_kunnr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_kunnr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_kunnr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_kunnr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_kunnr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_kunnr-dmbtr5.
    wa_kunnr-begbal = 0.
*** Modify By Budi 10/03/2006
    MOVE wa_itab-budat  TO wa_kunnr-budat.
*** End Modify

    PERFORM f_get_modify USING wa_kunnr-kunnr wa_kunnr-gjahr wa_kunnr-belnr 'PROC'
                         CHANGING wa_kunnr-objkey.

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_kunnr-current,wa_kunnr-dmbtr1,wa_kunnr-dmbtr2,
                 wa_kunnr-dmbtr3,wa_kunnr-dmbtr4,wa_kunnr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_kunnr-current,wa_kunnr-dmbtr1,wa_kunnr-dmbtr2,
                   wa_kunnr-dmbtr3,wa_kunnr-dmbtr4,wa_kunnr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_kunnr TO i_kunnr.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " KUNNR_PROCESS

*&---------------------------------------------------------------------*
*&      Form  ZUONR_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zuonr_process.
  CLEAR: wa_begbal.
  REFRESH i_zuonr.

  DATA: lv_sort(25).

  PERFORM f_get_modify USING va_kunnr va_gjahr1 va_belnr 'ZUONR'
                       CHANGING lv_sort.

  IF lv_sort EQ 'ZONT' OR
    lv_sort EQ 'ONTV'.
    LOOP AT i_begbal INTO wa_begbal
      WHERE gsber EQ tgsbt-gsber AND
            kunnr EQ va_kunnr    AND
            belnr EQ va_belnr    AND
            gjahr EQ va_gjahr1.
      MOVE wa_begbal-gsber  TO wa_zuonr-gsber.
      MOVE wa_begbal-kunnr  TO wa_zuonr-kunnr.
      MOVE wa_begbal-shkzg  TO wa_zuonr-shkzg.
      MOVE wa_begbal-monat  TO wa_zuonr-monat.
      MOVE wa_begbal-blart  TO wa_zuonr-blart.
      MOVE wa_begbal-zuonr  TO wa_zuonr-zuonr.
      MOVE wa_begbal-augbl  TO wa_zuonr-augbl.
      MOVE wa_begbal-dmbtr  TO wa_zuonr-begbal.
      MOVE wa_begbal-belnr  TO wa_zuonr-belnr.
      MOVE wa_begbal-gjahr  TO wa_zuonr-gjahr.
*** Modify By Budi 10/03/2006
      MOVE wa_begbal-budat  TO wa_zuonr-budat.
*** End Modify
      APPEND wa_zuonr TO i_zuonr.
      CLEAR: wa_begbal.
    ENDLOOP.

    CLEAR: wa_itab.
    LOOP AT i_itab INTO wa_itab
      WHERE gsber EQ tgsbt-gsber AND
            kunnr EQ va_kunnr    AND
            belnr EQ va_belnr    AND
            gjahr EQ va_gjahr1.
      MOVE wa_itab-gsber    TO wa_zuonr-gsber.
      MOVE wa_itab-kunnr    TO wa_zuonr-kunnr.
      MOVE wa_itab-shkzg    TO wa_zuonr-shkzg.
      MOVE wa_itab-gjahr    TO wa_zuonr-gjahr.
      MOVE wa_itab-monat    TO wa_zuonr-monat.
      MOVE wa_itab-blart    TO wa_zuonr-blart.
      MOVE wa_itab-zuonr    TO wa_zuonr-zuonr.
      MOVE wa_itab-augbl    TO wa_zuonr-augbl.
      MOVE wa_itab-current  TO wa_zuonr-current.
      MOVE wa_itab-dmbtr    TO wa_zuonr-dmbtr.
      MOVE wa_itab-dmbtr1   TO wa_zuonr-dmbtr1.
      MOVE wa_itab-dmbtr2   TO wa_zuonr-dmbtr2.
      MOVE wa_itab-dmbtr3   TO wa_zuonr-dmbtr3.
      MOVE wa_itab-dmbtr4   TO wa_zuonr-dmbtr4.
      MOVE wa_itab-dmbtr5   TO wa_zuonr-dmbtr5.
      MOVE wa_itab-belnr    TO wa_zuonr-belnr.
      MOVE wa_itab-gjahr    TO wa_zuonr-gjahr.
      wa_zuonr-begbal = 0.
*** Modify By Budi 10/03/2006
      MOVE wa_itab-budat  TO wa_zuonr-budat.
*** End Modify
      APPEND wa_zuonr TO i_zuonr.
      CLEAR: wa_itab.
    ENDLOOP.
  ELSE.
    LOOP AT i_begbal INTO wa_begbal
      WHERE gsber EQ tgsbt-gsber AND
            kunnr EQ va_kunnr.
      MOVE wa_begbal-gsber  TO wa_zuonr-gsber.
      MOVE wa_begbal-kunnr  TO wa_zuonr-kunnr.
      MOVE wa_begbal-shkzg  TO wa_zuonr-shkzg.
      MOVE wa_begbal-monat  TO wa_zuonr-monat.
      MOVE wa_begbal-blart  TO wa_zuonr-blart.
      MOVE wa_begbal-zuonr  TO wa_zuonr-zuonr.
      MOVE wa_begbal-augbl  TO wa_zuonr-augbl.
      MOVE wa_begbal-dmbtr  TO wa_zuonr-begbal.
      MOVE wa_begbal-belnr  TO wa_zuonr-belnr.
      MOVE wa_begbal-gjahr  TO wa_zuonr-gjahr.
*** Modify By Budi 10/03/2006
      MOVE wa_begbal-budat  TO wa_zuonr-budat.
*** End Modify
      APPEND wa_zuonr TO i_zuonr.
      CLEAR: wa_begbal.
    ENDLOOP.

    CLEAR: wa_itab.
    LOOP AT i_itab INTO wa_itab
      WHERE gsber EQ tgsbt-gsber AND
            kunnr EQ va_kunnr.
      MOVE wa_itab-gsber    TO wa_zuonr-gsber.
      MOVE wa_itab-kunnr    TO wa_zuonr-kunnr.
      MOVE wa_itab-shkzg    TO wa_zuonr-shkzg.
      MOVE wa_itab-gjahr    TO wa_zuonr-gjahr.
      MOVE wa_itab-monat    TO wa_zuonr-monat.
      MOVE wa_itab-blart    TO wa_zuonr-blart.
      MOVE wa_itab-zuonr    TO wa_zuonr-zuonr.
      MOVE wa_itab-augbl    TO wa_zuonr-augbl.
      MOVE wa_itab-current  TO wa_zuonr-current.
      MOVE wa_itab-dmbtr    TO wa_zuonr-dmbtr.
      MOVE wa_itab-dmbtr1   TO wa_zuonr-dmbtr1.
      MOVE wa_itab-dmbtr2   TO wa_zuonr-dmbtr2.
      MOVE wa_itab-dmbtr3   TO wa_zuonr-dmbtr3.
      MOVE wa_itab-dmbtr4   TO wa_zuonr-dmbtr4.
      MOVE wa_itab-dmbtr5   TO wa_zuonr-dmbtr5.
      MOVE wa_itab-belnr    TO wa_zuonr-belnr.
      MOVE wa_itab-gjahr    TO wa_zuonr-gjahr.
      wa_zuonr-begbal = 0.
*** Modify By Budi 10/03/2006
      MOVE wa_itab-budat  TO wa_zuonr-budat.
*** End Modify
      APPEND wa_zuonr TO i_zuonr.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " ZUONR_PROCESS

*&---------------------------------------------------------------------*
*&      Form  CETAK_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_header.
  DATA: l_butxt LIKE t001-butxt.

  FORMAT INTENSIFIED ON.
  SELECT SINGLE butxt
    FROM t001
    INTO l_butxt
    WHERE bukrs EQ pa_bukrs.

  PERFORM bulan.

  WRITE: /    l_butxt,
          107 'AR AGING REPORT',
          190 'Printing Date :', sy-datum, '-', sy-uzeit.
  WRITE: /    'Currency      :', va_currency,
          97  'Period  :', va_period, '-', pa_gstid.
ENDFORM.                    " CETAK_HEADER

*&---------------------------------------------------------------------*
*&      Form  CETAK_GSBER_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_gsber_header.
  CONCATENATE '<' int1low 'Hari' INTO text1
    SEPARATED BY space.
  CONCATENATE int1low '-' int2low 'Hari' INTO text2
    SEPARATED BY space.
  CONCATENATE int2low '-' int3low 'Hari' INTO text3
    SEPARATED BY space.
  CONCATENATE int3low '-' int4low 'Hari' INTO text4
    SEPARATED BY space.
  CONCATENATE '>' int4low 'Hari' INTO text5
    SEPARATED BY space.

  FORMAT COLOR 1.
  WRITE: /    sy-uline(219).
  WRITE: /    sy-vline, 'Business area', 29 sy-vline NO-GAP.
  SET LEFT SCROLL-BOUNDARY.
  WRITE:     'Beginning Balance',
              sy-vline, 'Net Sales',
          67  sy-vline, 'Payment',
          86  sy-vline, 'Ending Balance',
          105 sy-vline, 'Current',
          124 sy-vline, text1,
              sy-vline, text2,
              sy-vline, text3,
              sy-vline, text4,
              sy-vline, text5,
          219 sy-vline.
  WRITE: /    sy-uline(219).
  FORMAT COLOR OFF.
ENDFORM.                    " CETAK_GSBER_HEADER

*&---------------------------------------------------------------------*
*&      Form  CETAK_HEADER_KUNNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_header_kunnr.
  PERFORM cetak_header.
*** Modify By Budi 10/03/2006
  IF va_count NE 0.
    va_gtext = 'ALL'.
  ENDIF.
*** End Modify
  WRITE: /    'Business Area :', va_gtext.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'No. Cust.', '-', 'Customer Name',
           40 sy-vline NO-GAP.
  SET LEFT SCROLL-BOUNDARY.
  WRITE:     'Beginning Balance',
              sy-vline, 'Net Sales',
          78  sy-vline, 'Payment',
          97  sy-vline, 'Ending Balance',
          116 sy-vline, 'Current',
          135 sy-vline, text1,
              sy-vline, text2,
              sy-vline, text3,
              sy-vline, text4,
              sy-vline, text5,
          230 sy-vline.
  WRITE: /    sy-uline(230).
  FORMAT COLOR OFF.
ENDFORM.                    " CETAK_HEADER_KUNNR

*&---------------------------------------------------------------------*
*&      Form  CETAK_HEADER_ZUONR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_header_zuonr.
  PERFORM cetak_header.

*  SELECT SINGLE NAME1
*    FROM KNA1
*    INTO VA_NAME1
*    WHERE KUNNR EQ VA_KUNNR.

  WRITE: /    'Business Area :', va_gtext.
  IF radio3 EQ 'X'.
    WRITE: /    'Customer Name :', va_kunnr, '-', va_name1.
  ELSEIF radio4 EQ 'X'.
    WRITE: /    'Industry Key  :', va_brsch, '-', va_brtxt.
  ELSEIF radio5 EQ 'X'.
    WRITE: /    'Account Name  :', va_hkont, '-', va_txt20.
  ENDIF.
  FORMAT COLOR 1.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(232).
  WRITE: /    sy-vline, 'Invoice Number',
          29  sy-vline, 'Clrng doc.', sy-vline NO-GAP.
  SET LEFT SCROLL-BOUNDARY.
  WRITE:      'Beginning Balance',
              sy-vline, 'Net Sales',
          80  sy-vline, 'Payment',
          99  sy-vline, 'Ending Balance',
          118 sy-vline, 'Current',
          137 sy-vline, text1,
              sy-vline, text2,
              sy-vline, text3,
              sy-vline, text4,
              sy-vline, text5,
          232 sy-vline.
  WRITE: /    sy-uline(232).
  FORMAT COLOR OFF.
ENDFORM.                    " CETAK_HEADER_ZUONR

*&---------------------------------------------------------------------*
*&      Form  CETAK_GSBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_gsber.
  DATA: zebra TYPE i.

  zebra = 0.
  va_count = 0.

  PERFORM cetak_header.
  PERFORM cetak_gsber_header.

  CLEAR: wa_gsber.
  SORT i_gsber BY gsber.
  LOOP AT i_gsber INTO wa_gsber.
    IF zebra = 0.
      FORMAT INTENSIFIED OFF.
      FORMAT COLOR 2.
      zebra = 1.
    ELSE.
      FORMAT COLOR 1.
      zebra = 0.
    ENDIF.
    MOVE wa_gsber-gtext TO va_gtext.
    WRITE: /    sy-vline, va_gtext,
                sy-vline, wa_gsber-begbal CURRENCY va_currency,
                sy-vline, wa_gsber-netsales CURRENCY va_currency,
                sy-vline, wa_gsber-payment CURRENCY va_currency,
                sy-vline, wa_gsber-endbal CURRENCY va_currency,
                sy-vline, wa_gsber-current CURRENCY va_currency,
                sy-vline, wa_gsber-dmbtr1 CURRENCY va_currency,
                sy-vline, wa_gsber-dmbtr2 CURRENCY va_currency,
                sy-vline, wa_gsber-dmbtr3 CURRENCY va_currency,
                sy-vline, wa_gsber-dmbtr4 CURRENCY va_currency,
                sy-vline, wa_gsber-dmbtr5 CURRENCY va_currency,
                sy-vline.

    ADD wa_gsber-begbal   TO total_begbal.
    ADD wa_gsber-netsales TO total_netsales.
    ADD wa_gsber-payment  TO total_payment.
    ADD wa_gsber-endbal   TO total_endbal.
    ADD wa_gsber-current  TO total_current.
    ADD wa_gsber-dmbtr1   TO total_dmbtr1.
    ADD wa_gsber-dmbtr2   TO total_dmbtr2.
    ADD wa_gsber-dmbtr3   TO total_dmbtr3.
    ADD wa_gsber-dmbtr4   TO total_dmbtr4.
    ADD wa_gsber-dmbtr5   TO total_dmbtr5.
    CLEAR: wa_gsber.
  ENDLOOP.
  FORMAT COLOR 3.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(219).
  WRITE: /    sy-vline, 'Total',
          29  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_netsales CURRENCY va_currency,
              sy-vline, total_payment CURRENCY va_currency,
              sy-vline, total_endbal CURRENCY va_currency,
              sy-vline, total_current CURRENCY va_currency,
              sy-vline, total_dmbtr1 CURRENCY va_currency,
              sy-vline, total_dmbtr2 CURRENCY va_currency,
              sy-vline, total_dmbtr3 CURRENCY va_currency,
              sy-vline, total_dmbtr4 CURRENCY va_currency,
              sy-vline, total_dmbtr5 CURRENCY va_currency,
              sy-vline.
  WRITE: /    sy-uline(219).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED OFF.
  CLEAR: total_begbal, total_netsales, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.
ENDFORM.                    " CETAK_GSBER

*&---------------------------------------------------------------------*
*&      Form  CETAK_DETAIL_KUNNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_detail_kunnr USING fu_sort.
  DATA: zebra TYPE i,
        l_gstid(6).

  DATA: lv_belnr  TYPE bsid-belnr,
        lv_gjahr  TYPE bsid-gjahr,
        lv_kunnr  TYPE bsid-kunnr.

  CLEAR: l_gstid.
  zebra = 0.

  PERFORM cetak_header_kunnr.

  CLEAR: wa_kunnr.

  CASE fu_sort.
    WHEN '1'.
      SORT i_kunnr BY objkey kunnr.
    WHEN '2'.
      SORT i_kunnr BY kunnr.
      PERFORM f_modify_objkey_kunnr.
  ENDCASE.

*** Modify By Budi 10/03/2006
  IF va_ucomm = 'ALL'.
    LOOP AT i_kunnr INTO wa_kunnr.
      IF wa_kunnr-shkzg EQ 'S'.
        ADD wa_kunnr-begbal TO va_begbal.
        ADD wa_kunnr-current TO va_current.
        ADD wa_kunnr-dmbtr1 TO va_dmbtr1.
        ADD wa_kunnr-dmbtr2 TO va_dmbtr2.
        ADD wa_kunnr-dmbtr3 TO va_dmbtr3.
        ADD wa_kunnr-dmbtr4 TO va_dmbtr4.
        ADD wa_kunnr-dmbtr5 TO va_dmbtr5.
      ELSE.
        va_begbal = va_begbal - wa_kunnr-begbal.
        va_current = va_current - wa_kunnr-current.
        va_dmbtr1 = va_dmbtr1 - wa_kunnr-dmbtr1.
        va_dmbtr2 = va_dmbtr2 - wa_kunnr-dmbtr2.
        va_dmbtr3 = va_dmbtr3 - wa_kunnr-dmbtr3.
        va_dmbtr4 = va_dmbtr4 - wa_kunnr-dmbtr4.
        va_dmbtr5 = va_dmbtr5 - wa_kunnr-dmbtr5.
      ENDIF.

      CONCATENATE wa_kunnr-gjahr wa_kunnr-monat INTO l_gstid.

*    IF WA_KUNNR-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*      IF L_GSTID EQ PA_GSTID(6) AND
      IF wa_kunnr-budat(6) EQ pa_gstid(6) AND
*** End Modify
         wa_kunnr-blart NE 'DZ'.
        IF wa_kunnr-shkzg EQ 'S'.
          ADD wa_kunnr-dmbtr TO va_netsales.
        ELSE.
          va_netsales = va_netsales - wa_kunnr-dmbtr.
        ENDIF.
      ENDIF.

*    IF WA_KUNNR-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*      IF L_GSTID EQ PA_GSTID(6) AND
      IF wa_kunnr-budat(6) EQ pa_gstid(6) AND
*** End Modify
         wa_kunnr-blart EQ 'DZ'.
        IF wa_kunnr-shkzg EQ 'S'.
          ADD wa_kunnr-dmbtr TO va_payment.
        ELSE.
          va_payment = va_payment - wa_kunnr-dmbtr.
        ENDIF.
      ENDIF.

      lv_kunnr  = wa_kunnr-kunnr.
      lv_belnr  = wa_kunnr-belnr.
      lv_gjahr  = wa_kunnr-gjahr.

      AT END OF objkey.
        IF zebra = 0.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 2.
          zebra = 1.
        ELSE.
          FORMAT COLOR 1.
          zebra = 0.
        ENDIF.

        PERFORM f_get_modify USING lv_kunnr lv_gjahr lv_belnr 'PRINT'
                             CHANGING va_name1.

        va_endbal = va_begbal + va_netsales + va_payment.
        ADD va_begbal   TO total_begbal.
        ADD va_netsales TO total_netsales.
        ADD va_payment  TO total_payment.
        ADD va_endbal   TO total_endbal.
        ADD va_current  TO total_current.
        ADD va_dmbtr1   TO total_dmbtr1.
        ADD va_dmbtr2   TO total_dmbtr2.
        ADD va_dmbtr3   TO total_dmbtr3.
        ADD va_dmbtr4   TO total_dmbtr4.
        ADD va_dmbtr5   TO total_dmbtr5.

        WRITE va_begbal TO va_begbal1 CURRENCY va_currency.
        MOVE lv_kunnr TO va_kunnr.

        IF va_begbal   NE 0 OR
           va_netsales NE 0 OR
           va_payment  NE 0 OR
           va_endbal   NE 0 OR
           va_current  NE 0 OR
           va_dmbtr1   NE 0 OR
           va_dmbtr2   NE 0 OR
           va_dmbtr3   NE 0 OR
           va_dmbtr4   NE 0 OR
           va_dmbtr5   NE 0.
          WRITE: /    sy-vline NO-GAP, va_kunnr, '-', va_name1 NO-GAP,
                      sy-vline, va_begbal CURRENCY va_currency,
                      sy-vline, va_netsales CURRENCY va_currency,
                      sy-vline, va_payment CURRENCY va_currency,
                      sy-vline, va_endbal CURRENCY va_currency,
                      sy-vline, va_current CURRENCY va_currency,
                      sy-vline, va_dmbtr1 CURRENCY va_currency,
                      sy-vline, va_dmbtr2 CURRENCY va_currency,
                      sy-vline, va_dmbtr3 CURRENCY va_currency,
                      sy-vline, va_dmbtr4 CURRENCY va_currency,
                      sy-vline, va_dmbtr5 CURRENCY va_currency,
                      sy-vline.

          va_belnr   = lv_belnr.
          va_gjahr1  = lv_gjahr.
          HIDE: va_belnr, va_gjahr1.
        ENDIF.

        CLEAR: va_begbal, va_netsales, va_payment, va_endbal, va_current,
               va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
      ENDAT.
      CLEAR: wa_kunnr.
    ENDLOOP.

  ELSE.
*** End Modify

    LOOP AT i_kunnr INTO wa_kunnr
      WHERE gsber EQ tgsbt-gsber.
      IF wa_kunnr-shkzg EQ 'S'.
        ADD wa_kunnr-begbal TO va_begbal.
        ADD wa_kunnr-current TO va_current.
        ADD wa_kunnr-dmbtr1 TO va_dmbtr1.
        ADD wa_kunnr-dmbtr2 TO va_dmbtr2.
        ADD wa_kunnr-dmbtr3 TO va_dmbtr3.
        ADD wa_kunnr-dmbtr4 TO va_dmbtr4.
        ADD wa_kunnr-dmbtr5 TO va_dmbtr5.
      ELSE.
        va_begbal = va_begbal - wa_kunnr-begbal.
        va_current = va_current - wa_kunnr-current.
        va_dmbtr1 = va_dmbtr1 - wa_kunnr-dmbtr1.
        va_dmbtr2 = va_dmbtr2 - wa_kunnr-dmbtr2.
        va_dmbtr3 = va_dmbtr3 - wa_kunnr-dmbtr3.
        va_dmbtr4 = va_dmbtr4 - wa_kunnr-dmbtr4.
        va_dmbtr5 = va_dmbtr5 - wa_kunnr-dmbtr5.
      ENDIF.

      CONCATENATE wa_kunnr-gjahr wa_kunnr-monat INTO l_gstid.

*    IF WA_KUNNR-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*      IF L_GSTID EQ PA_GSTID(6) AND
      IF wa_kunnr-budat(6) EQ pa_gstid(6) AND
*** End Modify
         wa_kunnr-blart NE 'DZ'.
        IF wa_kunnr-shkzg EQ 'S'.
          ADD wa_kunnr-dmbtr TO va_netsales.
        ELSE.
          va_netsales = va_netsales - wa_kunnr-dmbtr.
        ENDIF.
      ENDIF.

*    IF WA_KUNNR-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*      IF L_GSTID EQ PA_GSTID(6) AND
      IF wa_kunnr-budat(6) EQ pa_gstid(6) AND
*** End Modify
         wa_kunnr-blart EQ 'DZ'.
        IF wa_kunnr-shkzg EQ 'S'.
          ADD wa_kunnr-dmbtr TO va_payment.
        ELSE.
          va_payment = va_payment - wa_kunnr-dmbtr.
        ENDIF.
      ENDIF.

      lv_kunnr  = wa_kunnr-kunnr.
      lv_belnr  = wa_kunnr-belnr.
      lv_gjahr  = wa_kunnr-gjahr.

      AT END OF objkey.
        IF zebra = 0.
          FORMAT INTENSIFIED OFF.
          FORMAT COLOR 2.
          zebra = 1.
        ELSE.
          FORMAT COLOR 1.
          zebra = 0.
        ENDIF.

        PERFORM f_get_modify USING lv_kunnr lv_gjahr lv_belnr 'PRINT'
                             CHANGING va_name1.

        va_endbal = va_begbal + va_netsales + va_payment.
        ADD va_begbal   TO total_begbal.
        ADD va_netsales TO total_netsales.
        ADD va_payment  TO total_payment.
        ADD va_endbal   TO total_endbal.
        ADD va_current  TO total_current.
        ADD va_dmbtr1   TO total_dmbtr1.
        ADD va_dmbtr2   TO total_dmbtr2.
        ADD va_dmbtr3   TO total_dmbtr3.
        ADD va_dmbtr4   TO total_dmbtr4.
        ADD va_dmbtr5   TO total_dmbtr5.

        WRITE va_begbal TO va_begbal1 CURRENCY va_currency.
        MOVE lv_kunnr TO va_kunnr.

        IF va_begbal   NE 0 OR
           va_netsales NE 0 OR
           va_payment  NE 0 OR
           va_endbal   NE 0 OR
           va_current  NE 0 OR
           va_dmbtr1   NE 0 OR
           va_dmbtr2   NE 0 OR
           va_dmbtr3   NE 0 OR
           va_dmbtr4   NE 0 OR
           va_dmbtr5   NE 0.
          WRITE: /    sy-vline NO-GAP, va_kunnr, '-', va_name1 NO-GAP,
                      sy-vline, va_begbal CURRENCY va_currency,
                      sy-vline, va_netsales CURRENCY va_currency,
                      sy-vline, va_payment CURRENCY va_currency,
                      sy-vline, va_endbal CURRENCY va_currency,
                      sy-vline, va_current CURRENCY va_currency,
                      sy-vline, va_dmbtr1 CURRENCY va_currency,
                      sy-vline, va_dmbtr2 CURRENCY va_currency,
                      sy-vline, va_dmbtr3 CURRENCY va_currency,
                      sy-vline, va_dmbtr4 CURRENCY va_currency,
                      sy-vline, va_dmbtr5 CURRENCY va_currency,
                      sy-vline.

          va_belnr   = lv_belnr.
          va_gjahr1  = lv_gjahr.
          HIDE: va_belnr, va_gjahr1.
        ENDIF.

        CLEAR: va_begbal, va_netsales, va_payment, va_endbal, va_current,
                  va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
      ENDAT.
      CLEAR: wa_kunnr.
    ENDLOOP.

*** Modify By Budi 10/03/2006
  ENDIF.
*** End Modify

  FORMAT COLOR 3.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'Total',
          40  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_netsales CURRENCY va_currency,
              sy-vline, total_payment CURRENCY va_currency,
              sy-vline, total_endbal CURRENCY va_currency,
              sy-vline, total_current CURRENCY va_currency,
              sy-vline, total_dmbtr1 CURRENCY va_currency,
              sy-vline, total_dmbtr2 CURRENCY va_currency,
              sy-vline, total_dmbtr3 CURRENCY va_currency,
              sy-vline, total_dmbtr4 CURRENCY va_currency,
              sy-vline, total_dmbtr5 CURRENCY va_currency,
              sy-vline.
  WRITE: /    sy-uline(230).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED OFF.
  CLEAR: total_begbal, total_netsales, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.

ENDFORM.                    " CETAK_DETAIL_KUNNR

*&---------------------------------------------------------------------*
*&      Form  CETAK_DETAIL_ZUONR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_detail_zuonr.
  DATA: zebra TYPE i,
        l_gstid(6).

  CLEAR: l_gstid.
  zebra = 0.

  PERFORM cetak_header_zuonr.

  CLEAR: wa_zuonr.
*  SORT i_zuonr BY belnr augbl zuonr.
  SORT i_zuonr." BY belnr augbl zuonr. "Modify By sol_jonhar 01/10/2020
  LOOP AT i_zuonr INTO wa_zuonr.
*    WHERE GSBER EQ TGSBT-GSBER AND
*          KUNNR EQ VA_KUNNR.

    IF wa_zuonr-shkzg EQ 'S'.
      ADD wa_zuonr-begbal TO va_begbal.
      ADD wa_zuonr-current TO va_current.
      ADD wa_zuonr-dmbtr1 TO va_dmbtr1.
      ADD wa_zuonr-dmbtr2 TO va_dmbtr2.
      ADD wa_zuonr-dmbtr3 TO va_dmbtr3.
      ADD wa_zuonr-dmbtr4 TO va_dmbtr4.
      ADD wa_zuonr-dmbtr5 TO va_dmbtr5.
    ELSE.
      va_begbal = va_begbal - wa_zuonr-begbal.
      va_current = va_current - wa_zuonr-current.
      va_dmbtr1 = va_dmbtr1 - wa_zuonr-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_zuonr-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_zuonr-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_zuonr-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_zuonr-dmbtr5.
    ENDIF.

    CONCATENATE wa_zuonr-gjahr wa_zuonr-monat INTO l_gstid.

*    IF WA_ZUONR-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_zuonr-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_zuonr-blart NE 'DZ'.
      IF wa_zuonr-shkzg EQ 'S'.
        ADD wa_zuonr-dmbtr TO va_netsales.
      ELSE.
        va_netsales = va_netsales - wa_zuonr-dmbtr.
      ENDIF.
    ENDIF.

*    IF WA_ZUONR-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_zuonr-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_zuonr-blart EQ 'DZ'.
      IF wa_zuonr-shkzg EQ 'S'.
        ADD wa_zuonr-dmbtr TO va_payment.
      ELSE.
        va_payment = va_payment - wa_zuonr-dmbtr.
      ENDIF.
    ENDIF.

    MOVE wa_zuonr-belnr TO va_belnr.
    MOVE wa_zuonr-gjahr TO va_gjahr1.
    MOVE wa_zuonr-zuonr TO va_zuonr.
    MOVE wa_zuonr-augbl TO va_augbl.

    AT END OF belnr.
      IF sy-linno EQ 59.
        FORMAT COLOR OFF.
        FORMAT INTENSIFIED OFF.
        WRITE: /    sy-uline(232).
        PERFORM cetak_header_zuonr.
        zebra = 0.
      ENDIF.

      IF zebra = 0.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT COLOR 1.
        zebra = 0.
      ENDIF.

      va_endbal = va_begbal + va_netsales + va_payment.

      IF va_augbl IS NOT INITIAL.
        READ TABLE i_augbl WITH KEY augbl = va_augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: va_endbal,va_current,va_dmbtr1,va_dmbtr2,
                   va_dmbtr3,va_dmbtr4,va_dmbtr5.
          ENDIF.
        ELSE.
          SORT i_augbl BY augbl.
          READ TABLE i_augbl WITH KEY augbl = va_augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
          IF sy-subrc = 0.
            IF i_augbl-dmbtr IS INITIAL.
              CLEAR: va_endbal,va_current,va_dmbtr1,va_dmbtr2,
                     va_dmbtr3,va_dmbtr4,va_dmbtr5.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      ADD va_begbal   TO total_begbal.
      ADD va_netsales TO total_netsales.
      ADD va_payment  TO total_payment.
      ADD va_endbal   TO total_endbal.
      ADD va_current  TO total_current.
      ADD va_dmbtr1   TO total_dmbtr1.
      ADD va_dmbtr2   TO total_dmbtr2.
      ADD va_dmbtr3   TO total_dmbtr3.
      ADD va_dmbtr4   TO total_dmbtr4.
      ADD va_dmbtr5   TO total_dmbtr5.

      IF va_begbal  NE 0 OR
        va_netsales NE 0 OR
        va_payment  NE 0 OR
        va_endbal   NE 0 OR
        va_current  NE 0 OR
        va_dmbtr1   NE 0 OR
        va_dmbtr2   NE 0 OR
        va_dmbtr3   NE 0 OR
        va_dmbtr4   NE 0 OR
        va_dmbtr5   NE 0.
        FORMAT INTENSIFIED OFF.
        WRITE: /    sy-vline, va_zuonr,
                29  sy-vline, va_augbl,
                    sy-vline, va_begbal CURRENCY va_currency,
                    sy-vline, va_netsales CURRENCY va_currency,
                    sy-vline, va_payment CURRENCY va_currency,
                    sy-vline, va_endbal CURRENCY va_currency,
                    sy-vline, va_current CURRENCY va_currency,
                    sy-vline, va_dmbtr1 CURRENCY va_currency,
                    sy-vline, va_dmbtr2 CURRENCY va_currency,
                    sy-vline, va_dmbtr3 CURRENCY va_currency,
                    sy-vline, va_dmbtr4 CURRENCY va_currency,
                    sy-vline, va_dmbtr5 CURRENCY va_currency,
                232 sy-vline.
        HIDE: va_belnr, va_gjahr1.
        CLEAR: va_begbal, va_netsales, va_payment, va_endbal,
               va_current, va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4,
               va_dmbtr5, va_augbl.
      ELSE.
        IF zebra = 0.
          zebra = 1.
        ELSE.
          zebra = 0.
        ENDIF.
      ENDIF.
    ENDAT.
    CLEAR: wa_zuonr.
  ENDLOOP.

  FORMAT COLOR 3.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(232).
  WRITE: /    sy-vline, 'Total',
          42  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_netsales CURRENCY va_currency,
              sy-vline, total_payment CURRENCY va_currency,
              sy-vline, total_endbal CURRENCY va_currency,
              sy-vline, total_current CURRENCY va_currency,
              sy-vline, total_dmbtr1 CURRENCY va_currency,
              sy-vline, total_dmbtr2 CURRENCY va_currency,
              sy-vline, total_dmbtr3 CURRENCY va_currency,
              sy-vline, total_dmbtr4 CURRENCY va_currency,
              sy-vline, total_dmbtr5 CURRENCY va_currency,
          232 sy-vline.
  WRITE: /    sy-uline(232).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED OFF.
  CLEAR: total_begbal, total_netsales, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.
ENDFORM.                    " CETAK_DETAIL_ZUONR

*&---------------------------------------------------------------------*
*&      Form  BULAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bulan.
  MOVE pa_gstid+4(2) TO va_bulan.
  MOVE pa_gstid+0(4) TO va_tahun.
  CASE va_bulan.
    WHEN '01'.
      MOVE 'JANUARI'   TO va_bulan_text.
    WHEN '02'.
      MOVE 'FEBRUARI'  TO va_bulan_text.
    WHEN '03'.
      MOVE 'MARET'     TO va_bulan_text.
    WHEN '04'.
      MOVE 'APRIL'     TO va_bulan_text.
    WHEN '05'.
      MOVE 'MEI'       TO va_bulan_text.
    WHEN '06'.
      MOVE 'JUNI'      TO va_bulan_text.
    WHEN '07'.
      MOVE 'JULI'      TO va_bulan_text.
    WHEN '08'.
      MOVE 'AGUSTUS'   TO va_bulan_text.
    WHEN '09'.
      MOVE 'SEPTEMBER' TO va_bulan_text.
    WHEN '10'.
      MOVE 'OKTOBER'   TO va_bulan_text.
    WHEN '11'.
      MOVE 'NOVEMBER'  TO va_bulan_text.
    WHEN '12'.
      MOVE 'DESEMBER'  TO va_bulan_text.
  ENDCASE.
  CONCATENATE va_bulan_text va_tahun INTO va_period
    SEPARATED BY space.
ENDFORM.                    " BULAN

*&---------------------------------------------------------------------*
*&      Form  PROSES_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_all.
  CLEAR: wa_begbal.
  REFRESH i_kunnr.

  LOOP AT i_begbal INTO wa_begbal.
    MOVE wa_begbal-belnr  TO wa_kunnr-belnr.
    MOVE wa_begbal-gjahr  TO wa_kunnr-gjahr.

    MOVE wa_begbal-gsber  TO wa_kunnr-gsber.
    MOVE wa_begbal-kunnr  TO wa_kunnr-kunnr.
    MOVE wa_begbal-shkzg  TO wa_kunnr-shkzg.
    MOVE wa_begbal-monat  TO wa_kunnr-monat.
    MOVE wa_begbal-blart  TO wa_kunnr-blart.
    MOVE wa_begbal-dmbtr  TO wa_kunnr-begbal.
*** Modify By Budi 10/03/2006
    MOVE wa_begbal-budat  TO wa_kunnr-budat.
*** End Modify

    PERFORM f_get_modify USING wa_kunnr-kunnr wa_kunnr-gjahr wa_kunnr-belnr 'PROC'
                         CHANGING wa_kunnr-objkey.

    APPEND wa_kunnr TO i_kunnr.
    CLEAR: wa_begbal.
  ENDLOOP.

  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab.
    MOVE wa_itab-belnr  TO wa_kunnr-belnr.
    MOVE wa_itab-gjahr  TO wa_kunnr-gjahr.

    MOVE wa_itab-gsber    TO wa_kunnr-gsber.
    MOVE wa_itab-kunnr    TO wa_kunnr-kunnr.
    MOVE wa_itab-shkzg    TO wa_kunnr-shkzg.
    MOVE wa_itab-gjahr    TO wa_kunnr-gjahr.
    MOVE wa_itab-monat    TO wa_kunnr-monat.
    MOVE wa_itab-blart    TO wa_kunnr-blart.
    MOVE wa_itab-current  TO wa_kunnr-current.
    MOVE wa_itab-dmbtr    TO wa_kunnr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_kunnr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_kunnr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_kunnr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_kunnr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_kunnr-dmbtr5.
    wa_kunnr-begbal = 0.
*** Modify By Budi 10/03/2006
    MOVE wa_itab-budat  TO wa_kunnr-budat.
*** End Modify

    PERFORM f_get_modify USING wa_kunnr-kunnr wa_kunnr-gjahr wa_kunnr-belnr 'PROC'
                         CHANGING wa_kunnr-objkey.

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_kunnr-current,wa_kunnr-dmbtr1,wa_kunnr-dmbtr2,
                 wa_kunnr-dmbtr3,wa_kunnr-dmbtr4,wa_kunnr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_kunnr-current,wa_kunnr-dmbtr1,wa_kunnr-dmbtr2,
                   wa_kunnr-dmbtr3,wa_kunnr-dmbtr4,wa_kunnr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_kunnr TO i_kunnr.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " PROSES_ALL

*&---------------------------------------------------------------------*
*&      Form  CETAK_DETAIL_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_detail_all.
  DATA: zebra TYPE i,
        l_gstid(6).

  DATA: lv_belnr  TYPE bsid-belnr,
        lv_gjahr  TYPE bsid-gjahr,
        lv_kunnr  TYPE bsid-kunnr.

  CLEAR: l_gstid.

  zebra = 0.
  va_count = 1.

  PERFORM cetak_header_all.

  CLEAR: wa_kunnr.
*  SORT i_kunnr BY objkey kunnr.
  SORT i_kunnr." BY objkey kunnr. "Modify By sol_jonhar 01/10/2020
  LOOP AT i_kunnr INTO wa_kunnr.
    IF wa_kunnr-shkzg EQ 'S'.
      ADD wa_kunnr-begbal TO va_begbal.
      ADD wa_kunnr-current TO va_current.
      ADD wa_kunnr-dmbtr1 TO va_dmbtr1.
      ADD wa_kunnr-dmbtr2 TO va_dmbtr2.
      ADD wa_kunnr-dmbtr3 TO va_dmbtr3.
      ADD wa_kunnr-dmbtr4 TO va_dmbtr4.
      ADD wa_kunnr-dmbtr5 TO va_dmbtr5.
    ELSE.
      va_begbal = va_begbal - wa_kunnr-begbal.
      va_current = va_current - wa_kunnr-current.
      va_dmbtr1 = va_dmbtr1 - wa_kunnr-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_kunnr-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_kunnr-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_kunnr-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_kunnr-dmbtr5.
    ENDIF.

    CONCATENATE wa_kunnr-gjahr wa_kunnr-monat INTO l_gstid.

*    IF WA_KUNNR-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_kunnr-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_kunnr-blart NE 'DZ'.
      IF wa_kunnr-shkzg EQ 'S'.
        ADD wa_kunnr-dmbtr TO va_netsales.
      ELSE.
        va_netsales = va_netsales - wa_kunnr-dmbtr.
      ENDIF.
    ENDIF.

*    IF WA_KUNNR-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_kunnr-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_kunnr-blart EQ 'DZ'.
      IF wa_kunnr-shkzg EQ 'S'.
        ADD wa_kunnr-dmbtr TO va_payment.
      ELSE.
        va_payment = va_payment - wa_kunnr-dmbtr.
      ENDIF.
    ENDIF.

    lv_kunnr  = wa_kunnr-kunnr.
    lv_belnr  = wa_kunnr-belnr.
    lv_gjahr  = wa_kunnr-gjahr.

    AT END OF objkey.
      IF zebra = 0.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT COLOR 1.
        zebra = 0.
      ENDIF.

      PERFORM f_get_modify USING lv_kunnr lv_gjahr lv_belnr 'PRINT'
                           CHANGING va_name1.

      va_endbal = va_begbal + va_netsales + va_payment.
      ADD va_begbal   TO total_begbal.
      ADD va_netsales TO total_netsales.
      ADD va_payment  TO total_payment.
      ADD va_endbal   TO total_endbal.
      ADD va_current  TO total_current.
      ADD va_dmbtr1   TO total_dmbtr1.
      ADD va_dmbtr2   TO total_dmbtr2.
      ADD va_dmbtr3   TO total_dmbtr3.
      ADD va_dmbtr4   TO total_dmbtr4.
      ADD va_dmbtr5   TO total_dmbtr5.

      WRITE va_begbal TO va_begbal1 CURRENCY va_currency.
      MOVE lv_kunnr TO va_kunnr.

      IF va_begbal   NE 0 OR
         va_netsales NE 0 OR
         va_payment  NE 0 OR
         va_endbal   NE 0 OR
         va_current  NE 0 OR
         va_dmbtr1   NE 0 OR
         va_dmbtr2   NE 0 OR
         va_dmbtr3   NE 0 OR
         va_dmbtr4   NE 0 OR
         va_dmbtr5   NE 0.
        WRITE: /    sy-vline NO-GAP, va_kunnr, '-', va_name1 NO-GAP,
                    sy-vline, va_begbal CURRENCY va_currency,
                    sy-vline, va_netsales CURRENCY va_currency,
                    sy-vline, va_payment CURRENCY va_currency,
                    sy-vline, va_endbal CURRENCY va_currency,
                    sy-vline, va_current CURRENCY va_currency,
                    sy-vline, va_dmbtr1 CURRENCY va_currency,
                    sy-vline, va_dmbtr2 CURRENCY va_currency,
                    sy-vline, va_dmbtr3 CURRENCY va_currency,
                    sy-vline, va_dmbtr4 CURRENCY va_currency,
                    sy-vline, va_dmbtr5 CURRENCY va_currency,
                    sy-vline.
        va_belnr   = lv_belnr.
        va_gjahr1  = lv_gjahr.
        HIDE: va_belnr, va_gjahr1.
      ENDIF.

      CLEAR: va_begbal, va_netsales, va_payment, va_endbal, va_current,
             va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
    ENDAT.
    CLEAR: wa_kunnr.
  ENDLOOP.
  FORMAT COLOR 3.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'Total',
          40  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_netsales CURRENCY va_currency,
              sy-vline, total_payment CURRENCY va_currency,
              sy-vline, total_endbal CURRENCY va_currency,
              sy-vline, total_current CURRENCY va_currency,
              sy-vline, total_dmbtr1 CURRENCY va_currency,
              sy-vline, total_dmbtr2 CURRENCY va_currency,
              sy-vline, total_dmbtr3 CURRENCY va_currency,
              sy-vline, total_dmbtr4 CURRENCY va_currency,
              sy-vline, total_dmbtr5 CURRENCY va_currency,
              sy-vline.
  WRITE: /    sy-uline(230).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED OFF.
  CLEAR: total_begbal, total_netsales, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.
ENDFORM.                    " CETAK_DETAIL_ALL

*&---------------------------------------------------------------------*
*&      Form  CETAK_HEADER_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_header_all.
  PERFORM cetak_header.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'No. Cust.', '-', 'Customer Name',
           40 sy-vline NO-GAP.
  SET LEFT SCROLL-BOUNDARY.
  WRITE:     'Beginning Balance',
              sy-vline, 'Net Sales',
          78  sy-vline, 'Payment',
          97  sy-vline, 'Ending Balance',
          116 sy-vline, 'Current',
          135 sy-vline, text1,
              sy-vline, text2,
              sy-vline, text3,
              sy-vline, text4,
              sy-vline, text5,
          230 sy-vline.
  WRITE: /    sy-uline(230).
  FORMAT COLOR OFF.
ENDFORM.                    " CETAK_HEADER_ALL

*&---------------------------------------------------------------------*
*&      Form  ZUONR_PROCESS1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zuonr_process1.
  DATA: lv_sort(25).

  CLEAR: wa_begbal.
  REFRESH i_zuonr.

  PERFORM f_get_modify USING va_kunnr va_gjahr1 va_belnr 'ZUONR'
                   CHANGING lv_sort.

  IF lv_sort EQ 'ZONT' OR
    lv_sort EQ 'ONTC'.
    LOOP AT i_begbal INTO wa_begbal
      WHERE kunnr EQ va_kunnr AND
            belnr EQ va_belnr AND
            gjahr EQ va_gjahr1.
      MOVE wa_begbal-gsber  TO wa_zuonr-gsber.
      MOVE wa_begbal-kunnr  TO wa_zuonr-kunnr.
      MOVE wa_begbal-shkzg  TO wa_zuonr-shkzg.
      MOVE wa_begbal-monat  TO wa_zuonr-monat.
      MOVE wa_begbal-blart  TO wa_zuonr-blart.
      MOVE wa_begbal-zuonr  TO wa_zuonr-zuonr.
      MOVE wa_begbal-augbl  TO wa_zuonr-augbl.
      MOVE wa_begbal-dmbtr  TO wa_zuonr-begbal.
      MOVE wa_begbal-belnr  TO wa_zuonr-belnr.
      MOVE wa_begbal-gjahr  TO wa_zuonr-gjahr.
*** Modify By Budi 10/03/2006
      MOVE wa_begbal-budat  TO wa_zuonr-budat.
*** End Modify
      APPEND wa_zuonr TO i_zuonr.
      CLEAR: wa_begbal.
    ENDLOOP.

    CLEAR: wa_itab.
    LOOP AT i_itab INTO wa_itab
      WHERE kunnr EQ va_kunnr AND
            belnr EQ va_belnr AND
            gjahr EQ va_gjahr1.
      MOVE wa_itab-gsber    TO wa_zuonr-gsber.
      MOVE wa_itab-kunnr    TO wa_zuonr-kunnr.
      MOVE wa_itab-shkzg    TO wa_zuonr-shkzg.
      MOVE wa_itab-gjahr    TO wa_zuonr-gjahr.
      MOVE wa_itab-monat    TO wa_zuonr-monat.
      MOVE wa_itab-blart    TO wa_zuonr-blart.
      MOVE wa_itab-zuonr    TO wa_zuonr-zuonr.
      MOVE wa_itab-augbl    TO wa_zuonr-augbl.
      MOVE wa_itab-current  TO wa_zuonr-current.
      MOVE wa_itab-dmbtr    TO wa_zuonr-dmbtr.
      MOVE wa_itab-dmbtr1   TO wa_zuonr-dmbtr1.
      MOVE wa_itab-dmbtr2   TO wa_zuonr-dmbtr2.
      MOVE wa_itab-dmbtr3   TO wa_zuonr-dmbtr3.
      MOVE wa_itab-dmbtr4   TO wa_zuonr-dmbtr4.
      MOVE wa_itab-dmbtr5   TO wa_zuonr-dmbtr5.
      MOVE wa_itab-belnr    TO wa_zuonr-belnr.
      MOVE wa_itab-gjahr    TO wa_zuonr-gjahr.
      wa_zuonr-begbal = 0.
*** Modify By Budi 10/03/2006
      MOVE wa_itab-budat  TO wa_zuonr-budat.
*** End Modify
      APPEND wa_zuonr TO i_zuonr.
      CLEAR: wa_itab.
    ENDLOOP.
  ELSE.
    LOOP AT i_begbal INTO wa_begbal
      WHERE kunnr EQ va_kunnr.
      MOVE wa_begbal-gsber  TO wa_zuonr-gsber.
      MOVE wa_begbal-kunnr  TO wa_zuonr-kunnr.
      MOVE wa_begbal-shkzg  TO wa_zuonr-shkzg.
      MOVE wa_begbal-monat  TO wa_zuonr-monat.
      MOVE wa_begbal-blart  TO wa_zuonr-blart.
      MOVE wa_begbal-zuonr  TO wa_zuonr-zuonr.
      MOVE wa_begbal-augbl  TO wa_zuonr-augbl.
      MOVE wa_begbal-dmbtr  TO wa_zuonr-begbal.
      MOVE wa_begbal-belnr  TO wa_zuonr-belnr.
      MOVE wa_begbal-gjahr  TO wa_zuonr-gjahr.
*** Modify By Budi 10/03/2006
      MOVE wa_begbal-budat  TO wa_zuonr-budat.
*** End Modify
      APPEND wa_zuonr TO i_zuonr.
      CLEAR: wa_begbal.
    ENDLOOP.

    CLEAR: wa_itab.
    LOOP AT i_itab INTO wa_itab
      WHERE kunnr EQ va_kunnr.
      MOVE wa_itab-gsber    TO wa_zuonr-gsber.
      MOVE wa_itab-kunnr    TO wa_zuonr-kunnr.
      MOVE wa_itab-shkzg    TO wa_zuonr-shkzg.
      MOVE wa_itab-gjahr    TO wa_zuonr-gjahr.
      MOVE wa_itab-monat    TO wa_zuonr-monat.
      MOVE wa_itab-blart    TO wa_zuonr-blart.
      MOVE wa_itab-zuonr    TO wa_zuonr-zuonr.
      MOVE wa_itab-augbl    TO wa_zuonr-augbl.
      MOVE wa_itab-current  TO wa_zuonr-current.
      MOVE wa_itab-dmbtr    TO wa_zuonr-dmbtr.
      MOVE wa_itab-dmbtr1   TO wa_zuonr-dmbtr1.
      MOVE wa_itab-dmbtr2   TO wa_zuonr-dmbtr2.
      MOVE wa_itab-dmbtr3   TO wa_zuonr-dmbtr3.
      MOVE wa_itab-dmbtr4   TO wa_zuonr-dmbtr4.
      MOVE wa_itab-dmbtr5   TO wa_zuonr-dmbtr5.
      MOVE wa_itab-belnr    TO wa_zuonr-belnr.
      MOVE wa_itab-gjahr    TO wa_zuonr-gjahr.
      wa_zuonr-begbal = 0.
*** Modify By Budi 10/03/2006
      MOVE wa_itab-budat  TO wa_zuonr-budat.
*** End Modify
      APPEND wa_zuonr TO i_zuonr.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " ZUONR_PROCESS1

*&---------------------------------------------------------------------*
*&      Form  CETAK_DETAIL_ZUONR1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_detail_zuonr1.
  DATA: zebra   TYPE i,
        l_color TYPE i,
        l_gstid(6).

  CLEAR: l_gstid.
  zebra = 0.

  PERFORM cetak_header_zuonr1.

  CLEAR: wa_zuonr.
*  SORT i_zuonr BY belnr augbl zuonr.
  SORT i_zuonr. " BY belnr augbl zuonr. "Modify By sol_jonhar 01/10/2020

  LOOP AT i_zuonr INTO wa_zuonr.
*    WHERE KUNNR EQ VA_KUNNR.

    IF wa_zuonr-shkzg EQ 'S'.
      ADD wa_zuonr-begbal TO va_begbal.
      ADD wa_zuonr-current TO va_current.
      ADD wa_zuonr-dmbtr1 TO va_dmbtr1.
      ADD wa_zuonr-dmbtr2 TO va_dmbtr2.
      ADD wa_zuonr-dmbtr3 TO va_dmbtr3.
      ADD wa_zuonr-dmbtr4 TO va_dmbtr4.
      ADD wa_zuonr-dmbtr5 TO va_dmbtr5.
    ELSE.
      va_begbal = va_begbal - wa_zuonr-begbal.
      va_current = va_current - wa_zuonr-current.
      va_dmbtr1 = va_dmbtr1 - wa_zuonr-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_zuonr-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_zuonr-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_zuonr-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_zuonr-dmbtr5.
    ENDIF.

    CONCATENATE wa_zuonr-gjahr wa_zuonr-monat INTO l_gstid.

*    IF WA_ZUONR-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_zuonr-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_zuonr-blart NE 'DZ'.
      IF wa_zuonr-shkzg EQ 'S'.
        ADD wa_zuonr-dmbtr TO va_netsales.
      ELSE.
        va_netsales = va_netsales - wa_zuonr-dmbtr.
      ENDIF.
    ENDIF.

*    IF WA_ZUONR-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_zuonr-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_zuonr-blart EQ 'DZ'.
      IF wa_zuonr-shkzg EQ 'S'.
        ADD wa_zuonr-dmbtr TO va_payment.
      ELSE.
        va_payment = va_payment - wa_zuonr-dmbtr.
      ENDIF.
    ENDIF.

    MOVE wa_zuonr-belnr TO va_belnr.
    MOVE wa_zuonr-gjahr TO va_gjahr1.
    MOVE wa_zuonr-zuonr TO va_zuonr.
    MOVE wa_zuonr-augbl TO va_augbl.

    AT END OF belnr.
      IF sy-linno EQ 59.
        FORMAT COLOR OFF.
        FORMAT INTENSIFIED OFF.
        WRITE: /    sy-uline(232).
        PERFORM cetak_header_zuonr1.
        zebra = 0.
      ENDIF.

      IF zebra = 0.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT COLOR 1.
        zebra = 0.
      ENDIF.

      va_endbal = va_begbal + va_netsales + va_payment.

      IF va_augbl IS NOT INITIAL.
        READ TABLE i_augbl WITH KEY augbl = va_augbl.
        IF sy-subrc = 0 AND i_augbl-dmbtr IS INITIAL.
          CLEAR: va_endbal,va_current,va_dmbtr1,va_dmbtr2,
                 va_dmbtr3,va_dmbtr4,va_dmbtr5.
        ENDIF.
      ENDIF.

      ADD va_begbal   TO total_begbal.
      ADD va_netsales TO total_netsales.
      ADD va_payment  TO total_payment.
      ADD va_endbal   TO total_endbal.
      ADD va_current  TO total_current.
      ADD va_dmbtr1   TO total_dmbtr1.
      ADD va_dmbtr2   TO total_dmbtr2.
      ADD va_dmbtr3   TO total_dmbtr3.
      ADD va_dmbtr4   TO total_dmbtr4.
      ADD va_dmbtr5   TO total_dmbtr5.

      IF va_begbal  NE 0 OR
        va_netsales NE 0 OR
        va_payment  NE 0 OR
        va_endbal   NE 0 OR
        va_current  NE 0 OR
        va_dmbtr1   NE 0 OR
        va_dmbtr2   NE 0 OR
        va_dmbtr3   NE 0 OR
        va_dmbtr4   NE 0 OR
        va_dmbtr5   NE 0.
        FORMAT INTENSIFIED OFF.
        WRITE: /    sy-vline, va_zuonr,
                29  sy-vline, va_augbl,
                    sy-vline, va_begbal CURRENCY va_currency,
                    sy-vline, va_netsales CURRENCY va_currency,
                    sy-vline, va_payment CURRENCY va_currency,
                    sy-vline, va_endbal CURRENCY va_currency,
                    sy-vline, va_current CURRENCY va_currency,
                    sy-vline, va_dmbtr1 CURRENCY va_currency,
                    sy-vline, va_dmbtr2 CURRENCY va_currency,
                    sy-vline, va_dmbtr3 CURRENCY va_currency,
                    sy-vline, va_dmbtr4 CURRENCY va_currency,
                    sy-vline, va_dmbtr5 CURRENCY va_currency,
                232 sy-vline.
        HIDE: va_belnr, va_gjahr1.
      ELSE.
        IF zebra = 0.
          zebra = 1.
        ELSE.
          zebra = 0.
        ENDIF.
      ENDIF.
      CLEAR: va_begbal, va_netsales, va_payment, va_endbal,
             va_current, va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4,
             va_dmbtr5, va_augbl.
    ENDAT.
    CLEAR: wa_zuonr.
  ENDLOOP.

  FORMAT COLOR 3.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(232).
  WRITE: /    sy-vline, 'Total',
          42  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_netsales CURRENCY va_currency,
              sy-vline, total_payment CURRENCY va_currency,
              sy-vline, total_endbal CURRENCY va_currency,
              sy-vline, total_current CURRENCY va_currency,
              sy-vline, total_dmbtr1 CURRENCY va_currency,
              sy-vline, total_dmbtr2 CURRENCY va_currency,
              sy-vline, total_dmbtr3 CURRENCY va_currency,
              sy-vline, total_dmbtr4 CURRENCY va_currency,
              sy-vline, total_dmbtr5 CURRENCY va_currency,
          232 sy-vline.
  WRITE: /    sy-uline(232).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED OFF.
  CLEAR: total_begbal, total_netsales, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.
ENDFORM.                    " CETAK_DETAIL_ZUONR1

*&---------------------------------------------------------------------*
*&      Form  CETAK_HEADER_ZUONR1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_header_zuonr1.
  PERFORM cetak_header.

*  SELECT SINGLE NAME1
*    FROM KNA1
*    INTO VA_NAME1
*    WHERE KUNNR EQ VA_KUNNR.

*  WRITE: /    'Customer Name :', VA_NAME1.
  IF radio3 EQ 'X'.
    WRITE: /    'Customer Name :', va_kunnr, '-', va_name1.
  ELSEIF radio4 EQ 'X'.
    WRITE: /    'Industry Key  :', va_brsch, '-', va_brtxt.
  ELSEIF radio5 EQ 'X'.
    WRITE: /    'Account Name  :', va_hkont, '-', va_txt20.
  ENDIF.
  FORMAT COLOR 1.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(232).
  WRITE: /    sy-vline, 'Invoice Number',
          29  sy-vline, 'Clrng doc.', sy-vline NO-GAP.
  SET LEFT SCROLL-BOUNDARY.
  WRITE:      'Beginning Balance',
              sy-vline, 'Net Sales',
          80  sy-vline, 'Payment',
          99  sy-vline, 'Ending Balance',
          118 sy-vline, 'Current',
          137 sy-vline, text1,
              sy-vline, text2,
              sy-vline, text3,
              sy-vline, text4,
              sy-vline, text5,
          232 sy-vline.
  WRITE: /    sy-uline(232).
  FORMAT COLOR OFF.
ENDFORM.                    " CETAK_HEADER_ZUONR1

*&---------------------------------------------------------------------*
*&      Form  GET_DATE_DZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_date_dz.
  CLEAR: wa_itab_dz.
*** Modify By Budi 10/03/2006
  CLEAR: va_clear, va_dmbtr.
*** End Modify
  IF wa_itab-blart EQ 'DZ'.
    READ TABLE i_itab_rv INTO wa_itab_dz
    WITH KEY augbl = wa_itab-augbl
             gsber = wa_itab-gsber
             kunnr = wa_itab-kunnr
             blart = 'RV'
    ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
    IF sy-subrc EQ 0.
      wa_itab-zfbdt = wa_itab_dz-augdt.
      wa_itab-zbd1t = wa_itab_dz-zbd1t.
*** Modify By Budi 10/03/2006
      va_clear = '1'.
*** End Modify
    ELSE.
      READ TABLE i_itab_dr INTO wa_itab_dz
      WITH KEY augbl = wa_itab-augbl
               gsber = wa_itab-gsber
               kunnr = wa_itab-kunnr
               blart = 'DR'
      ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc EQ 0.
        wa_itab-zfbdt = wa_itab_dz-augdt.
        wa_itab-zbd1t = wa_itab_dz-zbd1t.
*** Modify By Budi 10/03/2006
        va_clear = '1'.
*** End Modify
      ELSE.
        READ TABLE i_itab_da INTO wa_itab_dz
        WITH KEY augbl = wa_itab-augbl
                 gsber = wa_itab-gsber
                 kunnr = wa_itab-kunnr
                 blart = 'DA'
        ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc EQ 0.
          wa_itab-zfbdt = wa_itab_dz-augdt.
          wa_itab-zbd1t = wa_itab_dz-zbd1t.
*** Modify By Budi 10/03/2006
          va_clear = '1'.
*** End Modify
        ELSE.
          READ TABLE i_itab_za INTO wa_itab_dz
          WITH KEY augbl = wa_itab-augbl
                   gsber = wa_itab-gsber
                   kunnr = wa_itab-kunnr
                   blart = 'ZA'
          ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
          IF sy-subrc EQ 0.
            wa_itab-zfbdt = wa_itab_dz-augdt.
            wa_itab-zbd1t = wa_itab_dz-zbd1t.
*** Modify By Budi 10/03/2006
            va_clear = '1'.
*** End Modify
          ELSE.
            READ TABLE i_itab_sa INTO wa_itab_dz
            WITH KEY augbl = wa_itab-augbl
                     gsber = wa_itab-gsber
                     kunnr = wa_itab-kunnr
                     blart = 'SA'
            ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
            IF sy-subrc EQ 0.
              wa_itab-zfbdt = wa_itab_dz-augdt.
              wa_itab-zbd1t = wa_itab_dz-zbd1t.
*** Modify By Budi 10/03/2006
              va_clear = '1'.
*** End Modify
            ELSE.
              READ TABLE i_itab_dg INTO wa_itab_dz
              WITH KEY augbl = wa_itab-augbl
                       gsber = wa_itab-gsber
                       kunnr = wa_itab-kunnr
                       blart = 'DG'
              ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
              IF sy-subrc EQ 0.
                wa_itab-zfbdt = wa_itab_dz-augdt.
                wa_itab-zbd1t = wa_itab_dz-zbd1t.
*** Modify By Budi 10/03/2006
                va_clear = '1'.
              ELSE.
                READ TABLE i_itab_d1 INTO wa_itab_dz
                WITH KEY augbl = wa_itab-augbl
                         gsber = wa_itab-gsber
                         kunnr = wa_itab-kunnr
                         blart = 'D1'
                ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
                IF sy-subrc EQ 0.
                  wa_itab-zfbdt = wa_itab_dz-augdt.
                  wa_itab-zbd1t = wa_itab_dz-zbd1t.
                  va_clear = '1'.
                ELSE.
                  READ TABLE i_itab_zc INTO wa_itab_dz
                  WITH KEY augbl = wa_itab-augbl
                           gsber = wa_itab-gsber
                           kunnr = wa_itab-kunnr
                           blart = 'ZC'
                  ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
                  IF sy-subrc EQ 0.
                    wa_itab-zfbdt = wa_itab_dz-augdt.
                    wa_itab-zbd1t = wa_itab_dz-zbd1t.
                    va_clear = '1'.
                  ELSE.
                    READ TABLE i_itab_zi INTO wa_itab_dz
                    WITH KEY augbl = wa_itab-augbl
                             gsber = wa_itab-gsber
                             kunnr = wa_itab-kunnr
                             blart = 'ZI'
                    ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
                    IF sy-subrc EQ 0.
                      wa_itab-zfbdt = wa_itab_dz-augdt.
                      wa_itab-zbd1t = wa_itab_dz-zbd1t.
                      va_clear = '1'.
                    ELSE.
                      READ TABLE i_itab_zk INTO wa_itab_dz
                      WITH KEY augbl = wa_itab-augbl
                               gsber = wa_itab-gsber
                               kunnr = wa_itab-kunnr
                               blart = 'ZK'
                      ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
                      IF sy-subrc EQ 0.
                        wa_itab-zfbdt = wa_itab_dz-augdt.
                        wa_itab-zbd1t = wa_itab_dz-zbd1t.
                        va_clear = '1'.
                      ELSE.
                        READ TABLE i_itab_ab INTO wa_itab_dz
                        WITH KEY augbl = wa_itab-augbl
                                 gsber = wa_itab-gsber
                                 kunnr = wa_itab-kunnr
                                 blart = 'AB'
                        ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
                        IF sy-subrc EQ 0.
                          wa_itab-zfbdt = wa_itab_dz-augdt.
                          wa_itab-zbd1t = wa_itab_dz-zbd1t.
                          va_clear = '1'.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
*** End Modify
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*** Modify By Budi 10/03/2006
  ELSE.
*  READ TABLE I_ITAB_DZ INTO WA_ITAB_DZ
*  WITH KEY AUGBL = WA_ITAB-AUGBL BLART = 'DZ'
*  ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
*  IF SY-SUBRC EQ 0.
    LOOP AT i_itab_dz INTO wa_itab_dz
      WHERE augbl = wa_itab-augbl AND
            gsber = wa_itab-gsber AND
            kunnr = wa_itab-kunnr AND
            blart = 'DZ'.
      IF wa_itab_dz-shkzg EQ wa_itab-shkzg.
        wa_itab_dz-dmbtr = wa_itab_dz-dmbtr * -1.
      ENDIF.
      va_clear = '1'.
      va_dmbtr = va_dmbtr + wa_itab_dz-dmbtr.
*      IF wa_itab-augbl IS INITIAL.
*        DELETE TABLE i_itab_dz FROM wa_itab_dz.
*        EXIT.
*      ELSE.
      DELETE TABLE i_itab_dz FROM wa_itab_dz.
*      ENDIF.
    ENDLOOP.
*  ENDIF.
*** End Modify
  ENDIF.
ENDFORM.                    " GET_DATE_DZ

*&---------------------------------------------------------------------*
*&      Form  BRSCH_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM brsch_process.
  CLEAR: wa_begbal.
  REFRESH i_brsch.
  LOOP AT i_begbal INTO wa_begbal
    WHERE gsber EQ tgsbt-gsber AND
          brsch IN so_brsch.
    MOVE wa_begbal-gsber  TO wa_brsch-gsber.
    MOVE wa_begbal-brsch  TO wa_brsch-brsch.
    MOVE wa_begbal-shkzg  TO wa_brsch-shkzg.
    MOVE wa_begbal-monat  TO wa_brsch-monat.
    MOVE wa_begbal-blart  TO wa_brsch-blart.
    MOVE wa_begbal-dmbtr  TO wa_brsch-begbal.
*** Modify By Budi 10/03/2006
    MOVE wa_begbal-budat  TO wa_brsch-budat.
*** End Modify
    APPEND wa_brsch TO i_brsch.
    CLEAR: wa_begbal.
  ENDLOOP.

  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE gsber EQ tgsbt-gsber AND
          brsch IN so_brsch.
    MOVE wa_itab-gsber    TO wa_brsch-gsber.
    MOVE wa_itab-brsch    TO wa_brsch-brsch.
    MOVE wa_itab-shkzg    TO wa_brsch-shkzg.
    MOVE wa_itab-gjahr    TO wa_brsch-gjahr.
    MOVE wa_itab-monat    TO wa_brsch-monat.
    MOVE wa_itab-blart    TO wa_brsch-blart.
    MOVE wa_itab-current  TO wa_brsch-current.
    MOVE wa_itab-dmbtr    TO wa_brsch-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_brsch-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_brsch-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_brsch-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_brsch-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_brsch-dmbtr5.
    wa_brsch-begbal = 0.
*** Modify By Budi 10/03/2006
    MOVE wa_itab-budat  TO wa_brsch-budat.
*** End Modify

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_brsch-current,wa_brsch-dmbtr1,wa_brsch-dmbtr2,
                 wa_brsch-dmbtr3,wa_brsch-dmbtr4,wa_brsch-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_brsch-current,wa_brsch-dmbtr1,wa_brsch-dmbtr2,
                   wa_brsch-dmbtr3,wa_brsch-dmbtr4,wa_brsch-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_brsch TO i_brsch.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " BRSCH_PROCESS

*&---------------------------------------------------------------------*
*&      Form  CETAK_DETAIL_BRSCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_detail_brsch.

  DATA: zebra TYPE i,
        l_gstid(6).

  CLEAR: l_gstid, va_brsch, va_brtxt.
  zebra = 0.

  PERFORM cetak_header_brsch.

  CLEAR: wa_brsch.
*  SORT i_brsch BY brsch.
  SORT i_brsch ."BY brsch. "Modify By sol_jonhar 01/10/2020
  LOOP AT i_brsch INTO wa_brsch
    WHERE gsber EQ tgsbt-gsber.
    IF wa_brsch-shkzg EQ 'S'.
      ADD wa_brsch-begbal TO va_begbal.
      ADD wa_brsch-current TO va_current.
      ADD wa_brsch-dmbtr1 TO va_dmbtr1.
      ADD wa_brsch-dmbtr2 TO va_dmbtr2.
      ADD wa_brsch-dmbtr3 TO va_dmbtr3.
      ADD wa_brsch-dmbtr4 TO va_dmbtr4.
      ADD wa_brsch-dmbtr5 TO va_dmbtr5.
    ELSE.
      va_begbal = va_begbal - wa_brsch-begbal.
      va_current = va_current - wa_brsch-current.
      va_dmbtr1 = va_dmbtr1 - wa_brsch-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_brsch-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_brsch-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_brsch-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_brsch-dmbtr5.
    ENDIF.

    CONCATENATE wa_brsch-gjahr wa_brsch-monat INTO l_gstid.

*    IF WA_BRSCH-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_brsch-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_brsch-blart NE 'DZ'.
      IF wa_brsch-shkzg EQ 'S'.
        ADD wa_brsch-dmbtr TO va_netsales.
      ELSE.
        va_netsales = va_netsales - wa_brsch-dmbtr.
      ENDIF.
    ENDIF.

*    IF WA_BRSCH-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_brsch-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_brsch-blart EQ 'DZ'.
      IF wa_brsch-shkzg EQ 'S'.
        ADD wa_brsch-dmbtr TO va_payment.
      ELSE.
        va_payment = va_payment - wa_brsch-dmbtr.
      ENDIF.
    ENDIF.

    AT END OF brsch.
      IF zebra = 0.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT COLOR 1.
        zebra = 0.
      ENDIF.

      SELECT SINGLE brtxt
        FROM t016t
        INTO va_brtxt
        WHERE brsch EQ wa_brsch-brsch.

      va_endbal = va_begbal + va_netsales + va_payment.
      ADD va_begbal   TO total_begbal.
      ADD va_netsales TO total_netsales.
      ADD va_payment  TO total_payment.
      ADD va_endbal   TO total_endbal.
      ADD va_current  TO total_current.
      ADD va_dmbtr1   TO total_dmbtr1.
      ADD va_dmbtr2   TO total_dmbtr2.
      ADD va_dmbtr3   TO total_dmbtr3.
      ADD va_dmbtr4   TO total_dmbtr4.
      ADD va_dmbtr5   TO total_dmbtr5.

      WRITE va_begbal TO va_begbal1 CURRENCY va_currency.
      MOVE wa_brsch-brsch TO va_brsch.

      IF va_begbal   NE 0 OR
         va_netsales NE 0 OR
         va_payment  NE 0 OR
         va_endbal   NE 0 OR
         va_current  NE 0 OR
         va_dmbtr1   NE 0 OR
         va_dmbtr2   NE 0 OR
         va_dmbtr3   NE 0 OR
         va_dmbtr4   NE 0 OR
         va_dmbtr5   NE 0.
        WRITE: /    sy-vline NO-GAP, va_brsch, '-', va_brtxt NO-GAP,
                    sy-vline, va_begbal CURRENCY va_currency,
                    sy-vline, va_netsales CURRENCY va_currency,
                    sy-vline, va_payment CURRENCY va_currency,
                    sy-vline, va_endbal CURRENCY va_currency,
                    sy-vline, va_current CURRENCY va_currency,
                    sy-vline, va_dmbtr1 CURRENCY va_currency,
                    sy-vline, va_dmbtr2 CURRENCY va_currency,
                    sy-vline, va_dmbtr3 CURRENCY va_currency,
                    sy-vline, va_dmbtr4 CURRENCY va_currency,
                    sy-vline, va_dmbtr5 CURRENCY va_currency,
                    sy-vline.
      ENDIF.

      CLEAR: va_begbal, va_netsales, va_payment, va_endbal, va_current,
             va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
    ENDAT.
    CLEAR: wa_brsch.
  ENDLOOP.
  FORMAT COLOR 3.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'Total',
          40  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_netsales CURRENCY va_currency,
              sy-vline, total_payment CURRENCY va_currency,
              sy-vline, total_endbal CURRENCY va_currency,
              sy-vline, total_current CURRENCY va_currency,
              sy-vline, total_dmbtr1 CURRENCY va_currency,
              sy-vline, total_dmbtr2 CURRENCY va_currency,
              sy-vline, total_dmbtr3 CURRENCY va_currency,
              sy-vline, total_dmbtr4 CURRENCY va_currency,
              sy-vline, total_dmbtr5 CURRENCY va_currency,
              sy-vline.
  WRITE: /    sy-uline(230).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED OFF.
  CLEAR: total_begbal, total_netsales, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.

ENDFORM.                    " CETAK_DETAIL_BRSCH

*&---------------------------------------------------------------------*
*&      Form  HKONT_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hkont_process.
  CLEAR: wa_begbal.
  REFRESH i_hkont.
  LOOP AT i_begbal INTO wa_begbal
    WHERE gsber EQ tgsbt-gsber AND
          hkont IN so_hkont.
    MOVE wa_begbal-gsber  TO wa_hkont-gsber.
    MOVE wa_begbal-hkont  TO wa_hkont-hkont.
    MOVE wa_begbal-shkzg  TO wa_hkont-shkzg.
    MOVE wa_begbal-monat  TO wa_hkont-monat.
    MOVE wa_begbal-blart  TO wa_hkont-blart.
    MOVE wa_begbal-dmbtr  TO wa_hkont-begbal.
*** Modify By Budi 10/03/2006
    MOVE wa_begbal-budat  TO wa_hkont-budat.
*** End Modify
    APPEND wa_hkont TO i_hkont.
    CLEAR: wa_begbal.
  ENDLOOP.

  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE gsber EQ tgsbt-gsber AND
          hkont IN so_hkont.
    MOVE wa_itab-gsber    TO wa_hkont-gsber.
    MOVE wa_itab-hkont    TO wa_hkont-hkont.
    MOVE wa_itab-shkzg    TO wa_hkont-shkzg.
    MOVE wa_itab-gjahr    TO wa_hkont-gjahr.
    MOVE wa_itab-monat    TO wa_hkont-monat.
    MOVE wa_itab-blart    TO wa_hkont-blart.
    MOVE wa_itab-current  TO wa_hkont-current.
    MOVE wa_itab-dmbtr    TO wa_hkont-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_hkont-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_hkont-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_hkont-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_hkont-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_hkont-dmbtr5.
    wa_hkont-begbal = 0.
*** Modify By Budi 10/03/2006
    MOVE wa_itab-budat  TO wa_hkont-budat.
*** End Modify

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_hkont-current,wa_hkont-dmbtr1,wa_hkont-dmbtr2,
                 wa_hkont-dmbtr3,wa_hkont-dmbtr4,wa_hkont-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_hkont-current,wa_hkont-dmbtr1,wa_hkont-dmbtr2,
                   wa_hkont-dmbtr3,wa_hkont-dmbtr4,wa_hkont-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_hkont TO i_hkont.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " HKONT_PROCESS

*&---------------------------------------------------------------------*
*&      Form  CETAK_DETAIL_HKONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_detail_hkont.

  DATA: zebra TYPE i,
        l_gstid(6).

  CLEAR: l_gstid, va_hkont, va_txt20.
  zebra = 0.

  PERFORM cetak_header_hkont.

  CLEAR: wa_hkont.
*  SORT i_hkont BY hkont.
  SORT i_hkont. " BY hkont. "Modify By sol_jonhar 01/10/2020
  LOOP AT i_hkont INTO wa_hkont
    WHERE gsber EQ tgsbt-gsber.
    IF wa_hkont-shkzg EQ 'S'.
      ADD wa_hkont-begbal TO va_begbal.
      ADD wa_hkont-current TO va_current.
      ADD wa_hkont-dmbtr1 TO va_dmbtr1.
      ADD wa_hkont-dmbtr2 TO va_dmbtr2.
      ADD wa_hkont-dmbtr3 TO va_dmbtr3.
      ADD wa_hkont-dmbtr4 TO va_dmbtr4.
      ADD wa_hkont-dmbtr5 TO va_dmbtr5.
    ELSE.
      va_begbal = va_begbal - wa_hkont-begbal.
      va_current = va_current - wa_hkont-current.
      va_dmbtr1 = va_dmbtr1 - wa_hkont-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_hkont-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_hkont-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_hkont-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_hkont-dmbtr5.
    ENDIF.

    CONCATENATE wa_hkont-gjahr wa_hkont-monat INTO l_gstid.

*    IF WA_HKONT-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_hkont-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_hkont-blart NE 'DZ'.
      IF wa_hkont-shkzg EQ 'S'.
        ADD wa_hkont-dmbtr TO va_netsales.
      ELSE.
        va_netsales = va_netsales - wa_hkont-dmbtr.
      ENDIF.
    ENDIF.

*    IF WA_HKONT-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_hkont-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_hkont-blart EQ 'DZ'.
      IF wa_hkont-shkzg EQ 'S'.
        ADD wa_hkont-dmbtr TO va_payment.
      ELSE.
        va_payment = va_payment - wa_hkont-dmbtr.
      ENDIF.
    ENDIF.

    AT END OF hkont.
      IF zebra = 0.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT COLOR 1.
        zebra = 0.
      ENDIF.

      SELECT SINGLE txt20
        FROM skat
        INTO va_txt20
        WHERE spras EQ sy-langu  AND
              ktopl EQ 'TSPC'    AND
              saknr EQ wa_hkont-hkont.

      va_endbal = va_begbal + va_netsales + va_payment.
      ADD va_begbal   TO total_begbal.
      ADD va_netsales TO total_netsales.
      ADD va_payment  TO total_payment.
      ADD va_endbal   TO total_endbal.
      ADD va_current  TO total_current.
      ADD va_dmbtr1   TO total_dmbtr1.
      ADD va_dmbtr2   TO total_dmbtr2.
      ADD va_dmbtr3   TO total_dmbtr3.
      ADD va_dmbtr4   TO total_dmbtr4.
      ADD va_dmbtr5   TO total_dmbtr5.

      WRITE va_begbal TO va_begbal1 CURRENCY va_currency.
      MOVE wa_hkont-hkont TO va_hkont.

      IF va_begbal   NE 0 OR
         va_netsales NE 0 OR
         va_payment  NE 0 OR
         va_endbal   NE 0 OR
         va_current  NE 0 OR
         va_dmbtr1   NE 0 OR
         va_dmbtr2   NE 0 OR
         va_dmbtr3   NE 0 OR
         va_dmbtr4   NE 0 OR
         va_dmbtr5   NE 0.
        WRITE: /    sy-vline NO-GAP, va_hkont, '-', va_txt20 NO-GAP,
                    sy-vline, va_begbal CURRENCY va_currency,
                    sy-vline, va_netsales CURRENCY va_currency,
                    sy-vline, va_payment CURRENCY va_currency,
                    sy-vline, va_endbal CURRENCY va_currency,
                    sy-vline, va_current CURRENCY va_currency,
                    sy-vline, va_dmbtr1 CURRENCY va_currency,
                    sy-vline, va_dmbtr2 CURRENCY va_currency,
                    sy-vline, va_dmbtr3 CURRENCY va_currency,
                    sy-vline, va_dmbtr4 CURRENCY va_currency,
                    sy-vline, va_dmbtr5 CURRENCY va_currency,
                    sy-vline.
      ENDIF.

      CLEAR: va_begbal, va_netsales, va_payment, va_endbal, va_current,
             va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
    ENDAT.
    CLEAR: wa_hkont.
  ENDLOOP.
  FORMAT COLOR 3.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'Total',
          40  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_netsales CURRENCY va_currency,
              sy-vline, total_payment CURRENCY va_currency,
              sy-vline, total_endbal CURRENCY va_currency,
              sy-vline, total_current CURRENCY va_currency,
              sy-vline, total_dmbtr1 CURRENCY va_currency,
              sy-vline, total_dmbtr2 CURRENCY va_currency,
              sy-vline, total_dmbtr3 CURRENCY va_currency,
              sy-vline, total_dmbtr4 CURRENCY va_currency,
              sy-vline, total_dmbtr5 CURRENCY va_currency,
              sy-vline.
  WRITE: /    sy-uline(230).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED OFF.
  CLEAR: total_begbal, total_netsales, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.

ENDFORM.                    " CETAK_DETAIL_HKONT

*&---------------------------------------------------------------------*
*&      Form  CETAK_HEADER_BRSCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_header_brsch.
  PERFORM cetak_header.
  IF sy-ucomm NE 'ALL'.
    WRITE: /    'Business Area :', va_gtext.
  ENDIF.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'Industry', '-', 'Description',
           40 sy-vline NO-GAP.
  SET LEFT SCROLL-BOUNDARY.
  WRITE:     'Beginning Balance',
              sy-vline, 'Net Sales',
          78  sy-vline, 'Payment',
          97  sy-vline, 'Ending Balance',
          116 sy-vline, 'Current',
          135 sy-vline, text1,
              sy-vline, text2,
              sy-vline, text3,
              sy-vline, text4,
              sy-vline, text5,
          230 sy-vline.
  WRITE: /    sy-uline(230).
  FORMAT COLOR OFF.
ENDFORM.                    " CETAK_HEADER_BRSCH

*&---------------------------------------------------------------------*
*&      Form  CETAK_HEADER_HKONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_header_hkont.
  PERFORM cetak_header.
  IF sy-ucomm NE 'ALL'.
    WRITE: /    'Business Area :', va_gtext.
  ENDIF.
  FORMAT COLOR 1.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'Account', '-', 'Description',
           40 sy-vline NO-GAP.
  SET LEFT SCROLL-BOUNDARY.
  WRITE:     'Beginning Balance',
              sy-vline, 'Net Sales',
          78  sy-vline, 'Payment',
          97  sy-vline, 'Ending Balance',
          116 sy-vline, 'Current',
          135 sy-vline, text1,
              sy-vline, text2,
              sy-vline, text3,
              sy-vline, text4,
              sy-vline, text5,
          230 sy-vline.
  WRITE: /    sy-uline(230).
  FORMAT COLOR OFF.
ENDFORM.                    " CETAK_HEADER_HKONT

*&---------------------------------------------------------------------*
*&      Form  PROCESS_BRSCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_brsch.
  CLEAR: wa_begbal, wa_kunnr.
  REFRESH i_kunnr.
  LOOP AT i_begbal INTO wa_begbal
    WHERE gsber EQ tgsbt-gsber AND
          brsch EQ va_brsch.
    MOVE wa_begbal-gsber  TO wa_kunnr-gsber.
    MOVE wa_begbal-kunnr  TO wa_kunnr-kunnr.
    MOVE wa_begbal-shkzg  TO wa_kunnr-shkzg.
    MOVE wa_begbal-monat  TO wa_kunnr-monat.
    MOVE wa_begbal-blart  TO wa_kunnr-blart.
    MOVE wa_begbal-dmbtr  TO wa_kunnr-begbal.
*** Modify By Budi 10/03/2006
    MOVE wa_begbal-budat  TO wa_kunnr-budat.
*** End Modify
    APPEND wa_kunnr TO i_kunnr.
    CLEAR: wa_begbal.
  ENDLOOP.

  CLEAR: wa_itab, wa_kunnr.
  LOOP AT i_itab INTO wa_itab
    WHERE gsber EQ tgsbt-gsber AND
          brsch EQ va_brsch.
    MOVE wa_itab-gsber    TO wa_kunnr-gsber.
    MOVE wa_itab-kunnr    TO wa_kunnr-kunnr.
    MOVE wa_itab-shkzg    TO wa_kunnr-shkzg.
    MOVE wa_itab-gjahr    TO wa_kunnr-gjahr.
    MOVE wa_itab-monat    TO wa_kunnr-monat.
    MOVE wa_itab-blart    TO wa_kunnr-blart.
    MOVE wa_itab-current  TO wa_kunnr-current.
    MOVE wa_itab-dmbtr    TO wa_kunnr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_kunnr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_kunnr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_kunnr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_kunnr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_kunnr-dmbtr5.
    wa_kunnr-begbal = 0.
*** Modify By Budi 10/03/2006
    MOVE wa_itab-budat  TO wa_kunnr-budat.
*** End Modify

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_kunnr-current,wa_kunnr-dmbtr1,wa_kunnr-dmbtr2,
                 wa_kunnr-dmbtr3,wa_kunnr-dmbtr4,wa_kunnr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_kunnr-current,wa_kunnr-dmbtr1,wa_kunnr-dmbtr2,
                   wa_kunnr-dmbtr3,wa_kunnr-dmbtr4,wa_kunnr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_kunnr TO i_kunnr.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " PROCESS_BRSCH

*&---------------------------------------------------------------------*
*&      Form  PROCESS_HKONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_hkont.
  CLEAR: wa_begbal, wa_kunnr.
  REFRESH i_kunnr.
  LOOP AT i_begbal INTO wa_begbal
    WHERE gsber EQ tgsbt-gsber AND
          hkont EQ va_hkont.
    MOVE wa_begbal-gsber  TO wa_kunnr-gsber.
    MOVE wa_begbal-kunnr  TO wa_kunnr-kunnr.
    MOVE wa_begbal-shkzg  TO wa_kunnr-shkzg.
    MOVE wa_begbal-monat  TO wa_kunnr-monat.
    MOVE wa_begbal-blart  TO wa_kunnr-blart.
    MOVE wa_begbal-dmbtr  TO wa_kunnr-begbal.
*** Modify By Budi 10/03/2006
    MOVE wa_begbal-budat  TO wa_kunnr-budat.
*** End Modify
    APPEND wa_kunnr TO i_kunnr.
    CLEAR: wa_begbal.
  ENDLOOP.

  CLEAR: wa_itab, wa_kunnr.
  LOOP AT i_itab INTO wa_itab
    WHERE gsber EQ tgsbt-gsber AND
          hkont EQ va_hkont.
    MOVE wa_itab-gsber    TO wa_kunnr-gsber.
    MOVE wa_itab-kunnr    TO wa_kunnr-kunnr.
    MOVE wa_itab-shkzg    TO wa_kunnr-shkzg.
    MOVE wa_itab-gjahr    TO wa_kunnr-gjahr.
    MOVE wa_itab-monat    TO wa_kunnr-monat.
    MOVE wa_itab-blart    TO wa_kunnr-blart.
    MOVE wa_itab-current  TO wa_kunnr-current.
    MOVE wa_itab-dmbtr    TO wa_kunnr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_kunnr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_kunnr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_kunnr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_kunnr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_kunnr-dmbtr5.
    wa_kunnr-begbal = 0.
*** Modify By Budi 10/03/2006
    MOVE wa_itab-budat  TO wa_kunnr-budat.
*** End Modify

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_kunnr-current,wa_kunnr-dmbtr1,wa_kunnr-dmbtr2,
                 wa_kunnr-dmbtr3,wa_kunnr-dmbtr4,wa_kunnr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_kunnr-current,wa_kunnr-dmbtr1,wa_kunnr-dmbtr2,
                   wa_kunnr-dmbtr3,wa_kunnr-dmbtr4,wa_kunnr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_kunnr TO i_kunnr.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " PROCESS_HKONT

*&---------------------------------------------------------------------*
*&      Form  PROCESS1_BRSCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process1_brsch.
  CLEAR: wa_begbal, wa_kunnr.
  REFRESH i_kunnr.
  LOOP AT i_begbal INTO wa_begbal
    WHERE brsch EQ va_brsch.
    MOVE wa_begbal-gsber  TO wa_kunnr-gsber.
    MOVE wa_begbal-kunnr  TO wa_kunnr-kunnr.
    MOVE wa_begbal-shkzg  TO wa_kunnr-shkzg.
    MOVE wa_begbal-monat  TO wa_kunnr-monat.
    MOVE wa_begbal-blart  TO wa_kunnr-blart.
    MOVE wa_begbal-dmbtr  TO wa_kunnr-begbal.
*** Modify By Budi 10/03/2006
    MOVE wa_begbal-budat  TO wa_kunnr-budat.
*** End Modify
    APPEND wa_kunnr TO i_kunnr.
    CLEAR: wa_begbal.
  ENDLOOP.

  CLEAR: wa_itab, wa_kunnr.
  LOOP AT i_itab INTO wa_itab
    WHERE brsch EQ va_brsch.
    MOVE wa_itab-gsber    TO wa_kunnr-gsber.
    MOVE wa_itab-kunnr    TO wa_kunnr-kunnr.
    MOVE wa_itab-shkzg    TO wa_kunnr-shkzg.
    MOVE wa_itab-gjahr    TO wa_kunnr-gjahr.
    MOVE wa_itab-monat    TO wa_kunnr-monat.
    MOVE wa_itab-blart    TO wa_kunnr-blart.
    MOVE wa_itab-current  TO wa_kunnr-current.
    MOVE wa_itab-dmbtr    TO wa_kunnr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_kunnr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_kunnr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_kunnr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_kunnr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_kunnr-dmbtr5.
    wa_kunnr-begbal = 0.
*** Modify By Budi 10/03/2006
    MOVE wa_itab-budat  TO wa_kunnr-budat.
*** End Modify

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_kunnr-current,wa_kunnr-dmbtr1,wa_kunnr-dmbtr2,
                 wa_kunnr-dmbtr3,wa_kunnr-dmbtr4,wa_kunnr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_kunnr-current,wa_kunnr-dmbtr1,wa_kunnr-dmbtr2,
                   wa_kunnr-dmbtr3,wa_kunnr-dmbtr4,wa_kunnr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_kunnr TO i_kunnr.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " PROCESS1_BRSCH

*&---------------------------------------------------------------------*
*&      Form  PROCESS1_HKONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process1_hkont.
  CLEAR: wa_begbal, wa_kunnr.
  REFRESH i_kunnr.
  LOOP AT i_begbal INTO wa_begbal
    WHERE hkont EQ va_hkont.
    MOVE wa_begbal-gsber  TO wa_kunnr-gsber.
    MOVE wa_begbal-kunnr  TO wa_kunnr-kunnr.
    MOVE wa_begbal-shkzg  TO wa_kunnr-shkzg.
    MOVE wa_begbal-monat  TO wa_kunnr-monat.
    MOVE wa_begbal-blart  TO wa_kunnr-blart.
    MOVE wa_begbal-dmbtr  TO wa_kunnr-begbal.
*** Modify By Budi 10/03/2006
    MOVE wa_begbal-budat  TO wa_kunnr-budat.
*** End Modify
    APPEND wa_kunnr TO i_kunnr.
    CLEAR: wa_begbal.
  ENDLOOP.

  CLEAR: wa_itab, wa_kunnr.
  LOOP AT i_itab INTO wa_itab
    WHERE hkont EQ va_hkont.
    MOVE wa_itab-gsber    TO wa_kunnr-gsber.
    MOVE wa_itab-kunnr    TO wa_kunnr-kunnr.
    MOVE wa_itab-shkzg    TO wa_kunnr-shkzg.
    MOVE wa_itab-gjahr    TO wa_kunnr-gjahr.
    MOVE wa_itab-monat    TO wa_kunnr-monat.
    MOVE wa_itab-blart    TO wa_kunnr-blart.
    MOVE wa_itab-current  TO wa_kunnr-current.
    MOVE wa_itab-dmbtr    TO wa_kunnr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_kunnr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_kunnr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_kunnr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_kunnr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_kunnr-dmbtr5.
    wa_kunnr-begbal = 0.
*** Modify By Budi 10/03/2006
    MOVE wa_itab-budat  TO wa_kunnr-budat.
*** End Modify

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_kunnr-current,wa_kunnr-dmbtr1,wa_kunnr-dmbtr2,
                 wa_kunnr-dmbtr3,wa_kunnr-dmbtr4,wa_kunnr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_kunnr-current,wa_kunnr-dmbtr1,wa_kunnr-dmbtr2,
                   wa_kunnr-dmbtr3,wa_kunnr-dmbtr4,wa_kunnr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_kunnr TO i_kunnr.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " PROCESS1_HKONT

*&---------------------------------------------------------------------*
*&      Form  PROSES_ALL1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_all1.
  CLEAR: wa_begbal.
  REFRESH i_brsch.
  LOOP AT i_begbal INTO wa_begbal.
    MOVE wa_begbal-gsber  TO wa_brsch-gsber.
    MOVE wa_begbal-brsch  TO wa_brsch-brsch.
    MOVE wa_begbal-shkzg  TO wa_brsch-shkzg.
    MOVE wa_begbal-monat  TO wa_brsch-monat.
    MOVE wa_begbal-blart  TO wa_brsch-blart.
    MOVE wa_begbal-dmbtr  TO wa_brsch-begbal.
*** Modify By Budi 10/03/2006
    MOVE wa_begbal-budat  TO wa_brsch-budat.
*** End Modify
    APPEND wa_brsch TO i_brsch.
    CLEAR: wa_begbal.
  ENDLOOP.

  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab.
    MOVE wa_itab-gsber    TO wa_brsch-gsber.
    MOVE wa_itab-brsch    TO wa_brsch-brsch.
    MOVE wa_itab-shkzg    TO wa_brsch-shkzg.
    MOVE wa_itab-gjahr    TO wa_brsch-gjahr.
    MOVE wa_itab-monat    TO wa_brsch-monat.
    MOVE wa_itab-blart    TO wa_brsch-blart.
    MOVE wa_itab-current  TO wa_brsch-current.
    MOVE wa_itab-dmbtr    TO wa_brsch-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_brsch-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_brsch-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_brsch-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_brsch-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_brsch-dmbtr5.
    wa_brsch-begbal = 0.
*** Modify By Budi 10/03/2006
    MOVE wa_itab-budat  TO wa_brsch-budat.
*** End Modify

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_brsch-current,wa_brsch-dmbtr1,wa_brsch-dmbtr2,
                 wa_brsch-dmbtr3,wa_brsch-dmbtr4,wa_brsch-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_brsch-current,wa_brsch-dmbtr1,wa_brsch-dmbtr2,
                   wa_brsch-dmbtr3,wa_brsch-dmbtr4,wa_brsch-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_brsch TO i_brsch.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " PROSES_ALL1

*&---------------------------------------------------------------------*
*&      Form  CETAK_DETAIL_ALL1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_detail_all1.
  DATA: zebra TYPE i,
        l_gstid(6).

  CLEAR: l_gstid.

  zebra = 0.
  va_count = 1.

  PERFORM cetak_header_brsch.

  CLEAR: wa_brsch.
*  SORT i_brsch BY brsch.
  SORT i_brsch ."BY brsch. "Modify By sol_jonhar 01/10/2020
  LOOP AT i_brsch INTO wa_brsch.
    IF wa_brsch-shkzg EQ 'S'.
      ADD wa_brsch-begbal TO va_begbal.
      ADD wa_brsch-current TO va_current.
      ADD wa_brsch-dmbtr1 TO va_dmbtr1.
      ADD wa_brsch-dmbtr2 TO va_dmbtr2.
      ADD wa_brsch-dmbtr3 TO va_dmbtr3.
      ADD wa_brsch-dmbtr4 TO va_dmbtr4.
      ADD wa_brsch-dmbtr5 TO va_dmbtr5.
    ELSE.
      va_begbal = va_begbal - wa_brsch-begbal.
      va_current = va_current - wa_brsch-current.
      va_dmbtr1 = va_dmbtr1 - wa_brsch-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_brsch-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_brsch-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_brsch-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_brsch-dmbtr5.
    ENDIF.

    CONCATENATE wa_brsch-gjahr wa_brsch-monat INTO l_gstid.

*    IF WA_BRSCH-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_brsch-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_brsch-blart NE 'DZ'.
      IF wa_brsch-shkzg EQ 'S'.
        ADD wa_brsch-dmbtr TO va_netsales.
      ELSE.
        va_netsales = va_netsales - wa_brsch-dmbtr.
      ENDIF.
    ENDIF.

*    IF WA_BRSCH-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_brsch-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_brsch-blart EQ 'DZ'.
      IF wa_brsch-shkzg EQ 'S'.
        ADD wa_brsch-dmbtr TO va_payment.
      ELSE.
        va_payment = va_payment - wa_brsch-dmbtr.
      ENDIF.
    ENDIF.

    AT END OF brsch.
      IF zebra = 0.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT COLOR 1.
        zebra = 0.
      ENDIF.

      SELECT SINGLE brtxt
        FROM t016t
        INTO va_brtxt
        WHERE brsch EQ wa_brsch-brsch.

      va_endbal = va_begbal + va_netsales + va_payment.
      ADD va_begbal   TO total_begbal.
      ADD va_netsales TO total_netsales.
      ADD va_payment  TO total_payment.
      ADD va_endbal   TO total_endbal.
      ADD va_current  TO total_current.
      ADD va_dmbtr1   TO total_dmbtr1.
      ADD va_dmbtr2   TO total_dmbtr2.
      ADD va_dmbtr3   TO total_dmbtr3.
      ADD va_dmbtr4   TO total_dmbtr4.
      ADD va_dmbtr5   TO total_dmbtr5.

      WRITE va_begbal TO va_begbal1 CURRENCY va_currency.
      MOVE wa_brsch-brsch TO va_brsch.

      IF va_begbal   NE 0 OR
         va_netsales NE 0 OR
         va_payment  NE 0 OR
         va_endbal   NE 0 OR
         va_current  NE 0 OR
         va_dmbtr1   NE 0 OR
         va_dmbtr2   NE 0 OR
         va_dmbtr3   NE 0 OR
         va_dmbtr4   NE 0 OR
         va_dmbtr5   NE 0.
        WRITE: /    sy-vline NO-GAP, va_brsch, '-', va_brtxt NO-GAP,
                    sy-vline, va_begbal CURRENCY va_currency,
                    sy-vline, va_netsales CURRENCY va_currency,
                    sy-vline, va_payment CURRENCY va_currency,
                    sy-vline, va_endbal CURRENCY va_currency,
                    sy-vline, va_current CURRENCY va_currency,
                    sy-vline, va_dmbtr1 CURRENCY va_currency,
                    sy-vline, va_dmbtr2 CURRENCY va_currency,
                    sy-vline, va_dmbtr3 CURRENCY va_currency,
                    sy-vline, va_dmbtr4 CURRENCY va_currency,
                    sy-vline, va_dmbtr5 CURRENCY va_currency,
                    sy-vline.
      ENDIF.

      CLEAR: va_begbal, va_netsales, va_payment, va_endbal, va_current,
             va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
    ENDAT.
    CLEAR: wa_brsch.
  ENDLOOP.
  FORMAT COLOR 3.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'Total',
          40  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_netsales CURRENCY va_currency,
              sy-vline, total_payment CURRENCY va_currency,
              sy-vline, total_endbal CURRENCY va_currency,
              sy-vline, total_current CURRENCY va_currency,
              sy-vline, total_dmbtr1 CURRENCY va_currency,
              sy-vline, total_dmbtr2 CURRENCY va_currency,
              sy-vline, total_dmbtr3 CURRENCY va_currency,
              sy-vline, total_dmbtr4 CURRENCY va_currency,
              sy-vline, total_dmbtr5 CURRENCY va_currency,
              sy-vline.
  WRITE: /    sy-uline(230).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED OFF.
  CLEAR: total_begbal, total_netsales, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.
ENDFORM.                    " CETAK_DETAIL_ALL1

*&---------------------------------------------------------------------*
*&      Form  PROSES_ALL2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proses_all2.
  CLEAR: wa_begbal.
  REFRESH i_hkont.
  LOOP AT i_begbal INTO wa_begbal.
    MOVE wa_begbal-gsber  TO wa_hkont-gsber.
    MOVE wa_begbal-hkont  TO wa_hkont-hkont.
    MOVE wa_begbal-shkzg  TO wa_hkont-shkzg.
    MOVE wa_begbal-monat  TO wa_hkont-monat.
    MOVE wa_begbal-blart  TO wa_hkont-blart.
    MOVE wa_begbal-dmbtr  TO wa_hkont-begbal.
*** Modify By Budi 10/03/2006
    MOVE wa_begbal-budat  TO wa_hkont-budat.
*** End Modify
    APPEND wa_hkont TO i_hkont.
    CLEAR: wa_begbal.
  ENDLOOP.

  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab.
    MOVE wa_itab-gsber    TO wa_hkont-gsber.
    MOVE wa_itab-hkont    TO wa_hkont-hkont.
    MOVE wa_itab-shkzg    TO wa_hkont-shkzg.
    MOVE wa_itab-gjahr    TO wa_hkont-gjahr.
    MOVE wa_itab-monat    TO wa_hkont-monat.
    MOVE wa_itab-blart    TO wa_hkont-blart.
    MOVE wa_itab-current  TO wa_hkont-current.
    MOVE wa_itab-dmbtr    TO wa_hkont-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_hkont-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_hkont-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_hkont-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_hkont-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_hkont-dmbtr5.
    wa_hkont-begbal = 0.
*** Modify By Budi 10/03/2006
    MOVE wa_itab-budat  TO wa_hkont-budat.
*** End Modify

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_hkont-current,wa_hkont-dmbtr1,wa_hkont-dmbtr2,
                 wa_hkont-dmbtr3,wa_hkont-dmbtr4,wa_hkont-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_hkont-current,wa_hkont-dmbtr1,wa_hkont-dmbtr2,
                   wa_hkont-dmbtr3,wa_hkont-dmbtr4,wa_hkont-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_hkont TO i_hkont.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " PROSES_ALL2

*&---------------------------------------------------------------------*
*&      Form  CETAK_DETAIL_ALL2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_detail_all2.
  DATA: zebra TYPE i,
        l_gstid(6).

  CLEAR: l_gstid.

  zebra = 0.
  va_count = 1.

  PERFORM cetak_header_hkont.

  CLEAR: wa_hkont.
*  SORT i_hkont BY hkont.
  SORT i_hkont." BY hkont. "Modify By sol_jonhar 01/10/2020
  LOOP AT i_hkont INTO wa_hkont.
    IF wa_hkont-shkzg EQ 'S'.
      ADD wa_hkont-begbal TO va_begbal.
      ADD wa_hkont-current TO va_current.
      ADD wa_hkont-dmbtr1 TO va_dmbtr1.
      ADD wa_hkont-dmbtr2 TO va_dmbtr2.
      ADD wa_hkont-dmbtr3 TO va_dmbtr3.
      ADD wa_hkont-dmbtr4 TO va_dmbtr4.
      ADD wa_hkont-dmbtr5 TO va_dmbtr5.
    ELSE.
      va_begbal = va_begbal - wa_hkont-begbal.
      va_current = va_current - wa_hkont-current.
      va_dmbtr1 = va_dmbtr1 - wa_hkont-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_hkont-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_hkont-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_hkont-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_hkont-dmbtr5.
    ENDIF.

    CONCATENATE wa_hkont-gjahr wa_hkont-monat INTO l_gstid.

*    IF WA_HKONT-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_hkont-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_hkont-blart NE 'DZ'.
      IF wa_hkont-shkzg EQ 'S'.
        ADD wa_hkont-dmbtr TO va_netsales.
      ELSE.
        va_netsales = va_netsales - wa_hkont-dmbtr.
      ENDIF.
    ENDIF.

*    IF WA_HKONT-MONAT EQ PA_GSTID+4(2) AND
*** Modify By Budi 10/03/2006
*    IF L_GSTID EQ PA_GSTID(6) AND
    IF wa_hkont-budat(6) EQ pa_gstid(6) AND
*** End Modify
       wa_hkont-blart EQ 'DZ'.
      IF wa_hkont-shkzg EQ 'S'.
        ADD wa_hkont-dmbtr TO va_payment.
      ELSE.
        va_payment = va_payment - wa_hkont-dmbtr.
      ENDIF.
    ENDIF.

    AT END OF hkont.
      IF zebra = 0.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT COLOR 1.
        zebra = 0.
      ENDIF.

      SELECT SINGLE txt20
        FROM skat
        INTO va_txt20
        WHERE spras EQ sy-langu  AND
              ktopl EQ 'TSPC'    AND
              saknr EQ wa_hkont-hkont.

      va_endbal = va_begbal + va_netsales + va_payment.
      ADD va_begbal   TO total_begbal.
      ADD va_netsales TO total_netsales.
      ADD va_payment  TO total_payment.
      ADD va_endbal   TO total_endbal.
      ADD va_current  TO total_current.
      ADD va_dmbtr1   TO total_dmbtr1.
      ADD va_dmbtr2   TO total_dmbtr2.
      ADD va_dmbtr3   TO total_dmbtr3.
      ADD va_dmbtr4   TO total_dmbtr4.
      ADD va_dmbtr5   TO total_dmbtr5.

      WRITE va_begbal TO va_begbal1 CURRENCY va_currency.
      MOVE wa_hkont-hkont TO va_hkont.

      IF va_begbal   NE 0 OR
         va_netsales NE 0 OR
         va_payment  NE 0 OR
         va_endbal   NE 0 OR
         va_current  NE 0 OR
         va_dmbtr1   NE 0 OR
         va_dmbtr2   NE 0 OR
         va_dmbtr3   NE 0 OR
         va_dmbtr4   NE 0 OR
         va_dmbtr5   NE 0.
        WRITE: /    sy-vline NO-GAP, va_hkont, '-', va_txt20 NO-GAP,
                    sy-vline, va_begbal CURRENCY va_currency,
                    sy-vline, va_netsales CURRENCY va_currency,
                    sy-vline, va_payment CURRENCY va_currency,
                    sy-vline, va_endbal CURRENCY va_currency,
                    sy-vline, va_current CURRENCY va_currency,
                    sy-vline, va_dmbtr1 CURRENCY va_currency,
                    sy-vline, va_dmbtr2 CURRENCY va_currency,
                    sy-vline, va_dmbtr3 CURRENCY va_currency,
                    sy-vline, va_dmbtr4 CURRENCY va_currency,
                    sy-vline, va_dmbtr5 CURRENCY va_currency,
                    sy-vline.
      ENDIF.

      CLEAR: va_begbal, va_netsales, va_payment, va_endbal, va_current,
             va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
    ENDAT.
    CLEAR: wa_hkont.
  ENDLOOP.
  FORMAT COLOR 3.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'Total',
          40  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_netsales CURRENCY va_currency,
              sy-vline, total_payment CURRENCY va_currency,
              sy-vline, total_endbal CURRENCY va_currency,
              sy-vline, total_current CURRENCY va_currency,
              sy-vline, total_dmbtr1 CURRENCY va_currency,
              sy-vline, total_dmbtr2 CURRENCY va_currency,
              sy-vline, total_dmbtr3 CURRENCY va_currency,
              sy-vline, total_dmbtr4 CURRENCY va_currency,
              sy-vline, total_dmbtr5 CURRENCY va_currency,
              sy-vline.
  WRITE: /    sy-uline(230).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED OFF.
  CLEAR: total_begbal, total_netsales, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.
ENDFORM.                    " CETAK_DETAIL_ALL2

*&---------------------------------------------------------------------*
*&      Form  F_GET_MODIFY
*&---------------------------------------------------------------------*
FORM f_get_modify  USING    fu_kunnr fu_gjahr fu_belnr fu_process
                   CHANGING fc_name1.

  DATA: lv_ktokd  TYPE kna1-ktokd.

  SELECT SINGLE name1 ktokd
    FROM kna1
    INTO (fc_name1, lv_ktokd)
    WHERE kunnr EQ fu_kunnr.

  CASE fu_process.
    WHEN 'PRINT'.
      IF lv_ktokd EQ 'ZONT' OR
        lv_ktokd EQ 'ONTC'.
        SELECT SINGLE name1
        FROM bsec
        INTO fc_name1
        WHERE bukrs EQ pa_bukrs AND
              belnr EQ fu_belnr AND
              gjahr EQ fu_gjahr.
      ENDIF.
    WHEN 'PROC'.
      IF lv_ktokd EQ 'ZONT' OR
        lv_ktokd EQ 'ONTC'.
        CONCATENATE fu_kunnr fu_belnr INTO fc_name1.
      ELSE.
        fc_name1  = fu_kunnr.
      ENDIF.
    WHEN 'ZUONR'.
      fc_name1  = lv_ktokd.
  ENDCASE.
ENDFORM.                    " F_GET_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_COLLECT_CLEARING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ITAB  text
*----------------------------------------------------------------------*
FORM f_collect_clearing  USING  fw_itab STRUCTURE wa_itab.
  i_augbl-augbl = fw_itab-augbl.
  CASE fw_itab-shkzg.
    WHEN 'H'.
      i_augbl-dmbtr = fw_itab-dmbtr * -1.
    WHEN 'S'.
      i_augbl-dmbtr = fw_itab-dmbtr.
  ENDCASE.
  COLLECT i_augbl. CLEAR i_augbl.
ENDFORM.                    " F_COLLECT_CLEARING

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_OBJKEY_KUNNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_objkey_kunnr .
  LOOP AT i_kunnr INTO wa_kunnr.
    IF wa_kunnr-objkey IS INITIAL.
      wa_kunnr-objkey = wa_kunnr-kunnr.
      MODIFY i_kunnr FROM wa_kunnr TRANSPORTING objkey.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_OBJKEY_KUNNR
*&---------------------------------------------------------------------*
*&      Form  F_INITIAL_BLART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initial_blart .
*            blart IN ('RV','ZA','DR','DA','DZ','SA','DG','AB',
*                      'D1', 'ZC','ZI','ZK').
  REFRESH: s_blart.
  s_blart-sign = 'I'.
  s_blart-low  = 'RV'. ",'ZA','DR','DA','DZ','SA','DG','AB',.
  s_blart-option = 'EQ'.
  APPEND s_blart.

  s_blart-sign = 'I'.
  s_blart-low  = 'ZA'. ",'DR','DA','DZ','SA','DG','AB',.
  s_blart-option = 'EQ'.
  APPEND s_blart.

  s_blart-sign = 'I'.
  s_blart-low  = 'DR'. ",'DA','DZ','SA','DG','AB',.
  s_blart-option = 'EQ'.
  APPEND s_blart.

  s_blart-sign = 'I'.
  s_blart-low  = 'DA'. ",'DZ','SA','DG','AB',.
  s_blart-option = 'EQ'.
  APPEND s_blart.

  s_blart-sign = 'I'.
  s_blart-low  = 'DZ'. ",'SA','DG','AB',.
  s_blart-option = 'EQ'.
  APPEND s_blart.

  s_blart-sign = 'I'.
  s_blart-low  = 'SA'. ",'DG','AB',.
  s_blart-option = 'EQ'.
  APPEND s_blart.

  s_blart-sign = 'I'.
  s_blart-low  = 'DG'. ",'AB',.
  s_blart-option = 'EQ'.
  APPEND s_blart.

  s_blart-sign = 'I'.
  s_blart-low  = 'AB'.
  s_blart-option = 'EQ'.
  APPEND s_blart.

  s_blart-sign = 'I'.
  s_blart-low  = 'D1'. ", 'ZC','ZI','ZK').
  s_blart-option = 'EQ'.
  APPEND s_blart.

  s_blart-sign = 'I'.
  s_blart-low  = 'ZC'. ",'ZI','ZK').
  s_blart-option = 'EQ'.

  APPEND s_blart.
  s_blart-sign = 'I'.
  s_blart-low  = 'ZI'. ",'ZK').
  s_blart-option = 'EQ'.
  APPEND s_blart.

  s_blart-sign = 'I'.
  s_blart-low  = 'ZK'.
  s_blart-option = 'EQ'.

ENDFORM.                    " F_INITIAL_BLART
