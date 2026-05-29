*----------------------------------------------------------------------*
*   INCLUDE ZQM_QE51NF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA : low(10),
         high(10).

  SELECT SINGLE name1
    FROM t001w
    INTO gv_headl1
    WHERE werks = pa_werks.

  CONCATENATE pa_werks '-' gv_headl1 INTO gv_headl1
  SEPARATED BY space.

  SELECT SINGLE maktx
    FROM makt
    INTO gv_headl2
    WHERE matnr = pa_matnr.

  CONCATENATE pa_matnr '-' gv_headl2 INTO gv_headl2
  SEPARATED BY space.

  WRITE so_erste-low TO low DD/MM/YYYY.
  WRITE so_erste-high TO high DD/MM/YYYY.

  CONCATENATE low '-' high INTO gv_headl3
  SEPARATED BY space.

  SELECT SINGLE kurztext
    FROM qpmt
    INTO gv_headl4
    WHERE zaehler = pa_werks
      AND mkmnr   = pa_verwm
      AND version = '000001'.

  CONCATENATE pa_verwm '-' gv_headl4
  INTO gv_headl4
  SEPARATED BY space.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA : char_requirements    LIKE bapi2045d1 OCCURS 0 WITH HEADER LINE,
         sample_results       LIKE bapi2045d3 OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF lt_key OCCURS 0,
           prueflos   TYPE qplos,
           vorglfnr   TYPE qlfnkn,
           merknr     TYPE qmerknrp,
         END OF lt_key.

  DATA : BEGIN OF lt_rec OCCURS 0,
           prueflos   TYPE qplos,
           count      TYPE i,
         END OF lt_rec.

  DATA : lt_qasr  LIKE gt_qasr OCCURS 0 WITH HEADER LINE,
         ls_qase  LIKE LINE OF gt_qase.

  SELECT SINGLE maktx
    FROM makt
    INTO gv_maktx
    WHERE matnr EQ pa_matnr
      AND spras EQ sy-langu.

  CASE pa_werks.
    WHEN '0401'.
      SELECT prueflos matnr charg objnr plnty plnnr plnal aufpl
        FROM qals
        INTO TABLE gt_qals
        WHERE werk      EQ pa_werks
