************************************************************************
*                  REPORT                                              *
*----------------------------------------------------------------------*
* ABAP Name   : ZFAP_AGING_TSP                                         *
* Created by  : Didik Imawan                                           *
* Created on  : 31/03/2003                                             *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description                   *
*                                                                      *
* 02/05/2005  Budi Pramono  Tambah Radiobutton Account ( HKONT )       *
* 01/10/2020  sol_jonhar    Modify sorting at end statement            *
*                           and ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020 syntax                   *                                                     *
************************************************************************
REPORT zfap_aging_tsp MESSAGE-ID zf
                      LINE-SIZE  232
                      LINE-COUNT 60
                      NO STANDARD PAGE HEADING.

INCLUDE zfap_aging_tsp_top.

INCLUDE zabp_atz.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS :
             pa_bukrs LIKE t001t-bukrs OBLIGATORY DEFAULT '8010'.
*                                          MODIF ID XXX.
SELECT-OPTIONS:
             so_gsber FOR bsik-gsber.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio3 RADIOBUTTON GROUP grp2 DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 6(26) text-010 FOR FIELD radio3.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS : so_lifnr FOR lfa1-lifnr MODIF ID zzz.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio4 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 6(26) text-011 FOR FIELD radio4.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS : so_brsch FOR lfa1-brsch NO INTERVALS.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio5 RADIOBUTTON GROUP grp2.
SELECTION-SCREEN : COMMENT 6(26) text-012 FOR FIELD radio5.
SELECTION-SCREEN POSITION 30.
SELECT-OPTIONS : so_hkont FOR bsik-hkont.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.

PARAMETERS:
             pa_gstid LIKE bsid-budat OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 1(10) text-002.
SELECTION-SCREEN :  POSITION 33.
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
SELECT-OPTIONS: so_umskz FOR bsik-umskz NO INTERVALS.
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

  PERFORM cek.
  SET PF-STATUS '100'.

  va_monat1 = pa_gstid+4(2).
  va_monat2 = pa_gstid+4(2) + 1.

  IF va_monat2 > 12.
    va_monat2 = va_monat2 - 12.
    va_gjahr  = pa_gstid(4) + 1.
  ELSE.
    va_gjahr  = pa_gstid(4).
  ENDIF.

  CONCATENATE pa_gstid(4) va_monat1 '01' INTO va_gerdat1.
  CONCATENATE va_gjahr va_monat2 '01' INTO va_gerdat2.

*  Perform f_initial_blart.
  REFRESH: s_blart.
  m_range: 'KA','KG','KR','KZ','RC','RE','SA','OP','AB','K1', 'ZX', 'ZY','ZZ'.

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
    va_currency = pa_waers.
  ENDIF.

  PERFORM process_data.
  PERFORM cetak_gsber.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&        AT USER-COMMAND
*&---------------------------------------------------------------------*
AT USER-COMMAND.
  CASE sy-ucomm.
    WHEN 'CHOOSE'.
      READ CURRENT LINE FIELD VALUE: va_gtext, va_lifnr, va_brsch,
                                     va_begbal1, va_lifnr1, va_brsch1,
                                     va_belnr, va_gjahr1, va_zuonr,
                                     va_hkont.
      DATA : ffield(20), fvalue(20).
      GET CURSOR FIELD ffield VALUE fvalue.
      CASE ffield.
        WHEN 'VA_GTEXT'.
          SELECT SINGLE *
             FROM tgsbt
             WHERE gtext EQ va_gtext.
          IF radio3 EQ 'X'.
            counter = 0.
            PERFORM lifnr_process.
            PERFORM cetak_detail_lifnr USING '1'.
          ENDIF.
          IF radio4 EQ 'X'.
            counter = 0.
            PERFORM brsch_process.
            PERFORM cetak_detail_brsch.
          ENDIF.
          IF radio5 EQ 'X'.
            counter = 0.
            PERFORM hkont_process.
            PERFORM cetak_detail_hkont.
          ENDIF.

        WHEN 'VA_LIFNR'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = va_lifnr
            IMPORTING
              output = va_lifnr.
          IF va_count EQ 0.
            PERFORM zuonr_process.
            PERFORM cetak_detail_zuonr.
          ELSE.
            PERFORM zuonr_process1.
            PERFORM cetak_detail_zuonr1.
          ENDIF.

        WHEN 'VA_LIFNR1'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = va_lifnr1
            IMPORTING
              output = va_lifnr1.
          PERFORM zuonr_process_total.
          PERFORM cetak_detail_zuonr_total.

        WHEN 'VA_BRSCH'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = va_brsch
            IMPORTING
              output = va_brsch.
          IF va_count EQ 0.
            PERFORM lifnr_process_1.
            PERFORM cetak_detail_lifnr USING '2'.
          ELSE.
            PERFORM lifnr_process_11.
            PERFORM cetak_detail_lifnr USING '2'.
          ENDIF.

        WHEN 'VA_BRSCH1'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = va_brsch1
            IMPORTING
              output = va_brsch1.
          PERFORM lifnr_process_1_total.
          PERFORM cetak_detail_lifnr_total.

        WHEN 'VA_HKONT'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = va_hkont
            IMPORTING
              output = va_hkont.
          IF va_count EQ 0.
            PERFORM lifnr_process_2.
            PERFORM cetak_detail_lifnr USING '2'.
          ELSE.
            PERFORM lifnr_process_21.
            PERFORM cetak_detail_lifnr USING '2'.
          ENDIF.

        WHEN 'VA_HKONT1'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = va_hkont1
            IMPORTING
              output = va_hkont1.
          PERFORM lifnr_process_2_total.
          PERFORM cetak_detail_lifnr_total.

        WHEN 'VA_ZUONR'.
          SET PARAMETER ID 'BLN' FIELD va_belnr.
          SET PARAMETER ID 'BUK' FIELD pa_bukrs.
          SET PARAMETER ID 'GJR' FIELD va_gjahr1.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDCASE.

    WHEN 'BUSINESS'.
      PERFORM cetak_gsber.

    WHEN 'ALL'.
      IF radio3 EQ 'X'.
        counter = 1.
        va_count = 1.
        PERFORM lifnr_process1.
        PERFORM cetak_detail_lifnr USING '1'.
      ENDIF.
      IF radio4 EQ 'X'.
        counter = 1.
        va_count = 1.
        PERFORM brsch_process1.
        PERFORM cetak_detail_brsch.
      ENDIF.
      IF radio5 EQ 'X'.
        counter = 1.
        va_count = 1.
        PERFORM hkont_process1.
        PERFORM cetak_detail_hkont.
      ENDIF.

    WHEN 'EXIT' OR 'CANCL'.
      LEAVE TO SCREEN 0.
  ENDCASE.

**&---------------------------------------------------------------------
*
**&        AT LINE-SELECTION
**&---------------------------------------------------------------------
*
*  AT LINE-SELECTION.
*    READ CURRENT LINE FIELD VALUE: VA_GTEXT, VA_LIFNR, VA_BRSCH,
*                                   VA_BEGBAL1, VA_LIFNR1, VA_BRSCH1.
*    DATA : FFIELD(20), FVALUE(20).
*    GET CURSOR FIELD FFIELD VALUE FVALUE.
*    CASE FFIELD.
*       WHEN 'VA_GTEXT'.
*          SELECT SINGLE *
*             FROM TGSBT
*             WHERE GTEXT EQ VA_GTEXT.
*               IF RADIO3 EQ 'X'.
*                 COUNTER = 0.
*                 PERFORM LIFNR_PROCESS.
*                 PERFORM CETAK_DETAIL_LIFNR.
*               ENDIF.
*               IF RADIO4 EQ 'X'.
*                 COUNTER = 0.
*                 PERFORM BRSCH_PROCESS.
*                 PERFORM CETAK_DETAIL_BRSCH.
*               ENDIF.
*
*       WHEN 'VA_LIFNR'.
*         PERFORM ZUONR_PROCESS.
*         PERFORM CETAK_DETAIL_ZUONR.
*
*       WHEN 'VA_LIFNR1'.
*         PERFORM ZUONR_PROCESS_TOTAL.
*         PERFORM CETAK_DETAIL_ZUONR_TOTAL.
*
*       WHEN 'VA_BRSCH'.
*         PERFORM LIFNR_PROCESS_1.
*         PERFORM CETAK_DETAIL_LIFNR.
*
*       WHEN 'VA_BRSCH1'.
*         PERFORM LIFNR_PROCESS_1_TOTAL.
*         PERFORM CETAK_DETAIL_LIFNR_TOTAL.
*    ENDCASE.
*
*    CASE FVALUE.
*      WHEN 'Grand Total'.
*        IF RADIO3 EQ 'X'.
*          COUNTER = 1.
*          PERFORM LIFNR_PROCESS_TOTAL.
*          PERFORM CETAK_DETAIL_LIFNR.
*        ENDIF.
*        IF RADIO4 EQ 'X'.
*          COUNTER = 1.
*          PERFORM BRSCH_PROCESS_TOTAL.
*          PERFORM CETAK_DETAIL_BRSCH.
*        ENDIF.
*    ENDCASE.

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
      FROM bsik
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            lifnr IN so_lifnr AND
            gsber IN so_gsber AND
            umskz IN so_umskz AND
            budat LE pa_gstid AND
*            bldat LE pa_gstid AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').

    SELECT *
      FROM bsak
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            lifnr IN so_lifnr   AND
            gsber IN so_gsber   AND
            umskz IN so_umskz   AND
            budat LE pa_gstid   AND
*            bldat LE pa_gstid AND
            augdt GE va_gerdat1 AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').
  ENDIF.

  IF x_norm EQ 'X' AND
     x_shbv EQ space.
    SELECT *
      FROM bsik
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            umskz EQ space    AND
            lifnr IN so_lifnr AND
            gsber IN so_gsber AND
            budat LE pa_gstid AND
*            bldat LE pa_gstid AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').

    SELECT *
      FROM bsak
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            umskz EQ space      AND
            lifnr IN so_lifnr   AND
            gsber IN so_gsber   AND
            budat LE pa_gstid   AND
*            bldat LE pa_gstid   AND
            augdt GE va_gerdat1 AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').
  ENDIF.

  IF x_norm EQ space AND
     x_shbv EQ 'X'   AND
     so_umskz EQ space.
    SELECT *
      FROM bsik
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            umskz NE space    AND
            lifnr IN so_lifnr AND
            gsber IN so_gsber AND
            budat LE pa_gstid AND
*            bldat LE pa_gstid AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').

    SELECT *
      FROM bsak
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            umskz NE space      AND
            lifnr IN so_lifnr   AND
            gsber IN so_gsber   AND
            budat LE pa_gstid   AND
*            bldat LE pa_gstid   AND
            augdt GE va_gerdat1 AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').
  ENDIF.

  IF x_norm EQ space AND
     x_shbv EQ 'X'   AND
     so_umskz NE space.
    SELECT *
      FROM bsik
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            lifnr IN so_lifnr AND
            gsber IN so_gsber AND
            umskz IN so_umskz AND
            budat LE pa_gstid AND
*            bldat LE pa_gstid AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').

    SELECT *
      FROM bsak
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            lifnr IN so_lifnr   AND
            gsber IN so_gsber   AND
            umskz IN so_umskz   AND
            budat LE pa_gstid   AND
*            bldat LE pa_gstid   AND
            augdt GE va_gerdat1 AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').
  ENDIF.
ENDFORM.                    " GET_DATA_RADIO1

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
      FROM bsik
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            lifnr IN so_lifnr AND
            gsber IN so_gsber AND
            umskz IN so_umskz AND
            budat LE pa_gstid AND
*            BLDAT LE PA_GSTID AND
            waers EQ pa_waers AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').

    SELECT *
      FROM bsak
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            lifnr IN so_lifnr   AND
            gsber IN so_gsber   AND
            umskz IN so_umskz   AND
            budat LE pa_gstid   AND
*            BLDAT LE PA_GSTID   AND
            augdt GE va_gerdat1 AND
            waers EQ pa_waers   AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').
  ENDIF.

  IF x_norm EQ 'X' AND
     x_shbv EQ space.
    SELECT *
      FROM bsik
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            umskz EQ space    AND
            lifnr IN so_lifnr AND
            gsber IN so_gsber AND
            budat LE pa_gstid AND
*            BLDAT LE PA_GSTID AND
            waers EQ pa_waers AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').

    SELECT *
      FROM bsak
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            umskz EQ space      AND
            lifnr IN so_lifnr   AND
            gsber IN so_gsber   AND
            budat LE pa_gstid   AND
*            BLDAT LE PA_GSTID   AND
            augdt GE va_gerdat1 AND
            waers EQ pa_waers   AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').
  ENDIF.

  IF x_norm EQ space AND
     x_shbv EQ 'X'   AND
     so_umskz EQ space.
    SELECT *
      FROM bsik
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            umskz NE space    AND
            lifnr IN so_lifnr AND
            gsber IN so_gsber AND
            budat LE pa_gstid AND
*            BLDAT LE PA_GSTID AND
            waers EQ pa_waers AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').

    SELECT *
      FROM bsak
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            umskz NE space      AND
            lifnr IN so_lifnr   AND
            gsber IN so_gsber   AND
            budat LE pa_gstid   AND
*            BLDAT LE PA_GSTID   AND
            augdt GE va_gerdat1 AND
            waers EQ pa_waers   AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').
  ENDIF.

  IF x_norm EQ space AND
     x_shbv EQ 'X'   AND
     so_umskz NE space.
    SELECT *
      FROM bsik
      INTO CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs AND
            hkont IN so_hkont AND
            lifnr IN so_lifnr AND
            gsber IN so_gsber AND
            umskz IN so_umskz AND
            budat LE pa_gstid AND
*            BLDAT LE PA_GSTID AND
            waers EQ pa_waers AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').

    SELECT *
      FROM bsak
      APPENDING CORRESPONDING FIELDS OF TABLE i_itab
      WHERE bukrs EQ pa_bukrs   AND
            hkont IN so_hkont   AND
            lifnr IN so_lifnr   AND
            gsber IN so_gsber   AND
            umskz IN so_umskz   AND
            budat LE pa_gstid   AND
*            BLDAT LE PA_GSTID   AND
            augdt GE va_gerdat1 AND
            waers EQ pa_waers   AND
            blart IN s_blart.
*            blart IN ('KA','KG','KR','KZ','RC','RE','SA','OP','AB',
*                      'K1').
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
  DATA: jatuh_tempo TYPE i.

  APPEND LINES OF i_itab TO i_itab_ka.
  DELETE i_itab_ka WHERE blart NE 'KA'.
  SORT i_itab_ka BY augbl gsber lifnr.

  APPEND LINES OF i_itab TO i_itab_kg.
  DELETE i_itab_kg WHERE blart NE 'KG'.
  SORT i_itab_kg BY augbl gsber lifnr.

  APPEND LINES OF i_itab TO i_itab_kr.
  DELETE i_itab_kr WHERE blart NE 'KR'.
  SORT i_itab_kr BY augbl gsber lifnr.

  APPEND LINES OF i_itab TO i_itab_rc.
  DELETE i_itab_rc WHERE blart NE 'RC'.
  SORT i_itab_rc BY augbl gsber lifnr.

  APPEND LINES OF i_itab TO i_itab_re.
  DELETE i_itab_re WHERE blart NE 'RE'.
  SORT i_itab_re BY augbl gsber lifnr.

  APPEND LINES OF i_itab TO i_itab_sa.
  DELETE i_itab_sa WHERE blart NE 'SA'.
  SORT i_itab_sa BY augbl gsber lifnr.

  APPEND LINES OF i_itab TO i_itab_op.
  DELETE i_itab_op WHERE blart NE 'OP'.
  SORT i_itab_op BY augbl gsber lifnr.

