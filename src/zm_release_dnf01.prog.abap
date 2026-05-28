*----------------------------------------------------------------------*
*   INCLUDE ZM_RELEASE_DNF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  PERFORM f_check_authorization .
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.

  PERFORM f_get_likp.

  PERFORM f_get_lips.

ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  PERFORM f_alv TABLES gt_out.
ENDFORM.                    "F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  PERFORM f_build_event       TABLES  t_alv_event[].
  lv_func    = 'REUSE_ALV_LIST_DISPLAY'.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      i_grid_title             = lv_title
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
      it_sort                  = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      is_print                 = d_print
    TABLES
      t_outtab                 = ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    "F_ALV

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.
  CASE 'X'.
    WHEN p_rel.
      PERFORM f_fieldcatg USING ft_report:
        'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '' '' ,
        'VBELN' '' '' '' '12' 'No. DN' '' '' '' '' '' '' '' '' '' '' ,
        'KUNNR' '' '' '' '15' 'Ship-to Party' '' '' '' '' '' '' '' '' '' '',
        'NAME1' '' '' '' '25' 'Name' '' '' '' '' '' '' '' '' '' '',
        'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LFIMG' 'LIPS' 'LFIMG' '' '' '' '' '' '' '' '' '' 'VRKME' '' '' '',
        'VRKME' 'LIPS' 'VRKME' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MESSAGE' '' '' '' '40' 'Message' '' '' '' '' '' '' '' '' '' ''.
    WHEN p_doc.
      PERFORM f_fieldcatg USING ft_report:
        'VBELN' '' '' '' '12' 'No. DN' '' '' '' '' '' '' '' '' '' '' ,
        'KUNNR' '' '' '' '15' 'Ship-to Party' '' '' '' '' '' '' '' '' '' '',
        'NAME1' '' '' '' '25' 'Name' '' '' '' '' '' '' '' '' '' '',
        'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LFIMG' 'LIPS' 'LFIMG' '' '' '' '' '' '' '' '' '' 'VRKME' '' '' '',
        'VRKME' 'LIPS' 'VRKME' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZRELBY' 'ZMRELDN' 'ZRELBY' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZRELDT' 'ZMRELDN' 'ZRELDT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZRELTM' 'ZMRELDN' 'ZRELTM' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDCASE.
ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*&  Emphasize
*&  - 1st char = C (color property)
*&  - 2nd char = color code (from 0 to 7)
*&    0 = background color
*&    1 = blue
*&    2 = gray
*&    3 = yellow
*&    4 = blue/gray
*&    5 = green
*&    6 = red
*&    7 = orange
*&  - 3rd char = intensified (0=off, 1=on)
*&  - 4th char = inverse display (0=off, 1=on)
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_dec)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_input)
                          value(fu_emphasize).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname       = fu_reftb.
  ld_fieldcat-ref_fieldname     = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-seltext_l         = fu_fltxt.
  ld_fieldcat-seltext_m         = fu_fltxt.
  ld_fieldcat-seltext_s         = fu_fltxt.
  ld_fieldcat-reptext_ddic      = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out      = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-input             = fu_input.
  ld_fieldcat-emphasize         = fu_emphasize.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "F_BUILD_EVENT

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT_EXIT
*---------------------------------------------------------------------*
FORM f_build_event_exit.
  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.
ENDFORM.                    "F_BUILD_EVENT_EXIT

*---------------------------------------------------------------------*
*       FORM F_BUILD_LAYOUT
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
  CASE 'X'.
    WHEN p_rel.
      fu_layout-box_fieldname      = 'CHECK'.
  ENDCASE.
ENDFORM.                    "F_BUILD_LAYOUT

*---------------------------------------------------------------------*
*       FORM F_BUILD_PRINT
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "F_BUILD_PRINT

*---------------------------------------------------------------------*
*       FORM F_BUILD_SORTFIELD
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'VBELN'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "F_BUILD_SORTFIELD

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
  CLEAR: gt_out, gt_out[].
