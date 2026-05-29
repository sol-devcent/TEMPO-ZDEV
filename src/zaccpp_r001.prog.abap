*&---------------------------------------------------------------------*
*& Report  ZACCPP_R001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zaccpp_r001 NO STANDARD PAGE HEADING.

INCLUDE zaccpp_r001top.

INCLUDE zaccpp_r001cl1.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-001.
SELECT-OPTIONS so_aufnr     FOR afpo-aufnr MODIF ID sau.
SELECT-OPTIONS so_matnr     FOR afpo-matnr MODIF ID sma.
SELECT-OPTIONS so_charg     FOR afpo-charg MODIF ID sch.
SELECTION-SCREEN END OF BLOCK general.

INITIALIZATION.
  gv_repid  = sy-repid.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_selection.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN space.
      PERFORM f_validate_screen.
    WHEN 'ONLI'.
      PERFORM f_validate_screen.
  ENDCASE.

START-OF-SELECTION.
  PERFORM f_init_data.
  PERFORM f_crt_dyn_int_table USING 'T'.
*  PERFORM f_crt_dyn_int_table USING 'B'.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zaccpp_r001f01.