*          AND herkunft  EQ '09'
          AND charg     IN so_charg
          AND matnr     EQ pa_matnr
          AND ersteldat IN so_erste.
    WHEN OTHERS.
      SELECT prueflos matnr charg objnr plnty plnnr plnal aufpl
        FROM qals
        INTO TABLE gt_qals
        WHERE werk      EQ pa_werks
          AND art       EQ '03'
          AND charg     IN so_charg
          AND matnr     EQ pa_matnr
          AND ersteldat IN so_erste
          AND plnty     EQ '2'.
  ENDCASE.

  PERFORM f_validate_system_status USING 'REC' 'RREC'.

  CHECK gt_qals[] IS NOT INITIAL.

  SELECT *
    FROM plmk
    INTO CORRESPONDING FIELDS OF TABLE gt_plmk
    FOR ALL ENTRIES IN gt_qals
    WHERE plnty     = gt_qals-plnty
      AND plnnr     = gt_qals-plnnr
      AND verwmerkm = pa_verwm.

  CHECK gt_plmk[] IS NOT INITIAL.

  CASE pa_werks.
    WHEN '0401'.
      SELECT plnty plnnr plnkn zaehl vornr steus phflg ltxa1
        FROM plpo
        INTO TABLE gt_plpo
        FOR ALL ENTRIES IN gt_plmk
        WHERE plnty = gt_plmk-plnty
          AND plnnr = gt_plmk-plnnr
          AND plnkn = gt_plmk-plnkn.
    WHEN OTHERS.
      SELECT plnty plnnr plnkn zaehl vornr steus phflg ltxa1
        FROM plpo
        INTO TABLE gt_plpo
        FOR ALL ENTRIES IN gt_plmk
        WHERE plnty = gt_plmk-plnty
          AND plnnr = gt_plmk-plnnr
          AND plnkn = gt_plmk-plnkn
          AND steus = 'ZQ01'
          AND phflg = 'X'.
  ENDCASE.

  LOOP AT gt_qals.
    LOOP AT gt_plmk WHERE plnty = gt_qals-plnty
                      AND plnnr = gt_qals-plnnr.
      lt_key-prueflos   = gt_qals-prueflos.
      lt_key-merknr     = gt_plmk-merknr.
      LOOP AT gt_plpo WHERE plnty = gt_plmk-plnty
                        AND plnnr = gt_plmk-plnnr
                        AND plnkn = gt_plmk-plnkn.
        CALL FUNCTION 'QIBP_GET_VORGLFNR'
          EXPORTING
            i_insp_lot           = gt_qals-prueflos
            i_oper_no            = gt_plpo-vornr
          IMPORTING
            e_vorglfnr           = lt_key-vorglfnr
          EXCEPTIONS
            wrong_inspection_lot = 1
            wrong_operation_no   = 2
            OTHERS               = 3.
        IF sy-subrc = 0.
          APPEND lt_key.
        ENDIF.
      ENDLOOP.
      CLEAR lt_key.
    ENDLOOP.
  ENDLOOP.
  SORT lt_key BY prueflos vorglfnr merknr.
  DELETE ADJACENT DUPLICATES FROM lt_key COMPARING ALL FIELDS.

  CHECK lt_key[] IS NOT INITIAL.

  READ TABLE gt_plmk INDEX 1.
  IF sy-subrc = 0.
    gv_katalgart1 = gt_plmk-katalgart1.
  ENDIF.

  IF gv_katalgart1 = '1'.
* Result for Qualitative --> QASR
    SELECT prueflos vorglfnr merknr probenr katalgart1
           gruppe1 code1 original_input
      FROM qasr
      INTO TABLE gt_qasr
      FOR ALL ENTRIES IN lt_key
      WHERE prueflos  = lt_key-prueflos
        AND vorglfnr  = lt_key-vorglfnr
        AND merknr    = lt_key-merknr.

    lt_qasr[] = gt_qasr[].
    SORT lt_qasr BY katalgart1 gruppe1 code1.
    DELETE ADJACENT DUPLICATES FROM lt_qasr
    COMPARING katalgart1 gruppe1 code1.

    CHECK lt_qasr[] IS NOT INITIAL.

    SELECT katalogart codegruppe code kurztext
      FROM qpct
      INTO TABLE gt_qpct
      FOR ALL ENTRIES IN lt_qasr
      WHERE katalogart  = lt_qasr-katalgart1
        AND codegruppe  = lt_qasr-gruppe1
        AND code        = lt_qasr-code1
        AND sprache     = sy-langu.

    SORT gt_qasr BY prueflos.
    LOOP AT gt_qasr.
      lt_rec-prueflos = gt_qasr-prueflos.
      lt_rec-count    = 1.
      COLLECT lt_rec.
    ENDLOOP.
  ELSE.
* Result for Quantitative --> QASE
    SELECT *
      FROM qase
      INTO CORRESPONDING FIELDS OF TABLE gt_qase
      FOR ALL ENTRIES IN lt_key
      WHERE prueflos  = lt_key-prueflos
        AND vorglfnr  = lt_key-vorglfnr
        AND merknr    = lt_key-merknr.

    SORT gt_qase BY prueflos.
    LOOP AT gt_qase INTO ls_qase.
      lt_rec-prueflos = ls_qase-prueflos.
      lt_rec-count    = 1.
      COLLECT lt_rec.
    ENDLOOP.
  ENDIF.

  SORT lt_rec BY count DESCENDING.
  READ TABLE lt_rec INDEX 1.
  gv_rec  = lt_rec-count.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  DATA : lv_title    TYPE lvc_title.

  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_layout      USING   d_layout.
