*&---------------------------------------------------------------------*
*& Report  ZTIMDESFI_E002
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztimdesfi_e002 NO STANDARD PAGE HEADING.

INCLUDE ztimdesfi_e002top.

INCLUDE ztimdesfi_e002cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_bukrs   TYPE bkpf-bukrs MODIF ID pbu.
PARAMETERS pa_vkbur   TYPE vbak-vkbur MODIF ID pvk.
SELECT-OPTIONS so_kunnr   FOR bsid-kunnr MODIF ID sku.
SELECT-OPTIONS so_vbevl   FOR bsid-zuonr MODIF ID svl.
SELECT-OPTIONS so_zfbdt   FOR bsid-zfbdt MODIF ID szf DEFAULT sy-datum.
SELECT-OPTIONS so_webno   FOR zfidt011-webno MODIF ID swe.
SELECT-OPTIONS so_budat   FOR zfidt011-budat MODIF ID sbd DEFAULT sy-datum.

PARAMETERS pa_stgrd   TYPE uf05a-stgrd MODIF ID pst.
PARAMETERS pa_webno   TYPE zfidt011-webno MODIF ID pwe.
PARAMETERS pa_gjahr   TYPE zfidt011-gjahr MODIF ID pwe.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio3 RADIOBUTTON GROUP grp1 MODIF ID ra3.
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

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  CASE 'X'.
    WHEN radio3.
      PERFORM f_get_data.
      PERFORM f_process_data.
      PERFORM f_print_reverse.

    WHEN OTHERS.
      PERFORM f_create_dyn_int_table.
      PERFORM f_get_data.
      PERFORM f_process_data.
      PERFORM f_print_data.
  ENDCASE.

  INCLUDE ztimdesfi_e002m01.

  INCLUDE ztimdesfi_e002f01.
