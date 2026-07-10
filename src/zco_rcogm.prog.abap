*&---------------------------------------------------------------------*
*& Report  ZCO_RCOGM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zco_rcogm NO STANDARD PAGE HEADING.

INCLUDE zco_rcogmtop.

INCLUDE zco_rcogmcl1.

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_werks       TYPE caufv-werks MODIF ID pwe.
SELECT-OPTIONS so_matnr   FOR caufv-plnbez MODIF ID sma.
PARAMETERS pa_monat       TYPE bsid-monat MODIF ID pmo.
PARAMETERS pa_gjahr       TYPE bsid-gjahr MODIF ID pgj.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid    = sy-repid.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_selection_screen_output.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_selection_screen.
    WHEN space.
      PERFORM f_selection_screen.
  ENDCASE.

START-OF-SELECTION.
  PERFORM f_init_data.
  PERFORM f_create_dyn_int_table.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zco_rcogmm01.

  INCLUDE zco_rcogmf01.