*** Modify By Budi 10/03/2006
  APPEND LINES OF i_itab TO i_itab_k1.
  DELETE i_itab_k1 WHERE blart NE 'K1'.
  SORT i_itab_k1 BY augbl gsber lifnr.

  APPEND LINES OF i_itab TO i_itab_kz.
  DELETE i_itab_kz WHERE blart NE 'KZ'.
  SORT i_itab_kz BY augbl gsber lifnr.
*** End Modify

*** Modify By Budi 26/07/2006
  APPEND LINES OF i_itab TO i_itab_ab.
  DELETE i_itab_ab WHERE blart NE 'AB'.
  SORT i_itab_ab BY augbl gsber lifnr.
*** End Modify By Budi 26/07/2006

  APPEND LINES OF i_itab TO i_itab_zx.
  DELETE i_itab_zx WHERE blart NE 'ZX'.
  SORT i_itab_zx BY augbl gsber lifnr.

  APPEND LINES OF i_itab TO i_itab_zy.
  DELETE i_itab_zy WHERE blart NE 'ZY'.
  SORT i_itab_zy BY augbl gsber lifnr.

  APPEND LINES OF i_itab TO i_itab_zz.
  DELETE i_itab_zz WHERE blart NE 'ZZ'.
  SORT i_itab_zz BY augbl gsber lifnr.

  CLEAR: wa_itab.
*  SORT i_itab BY augbl gsber lifnr.
  SORT i_itab." BY augbl gsber lifnr. "Modify by sol_jonhar 01/10/2020
  LOOP AT i_itab INTO wa_itab.
    SELECT SINGLE name1 brsch
      FROM lfa1
      INTO (wa_itab-name1, wa_itab-brsch)
      WHERE lifnr EQ wa_itab-lifnr.

    PERFORM get_date_kz.

    IF wa_itab-augbl NE space.
      wa_itab-zfbdt = wa_itab-augdt.
      PERFORM f_collect_clearing USING wa_itab.
    ENDIF.

*** Modify By Budi 10/03/2006
*      JATUH_TEMPO = PA_GSTID - WA_ITAB-ZFBDT.
    IF pa_bukrs = '8330' OR pa_bukrs = '8360'.
      jatuh_tempo = pa_gstid - wa_itab-budat.
    ELSE.
      jatuh_tempo = pa_gstid - wa_itab-bldat.
    ENDIF.
*** End Modify
    jatuh_tempo = jatuh_tempo - wa_itab-zbd1t.

*    IF WA_ITAB-BLART NE 'KZ'  AND
*      WA_ITAB-AUGBL EQ SPACE.
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
*    ENDIF.

*** Modify By Budi 10/03/2006
    IF NOT va_clear IS INITIAL AND wa_itab-blart EQ 'KZ'.
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

  IF radio4 EQ 'X'.
    CLEAR: wa_itab.
*    SORT i_itab BY gsber brsch.
    SORT i_itab." BY gsber brsch. "Modify by sol_jonhar 01/10/2020
    LOOP AT i_itab INTO wa_itab
      WHERE brsch IN so_brsch.
      wa_itab1-gsber   = wa_itab-gsber.
      wa_itab1-brsch   = wa_itab-brsch.
      wa_itab1-lifnr   = wa_itab-lifnr.
      wa_itab1-gjahr   = wa_itab-gjahr.
      wa_itab1-name1   = wa_itab-name1.
      wa_itab1-blart   = wa_itab-blart.
      wa_itab1-zuonr   = wa_itab-zuonr.
      wa_itab1-belnr   = wa_itab-belnr.
      wa_itab1-monat   = wa_itab-monat.
      wa_itab1-budat   = wa_itab-budat.
      wa_itab1-bldat   = wa_itab-bldat.
      wa_itab1-augdt   = wa_itab-augdt.
      wa_itab1-zfbdt   = wa_itab-zfbdt.
      wa_itab1-zbd1t   = wa_itab-zbd1t.
      wa_itab1-shkzg   = wa_itab-shkzg.
      wa_itab1-zbd1tx  = wa_itab-zbd1tx.
      wa_itab1-current = wa_itab-current.
      wa_itab1-wrbtr   = wa_itab-wrbtr.
      wa_itab1-dmbtr   = wa_itab-dmbtr.
      wa_itab1-dmbtr1  = wa_itab-dmbtr1.
      wa_itab1-dmbtr2  = wa_itab-dmbtr2.
      wa_itab1-dmbtr3  = wa_itab-dmbtr3.
      wa_itab1-dmbtr4  = wa_itab-dmbtr4.
      wa_itab1-dmbtr5  = wa_itab-dmbtr5.
      APPEND wa_itab1 TO i_itab1.
    ENDLOOP.
  ENDIF.

  IF radio3 EQ 'X'.
    CLEAR: wa_itab.
*    SORT i_itab BY gsber lifnr.
    SORT i_itab." BY gsber lifnr. "Modify by sol_jonhar 01/10/2020
    LOOP AT i_itab INTO wa_itab.
      IF wa_itab-shkzg EQ 'S'.
        ADD wa_itab-current TO va_current.
        ADD wa_itab-dmbtr1 TO va_dmbtr1.
        ADD wa_itab-dmbtr2 TO va_dmbtr2.
        ADD wa_itab-dmbtr3 TO va_dmbtr3.
        ADD wa_itab-dmbtr4 TO va_dmbtr4.
        ADD wa_itab-dmbtr5 TO va_dmbtr5.
        IF wa_itab-budat(6) LT pa_gstid(6).
*        IF wa_itab-bldat(6) LT pa_gstid(6).
          ADD wa_itab-dmbtr TO va_begbal.
        ENDIF.
        IF wa_itab-blart NE 'KZ'.
          IF wa_itab-budat GE va_gerdat1 AND
             wa_itab-budat LT va_gerdat2.
*          IF wa_itab-bldat GE va_gerdat1 AND
*             wa_itab-bldat LT va_gerdat2.
            ADD wa_itab-dmbtr TO va_purchase.
          ENDIF.
        ELSE.
          IF wa_itab-budat GE va_gerdat1 AND
             wa_itab-budat LT va_gerdat2.
*          IF wa_itab-bldat GE va_gerdat1 AND
*             wa_itab-bldat LT va_gerdat2.
            ADD wa_itab-dmbtr TO va_payment.
          ENDIF.
        ENDIF.
      ELSE.
        va_current = va_current - wa_itab-current.
        va_dmbtr1 = va_dmbtr1 - wa_itab-dmbtr1.
        va_dmbtr2 = va_dmbtr2 - wa_itab-dmbtr2.
        va_dmbtr3 = va_dmbtr3 - wa_itab-dmbtr3.
        va_dmbtr4 = va_dmbtr4 - wa_itab-dmbtr4.
        va_dmbtr5 = va_dmbtr5 - wa_itab-dmbtr5.
        IF wa_itab-budat(6) LT pa_gstid(6).
*        IF wa_itab-bldat(6) LT pa_gstid(6).
          va_begbal = va_begbal - wa_itab-dmbtr.
        ENDIF.
        IF wa_itab-blart NE 'KZ'.
          IF wa_itab-budat GE va_gerdat1 AND
             wa_itab-budat LT va_gerdat2.
*          IF wa_itab-bldat GE va_gerdat1 AND
*             wa_itab-bldat LT va_gerdat2.
            va_purchase = va_purchase - wa_itab-dmbtr.
          ENDIF.
        ELSE.
          IF wa_itab-budat GE va_gerdat1 AND
             wa_itab-budat LT va_gerdat2.
*          IF wa_itab-bldat GE va_gerdat1 AND
*             wa_itab-bldat LT va_gerdat2.
            va_payment = va_payment - wa_itab-dmbtr.
          ENDIF.
        ENDIF.
      ENDIF.

      AT END OF gsber.
        wa_gsber-endbal = va_begbal + va_purchase + va_payment.
        SELECT SINGLE gtext
          FROM tgsbt
          INTO wa_gsber-gtext
          WHERE gsber EQ wa_itab-gsber.
        MOVE wa_itab-gsber TO wa_gsber-gsber.
        MOVE va_begbal   TO wa_gsber-begbal.
        MOVE va_purchase TO wa_gsber-purchase.
        MOVE va_payment  TO wa_gsber-payment.
        MOVE va_current  TO wa_gsber-current.
        MOVE va_dmbtr1   TO wa_gsber-dmbtr1.
        MOVE va_dmbtr2   TO wa_gsber-dmbtr2.
        MOVE va_dmbtr3   TO wa_gsber-dmbtr3.
        MOVE va_dmbtr4   TO wa_gsber-dmbtr4.
        MOVE va_dmbtr5   TO wa_gsber-dmbtr5.
        APPEND wa_gsber TO i_gsber.
        CLEAR: wa_gsber, va_begbal, va_purchase, va_payment, va_current,
               va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
      ENDAT.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.

  IF radio4 EQ 'X'.
    CLEAR: wa_itab1.
*    SORT i_itab1 BY gsber brsch.
    SORT i_itab1." BY gsber brsch. "Modify by sol_jonhar 01/10/2020
    LOOP AT i_itab1 INTO wa_itab1.
      IF wa_itab1-shkzg EQ 'S'.
        ADD wa_itab1-current TO va_current.
        ADD wa_itab1-dmbtr1 TO va_dmbtr1.
        ADD wa_itab1-dmbtr2 TO va_dmbtr2.
        ADD wa_itab1-dmbtr3 TO va_dmbtr3.
        ADD wa_itab1-dmbtr4 TO va_dmbtr4.
        ADD wa_itab1-dmbtr5 TO va_dmbtr5.
        IF wa_itab1-budat(6) LT pa_gstid(6).
*        IF wa_itab1-bldat(6) LT pa_gstid(6).
          ADD wa_itab1-dmbtr TO va_begbal.
        ENDIF.
        IF wa_itab1-blart NE 'KZ'.
          IF wa_itab1-budat GE va_gerdat1.
*          IF wa_itab1-bldat GE va_gerdat1.
            ADD wa_itab1-dmbtr TO va_purchase.
          ENDIF.
        ELSE.
          IF wa_itab1-budat GE va_gerdat1 AND
             wa_itab1-budat LT va_gerdat2.
*          IF wa_itab1-bldat GE va_gerdat1 AND
*             wa_itab1-bldat LT va_gerdat2.
            ADD wa_itab1-dmbtr TO va_payment.
          ENDIF.
        ENDIF.
      ELSE.
        va_current = va_current - wa_itab1-current.
        va_dmbtr1 = va_dmbtr1 - wa_itab1-dmbtr1.
        va_dmbtr2 = va_dmbtr2 - wa_itab1-dmbtr2.
        va_dmbtr3 = va_dmbtr3 - wa_itab1-dmbtr3.
        va_dmbtr4 = va_dmbtr4 - wa_itab1-dmbtr4.
        va_dmbtr5 = va_dmbtr5 - wa_itab1-dmbtr5.
        IF wa_itab1-budat(6) LT pa_gstid(6).
*        IF wa_itab1-bldat(6) LT pa_gstid(6).
          va_begbal = va_begbal - wa_itab1-dmbtr.
        ENDIF.
        IF wa_itab1-blart NE 'KZ'.
          IF wa_itab1-budat GE va_gerdat1 AND
             wa_itab1-budat LT va_gerdat2.
*          IF wa_itab1-bldat GE va_gerdat1 AND
*             wa_itab1-bldat LT va_gerdat2.
            va_purchase = va_purchase - wa_itab1-dmbtr.
          ENDIF.
        ELSE.
          IF wa_itab1-budat GE va_gerdat1 AND
             wa_itab1-budat LT va_gerdat2.
*          IF wa_itab1-bldat GE va_gerdat1 AND
*             wa_itab1-bldat LT va_gerdat2.
            va_payment = va_payment - wa_itab1-dmbtr.
          ENDIF.
        ENDIF.
      ENDIF.

      AT END OF gsber.
        wa_gsber-endbal = va_begbal + va_purchase + va_payment.
        SELECT SINGLE gtext
          FROM tgsbt
          INTO wa_gsber-gtext
          WHERE gsber EQ wa_itab1-gsber.
        MOVE wa_itab1-gsber TO wa_gsber-gsber.
        MOVE va_begbal   TO wa_gsber-begbal.
        MOVE va_purchase TO wa_gsber-purchase.
        MOVE va_payment  TO wa_gsber-payment.
        MOVE va_current  TO wa_gsber-current.
        MOVE va_dmbtr1   TO wa_gsber-dmbtr1.
        MOVE va_dmbtr2   TO wa_gsber-dmbtr2.
        MOVE va_dmbtr3   TO wa_gsber-dmbtr3.
        MOVE va_dmbtr4   TO wa_gsber-dmbtr4.
        MOVE va_dmbtr5   TO wa_gsber-dmbtr5.
        APPEND wa_gsber TO i_gsber.
        CLEAR: wa_gsber, va_begbal, va_purchase, va_payment, va_current,
               va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
      ENDAT.
      CLEAR: wa_itab1.
    ENDLOOP.
  ENDIF.

  IF radio5 EQ 'X'.
    CLEAR: wa_itab.
*    SORT i_itab BY gsber hkont.
    SORT i_itab. "BY gsber hkont. "Modify by sol_jonhar 01/10/2020
    LOOP AT i_itab INTO wa_itab.
      IF wa_itab-shkzg EQ 'S'.
        ADD wa_itab-current TO va_current.
        ADD wa_itab-dmbtr1 TO va_dmbtr1.
        ADD wa_itab-dmbtr2 TO va_dmbtr2.
        ADD wa_itab-dmbtr3 TO va_dmbtr3.
        ADD wa_itab-dmbtr4 TO va_dmbtr4.
        ADD wa_itab-dmbtr5 TO va_dmbtr5.
        IF wa_itab-budat(6) LT pa_gstid(6).
*        IF wa_itab-bldat(6) LT pa_gstid(6).
          ADD wa_itab-dmbtr TO va_begbal.
        ENDIF.
        IF wa_itab-blart NE 'KZ'.
          IF wa_itab-budat GE va_gerdat1 AND
             wa_itab-budat LT va_gerdat2.
*          IF wa_itab-bldat GE va_gerdat1 AND
*             wa_itab-bldat LT va_gerdat2.
            ADD wa_itab-dmbtr TO va_purchase.
          ENDIF.
        ELSE.
          IF wa_itab-budat GE va_gerdat1 AND
             wa_itab-budat LT va_gerdat2.
*          IF wa_itab-bldat GE va_gerdat1 AND
*             wa_itab-bldat LT va_gerdat2.
            ADD wa_itab-dmbtr TO va_payment.
          ENDIF.
        ENDIF.
      ELSE.
        va_current = va_current - wa_itab-current.
        va_dmbtr1 = va_dmbtr1 - wa_itab-dmbtr1.
        va_dmbtr2 = va_dmbtr2 - wa_itab-dmbtr2.
        va_dmbtr3 = va_dmbtr3 - wa_itab-dmbtr3.
        va_dmbtr4 = va_dmbtr4 - wa_itab-dmbtr4.
        va_dmbtr5 = va_dmbtr5 - wa_itab-dmbtr5.
        IF wa_itab-budat(6) LT pa_gstid(6).
