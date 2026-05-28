*&---------------------------------------------------------------------*
*& Report  ZF_DAY_SLS_OUTSTANDING_FKART
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zf_day_sales_outstanding MESSAGE-ID zf
                                NO STANDARD PAGE HEADING
                                LINE-SIZE  157.

INCLUDE zsheader.

INCLUDE zf_dso_fkarttop.

****************************************************
*        Parameters                                *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS   pa_bukrs LIKE t001-bukrs OBLIGATORY DEFAULT '8020'.
SELECT-OPTIONS  so_gsber FOR tvbur-vkbur.
SELECT-OPTIONS  so_kdgrp FOR knvv-kdgrp.
SELECT-OPTIONS  so_kvgr3 FOR knvv-kvgr3 MODIF ID kv3.
SELECT-OPTIONS  so_brsch FOR kna1-brsch.
SELECT-OPTIONS  so_kunnr FOR bsid-kunnr.
SELECT-OPTIONS  so_fkart FOR tvfk-fkart.
PARAMETERS   pa_date LIKE sy-datum OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN SKIP 1.
PARAMETERS   pa_dso(2) DEFAULT '03'.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-003.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: x_norm LIKE itemset-xnorm AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 4(24) TEXT-104 FOR FIELD x_norm.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: x_shbv LIKE itemset-xshbv AS CHECKBOX.
SELECTION-SCREEN : COMMENT 4(24) TEXT-105 FOR FIELD x_shbv.
SELECTION-SCREEN:  POSITION 30.
SELECT-OPTIONS: so_umskz FOR bsid-umskz NO INTERVALS.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK c WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND usr.
SELECTION-SCREEN : COMMENT 5(45) TEXT-003 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(45) TEXT-004 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(45) TEXT-005 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(45) TEXT-006 FOR FIELD radio4.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio5 RADIOBUTTON GROUP grp1 MODIF ID ptt.
SELECTION-SCREEN : COMMENT 5(45) TEXT-007 FOR FIELD radio5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio6 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(50) TEXT-008 FOR FIELD radio6.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio7 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(50) TEXT-009 FOR FIELD radio7.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio9 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(50) TEXT-017 FOR FIELD radio9.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio10 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(79) TEXT-018 FOR FIELD radio10.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio8 RADIOBUTTON GROUP grp1 MODIF ID sut.
SELECTION-SCREEN : COMMENT 5(50) TEXT-016 FOR FIELD radio8.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK c.

AT SELECTION-SCREEN OUTPUT.
  IF pa_bukrs EQ '8070'.
    LOOP AT SCREEN.
      IF screen-group1 = 'PTT'.
        screen-active  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'SUT'.
        screen-active  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  LOOP AT SCREEN.
    CASE 'X'.
      WHEN radio10.
        IF screen-group1 = 'KV3'.
          screen-input  = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN OTHERS.
        IF screen-group1 = 'KV3'.
          screen-input  = 1.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
  ENDLOOP.

************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* AT SELECTION-SCREEN
************************************************************************
AT SELECTION-SCREEN ON RADIOBUTTON GROUP grp1.
  CASE 'X'.
    WHEN radio10.
      PERFORM f_init_kvgr3.
    WHEN OTHERS.
      CLEAR: so_kvgr3,so_kvgr3[].
  ENDCASE.

AT SELECTION-SCREEN ON so_kunnr .
  SELECT SINGLE * FROM kna1
         WHERE kunnr IN so_kunnr.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Customer Number Not Found'.
  ENDIF.

AT SELECTION-SCREEN ON so_kdgrp.
  SELECT SINGLE * FROM t151
         WHERE kdgrp IN so_kdgrp.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Customer Group Not Found'.
  ENDIF.

AT SELECTION-SCREEN ON so_kvgr3.
  SELECT SINGLE kvgr3 INTO gv_kvgr3 FROM tvv3
         WHERE kvgr3 IN so_kvgr3.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Sub Customer Group Not Found'.
  ENDIF.

AT SELECTION-SCREEN ON so_brsch.
  SELECT SINGLE * FROM t016
         WHERE brsch IN so_brsch.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Industry Code Not Found'.
  ENDIF.

AT SELECTION-SCREEN ON pa_bukrs.
  SELECT SINGLE butxt INTO v_title1 FROM t001 WHERE bukrs EQ pa_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Company Not Found'.
  ENDIF.

  IF pa_bukrs EQ '8020' OR pa_bukrs EQ '8030' OR
    pa_bukrs EQ '8070'.
  ELSE.
    MESSAGE e000(zs)
      WITH 'CoCd must be entry (8020, 8030, 8070)'.
  ENDIF.

AT SELECTION-SCREEN ON so_gsber.
  SELECT SINGLE * FROM tvbur
         WHERE vkbur IN so_gsber.
  IF sy-subrc NE 0.
    MESSAGE e000(zf) WITH 'Sales Office Not Found'.
  ENDIF.

AT SELECTION-SCREEN ON so_umskz.
  IF x_shbv = 'X' AND so_umskz IS INITIAL.
    so_umskz-low = 'T'.
    so_umskz-sign = 'I'.
    so_umskz-option = 'EQ'.
    APPEND so_umskz.

    so_umskz-low = 'V'.
    so_umskz-sign = 'I'.
    so_umskz-option = 'EQ'.
    APPEND so_umskz.

    so_umskz-low = 'U'.
    so_umskz-sign = 'I'.
    so_umskz-option = 'EQ'.
    APPEND so_umskz.
  ENDIF.

