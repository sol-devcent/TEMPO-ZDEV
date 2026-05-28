*&---------------------------------------------------------------------*
*& Report  ZF_TTF
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zf_ttf NO STANDARD PAGE HEADING.

INCLUDE zf_ttftop.

INCLUDE zf_ttfcl1.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-001.
PARAMETER pa_bukrs  TYPE bsid-bukrs MODIF ID pbu.
PARAMETER pa_vkbur  TYPE knvv-vkbur MODIF ID pvk.
SELECT-OPTIONS so_vkbur   FOR knvv-vkbur MODIF ID svk.
PARAMETER pa_kunnr  TYPE kna1-kunnr MODIF ID pku.
SELECT-OPTIONS so_kunnr   FOR kna1-kunnr MODIF ID sku.
SELECT-OPTIONS so_zuonr   FOR bsid-zuonr MODIF ID szu.
PARAMETER pa_stida  TYPE rfpdo-allgstid MODIF ID pst DEFAULT sy-datum.
SELECT-OPTIONS so_tglin   FOR zftransttf-tglinput MODIF ID stg.
SELECTION-SCREEN END OF BLOCK general.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS pa_cust  RADIOBUTTON GROUP grp1 USER-COMMAND rad
                                           DEFAULT 'X'.
PARAMETERS pa_paym  RADIOBUTTON GROUP grp1.
PARAMETERS pa_data  RADIOBUTTON GROUP grp1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS pa_rept  RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(20) text-003 FOR FIELD pa_rept.
SELECTION-SCREEN POSITION 32.
SELECTION-SCREEN COMMENT 35(20) text-007 FOR FIELD pa_varnt MODIF ID pva.
PARAMETER pa_varnt  TYPE disvariant-variant MODIF ID pva.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK option.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  d_repid = sy-repid.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON ( PARAMETERS )
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_varnt.
  PERFORM f_variant_f4 CHANGING pa_varnt.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

  INCLUDE zf_ttff01.