*        IF wa_itab-bldat(6) LT pa_gstid(6).
          va_begbal = va_begbal - wa_itab-dmbtr.
        ENDIF.
        IF wa_itab-blart NE 'KZ'.
          IF wa_itab-budat GE va_gerdat1 AND
             wa_itab-budat LT va_gerdat2.
*          IF wa_itab-bldat GE va_gerdat1 AND
*             wa_itab-bldat LT va_gerdat2.
            va_purchase = va_purchase - wa_itab-dmbtr.
          ENDIF.
        ELSE.
          IF wa_itab-budat GE va_gerdat1 AND
             wa_itab-budat LT va_gerdat2.
*          IF wa_itab-bldat GE va_gerdat1 AND
*             wa_itab-bldat LT va_gerdat2.
            va_payment = va_payment - wa_itab-dmbtr.
          ENDIF.
        ENDIF.
      ENDIF.

      AT END OF gsber.
        wa_gsber-endbal = va_begbal + va_purchase + va_payment.
        SELECT SINGLE gtext
          FROM tgsbt
          INTO wa_gsber-gtext
          WHERE gsber EQ wa_itab-gsber.
        MOVE wa_itab-gsber TO wa_gsber-gsber.
        MOVE va_begbal   TO wa_gsber-begbal.
        MOVE va_purchase TO wa_gsber-purchase.
        MOVE va_payment  TO wa_gsber-payment.
        MOVE va_current  TO wa_gsber-current.
        MOVE va_dmbtr1   TO wa_gsber-dmbtr1.
        MOVE va_dmbtr2   TO wa_gsber-dmbtr2.
        MOVE va_dmbtr3   TO wa_gsber-dmbtr3.
        MOVE va_dmbtr4   TO wa_gsber-dmbtr4.
        MOVE va_dmbtr5   TO wa_gsber-dmbtr5.
        APPEND wa_gsber TO i_gsber.
        CLEAR: wa_gsber, va_begbal, va_purchase, va_payment, va_current,
               va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
      ENDAT.
      CLEAR: wa_itab.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  LIFNR_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lifnr_process.
  SORT i_itab BY lifnr.
  REFRESH i_lifnr.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE gsber EQ tgsbt-gsber AND
          lifnr IN so_lifnr.
    MOVE wa_itab-gsber    TO wa_lifnr-gsber.
    MOVE wa_itab-budat    TO wa_lifnr-budat.
    MOVE wa_itab-bldat    TO wa_lifnr-bldat.
    MOVE wa_itab-augdt    TO wa_lifnr-augdt.
    MOVE wa_itab-lifnr    TO wa_lifnr-lifnr.
    MOVE wa_itab-shkzg    TO wa_lifnr-shkzg.
    MOVE wa_itab-monat    TO wa_lifnr-monat.
    MOVE wa_itab-blart    TO wa_lifnr-blart.
    MOVE wa_itab-current  TO wa_lifnr-current.
    MOVE wa_itab-dmbtr    TO wa_lifnr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_lifnr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_lifnr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_lifnr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_lifnr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_lifnr-dmbtr5.
    MOVE wa_itab-belnr    TO wa_lifnr-belnr.
    MOVE wa_itab-gjahr    TO wa_lifnr-gjahr.

    PERFORM f_get_modify USING wa_lifnr-lifnr wa_lifnr-gjahr wa_lifnr-belnr 'PROC'
                         CHANGING wa_lifnr-objkey.

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                 wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                   wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_lifnr TO i_lifnr.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " LIFNR_PROCESS

*&---------------------------------------------------------------------*
*&      Form  LIFNR_PROCESS_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lifnr_process_1.
  REFRESH i_lifnr.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE gsber EQ tgsbt-gsber AND
          brsch EQ va_brsch.
    MOVE wa_itab-gsber    TO wa_lifnr-gsber.
    MOVE wa_itab-budat    TO wa_lifnr-budat.
    MOVE wa_itab-bldat    TO wa_lifnr-bldat.
    MOVE wa_itab-augdt    TO wa_lifnr-augdt.
    MOVE wa_itab-lifnr    TO wa_lifnr-lifnr.
    MOVE wa_itab-shkzg    TO wa_lifnr-shkzg.
    MOVE wa_itab-monat    TO wa_lifnr-monat.
    MOVE wa_itab-blart    TO wa_lifnr-blart.
    MOVE wa_itab-current  TO wa_lifnr-current.
    MOVE wa_itab-dmbtr    TO wa_lifnr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_lifnr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_lifnr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_lifnr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_lifnr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_lifnr-dmbtr5.
    MOVE wa_itab-belnr    TO wa_lifnr-belnr.
    MOVE wa_itab-gjahr    TO wa_lifnr-gjahr.

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                 wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                   wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_lifnr TO i_lifnr.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " LIFNR_PROCESS_1

*&---------------------------------------------------------------------*
*&      Form  LIFNR_PROCESS_1_TOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lifnr_process_1_total.
  REFRESH i_lifnr.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE brsch EQ va_brsch1.
    MOVE wa_itab-gsber    TO wa_lifnr-gsber.
    MOVE wa_itab-budat    TO wa_lifnr-budat.
    MOVE wa_itab-bldat    TO wa_lifnr-bldat.
    MOVE wa_itab-augdt    TO wa_lifnr-augdt.
    MOVE wa_itab-lifnr    TO wa_lifnr-lifnr.
    MOVE wa_itab-shkzg    TO wa_lifnr-shkzg.
    MOVE wa_itab-monat    TO wa_lifnr-monat.
    MOVE wa_itab-blart    TO wa_lifnr-blart.
    MOVE wa_itab-current  TO wa_lifnr-current.
    MOVE wa_itab-dmbtr    TO wa_lifnr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_lifnr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_lifnr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_lifnr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_lifnr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_lifnr-dmbtr5.
    MOVE wa_itab-belnr    TO wa_lifnr-belnr.
    MOVE wa_itab-gjahr    TO wa_lifnr-gjahr.

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                 wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                   wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_lifnr TO i_lifnr.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " LIFNR_PROCESS_1_TOTAL

*&---------------------------------------------------------------------*
*&      Form  BRSCH_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM brsch_process.
  SORT i_itab BY brsch.
  REFRESH i_brsch.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE gsber EQ tgsbt-gsber AND
          brsch IN so_brsch.
    MOVE wa_itab-gsber    TO wa_brsch-gsber.
    MOVE wa_itab-budat    TO wa_brsch-budat.
    MOVE wa_itab-bldat    TO wa_brsch-bldat.
    MOVE wa_itab-augdt    TO wa_brsch-augdt.
    MOVE wa_itab-lifnr    TO wa_brsch-lifnr.
    MOVE wa_itab-brsch    TO wa_brsch-brsch.
    MOVE wa_itab-shkzg    TO wa_brsch-shkzg.
    MOVE wa_itab-monat    TO wa_brsch-monat.
    MOVE wa_itab-blart    TO wa_brsch-blart.
    MOVE wa_itab-current  TO wa_brsch-current.
    MOVE wa_itab-dmbtr    TO wa_brsch-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_brsch-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_brsch-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_brsch-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_brsch-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_brsch-dmbtr5.

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
*&      Form  ZUONR_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zuonr_process.
  REFRESH: i_zuonr.
  CLEAR: wa_itab,i_augbl.

  DATA: lv_sort(25).

  PERFORM f_get_modify USING va_lifnr va_gjahr1 va_belnr 'ZUONR'
                       CHANGING lv_sort.

  IF lv_sort EQ 'ONTV'.
    LOOP AT i_itab INTO wa_itab
      WHERE gsber EQ tgsbt-gsber AND
            lifnr EQ va_lifnr    AND
            belnr EQ va_belnr    AND
            gjahr EQ va_gjahr1.
      MOVE wa_itab-gsber    TO wa_zuonr-gsber.
      MOVE wa_itab-lifnr    TO wa_zuonr-lifnr.
      MOVE wa_itab-budat    TO wa_zuonr-budat.
      MOVE wa_itab-bldat    TO wa_zuonr-bldat.
      MOVE wa_itab-augdt    TO wa_zuonr-augdt.
      MOVE wa_itab-shkzg    TO wa_zuonr-shkzg.
      MOVE wa_itab-monat    TO wa_zuonr-monat.
      MOVE wa_itab-blart    TO wa_zuonr-blart.
      MOVE wa_itab-zuonr    TO wa_zuonr-zuonr.
      MOVE wa_itab-current  TO wa_zuonr-current.
      MOVE wa_itab-dmbtr    TO wa_zuonr-dmbtr.
      MOVE wa_itab-dmbtr1   TO wa_zuonr-dmbtr1.
      MOVE wa_itab-dmbtr2   TO wa_zuonr-dmbtr2.
      MOVE wa_itab-dmbtr3   TO wa_zuonr-dmbtr3.
      MOVE wa_itab-dmbtr4   TO wa_zuonr-dmbtr4.
      MOVE wa_itab-dmbtr5   TO wa_zuonr-dmbtr5.
      MOVE wa_itab-belnr    TO wa_zuonr-belnr.
      MOVE wa_itab-gjahr    TO wa_zuonr-gjahr.
      MOVE wa_itab-augbl    TO wa_zuonr-augbl.
      APPEND wa_zuonr TO i_zuonr.
      CLEAR: wa_itab.

*      IF wa_zuonr-augbl IS NOT INITIAL.
*        i_augbl-augbl = wa_zuonr-augbl.
*        CASE wa_zuonr-shkzg.
*          WHEN 'H'.
*            i_augbl-dmbtr = wa_zuonr-dmbtr * -1.
*          WHEN 'S'.
*            i_augbl-dmbtr = wa_zuonr-dmbtr.
*          WHEN OTHERS.
*        ENDCASE.
*        COLLECT i_augbl. CLEAR i_augbl.
*      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT i_itab INTO wa_itab
      WHERE gsber EQ tgsbt-gsber AND
            lifnr EQ va_lifnr.
      MOVE wa_itab-gsber    TO wa_zuonr-gsber.
      MOVE wa_itab-lifnr    TO wa_zuonr-lifnr.
      MOVE wa_itab-budat    TO wa_zuonr-budat.
      MOVE wa_itab-bldat    TO wa_zuonr-bldat.
      MOVE wa_itab-augdt    TO wa_zuonr-augdt.
      MOVE wa_itab-shkzg    TO wa_zuonr-shkzg.
      MOVE wa_itab-monat    TO wa_zuonr-monat.
      MOVE wa_itab-blart    TO wa_zuonr-blart.
      MOVE wa_itab-zuonr    TO wa_zuonr-zuonr.
      MOVE wa_itab-current  TO wa_zuonr-current.
      MOVE wa_itab-dmbtr    TO wa_zuonr-dmbtr.
      MOVE wa_itab-dmbtr1   TO wa_zuonr-dmbtr1.
      MOVE wa_itab-dmbtr2   TO wa_zuonr-dmbtr2.
      MOVE wa_itab-dmbtr3   TO wa_zuonr-dmbtr3.
      MOVE wa_itab-dmbtr4   TO wa_zuonr-dmbtr4.
      MOVE wa_itab-dmbtr5   TO wa_zuonr-dmbtr5.
      MOVE wa_itab-belnr    TO wa_zuonr-belnr.
      MOVE wa_itab-gjahr    TO wa_zuonr-gjahr.
      MOVE wa_itab-augbl    TO wa_zuonr-augbl.
      APPEND wa_zuonr TO i_zuonr.
      CLEAR: wa_itab.

*      IF wa_zuonr-augbl IS NOT INITIAL.
*        i_augbl-augbl = wa_zuonr-augbl.
*        CASE wa_zuonr-shkzg.
*          WHEN 'H'.
*            i_augbl-dmbtr = wa_zuonr-dmbtr * -1.
*          WHEN 'S'.
*            i_augbl-dmbtr = wa_zuonr-dmbtr.
*          WHEN OTHERS.
*        ENDCASE.
*        COLLECT i_augbl. CLEAR i_augbl.
*      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " ZUONR_PROCESS

*&---------------------------------------------------------------------*
*&      Form  ZUONR_PROCESS_TOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zuonr_process_total.
  REFRESH i_zuonr.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE lifnr EQ va_lifnr1.
    MOVE wa_itab-gsber    TO wa_zuonr-gsber.
    MOVE wa_itab-lifnr    TO wa_zuonr-lifnr.
    MOVE wa_itab-budat    TO wa_zuonr-budat.
    MOVE wa_itab-bldat    TO wa_zuonr-bldat.
    MOVE wa_itab-augdt    TO wa_zuonr-augdt.
    MOVE wa_itab-shkzg    TO wa_zuonr-shkzg.
    MOVE wa_itab-monat    TO wa_zuonr-monat.
    MOVE wa_itab-blart    TO wa_zuonr-blart.
    MOVE wa_itab-zuonr    TO wa_zuonr-zuonr.
    MOVE wa_itab-current  TO wa_zuonr-current.
    MOVE wa_itab-dmbtr    TO wa_zuonr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_zuonr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_zuonr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_zuonr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_zuonr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_zuonr-dmbtr5.
    MOVE wa_itab-belnr    TO wa_zuonr-belnr.
    MOVE wa_itab-gjahr    TO wa_zuonr-gjahr.
    MOVE wa_itab-augbl    TO wa_zuonr-augbl.

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_zuonr-current,wa_zuonr-dmbtr1,wa_zuonr-dmbtr2,
                 wa_zuonr-dmbtr3,wa_zuonr-dmbtr4,wa_zuonr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_zuonr-current,wa_zuonr-dmbtr1,wa_zuonr-dmbtr2,
                   wa_zuonr-dmbtr3,wa_zuonr-dmbtr4,wa_zuonr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_zuonr TO i_zuonr.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " ZUONR_PROCESS_TOTAL

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
                sy-vline, wa_gsber-purchase CURRENCY va_currency,
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
    ADD wa_gsber-purchase TO total_purchase.
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
  WRITE: /    sy-vline, 'Grand Total',
          29  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_purchase CURRENCY va_currency,
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
  CLEAR: total_begbal, total_purchase, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.
ENDFORM.                    " CETAK_GSBER

*&---------------------------------------------------------------------*
*&      Form  CETAK_DETAIL_LIFNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_detail_lifnr USING fu_sort.
  DATA: zebra TYPE i.

  DATA: lv_belnr  TYPE bsik-belnr,
        lv_gjahr  TYPE bsik-gjahr,
        lv_lifnr  TYPE bsik-lifnr.

  zebra = 0.

  PERFORM cetak_header_lifnr.

  CLEAR: wa_lifnr.
  CASE fu_sort.
    WHEN '1'.
*      SORT i_lifnr BY objkey lifnr.
      SORT i_lifnr." BY objkey lifnr. "Modify by sol_jonhar 01/10/2020
    WHEN '2'.
      SORT i_lifnr BY lifnr.
  ENDCASE.
  LOOP AT i_lifnr INTO wa_lifnr.
    IF wa_lifnr-shkzg EQ 'S'.
      ADD wa_lifnr-current TO va_current.
      ADD wa_lifnr-dmbtr1 TO va_dmbtr1.
      ADD wa_lifnr-dmbtr2 TO va_dmbtr2.
      ADD wa_lifnr-dmbtr3 TO va_dmbtr3.
      ADD wa_lifnr-dmbtr4 TO va_dmbtr4.
      ADD wa_lifnr-dmbtr5 TO va_dmbtr5.
      IF wa_lifnr-budat(6) LT pa_gstid(6).
