*&---------------------------------------------------------------------*
*& Report  ZFI_E005
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_e005 NO STANDARD PAGE HEADING.

INCLUDE zfi_e005top.

INCLUDE zfi_e005cl1.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN -> SELECTION
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS pa_bukrs       TYPE bkpf-bukrs MODIF ID pbu.
PARAMETERS pa_zbank       TYPE zfidt004-zbank MODIF ID pba.
PARAMETERS pa_norek       TYPE zfidt004-znorek MODIF ID pno.
PARAMETERS pa_budat       TYPE zfidt003-budat MODIF ID pbd.
PARAMETERS pa_zuonr       TYPE bseg-zuonr MODIF ID pzu.
PARAMETERS pa_zuon1       TYPE bseg-zuonr MODIF ID pz1.
PARAMETERS pa_fname       TYPE ibipparms-path MODIF ID pfn.
SELECT-OPTIONS so_budat   FOR bkpf-budat MODIF ID sbd.
SELECT-OPTIONS so_zbank   FOR zfidt004-zbank MODIF ID sba.
SELECT-OPTIONS so_zuonr   FOR bseg-zuonr MODIF ID szu.
SELECT-OPTIONS so_zuon1   FOR bseg-zuonr MODIF ID sz1.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_excel AS CHECKBOX MODIF ID pex.
PARAMETERS pa_prev AS CHECKBOX MODIF ID ppr.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
PARAMETERS pa_pdfnm       TYPE ibipparms-path MODIF ID pf1.
SELECTION-SCREEN SKIP 1.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio2 RADIOBUTTON GROUP grp1.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
PARAMETERS radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN ULINE.
PARAMETERS radio5 RADIOBUTTON GROUP grp1.
PARAMETERS radio6 RADIOBUTTON GROUP grp1.
PARAMETERS radio8 RADIOBUTTON GROUP grp1.
PARAMETERS radio7 RADIOBUTTON GROUP grp1.
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
  PERFORM f_f4_filename USING 'FILE'
                        CHANGING pa_fname.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_pdfnm.
  PERFORM f_f4_filename USING 'PATH'
                        CHANGING pa_pdfnm.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_zbank.
  PERFORM f_f4_bank USING 'PA_ZBANK' 'PA_BUKRS' 'ZBANK' 'PA_NOREK'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_norek.
  PERFORM f_f4_norek USING 'PA_NOREK' 'PA_BUKRS' 'ZNOREK' 'PA_ZBANK' 'PA_WAERS'.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  IF gv_subrc = 0.
    PERFORM f_create_dyn_int_table.
    PERFORM f_get_data.
    CASE 'X'.
      WHEN radio1.
        PERFORM f_process_data.
        PERFORM f_print_data.
      WHEN radio2.
        IF gt_x005[] IS NOT INITIAL.
          PERFORM f_prepare_print_brv USING pa_bukrs pa_zuonr pa_budat
                                            pa_zbank pa_norek.
          PERFORM f_print_form USING pa_prev 'X' 'ZFTRS_F002' 'X' '' ''.
        ELSE.
          gv_subrc = 6.
        ENDIF.
      WHEN radio3.
        IF gt_x005[] IS NOT INITIAL.
          PERFORM f_reverse_data USING 'BRV'.
        ENDIF.
      WHEN radio4.
        PERFORM f_process_report.
        PERFORM f_print_data.
      WHEN radio5.
        gs_bpv-budat = sy-datum.
        gs_bpv-waers = 'IDR'.
        CALL SCREEN 100.
      WHEN radio6.
        PERFORM f_prepare_print_bpv TABLES gt_bpv
                                    USING gs_bpv-bukrs gs_bpv-zbpvn gs_bpv-budat
                                          gs_bpv-cheque gs_bpv-kursf ''.
        PERFORM f_print_form USING '' 'X' 'ZFTRS_F003' 'X' '' ''.
      WHEN radio7.
        PERFORM f_process_report.
        PERFORM f_print_data.
      WHEN radio8.
        IF gt_bpv[] IS NOT INITIAL.
          PERFORM f_reverse_data USING 'BPV'.
        ENDIF.
    ENDCASE.
  ENDIF.

  CASE gv_subrc.
    WHEN 1.
      MESSAGE s000(zab) WITH 'Bank tidak sesuai' DISPLAY LIKE 'E'.
    WHEN 2.
      MESSAGE s000(zab) WITH 'Company code tidak sesuai' DISPLAY LIKE 'E'.
    WHEN 3.
      MESSAGE s000(zab) WITH 'Tanggal posting tidak sesuai' DISPLAY LIKE 'E'.
    WHEN 4.
      MESSAGE s000(zab) WITH 'Bank belum dimaintain' DISPLAY LIKE 'E'.
    WHEN 5.
      MESSAGE s000(zab) WITH 'Voucher nomor sudah pernah ada' DISPLAY LIKE 'E'.
    WHEN 6.
      MESSAGE s000(zab) WITH 'Data tidak ditemukan' DISPLAY LIKE 'E'.
    WHEN 7.
      MESSAGE s000(zab) WITH 'File yang diupload tidak sesuai' DISPLAY LIKE 'E'.
  ENDCASE.

  INCLUDE zfi_e005m01.

  INCLUDE zfi_e005f01.