*  PERFORM f_comment_build     USING   gt_list_top_of_page[].

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout                = d_layout
      it_fieldcat              = gt_alv_fieldcat
      it_sort                  = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      is_print                 = d_print
    TABLES
      t_outtab                 = <fs_itab>.

*  PERFORM f_alv TABLES <fs_itab>.
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
  PERFORM f_fieldcatg USING ft_report:
    'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' ''.
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
  fu_layout-box_fieldname      = 'CHECK'.
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
  ld_sort-fieldname = 'PRUEFLOS'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'CHARG'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "F_BUILD_SORTFIELD

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
*  PERFORM f_hdr_uline.
*  PERFORM f_hdr_line1 USING sy-title.
*  PERFORM f_hdr_line2 USING ''.
*  PERFORM f_hdr_line3 USING ''.
*  PERFORM f_hdr_uline.

*  WRITE : / sy-title.
*  SKIP 1.
*  WRITE : / gv_headl1.
*  WRITE : / gv_headl2.
*  WRITE : / gv_headl3.
*  WRITE : / gv_headl4.
*  SKIP 1.

  DATA: ls_line      TYPE slis_listheader,
        ihead        TYPE slis_t_listheader.

  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = sy-title.
  APPEND ls_line TO ihead.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key  = 'Plant'.
  ls_line-info = gv_headl1.
  APPEND ls_line TO ihead.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key  = 'Material'.
  ls_line-info = gv_headl2.
  APPEND ls_line TO ihead.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key  = 'Period'.
  ls_line-info = gv_headl3.
  APPEND ls_line TO ihead.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-info = gv_headl4.
  ls_line-key  = 'Master insp.charac.'.
  APPEND ls_line TO ihead.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = ihead.
  REFRESH ihead.
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
  SET PF-STATUS 'STANDARD'.
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
  DATA : lv_fieldname   TYPE lvc_fname,
         lv_count       TYPE qstipronr,
         lv_subrc       TYPE sy-subrc,
         lv_mittelwert(25).

  DATA : ls_qase  LIKE LINE OF gt_qase.

  SORT gt_qasr BY prueflos vorglfnr merknr probenr.
  SORT gt_qase BY prueflos detailerg.

  LOOP AT gt_qals.
    lv_subrc  = 4.
    ASSIGN COMPONENT 'PRUEFLOS' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field>  = gt_qals-prueflos.

    ASSIGN COMPONENT 'CHARG' OF STRUCTURE <fs_wa> TO <fs_field>.
    <fs_field>  = gt_qals-charg.

    LOOP AT gt_plpo WHERE plnty = gt_qals-plnty
                      AND plnnr = gt_qals-plnnr.
      ASSIGN COMPONENT 'VORNR' OF STRUCTURE <fs_wa> TO <fs_field>.
      <fs_field>  = gt_plpo-vornr.
      ASSIGN COMPONENT 'LTXA1' OF STRUCTURE <fs_wa> TO <fs_field>.
      <fs_field>  = gt_plpo-ltxa1.

      IF gv_katalgart1 = '1'.
        LOOP AT gt_qasr WHERE prueflos = gt_qals-prueflos.
          ADD 1 TO lv_count.
          CONCATENATE 'OI' lv_count INTO lv_fieldname.
          READ TABLE gt_qpct WITH KEY katalogart  = gt_qasr-katalgart1
                                      codegruppe  = gt_qasr-gruppe1
                                      code        = gt_qasr-code1.
          IF sy-subrc = 0.