ENDFORM.                    " F_FREE_MEMORY

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_ALV_DATA
*&---------------------------------------------------------------------*
FORM f_clear_alv_data.
  CLEAR:t_alv_fieldcat,
        t_alv_event,
        t_events,
        t_alv_isort,
        t_alv_filter,
        t_event_exit,
        d_alv_isort,
        d_alv_variant,
        d_alv_list_scroll,
        d_alv_sort_postn,
        d_alv_keyinfo,
        d_alv_fieldcat,
        d_alv_formname,
        d_alv_ucomm,
        d_alv_print,
        d_alv_repid,
        d_alv_tabix,
        d_alv_subrc,
        d_alv_screen_start_column,
        d_alv_screen_start_line,
        d_alv_screen_end_column,
        d_alv_screen_end_line,
        d_alv_layout,
        d_layout,
        d_repid,
        d_print.

  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.
ENDFORM.                    " F_CLEAR_ALV_DATA

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  CASE 'X'.
    WHEN p_rel.
      SET PF-STATUS 'TOEXECUTE'.
    WHEN p_doc.
      SET PF-STATUS 'STANDARD'.
  ENDCASE.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM F_GUI_MESSAGE
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "F_GUI_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.
  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
    fc_alv_variant-report = d_repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = fc_alv_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      IF NOT sy-msgid IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR fc_alv_variant.
    fc_alv_variant-report = sy-repid.
  ENDIF.
ENDFORM.                    " F_ALV_VARIANT_EXIST

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data.
  DATA: lv_date(10).

  SORT gt_likp BY vbeln.
  SORT gt_lips BY vbeln posnr.
  SORT gt_vbuk BY vbeln.
  SORT gt_zmreldn BY vbeln.

  LOOP AT gt_likp.
    READ TABLE gt_vbuk WITH KEY vbeln = gt_likp-vbeln.
    IF sy-subrc EQ 0.
      CONTINUE.
    ELSE.
      READ TABLE gt_zmreldn WITH KEY vbeln = gt_likp-vbeln
                            BINARY SEARCH.
      IF sy-subrc EQ 0.
        gt_out-icon = icon_led_red.
        WRITE gt_zmreldn-zreldt TO lv_date DD/MM/YYYY.
        CONCATENATE 'DN Sudah di release tanggal' lv_date
        INTO gt_out-message
        SEPARATED BY space.
        gt_out-zrelby = gt_zmreldn-zrelby.
        gt_out-zreldt = gt_zmreldn-zreldt.
        gt_out-zreltm = gt_zmreldn-zreltm.
      ELSE.
        gt_out-icon = icon_led_green.
        CLEAR: gt_out-message, gt_out-zrelby, gt_out-zreldt, gt_out-zreltm.
      ENDIF.

      gt_out-vbeln  = gt_likp-vbeln.
      gt_out-kunnr  = gt_likp-kunnr.
      READ TABLE gt_kna1 WITH KEY kunnr = gt_likp-kunnr.
      IF sy-subrc EQ 0.
        gt_out-name1  = gt_kna1-name1.
      ENDIF.
      CLEAR gt_out-check.

      LOOP AT gt_lips WHERE vbeln EQ gt_likp-vbeln.
        gt_out-matnr  = gt_lips-matnr.
        READ TABLE gt_mara WITH KEY matnr = gt_lips-matnr.
        IF sy-subrc EQ 0.
          gt_out-maktx  = gt_mara-maktx.
        ELSE.
          CONTINUE.
        ENDIF.
        gt_out-lfimg  = gt_lips-lfimg + gt_lips-kcmeng.
        gt_out-vrkme  = gt_lips-vrkme.
        APPEND gt_out.
        IF gt_out-check IS INITIAL.
          gt_out-check  = '2'.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE,
        lv_vbeln       TYPE vbeln_vl.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.

    WHEN '&IC1'.
      IF fu_selfield-value IS NOT INITIAL.
        CASE fu_selfield-sel_tab_field.
          WHEN 'GT_OUT-VBELN'.
            lv_vbeln  = fu_selfield-value.
            SET PARAMETER ID 'VL' FIELD lv_vbeln.
            CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
        ENDCASE.
      ENDIF.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.
  DATA: lt_out  LIKE gt_out OCCURS 0 WITH HEADER LINE,
        lt_save LIKE zmreldn OCCURS 0 WITH HEADER LINE.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE check NE 'X'
                   OR icon EQ icon_led_red.

  LOOP AT lt_out.
    lt_save-vbeln  = lt_out-vbeln.
    lt_save-zrelby = sy-uname.
    lt_save-zreldt = sy-datum.
    lt_save-zreltm = sy-uzeit.
    APPEND lt_save.
  ENDLOOP.

  IF lt_save[] IS NOT INITIAL.
    INSERT zmreldn FROM TABLE lt_save.
    MESSAGE s000(zab) WITH 'Data already processed'.
    LEAVE TO SCREEN 0.
  ELSE.
    MESSAGE e000(zab) WITH 'No data to execute'.
  ENDIF.
