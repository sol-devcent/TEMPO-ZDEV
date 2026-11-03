*&---------------------------------------------------------------------*
*& Report ZFIDT010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfidt010.

TABLES: zfidt020.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE TEXT-001.
PARAMETERS: p_bukrs TYPE zfidt020-bukrs OBLIGATORY.
SELECT-OPTIONS: s_belnr FOR zfidt020-belnr,
                s_gjahr FOR zfidt020-gjahr NO INTERVALS NO-EXTENSION,
                s_budat FOR zfidt020-budat.
SELECTION-SCREEN END OF BLOCK general.

INITIALIZATION.
  %_p_bukrs_%_app_%-text = 'Company Code'.
  %_s_belnr_%_app_%-text = 'Document Number'.
  %_s_gjahr_%_app_%-text = 'Year'.
  %_s_budat_%_app_%-text = 'Posting Date'.

START-OF-SELECTION.
  DATA(lo_object) = NEW zfidt010_class( ).
  DATA: lv_message TYPE char255,
        lv_status  TYPE char1.
  lo_object->run( EXPORTING p_bukrs = p_bukrs s_belnr = s_belnr[] s_gjahr = s_gjahr[] s_budat = s_budat[] IMPORTING lv_message = lv_message lv_status = lv_status ).
  IF lv_message IS NOT INITIAL.
    IF lv_status = 'S'.
      MESSAGE lv_message TYPE 'S'.
    ELSE.
      MESSAGE lv_message TYPE 'E'.
    ENDIF.
  ELSE.
    MESSAGE 'Success' TYPE 'S'.
  ENDIF.
