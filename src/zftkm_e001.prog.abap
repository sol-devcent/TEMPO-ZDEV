*&---------------------------------------------------------------------*
*& Report  ZFTKM_E001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zftkm_e001 NO STANDARD PAGE HEADING.

INCLUDE zftkm_e001top.

INCLUDE zftkm_e001cl1.

INCLUDE zabp_bdc.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-001.
PARAMETERS pa_bukrs   TYPE bsid-bukrs MODIF ID pbu.
PARAMETERS pa_bukrx   TYPE bsid-bukrs MODIF ID pbx.
PARAMETERS pa_vkbur   TYPE vbrp-vkbur MODIF ID pvk.
PARAMETERS pa_kunnr   TYPE bsid-kunnr MODIF ID pku DEFAULT 'TSB8020'.
PARAMETERS pa_mastx   TYPE spmon MODIF ID pma DEFAULT sy-datum(6).
SELECT-OPTIONS so_fakdt   FOR zgdtxdt0003-fakdat MODIF ID sdt.
SELECT-OPTIONS so_fakno   FOR zgdtxdt0003-fakturno MODIF ID sno.
SELECT-OPTIONS so_vbeln   FOR zgdtxdt0003-vbeln MODIF ID svb.
PARAMETERS pa_belnr   TYPE bsid-belnr MODIF ID pbe.
PARAMETERS pa_gjahr   TYPE bsid-gjahr MODIF ID pgj DEFAULT sy-datum(4).
SELECT-OPTIONS so_budat   FOR bsid-budat MODIF ID sbu.
SELECTION-SCREEN BEGIN OF BLOCK posting WITH FRAME TITLE text-002.
PARAMETERS pa_budat   TYPE bsid-budat MODIF ID pud DEFAULT sy-datum.
PARAMETERS pa_bldat   TYPE bsid-bldat MODIF ID pbl DEFAULT sy-datum.
*PARAMETERS pa_xblnr   TYPE bsid-xblnr MODIF ID pxb.
*PARAMETERS pa_bktxt   TYPE bkpf-bktxt MODIF ID pbk.
SELECTION-SCREEN END OF BLOCK posting.
SELECT-OPTIONS so_vkbur   FOR vbrp-vkbur MODIF ID svk.
SELECTION-SCREEN END OF BLOCK general.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-003.
PARAMETERS pa_proc RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND rad.
PARAMETERS pa_reve RADIOBUTTON GROUP grp1.
PARAMETERS pa_rept RADIOBUTTON GROUP grp1.
PARAMETERS pa_detl RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.
*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid = sy-repid.

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

  INCLUDE zftkm_e001f01.