ENDFORM.                    " F_POST_ENTRIES

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
FORM f_f4_for_variant_alv CHANGING fc_variant.
  DATA: ld_variant LIKE disvariant.
  DATA: ld_repid   LIKE sy-repid.

  ld_repid = sy-repid.
  ld_variant-report   = ld_repid.
  ld_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ld_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ld_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    fc_variant = ld_variant-variant.
  ENDIF.
ENDFORM.                    " F_F4_FOR_VARIANT_ALV

*&---------------------------------------------------------------------*
*&      Form  F_GET_PARAMETERS
*&---------------------------------------------------------------------*
FORM f_get_parameters  USING    fu_value
                       CHANGING fc_value.
  CALL FUNCTION 'ACC_USER_PARAMETER_GET'
    EXPORTING
      i_param_id    = fu_value
    IMPORTING
      e_param_value = fc_value.
ENDFORM.                    " F_GET_PARAMETERS

*&---------------------------------------------------------------------*
*&      Form  F_GET_LIKP
*&---------------------------------------------------------------------*
FORM f_get_likp  .

  DATA: lt_likp   LIKE gt_likp OCCURS 0 WITH HEADER LINE.

  SELECT vbeln vstel vkorg kunnr lfart
    FROM likp
    INTO TABLE gt_likp
    WHERE vbeln IN so_vbeln
      AND erdat IN so_erdat
      AND vstel EQ pa_vstel
      AND vkorg EQ pa_bukrs.
  "AND lfart IN so_lfart.

  IF gt_likp[] IS NOT INITIAL.
    SELECT vbeln zrelby zreldt zreltm
      FROM zmreldn
      INTO CORRESPONDING FIELDS OF TABLE gt_zmreldn
      FOR ALL ENTRIES IN gt_likp
      WHERE vbeln EQ gt_likp-vbeln.

    SELECT vbeln wbstk
      FROM vbuk
      INTO TABLE gt_vbuk
      FOR ALL ENTRIES IN gt_likp
      WHERE vbeln EQ gt_likp-vbeln
        AND wbstk EQ 'C'.
  ENDIF.

  lt_likp[] = gt_likp[].
  SORT lt_likp BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_likp COMPARING kunnr.
  IF lt_likp[] IS NOT INITIAL.
    SELECT kunnr name1
      FROM kna1
      INTO TABLE gt_kna1
      FOR ALL ENTRIES IN lt_likp
      WHERE kunnr EQ lt_likp-kunnr.
  ENDIF.
ENDFORM.                    " F_GET_LIKP

