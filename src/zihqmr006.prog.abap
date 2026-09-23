*&---------------------------------------------------------------------*
*& Report ZIHQMR006
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zihqmr006 NO STANDARD PAGE HEADING
                            LINE-SIZE 255.
INCLUDE zabp_atz.
INCLUDE zabp_udf.
INCLUDE zabp_header.
INCLUDE zabp_frm.
INCLUDE zabp_alv_common.
INCLUDE zabp_bdc.
TABLES: sscrfields, mkpf, mseg.

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS:
  so_budat  FOR mkpf-budat OBLIGATORY,
  so_werks  FOR mseg-werks OBLIGATORY NO INTERVALS,
  so_matnr  FOR mseg-matnr NO INTERVALS,
  so_lifnr  FOR mseg-lifnr NO INTERVALS.
SELECTION-SCREEN END OF BLOCK data.

DATA: lo_object TYPE REF TO zihqmr006_class.

INITIALIZATION.

AT SELECTION-SCREEN OUTPUT.
  IF lo_object IS NOT BOUND.
    lo_object = NEW zihqmr006_class( ).
  ENDIF.

AT SELECTION-SCREEN.
  LOOP AT so_werks.
    AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
             ID 'ACTVT' FIELD '03'
             ID 'WERKS' FIELD so_werks-low.
    IF sy-subrc = 4.
      MESSAGE e000(zab) WITH 'No authorization for Plant' so_werks-low.
    ELSEIF sy-subrc <> 0.
      MESSAGE e000(zab) WITH 'Internal problem in authorization check'.
    ENDIF.
  ENDLOOP.

  DATA: va_error TYPE i.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      va_error = lo_object->validate_screen_1000( matnr = so_matnr[] lifnr = so_lifnr[] ).
    WHEN space.
      va_error = lo_object->validate_screen_1000( matnr = so_matnr[] lifnr = so_lifnr[] ).
  ENDCASE.

  IF va_error = 1.
    CLEAR sscrfields-ucomm.
  ENDIF.

START-OF-SELECTION.
    lo_object->run( so_budat = so_budat[] so_werks = so_werks[] so_matnr = so_matnr[] so_lifnr = so_lifnr[]
    lv_program = sy-cprog title_name = sy-title datum = sy-datum id = sy-sysid mandt = sy-mandt username = sy-uname uzeit = sy-uzeit ).
END-OF-SELECTION.
