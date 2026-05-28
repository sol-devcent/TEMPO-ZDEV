*&---------------------------------------------------------------------*
*& Report  ZMM_E002
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zmm_e002 NO STANDARD PAGE HEADING.

INCLUDE zmm_e002top.

INCLUDE zmm_e002cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_fhead       TYPE ibipparms-path MODIF ID p01.
PARAMETERS pa_fitem       TYPE ibipparms-path MODIF ID p02.
PARAMETERS pa_fglac       TYPE ibipparms-path MODIF ID p03.
PARAMETERS pa_fmatn       TYPE ibipparms-path MODIF ID p04.
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
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_fhead.
  PERFORM f_f4_filename CHANGING pa_fhead.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_fglac.
  PERFORM f_f4_filename CHANGING pa_fglac.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_fmatn.
  PERFORM f_f4_filename CHANGING pa_fmatn.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_create_dyn_int_table.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zmm_e002m01.

  INCLUDE zmm_e002f01.
