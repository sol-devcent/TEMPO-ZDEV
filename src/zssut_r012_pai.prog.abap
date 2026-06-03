*&---------------------------------------------------------------------*
*&  Include           ZSSUT_I010_PAI
*&---------------------------------------------------------------------*

*&SPWIZARD: INPUT MODULE FOR TC 'T_CONTROL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE t_control_modify INPUT.
  DATA: ls_kna1 TYPE kna1.
  DATA: lv_kunnr TYPE char10.
  DATA: lv_msg TYPE string.
*  break sap_dev02.
  " __* get name and address
  IF gs_itab-kunnr IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gs_itab-kunnr
      IMPORTING
        output = lv_kunnr.
    " __* VALIDATION
    " 1
    " check whether the user select a customer with correct Sales Org and Sales Office
    DATA ls_knvv TYPE knvv.
    SELECT SINGLE * FROM knvv INTO ls_knvv WHERE kunnr = lv_kunnr AND vkorg = p_vkorg AND vkbur = p_vkbur.
    IF sy-subrc <> 0.
      CONCATENATE 'Customer must be in Sales Org =' p_vkorg 'and Sales Office =' p_vkbur INTO lv_msg SEPARATED BY space.
      MESSAGE lv_msg TYPE 'E'.
    ENDIF.
    " check salesman
    DATA: ls_knvp   TYPE knvp,
          lv_kunn2  TYPE kunn2,
          lv_kunn2tmp TYPE kunn2.
    SELECT SINGLE kunn2 INTO lv_kunn2tmp
      FROM zssutdt022 WHERE vkorg = p_vkorg AND
                            vtweg = '10'    AND
                            spart = '00'    AND
                            kunnr = lv_kunnr AND
                            vkbur = p_vkbur AND
                            pernr = p_pernr.

* Penambahan pengecekan untuk entry data baru
    IF lv_kunn2tmp IS INITIAL.
      SELECT SINGLE kunn2
      FROM knvp
      INTO lv_kunn2tmp
      WHERE kunnr = lv_kunnr
        AND vkorg = p_vkorg
        AND vtweg = '10'
        AND spart = '00'
        AND parvw = 'ZS'.
    ENDIF.

    SELECT SINGLE *
      FROM knvp
      INTO ls_knvp
      WHERE kunnr = lv_kunnr
        AND vkorg = p_vkorg
        AND vtweg = '10'
        AND spart = '00'
        AND parvw = 'ZS'
        AND kunn2 = lv_kunn2tmp.
    IF sy-subrc EQ 0.
      lv_kunn2  = ls_knvp-kunn2.
      CLEAR ls_knvp.
      SELECT SINGLE *
        FROM knvp
        INTO ls_knvp
        WHERE kunnr = lv_kunn2
          AND vkorg = p_vkorg
          AND vtweg = '10'
          AND spart = '00'
          AND parvw = 'VE'.
      IF sy-subrc <> 0.
        lv_msg = 'Different Salesman code'.
        MESSAGE lv_msg TYPE 'E'.
      ELSEIF ls_knvp-pernr NE p_pernr.
        lv_msg = 'Different Salesman code'.
        MESSAGE lv_msg TYPE 'E'.
      ENDIF.
    ENDIF.
    " no double customer inputed
    " 2

    " customer description
    SELECT SINGLE * FROM kna1 INTO ls_kna1 WHERE kunnr = lv_kunnr.
    IF sy-subrc = 0.
      gs_itab-name1 = ls_kna1-name1.
      IF ls_kna1-name2 IS NOT INITIAL.
        gs_itab-addrs = ls_kna1-name2.
      ELSE.
        gs_itab-addrs = ls_kna1-stras.
      ENDIF.
    ENDIF.
    " route list
    CLEAR ls_knvp.
    SELECT SINGLE * FROM knvp INTO ls_knvp
      WHERE kunnr = lv_kunnr
      AND   vkorg = p_vkorg
      AND   vtweg = _vtweg
      AND   spart = _spart
      AND   parvw = _parvw.
    IF sy-subrc = 0.
      gs_itab-kunn2 = ls_knvp-kunn2.
    ENDIF.
    " __* MODIFY ITAB

    gs_itab-kunnr = lv_kunnr.

    MODIFY gt_itab
      FROM gs_itab
      INDEX t_control-current_line.
  ENDIF.

  IF sy-ucomm <> '&F03' AND
    sy-ucomm <> '&F15' AND
    sy-ucomm <> '&F12'.
    DATA : lt_itab LIKE TABLE OF gt_itab WITH HEADER LINE,
           lv_count TYPE int4.

    READ TABLE gt_022m WITH KEY kunnr = lv_kunnr.
    IF sy-subrc <> 0.
      gv_subrc  = 1.
      lv_msg = 'Customer belum terdaftar di matrix kunjungan'.
      MESSAGE lv_msg TYPE 'E'.
    ELSE.
      lt_itab[] = gt_itab[].
      SORT lt_itab BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING kunnr.
      CLEAR lv_count.
      LOOP AT lt_itab.
        CLEAR lv_count.
        LOOP AT gt_itab WHERE kunnr = lt_itab-kunnr.
          ADD 1 TO lv_count.
        ENDLOOP.
        IF lv_count > 1.
          gv_subrc  = 1.
          CONCATENATE 'Customer' lv_kunnr 'already exist in the list.'
          INTO lv_msg SEPARATED BY space.
          MESSAGE lv_msg TYPE 'E'.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDMODULE.                    "T_CONTROL_MODIFY INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'T_CONTROL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE t_control_mark INPUT.
  DATA: g_t_control_wa2 LIKE LINE OF gt_itab.
  IF t_control-line_sel_mode = 1 AND gs_itab-mark = 'X'.
    LOOP AT gt_itab INTO g_t_control_wa2
      WHERE mark = 'X'.
      g_t_control_wa2-mark = ''.
      MODIFY gt_itab
        FROM g_t_control_wa2
        TRANSPORTING mark.
    ENDLOOP.
  ENDIF.
  MODIFY gt_itab
    FROM gs_itab
    INDEX t_control-current_line
    TRANSPORTING mark.