************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
  DATA lv_parva(40).

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'BUK'.

  IF sy-subrc EQ 0.
    pa_bukrs  = lv_parva.
  ENDIF.

  CLEAR lv_parva.

  SELECT SINGLE parva
    FROM usr05
    INTO lv_parva
    WHERE bname EQ sy-uname AND
          parid EQ 'GSB'.

  IF sy-subrc EQ 0.
    so_gsber-low  = lv_parva.
    APPEND so_gsber.
  ENDIF.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.
  IF pa_bukrs EQ '8070'.
    SET PF-STATUS '101'.
  ELSE.
    SET PF-STATUS '100'.
  ENDIF.
*  sy-pagno = 1.
  PERFORM cek.

  v_repid = 'Day Sales Outstanding'.

  PERFORM f_init_column.
  PERFORM f_mapping_soff.
  PERFORM f_get_data.

  DESCRIBE TABLE i_itab LINES c1.
  WRITE ra_budat-low TO va_text.
  WRITE ra_budat-high TO v_title3.
  CONCATENATE 'Periode ' va_text 'to' v_title3
      INTO v_title3 SEPARATED BY space.

  PERFORM f_dso_billing_type TABLES i_itab.
  PERFORM f_dso_billing_type TABLES i_itab3.

  CASE 'X'.
    WHEN radio1.
*      PERFORM f_proses1.    " Branch
      PERFORM f_new_proses1.
    WHEN radio2.
*      PERFORM f_proses2.    " Customer Group
      PERFORM f_new_proses2.
    WHEN radio3.
*      PERFORM f_proses3.    " Salesman
      PERFORM f_new_proses3.
    WHEN radio4.
*      PERFORM f_proses4.    " Customer
      PERFORM f_new_proses4.
    WHEN radio5.
*      PERFORM f_proses5.    " Industry Code
      PERFORM f_new_proses5.
    WHEN radio6.
*      PERFORM f_proses6.    " Customer Group Nasional
      PERFORM f_new_proses6.
    WHEN radio7.
*      PERFORM f_proses7.    " Channel, Customer Group
      PERFORM f_new_proses7.
    WHEN radio8.
*      PERFORM f_proses8.    " Sub Customer Group
      PERFORM f_new_proses8.
    WHEN radio9.
*      PERFORM f_proses9.    " Billing Type
      PERFORM f_new_proses9.
    WHEN radio10.
      NEW-PAGE LINE-SIZE 173.
      PERFORM f_proses4.    " Customer - Tempo Trading
  ENDCASE.

  INCLUDE zf_dso_fkartf01.

TOP-OF-PAGE.
*   Perform f_write_header.
*   Perform f_write_header_column.
END-OF-PAGE.

AT USER-COMMAND.
  sy-lsind = 0.
  CASE sy-ucomm.
    WHEN 'BRANCH'.
      CLEAR: radio1,radio2,radio3,radio4,radio5,radio6,radio7,radio8,radio9,radio10.
*      PERFORM f_proses1.
      PERFORM f_new_proses1.
    WHEN 'CUSTOMER'.
      CLEAR: radio1,radio2,radio3,radio4,radio5,radio6,radio7,radio8,radio9,radio10.
*      PERFORM f_proses4.
      PERFORM f_new_proses4.
    WHEN 'SALESMAN'.
      CLEAR: radio1,radio2,radio3,radio4,radio5,radio6,radio7,radio8,radio9,radio10.
*      PERFORM f_proses3.
      PERFORM f_new_proses3.
    WHEN 'CUSTGROUP'.
      CLEAR: radio1,radio2,radio3,radio4,radio5,radio6,radio7,radio8,radio9,radio10.
*      PERFORM f_proses2.
      PERFORM f_new_proses2.
    WHEN 'INDUSTRY'.
      CLEAR: radio1,radio2,radio3,radio4,radio5,radio6,radio7,radio8,radio9,radio10.
*      PERFORM f_proses5.
      PERFORM f_new_proses5.
    WHEN 'GROUPNAS'.
      CLEAR: radio1,radio2,radio3,radio4,radio5,radio6,radio7,radio8,radio9,radio10.
*      PERFORM f_proses6.
      PERFORM f_new_proses6.
    WHEN 'CHANNEL'.
      CLEAR: radio1,radio2,radio3,radio4,radio5,radio6,radio7,radio8,radio9,radio10.
*      PERFORM f_proses7.
      PERFORM f_new_proses7.
    WHEN 'SUBCUSTGRP'.
      CLEAR: radio1,radio2,radio3,radio4,radio5,radio6,radio7,radio8,radio9,radio10.
*      PERFORM f_proses8.
      PERFORM f_new_proses8.
    WHEN 'BILLTY'.
      CLEAR: radio1,radio2,radio3,radio4,radio5,radio6,radio7,radio8,radio9,radio10.
*      PERFORM f_proses9.
      PERFORM f_new_proses9.
    WHEN '05T'.
      CLEAR: radio1,radio2,radio3,radio4,radio5,radio6,radio7,radio8,radio9,radio10.
      radio10 = 'X'.
      NEW-PAGE LINE-SIZE 173.
      PERFORM f_proses4.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE  PROGRAM.
  ENDCASE.

  INCLUDE zf_dso_fkartf02.