*            CONCATENATE gt_qasr-original_input gt_qpct-kurztext
            CONCATENATE gt_qasr-code1 gt_qpct-kurztext
            INTO gt_qasr-original_input
            SEPARATED BY space.
          ENDIF.

          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_wa> TO <fs_field>.
          PERFORM f_conversion_char_num USING gt_qasr-original_input.

          CONCATENATE 'MEINS' lv_count INTO lv_fieldname.
          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_wa> TO <fs_field>.
          <fs_field> = 'X'.
        ENDLOOP.
      ELSE.
        LOOP AT gt_qase INTO ls_qase WHERE prueflos = gt_qals-prueflos.
          ADD 1 TO lv_count.
          CONCATENATE 'OI' lv_count INTO lv_fieldname.
          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_wa> TO <fs_field>.
          CONDENSE ls_qase-original_input NO-GAPS.
          PERFORM f_conversion_char_num USING ls_qase-original_input.

          CONCATENATE 'MEINS' lv_count INTO lv_fieldname.
          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_wa> TO <fs_field>.
          <fs_field> = 'X'.
        ENDLOOP.
      ENDIF.

      APPEND <fs_wa> TO <fs_itab>.
      CLEAR : <fs_wa>, lv_count.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.

    WHEN '&SINGLE'.
      PERFORM f_single_chart.

    WHEN '&MEAN'.
      PERFORM f_mean_chart.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.

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
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .

ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA : lv_erste   TYPE sy-datum.

  IF pa_werks IS INITIAL.
    PERFORM f_error_selection_screen USING 'WER' ''.
  ENDIF.

  IF pa_matnr IS INITIAL.
    PERFORM f_error_selection_screen USING 'MAT' ''.
  ENDIF.

  IF pa_verwm IS INITIAL.
    PERFORM f_error_selection_screen USING 'VER' ''.
  ENDIF.

  IF so_erste[] IS INITIAL.
    PERFORM f_error_selection_screen USING 'ERS' ''.
  ELSE.
    lv_erste  = so_erste-low.

    DO 12 TIMES.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = lv_erste
        IMPORTING
          last_day_of_month = lv_erste
        EXCEPTIONS
          day_in_no_date    = 1
          OTHERS            = 2.
      lv_erste = lv_erste + 1.
    ENDDO.

    IF so_erste-high IS NOT INITIAL.
      IF so_erste-high >= lv_erste.
        PERFORM f_error_selection_screen USING 'ERS' '1'.
      ENDIF.
    ELSE.
      so_erste-high   = lv_erste.
      so_erste-option = 'BT'.
      MODIFY so_erste INDEX 1 TRANSPORTING high option.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_CRT_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_crt_dyn_int_table .
  DATA : lv_pos      TYPE i,
         lv_count    TYPE qstipronr,
         lv_coltext  TYPE qstipronr.

  lv_pos = lv_pos + 1.
  PERFORM f_fieldname USING :
    'CHECK' '' '' '' '' '' 'X' 'X',
    'PRUEFLOS' 'PRUEFLOS' 'QALS' '' '' '' '' '',
    'CHARG' 'CHARG' 'QALS' '' '' '' '' '',
    'VORNR' 'VORNR' 'PLPO' '' '' '' '' '',
    'LTXA1' '' '' '40' 'Operation' '' '' ''.

  CLEAR gw_dyn_fcat.

  DO gv_rec TIMES.
    ADD 1 TO lv_count.
    CONCATENATE 'OI' lv_count INTO gw_dyn_fcat-fieldname.
    lv_coltext = lv_count.
    SHIFT lv_coltext LEFT DELETING LEADING '0'.
    CONCATENATE 'Sample' lv_coltext INTO gw_dyn_fcat-coltext
    SEPARATED BY space.
    gw_dyn_fcat-datatype  = 'QUAN'.
    CONCATENATE 'MEINS' lv_count INTO gw_dyn_fcat-qfieldname.
    APPEND gw_dyn_fcat TO gt_dyn_fcat.
    CLEAR gw_dyn_fcat.

    CONCATENATE 'MEINS' lv_count INTO gw_dyn_fcat-fieldname.
    gw_dyn_fcat-no_out  = 'X'.
    APPEND gw_dyn_fcat TO gt_dyn_fcat.
    CLEAR gw_dyn_fcat.
  ENDDO.

  CLEAR gw_dyn_fcat.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      i_style_table             = 'X'
      it_fieldcatalog           = gt_dyn_fcat