ENDMODULE.                    "T_CONTROL_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'T_CONTROL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE t_control_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'T_CONTROL'
                              'GT_ITAB'
                              'MARK'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "T_CONTROL_USER_COMMAND INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_100  INPUT
*&---------------------------------------------------------------------*
MODULE pai_100 INPUT.
  DATA lv_answer TYPE char1.

  DATA : gt_fieldcat      TYPE lvc_t_fcat,
         gt_filter        TYPE lvc_t_filt WITH HEADER LINE.

  DATA:  l_layout         TYPE lvc_s_layo,
         l_filter_index   TYPE lvc_t_fidx,
         l_selected_cols  TYPE lvc_t_col WITH HEADER LINE.

  CASE sy-ucomm.
    WHEN '&F03' OR '&F15' OR '&F12'.
      PERFORM f_check_changes.
      IF gv_changes IS INITIAL.
        LEAVE TO SCREEN 0.
      ELSE.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            text_question         = 'Data have been changed. Do you want to save?'
            text_button_1         = 'Yes'
            text_button_2         = 'No'
            display_cancel_button = 'X'
          IMPORTING
            answer                = lv_answer
          EXCEPTIONS
            text_not_found        = 1
            OTHERS                = 2.
        IF sy-subrc = 0.
          IF lv_answer = '1'.
            PERFORM f_save_database.
            LEAVE TO SCREEN 0.
          ELSEIF lv_answer = '2'.
            LEAVE TO SCREEN 0.
          ELSE.
            " cancel, keep in this screen
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN '&SAV'.
      IF gv_edit = 'X'.
        PERFORM f_save_database.
        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN '&RNT'.
*      PERFORM f_check_changes.
*      IF gv_changes IS NOT INITIAL.
*        PERFORM f_save_database.
*      ENDIF.
*      PERFORM f_populate_data.
*      PERFORM f_print_form.

    WHEN 'EDT'.
      IF s_datum-low < sy-datum.
      "IF p_datum < sy-datum.
        MESSAGE 'Data cannot be edited because the date is in the past' TYPE 'I'.
        RETURN.
      ENDIF.
      IF gv_edit = 'X'.
        CLEAR gv_edit.