*&---------------------------------------------------------------------*
*&      Form  F_GET_LIPS
*&---------------------------------------------------------------------*
FORM f_get_lips  .
  DATA: lt_lips LIKE gt_lips OCCURS 0 WITH HEADER LINE.
  DATA: lt_likp LIKE gt_likp OCCURS 0 WITH HEADER LINE.
  DATA: lt_mvke TYPE TABLE OF mvke.

  IF gt_likp[] IS NOT INITIAL.
    lt_likp[] = gt_likp[].
    DELETE lt_likp WHERE lfart NE 'ZSFK'.
    IF lt_likp[] IS NOT INITIAL.
      SELECT vbeln posnr matnr lfimg vrkme kcmeng
        FROM lips
        INTO TABLE gt_lips
        FOR ALL ENTRIES IN lt_likp
        WHERE vbeln EQ lt_likp-vbeln
          AND fkrel EQ space.
    ENDIF.
    lt_likp[] = gt_likp[].
    DELETE lt_likp WHERE lfart EQ 'ZSFK'.
    IF lt_likp[] IS NOT INITIAL.
      SELECT vbeln posnr matnr lfimg vrkme kcmeng
        FROM lips
        APPENDING TABLE gt_lips
        FOR ALL ENTRIES IN lt_likp
        WHERE vbeln EQ lt_likp-vbeln
          AND fkrel NE space.
    ENDIF.

    lt_lips[] = gt_lips[].
    SORT lt_lips BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_lips COMPARING matnr.
    IF lt_lips[] IS NOT INITIAL.
      IF gv_alkes IS INITIAL.
        SELECT * INTO TABLE lt_mvke
          FROM mvke FOR ALL ENTRIES IN lt_lips
          WHERE matnr = lt_lips-matnr
            AND vkorg = pa_bukrs
            AND vtweg = '10'
            AND mvgr1 NE '04'.
        IF lt_mvke[] IS NOT INITIAL.
          SELECT mara~matnr maktx
            FROM mara JOIN makt ON mara~matnr EQ makt~matnr
            INTO TABLE gt_mara
            FOR ALL ENTRIES IN lt_mvke
            WHERE mara~matnr EQ lt_mvke-matnr
              AND spras EQ sy-langu
              AND mtart EQ 'ZPHA'.
        ENDIF.
      ELSE.
        SELECT * INTO TABLE lt_mvke
          FROM mvke FOR ALL ENTRIES IN lt_lips
          WHERE matnr = lt_lips-matnr
            AND vkorg = pa_bukrs
            AND vtweg = '10'
            AND mvgr1 = '04'.
        IF lt_mvke[] IS NOT INITIAL.
          SELECT mara~matnr maktx
            FROM mara JOIN makt ON mara~matnr EQ makt~matnr
            INTO TABLE gt_mara
            FOR ALL ENTRIES IN lt_mvke
            WHERE mara~matnr EQ lt_mvke-matnr
              AND spras EQ sy-langu.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_LIPS

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .

ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF pa_bukrs IS INITIAL.
    PERFORM f_error_selection_screen USING 'BUK' '0'.
  ENDIF.

  IF pa_vstel IS INITIAL.
    PERFORM f_error_selection_screen USING 'VST' '0'.
  ENDIF.

*  IF so_erdat[] IS INITIAL.
*    PERFORM f_error_selection_screen USING 'ERD' '0'.
*  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
  ENDCASE.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_SELECTION_SCREE

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_AUTHORIZATION
*&---------------------------------------------------------------------*
FORM f_check_authorization .
  DATA : return     TYPE STANDARD TABLE OF bapiret2,
         groups     TYPE STANDARD TABLE OF bapigroups,
         ls_groups  LIKE LINE OF groups.

  DATA : lv_check.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    TABLES
      return   = return
      groups   = groups.

  LOOP AT groups INTO ls_groups.
    IF ls_groups-usergroup(3) = 'TDS'.
      lv_check = 4.
    ENDIF.
  ENDLOOP.

  IF lv_check IS INITIAL.
    AUTHORITY-CHECK OBJECT 'ZMMPJA_PST'
        ID 'ACTVT' FIELD '01'.
    IF sy-subrc = 0.
      gv_alkes  = 'X'.
*  ELSE.
*    AUTHORITY-CHECK OBJECT 'ZMMPJA_CX'
*        ID 'ACTVT' FIELD '43'.
*    IF sy-subrc = 0.
*      gv_alkes  = 'X'.
*    ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_AUTHORIZATION