* Begin remark unicode coversion - DEVK966054
* 18.03.2020 - sol chirka
      i_length_in_byte          = 'X'
* End insert Unicode conversion - DEVK966054
    IMPORTING
      ep_table                  = gt_dyn_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.

  IF sy-subrc EQ 0.
* Assign the new table to field symbol
    ASSIGN gt_dyn_table->* TO <fs_itab>.
* Create dynamic work area for the dynamic table
    CREATE DATA gw_line LIKE LINE OF <fs_itab>.
    ASSIGN gw_line->* TO <fs_wa>.
  ENDIF.

  CLEAR lv_pos.

  LOOP AT gt_dyn_fcat INTO gw_dyn_fcat.
    lv_pos = lv_pos + 1.
    gw_alv_fieldcat-fieldname     = gw_dyn_fcat-fieldname.
    gw_alv_fieldcat-tabname       = gw_dyn_fcat-tabname.
    gw_alv_fieldcat-seltext_l     = gw_dyn_fcat-coltext.
    gw_alv_fieldcat-outputlen     = gw_dyn_fcat-outputlen.
    gw_alv_fieldcat-col_pos       = lv_pos.
    gw_alv_fieldcat-do_sum        = gw_dyn_fcat-do_sum.
    gw_alv_fieldcat-emphasize     = gw_dyn_fcat-emphasize.
    gw_alv_fieldcat-key           = gw_dyn_fcat-key.
    gw_alv_fieldcat-no_out        = gw_dyn_fcat-no_out.
    gw_alv_fieldcat-ref_fieldname = gw_dyn_fcat-ref_field.
    gw_alv_fieldcat-ref_tabname   = gw_dyn_fcat-ref_table.
    gw_alv_fieldcat-inttype       = gw_dyn_fcat-inttype.
    gw_alv_fieldcat-decimals_out  = gw_dyn_fcat-decimals_o.
    gw_alv_fieldcat-qfieldname    = gw_dyn_fcat-qfieldname.
    gw_alv_fieldcat-checkbox      = gw_dyn_fcat-checkbox.
    APPEND gw_alv_fieldcat TO gt_alv_fieldcat.
  ENDLOOP.
ENDFORM.                    " F_CRT_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_FIELDNAME
*&---------------------------------------------------------------------*
FORM f_fieldname  USING    fu_fieldname
                           fu_ref_field
                           fu_ref_table
                           fu_outputlen
                           fu_coltext
                           fu_col_pos
                           fu_checkbox
                           fu_noout.

  gw_dyn_fcat-fieldname   = fu_fieldname.
  gw_dyn_fcat-ref_field   = fu_ref_field.
  gw_dyn_fcat-ref_table   = fu_ref_table.
  gw_dyn_fcat-outputlen   = fu_outputlen.
  gw_dyn_fcat-coltext     = fu_coltext.
  gw_dyn_fcat-col_pos     = fu_col_pos.
  gw_dyn_fcat-checkbox    = fu_checkbox.
  gw_dyn_fcat-no_out      = fu_noout.
*  gw_dyn_fcat-key         = 'X'.
*  gw_dyn_fcat-key_sel     = 'X'.
  APPEND gw_dyn_fcat TO gt_dyn_fcat.

ENDFORM.                    " F_FIELDNAME

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
    WHEN '1'.
      lv_mess = 'Lot created on only for 1 year'.
  ENDCASE.

  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SYSTEM_STATUS