*      PERFORM f_check_changes.
*      IF gv_changes IS INITIAL.
*        CLEAR gv_edit.
*      else.
*        CALL FUNCTION 'POPUP_TO_CONFIRM'
*        EXPORTING
*          text_question         = 'Data have been changed. Do you want to save?'
*          text_button_1         = 'Yes'
*          text_button_2         = 'No'
*          display_cancel_button = 'X'
*        IMPORTING
*          answer                = lv_answer
*        EXCEPTIONS
*          text_not_found        = 1
*          OTHERS                = 2.
*        IF sy-subrc = 0.
*          IF lv_answer = '1'.
*            clear gv_edit.
*          ELSEIF lv_answer = '2'.
*            LEAVE TO SCREEN 0.
*          ELSE.
*            " cancel, keep in this screen
*          ENDIF.
*        ENDIF.
*      endif.
      ELSE.
        gv_edit = 'X'.
      ENDIF.

    WHEN '&ILT'.
      READ TABLE t_control-cols INTO cols WITH KEY selected = 'X'.
      IF sy-subrc = 0.
        l_selected_cols = cols-screen-name+8.
        APPEND l_selected_cols.

        CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
          EXPORTING
            i_structure_name       = 'ZSSUTST014'
          CHANGING
            ct_fieldcat            = gt_fieldcat[]
          EXCEPTIONS
            inconsistent_interface = 1
            program_error          = 2
            OTHERS                 = 99.

        IF sy-subrc = 0.
          CALL FUNCTION 'LVC_FILTER'
            EXPORTING
              i_callback_programm = sy-repid
              it_fieldcat         = gt_fieldcat[]
              it_selected_cols    = l_selected_cols[]
              is_layout           = l_layout
            IMPORTING
              et_filter_index     = l_filter_index
            TABLES
              it_data             = gt_itab[]          "gt_subitems
            CHANGING
              ct_filter           = gt_filter[]
            EXCEPTIONS
              OTHERS              = 0.

          LOOP AT l_selected_cols.
            LOOP AT gt_filter WHERE fieldname = l_selected_cols-fieldname.
              PERFORM f_append_ranges USING l_selected_cols
                                            gt_filter-low
                                            gt_filter-high
                                            gt_filter-sign
                                            gt_filter-option.
            ENDLOOP.
          ENDLOOP.

          PERFORM f_filter_itab1.
        ENDIF.

        CLEAR: gt_filter, gt_filter[], l_selected_cols, l_selected_cols[].
      ENDIF.

    WHEN '&OUP'.
      READ TABLE t_control-cols INTO cols WITH KEY selected = 'X'.
      IF sy-subrc = 0.
        SORT gt_itab STABLE BY (cols-screen-name+8) ASCENDING.
        cols-selected = ' '.
        MODIFY t_control-cols FROM cols INDEX sy-tabix.
      ENDIF.

    WHEN '&ODN'.
      READ TABLE t_control-cols INTO cols WITH KEY selected = 'X'.
      IF sy-subrc = 0.
        SORT gt_itab STABLE BY (cols-screen-name+8) DESCENDING.
        cols-selected = ' '.
        MODIFY t_control-cols FROM cols INDEX sy-tabix.
      ENDIF.

  ENDCASE.
ENDMODULE.                 " PAI_100  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_KUNN2  INPUT
*&---------------------------------------------------------------------*
MODULE f4_kunn2 INPUT.
*  data: lv_sfield(15) type c.
*  data: lv_sline type i.
*  get cursor field lv_sfield line lv_sline.
*  lv_sline = t_control-top_line + lv_sline - 1.

ENDMODULE.                 " F4_KUNN2  INPUT

*&---------------------------------------------------------------------*
*&      Module  F4_KUNNR  INPUT
*&---------------------------------------------------------------------*
MODULE f4_kunnr INPUT.

ENDMODULE.                 " F4_KUNNR  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_RANGES
*&---------------------------------------------------------------------*
FORM f_append_ranges  USING    fu_selected_cols
                               fu_filter_low
                               fu_filter_high
                               fu_filter_sign
                               fu_filter_option.

  CASE fu_selected_cols.
    WHEN 'KUNN2'.
      r_kunn2-low    = fu_filter_low.
      r_kunn2-high   = fu_filter_high.
      r_kunn2-sign   = fu_filter_sign.
      r_kunn2-option = fu_filter_option.
      APPEND r_kunn2.
    WHEN 'KUNNR'.
      r_kunnr-low    = fu_filter_low.
      r_kunnr-high   = fu_filter_high.
      r_kunnr-sign   = fu_filter_sign.
      r_kunnr-option = fu_filter_option.
      APPEND r_kunnr.
    WHEN 'NAME1'.
      r_name1-low    = fu_filter_low.
      r_name1-high   = fu_filter_high.
      r_name1-sign   = fu_filter_sign.
      r_name1-option = fu_filter_option.
      APPEND r_name1.
    WHEN 'ADDRS'.
      r_addrs-low    = fu_filter_low.
      r_addrs-high   = fu_filter_high.
      r_addrs-sign   = fu_filter_sign.
      r_addrs-option = fu_filter_option.
      APPEND r_addrs.
  ENDCASE.
ENDFORM.                    " F_APPEND_RANGES