*      IF wa_lifnr-bldat(6) LT pa_gstid(6).
        ADD wa_lifnr-dmbtr TO va_begbal.
      ENDIF.
      IF wa_lifnr-blart NE 'KZ'.
        IF wa_lifnr-budat GE va_gerdat1 AND
           wa_lifnr-budat LT va_gerdat2.
*        IF wa_lifnr-bldat GE va_gerdat1 AND
*           wa_lifnr-bldat LT va_gerdat2.
          ADD wa_lifnr-dmbtr TO va_purchase.
        ENDIF.
      ELSE.
        IF wa_lifnr-budat GE va_gerdat1 AND
           wa_lifnr-budat LT va_gerdat2.
*        IF wa_lifnr-bldat GE va_gerdat1 AND
*           wa_lifnr-bldat LT va_gerdat2.
          ADD wa_lifnr-dmbtr TO va_payment.
        ENDIF.
      ENDIF.
    ELSE.
      va_current = va_current - wa_lifnr-current.
      va_dmbtr1 = va_dmbtr1 - wa_lifnr-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_lifnr-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_lifnr-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_lifnr-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_lifnr-dmbtr5.
      IF wa_lifnr-budat(6) LT pa_gstid(6).
*      IF wa_lifnr-bldat(6) LT pa_gstid(6).
        va_begbal = va_begbal - wa_lifnr-dmbtr.
      ENDIF.
      IF wa_lifnr-blart NE 'KZ'.
        IF wa_lifnr-budat GE va_gerdat1 AND
           wa_lifnr-budat LT va_gerdat2.
*        IF wa_lifnr-bldat GE va_gerdat1 AND
*           wa_lifnr-bldat LT va_gerdat2.
          va_purchase = va_purchase - wa_lifnr-dmbtr.
        ENDIF.
      ELSE.
        IF wa_lifnr-budat GE va_gerdat1 AND
           wa_lifnr-budat LT va_gerdat2.
*        IF wa_lifnr-bldat GE va_gerdat1 AND
*           wa_lifnr-bldat LT va_gerdat2.
          va_payment = va_payment - wa_lifnr-dmbtr.
        ENDIF.
      ENDIF.
    ENDIF.

    lv_lifnr  = wa_lifnr-lifnr.
    lv_belnr  = wa_lifnr-belnr.
    lv_gjahr  = wa_lifnr-gjahr.

    AT END OF objkey.
      IF zebra = 0.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT COLOR 1.
        zebra = 0.
      ENDIF.

      PERFORM f_get_modify USING lv_lifnr lv_gjahr lv_belnr 'PRINT'
                           CHANGING va_name1.

      va_endbal = va_begbal + va_purchase + va_payment.
      WRITE va_begbal TO va_begbal1 CURRENCY va_currency.

      IF fvalue EQ 'Grand Total'.
        MOVE lv_lifnr TO va_lifnr1.
      ELSE.
        MOVE lv_lifnr TO va_lifnr.
      ENDIF.

      IF va_begbal  NE 0 OR
        va_purchase NE 0 OR
        va_payment  NE 0 OR
        va_endbal   NE 0.
        IF fvalue EQ 'Grand Total'.
          WRITE: /    sy-vline NO-GAP, va_lifnr1, '-', va_name1 NO-GAP.
        ELSE.
          WRITE: /    sy-vline NO-GAP, va_lifnr, '-', va_name1 NO-GAP.
        ENDIF.
        WRITE:      sy-vline, va_begbal CURRENCY va_currency,
                    sy-vline, va_purchase CURRENCY va_currency,
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

        ADD va_begbal   TO total_begbal.
        ADD va_purchase TO total_purchase.
        ADD va_payment  TO total_payment.
        ADD va_endbal   TO total_endbal.
        ADD va_current  TO total_current.
        ADD va_dmbtr1   TO total_dmbtr1.
        ADD va_dmbtr2   TO total_dmbtr2.
        ADD va_dmbtr3   TO total_dmbtr3.
        ADD va_dmbtr4   TO total_dmbtr4.
        ADD va_dmbtr5   TO total_dmbtr5.

      ELSE.
        IF zebra = 0.
          zebra = 1.
        ELSE.
          zebra = 0.
        ENDIF.
      ENDIF.

      CLEAR: va_begbal, va_purchase, va_payment, va_endbal, va_current,
             va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
    ENDAT.

    CLEAR: wa_lifnr.
  ENDLOOP.

  FORMAT COLOR 3.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'Total',
          40  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_purchase CURRENCY va_currency,
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
  CLEAR: total_begbal, total_purchase, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.
ENDFORM.                    " CETAK_DETAIL_LIFNR

*&---------------------------------------------------------------------*
*&      Form  CETAK_DETAIL_LIFNR_TOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_detail_lifnr_total.
  DATA: zebra TYPE i.

  DATA: lv_belnr  LIKE bsik-belnr,
        lv_gjahr  LIKE bsik-gjahr,
        lv_ktokk  LIKE lfa1-ktokk.

  zebra = 0.

  PERFORM cetak_header_lifnr.

  "--Start modify by sol_jonhar 01/10/2020
  CLEAR : wa_lifnr2.
  REFRESH : i_lifnr2.

  LOOP AT i_lifnr INTO wa_lifnr.
    MOVE-CORRESPONDING wa_lifnr TO wa_lifnr2.
    APPEND wa_lifnr2 TO i_lifnr2.
  ENDLOOP.

  SORT i_lifnr2." BY lifnr.
  LOOP AT i_lifnr2 INTO wa_lifnr2.
    IF wa_lifnr2-shkzg EQ 'S'.
      ADD wa_lifnr2-current TO va_current.
      ADD wa_lifnr2-dmbtr1 TO va_dmbtr1.
      ADD wa_lifnr2-dmbtr2 TO va_dmbtr2.
      ADD wa_lifnr2-dmbtr3 TO va_dmbtr3.
      ADD wa_lifnr2-dmbtr4 TO va_dmbtr4.
      ADD wa_lifnr2-dmbtr5 TO va_dmbtr5.
      IF wa_lifnr2-budat(6) LT pa_gstid(6).
*      IF wa_lifnr-bldat(6) LT pa_gstid(6).
        ADD wa_lifnr2-dmbtr TO va_begbal.
      ENDIF.
      IF wa_lifnr2-blart NE 'KZ'.
        IF wa_lifnr2-budat GE va_gerdat1 AND
           wa_lifnr2-budat LT va_gerdat2.
*        IF wa_lifnr-bldat GE va_gerdat1 AND
*           wa_lifnr-bldat LT va_gerdat2.
          ADD wa_lifnr2-dmbtr TO va_purchase.
        ENDIF.
      ELSE.
        IF wa_lifnr2-budat GE va_gerdat1 AND
           wa_lifnr2-budat LT va_gerdat2.
*        IF wa_lifnr-bldat GE va_gerdat1 AND
*           wa_lifnr-bldat LT va_gerdat2.
          ADD wa_lifnr2-dmbtr TO va_payment.
        ENDIF.
      ENDIF.
    ELSE.
      va_current = va_current - wa_lifnr2-current.
      va_dmbtr1 = va_dmbtr1 - wa_lifnr2-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_lifnr2-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_lifnr2-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_lifnr2-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_lifnr2-dmbtr5.
      IF wa_lifnr2-budat(6) LT pa_gstid(6).
*      IF wa_lifnr-bldat(6) LT pa_gstid(6).
        va_begbal = va_begbal - wa_lifnr2-dmbtr.
      ENDIF.
      IF wa_lifnr2-blart NE 'KZ'.
        IF wa_lifnr2-budat GE va_gerdat1 AND
           wa_lifnr2-budat LT va_gerdat2.
*        IF wa_lifnr-bldat GE va_gerdat1 AND
*           wa_lifnr-bldat LT va_gerdat2.
          va_purchase = va_purchase - wa_lifnr2-dmbtr.
        ENDIF.
      ELSE.
        IF wa_lifnr2-budat GE va_gerdat1 AND
           wa_lifnr2-budat LT va_gerdat2.
*        IF wa_lifnr-bldat GE va_gerdat1 AND
*           wa_lifnr-bldat LT va_gerdat2.
          va_payment = va_payment - wa_lifnr2-dmbtr.
        ENDIF.
      ENDIF.
    ENDIF.

    lv_belnr  = wa_lifnr2-belnr.
    lv_gjahr  = wa_lifnr2-gjahr.

    AT END OF lifnr.
      IF zebra = 0.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR 2.
        zebra = 1.
      ELSE.
        FORMAT COLOR 1.
        zebra = 0.
      ENDIF.

      PERFORM f_get_modify USING wa_lifnr2-lifnr lv_gjahr lv_belnr 'PRINT'
                           CHANGING va_name1.

      va_endbal = va_begbal + va_purchase + va_payment.
      WRITE va_begbal TO va_begbal1 CURRENCY va_currency.

      IF counter = 1.
        MOVE wa_lifnr2-lifnr TO va_lifnr1.
      ELSE.
        MOVE wa_lifnr2-lifnr TO va_lifnr.
      ENDIF.

      IF va_begbal  NE 0 OR
        va_purchase NE 0 OR
        va_payment  NE 0 OR
        va_endbal   NE 0.
        IF counter EQ 1.
          WRITE: /    sy-vline NO-GAP, va_lifnr1, '-', va_name1 NO-GAP.
        ELSE.
          WRITE: /    sy-vline NO-GAP, va_lifnr, '-', va_name1 NO-GAP.
        ENDIF.
        WRITE:      sy-vline, va_begbal CURRENCY va_currency,
                    sy-vline, va_purchase CURRENCY va_currency,
                    sy-vline, va_payment CURRENCY va_currency,
                    sy-vline, va_endbal CURRENCY va_currency,
                    sy-vline, va_current CURRENCY va_currency,
                    sy-vline, va_dmbtr1 CURRENCY va_currency,
                    sy-vline, va_dmbtr2 CURRENCY va_currency,
                    sy-vline, va_dmbtr3 CURRENCY va_currency,
                    sy-vline, va_dmbtr4 CURRENCY va_currency,
                    sy-vline, va_dmbtr5 CURRENCY va_currency,
                    sy-vline.

        ADD va_begbal   TO total_begbal.
        ADD va_purchase TO total_purchase.
        ADD va_payment  TO total_payment.
        ADD va_endbal   TO total_endbal.
        ADD va_current  TO total_current.
        ADD va_dmbtr1   TO total_dmbtr1.
        ADD va_dmbtr2   TO total_dmbtr2.
        ADD va_dmbtr3   TO total_dmbtr3.
        ADD va_dmbtr4   TO total_dmbtr4.
        ADD va_dmbtr5   TO total_dmbtr5.

      ELSE.
        IF zebra = 0.
          zebra = 1.
        ELSE.
          zebra = 0.
        ENDIF.
      ENDIF.

      CLEAR: va_begbal, va_purchase, va_payment, va_endbal, va_current,
             va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
    ENDAT.
    CLEAR: wa_lifnr2.
  ENDLOOP.


  "--End of modify by sol_jonhar 01/10/2020


*  CLEAR: wa_lifnr.
*  SORT i_lifnr BY lifnr.
*  LOOP AT i_lifnr INTO wa_lifnr.
*    IF wa_lifnr-shkzg EQ 'S'.
*      ADD wa_lifnr-current TO va_current.
*      ADD wa_lifnr-dmbtr1 TO va_dmbtr1.
*      ADD wa_lifnr-dmbtr2 TO va_dmbtr2.
*      ADD wa_lifnr-dmbtr3 TO va_dmbtr3.
*      ADD wa_lifnr-dmbtr4 TO va_dmbtr4.
*      ADD wa_lifnr-dmbtr5 TO va_dmbtr5.
*      IF wa_lifnr-budat(6) LT pa_gstid(6).
**      IF wa_lifnr-bldat(6) LT pa_gstid(6).
*        ADD wa_lifnr-dmbtr TO va_begbal.
*      ENDIF.
*      IF wa_lifnr-blart NE 'KZ'.
*        IF wa_lifnr-budat GE va_gerdat1 AND
*           wa_lifnr-budat LT va_gerdat2.
**        IF wa_lifnr-bldat GE va_gerdat1 AND
**           wa_lifnr-bldat LT va_gerdat2.
*          ADD wa_lifnr-dmbtr TO va_purchase.
*        ENDIF.
*      ELSE.
*        IF wa_lifnr-budat GE va_gerdat1 AND
*           wa_lifnr-budat LT va_gerdat2.
**        IF wa_lifnr-bldat GE va_gerdat1 AND
**           wa_lifnr-bldat LT va_gerdat2.
*          ADD wa_lifnr-dmbtr TO va_payment.
*        ENDIF.
*      ENDIF.
*    ELSE.
*      va_current = va_current - wa_lifnr-current.
*      va_dmbtr1 = va_dmbtr1 - wa_lifnr-dmbtr1.
*      va_dmbtr2 = va_dmbtr2 - wa_lifnr-dmbtr2.
*      va_dmbtr3 = va_dmbtr3 - wa_lifnr-dmbtr3.
*      va_dmbtr4 = va_dmbtr4 - wa_lifnr-dmbtr4.
*      va_dmbtr5 = va_dmbtr5 - wa_lifnr-dmbtr5.
*      IF wa_lifnr-budat(6) LT pa_gstid(6).
**      IF wa_lifnr-bldat(6) LT pa_gstid(6).
*        va_begbal = va_begbal - wa_lifnr-dmbtr.
*      ENDIF.
*      IF wa_lifnr-blart NE 'KZ'.
*        IF wa_lifnr-budat GE va_gerdat1 AND
*           wa_lifnr-budat LT va_gerdat2.
**        IF wa_lifnr-bldat GE va_gerdat1 AND
**           wa_lifnr-bldat LT va_gerdat2.
*          va_purchase = va_purchase - wa_lifnr-dmbtr.
*        ENDIF.
*      ELSE.
*        IF wa_lifnr-budat GE va_gerdat1 AND
*           wa_lifnr-budat LT va_gerdat2.
**        IF wa_lifnr-bldat GE va_gerdat1 AND
**           wa_lifnr-bldat LT va_gerdat2.
*          va_payment = va_payment - wa_lifnr-dmbtr.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*    lv_belnr  = wa_lifnr-belnr.
*    lv_gjahr  = wa_lifnr-gjahr.
*
*    AT END OF lifnr.
*      IF zebra = 0.
*        FORMAT INTENSIFIED OFF.
*        FORMAT COLOR 2.
*        zebra = 1.
*      ELSE.
*        FORMAT COLOR 1.
*        zebra = 0.
*      ENDIF.
*
*      PERFORM f_get_modify USING wa_lifnr-lifnr lv_gjahr lv_belnr 'PRINT'
*                           CHANGING va_name1.
*
*      va_endbal = va_begbal + va_purchase + va_payment.
*      WRITE va_begbal TO va_begbal1 CURRENCY va_currency.
*
*      IF counter = 1.
*        MOVE wa_lifnr-lifnr TO va_lifnr1.
*      ELSE.
*        MOVE wa_lifnr-lifnr TO va_lifnr.
*      ENDIF.
*
*      IF va_begbal  NE 0 OR
*        va_purchase NE 0 OR
*        va_payment  NE 0 OR
*        va_endbal   NE 0.
*        IF counter EQ 1.
*          WRITE: /    sy-vline NO-GAP, va_lifnr1, '-', va_name1 NO-GAP.
*        ELSE.
*          WRITE: /    sy-vline NO-GAP, va_lifnr, '-', va_name1 NO-GAP.
*        ENDIF.
*        WRITE:      sy-vline, va_begbal CURRENCY va_currency,
*                    sy-vline, va_purchase CURRENCY va_currency,
*                    sy-vline, va_payment CURRENCY va_currency,
*                    sy-vline, va_endbal CURRENCY va_currency,
*                    sy-vline, va_current CURRENCY va_currency,
*                    sy-vline, va_dmbtr1 CURRENCY va_currency,
*                    sy-vline, va_dmbtr2 CURRENCY va_currency,
*                    sy-vline, va_dmbtr3 CURRENCY va_currency,
*                    sy-vline, va_dmbtr4 CURRENCY va_currency,
*                    sy-vline, va_dmbtr5 CURRENCY va_currency,
*                    sy-vline.
*
*        ADD va_begbal   TO total_begbal.
*        ADD va_purchase TO total_purchase.
*        ADD va_payment  TO total_payment.
*        ADD va_endbal   TO total_endbal.
*        ADD va_current  TO total_current.
*        ADD va_dmbtr1   TO total_dmbtr1.
*        ADD va_dmbtr2   TO total_dmbtr2.
*        ADD va_dmbtr3   TO total_dmbtr3.
*        ADD va_dmbtr4   TO total_dmbtr4.
*        ADD va_dmbtr5   TO total_dmbtr5.
*
*      ELSE.
*        IF zebra = 0.
*          zebra = 1.
*        ELSE.
*          zebra = 0.
*        ENDIF.
*      ENDIF.
*
*      CLEAR: va_begbal, va_purchase, va_payment, va_endbal, va_current,
*             va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
*    ENDAT.
*    CLEAR: wa_lifnr.
*  ENDLOOP.

  FORMAT COLOR 3.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'Total',
          40  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_purchase CURRENCY va_currency,
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
  CLEAR: total_begbal, total_purchase, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.
