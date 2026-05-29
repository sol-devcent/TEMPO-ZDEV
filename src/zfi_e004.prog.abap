*&---------------------------------------------------------------------*
*& Report  ZFI_E004
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_e004 NO STANDARD PAGE HEADING.

INCLUDE zfi_e004top.

INCLUDE zfi_e004cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_bukrs  TYPE zfidt002-bukrs MODIF ID pbu.
PARAMETERS pa_zbank  TYPE zfidt002-zbank MODIF ID pba.
PARAMETERS pa_belnr  TYPE bkpf-belnr MODIF ID pbe.
PARAMETERS pa_gjahr  TYPE bkpf-gjahr MODIF ID pgj.
PARAMETERS pa_budat  TYPE zfidt003-budat MODIF ID pbd.
PARAMETERS pa_fname  TYPE ibipparms-path MODIF ID pfn.
PARAMETERS pa_zuonr  TYPE bseg-zuonr MODIF ID pzu.
SELECT-OPTIONS so_budat   FOR bkpf-budat MODIF ID sbd.
SELECT-OPTIONS so_zbank   FOR zfidt002-zbank MODIF ID sba.
SELECT-OPTIONS so_zuonr   FOR bseg-zuonr MODIF ID szu.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_prev AS CHECKBOX MODIF ID ppr.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
PARAMETERS radio4 RADIOBUTTON GROUP grp1.
PARAMETERS radio5 RADIOBUTTON GROUP grp1.
PARAMETERS radio7 RADIOBUTTON GROUP grp1.
PARAMETERS radio6 RADIOBUTTON GROUP grp1.
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
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_fname.
  PERFORM f_f4_filename CHANGING pa_fname.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  IF gv_subrc = 0.
    PERFORM f_create_dyn_int_table.
    PERFORM f_get_data.
    IF gv_subrc = 0.
      CASE 'X'.
        WHEN radio1.
          PERFORM f_process_data.
          PERFORM f_print_data.
        WHEN radio2.
          IF gt_x003[] IS NOT INITIAL.
            PERFORM f_prepare_print USING pa_bukrs '' pa_budat
                                          pa_zbank.
            PERFORM f_print_form.
          ELSE.
            gv_subrc = 3.
          ENDIF.
        WHEN radio3.
          PERFORM f_reprint_form.
        WHEN radio4.
          PERFORM f_reverse_data USING 'BRV'.
        WHEN radio5.
          IF gt_x003[] IS NOT INITIAL.
            PERFORM f_process_report.
            PERFORM f_print_data.
          ELSE.
            gv_subrc = 4.
          ENDIF.
        WHEN radio7.
          PERFORM f_process_report.
          PERFORM f_print_data.
        WHEN radio6.
          PERFORM f_process_report.
          PERFORM f_print_data.
      ENDCASE.
    ENDIF.
  ENDIF.

  CASE gv_subrc.
    WHEN 1.
      MESSAGE s000(zab) WITH 'Bank tidak sesuai' DISPLAY LIKE 'E'.
    WHEN 2.
      MESSAGE s000(zab) WITH 'Tanggal posting tidak sesuai' DISPLAY LIKE 'E'.
    WHEN 3.
      MESSAGE s000(zab) WITH 'Data sudah pernah di print' DISPLAY LIKE 'E'.
    WHEN 4.
      MESSAGE s000(zab) WITH 'Data tidak ada/sudah di posting' DISPLAY LIKE 'E'.
    WHEN 5.
      MESSAGE s000(zab) WITH 'Voucher nomor sudah pernah ada' DISPLAY LIKE 'E'.
    WHEN 6.
      MESSAGE s000(zab) WITH 'You are not authorized' DISPLAY LIKE 'E'.
    WHEN 7.
      MESSAGE s000(zab) WITH 'Company code tidak sesuai' DISPLAY LIKE 'E'.
  ENDCASE.

  INCLUDE zfi_e004m01.

  INCLUDE zfi_e004f01.
