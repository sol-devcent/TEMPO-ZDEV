*&---------------------------------------------------------------------*
*& Report  ZSPICKUP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zcoretax_e001 NO STANDARD PAGE HEADING LINE-SIZE  350..


INCLUDE zcoretax_e001_top.
*INCLUDE zghfi_e001_top.
* common report header and other functions
INCLUDE zabp_header.

* ALV common functions
INCLUDE zabp_alv_common.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE title.
PARAMETERS: p_bukrs TYPE vbrk-bukrs OBLIGATORY.
PARAMETERS: p_perio TYPE abper_rf OBLIGATORY DEFAULT sy-datum(6).


SELECT-OPTIONS s_vkbur FOR vbrp-vkbur MODIF ID ptt. " OBLIGATORY.
SELECT-OPTIONS: s_kunrg FOR vbrk-kunrg.
SELECT-OPTIONS s_vbeln FOR vbrk-vbeln MODIF ID ptt. " DEFAULT '1053551843'.
SELECT-OPTIONS s_bbill FOR zdg2fidt0008-bbill MODIF ID er. " DEFAULT '1053551843'.
SELECT-OPTIONS s_belnr FOR bkpf-belnr MODIF ID fi NO INTERVALS. " DEFAULT '1053551843'.
SELECT-OPTIONS s_budat FOR bkpf-budat MODIF ID fi NO-EXTENSION . " DEFAULT '1053551843'.
SELECT-OPTIONS s_fkdat FOR vbrk-fkdat MODIF ID fx NO-EXTENSION . " NO-DISPLAY.
SELECT-OPTIONS s_txdat FOR zmm_cust_rec-txdat MODIF ID tx NO-EXTENSION .. " NO-DISPLAY.
SELECT-OPTIONS s_vgbel FOR vbrp-vgbel MODIF ID dlv.

SELECT-OPTIONS s_kdctr FOR zdg2fidt0008-zzkdctr MODIF ID er NO INTERVALS.. " DEFAULT '1053551843'.
SELECT-OPTIONS s_tknum FOR vttk-tknum MODIF ID btm NO INTERVALS. " DEFAULT '1053551843'.
SELECT-OPTIONS s_erdat FOR vttk-erdat MODIF ID btm NO-EXTENSION . " NO-DISPLAY.

SELECT-OPTIONS r_hkont FOR bseg-hkont NO-DISPLAY.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.

PARAMETERS : p_path(52) LOWER CASE MODIF ID abc DEFAULT '/outbound/coretax/' NO-DISPLAY.
PARAMETERS : p_prefix(20) LOWER CASE  DEFAULT '*' MODIF ID abc NO-DISPLAY.
PARAMETERS : p_name TYPE edi_path-pthnam DEFAULT 'coretax001.xml' NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK data.
PARAMETERS p_check AS CHECKBOX DEFAULT 'X'.
PARAMETERS p_file AS CHECKBOX MODIF ID abc DEFAULT 'X' .
PARAMETERS p_val AS CHECKBOX MODIF ID abd DEFAULT 'X' .
SELECTION-SCREEN END OF BLOCK block1.
SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.

PARAMETERS p_rad1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(35) TEXT-011 FOR FIELD p_rad1.
SELECTION-SCREEN : END OF LINE.
PARAMETERS p_rad2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_rad3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(30) TEXT-031 FOR FIELD p_rad3 .
SELECTION-SCREEN POSITION 35.
PARAMETERS : p_jasa AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN COMMENT 40(30) TEXT-032 FOR FIELD p_jasa.

SELECTION-SCREEN : END OF LINE.

PARAMETERS p_rad4 RADIOBUTTON GROUP grp1.
PARAMETERS p_rad5 RADIOBUTTON GROUP grp1.


SELECTION-SCREEN END OF BLOCK option.
************************************************************************
* AT SELECTION-SCREEN
************************************************************************

AT SELECTION-SCREEN ON p_bukrs.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
      ID 'BUKRS' FIELD p_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH 'You are not authorized with company code '
     p_bukrs.
  ENDIF.


