*&---------------------------------------------------------------------*
*& Report  ZFPAYROLL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfpayroll NO STANDARD PAGE HEADING.

INCLUDE zabp_bdc.

INCLUDE zfpayrolltop.

INCLUDE zfpayrollc01.

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS pa_bukrs       LIKE t001-bukrs MODIF ID pbu.
PARAMETERS pa_vkbur       LIKE tvbur-vkbur MODIF ID pvk.
SELECT-OPTIONS so_vkbur   FOR tvbur-vkbur MODIF ID svk.
PARAMETERS pa_monat       LIKE bkpf-monat MODIF ID pmo.
PARAMETERS pa_gjahr       LIKE bkpf-gjahr MODIF ID pgj.
PARAMETERS pa_budat       LIKE bkpf-budat MODIF ID pbt DEFAULT sy-datum.
SELECT-OPTIONS so_spmon   FOR bseg-abper MODIF ID ssp DEFAULT sy-datum(6).
PARAMETERS pa_filnm       TYPE rlgrap-filename MODIF ID pfl.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad.
PARAMETERS radio2 RADIOBUTTON GROUP grp1 DEFAULT 'X'.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
PARAMETERS radio4 RADIOBUTTON GROUP grp1.
PARAMETERS radio5 RADIOBUTTON GROUP grp1.
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
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_filnm.
  PERFORM f4_pa_filnm CHANGING pa_filnm.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_init_data.
  PERFORM f_get_data.
  IF gv_subrc IS INITIAL.
    PERFORM f_process_data.
    PERFORM f_print_data.
  ENDIF.
  PERFORM f_free_memory.

  INCLUDE zfpayrollf01.
