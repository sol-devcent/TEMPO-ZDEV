*&---------------------------------------------------------------------*
*& Report  ZFI_R003
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_r003 NO STANDARD PAGE HEADING.

INCLUDE zfi_r003top.

INCLUDE zfi_r003cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_vkorg     TYPE vbak-vkorg MODIF ID pvo.
SELECT-OPTIONS so_vkbur FOR vbak-vkbur MODIF ID svu.
SELECT-OPTIONS so_kdgrp FOR knvv-kdgrp MODIF ID skd.
*SELECT-OPTIONS so_kunnr FOR vbak-kunnr MODIF ID sku.
SELECT-OPTIONS so_knkli FOR vbak-knkli MODIF ID skn.
SELECT-OPTIONS so_rtvnr FOR vbak-bstnk MODIF ID srn.
SELECT-OPTIONS so_rtvdt FOR vbak-bstdk MODIF ID srd.
SELECT-OPTIONS so_vbeva FOR vbak-vbeln MODIF ID sva.
SELECT-OPTIONS so_erdva FOR vbak-erdat MODIF ID ser.
SELECT-OPTIONS so_vbevl FOR likp-vbeln MODIF ID svl.
SELECT-OPTIONS so_erdvl FOR likp-erdat MODIF ID sel.
SELECT-OPTIONS so_kodat FOR likp-kodat MODIF ID sko NO-DISPLAY.
SELECT-OPTIONS so_vbevf FOR vbrk-vbeln MODIF ID svf.
SELECT-OPTIONS so_fkdat FOR vbrk-fkdat MODIF ID sfk.
SELECT-OPTIONS so_nonr FOR zfppnnrh-nonr MODIF ID sno NO-DISPLAY.
SELECT-OPTIONS so_nrdt FOR zfppnnrh-nrdt MODIF ID snd NO-DISPLAY.
SELECT-OPTIONS so_budat FOR bsid-budat MODIF ID sbu.
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
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_create_dyn_int_table.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zfi_r003m01.

  INCLUDE zfi_r003f01.