*&---------------------------------------------------------------------*
FORM f_validate_system_status  USING    fu_sts01 fu_sts02.

  DATA : BEGIN OF lt_jest OCCURS 0,
           objnr    TYPE j_objnr,
           stat     TYPE j_status,
           txt04    TYPE j_txt04,
         END OF lt_jest.

  DATA : lv_count   TYPE int4.

  IF gt_qals[] IS NOT INITIAL.
    SELECT objnr stat txt04
      FROM jest JOIN tj02t ON jest~stat = tj02t~istat
      INTO CORRESPONDING FIELDS OF TABLE lt_jest
      FOR ALL ENTRIES IN gt_qals
      WHERE objnr   = gt_qals-objnr
        AND inact   = space
        AND spras   = sy-langu.
  ENDIF.

  LOOP AT gt_qals.
    CLEAR lv_count.
    LOOP AT lt_jest WHERE objnr = gt_qals-objnr.
      CASE lt_jest-txt04.
        WHEN fu_sts01.
          ADD 1 TO lv_count.
        WHEN fu_sts02.
          ADD 1 TO lv_count.
      ENDCASE.
    ENDLOOP.
    IF lv_count > 2.
      DELETE gt_qals.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_VALIDATE_SYSTEM_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM f_comment_build  USING    fu_title TYPE slis_t_listheader.

ENDFORM.                    " F_COMMENT_BUILD

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_CHAR_NUM
*&---------------------------------------------------------------------*
FORM f_conversion_char_num  USING    fu_input.
  DATA: lv_num    TYPE z19_3.

  CALL FUNCTION 'MOVE_CHAR_TO_NUM'
    EXPORTING
      chr             = fu_input
    IMPORTING
      num             = lv_num
    EXCEPTIONS
      convt_no_number = 1
      convt_overflow  = 2
      OTHERS          = 3.

  IF sy-subrc = 0.
    <fs_field> = lv_num.
  ELSE.
    <fs_field> = fu_input.
  ENDIF.
ENDFORM.                    " F_CONVERSION_CHAR_NUM

*&---------------------------------------------------------------------*
*&      Form  F_SINGLE_CHART
*&---------------------------------------------------------------------*
FORM f_single_chart .
  DATA : lt_qase  TYPE STANDARD TABLE OF qase INITIAL SIZE 0,
         ls_qase  LIKE LINE OF gt_qase,
         ls_qamv  TYPE qamv,
         l_graphics_still_active TYPE qm00-qkz.

  LOOP AT <fs_itab> ASSIGNING <fs_wa>.
    ASSIGN COMPONENT 'CHECK' OF STRUCTURE <fs_wa> TO <fs_field>.
    IF <fs_field> IS NOT INITIAL.
      ASSIGN COMPONENT 'PRUEFLOS' OF STRUCTURE <fs_wa> TO <fs_field>.
      LOOP AT gt_qase INTO ls_qase WHERE prueflos = <fs_field>.
        APPEND ls_qase TO lt_qase.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  SORT lt_qase BY prueflos DESCENDING.
  READ TABLE lt_qase INTO ls_qase INDEX 1.
  IF sy-subrc = 0.
    SELECT SINGLE *
      FROM qamv
      INTO CORRESPONDING FIELDS OF ls_qamv
      WHERE prueflos = ls_qase-prueflos
        AND vorglfnr = ls_qase-vorglfnr
        AND merknr   = ls_qase-merknr.
  ENDIF.

  CALL FUNCTION 'QEGR_RUN_CHART_FOR_QASE'
    EXPORTING
      i_merknr                = ls_qamv-merknr
      i_kurztext              = ls_qamv-kurztext
      i_ktextmat              = gv_maktx
      i_masseinhsw3           = ls_qamv-masseinhsw
      i_stellen               = ls_qamv-stellen
      i_tolobni               = ls_qamv-tolobni
      i_toleranzob            = ls_qamv-toleranzob
      i_sollwni               = ls_qamv-sollwni
      i_sollwert              = ls_qamv-sollwert
      i_tolunni               = ls_qamv-tolunni
      i_toleranzun            = ls_qamv-toleranzun
    IMPORTING
      e_graphics_still_active = l_graphics_still_active
    TABLES
      t_qasetab               = lt_qase
    EXCEPTIONS
      missing_data            = 1
      inconsistent_data       = 2
      programming_error       = 3
      OTHERS                  = 4.
