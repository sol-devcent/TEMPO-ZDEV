*&---------------------------------------------------------------------*
*& Report  ZCORETAX_E004
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zcoretax_e004 NO STANDARD PAGE HEADING.

INCLUDE zcoretax_e004top.

INCLUDE zcoretax_e004cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_bukrs TYPE vbrk-bukrs MODIF ID pbu.
SELECT-OPTIONS so_vkbur FOR vbrp-vkbur MODIF ID svk.
SELECT-OPTIONS so_kunrg FOR vbrk-kunrg MODIF ID sku.
SELECT-OPTIONS so_kdctr FOR zdg2fidt0008-zzkdctr MODIF ID skd.
SELECT-OPTIONS so_vbevf FOR vbrk-vbeln MODIF ID svf.
SELECT-OPTIONS so_fkdat FOR vbrk-fkdat MODIF ID sfk.
SELECT-OPTIONS so_vbevl FOR likp-vbeln MODIF ID svl.
SELECT-OPTIONS so_txdat FOR zmm_cust_rec-txdat MODIF ID stx.
SELECT-OPTIONS so_tknum FOR vttk-tknum MODIF ID stk.
SELECT-OPTIONS so_erdat FOR vttk-erdat MODIF ID ser.
SELECTION-SCREEN SKIP 1.
PARAMETERS p_check AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(36) TEXT-003 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(32) TEXT-004 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK option.

SELECTION-SCREEN BEGIN OF BLOCK variant WITH FRAME TITLE TEXT-005.
PARAMETERS pa_vari  TYPE slis_vari.
SELECTION-SCREEN END OF BLOCK variant.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid    = sy-repid.

  CONCATENATE sy-datum(6) '01' INTO so_fkdat-low.
  PERFORM f_last_day USING so_fkdat-low
                     CHANGING so_fkdat-high.
  so_fkdat-sign   = 'I'.
  so_fkdat-option = 'BT'.
  APPEND so_fkdat.

  CONCATENATE sy-datum(6) '01' INTO so_erdat-low.
  PERFORM f_last_day USING so_erdat-low
                     CHANGING so_erdat-high.
  so_erdat-sign   = 'I'.
  so_erdat-option = 'BT'.
  APPEND so_erdat.

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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_vari.
  PERFORM f_alv_variant_f4 CHANGING pa_vari.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_create_dyn_int_table.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  INCLUDE zcoretax_e004m01.

  INCLUDE zcoretax_e004f01.
