*&---------------------------------------------------------------------*
*& Report  ZWM_E005
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zwm_e005 NO STANDARD PAGE HEADING.

INCLUDE zwm_e005top.

INCLUDE zwm_e005cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_lgnum   TYPE ltak-lgnum MODIF ID plg OBLIGATORY.
SELECT-OPTIONS so_vbeln   FOR ltak-vbeln MODIF ID svb.
SELECT-OPTIONS so_tanum   FOR ltak-tanum MODIF ID sta.
SELECT-OPTIONS so_bdatu   FOR ltak-bdatu MODIF ID sbd
                                         DEFAULT sy-datum.
SELECT-OPTIONS so_tknum FOR vttp-tknum MODIF ID stk.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_block AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK data.
*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid    = sy-repid.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_selection-screen_output.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_selection-screen.
    WHEN space.
      PERFORM f_selection-screen.
  ENDCASE.

START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_create_dyn_int_table.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zwm_e005m01.

  INCLUDE zwm_e005f01.
