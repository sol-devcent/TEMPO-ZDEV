REPORT zihqmr003
               NO STANDARD PAGE HEADING
               LINE-SIZE 255.

INCLUDE zabp_atz.
INCLUDE zabp_udf.
INCLUDE zabp_header.
INCLUDE zabp_frm.
INCLUDE zabp_alv_common.
INCLUDE zabp_bdc.

TABLES: sscrfields, mara, koth700.

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS: p_werks LIKE koth700-werks MODIF ID pwe,
            p_mtart LIKE koth700-mtart MODIF ID pmt DEFAULT 'ZRM'.
SELECT-OPTIONS: s_matnr FOR mara-matnr MODIF ID sma.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS rad01 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(24) TEXT-002 FOR FIELD rad01.
SELECT-OPTIONS: s_date FOR koth700-datab NO-EXTENSION MODIF ID sd0.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS rad02 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(24) TEXT-003 FOR FIELD rad02.
SELECT-OPTIONS: s_date1 FOR koth700-datab NO-EXTENSION MODIF ID sd1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK data.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_vari  LIKE disvariant-variant. " ALV Variant

DATA: lo_object TYPE REF TO zihqmr003_class.

INITIALIZATION.

AT SELECTION-SCREEN OUTPUT.
  IF lo_object IS NOT BOUND.
    lo_object = NEW zihqmr003_class( ).
    lo_object->modify_screen_1000( EXPORTING rad01 = rad01 rad02 = rad02 CHANGING date = s_date[] date1 = s_date1[] ).
  ENDIF.

AT SELECTION-SCREEN ON p_werks.
  lo_object->werks_selection_screen( werks = p_werks  ).

*-Authorization
  macro_atz_single_werks p_werks c_atz_display.


*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      lo_object->validate_screen_1000( werks = p_werks mtart = p_mtart matnr = s_matnr[] date = s_date[] date1 = s_date1[] rad01 = rad01 rad02 = rad02 ).
    WHEN space.
      lo_object->validate_screen_1000( werks = p_werks mtart = p_mtart matnr = s_matnr[] date = s_date[] date1 = s_date1[] rad01 = rad01 rad02 = rad02 ).
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  lo_object->f4_for_variant_alv( CHANGING lv_variant = p_vari ).

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  lo_object->run(  p_werks = p_werks p_mtart = p_mtart s_matnr = s_matnr[]
  s_date = s_date[] s_date1 = s_date1[] p_rad01 = rad01 p_rad02 = rad02 p_vari = p_vari
  lv_program = sy-cprog title_name = sy-title datum = sy-datum id = sy-sysid mandt = sy-mandt username = sy-uname uzeit = sy-uzeit ).
END-OF-SELECTION.
