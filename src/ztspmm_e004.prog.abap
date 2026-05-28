*&---------------------------------------------------------------------*
*& Report  ZTSPMM_E004
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztspmm_e004 NO STANDARD PAGE HEADING.

INCLUDE ztspmm_e004top.

INCLUDE ztspmm_e004cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_werks     TYPE ztspmmdt006-werks MODIF ID pwe.
SELECT-OPTIONS so_ivnum   FOR ztspmmdt006-ivnum MODIF ID siv.
SELECT-OPTIONS so_matnr   FOR ztspmmdt006-matnr MODIF ID mat.
SELECT-OPTIONS so_lgort   FOR ztspmmdt006-lgort MODIF ID lgo.
SELECT-OPTIONS so_qdatu   FOR ztspmmdt006-qdatu MODIF ID sqd
                                                DEFAULT sy-datum.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_all   AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF SCREEN 200.
SELECTION-SCREEN BEGIN OF BLOCK 200 WITH FRAME.
PARAMETERS pa_budat   TYPE mkpf-budat DEFAULT sy-datum.
PARAMETERS pa_bldat   TYPE mkpf-bldat DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK 200.
SELECTION-SCREEN END OF SCREEN 200.

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

  IF pa_werks = '0101' OR pa_werks = '0102'.
    PERFORM f_get_domain_values.
    PERFORM f_create_dyn_int_table_tsp.
  ELSE.
    PERFORM f_create_dyn_int_table.
  ENDIF.

  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE ztspmm_e004m01.

  INCLUDE ztspmm_e004f01.
