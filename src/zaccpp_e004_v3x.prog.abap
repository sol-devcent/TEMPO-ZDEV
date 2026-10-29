*&---------------------------------------------------------------------*
*& Report  ZACCPP_E004_V3X
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zaccpp_e004_v3x NO STANDARD PAGE HEADING.

INCLUDE zaccpp_e004_v3xtop.

INCLUDE zaccpp_e004_v3xcl1.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-001.
SELECT-OPTIONS so_docno   FOR s501-docno
                          MODIF ID sdo.
SELECT-OPTIONS so_erdat   FOR zaccdtm-erdat
                          MODIF ID ser
                          DEFAULT sy-datum.
PARAMETERS pa_offst       TYPE eranz MODIF ID pof.
PARAMETERS pa_limit       TYPE eranz MODIF ID pli.
PARAMETERS pa_werks       TYPE t001w-werks MODIF ID pwe.
SELECT-OPTIONS so_werks   FOR t001w-werks
                          MODIF ID swe.
PARAMETERS pa_idloc(3)    MODIF ID plo.
PARAMETERS pa_idtuj(3)    MODIF ID ptu.
PARAMETERS pa_nie         TYPE ztspmmdt002-nie MODIF ID pni.
PARAMETERS pa_charg       TYPE mch1-charg MODIF ID pch.
SELECTION-SCREEN SKIP 1.
PARAMETERS pa_test  AS CHECKBOX MODIF ID tst.
SELECTION-SCREEN END OF BLOCK general.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad MODIF ID r01.
SELECTION-SCREEN COMMENT 5(43) text-003 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio2 RADIOBUTTON GROUP grp1 MODIF ID r02.
SELECTION-SCREEN COMMENT 5(33) text-004 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio3 RADIOBUTTON GROUP grp1 MODIF ID r03.
SELECTION-SCREEN COMMENT 5(33) text-005 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio4 RADIOBUTTON GROUP grp1 MODIF ID r04.
SELECTION-SCREEN COMMENT 5(33) text-006 FOR FIELD radio4.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio7 RADIOBUTTON GROUP grp1 MODIF ID r07.
SELECTION-SCREEN COMMENT 5(33) text-009 FOR FIELD radio7.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio8 RADIOBUTTON GROUP grp1 MODIF ID r08.
SELECTION-SCREEN COMMENT 5(33) text-010 FOR FIELD radio8.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio5 RADIOBUTTON GROUP grp1 MODIF ID r05.
SELECTION-SCREEN COMMENT 5(33) text-007 FOR FIELD radio5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio9 RADIOBUTTON GROUP grp1 MODIF ID r09.
SELECTION-SCREEN COMMENT 5(33) text-011 FOR FIELD radio9.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio6 RADIOBUTTON GROUP grp1 MODIF ID r06.
SELECTION-SCREEN COMMENT 5(33) text-008 FOR FIELD radio6.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK option.