ENDFORM.                    " CETAK_DETAIL_LIFNR_TOTAL

*&---------------------------------------------------------------------*
*&      Form  CETAK_DETAIL_BRSCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_detail_brsch.
  DATA: zebra TYPE i.

  zebra = 0.

  PERFORM cetak_header_brsch.

  CLEAR: wa_brsch.
*  SORT i_brsch BY brsch.
  SORT i_brsch." BY brsch. "Modify by sol_jonhar 01/10/2020
  LOOP AT i_brsch INTO wa_brsch.
    IF wa_brsch-shkzg EQ 'S'.
      ADD wa_brsch-current TO va_current.
      ADD wa_brsch-dmbtr1 TO va_dmbtr1.
      ADD wa_brsch-dmbtr2 TO va_dmbtr2.
      ADD wa_brsch-dmbtr3 TO va_dmbtr3.
      ADD wa_brsch-dmbtr4 TO va_dmbtr4.
      ADD wa_brsch-dmbtr5 TO va_dmbtr5.
      IF wa_brsch-budat(6) LT pa_gstid(6).
*      IF wa_brsch-bldat(6) LT pa_gstid(6).
        ADD wa_brsch-dmbtr TO va_begbal.
      ENDIF.
      IF wa_brsch-blart NE 'KZ'.
        IF wa_brsch-budat GE va_gerdat1 AND
           wa_brsch-budat LT va_gerdat2.
*        IF wa_brsch-bldat GE va_gerdat1 AND
*           wa_brsch-bldat LT va_gerdat2.
          ADD wa_brsch-dmbtr TO va_purchase.
        ENDIF.
      ELSE.
        IF wa_brsch-budat GE va_gerdat1 AND
           wa_brsch-budat LT va_gerdat2.
*        IF wa_brsch-bldat GE va_gerdat1 AND
*           wa_brsch-bldat LT va_gerdat2.
          ADD wa_brsch-dmbtr TO va_payment.
        ENDIF.
      ENDIF.
    ELSE.
      va_current = va_current - wa_brsch-current.
      va_dmbtr1 = va_dmbtr1 - wa_brsch-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_brsch-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_brsch-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_brsch-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_brsch-dmbtr5.
      IF wa_brsch-budat(6) LT pa_gstid(6).
*      IF wa_brsch-bldat(6) LT pa_gstid(6).
        va_begbal = va_begbal - wa_brsch-dmbtr.
      ENDIF.
      IF wa_brsch-blart NE 'KZ'.
        IF wa_brsch-budat GE va_gerdat1 AND
           wa_brsch-budat LT va_gerdat2.
*        IF wa_brsch-bldat GE va_gerdat1 AND
*           wa_brsch-bldat LT va_gerdat2.
          va_purchase = va_purchase - wa_brsch-dmbtr.
        ENDIF.
      ELSE.
        IF wa_brsch-budat GE va_gerdat1 AND
           wa_brsch-budat LT va_gerdat2.
*        IF wa_brsch-bldat GE va_gerdat1 AND
*           wa_brsch-bldat LT va_gerdat2.
          va_payment = va_payment - wa_brsch-dmbtr.
        ENDIF.
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

      va_endbal = va_begbal + va_purchase + va_payment.
      WRITE va_begbal TO va_begbal1 CURRENCY va_currency.

      IF fvalue EQ 'Grand Total'.
        MOVE wa_brsch-brsch TO va_brsch1.
      ELSE.
        MOVE wa_brsch-brsch TO va_brsch.
      ENDIF.

      IF va_begbal  NE 0 OR
        va_purchase NE 0 OR
        va_payment  NE 0 OR
        va_endbal   NE 0.
        IF fvalue EQ 'Grand Total'.
          WRITE: /    sy-vline NO-GAP, va_brsch1, '-', va_brtxt NO-GAP.
        ELSE.
          WRITE: /    sy-vline NO-GAP, va_brsch, '-', va_brtxt NO-GAP.
        ENDIF.
        WRITE:      sy-vline, va_begbal CURRENCY va_currency,
                    sy-vline, va_purchase CURRENCY va_currency,
                    sy-vline, va_payment CURRENCY va_currency,
                    sy-vline, va_endbal CURRENCY va_currency,
                    sy-vline, va_current CURRENCY va_currency,
                    sy-vline, va_dmbtr1 CURRENCY va_currency,
                    sy-vline, va_dmbtr2 CURRENCY va_currency,
                    sy-vline, va_dmbtr3 CURRENCY va_currency,
                    sy-vline, va_dmbtr4 CURRENCY va_currency,
                    sy-vline, va_dmbtr5 CURRENCY va_currency,
                    sy-vline.

        ADD va_begbal   TO total_begbal.
        ADD va_purchase TO total_purchase.
        ADD va_payment  TO total_payment.
        ADD va_endbal   TO total_endbal.
        ADD va_current  TO total_current.
        ADD va_dmbtr1   TO total_dmbtr1.
        ADD va_dmbtr2   TO total_dmbtr2.
        ADD va_dmbtr3   TO total_dmbtr3.
        ADD va_dmbtr4   TO total_dmbtr4.
        ADD va_dmbtr5   TO total_dmbtr5.
      ELSE.
        IF zebra = 0.
          zebra = 1.
        ELSE.
          zebra = 0.
        ENDIF.
      ENDIF.

      CLEAR: va_begbal, va_purchase, va_payment, va_endbal, va_current,
             va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
    ENDAT.
    CLEAR: wa_brsch.
  ENDLOOP.

  FORMAT COLOR 3.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'Total',
          40  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_purchase CURRENCY va_currency,
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
  CLEAR: total_begbal, total_purchase, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.
ENDFORM.                    " CETAK_DETAIL_BRSCH

*&---------------------------------------------------------------------*
*&      Form  CETAK_DETAIL_ZUONR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_detail_zuonr.
  DATA: zebra TYPE i.

  zebra = 0.

  PERFORM cetak_header_zuonr.

  CLEAR: wa_zuonr.
*  SORT i_zuonr BY belnr augbl zuonr.
  SORT i_zuonr." BY belnr augbl zuonr. "Modify by sol_jonhar 01/10/2020
  LOOP AT i_zuonr INTO wa_zuonr
    WHERE gsber EQ tgsbt-gsber AND
          lifnr EQ va_lifnr.

    IF wa_zuonr-shkzg EQ 'S'.
      ADD wa_zuonr-begbal TO va_begbal.
      ADD wa_zuonr-current TO va_current.
      ADD wa_zuonr-dmbtr1 TO va_dmbtr1.
      ADD wa_zuonr-dmbtr2 TO va_dmbtr2.
      ADD wa_zuonr-dmbtr3 TO va_dmbtr3.
      ADD wa_zuonr-dmbtr4 TO va_dmbtr4.
      ADD wa_zuonr-dmbtr5 TO va_dmbtr5.
      IF wa_zuonr-budat(6) LT pa_gstid(6).
*      IF wa_zuonr-bldat(6) LT pa_gstid(6).
        ADD wa_zuonr-dmbtr TO va_begbal.
      ENDIF.
      IF wa_zuonr-blart NE 'KZ'.
        IF wa_zuonr-budat GE va_gerdat1 AND
           wa_zuonr-budat LT va_gerdat2.
*        IF wa_zuonr-bldat GE va_gerdat1 AND
*           wa_zuonr-bldat LT va_gerdat2.
          ADD wa_zuonr-dmbtr TO va_purchase.
        ENDIF.
      ELSE.
        IF wa_zuonr-budat GE va_gerdat1 AND
           wa_zuonr-budat LT va_gerdat2.
*        IF wa_zuonr-bldat GE va_gerdat1 AND
*           wa_zuonr-bldat LT va_gerdat2.
          ADD wa_zuonr-dmbtr TO va_payment.
        ENDIF.
      ENDIF.
    ELSE.
      va_begbal = va_begbal - wa_zuonr-begbal.
      va_current = va_current - wa_zuonr-current.
      va_dmbtr1 = va_dmbtr1 - wa_zuonr-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_zuonr-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_zuonr-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_zuonr-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_zuonr-dmbtr5.
      IF wa_zuonr-budat(6) LT pa_gstid(6).
*      IF wa_zuonr-bldat(6) LT pa_gstid(6).
        va_begbal = va_begbal - wa_zuonr-dmbtr.
      ENDIF.
      IF wa_zuonr-blart NE 'KZ'.
        IF wa_zuonr-budat GE va_gerdat1 AND
           wa_zuonr-budat LT va_gerdat2.
*        IF wa_zuonr-bldat GE va_gerdat1 AND
*           wa_zuonr-bldat LT va_gerdat2.
          va_purchase = va_purchase - wa_zuonr-dmbtr.
        ENDIF.
      ELSE.
        IF wa_zuonr-budat GE va_gerdat1 AND
           wa_zuonr-budat LT va_gerdat2.
*        IF wa_zuonr-bldat GE va_gerdat1 AND
*           wa_zuonr-bldat LT va_gerdat2.
          va_payment = va_payment - wa_zuonr-dmbtr.
        ENDIF.
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

      va_endbal = va_begbal + va_purchase + va_payment.

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
      ADD va_purchase TO total_purchase.
      ADD va_payment  TO total_payment.
      ADD va_endbal   TO total_endbal.
      ADD va_current  TO total_current.
      ADD va_dmbtr1   TO total_dmbtr1.
      ADD va_dmbtr2   TO total_dmbtr2.
      ADD va_dmbtr3   TO total_dmbtr3.
      ADD va_dmbtr4   TO total_dmbtr4.
      ADD va_dmbtr5   TO total_dmbtr5.

      IF va_begbal  NE 0 OR
        va_purchase NE 0 OR
        va_payment  NE 0 OR
        va_endbal   NE 0 OR
        va_current  NE 0.
        FORMAT INTENSIFIED OFF.
        WRITE: /    sy-vline, va_zuonr,
                29  sy-vline, va_augbl,
                    sy-vline, va_begbal CURRENCY va_currency,
                    sy-vline, va_purchase CURRENCY va_currency,
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
        CLEAR: va_begbal, va_purchase, va_payment, va_endbal,
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
              sy-vline, total_purchase CURRENCY va_currency,
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
  CLEAR: total_begbal, total_purchase, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.
ENDFORM.                    " CETAK_DETAIL_ZUONR

*&---------------------------------------------------------------------*
*&      Form  CETAK_DETAIL_ZUONR_TOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_detail_zuonr_total.
  DATA: zebra TYPE i.

  zebra = 0.

  PERFORM cetak_header_zuonr.

  CLEAR: wa_zuonr.
*  SORT i_zuonr BY belnr augbl zuonr.
  SORT i_zuonr." BY belnr augbl zuonr. "Modify by sol_jonhar 01/10/2020
  LOOP AT i_zuonr INTO wa_zuonr
    WHERE lifnr EQ va_lifnr1.

    IF wa_zuonr-shkzg EQ 'S'.
      ADD wa_zuonr-begbal TO va_begbal.
      ADD wa_zuonr-current TO va_current.
      ADD wa_zuonr-dmbtr1 TO va_dmbtr1.
      ADD wa_zuonr-dmbtr2 TO va_dmbtr2.
      ADD wa_zuonr-dmbtr3 TO va_dmbtr3.
      ADD wa_zuonr-dmbtr4 TO va_dmbtr4.
      ADD wa_zuonr-dmbtr5 TO va_dmbtr5.
      IF wa_zuonr-budat(6) LT pa_gstid(6).
*      IF wa_zuonr-bldat(6) LT pa_gstid(6).
        ADD wa_zuonr-dmbtr TO va_begbal.
      ENDIF.
      IF wa_zuonr-blart NE 'KZ'.
        IF wa_zuonr-budat GE va_gerdat1 AND
           wa_zuonr-budat LT va_gerdat2.
*        IF wa_zuonr-bldat GE va_gerdat1 AND
*           wa_zuonr-bldat LT va_gerdat2.
          ADD wa_zuonr-dmbtr TO va_purchase.
        ENDIF.
      ELSE.
        IF wa_zuonr-budat GE va_gerdat1 AND
           wa_zuonr-budat LT va_gerdat2.
*        IF wa_zuonr-bldat GE va_gerdat1 AND
*           wa_zuonr-bldat LT va_gerdat2.
          ADD wa_zuonr-dmbtr TO va_payment.
        ENDIF.
      ENDIF.
    ELSE.
      va_begbal = va_begbal - wa_zuonr-begbal.
      va_current = va_current - wa_zuonr-current.
      va_dmbtr1 = va_dmbtr1 - wa_zuonr-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_zuonr-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_zuonr-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_zuonr-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_zuonr-dmbtr5.
      IF wa_zuonr-budat(6) LT pa_gstid(6).
*      IF wa_zuonr-bldat(6) LT pa_gstid(6).
        va_begbal = va_begbal - wa_zuonr-dmbtr.
      ENDIF.
      IF wa_zuonr-blart NE 'KZ'.
        IF wa_zuonr-budat GE va_gerdat1 AND
           wa_zuonr-budat LT va_gerdat2.
*        IF wa_zuonr-bldat GE va_gerdat1 AND
*           wa_zuonr-bldat LT va_gerdat2.
          va_purchase = va_purchase - wa_zuonr-dmbtr.
        ENDIF.
      ELSE.
        IF wa_zuonr-budat GE va_gerdat1 AND
           wa_zuonr-budat LT va_gerdat2.
