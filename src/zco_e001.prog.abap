*&---------------------------------------------------------------------*
*& Report  ZCO_E001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zco_e001 NO STANDARD PAGE HEADING.

INCLUDE zco_e001top.

INCLUDE zco_e001cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_bukrs   TYPE coep-bukrs OBLIGATORY.
PARAMETERS pa_gsber   TYPE coep-gsber OBLIGATORY.
PARAMETERS pa_perio   TYPE coep-perio DEFAULT sy-datum+4(2)
                                      OBLIGATORY.
PARAMETERS pa_gjahr   TYPE coep-gjahr DEFAULT sy-datum(4)
                                      OBLIGATORY.
PARAMETERS pa_khinr   TYPE csks-khinr OBLIGATORY.
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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_khinr.
  PERFORM f_value_kostl_group USING 'PA_KHINR'.

START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_create_dyn_int_table.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zco_e001m01.

  INCLUDE zco_e001f01.