*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  CASE 'X'.
    WHEN p_rad1 OR p_rad5.
      CLEAR: s_txdat[], s_fkdat[].
      CONCATENATE  p_perio '01' INTO s_txdat-low.
      s_txdat-high = s_txdat-low + 31.
      CONCATENATE  s_txdat-high(6) '01'  INTO s_txdat-high.
      s_txdat-high = s_txdat-high - 1.
      s_txdat-sign = 'I'.
      s_txdat-option = 'BT'.
      APPEND s_txdat.
      s_fkdat-low = s_txdat-low.
      s_fkdat-high = s_txdat-high.
      s_fkdat-sign = 'I'.
      s_fkdat-option = 'BT'.
      APPEND s_fkdat.

    WHEN p_rad3.
      CLEAR: s_budat[].
      CONCATENATE  p_perio '01' INTO s_budat-low.
      s_budat-high = s_budat-low + 31.
      CONCATENATE  s_budat-high(6) '01'  INTO s_budat-high.
      s_budat-high = s_budat-high - 1.
      s_budat-sign = 'I'.
      s_budat-option = 'BT'.
      APPEND s_budat.


    WHEN p_rad4.
      CLEAR: s_erdat[].
      CONCATENATE  p_perio '01' INTO s_erdat-low.
      s_erdat-high = s_erdat-low + 31.
      CONCATENATE  s_erdat-high(6) '01'  INTO s_erdat-high.
      s_erdat-high = s_erdat-high - 1.
      s_erdat-sign = 'I'.
      s_erdat-option = 'BT'.
      APPEND s_erdat.
    WHEN p_rad2.
      CLEAR: s_fkdat[].
      CONCATENATE  p_perio '01' INTO s_fkdat-low.
      s_fkdat-high = s_fkdat-low + 31.
      CONCATENATE  s_fkdat-high(6) '01'  INTO s_fkdat-high.
      s_fkdat-high = s_fkdat-high - 1.
      s_fkdat-sign = 'I'.
      s_fkdat-option = 'BT'.
      APPEND s_fkdat.
  ENDCASE.


  PERFORM f_modify_screen_1000.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'ABC'.
        screen-invisible = '0'.
        screen-input     = '0'.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.


INITIALIZATION.
  CLEAR: r_hkont, r_hkont[].
  r_hkont-low = '065*'.
  r_hkont-sign = 'I'.
  r_hkont-option = 'CP'.
  APPEND r_hkont.

  CONCATENATE  p_perio '01' INTO s_fkdat-low.
  s_fkdat-high = s_fkdat-low + 31.
  CONCATENATE  s_fkdat-high(6) '01'  INTO s_fkdat-high.
  s_fkdat-high = s_fkdat-high - 1.
  s_fkdat-sign = 'I'.
  s_fkdat-option = 'BT'.
  APPEND s_fkdat.

  CONCATENATE  p_perio '01' INTO s_txdat-low.
  s_txdat-high = s_txdat-low + 31.
  CONCATENATE  s_txdat-high(6) '01'  INTO s_txdat-high.
  s_txdat-high = s_txdat-high - 1.
  s_txdat-sign = 'I'.
  s_txdat-option = 'BT'.
  APPEND s_txdat.

  CONCATENATE  p_perio '01' INTO s_erdat-low.
  s_erdat-high = s_erdat-low + 31.
  CONCATENATE  s_erdat-high(6) '01'  INTO s_erdat-high.
  s_erdat-high = s_erdat-high - 1.
  s_erdat-sign = 'I'.
  s_erdat-option = 'BT'.
  APPEND s_erdat.

  CONCATENATE  p_perio '01' INTO s_budat-low.
  s_budat-high = s_budat-low + 31.
  CONCATENATE  s_budat-high(6) '01'  INTO s_budat-high.
  s_budat-high = s_budat-high - 1.
  s_budat-sign = 'I'.
  s_budat-option = 'BT'.
  APPEND s_budat.

  PERFORM init_data.