*        IF wa_zuonr-bldat GE va_gerdat1 AND
*           wa_zuonr-bldat LT va_gerdat2.
          va_payment = va_payment - wa_zuonr-dmbtr.
        ENDIF.
      ENDIF.
    ENDIF.

    MOVE wa_zuonr-belnr TO va_belnr.
    MOVE wa_zuonr-gjahr TO va_gjahr1.
    MOVE wa_zuonr-zuonr TO va_zuonr.

    IF wa_zuonr-augbl NE space.
      AT END OF augbl.
        IF sy-linno EQ 59.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED OFF.
          WRITE: /    sy-uline(219).
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

        va_endbal = va_begbal + va_purchase + va_payment.
        ADD va_begbal   TO total_begbal.
        ADD va_purchase TO total_purchase.
        ADD va_payment  TO total_payment.
        ADD va_endbal   TO total_endbal.
        ADD va_current  TO total_current.
        ADD va_dmbtr1   TO total_dmbtr1.
        ADD va_dmbtr2   TO total_dmbtr2.
        ADD va_dmbtr3   TO total_dmbtr3.
        ADD va_dmbtr4   TO total_dmbtr4.
        ADD va_dmbtr5   TO total_dmbtr5.

        IF va_begbal  NE 0 OR
          va_purchase NE 0 OR
          va_payment  NE 0 OR
          va_endbal   NE 0 OR
          va_current  NE 0.
          FORMAT INTENSIFIED OFF.
          WRITE: /    sy-vline, va_zuonr,
                  29  sy-vline, va_begbal CURRENCY va_currency,
                      sy-vline, va_purchase CURRENCY va_currency,
                      sy-vline, va_payment CURRENCY va_currency,
                      sy-vline, va_endbal CURRENCY va_currency,
                      sy-vline, va_current CURRENCY va_currency,
                      sy-vline, va_dmbtr1 CURRENCY va_currency,
                      sy-vline, va_dmbtr2 CURRENCY va_currency,
                      sy-vline, va_dmbtr3 CURRENCY va_currency,
                      sy-vline, va_dmbtr4 CURRENCY va_currency,
                      sy-vline, va_dmbtr5 CURRENCY va_currency,
                  219 sy-vline.
          HIDE: va_belnr, va_gjahr1.
          CLEAR: va_begbal, va_purchase, va_payment, va_endbal,
                 va_current, va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4,
                 va_dmbtr5.
        ELSE.
          IF zebra = 0.
            zebra = 1.
          ELSE.
            zebra = 0.
          ENDIF.
        ENDIF.
      ENDAT.
    ELSE.
      AT END OF belnr.
        IF sy-linno EQ 59.
          FORMAT COLOR OFF.
          FORMAT INTENSIFIED OFF.
          WRITE: /    sy-uline(219).
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

        va_endbal = va_begbal + va_purchase + va_payment.
        ADD va_begbal   TO total_begbal.
        ADD va_purchase TO total_purchase.
        ADD va_payment  TO total_payment.
        ADD va_endbal   TO total_endbal.
        ADD va_current  TO total_current.
        ADD va_dmbtr1   TO total_dmbtr1.
        ADD va_dmbtr2   TO total_dmbtr2.
        ADD va_dmbtr3   TO total_dmbtr3.
        ADD va_dmbtr4   TO total_dmbtr4.
        ADD va_dmbtr5   TO total_dmbtr5.

        IF va_begbal  NE 0 OR
          va_purchase NE 0 OR
          va_payment  NE 0 OR
          va_endbal   NE 0 OR
          va_current  NE 0.
          FORMAT INTENSIFIED OFF.
          WRITE: /    sy-vline, va_zuonr,
                  29  sy-vline, va_begbal CURRENCY va_currency,
                      sy-vline, va_purchase CURRENCY va_currency,
                      sy-vline, va_payment CURRENCY va_currency,
                      sy-vline, va_endbal CURRENCY va_currency,
                      sy-vline, va_current CURRENCY va_currency,
                      sy-vline, va_dmbtr1 CURRENCY va_currency,
                      sy-vline, va_dmbtr2 CURRENCY va_currency,
                      sy-vline, va_dmbtr3 CURRENCY va_currency,
                      sy-vline, va_dmbtr4 CURRENCY va_currency,
                      sy-vline, va_dmbtr5 CURRENCY va_currency,
                  219 sy-vline.
          HIDE: va_belnr, va_gjahr1.
          CLEAR: va_begbal, va_purchase, va_payment, va_endbal,
                 va_current, va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4,
                 va_dmbtr5.
        ELSE.
          IF zebra = 0.
            zebra = 1.
          ELSE.
            zebra = 0.
          ENDIF.
        ENDIF.
      ENDAT.
    ENDIF.
    CLEAR: wa_zuonr.
  ENDLOOP.

  FORMAT COLOR 3.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(219).
  WRITE: /    sy-vline, 'Total',
          29  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_purchase CURRENCY va_currency,
              sy-vline, total_payment CURRENCY va_currency,
              sy-vline, total_endbal CURRENCY va_currency,
              sy-vline, total_current CURRENCY va_currency,
              sy-vline, total_dmbtr1 CURRENCY va_currency,
              sy-vline, total_dmbtr2 CURRENCY va_currency,
              sy-vline, total_dmbtr3 CURRENCY va_currency,
              sy-vline, total_dmbtr4 CURRENCY va_currency,
              sy-vline, total_dmbtr5 CURRENCY va_currency,
          219 sy-vline.
  WRITE: /    sy-uline(219).
  FORMAT COLOR OFF.
  FORMAT INTENSIFIED OFF.
  CLEAR: total_begbal, total_purchase, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.
ENDFORM.                    " CETAK_DETAIL_ZUONR_TOTAL

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
          107 'AP AGING REPORT',
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
              sy-vline, 'Purchase',
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
*&      Form  CETAK_HEADER_LIFNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_header_lifnr.
  DATA: text_brsch(50).

  PERFORM cetak_header.
  IF counter = 1.
    IF va_count = 0.
      WRITE: / 'Grand Total AP Aging'.
    ENDIF.
  ELSE.
    IF va_brsch NE space.
      SELECT SINGLE brtxt
        FROM t016t
        INTO va_brtxt
        WHERE brsch EQ va_brsch.
      CONCATENATE va_gtext '(' va_brtxt ')' INTO text_brsch
                                            SEPARATED BY space.
      WRITE: /    'Business Area :', text_brsch.
    ELSEIF va_txt20 NE space.
      SELECT SINGLE txt20
        FROM skat
        INTO va_txt20
        WHERE spras EQ sy-langu  AND
              ktopl EQ 'TSPC'    AND
              saknr EQ va_hkont.
      CONCATENATE va_gtext '(' va_txt20 ')' INTO text_brsch
                                            SEPARATED BY space.
      WRITE: /    'Business Area :', text_brsch.
    ELSE.
      WRITE: /    'Business Area :', va_gtext.
    ENDIF.
  ENDIF.

  FORMAT COLOR 1.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'No. Vend.', '-', 'Vendor Name',
           40 sy-vline NO-GAP.
  SET LEFT SCROLL-BOUNDARY.
  WRITE:     'Beginning Balance',
              sy-vline, 'Purchase',
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
ENDFORM.                    " CETAK_HEADER_LIFNR

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

  IF counter = 1.
    WRITE: / 'Grand Total AP Aging'.
  ELSE.
    WRITE: /    'Business Area :', va_gtext.
  ENDIF.

  FORMAT COLOR 1.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'Industry', '-', 'Description',
           40 sy-vline NO-GAP.
  SET LEFT SCROLL-BOUNDARY.
  WRITE:     'Beginning Balance',
              sy-vline, 'Purchase',
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
*&      Form  CETAK_HEADER_ZUONR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cetak_header_zuonr.
  DATA: lv_ktokk  LIKE lfa1-ktokk.

  PERFORM cetak_header.

  SELECT SINGLE name1 ktokk
    FROM lfa1
    INTO (va_name1, lv_ktokk)
    WHERE lifnr EQ va_lifnr.

  IF counter = 1.
    IF va_count = 0.
      WRITE: / 'Grand Total AP Aging'.
    ENDIF.
  ELSE.
    WRITE: /    'Business Area :', va_gtext.
    WRITE: /    'Vendor Name   :', va_name1.
  ENDIF.

  FORMAT COLOR 1.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(232).
  WRITE: /    sy-vline, 'Invoice Number',
          29  sy-vline, 'Clrng doc.', sy-vline NO-GAP.
  SET LEFT SCROLL-BOUNDARY.
  WRITE:      'Beginning Balance',
              sy-vline, 'Purchase',
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
*&      Form  ZUONR_PROCESS1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zuonr_process1.
  DATA: lv_sort(25).

  REFRESH: i_zuonr,i_augbl.
  CLEAR: wa_itab.

  PERFORM f_get_modify USING va_lifnr va_gjahr1 va_belnr 'ZUONR'
                     CHANGING lv_sort.

  IF lv_sort EQ 'ONTV'.
    LOOP AT i_itab INTO wa_itab
      WHERE lifnr EQ va_lifnr AND
            belnr EQ va_belnr AND
            gjahr EQ va_gjahr1.
      MOVE wa_itab-gsber    TO wa_zuonr-gsber.
      MOVE wa_itab-lifnr    TO wa_zuonr-lifnr.
      MOVE wa_itab-budat    TO wa_zuonr-budat.
      MOVE wa_itab-bldat    TO wa_zuonr-bldat.
      MOVE wa_itab-augdt    TO wa_zuonr-augdt.
      MOVE wa_itab-shkzg    TO wa_zuonr-shkzg.
      MOVE wa_itab-monat    TO wa_zuonr-monat.
      MOVE wa_itab-blart    TO wa_zuonr-blart.
      MOVE wa_itab-zuonr    TO wa_zuonr-zuonr.
      MOVE wa_itab-current  TO wa_zuonr-current.
      MOVE wa_itab-dmbtr    TO wa_zuonr-dmbtr.
      MOVE wa_itab-dmbtr1   TO wa_zuonr-dmbtr1.
      MOVE wa_itab-dmbtr2   TO wa_zuonr-dmbtr2.
      MOVE wa_itab-dmbtr3   TO wa_zuonr-dmbtr3.
      MOVE wa_itab-dmbtr4   TO wa_zuonr-dmbtr4.
      MOVE wa_itab-dmbtr5   TO wa_zuonr-dmbtr5.
      MOVE wa_itab-belnr    TO wa_zuonr-belnr.
      MOVE wa_itab-gjahr    TO wa_zuonr-gjahr.
      MOVE wa_itab-augbl    TO wa_zuonr-augbl.
      APPEND wa_zuonr TO i_zuonr.
      CLEAR: wa_itab.

*      IF wa_zuonr-augbl IS NOT INITIAL.
*        i_augbl-augbl = wa_zuonr-augbl.
*        CASE wa_zuonr-shkzg.
*          WHEN 'H'.
*            i_augbl-dmbtr = wa_zuonr-dmbtr * -1.
*          WHEN 'S'.
*            i_augbl-dmbtr = wa_zuonr-dmbtr.
*          WHEN OTHERS.
*        ENDCASE.
*        COLLECT i_augbl. CLEAR i_augbl.
*      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT i_itab INTO wa_itab
      WHERE lifnr EQ va_lifnr.
      MOVE wa_itab-gsber    TO wa_zuonr-gsber.
      MOVE wa_itab-lifnr    TO wa_zuonr-lifnr.
      MOVE wa_itab-budat    TO wa_zuonr-budat.
      MOVE wa_itab-bldat    TO wa_zuonr-bldat.
      MOVE wa_itab-augdt    TO wa_zuonr-augdt.
      MOVE wa_itab-shkzg    TO wa_zuonr-shkzg.
      MOVE wa_itab-monat    TO wa_zuonr-monat.
      MOVE wa_itab-blart    TO wa_zuonr-blart.
      MOVE wa_itab-zuonr    TO wa_zuonr-zuonr.
      MOVE wa_itab-current  TO wa_zuonr-current.
      MOVE wa_itab-dmbtr    TO wa_zuonr-dmbtr.
      MOVE wa_itab-dmbtr1   TO wa_zuonr-dmbtr1.
      MOVE wa_itab-dmbtr2   TO wa_zuonr-dmbtr2.
      MOVE wa_itab-dmbtr3   TO wa_zuonr-dmbtr3.
      MOVE wa_itab-dmbtr4   TO wa_zuonr-dmbtr4.
      MOVE wa_itab-dmbtr5   TO wa_zuonr-dmbtr5.
      MOVE wa_itab-belnr    TO wa_zuonr-belnr.
      MOVE wa_itab-gjahr    TO wa_zuonr-gjahr.
      MOVE wa_itab-augbl    TO wa_zuonr-augbl.
      APPEND wa_zuonr TO i_zuonr.
      CLEAR: wa_itab.

*      IF wa_zuonr-augbl IS NOT INITIAL.
*        i_augbl-augbl = wa_zuonr-augbl.
*        CASE wa_zuonr-shkzg.
*          WHEN 'H'.
*            i_augbl-dmbtr = wa_zuonr-dmbtr * -1.
*          WHEN 'S'.
*            i_augbl-dmbtr = wa_zuonr-dmbtr.
*          WHEN OTHERS.
*        ENDCASE.
*        COLLECT i_augbl. CLEAR i_augbl.
*      ENDIF.
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
  DATA: zebra TYPE i.

  zebra = 0.

  PERFORM cetak_header_zuonr.

  CLEAR: wa_zuonr.
  SORT i_zuonr BY belnr augbl zuonr.
  LOOP AT i_zuonr INTO wa_zuonr
    WHERE lifnr EQ va_lifnr.

    IF wa_zuonr-shkzg EQ 'S'.
      ADD wa_zuonr-begbal TO va_begbal.
      ADD wa_zuonr-current TO va_current.
      ADD wa_zuonr-dmbtr1 TO va_dmbtr1.
      ADD wa_zuonr-dmbtr2 TO va_dmbtr2.
      ADD wa_zuonr-dmbtr3 TO va_dmbtr3.
      ADD wa_zuonr-dmbtr4 TO va_dmbtr4.
      ADD wa_zuonr-dmbtr5 TO va_dmbtr5.
      IF wa_zuonr-budat(6) LT pa_gstid(6).
*      IF wa_zuonr-bldat(6) LT pa_gstid(6).
        ADD wa_zuonr-dmbtr TO va_begbal.
      ENDIF.
      IF wa_zuonr-blart NE 'KZ'.
        IF wa_zuonr-budat GE va_gerdat1 AND
           wa_zuonr-budat LT va_gerdat2.
*        IF wa_zuonr-bldat GE va_gerdat1 AND
*           wa_zuonr-bldat LT va_gerdat2.
          ADD wa_zuonr-dmbtr TO va_purchase.
        ENDIF.
      ELSE.
        IF wa_zuonr-budat GE va_gerdat1 AND
           wa_zuonr-budat LT va_gerdat2.
*        IF wa_zuonr-bldat GE va_gerdat1 AND
*           wa_zuonr-bldat LT va_gerdat2.
          ADD wa_zuonr-dmbtr TO va_payment.
        ENDIF.
      ENDIF.
    ELSE.
      va_begbal = va_begbal - wa_zuonr-begbal.
      va_current = va_current - wa_zuonr-current.
      va_dmbtr1 = va_dmbtr1 - wa_zuonr-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_zuonr-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_zuonr-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_zuonr-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_zuonr-dmbtr5.
      IF wa_zuonr-budat(6) LT pa_gstid(6).
