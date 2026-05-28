*&---------------------------------------------------------------------*
*& Report  ZHSMMM_E007
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zhsmmm_e007 NO STANDARD PAGE HEADING.

INCLUDE zhsmmm_e007top.

INCLUDE zhsmmm_e007cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_ekgrp LIKE t024-ekgrp MODIF ID pek.
PARAMETERS pa_frgco LIKE t16fc-frgco OBLIGATORY.
SELECT-OPTIONS so_zalno   FOR zgdmmt004z-zalno.
SELECT-OPTIONS so_zaldt   FOR zgdmmt004z-zaldt.
SELECT-OPTIONS so_submi   FOR zgdmmt004z-submi.
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

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN ON VALUE-REQUEST FOR
*&---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_fname.
*  PERFORM f_f4_filename CHANGING pa_fname.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_frgco.
  PERFORM f_f4_frgco CHANGING pa_frgco.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  IF gv_subrc = 0.
    PERFORM f_create_dyn_int_table.
    PERFORM f_get_data.
    PERFORM f_process_data.
    PERFORM f_print_data.
  ELSE.
    MESSAGE s000(zab) WITH 'Release Code error'.
  ENDIF.

  INCLUDE zhsmmm_e007m01.

  INCLUDE zhsmmm_e007f01.