INITIALIZATION.
  gv_repid    = sy-repid.
  PERFORM f_login_data.
  IF gv_token IS INITIAL.
    CASE gv_error.
      WHEN 1.
        MESSAGE s000(zab) WITH 'Authentication failed, Invalid email or password!'
                          DISPLAY LIKE 'E'.
      WHEN 2.
        MESSAGE s000(zab) WITH 'User token mismatch!' DISPLAY LIKE 'E'.
    ENDCASE.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  IF gv_autho = 1.
    PERFORM f_modify_screen USING : 'R06' '' '0' '' '',
                                    'R09' '' '0' '' ''.
  ENDIF.
  CASE 'X'.
    WHEN radio1.
      IF gv_error IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'SDO' '' '0' '' '',
                                        'SER' '' '0' '' ''.
      ENDIF.
      PERFORM f_modify_screen USING : 'POF' '0' '' '' '',
                                      'PLI' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'SWE' '0' '' '' '',
                                      'PLO' '0' '' '' '',
                                      'PAR' '0' '' '' '',
                                      'PTU' '0' '' '' '',
                                      'TST' '0' '' '' '',
                                      'PNI' '0' '' '' '',
                                      'PCH' '0' '' '' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'POF' '0' '' '' '',
                                      'PLI' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'SWE' '0' '' '' '',
                                      'PTU' '0' '' '' '',
                                      'TST' '0' '' '' '',
                                      'PNI' '0' '' '' '',
                                      'PCH' '0' '' '' ''.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'POF' '0' '' '' '',
                                      'PLI' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'SWE' '0' '' '' '',
                                      'PLO' '0' '' '' '',
                                      'PAR' '0' '' '' '',
                                      'PTU' '0' '' '' '',
                                      'TST' '0' '' '' '',
                                      'PNI' '0' '' '' '',
                                      'PCH' '0' '' '' ''.
    WHEN radio4.
      PERFORM f_modify_screen USING : 'SDO' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'SWE' '0' '' '' '',
                                      'PLO' '0' '' '' '',
                                      'TST' '0' '' '' '',
                                      'PAR' '0' '' '' '',
                                      'PTU' '0' '' '' '',
                                      'PNI' '0' '' '' '',
                                      'PCH' '0' '' '' ''.
    WHEN radio5.
      PERFORM f_modify_screen USING : 'POF' '0' '' '' '',
                                      'PLI' '0' '' '' '',
                                      'SWE' '0' '' '' '',
                                      'PLO' '0' '' '' '',
                                      'PAR' '0' '' '' '',
                                      'TST' '0' '' '' '',
                                      'PNI' '0' '' '' '',
                                      'PCH' '0' '' '' ''.
    WHEN radio6.
      PERFORM f_modify_screen USING : 'POF' '0' '' '' '',
                                      'PLI' '0' '' '' '',
                                      'SWE' '0' '' '' '',
                                      'PLO' '0' '' '' '',
                                      'PAR' '0' '' '' '',
                                      'PTU' '0' '' '' '',
                                      'TST' '0' '' '' '',
                                      'PNI' '0' '' '' '',
                                      'PCH' '0' '' '' ''.
    WHEN radio7.
      PERFORM f_modify_screen USING : 'SDO' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'POF' '0' '' '' '',
                                      'PLI' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'TST' '0' '' '' '',
                                      'PLO' '0' '' '' '',
                                      'PAR' '0' '' '' '',
                                      'PTU' '0' '' '' '',
                                      'PNI' '0' '' '' '',
                                      'PCH' '0' '' '' ''.
    WHEN radio8.
      PERFORM f_modify_screen USING : 'SDO' '0' '' '' '',
                                      'SER' '0' '' '' '',
                                      'PWE' '0' '' '' '',
                                      'SWE' '0' '' '' '',
                                      'PLO' '0' '' '' '',
                                      'TST' '0' '' '' '',
                                      'PAR' '0' '' '' '',
                                      'PTU' '0' '' '' '',
                                      'PNI' '0' '' '' '',
                                      'PCH' '0' '' '' ''.
    WHEN radio9.
      IF gv_autho = '1'.
        PERFORM f_modify_screen USING : 'SDO' '0' '' '' '',
                                        'SER' '0' '' '' '',
                                        'SWE' '0' '' '' '',
                                        'PLO' '0' '' '' '',
                                        'TST' '0' '' '' '',
                                        'PAR' '0' '' '' '',
                                        'PTU' '0' '' '' ''.
      ELSE.
        PERFORM f_modify_screen USING : 'SDO' '0' '' '' '',
                                        'SER' '0' '' '' '',
                                        'SWE' '0' '' '' '',
                                        'PLO' '0' '' '' '',
                                        'TST' '0' '' '' '',
                                        'PAR' '0' '' '' '',
                                        'PTU' '0' '' '' '',
                                        'R01' '' '0' '' '',
                                        'R02' '' '0' '' '',
                                        'R03' '' '0' '' '',
                                        'R04' '' '0' '' '',
                                        'R05' '' '0' '' '',
                                        'R07' '' '0' '' '',
                                        'R08' '' '0' '' ''.
      ENDIF.
  ENDCASE.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      CASE 'X'.
        WHEN radio2.
          IF pa_idloc IS INITIAL.
            PERFORM f_error_message USING 'PLO' ''.
          ELSE.
            PERFORM f_idsarana_f4_help USING '' ''.
          ENDIF.
        WHEN radio5.
          IF pa_werks IS INITIAL.
            PERFORM f_error_message USING 'PWE' ''.
          ENDIF.
        WHEN radio6.
          IF pa_werks IS INITIAL.
            PERFORM f_error_message USING 'PWE' ''.
          ENDIF.
      ENDCASE.
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_idloc.
  PERFORM f_f4_help USING 'IDLOC' 'PA_IDLOC'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_idtuj.
  PERFORM f_f4_help USING 'IDTUJ' 'PA_IDTUJ'.

START-OF-SELECTION.
  PERFORM f_init_data.
  IF gv_token IS NOT INITIAL.
    CASE 'X'.
      WHEN radio4.
        PERFORM f_crt_dyn_int_table.
        IF gt_items[] IS INITIAL.
          PERFORM f_informasi_sarana.
          PERFORM f_process_sarana USING 'X'.
        ENDIF.
        PERFORM f_print_data.
      WHEN radio7.
        PERFORM f_add_lokasi_sarana.
        PERFORM f_write_error.
      WHEN radio8.
        PERFORM f_crt_dyn_int_table.
        IF gt_items[] IS INITIAL.
          PERFORM f_informasi_sarana_tujuan.
          PERFORM f_process_sarana_tujuan USING 'X'.
        ENDIF.
        PERFORM f_print_data.
      WHEN radio9.
        PERFORM f_crt_dyn_int_table.
        IF gt_items[] IS INITIAL.
          PERFORM f_inbound_product.
          PERFORM f_process_inbound_product USING 'X'.
        ENDIF.
        PERFORM f_print_data.
      WHEN OTHERS.
        PERFORM f_get_data.
        IF gt_s501[] IS NOT INITIAL.
          CASE 'X'.
            WHEN radio1.
              PERFORM f_registerparent_process.
            WHEN radio2.
              PERFORM f_registerprimer_process USING 'ESTO' 'ZREGPRIMER_BPOM'.
            WHEN radio3.
              PERFORM f_packaging_aggregate_process.
            WHEN radio5.
              PERFORM f_barcode_process.
              PERFORM f_kirim_process.
            WHEN radio6.
              PERFORM f_barcode_process.
              PERFORM f_terima_process.
          ENDCASE.
        ELSE.
          MESSAGE s000(zab) WITH 'Data not found' DISPLAY LIKE 'E'.
        ENDIF.

        PERFORM f_write_error.
    ENDCASE.
  ELSE.
    CASE gv_error.
      WHEN 1.
        MESSAGE s000(zab) WITH 'Authentication failed, Invalid email or password!'
                          DISPLAY LIKE 'E'.
      WHEN 2.
        MESSAGE s000(zab) WITH 'User token mismatch!' DISPLAY LIKE 'E'.
    ENDCASE.
  ENDIF.

  INCLUDE zaccpp_e004_v3xf01.