*      IF wa_zuonr-bldat(6) LT pa_gstid(6).
        va_begbal = va_begbal - wa_zuonr-dmbtr.
      ENDIF.
      IF wa_zuonr-blart NE 'KZ'.
        IF wa_zuonr-budat GE va_gerdat1 AND
           wa_zuonr-budat LT va_gerdat2.
*        IF wa_zuonr-bldat GE va_gerdat1 AND
*           wa_zuonr-bldat LT va_gerdat2.
          va_purchase = va_purchase - wa_zuonr-dmbtr.
        ENDIF.
      ELSE.
        IF wa_zuonr-budat GE va_gerdat1 AND
           wa_zuonr-budat LT va_gerdat2.
*        IF wa_zuonr-bldat GE va_gerdat1 AND
*           wa_zuonr-bldat LT va_gerdat2.
          va_payment = va_payment - wa_zuonr-dmbtr.
        ENDIF.
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

      va_endbal = va_begbal + va_purchase + va_payment.

      IF va_augbl IS NOT INITIAL.
        READ TABLE i_augbl WITH KEY augbl = va_augbl.
        IF sy-subrc = 0 AND i_augbl-dmbtr IS INITIAL.
          CLEAR: va_endbal,va_current,va_dmbtr1,va_dmbtr2,
                 va_dmbtr3,va_dmbtr4,va_dmbtr5.
        ENDIF.
      ENDIF.

      ADD va_begbal   TO total_begbal.
      ADD va_purchase TO total_purchase.
      ADD va_payment  TO total_payment.
      ADD va_endbal   TO total_endbal.
      ADD va_current  TO total_current.
      ADD va_dmbtr1   TO total_dmbtr1.
      ADD va_dmbtr2   TO total_dmbtr2.
      ADD va_dmbtr3   TO total_dmbtr3.
      ADD va_dmbtr4   TO total_dmbtr4.
      ADD va_dmbtr5   TO total_dmbtr5.

      IF va_begbal  NE 0 OR
        va_purchase NE 0 OR
        va_payment  NE 0 OR
        va_endbal   NE 0 OR
        va_current  NE 0.
        FORMAT INTENSIFIED OFF.
        WRITE: /    sy-vline, va_zuonr,
                29  sy-vline, va_augbl,
                    sy-vline, va_begbal CURRENCY va_currency,
                    sy-vline, va_purchase CURRENCY va_currency,
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
        CLEAR: va_begbal, va_purchase, va_payment, va_endbal,
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
              sy-vline, total_purchase CURRENCY va_currency,
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
  CLEAR: total_begbal, total_purchase, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.
ENDFORM.                    " CETAK_DETAIL_ZUONR1

*&---------------------------------------------------------------------*
*&      Form  LIFNR_PROCESS_11
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lifnr_process_11.
  REFRESH i_lifnr.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE brsch EQ va_brsch.
    MOVE wa_itab-gsber    TO wa_lifnr-gsber.
    MOVE wa_itab-budat    TO wa_lifnr-budat.
    MOVE wa_itab-bldat    TO wa_lifnr-bldat.
    MOVE wa_itab-augdt    TO wa_lifnr-augdt.
    MOVE wa_itab-lifnr    TO wa_lifnr-lifnr.
    MOVE wa_itab-shkzg    TO wa_lifnr-shkzg.
    MOVE wa_itab-monat    TO wa_lifnr-monat.
    MOVE wa_itab-blart    TO wa_lifnr-blart.
    MOVE wa_itab-current  TO wa_lifnr-current.
    MOVE wa_itab-dmbtr    TO wa_lifnr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_lifnr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_lifnr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_lifnr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_lifnr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_lifnr-dmbtr5.
    MOVE wa_itab-belnr    TO wa_lifnr-belnr.
    MOVE wa_itab-gjahr    TO wa_lifnr-gjahr.

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                 wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                   wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_lifnr TO i_lifnr.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " LIFNR_PROCESS_11

*&---------------------------------------------------------------------*
*&      Form  LIFNR_PROCESS1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lifnr_process1.
  SORT i_itab BY lifnr.
  REFRESH i_lifnr.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE lifnr IN so_lifnr.
    MOVE wa_itab-gsber    TO wa_lifnr-gsber.
    MOVE wa_itab-budat    TO wa_lifnr-budat.
    MOVE wa_itab-bldat    TO wa_lifnr-bldat.
    MOVE wa_itab-augdt    TO wa_lifnr-augdt.
    MOVE wa_itab-lifnr    TO wa_lifnr-lifnr.
    MOVE wa_itab-shkzg    TO wa_lifnr-shkzg.
    MOVE wa_itab-monat    TO wa_lifnr-monat.
    MOVE wa_itab-blart    TO wa_lifnr-blart.
    MOVE wa_itab-current  TO wa_lifnr-current.
    MOVE wa_itab-dmbtr    TO wa_lifnr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_lifnr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_lifnr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_lifnr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_lifnr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_lifnr-dmbtr5.
    MOVE wa_itab-belnr    TO wa_lifnr-belnr.
    MOVE wa_itab-gjahr    TO wa_lifnr-gjahr.

    PERFORM f_get_modify USING wa_lifnr-lifnr wa_lifnr-gjahr wa_lifnr-belnr 'PROC'
                         CHANGING wa_lifnr-objkey.

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                 wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                   wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_lifnr TO i_lifnr.
    CLEAR: wa_itab.
  ENDLOOP.
ENDFORM.                    " LIFNR_PROCESS1

*&---------------------------------------------------------------------*
*&      Form  BRSCH_PROCESS1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM brsch_process1.
  SORT i_itab BY brsch.
  REFRESH i_brsch.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE brsch IN so_brsch.
    MOVE wa_itab-gsber    TO wa_brsch-gsber.
    MOVE wa_itab-budat    TO wa_brsch-budat.
    MOVE wa_itab-bldat    TO wa_brsch-bldat.
    MOVE wa_itab-augdt    TO wa_brsch-augdt.
    MOVE wa_itab-lifnr    TO wa_brsch-lifnr.
    MOVE wa_itab-brsch    TO wa_brsch-brsch.
    MOVE wa_itab-shkzg    TO wa_brsch-shkzg.
    MOVE wa_itab-monat    TO wa_brsch-monat.
    MOVE wa_itab-blart    TO wa_brsch-blart.
    MOVE wa_itab-current  TO wa_brsch-current.
    MOVE wa_itab-dmbtr    TO wa_brsch-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_brsch-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_brsch-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_brsch-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_brsch-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_brsch-dmbtr5.

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
ENDFORM.                    " BRSCH_PROCESS1

*&---------------------------------------------------------------------*
*&      Form  GET_DATE_KZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_date_kz.
  CLEAR: wa_itab_kz.
*** Modify By Budi 10/03/2006
  CLEAR: va_clear, va_dmbtr.
*** End Modify
  IF wa_itab-blart EQ 'KZ'.
    READ TABLE i_itab_ka INTO wa_itab_kz
    WITH KEY augbl = wa_itab-augbl
             gsber = wa_itab-gsber
             lifnr = wa_itab-lifnr
             blart = 'KA'
    ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
    IF sy-subrc EQ 0.
      wa_itab-zfbdt = wa_itab_kz-augdt.
      wa_itab-zbd1t = wa_itab_kz-zbd1t.
*** Modify By Budi 10/03/2006
      va_clear = '1'.
*** End Modify
    ELSE.
      READ TABLE i_itab_kg INTO wa_itab_kz
      WITH KEY augbl = wa_itab-augbl
               gsber = wa_itab-gsber
               lifnr = wa_itab-lifnr
               blart = 'KG'
      ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc EQ 0.
        wa_itab-zfbdt = wa_itab_kz-augdt.
        wa_itab-zbd1t = wa_itab_kz-zbd1t.
*** Modify By Budi 10/03/2006
        va_clear = '1'.
*** End Modify
      ELSE.
        READ TABLE i_itab_kr INTO wa_itab_kz
        WITH KEY augbl = wa_itab-augbl
                 gsber = wa_itab-gsber
                 lifnr = wa_itab-lifnr
                 blart = 'KR'
        ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc EQ 0.
          wa_itab-zfbdt = wa_itab_kz-augdt.
          wa_itab-zbd1t = wa_itab_kz-zbd1t.
*** Modify By Budi 10/03/2006
          va_clear = '1'.
*** End Modify
        ELSE.
          READ TABLE i_itab_rc INTO wa_itab_kz
          WITH KEY augbl = wa_itab-augbl
                   gsber = wa_itab-gsber
                   lifnr = wa_itab-lifnr
                   blart = 'RC'
          ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
          IF sy-subrc EQ 0.
            wa_itab-zfbdt = wa_itab_kz-augdt.
            wa_itab-zbd1t = wa_itab_kz-zbd1t.
*** Modify By Budi 10/03/2006
            va_clear = '1'.
*** End Modify
          ELSE.
            READ TABLE i_itab_re INTO wa_itab_kz
            WITH KEY augbl = wa_itab-augbl
                     gsber = wa_itab-gsber
                     lifnr = wa_itab-lifnr
                     blart = 'RE'
            ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
            IF sy-subrc EQ 0.
              wa_itab-zfbdt = wa_itab_kz-augdt.
              wa_itab-zbd1t = wa_itab_kz-zbd1t.
*** Modify By Budi 10/03/2006
              va_clear = '1'.
*** End Modify
            ELSE.
              READ TABLE i_itab_sa INTO wa_itab_kz
              WITH KEY augbl = wa_itab-augbl
                       gsber = wa_itab-gsber
                       lifnr = wa_itab-lifnr
                       blart = 'SA'
              ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
              IF sy-subrc EQ 0.
                wa_itab-zfbdt = wa_itab_kz-augdt.
                wa_itab-zbd1t = wa_itab_kz-zbd1t.
*** Modify By Budi 10/03/2006
                va_clear = '1'.
*** End Modify
              ELSE.
                READ TABLE i_itab_op INTO wa_itab_kz
                WITH KEY augbl = wa_itab-augbl
                         gsber = wa_itab-gsber
                         lifnr = wa_itab-lifnr
                         blart = 'OP'
                ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
                IF sy-subrc EQ 0.
                  wa_itab-zfbdt = wa_itab_kz-augdt.
                  wa_itab-zbd1t = wa_itab_kz-zbd1t.
*** Modify By Budi 10/03/2006
                  va_clear = '1'.
                ELSE.
                  READ TABLE i_itab_k1 INTO wa_itab_kz
                  WITH KEY augbl = wa_itab-augbl
                           gsber = wa_itab-gsber
                           lifnr = wa_itab-lifnr
                           blart = 'K1'
                  ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
                  IF sy-subrc EQ 0.
                    wa_itab-zfbdt = wa_itab_kz-augdt.
                    wa_itab-zbd1t = wa_itab_kz-zbd1t.
                    va_clear = '1'.
*** Modify By Budi 26/07/2006
                  ELSE.
                    READ TABLE i_itab_ab INTO wa_itab_kz
                    WITH KEY augbl = wa_itab-augbl
                             gsber = wa_itab-gsber
                             lifnr = wa_itab-lifnr
                             blart = 'AB'
                    ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
                    IF sy-subrc EQ 0.
                      wa_itab-zfbdt = wa_itab_kz-augdt.
                      wa_itab-zbd1t = wa_itab_kz-zbd1t.
                      va_clear = '1'.
                    ELSE.
                      READ TABLE i_itab_zx INTO wa_itab_kz
                      WITH KEY augbl = wa_itab-augbl
                               gsber = wa_itab-gsber
                               lifnr = wa_itab-lifnr
                               blart = 'ZX'
                      ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
                      IF sy-subrc EQ 0.
                        wa_itab-zfbdt = wa_itab_kz-augdt.
                        wa_itab-zbd1t = wa_itab_kz-zbd1t.
                        va_clear = '1'.
                      ELSE.
                        READ TABLE i_itab_zy INTO wa_itab_kz
                        WITH KEY augbl = wa_itab-augbl
                                 gsber = wa_itab-gsber
                                 lifnr = wa_itab-lifnr
                                 blart = 'ZY'
                        ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
                        IF sy-subrc EQ 0.
                          wa_itab-zfbdt = wa_itab_kz-augdt.
                          wa_itab-zbd1t = wa_itab_kz-zbd1t.
                          va_clear = '1'.
                        ELSE.
                          READ TABLE i_itab_zz INTO wa_itab_kz
                          WITH KEY augbl = wa_itab-augbl
                                   gsber = wa_itab-gsber
                                   lifnr = wa_itab-lifnr
                                   blart = 'ZZ'
                          ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
                          IF sy-subrc EQ 0.
                            wa_itab-zfbdt = wa_itab_kz-augdt.
                            wa_itab-zbd1t = wa_itab_kz-zbd1t.
                            va_clear = '1'.
                          ENDIF.
                        ENDIF.
                      ENDIF.
                    ENDIF.
*** End Modify By Budi 26/07/2006
                  ENDIF.
*** End Modify
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*** Modify By Budi 10/03/2006
**** Modify by sukardi 26/07/2006
*  ELSEIF wa_itab-blart EQ 'AB'.
**** end mofidy by sukardi 26/07/2006
  ELSE.
*  READ TABLE I_ITAB_KZ INTO WA_ITAB_KZ
*  WITH KEY AUGBL = WA_ITAB-AUGBL BLART = 'KZ'
*  ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
*  IF SY-SUBRC EQ 0.
    LOOP AT i_itab_kz INTO wa_itab_kz
      WHERE augbl = wa_itab-augbl AND
            gsber = wa_itab-gsber AND
            lifnr = wa_itab-lifnr AND
            blart = 'KZ'.
      IF wa_itab_kz-shkzg EQ wa_itab-shkzg.
        wa_itab_kz-dmbtr = wa_itab_kz-dmbtr * -1.
      ENDIF.
      va_clear = '1'.
      va_dmbtr = va_dmbtr + wa_itab_kz-dmbtr.
*      IF wa_itab-augbl IS INITIAL.
*        DELETE TABLE i_itab_kz FROM wa_itab_kz.
*        EXIT.
*      ELSE.
      DELETE TABLE i_itab_kz FROM wa_itab_kz.
*      ENDIF.
    ENDLOOP.
*  ENDIF.
*** End Modify
  ENDIF.
ENDFORM.                    " GET_DATE_KZ

*&---------------------------------------------------------------------*
*&      Form  HKONT_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hkont_process.

  SORT i_itab BY hkont.
  REFRESH i_hkont.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE gsber EQ tgsbt-gsber AND
          hkont IN so_hkont.
    MOVE wa_itab-hkont    TO wa_hkont-hkont.
    MOVE wa_itab-gsber    TO wa_hkont-gsber.
    MOVE wa_itab-budat    TO wa_hkont-budat.
    MOVE wa_itab-bldat    TO wa_hkont-bldat.
    MOVE wa_itab-augdt    TO wa_hkont-augdt.
    MOVE wa_itab-lifnr    TO wa_hkont-lifnr.
    MOVE wa_itab-brsch    TO wa_hkont-brsch.
    MOVE wa_itab-shkzg    TO wa_hkont-shkzg.
    MOVE wa_itab-monat    TO wa_hkont-monat.
    MOVE wa_itab-blart    TO wa_hkont-blart.
    MOVE wa_itab-current  TO wa_hkont-current.
    MOVE wa_itab-dmbtr    TO wa_hkont-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_hkont-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_hkont-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_hkont-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_hkont-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_hkont-dmbtr5.

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

  DATA: zebra TYPE i.

  zebra = 0.

  PERFORM cetak_header_hkont.

  CLEAR: wa_hkont.
