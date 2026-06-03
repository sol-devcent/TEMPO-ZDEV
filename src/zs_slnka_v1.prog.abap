
*&---------------------------------------------------------------------*
*& Report  ZS_SLNKA_V1
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zs_slnka_v1 NO STANDARD PAGE HEADING.

INCLUDE zabp_header.
INCLUDE zs_slnka_v1alv.
INCLUDE zs_slnka_v1top.

DATA : v_prodh LIKE t179-prodh.
RANGES : r_matkl FOR vbap-matkl.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS      p_vkorg LIKE tvko-vkorg DEFAULT '8020' OBLIGATORY.
SELECT-OPTIONS  s_vkbur FOR vbak-vkbur OBLIGATORY MODIF ID xxx.
SELECT-OPTIONS  s_erdat FOR vbak-erdat OBLIGATORY.
SELECT-OPTIONS  s_auart FOR vbak-auart NO INTERVALS MODIF ID bud.
SELECT-OPTIONS  s_kdgrp FOR vbkd-kdgrp.
SELECT-OPTIONS  s_kvgr3 FOR knvv-kvgr3.
SELECT-OPTIONS  s_kvgr4 FOR knvv-kvgr4.
SELECT-OPTIONS  s_knkli FOR vbak-knkli.
SELECT-OPTIONS  s_matkl FOR vbap-matkl.
SELECT-OPTIONS  s_matnr FOR vbap-matnr.
SELECT-OPTIONS  s_quotn FOR vbak-vbeln.
SELECT-OPTIONS  s_quotd FOR vbak-erdat.
SELECT-OPTIONS  s_vbeln FOR vbap-vbeln.
PARAMETERS      p_vkbur LIKE vbak-vkbur NO-DISPLAY.
PARAMETERS      p_down  AS CHECKBOX MODIF ID dwn.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE text-003.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS      p_val RADIOBUTTON GROUP grp2
                      DEFAULT 'X' USER-COMMAND grp2.
SELECTION-SCREEN COMMENT (40) text-010 FOR FIELD p_val.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS      p_qty RADIOBUTTON GROUP grp2.
SELECTION-SCREEN COMMENT (40) text-011 FOR FIELD p_qty.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block3.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-002.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio1 RADIOBUTTON GROUP grp1
                    DEFAULT 'X' USER-COMMAND grp1.
SELECTION-SCREEN : COMMENT (60) text-012 FOR FIELD radio1.
SELECTION-SCREEN POSITION 65.
PARAMETERS : p_stkout AS CHECKBOX MODIF ID 001.
SELECTION-SCREEN : COMMENT (25) text-013 FOR FIELD p_stkout.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (45) text-017 FOR FIELD radio3.
SELECTION-SCREEN POSITION 50.
PARAMETERS : p_total3 AS CHECKBOX MODIF ID 003.
SELECTION-SCREEN : COMMENT (7) text-023 FOR FIELD p_total3.
SELECTION-SCREEN POSITION 61.
PARAMETERS : p_text3 AS CHECKBOX MODIF ID 003.
SELECTION-SCREEN : COMMENT (9) text-029 FOR FIELD p_text3.
SELECTION-SCREEN POSITION 72.
PARAMETERS : p_back1 AS CHECKBOX MODIF ID 003.
SELECTION-SCREEN : COMMENT (11) text-030 FOR FIELD p_back1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (45) text-016 FOR FIELD radio2.
SELECTION-SCREEN POSITION 50.
PARAMETERS : p_total2 AS CHECKBOX MODIF ID 002.
SELECTION-SCREEN : COMMENT (7) text-023 FOR FIELD p_total2.
SELECTION-SCREEN POSITION 61.
PARAMETERS : p_text2 AS CHECKBOX MODIF ID 002.
SELECTION-SCREEN : COMMENT (9) text-029 FOR FIELD p_text2.
SELECTION-SCREEN POSITION 72.
PARAMETERS : p_back AS CHECKBOX MODIF ID 002.
SELECTION-SCREEN : COMMENT (11) text-030 FOR FIELD p_back.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (60) text-018 FOR FIELD radio4.
SELECTION-SCREEN POSITION 65.
PARAMETERS : p_total4 AS CHECKBOX MODIF ID 004.
SELECTION-SCREEN : COMMENT (11) text-021 FOR FIELD p_total4.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio5 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (60) text-015 FOR FIELD radio5.
SELECTION-SCREEN POSITION 65.
PARAMETERS : p_summ5 AS CHECKBOX DEFAULT 'X' MODIF ID 005.
SELECTION-SCREEN : COMMENT (25) text-025 FOR FIELD p_summ5.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : radio6 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT (60) text-020 FOR FIELD radio6.
SELECTION-SCREEN POSITION 65.
PARAMETERS : p_summ6 AS CHECKBOX DEFAULT 'X' MODIF ID 006.
SELECTION-SCREEN : COMMENT (25) text-025 FOR FIELD p_summ6.
SELECTION-SCREEN END OF LINE.

