*&---------------------------------------------------------------------*
*& Report  ZHSMMM_E008
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zhsmmm_e008 NO STANDARD PAGE HEADING.

INCLUDE zabp_bdc.

INCLUDE zhsmmm_e008top.

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_fname       TYPE ibipparms-path MODIF ID pfn OBLIGATORY.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_mode        TYPE char1 DEFAULT 'N' NO-DISPLAY. " OBLIGATORY .
SELECTION-SCREEN END OF BLOCK data.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_fname.
  PERFORM f_f4_filename CHANGING pa_fname.

AT SELECTION-SCREEN ON pa_mode.
  IF pa_mode IS INITIAL.
    MESSAGE e002(zz) WITH 'Batch proses harus diisi dengan A, E dan N'.
  ELSEIF pa_mode NE 'A' AND pa_mode NE 'E' AND pa_mode NE 'N'  .
    MESSAGE e002(zz) WITH 'Batch proses harus diisi dengan A, E dan N'.
  ENDIF.

START-OF-SELECTION.

  PERFORM f_get_data.
  PERFORM f_process_data.

  INCLUDE zhsmmm_e008f01.
