*&---------------------------------------------------------------------*
*& Report  ZPP_R003
*&
*&---------------------------------------------------------------------*
*& Logbook Sanitasi Report
*&
*&---------------------------------------------------------------------*

REPORT  zpp_r003 NO STANDARD PAGE HEADING.

INCLUDE zpp_r003top.

INCLUDE zpp_r003cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS    : pa_werks LIKE ztspppdt009-werks  MODIF ID pwe
                                                 OBLIGATORY.
SELECT-OPTIONS: so_wboot  FOR ztspppdt009-wbooth MODIF ID swb,
                so_equnr  FOR ztspppdt009-equnr  MODIF ID seq,
                so_afind  FOR ztspppdt009-afind  MODIF ID sis
                                                 DEFAULT sy-datum,
                so_fgbat  FOR ztspppdt009-charg  MODIF ID cha,
                so_aufnr  FOR ztspppdt009-aufnr  MODIF ID auf.
SELECTION-SCREEN END OF BLOCK data.

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

  INCLUDE zpp_r003m01.

  INCLUDE zpp_r003f01.
