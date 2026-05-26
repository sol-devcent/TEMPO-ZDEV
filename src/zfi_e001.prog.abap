*&---------------------------------------------------------------------*
*& Report  ZFI_E001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_e001 NO STANDARD PAGE HEADING.

INCLUDE zabp_bdc.

INCLUDE zfi_e001top.

INCLUDE zfi_e001cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_bukrs       TYPE bkpf-bukrs MODIF ID pbu
                                          OBLIGATORY
                                          DEFAULT '8020'.
SELECT-OPTIONS so_vkbur   FOR s626-vkbur MODIF ID svk.
PARAMETERS pa_prodh       TYPE s626-prodh1 MODIF ID spr
                                           OBLIGATORY
                                           DEFAULT 'UNI'.
SELECT-OPTIONS so_sptag   FOR s626-sptag MODIF ID ssp
                                         NO-EXTENSION
                                         DEFAULT sy-datum.
SELECT-OPTIONS so_xblnr   FOR bkpf-xblnr MODIF ID sxb.
SELECTION-SCREEN SKIP 1.
PARAMETER pa_vat  AS CHECKBOX DEFAULT 'X' MODIF ID pva.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
PARAMETERS radio4 RADIOBUTTON GROUP grp1.
PARAMETERS radio5 RADIOBUTTON GROUP grp1.
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

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_create_dyn_int_table.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zfi_e001m01.

  INCLUDE zfi_e001f01.
