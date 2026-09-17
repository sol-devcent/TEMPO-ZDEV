*&---------------------------------------------------------------------*
*& Report  ZRVTPSC00                                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*&   Versendung einer Lieferung an eine Spediteur zwecks Frachtplanung *
*&---------------------------------------------------------------------*

REPORT  zhsmpp_i001 MESSAGE-ID v6.

* common report header and other functions
INCLUDE zabp_header.

* ALV common functions
INCLUDE zabp_alv_common.

"INCLUDE i56idova.
INCLUDE zhsmpp_i001top.

SELECT-OPTIONS s_plant    FOR pgmi-werks.
SELECT-OPTIONS s_prgrp    FOR pgmi-prgrp OBLIGATORY..
SELECT-OPTIONS s_matnr    FOR plaf-matnr.
SELECT-OPTIONS s_psttr    FOR plaf-psttr OBLIGATORY.
SELECT-OPTIONS s_paart    FOR plaf-paart.
PARAMETERS p_back AS CHECKBOX DEFAULT 'X'.
"PARAMETERS p_bulan(1) DEFAULT '2'.

INITIALIZATION.
  DATA: ld_datum LIKE sy-datum, ld_datum1 LIKE sy-datum, ld_tahun(2).
  ld_datum = sy-datum.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = sy-datum
    IMPORTING
      last_day_of_month = ld_datum
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  ld_datum = ld_datum + 1.
  CALL FUNCTION 'RE_ADD_MONTH_TO_DATE'
    EXPORTING
      months  = 1
      olddate = ld_datum
    IMPORTING
      newdate = ld_datum.

  CALL FUNCTION 'RE_ADD_MONTH_TO_DATE'
    EXPORTING
      months  = 18
      olddate = ld_datum
    IMPORTING
      newdate = ld_datum1.

  s_psttr-low = ld_datum.
  s_psttr-high = ld_datum1.
  s_psttr-sign = 'I'.
  s_psttr-option = 'BT'.
  APPEND s_psttr.
  ld_tahun = sy-datum+2(2).

  CONCATENATE 'P' ld_tahun '*' INTO s_prgrp-low.
  s_prgrp-sign = 'I'.
  s_prgrp-option = 'CP'.
  APPEND  s_prgrp.
  IF sy-tcode = 'ZPPR022'.
    CLEAR: p_back.
    LOOP AT SCREEN.
      IF screen-name = 'P_BACK'.
        screen-invisible = '1'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

START-OF-SELECTION.
   IF sy-batch = 'X'.
    WRITE: / 'Background Proses'.
    p_back = 'X'.
  ENDIF.
  PERFORM f_get_data.
  PERFORM f_print_data.

  INCLUDE zhsmpp_i001f01.
*INCLUDE ZHSMMM_I001F01.
