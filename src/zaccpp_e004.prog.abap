*&---------------------------------------------------------------------*
*& Report  ZACCPP_E004
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zaccpp_e004 NO STANDARD PAGE HEADING.

INCLUDE zaccpp_e004top.

INCLUDE zaccpp_e004cl1.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-001.
SELECT-OPTIONS so_docno   FOR s501-docno
                          MODIF ID sdo.
SELECT-OPTIONS so_erdat   FOR zaccdtm-erdat
                          MODIF ID ser
                          DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK general.
SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE text-002.
*PARAMETERS pa_comp    TYPE zaccdtu-company OBLIGATORY DEFAULT 'BPOM'.
*SELECTION-SCREEN SKIP 1.
PARAMETERS radio2 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
PARAMETERS radio5 RADIOBUTTON GROUP grp1 MODIF ID xxx.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio6 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(33) text-004 FOR FIELD radio6.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS radio11 RADIOBUTTON GROUP grp1 MODIF ID xxx.
SELECTION-SCREEN COMMENT 5(33) text-003 FOR FIELD radio11 MODIF ID xxx.
SELECTION-SCREEN END OF LINE.
PARAMETERS radio13 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

INITIALIZATION.
  gv_repid  = sy-repid.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_selection.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN space.
      PERFORM f_validate_screen.
    WHEN 'ONLI'.
      PERFORM f_validate_screen.
  ENDCASE.

START-OF-SELECTION.
  PERFORM f_init_data.
  PERFORM f_login USING gv_login gv_logproxy.

  IF gv_error IS INITIAL.
    CASE 'X'.
      WHEN radio2.
        PERFORM f_get_data USING 'DO' '' ''.
        PERFORM f_process_data USING ''.

      WHEN radio3.
        PERFORM f_crt_dyn_int_table USING 'T'.
        PERFORM f_crt_dyn_int_table USING 'B'.
        PERFORM f_http_get USING gv_uri gv_proxy.
        PERFORM f_process_data USING ''.
        PERFORM f_print_data.

      WHEN radio5.
        PERFORM f_get_data USING 'PRO' 'ESTO' 'X'.
        PERFORM f_process_data USING ''.

      WHEN radio6.
        PERFORM f_get_data USING 'PRO' 'ESTO' ''.
        PERFORM f_process_data USING 'ESTO'.
        PERFORM f_get_data USING 'PRO' 'RTS' ''.
        PERFORM f_process_data USING 'RTS'.
        PERFORM f_get_data USING 'PRO' 'RJCT' ''.
        PERFORM f_process_data USING 'RJCT'.

      WHEN radio11.
        PERFORM f_get_data USING 'PRO' 'ESTO' 'X'.
        PERFORM f_process_data USING ''.

      WHEN radio13.
        PERFORM f_get_data USING 'INB' '' ''.
        PERFORM f_process_data USING ''.
    ENDCASE.
  ELSE.
    CASE gv_error.
      WHEN 1.
        MESSAGE s000(zab) WITH 'Token not found' DISPLAY LIKE 'E'.
    ENDCASE.
  ENDIF.

  INCLUDE zaccpp_e004f01.