PARAMETERS radio7 RADIOBUTTON GROUP grp1 MODIF ID hid.

SELECTION-SCREEN END OF BLOCK block2.


AT SELECTION-SCREEN.
  IF sy-slset = 'GEM'.
    CLEAR : s_matnr[], s_matnr.
    LOOP AT gt_mara.
      s_matnr-low     = gt_mara-matnr.
      s_matnr-sign    = 'I'.
      s_matnr-option  = 'EQ'.
      APPEND s_matnr.
      CLEAR s_matnr.
    ENDLOOP.
  ENDIF.

AT SELECTION-SCREEN ON s_matkl.
  REFRESH: r_matkl.
  SELECT prodh INTO v_prodh FROM t179 WHERE  prodh IN s_matkl.
    AUTHORITY-CHECK OBJECT 'ZPRINCIPAL'
        ID 'PRODH' FIELD v_prodh(3).
    IF sy-subrc EQ 0.
      r_matkl-sign  = 'I'.
      r_matkl-option = 'EQ'.
      r_matkl-low = v_prodh.
      APPEND r_matkl.
    ENDIF.
  ENDSELECT.
  IF r_matkl IS INITIAL.
    MESSAGE e002(zz) WITH 'You are not authorized'.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF gs_groups-usergroup IS INITIAL.
      IF screen-group1 = 'HID'.
        screen-active = '0'.
      ENDIF.
    ENDIF.

    IF radio1 NE 'X'.
      IF screen-group1 = '001'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF radio2 NE 'X'.
      IF screen-group1 = '002'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF radio3 NE 'X'.
      IF screen-group1 = '003'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF radio4 NE 'X'.
      IF screen-group1 = '004'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF radio5 NE 'X'.
      IF screen-group1 = '005'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF radio6 NE 'X'.
      IF screen-group1 = '006'.
        screen-active = '0'.
      ENDIF.
    ENDIF.
    IF screen-group1 = 'DWN'.
      AUTHORITY-CHECK OBJECT 'ZROFO'
                ID 'ACTVT' FIELD '61'.
      IF sy-subrc = 0.
        screen-active = '1'.
      ELSE.
        screen-active = '0'.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

INITIALIZATION.
  d_repid = sy-repid.

  CONCATENATE sy-datum(6) '01' INTO s_erdat-low.
  s_erdat-high = sy-datum.
  s_erdat-sign = 'I'.
  s_erdat-option = 'BT'.
  APPEND s_erdat.

  SELECT SINGLE parva
    FROM usr05
    INTO p_vkorg
    WHERE bname EQ sy-uname AND
          parid EQ 'VKO'.

  SELECT SINGLE parva
    FROM usr05
    INTO s_vkbur-low
    WHERE bname EQ sy-uname AND
          parid EQ 'VKB'.
  APPEND s_vkbur.

  IF p_vkorg EQ '8070'.
    SELECT SINGLE parva
      FROM usr05
      INTO s_auart-low
      WHERE bname EQ sy-uname AND
            parid EQ 'AAT'.
    s_auart-sign = 'I'.
    s_auart-option = 'CP'.
    APPEND s_auart.
  ELSE.
    s_auart-sign = 'I'.
    s_auart-option = 'CP'.
    s_auart-low = 'ZQ*'.
    APPEND s_auart.
  ENDIF.

  SELECT matnr
    FROM a603 AS a JOIN konp AS b ON a~knumh = b~knumh
    INTO TABLE gt_mara
    WHERE a~kappl EQ 'V'
      AND a~kschl = 'ZGEM'
      AND b~loevm_ko NE 'X'.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    TABLES
      return   = return
      groups   = groups.

  CLEAR gs_groups.
  LOOP AT groups INTO gs_groups.
    IF gs_groups-usergroup = 'TDS*'.
      EXIT.
    ENDIF.
    CLEAR gs_groups.
  ENDLOOP.

