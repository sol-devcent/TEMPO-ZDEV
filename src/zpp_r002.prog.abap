*&---------------------------------------------------------------------*
*& Report  ZPP_R002
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zpp_r002 NO STANDARD PAGE HEADING.

INCLUDE zpp_r002top.

INCLUDE zpp_r002cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_werks   TYPE resb-werks MODIF ID pwe
                                      OBLIGATORY.
SELECT-OPTIONS so_wboot   FOR zppresb_add-wbooth MODIF ID swb.
SELECT-OPTIONS so_equnr   FOR zppresb_add-equnr MODIF ID seq.
SELECT-OPTIONS so_istad   FOR zppresb_add-istad MODIF ID sis
                                                DEFAULT sy-datum.
SELECT-OPTIONS so_matnr   FOR zppresb_add-matnr MODIF ID sma.
SELECT-OPTIONS so_aufnr   FOR zppresb_add-aufnr MODIF ID auf.
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

  INCLUDE zpp_r002m01.

  INCLUDE zpp_r002f01.
