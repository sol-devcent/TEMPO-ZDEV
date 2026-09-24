*&---------------------------------------------------------------------*
*& Report ZKMM_F001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkmm_f001.

TABLES: caufv, resb, afpo.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_matnr FOR afpo-matnr OBLIGATORY.
PARAMETERS: p_werks TYPE resb-werks OBLIGATORY.
SELECT-OPTIONS s_datum FOR sy-datum OBLIGATORY.
*PARAMETERS: p_uname TYPE sy-uname.
SELECTION-SCREEN END OF BLOCK general.

INITIALIZATION.
* Text for selection screen variables
  %_s_matnr_%_app_%-text = 'Product'.
  %_p_werks_%_app_%-text = 'Plant'.
  %_s_datum_%_app_%-text = 'Requirement Date'.
*  %_p_uname_%_app_%-text = 'User Name'.

*  Default s_datum from current date to 1 week ahead
  s_datum-sign = 'I'.
  s_datum-option = 'BT'.
  s_datum-low = sy-datum.
  s_datum-high = sy-datum + 7.
  APPEND s_datum.

AT SELECTION-SCREEN OUTPUT.


START-OF-SELECTION.
  DATA(lo_object) = NEW zkmm_f001_class( ).
  DATA(lv_message) = lo_object->run( s_matnr = s_matnr[] p_werks = p_werks s_datum = s_datum[] lv_program = sy-cprog )."p_uname = p_uname lv_program = sy-cprog ).
  IF lv_message IS NOT INITIAL.
    MESSAGE lv_message TYPE 'E'.
  ENDIF.