START-OF-SELECTION.
  IF p_rad2 = 'X'.
    IF p_bukrs NE '8220' AND p_bukrs NE '8210'.
      MESSAGE e000(zb) WITH 'Khusus company code 8220 dan 8210'.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
  IF p_rad4 = 'X'.
    IF p_bukrs NE '8220' AND p_bukrs NE '8020'.
      MESSAGE e000(zb) WITH 'Khusus company code 8220 dan 8020'.
      LEAVE TO SCREEN 0.
      EXIT.
    ENDIF.
  ENDIF.
  IF p_rad5 = 'X'.
    IF p_bukrs NE '8800'.
      MESSAGE e000(zb) WITH 'Khusus company code 8800'.
      LEAVE TO SCREEN 0.
      EXIT.
    ENDIF.
  ENDIF.

  CASE 'X'.
    WHEN p_rad1 OR p_rad5.
      IF s_txdat-low(6) IS NOT INITIAL.
        IF s_txdat-low(6) NE p_perio.
          MESSAGE e000(zb) WITH 'Mohon Periode Pajak disesuaikan'.
          LEAVE TO SCREEN 0.
          EXIT.
        ENDIF.
      ENDIF.
      IF s_txdat-high(6) IS NOT INITIAL.
        IF s_txdat-high(6) NE p_perio.
          MESSAGE e000(zb) WITH 'Mohon Periode Pajak disesuaikan'.
          LEAVE TO SCREEN 0.
          EXIT.
        ENDIF.
      ENDIF.
      IF s_fkdat-low(6) IS NOT INITIAL.
        IF s_fkdat-low(6) NE p_perio.
          MESSAGE e000(zb) WITH 'Mohon Periode Pajak disesuaikan'.
          LEAVE TO SCREEN 0.
          EXIT.
        ENDIF.
      ENDIF.
      IF s_fkdat-high(6) IS NOT INITIAL.
        IF s_fkdat-high(6) NE p_perio.
          MESSAGE e000(zb) WITH 'Mohon Periode Pajak disesuaikan'.
          LEAVE TO SCREEN 0.
          EXIT.
        ENDIF.
      ENDIF.
    WHEN p_rad3.
      IF s_budat-low(6) IS NOT INITIAL.
        IF s_budat-low(6) NE p_perio.
          MESSAGE e000(zb) WITH 'Mohon Periode Pajak disesuaikan'.
          LEAVE TO SCREEN 0.
          EXIT.
        ENDIF.
      ENDIF.
      IF s_budat-high(6) IS NOT INITIAL.
        IF s_budat-high(6) NE p_perio.
          MESSAGE e000(zb) WITH 'Mohon Periode Pajak disesuaikan'.
          LEAVE TO SCREEN 0.
          EXIT.
        ENDIF.
      ENDIF.

    WHEN p_rad4.
      IF s_erdat-low(6) IS NOT INITIAL.
        IF s_erdat-low(6) NE p_perio.
          MESSAGE e000(zb) WITH 'Mohon Periode Pajak disesuaikan'.
          LEAVE TO SCREEN 0.
          EXIT.
        ENDIF.
      ENDIF.
      IF s_erdat-high(6) IS NOT INITIAL.
        IF s_erdat-high(6) NE p_perio.
          MESSAGE e000(zb) WITH 'Mohon Periode Pajak disesuaikan'.
          LEAVE TO SCREEN 0.
          EXIT.
        ENDIF.
      ENDIF.
    WHEN p_rad2.
      IF s_fkdat-low(6) IS NOT INITIAL.
        IF s_fkdat-low(6) NE p_perio.
          MESSAGE e000(zb) WITH 'Mohon Periode Pajak disesuaikan'.
          LEAVE TO SCREEN 0.
          EXIT.
        ENDIF.
      ENDIF.
  ENDCASE.
  CLEAR: gv_error.
  PERFORM f_prepare_table_itab.
  PERFORM f_get_data.
  CASE 'X'.
    WHEN p_rad1 OR p_rad5.
      PERFORM f_prepare_data_itab.
    WHEN p_rad2.
      PERFORM f_prepare_data_8220.
    WHEN p_rad3.
      PERFORM f_prepare_data_fi.
    WHEN p_rad4.
      PERFORM f_prepare_data_shipment.
  ENDCASE.
  SORT gt_header_xml BY bukrs vbeln.
  DELETE ADJACENT DUPLICATES FROM gt_header_xml COMPARING bukrs vbeln.
  PERFORM f_print_data.

  INCLUDE zcoretax_e001_f01.
*INCLUDE zghfi_e001_f01.