ENDFORM.                    " F_SINGLE_CHART

*&---------------------------------------------------------------------*
*&      Form  F_MEAN_CHART
*&---------------------------------------------------------------------*
FORM f_mean_chart .
  TYPES BEGIN OF t_mk_out.
  INCLUDE      STRUCTURE qgmk.
  TYPES :   decimals_out          TYPE slis_fieldcat_alv-decimals_out,
            dec_stat_out          TYPE slis_fieldcat_alv-decimals_out,
            dec_stat_inpproc_out  TYPE slis_fieldcat_alv-decimals_out,
            lights,
            selected,
         END OF t_mk_out.

  DATA : lt_qase  TYPE STANDARD TABLE OF qase INITIAL SIZE 0.

  DATA : l_xgraphics_still_active LIKE qm00-qkz.

  DATA : p_mk_outtab  TYPE STANDARD TABLE OF t_mk_out INITIAL SIZE 0,
         p_qgmk       LIKE LINE OF p_mk_outtab,
         l_qgmk_tab   LIKE qgmk OCCURS 0,
         l_qgmk       LIKE qgmk.

  lt_qase[] = gt_qase[].
  SORT lt_qase BY prueflos vorglfnr merknr.
  DELETE ADJACENT DUPLICATES FROM lt_qase COMPARING prueflos vorglfnr merknr.

  IF lt_qase[] IS NOT INITIAL.
    SELECT *
      FROM qamv INNER JOIN qamr
      ON qamv~prueflos = qamr~prueflos AND
         qamv~vorglfnr = qamr~vorglfnr AND
         qamv~merknr   = qamr~merknr
                INNER JOIN qasv
      ON qamv~prueflos = qasv~prueflos AND
         qamv~vorglfnr = qasv~vorglfnr AND
         qamv~merknr   = qasv~merknr
                INNER JOIN qals
      ON qamv~prueflos = qals~prueflos
      INTO CORRESPONDING FIELDS OF TABLE p_mk_outtab
      FOR ALL ENTRIES IN lt_qase
      WHERE qamv~prueflos EQ lt_qase-prueflos
        AND qamv~vorglfnr EQ lt_qase-vorglfnr
        AND qamv~merknr   EQ lt_qase-merknr
        AND qasv~probenr  EQ '000000'.
  ENDIF.

  LOOP AT <fs_itab> ASSIGNING <fs_wa>.
    ASSIGN COMPONENT 'CHECK' OF STRUCTURE <fs_wa> TO <fs_field>.
    IF <fs_field> IS NOT INITIAL.
      ASSIGN COMPONENT 'PRUEFLOS' OF STRUCTURE <fs_wa> TO <fs_field>.
      LOOP AT p_mk_outtab INTO p_qgmk WHERE prueflos = <fs_field>.
        APPEND p_qgmk TO l_qgmk_tab.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  SORT l_qgmk_tab BY prueflos DESCENDING.
  READ TABLE l_qgmk_tab INTO l_qgmk INDEX 1.

  CALL FUNCTION 'QEGR_RUN_CHART_FOR_QGMK'
    EXPORTING
      i_merknr                = l_qgmk-merknr
      i_kurztext              = l_qgmk-kurztext
      i_ktextmat              = gv_maktx
      i_masseinhsw6           = l_qgmk-masseinhsw
      i_stellen               = l_qgmk-stellen
      i_tolobni               = l_qgmk-tolobni
      i_sollwni               = l_qgmk-sollwni
      i_tolunni               = l_qgmk-tolunni
      i_time_axis             = ''
      i_page_size             = 20
    IMPORTING
      e_graphics_still_active = l_xgraphics_still_active
    TABLES
      t_qgmktab               = l_qgmk_tab
    EXCEPTIONS
      missing_data            = 1
      inconsistent_data       = 2
      programming_error       = 3
      OTHERS                  = 4.
ENDFORM.                    " F_MEAN_CHART
