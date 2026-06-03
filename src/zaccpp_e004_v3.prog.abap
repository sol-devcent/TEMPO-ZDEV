*&---------------------------------------------------------------------*
*& Report  ZACCPP_E004_V3
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zaccpp_e004_v3 NO STANDARD PAGE HEADING.

INCLUDE zaccpp_e004_v3top.

INCLUDE zaccpp_e004_v3cl1.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-001.
PARAMETERS pa_werks   TYPE s501-werks MODIF ID pwe.
SELECTION-SCREEN END OF BLOCK general.

SELECTION-SCREEN BEGIN OF SCREEN 9000.
SELECTION-SCREEN BEGIN OF BLOCK selection WITH FRAME TITLE text-001.
PARAMETERS pa_filnm   TYPE ibipparms-path MODIF ID pfi.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(28) text001 MODIF ID sdo
                                       FOR FIELD so_docno.
SELECT-OPTIONS so_docno   FOR s501-docno
                          MODIF ID sdo.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(28) text002 MODIF ID ser
                                       FOR FIELD so_erdat.
SELECT-OPTIONS so_erdat   FOR zaccdtm-erdat
                          MODIF ID ser
                          DEFAULT sy-datum.
SELECTION-SCREEN END OF LINE.

SELECT-OPTIONS so_senum   FOR zaccdtm-senum
                          MODIF ID sse.
PARAMETERS pa_desti   TYPE sy-index MODIF ID pde.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_test  AS CHECKBOX MODIF ID tst.
SELECTION-SCREEN END OF BLOCK selection.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio9 RADIOBUTTON GROUP grp1 USER-COMMAND rad
                                         DEFAULT 'X'
                                         MODIF ID ra9.
SELECTION-SCREEN COMMENT 5(43) text-011 FOR FIELD radio9.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio10 RADIOBUTTON GROUP grp1 MODIF ID ra0.
SELECTION-SCREEN COMMENT 5(43) text-012 FOR FIELD radio10.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 MODIF ID ra1.
SELECTION-SCREEN COMMENT 5(43) text-003 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio2 RADIOBUTTON GROUP grp1 MODIF ID ra2.
SELECTION-SCREEN COMMENT 5(33) text-004 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio3 RADIOBUTTON GROUP grp1 MODIF ID ra3.
SELECTION-SCREEN COMMENT 5(33) text-005 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio4 RADIOBUTTON GROUP grp1 MODIF ID ra4.
SELECTION-SCREEN COMMENT 5(33) text-006 FOR FIELD radio4.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio5 RADIOBUTTON GROUP grp1 MODIF ID ra5.
SELECTION-SCREEN COMMENT 5(33) text-007 FOR FIELD radio5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio6 RADIOBUTTON GROUP grp1 MODIF ID ra6.
SELECTION-SCREEN COMMENT 5(33) text-008 FOR FIELD radio6.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio7 RADIOBUTTON GROUP grp1 MODIF ID ra7.
SELECTION-SCREEN COMMENT 5(33) text-009 FOR FIELD radio7.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio8 RADIOBUTTON GROUP grp1 MODIF ID ra8.
SELECTION-SCREEN COMMENT 5(33) text-010 FOR FIELD radio8.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK option.
SELECTION-SCREEN END OF SCREEN 9000.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid    = sy-repid.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_selection.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI' OR 'RAD'.
      PERFORM f_selection_screen.
    WHEN space.
      PERFORM f_selection_screen.
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_filnm.
  PERFORM f_get_f4 CHANGING pa_filnm.

