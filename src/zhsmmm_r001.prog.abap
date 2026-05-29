*&---------------------------------------------------------------------*
*& Report  ZTDS_RTMP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zhsmmm_r001 NO STANDARD PAGE HEADING.

INCLUDE zhsmmm_r001top.

INCLUDE zhsmmm_r001cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
"PARAMETERS pa_ekgrp     TYPE zgdmmt004z-ekgrp.
SELECT-OPTIONS so_ekgrp   FOR zgdmmt004z-ekgrp.
SELECT-OPTIONS so_matnr   FOR zgdmmt004z-matnr MODIF ID sma.
SELECT-OPTIONS so_werks   FOR zgdmmt004z-werks MODIF ID swe.
SELECT-OPTIONS so_zalno   FOR zgdmmt004z-zalno MODIF ID szn.
SELECT-OPTIONS so_zaldt   FOR zgdmmt004z-zaldt MODIF ID szd.
*PARAMETERS pa_fname       TYPE ibipparms-path MODIF ID pfn.
SELECTION-SCREEN END OF BLOCK data.

*SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
*PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
*PARAMETERS radio2 RADIOBUTTON GROUP grp1.
*SELECTION-SCREEN END OF BLOCK option.

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

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN ON VALUE-REQUEST FOR
*&---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_fname.
*  PERFORM f_f4_filename CHANGING pa_fname.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_create_dyn_int_table.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zhsmmm_r001m01.

  INCLUDE zhsmmm_r001f01.
