*&---------------------------------------------------------------------*
*& Report  ZHSMMM_E001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zhsmmm_e001 NO STANDARD PAGE HEADING.

INCLUDE zhsmmm_e001top.

INCLUDE zhsmmm_e001cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_ekgrp       TYPE eban-ekgrp MODIF ID pek.
PARAMETERS pa_prgrp       TYPE pgmi-prgrp MODIF ID ppr.
PARAMETERS pa_matnr       TYPE mara-matnr MODIF ID pma.
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
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_prgrp.
*  PERFORM f_f4_filename CHANGING pa_fname.
  DATA : return_values  LIKE ddshretval OCCURS 0 WITH HEADER LINE,
         shlp           TYPE shlpname,
         shlpparam      TYPE shlpfield.

*  CASE 'X'.
*    WHEN radio1.
  shlp      = 'MAT2'.
  shlpparam = 'PRGRP'.
*    WHEN radio2.
*      shlp      = 'MAT1'.
*      shlpparam = 'MATNR'.
*  ENDCASE.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname           = '' "Mandatory
      fieldname         = '' "Mandatory
      searchhelp        = shlp
      shlpparam         = shlpparam
      dynpprog          = sy-cprog
      dynpnr            = sy-dynnr
      dynprofield       = 'PA_PRGRP'
*      display           = ''
    TABLES
      return_tab        = return_values
    EXCEPTIONS
      field_not_found   = 1
      no_help_for_field = 2
      inconsistent_help = 3
      no_values_found   = 4
      OTHERS            = 5.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  IF pa_ekgrp IS NOT INITIAL AND
    pa_prgrp IS NOT INITIAL.
    IF pa_matnr IS INITIAL.
      PERFORM f_lock_document USING ''.
    ELSE.
      PERFORM f_lock_document USING pa_matnr.
    ENDIF.
  ENDIF.

  IF gv_subrc IS INITIAL.
    PERFORM f_init_data.
    PERFORM f_create_dyn_int_table.
    PERFORM f_get_data.
    PERFORM f_process_data.
    PERFORM f_print_data.
  ENDIF.

  INCLUDE zhsmmm_e001m01.

  INCLUDE zhsmmm_e001f01.
