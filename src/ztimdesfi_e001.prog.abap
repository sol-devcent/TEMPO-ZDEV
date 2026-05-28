*&---------------------------------------------------------------------*
*& Report  ZTIMDESFI_E001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztimdesfi_e001 NO STANDARD PAGE HEADING.

INCLUDE zabp_alv_common.

INCLUDE ztimdesfi_e001top.

INCLUDE ztimdesfi_e001cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_bukrs   TYPE bkpf-bukrs MODIF ID pbu.
PARAMETERS pa_vkbur   TYPE vbak-vkbur MODIF ID pvk.
SELECT-OPTIONS so_kunnr   FOR vbak-kunnr MODIF ID szd.
SELECT-OPTIONS so_vbeln   FOR vbak-vbeln MODIF ID svb.
SELECT-OPTIONS so_erdat   FOR vbak-erdat MODIF ID ser.
PARAMETERS pa_cod AS CHECKBOX MODIF ID pco.
PARAMETERS pa_stgrd   TYPE uf05a-stgrd MODIF ID pst.
PARAMETERS pa_belnr   TYPE bkpf-belnr MODIF ID pbe.
PARAMETERS pa_gjahr   TYPE bkpf-gjahr MODIF ID pgj.
SELECT-OPTIONS so_budat   FOR bkpf-budat MODIF ID sbd.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK header WITH FRAME TITLE TEXT-002.
PARAMETERS pa_blart   TYPE bkpf-blart DEFAULT 'DA' MODIF ID pbt.
PARAMETERS pa_budat   TYPE bkpf-budat DEFAULT sy-datum MODIF ID pbd.
PARAMETERS pa_bldat   TYPE bkpf-bldat DEFAULT sy-datum MODIF ID pbl.
SELECTION-SCREEN END OF BLOCK header.

SELECTION-SCREEN BEGIN OF BLOCK payment WITH FRAME TITLE TEXT-003.
PARAMETERS pa_xblnr   TYPE bkpf-xblnr MODIF ID pxb.
PARAMETERS pa_hkont   TYPE bseg-hkont MODIF ID phk.
PARAMETERS pa_dmbtr   TYPE p DECIMALS 0 MODIF ID pdm.
SELECTION-SCREEN END OF BLOCK payment.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-004.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_hkont.
  PERFORM f_f4_hkont CHANGING pa_hkont.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  CASE 'X'.
    WHEN radio1.
      IF pa_cod IS INITIAL.
        PERFORM f_init_data.
        PERFORM f_create_dyn_int_table.
        PERFORM f_lock_table USING 'X'.
        IF gv_uname IS INITIAL.
          PERFORM f_get_data.
          IF gv_subrc = 0.
            PERFORM f_process_data.
            PERFORM f_print_data.
          ELSE.
            MESSAGE s000(zab) WITH 'Wrong G/L Account' DISPLAY LIKE 'E'.
          ENDIF.
        ELSE.
          MESSAGE s000(zab) WITH 'Transaction Lock by' gv_uname
          DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
    WHEN radio2.
      PERFORM f_get_reverse_data.
      PERFORM f_print_data.

    WHEN radio3.
      PERFORM f_get_report_data.
      PERFORM f_print_data.
  ENDCASE.

  INCLUDE ztimdesfi_e001m01.

  INCLUDE ztimdesfi_e001f01.
