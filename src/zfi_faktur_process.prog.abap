*&---------------------------------------------------------------------*
*& Report  ZFI_FAKTUR_PROCESS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_faktur_process NO STANDARD PAGE HEADING.

INCLUDE zfi_faktur_processtop.

INCLUDE zfi_faktur_processcl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_bukrs   TYPE t001-bukrs MODIF ID pbu.
PARAMETERS pa_filnm   TYPE ibipparms-path MODIF ID pfi.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_prev    AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad
                                         DEFAULT 'X'
                                         MODIF ID rad.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio2 RADIOBUTTON GROUP grp1 MODIF ID rad.
SELECTION-SCREEN COMMENT 3(17) TEXT-003 FOR FIELD radio2.
SELECTION-SCREEN COMMENT 40(15) TEXT-004.
PARAMETERS pa_separ DEFAULT ';' .
SELECTION-SCREEN END OF LINE.

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

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN ON VALUE-REQUEST FOR.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_filnm.
  PERFORM f_get_f4 CHANGING pa_filnm.

START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_create_dyn_int_table.
  PERFORM f_upload_data.
  IF gv_subrc = 0.
    PERFORM f_process_data.
    IF pa_prev IS INITIAL.
      PERFORM f_posting_data.
    ELSE.
      PERFORM f_print_data.
    ENDIF.
  ELSE.
    MESSAGE s000(zab) WITH 'This file is not for Company code' pa_bukrs
    DISPLAY LIKE 'E'.
  ENDIF.

  INCLUDE zfi_faktur_processm01.

  INCLUDE zfi_faktur_processf01.