*  SORT i_hkont BY hkont.
  SORT i_hkont." BY hkont. "Modify by sol_jonhar 01/10/2020
  LOOP AT i_hkont INTO wa_hkont.
    IF wa_hkont-shkzg EQ 'S'.
      ADD wa_hkont-current TO va_current.
      ADD wa_hkont-dmbtr1 TO va_dmbtr1.
      ADD wa_hkont-dmbtr2 TO va_dmbtr2.
      ADD wa_hkont-dmbtr3 TO va_dmbtr3.
      ADD wa_hkont-dmbtr4 TO va_dmbtr4.
      ADD wa_hkont-dmbtr5 TO va_dmbtr5.
      IF wa_hkont-budat(6) LT pa_gstid(6).
*      IF wa_hkont-bldat(6) LT pa_gstid(6).
        ADD wa_hkont-dmbtr TO va_begbal.
      ENDIF.
      IF wa_hkont-blart NE 'KZ'.
        IF wa_hkont-budat GE va_gerdat1 AND
           wa_hkont-budat LT va_gerdat2.
*        IF wa_hkont-bldat GE va_gerdat1 AND
*           wa_hkont-bldat LT va_gerdat2.
          ADD wa_hkont-dmbtr TO va_purchase.
        ENDIF.
      ELSE.
        IF wa_hkont-budat GE va_gerdat1 AND
           wa_hkont-budat LT va_gerdat2.
*        IF wa_hkont-bldat GE va_gerdat1 AND
*           wa_hkont-bldat LT va_gerdat2.
          ADD wa_hkont-dmbtr TO va_payment.
        ENDIF.
      ENDIF.
    ELSE.
      va_current = va_current - wa_hkont-current.
      va_dmbtr1 = va_dmbtr1 - wa_hkont-dmbtr1.
      va_dmbtr2 = va_dmbtr2 - wa_hkont-dmbtr2.
      va_dmbtr3 = va_dmbtr3 - wa_hkont-dmbtr3.
      va_dmbtr4 = va_dmbtr4 - wa_hkont-dmbtr4.
      va_dmbtr5 = va_dmbtr5 - wa_hkont-dmbtr5.
      IF wa_hkont-budat(6) LT pa_gstid(6).
*      IF wa_hkont-bldat(6) LT pa_gstid(6).
        va_begbal = va_begbal - wa_hkont-dmbtr.
      ENDIF.
      IF wa_hkont-blart NE 'KZ'.
        IF wa_hkont-budat GE va_gerdat1 AND
           wa_hkont-budat LT va_gerdat2.
*        IF wa_hkont-bldat GE va_gerdat1 AND
*           wa_hkont-bldat LT va_gerdat2.
          va_purchase = va_purchase - wa_hkont-dmbtr.
        ENDIF.
      ELSE.
        IF wa_hkont-budat GE va_gerdat1 AND
           wa_hkont-budat LT va_gerdat2.
*        IF wa_hkont-bldat GE va_gerdat1 AND
*           wa_hkont-bldat LT va_gerdat2.
          va_payment = va_payment - wa_hkont-dmbtr.
        ENDIF.
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

      va_endbal = va_begbal + va_purchase + va_payment.
      WRITE va_begbal TO va_begbal1 CURRENCY va_currency.

      IF fvalue EQ 'Grand Total'.
        MOVE wa_hkont-hkont TO va_hkont1.
      ELSE.
        MOVE wa_hkont-hkont TO va_hkont.
      ENDIF.

      IF va_begbal  NE 0 OR
        va_purchase NE 0 OR
        va_payment  NE 0 OR
        va_endbal   NE 0.
        IF fvalue EQ 'Grand Total'.
          WRITE: /    sy-vline NO-GAP, va_hkont1, '-', va_txt20 NO-GAP.
        ELSE.
          WRITE: /    sy-vline NO-GAP, va_hkont, '-', va_txt20 NO-GAP.
        ENDIF.
        WRITE:      sy-vline, va_begbal CURRENCY va_currency,
                    sy-vline, va_purchase CURRENCY va_currency,
                    sy-vline, va_payment CURRENCY va_currency,
                    sy-vline, va_endbal CURRENCY va_currency,
                    sy-vline, va_current CURRENCY va_currency,
                    sy-vline, va_dmbtr1 CURRENCY va_currency,
                    sy-vline, va_dmbtr2 CURRENCY va_currency,
                    sy-vline, va_dmbtr3 CURRENCY va_currency,
                    sy-vline, va_dmbtr4 CURRENCY va_currency,
                    sy-vline, va_dmbtr5 CURRENCY va_currency,
                    sy-vline.

        ADD va_begbal   TO total_begbal.
        ADD va_purchase TO total_purchase.
        ADD va_payment  TO total_payment.
        ADD va_endbal   TO total_endbal.
        ADD va_current  TO total_current.
        ADD va_dmbtr1   TO total_dmbtr1.
        ADD va_dmbtr2   TO total_dmbtr2.
        ADD va_dmbtr3   TO total_dmbtr3.
        ADD va_dmbtr4   TO total_dmbtr4.
        ADD va_dmbtr5   TO total_dmbtr5.
      ELSE.
        IF zebra = 0.
          zebra = 1.
        ELSE.
          zebra = 0.
        ENDIF.
      ENDIF.

      CLEAR: va_begbal, va_purchase, va_payment, va_endbal, va_current,
             va_dmbtr1, va_dmbtr2, va_dmbtr3, va_dmbtr4, va_dmbtr5.
    ENDAT.
    CLEAR: wa_hkont.
  ENDLOOP.

  FORMAT COLOR 3.
  FORMAT INTENSIFIED ON.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'Total',
          40  sy-vline, total_begbal CURRENCY va_currency,
              sy-vline, total_purchase CURRENCY va_currency,
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
  CLEAR: total_begbal, total_purchase, total_payment, total_endbal,
         total_current, total_dmbtr1, total_dmbtr2, total_dmbtr3,
         total_dmbtr4, total_dmbtr5.

ENDFORM.                    " CETAK_DETAIL_HKONT

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

  IF counter = 1.
    WRITE: / 'Grand Total AP Aging'.
  ELSE.
    WRITE: /    'Business Area :', va_gtext.
  ENDIF.

  FORMAT COLOR 1.
  WRITE: /    sy-uline(230).
  WRITE: /    sy-vline, 'Account', '-', 'Description',
           40 sy-vline NO-GAP.
  SET LEFT SCROLL-BOUNDARY.
  WRITE:     'Beginning Balance',
              sy-vline, 'Purchase',
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
*&      Form  HKONT_PROCESS1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hkont_process1.

  SORT i_itab BY hkont.
  REFRESH i_hkont.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE hkont IN so_hkont.
    MOVE wa_itab-hkont    TO wa_hkont-hkont.
    MOVE wa_itab-gsber    TO wa_hkont-gsber.
    MOVE wa_itab-budat    TO wa_hkont-budat.
    MOVE wa_itab-bldat    TO wa_hkont-bldat.
    MOVE wa_itab-augdt    TO wa_hkont-augdt.
    MOVE wa_itab-lifnr    TO wa_hkont-lifnr.
    MOVE wa_itab-brsch    TO wa_hkont-brsch.
    MOVE wa_itab-shkzg    TO wa_hkont-shkzg.
    MOVE wa_itab-monat    TO wa_hkont-monat.
    MOVE wa_itab-blart    TO wa_hkont-blart.
    MOVE wa_itab-current  TO wa_hkont-current.
    MOVE wa_itab-dmbtr    TO wa_hkont-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_hkont-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_hkont-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_hkont-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_hkont-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_hkont-dmbtr5.

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

ENDFORM.                    " HKONT_PROCESS1

*&---------------------------------------------------------------------*
*&      Form  LIFNR_PROCESS_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lifnr_process_2.

  REFRESH i_lifnr.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE gsber EQ tgsbt-gsber AND
          hkont EQ va_hkont.
    MOVE wa_itab-gsber    TO wa_lifnr-gsber.
    MOVE wa_itab-budat    TO wa_lifnr-budat.
    MOVE wa_itab-bldat    TO wa_lifnr-bldat.
    MOVE wa_itab-augdt    TO wa_lifnr-augdt.
    MOVE wa_itab-lifnr    TO wa_lifnr-lifnr.
    MOVE wa_itab-shkzg    TO wa_lifnr-shkzg.
    MOVE wa_itab-monat    TO wa_lifnr-monat.
    MOVE wa_itab-blart    TO wa_lifnr-blart.
    MOVE wa_itab-current  TO wa_lifnr-current.
    MOVE wa_itab-dmbtr    TO wa_lifnr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_lifnr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_lifnr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_lifnr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_lifnr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_lifnr-dmbtr5.
    MOVE wa_itab-belnr    TO wa_lifnr-belnr.
    MOVE wa_itab-gjahr    TO wa_lifnr-gjahr.

    PERFORM f_get_modify USING wa_lifnr-lifnr wa_lifnr-gjahr wa_lifnr-belnr 'PROC'
                         CHANGING wa_lifnr-objkey.

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                 wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                   wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_lifnr TO i_lifnr.
    CLEAR: wa_itab.
  ENDLOOP.

ENDFORM.                    " LIFNR_PROCESS_2

*&---------------------------------------------------------------------*
*&      Form  LIFNR_PROCESS_21
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lifnr_process_21.

  REFRESH i_lifnr.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE hkont EQ va_hkont.
    MOVE wa_itab-gsber    TO wa_lifnr-gsber.
    MOVE wa_itab-budat    TO wa_lifnr-budat.
    MOVE wa_itab-bldat    TO wa_lifnr-bldat.
    MOVE wa_itab-augdt    TO wa_lifnr-augdt.
    MOVE wa_itab-lifnr    TO wa_lifnr-lifnr.
    MOVE wa_itab-shkzg    TO wa_lifnr-shkzg.
    MOVE wa_itab-monat    TO wa_lifnr-monat.
    MOVE wa_itab-blart    TO wa_lifnr-blart.
    MOVE wa_itab-current  TO wa_lifnr-current.
    MOVE wa_itab-dmbtr    TO wa_lifnr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_lifnr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_lifnr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_lifnr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_lifnr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_lifnr-dmbtr5.
    MOVE wa_itab-belnr    TO wa_lifnr-belnr.
    MOVE wa_itab-gjahr    TO wa_lifnr-gjahr.

    PERFORM f_get_modify USING wa_lifnr-lifnr wa_lifnr-gjahr wa_lifnr-belnr 'PROC'
                         CHANGING wa_lifnr-objkey.

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                 wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                   wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_lifnr TO i_lifnr.
    CLEAR: wa_itab.
  ENDLOOP.

ENDFORM.                    " LIFNR_PROCESS_21

*&---------------------------------------------------------------------*
*&      Form  LIFNR_PROCESS_2_TOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lifnr_process_2_total.

  REFRESH i_lifnr.
  CLEAR: wa_itab.
  LOOP AT i_itab INTO wa_itab
    WHERE hkont EQ va_hkont1.
    MOVE wa_itab-gsber    TO wa_lifnr-gsber.
    MOVE wa_itab-budat    TO wa_lifnr-budat.
    MOVE wa_itab-bldat    TO wa_lifnr-bldat.
    MOVE wa_itab-augdt    TO wa_lifnr-augdt.
    MOVE wa_itab-lifnr    TO wa_lifnr-lifnr.
    MOVE wa_itab-shkzg    TO wa_lifnr-shkzg.
    MOVE wa_itab-monat    TO wa_lifnr-monat.
    MOVE wa_itab-blart    TO wa_lifnr-blart.
    MOVE wa_itab-current  TO wa_lifnr-current.
    MOVE wa_itab-dmbtr    TO wa_lifnr-dmbtr.
    MOVE wa_itab-dmbtr1   TO wa_lifnr-dmbtr1.
    MOVE wa_itab-dmbtr2   TO wa_lifnr-dmbtr2.
    MOVE wa_itab-dmbtr3   TO wa_lifnr-dmbtr3.
    MOVE wa_itab-dmbtr4   TO wa_lifnr-dmbtr4.
    MOVE wa_itab-dmbtr5   TO wa_lifnr-dmbtr5.
    MOVE wa_itab-belnr    TO wa_lifnr-belnr.
    MOVE wa_itab-gjahr    TO wa_lifnr-gjahr.

    IF wa_itab-augbl IS NOT INITIAL.
      READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
      IF sy-subrc = 0.
        IF i_augbl-dmbtr IS INITIAL.
          CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                 wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
        ENDIF.
      ELSE.
        SORT i_augbl BY augbl.
        READ TABLE i_augbl WITH KEY augbl = wa_itab-augbl ."BINARY SEARCH - Modify By sol_jonhar 01/10/2020.
        IF sy-subrc = 0.
          IF i_augbl-dmbtr IS INITIAL.
            CLEAR: wa_lifnr-current,wa_lifnr-dmbtr1,wa_lifnr-dmbtr2,
                   wa_lifnr-dmbtr3,wa_lifnr-dmbtr4,wa_lifnr-dmbtr5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND wa_lifnr TO i_lifnr.
    CLEAR: wa_itab.
  ENDLOOP.

ENDFORM.                    " LIFNR_PROCESS_2_TOTAL

*&---------------------------------------------------------------------*
*&      Form  CEK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cek.

  DATA : i_gsber TYPE tgsb-gsber OCCURS 0 WITH HEADER LINE.

  SELECT gsber INTO TABLE i_gsber
    FROM tgsb WHERE gsber IN so_gsber.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD pa_bukrs
           ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    MESSAGE i002(zz) WITH
      'You have no authorization for Company Code' pa_bukrs.
    STOP.
  ENDIF.
  LOOP AT i_gsber.
    AUTHORITY-CHECK OBJECT 'F_BKPF_GSB'
             ID 'GSBER' FIELD i_gsber
             ID 'ACTVT' FIELD '01'.
    IF sy-subrc NE 0.
      MESSAGE i002(zz) WITH
        'You have no authorization for Business Area' i_gsber.
      STOP.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CEK

*&---------------------------------------------------------------------*
*&      Form  F_GET_MODIFY
*&---------------------------------------------------------------------*
FORM f_get_modify  USING    fu_lifnr fu_gjahr fu_belnr fu_process
                   CHANGING fc_name1.

  DATA: lv_ktokk  TYPE lfa1-ktokk.

  SELECT SINGLE name1 ktokk
    FROM lfa1
    INTO (fc_name1, lv_ktokk)
    WHERE lifnr EQ fu_lifnr.

  CASE fu_process.
    WHEN 'PRINT'.
      IF lv_ktokk EQ 'ONTV'.
        SELECT SINGLE name1
        FROM bsec
        INTO fc_name1
        WHERE bukrs EQ pa_bukrs AND
              belnr EQ fu_belnr AND
              gjahr EQ fu_gjahr.
      ENDIF.
    WHEN 'PROC'.
      IF lv_ktokk EQ 'ONTV'.
        CONCATENATE fu_lifnr fu_belnr INTO fc_name1.
      ELSE.
        fc_name1  = fu_lifnr.
      ENDIF.
    WHEN 'ZUONR'.
      fc_name1  = lv_ktokk.
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