*&---------------------------------------------------------------------*
*&      Form  F_FILTER_ITAB1
*&---------------------------------------------------------------------*
FORM f_filter_itab1 .
  IF gt_temp1[] IS INITIAL.
    gt_temp1[] = gt_itab[].
  ELSE.
    CLEAR: gt_itab, gt_itab[].
    gt_itab[] = gt_temp1[].
  ENDIF.

  IF r_kunn2[] IS NOT INITIAL.
    DELETE gt_itab WHERE kunn2 NOT IN r_kunn2.
  ENDIF.
  IF r_kunnr[] IS NOT INITIAL.
    DELETE gt_itab WHERE kunnr NOT IN r_kunnr.
  ENDIF.
  IF r_name1[] IS NOT INITIAL.
    DELETE gt_itab WHERE name1 NOT IN r_name1.
  ENDIF.
  IF r_addrs[] IS NOT INITIAL.
    DELETE gt_itab WHERE addrs NOT IN r_addrs.
  ENDIF.

  CLEAR: r_kunn2[], r_kunnr[], r_name1[], r_addrs[].

ENDFORM.                    " F_FILTER_ITAB1

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_OBJECT
*&---------------------------------------------------------------------*
FORM f_lock_object  USING    fu_vkorg fu_vkbur fu_pernr fu_begda fu_daily.
  DATA: lt_028 LIKE zssutdt028 OCCURS 0 WITH HEADER LINE,
        lt_023 LIKE zssutdt023,
        lv_mess(100),
        lv_uname    TYPE sy-uname.


  SELECT SINGLE * INTO lt_023
    FROM zssutdt023
    WHERE vkorg EQ fu_vkorg
      AND vkbur EQ fu_vkbur.
  IF sy-subrc EQ 0.
*    lt_023-daily_call_num = zssutdt025-daily_call_num.
*    MOVE-CORRESPONDING lt_023 TO zssutdt023.
*    MODIFY zssutdt023.
    CALL FUNCTION 'ENQUEUE_EZSSUTDT023'
      EXPORTING
        vkorg          = fu_vkorg
        vkbur          = fu_vkbur
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      STOP.
    ENDIF.
  ELSE.
    lv_mess = 'Gagal mendapatkan nomor DCP' .
    MESSAGE lv_mess TYPE 'E'.
    STOP.
  ENDIF.

  SELECT SINGLE uname
    FROM zssutdt028
    INTO lv_uname
    WHERE vkorg EQ fu_vkorg
      AND vkbur EQ fu_vkbur
      AND pernr EQ fu_pernr
      AND sdate EQ fu_begda
      AND daily_call_num EQ fu_daily.

  IF sy-subrc NE 0.
    lt_028-vkorg  = fu_vkorg.
    lt_028-vkbur  = fu_vkbur.
    lt_028-pernr  = fu_pernr.
    lt_028-sdate  = fu_begda.
    lt_028-daily_call_num  = fu_daily.
    lt_028-uname  = sy-uname.
    APPEND lt_028.
    MODIFY zssutdt028 FROM TABLE lt_028.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_EZSSUTDT028'
    EXPORTING
      vkorg          = fu_vkorg
      vkbur          = fu_vkbur
      pernr          = fu_pernr
      sdate          = fu_begda
      daily_call_num = fu_daily
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  IF sy-subrc NE 0.
    CONCATENATE 'Transaction Lock by' lv_uname INTO lv_mess
    SEPARATED BY space.
    MESSAGE lv_mess TYPE 'E'.
  ENDIF.
ENDFORM.                    " F_LOCK_OBJECT

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_OBJECT
*&---------------------------------------------------------------------*
FORM f_unlock_object  USING    fu_vkorg fu_vkbur fu_pernr fu_begda fu_daily.
  CALL FUNCTION 'DEQUEUE_EZSSUTDT028'
    EXPORTING
      vkorg          = fu_vkorg
      vkbur          = fu_vkbur
      pernr          = fu_pernr
      sdate          = fu_begda
      daily_call_num = fu_daily.

  CALL FUNCTION 'DEQUEUE_EZSSUTDT023'
      EXPORTING
        vkorg          = fu_vkorg
        vkbur          = fu_vkbur.


  DELETE FROM zssutdt028 WHERE vkorg EQ fu_vkorg
                           AND vkbur EQ fu_vkbur
                           AND pernr EQ fu_pernr
                           AND sdate EQ fu_begda
                           AND daily_call_num EQ fu_daily.
ENDFORM.                    " F_UNLOCK_OBJECT