START-OF-SELECTION.
  PERFORM f_init_data.

  IF gs_zaccdtl IS NOT INITIAL.
    CALL SELECTION-SCREEN 9000.
  ELSE.
    gv_error = 1.
  ENDIF.

  IF sy-subrc = 0.
    IF gv_error IS INITIAL.
      PERFORM f_login_data.
      IF gv_token IS NOT INITIAL.
        CASE 'X'.
          WHEN radio1.
            IF gs_zaccdtl-zopt01 IS NOT INITIAL.
              PERFORM f_get_data USING 'PRO' ''.
              PERFORM f_registerparent_process.
            ELSE.
              gv_error  = 3.
            ENDIF.
          WHEN radio2.
            DATA : lv_subrc1    TYPE sy-subrc,
                   lv_subrc2    TYPE sy-subrc,
                   lv_subrc3    TYPE sy-subrc.

            IF gs_zaccdtl-zopt02 IS NOT INITIAL.
              PERFORM f_get_data USING 'PRO' '1'.
              PERFORM f_register_process USING 'ESTO'
                                         CHANGING lv_subrc1.
              PERFORM f_register_process USING 'RTS'
                                         CHANGING lv_subrc2.
              PERFORM f_register_process USING 'RJCT'
                                         CHANGING lv_subrc3.
              IF lv_subrc1 IS NOT INITIAL AND
                lv_subrc2 IS NOT INITIAL AND
                lv_subrc3 IS NOT INITIAL.
                gv_error = 2.
              ENDIF.
            ELSE.
              gv_error  = 3.
            ENDIF.
          WHEN radio3.
            IF gs_zaccdtl-zopt03 IS NOT INITIAL.
              PERFORM f_get_data USING 'PRO' '2'.
              PERFORM f_packingaggregate_process.
            ELSE.
              gv_error  = 3.
            ENDIF.
          WHEN radio4.
            IF gs_zaccdtl-zopt06 IS NOT INITIAL.
              PERFORM f_informasi.
              PERFORM f_create_dyn_int_table.
              PERFORM f_process_data.
              PERFORM f_print_data.
            ELSE.
              gv_error  = 3.
            ENDIF.
          WHEN radio5.
            IF gs_zaccdtl-zopt07 IS NOT INITIAL.
              PERFORM f_kirim_produk USING 'DO'.
            ELSE.
              gv_error  = 3.
            ENDIF.
          WHEN radio6.
*          IF gs_zaccdtl-zopt08 IS NOT INITIAL.
*            PERFORM f_informasi.
*            PERFORM f_create_dyn_int_table.
*            PERFORM f_process_data.
*            PERFORM f_print_data.
*          ELSE.
*            gv_error  = 3.
*          ENDIF.
          WHEN radio7.
            IF gs_zaccdtl-zopt09 IS NOT INITIAL.
              PERFORM f_terima_produk USING 'INB'.
            ELSE.
              gv_error  = 3.
            ENDIF.
          WHEN radio8.
            IF gs_zaccdtl-zopt10 IS NOT INITIAL.
              PERFORM f_get_data USING '' ''.
              PERFORM f_hapus_barcode TABLES gt_primer
                                      USING 'primer'.
              PERFORM f_hapus_barcode TABLES gt_sekunder
                                      USING 'sekunder'.
              PERFORM f_hapus_barcode TABLES gt_tersier
                                      USING 'tersier'.
            ELSE.
              gv_error  = 3.
            ENDIF.
          WHEN radio9.
            IF gs_zaccdtl-zopt01 IS NOT INITIAL.
              PERFORM f_informasi.
              PERFORM f_create_dyn_int_table.
              PERFORM f_process_data.
              PERFORM f_print_data.
            ELSE.
              gv_error  = 3.
            ENDIF.
          WHEN radio10.
            IF gs_zaccdtl-zopt02 IS NOT INITIAL.
              PERFORM f_create_dyn_int_table.
              PERFORM f_upload_data.
              PERFORM f_process_data.
            ELSE.
              gv_error  = 3.
            ENDIF.
        ENDCASE.
      ENDIF.

      IF gt_error[] IS INITIAL AND gv_error IS INITIAL.
        CASE 'X'.
          WHEN radio1.
          WHEN OTHERS.
            MESSAGE s000(zab) WITH 'Data terkirim'.
        ENDCASE.
      ELSE.
        PERFORM f_print_error.
      ENDIF.
    ELSE.
      CASE gv_error.
        WHEN 1.
          MESSAGE s000(zab) WITH 'User email not yet maintained' DISPLAY LIKE 'E'.
        WHEN 2.
          MESSAGE s000(zab) WITH 'No data processed' DISPLAY LIKE 'E'.
        WHEN 3.
          MESSAGE s000(zab) WITH 'You are not authorized' DISPLAY LIKE 'E'.
        WHEN OTHERS.
          MESSAGE s000(zab) WITH 'User token mismatch!' DISPLAY LIKE 'E'.
      ENDCASE.
    ENDIF.
  ELSE.
    CLEAR gv_default.
  ENDIF.

  INCLUDE zaccpp_e004_v3m01.

  INCLUDE zaccpp_e004_v3f01.