START-OF-SELECTION.

  IF r_matkl IS NOT INITIAL.
    REFRESH: s_matkl.
    s_matkl[] = r_matkl[].
  ELSE.
    MESSAGE a002(zz) WITH 'You are not authorized'.
    STOP.
  ENDIF.

  IF p_val = 'X'.
    va_text = 'By Value'.
  ELSE.
    va_text = 'By Quantity'.
  ENDIF.

*  IF p_vkorg EQ '8070'.
*    gv_kkber  = '8070'.
*  ELSE.
*    gv_kkber  = '8000'.
*  ENDIF.
  CASE p_vkorg.
    WHEN '8020'.
      gv_kkber  = '8000'.
    WHEN OTHERS.
      gv_kkber  = p_vkorg.
  ENDCASE.

  IF p_back IS NOT INITIAL OR p_back1 IS NOT INITIAL.
    CALL FUNCTION 'RS_VARIANT_CONTENTS'
      EXPORTING
        report               = 'ZS_SAC7_2_GET_DATA_NEW_V0'
        variant              = 'VAR1'
      TABLES
        valutab              = valuetab
      EXCEPTIONS
        variant_non_existent = 1
        variant_obsolete     = 2
        OTHERS               = 3.

    READ TABLE valuetab INTO ls_valuetab WITH KEY selname = 'PA_SPMON'.
    IF sy-subrc = 0.
      CONCATENATE ls_valuetab-low+3(4) ls_valuetab-low(2) INTO gv_spmon.
      IF gv_spmon = sy-datum(6).
        CLEAR : s_erdat[], gv_subrc.
        CONCATENATE gv_spmon '01' INTO s_erdat-low.
        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
          EXPORTING
            day_in            = s_erdat-low
          IMPORTING
            last_day_of_month = s_erdat-high
          EXCEPTIONS
            day_in_no_date    = 1
            OTHERS            = 2.
        s_erdat-sign    = 'I'.
        s_erdat-option  = 'BT'.
        APPEND s_erdat.

        CONCATENATE gv_path p_vkorg '_SO_' gv_spmon '.csv' INTO gv_path.

        OPEN DATASET gv_path FOR INPUT IN TEXT MODE ENCODING DEFAULT.

        gv_subrc  = sy-subrc.

        CLOSE DATASET gv_path.

        IF gv_subrc IS NOT INITIAL.
          PERFORM get_data.
        ENDIF.
      ELSE.
        CLEAR gv_subrc.
      ENDIF.
    ENDIF.
  ELSE.
    PERFORM get_data.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      IF p_stkout IS NOT INITIAL.
        PERFORM f_check_stock_outs.
      ENDIF.
  ENDCASE.

  PERFORM f_modify_data.

  CASE 'X'.
    WHEN radio1.
      PERFORM f_crt_dyn_int_table USING 'X'.
      PERFORM f_proses_data_radio1.
*      IF sy-slset(4) = 'DOWN'.
      IF p_down IS NOT INITIAL.
        PERFORM f_dyn_tab_download.
        PERFORM f_download.
        MESSAGE s000(zab) WITH 'Data already downloaded'.
      ELSE.
        PERFORM f_output_alv.
      ENDIF.

    WHEN radio2.
      PERFORM f_crt_dyn_int_table USING 'X'.
      PERFORM f_proses_data_radio2.
      PERFORM f_output_alv.

    WHEN radio3.
      PERFORM f_crt_dyn_int_table USING 'X'.
      PERFORM f_proses_data_radio3.
      PERFORM f_output_alv.

    WHEN radio4.
      PERFORM f_crt_dyn_int_table USING 'X'.
      PERFORM f_proses_data_radio4.
      PERFORM f_output_alv.

    WHEN radio5.
      PERFORM f_crt_dyn_int_table USING ''.
      IF p_summ5 IS INITIAL.
        PERFORM f_proses_data_radio5.
      ELSE.
        PERFORM f_proses_summdata_radio5.
      ENDIF.
      PERFORM f_output_alv.

    WHEN radio6.
      PERFORM f_crt_dyn_int_table USING ''.
      IF p_summ6 IS INITIAL.
        PERFORM f_proses_data_radio6.
      ELSE.
        PERFORM f_proses_summdata_radio6.
      ENDIF.
      PERFORM f_output_alv.

    WHEN radio7.
      PERFORM f_crt_dyn_int_table USING 'X'.
      PERFORM f_proses_data_radio7.
      PERFORM f_output_alv.

  ENDCASE.

  INCLUDE zs_slnka_v1f01.
