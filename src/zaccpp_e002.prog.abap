*&---------------------------------------------------------------------*
*& Report  ZACCPP_E002
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zaccpp_e002 NO STANDARD PAGE HEADING LINE-SIZE  294.

INCLUDE zaccpp_e002top.

INCLUDE zaccpp_e002cl1.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE TEXT-001.
PARAMETERS filenm  LIKE rlgrap-filename MODIF ID pfl.
PARAMETERS pa_xls  AS CHECKBOX USER-COMMAND xls.
SELECTION-SCREEN END OF BLOCK general.

SELECTION-SCREEN BEGIN OF BLOCK option WITH FRAME TITLE TEXT-002.
PARAMETERS radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad DEFAULT 'X'.
PARAMETERS p_id TYPE zaccppdt001-zdata MODIF ID pf2.
PARAMETERS radio2 RADIOBUTTON GROUP grp1 MODIF ID xxx.
PARAMETERS radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK option.

INITIALIZATION.
  gv_repid  = sy-repid.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_selection.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR filenm.
  PERFORM f_filename_f4 CHANGING filenm.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN space.
      PERFORM f_validate_screen.
    WHEN 'ONLI'.
      PERFORM f_validate_screen.
  ENDCASE.

START-OF-SELECTION.
  PERFORM f_init_data.
  PERFORM f_crt_dyn_int_table USING 'T'.
  IF pa_xls IS INITIAL.
    IF p_id IS INITIAL.
      IF radio1 = 'X'.
        SELECT *
          FROM zaccppdt001
          INTO CORRESPONDING FIELDS OF TABLE gt_zaccppdt001
          WHERE zproses = 'ACC_AGGR'
            AND status  = 'U' or status  = 'E'.
        IF sy-subrc = 0.
          LOOP AT gt_zaccppdt001 INTO gs_zaccppdt001.
            p_id = gs_zaccppdt001-zdata.
            CLEAR: gt_upload[], gt_accdtm[].
            PERFORM f_upload_fr_api USING gv_uri p_id.
            PERFORM f_get_data.
            PERFORM f_process_data.
            IF gv_backg IS INITIAL.
              PERFORM f_print_data.
            ENDIF.
          ENDLOOP.
          LEAVE PROGRAM.
        ENDIF.
      ELSE.
        PERFORM f_upload_fr_api USING gv_uri p_id.
      ENDIF.
    ELSE.
      PERFORM f_upload_fr_api USING gv_uri p_id.
    ENDIF.
  ELSE.
    PERFORM f_upload_fr_excel.
  ENDIF.
  "  PERFORM f_crt_dyn_int_table USING 'T'.

  CASE 'X'.
    WHEN radio3.
      PERFORM f_get_data.
      PERFORM f_update_data.

    WHEN radio2.
      PERFORM f_get_data.
      PERFORM f_cancel_data.
*      PERFORM f_process_data.
*      IF gv_backg IS INITIAL.
*        PERFORM f_print_data.
*      ELSE.
*        PERFORM f_cancel_data.
*      ENDIF.

    WHEN OTHERS.
      PERFORM f_get_data.
      PERFORM f_process_data.
      IF gv_backg IS INITIAL.
        PERFORM f_print_data.
      ENDIF.
  ENDCASE.

  INCLUDE zaccpp_e002f01.
