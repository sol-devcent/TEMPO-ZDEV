*----------------------------------------------------------------------*
*   INCLUDE ZBPCWM_E0005F01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA : lt_makt LIKE zbpc0005 OCCURS 0 WITH HEADER LINE,
         lt_005  TYPE STANDARD TABLE OF zbpc0005.

  CASE 'X'.
    WHEN radio1.
      SELECT *
        FROM zbpc0006
        INTO CORRESPONDING FIELDS OF TABLE gt_zbpc0006.
    WHEN radio2.
      SELECT *
        FROM zbpc0006
        INTO CORRESPONDING FIELDS OF TABLE gt_zbpc0006
        WHERE gudang IN so_whse.

      CLEAR : so_lgnum[], so_lgnum, so_lgtyp[], so_lgtyp.
      SORT gt_zbpc0006 BY lgnum lgtyp.
      LOOP AT gt_zbpc0006.
        so_lgnum-low    = gt_zbpc0006-lgnum.
        so_lgnum-sign   = 'I'.
        so_lgnum-option = 'EQ'.
        COLLECT so_lgnum.
        CLEAR so_lgnum.

        so_lgtyp-low    = gt_zbpc0006-lgtyp.
        so_lgtyp-sign   = 'I'.
        so_lgtyp-option = 'EQ'.
        COLLECT so_lgtyp.
        CLEAR so_lgtyp.
      ENDLOOP.
  ENDCASE.

  SELECT *
    FROM zbpc0005
    INTO CORRESPONDING FIELDS OF TABLE gt_zbpc0005
    WHERE lgnum   IN so_lgnum
      AND lgtyp   IN so_lgtyp
      AND lgpla   IN so_lgpla
      AND ivnum   IN so_ivnum
      AND erdat   IN so_erdat.

  lt_005[] = gt_zbpc0005[].
  SORT lt_005 BY lgnum lgtyp lgpla matnr charg.
  DELETE ADJACENT DUPLICATES FROM lt_005 COMPARING lgnum lgtyp lgpla matnr charg.
  IF lt_005[] IS NOT INITIAL.
    SELECT *
      FROM lqua
      INTO CORRESPONDING FIELDS OF TABLE gt_lqua
      FOR ALL ENTRIES IN lt_005
      WHERE lgnum = lt_005-lgnum
        AND lgtyp = lt_005-lgtyp
        AND lgpla = lt_005-lgpla
        AND matnr = lt_005-matnr
        AND charg = lt_005-charg.
  ENDIF.

  lt_makt[] = gt_zbpc0005[].
  SORT lt_makt BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_makt COMPARING matnr.

  CHECK lt_makt[] IS NOT INITIAL.

  SELECT matnr maktx
    FROM makt
    INTO TABLE gt_makt
    FOR ALL ENTRIES IN lt_makt
    WHERE matnr = lt_makt-matnr
      AND spras = sy-langu.

  SELECT lgnum lgtyp lgpla
    FROM lagp
    INTO TABLE gt_lagp
    WHERE lgnum   IN so_lgnum
      AND lgtyp   IN so_lgtyp.

  DESCRIBE TABLE gt_lagp LINES gv_03.
  WRITE gv_03 TO gv_03c DECIMALS 0.
  CONDENSE gv_03c NO-GAPS.
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
  PERFORM f_build_layout      USING   gs_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  lv_func    = 'REUSE_ALV_GRID_DISPLAY_LVC'.
  lv_title   = sy-title.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      i_callback_top_of_page   = 'F_TOP_OF_PAGE'
*     i_grid_title             = lv_title
      is_layout_lvc            = gs_layout
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
  PERFORM f_fieldcatg USING 'GT_OUT' :
    'CHECK' '' '' '' '5' '' '' '' '' '' '' '' '' 'X' '' 'X' '',
    'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '' '' '',
    'LGNUM' 'ZBPC0005' 'LGNUM' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'LGTYP' 'ZBPC0005' 'LGTYP' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'LGPLA' 'ZBPC0005' 'LGPLA' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'GUDANG' '' '' '' '20' 'Gudang' '' '' '' '' '' '' '' '' '' '' '',
    'IVNUM' 'ZBPC0005' 'IVNUM' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'IVPOS' 'ZBPC0005' 'IVPOS' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'LQNUM' 'ZBPC0005' 'LQNUM' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ADDNI' '' '' '' '5' 'NewIt' '' '' '' '' '' '' '' '' '' '' '',
    'MATNR' 'ZBPC0005' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WERKS' 'ZBPC0005' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'CHARG' 'ZBPC0005' 'CHARG' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MEINS' 'ZBPC0005' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'GESME' 'ZBPC0005' 'GESME' '' '' '' '' '' '' '' ''
    '' 'MEINS' '' '' '' '',
    'AUSME' 'LQUA' 'AUSME' '' '' '' '' '' '' '' ''
    '' 'MEINS' '' '' '' '',
    'GESME1' 'ZBPC0005' 'GESME' '' '' 'Total Stock Counted' '' '' '' '' ''
    '' 'MEINS' '' '' '' '',
    'SELISIH' 'ZBPC0005' 'GESME' '' '' 'Selisih' '' '' '' '' '' '' 'MEINS'
    '' '' '' '',
    'MENGA' 'ZBPC0005' 'MENGA' '' '' 'Stock Counted (CAR)' '' '' '' '' ''
    '' 'ALTME' '' '' '' '',
    'ALTME' 'ZBPC0005' 'ALTME' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MENGE' 'ZBPC0005' 'MENGE' '' '' 'Stock Counted (BUn)' '' '' '' '' ''
    '' 'MEINS' '' '' '' '',
    'KZNUL' 'ZBPC0005' 'KZNUL' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'LGORT' 'ZBPC0005' 'LGORT' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERDAT' 'ZBPC0005' 'ERDAT' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERZET' 'ZBPC0005' 'ERZET' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZUSER1' 'ZBPC0005' 'ZUSER1' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZCOUDT' 'ZBPC0005' 'ZCOUDT' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZCOUZT' 'ZBPC0005' 'ZCOUZT' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZCOUUN' 'ZBPC0005' 'ZCOUUN' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZFINDT' 'ZBPC0005' 'ZFINDT' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZFINZT' 'ZBPC0005' 'ZFINZT' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZFINUN' 'ZBPC0005' 'ZFINUN' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SENUM' '' '' '' '' 'Final SN' '' '' '' '' '' '' '' ''
    '' '' '',
    'ZFINAL' 'ZBPC0005' 'ZFINAL' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
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
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_dosum)
                          VALUE(fu_hotsp)
                          VALUE(fu_dec)
                          VALUE(fu_waers)
                          VALUE(fu_meins)
                          VALUE(fu_waers_f)
                          VALUE(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_input)
                          VALUE(fu_edit)
                          VALUE(fu_emphasize).

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
  ld_fieldcat-edit              = fu_edit.
  ld_fieldcat-emphasize         = fu_emphasize.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM F_BUILD_EVENT
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
*  REFRESH: ft_events.
*  CLEAR ft_events.
*  ft_events-name = slis_ev_top_of_page.
*  ft_events-form = 'F_TOP_OF_PAGE'.
*  APPEND ft_events.
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
FORM f_build_layout USING fu_layout TYPE lvc_s_layo.  "slis_layout_alv.
*  fu_layout-zebra              = 'X'.
*  fu_layout-colwidth_optimize  = space.
*  fu_layout-no_colhead         = space.
*  fu_layout-group_change_edit  = 'X'.
*  fu_layout-detail_popup       = 'X'.
**  fu_layout-box_fieldname      = 'CHECK'.

  fu_layout-zebra          = selected.
  fu_layout-no_rowmark     = selected.
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
  ld_sort-fieldname = 'IVNUM'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  ld_sort-subtot    = 'X'.
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

  CLEAR : gt_header[], gt_header, wa_header.

  PERFORM f_summary_data USING : 'S' 'Coverage dalam % :' '' gv_01c,
                                 'S' 'Jumlah Bin yang sudah dicek :' '' gv_02c,
                                 'S' 'Jumlah Bin total :' '' gv_03c,
                                 'S' 'Jumlah Bin yang tidak selisih :' '' gv_04c,
                                 'S' 'Jumlah Bin yang selisih :' '' gv_05c,
                                 'S' 'Selisih terkecil :' gv_06c gv_07c,
                                 'S' 'Selisih terbesar :' gv_08c gv_09c.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_header.

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
  DATA : fcode TYPE TABLE OF sy-ucomm.

  sy-lsind = 0.
  IF gt_error[] IS INITIAL.
    APPEND '&LOG'  TO fcode.
  ENDIF.

  SET PF-STATUS 'TOEXECUTE' EXCLUDING fcode.

  CLEAR ref_grid.
  IF ref_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref_grid.
  ENDIF.
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
  DATA : lv_flag(1),
         lv_meins(3).

  DATA : BEGIN OF lt_count OCCURS 0,
           lgpla   LIKE lagp-lgpla,
           ivnum   LIKE zbpc0005-ivnum,
           meins   LIKE mara-meins,
           min     LIKE zbpc0005-gesme,
           max     LIKE zbpc0005-gesme,
           selisih LIKE zbpc0005-gesme,
         END OF lt_count.

  DATA : ls_lqua   LIKE LINE OF gt_lqua.

  LOOP AT gt_zbpc0005.
    MOVE-CORRESPONDING gt_zbpc0005 TO gt_out.
    IF gt_out-zcoudt IS NOT INITIAL.
      gt_out-icon = icon_led_yellow.
    ELSE.
      gt_out-icon = icon_led_red.
    ENDIF.
    IF gt_out-zfindt IS NOT INITIAL.
      gt_out-icon = icon_led_green.
    ENDIF.

    READ TABLE gt_makt WITH KEY matnr = gt_zbpc0005-matnr.
    IF sy-subrc = 0.
      gt_out-maktx  = gt_makt-maktx.
    ENDIF.

    READ TABLE gt_zbpc0006 WITH KEY lgnum = gt_zbpc0005-lgnum
                                    lgtyp = gt_zbpc0005-lgtyp.
    IF sy-subrc = 0.
      gt_out-gudang  = gt_zbpc0006-gudang.
    ENDIF.

    gt_out-selisih  = gt_zbpc0005-gesme1 - gt_zbpc0005-gesme.

    CLEAR ls_lqua.
    READ TABLE gt_lqua INTO ls_lqua
                       WITH KEY lgnum = gt_zbpc0005-lgnum
                                lgtyp = gt_zbpc0005-lgtyp
                                lgpla = gt_zbpc0005-lgpla
                                matnr = gt_zbpc0005-matnr
                                charg = gt_zbpc0005-charg.
    IF sy-subrc = 0.
      gt_out-ausme = ls_lqua-ausme.
    ENDIF.
    APPEND gt_out.
  ENDLOOP.

  SORT gt_out BY lgpla.
  LOOP AT gt_out.
    IF gt_out-zcouun IS NOT INITIAL.
      lt_count-lgpla  = gt_out-lgpla.
      COLLECT lt_count.
    ENDIF.
    CLEAR lt_count.
  ENDLOOP.

  SORT gt_out BY lgpla ivnum DESCENDING selisih.
  LOOP AT lt_count.
    CLEAR : lv_flag, lt_count-ivnum.
    LOOP AT gt_out WHERE lgpla = lt_count-lgpla.
      IF lt_count-ivnum IS INITIAL.
        lt_count-ivnum  = gt_out-ivnum.
      ELSEIF lt_count-ivnum <> gt_out-ivnum.
        EXIT.
      ENDIF.
      lt_count-meins  = gt_out-meins.
      IF lv_flag IS INITIAL.
        lv_flag = 'X'.
        lt_count-min  = gt_out-selisih.
      ENDIF.
    ENDLOOP.
    lt_count-max  = gt_out-selisih.
    MODIFY lt_count TRANSPORTING min max meins ivnum.
    CLEAR lt_count.
  ENDLOOP.

  SORT gt_out BY lgpla ivnum DESCENDING.
  LOOP AT lt_count.
    LOOP AT gt_out WHERE lgpla = lt_count-lgpla
                     AND ivnum = lt_count-ivnum.
      IF gt_out-selisih <> 0.
        lt_count-selisih  = gt_out-selisih.
        EXIT.
      ENDIF.
    ENDLOOP.
    MODIFY lt_count TRANSPORTING selisih.
    CLEAR lt_count.
  ENDLOOP.

  DESCRIBE TABLE lt_count LINES gv_02.
  WRITE gv_02 TO gv_02c DECIMALS 0.
  CONDENSE gv_02c NO-GAPS.

  gv_01 = ( gv_02 / gv_03 ) * 100.
  WRITE gv_01 TO gv_01c DECIMALS 2.
  CONDENSE gv_01c NO-GAPS.

  LOOP AT lt_count.
    IF lt_count-selisih IS INITIAL.
      ADD 1 TO gv_04.
    ELSE.
      ADD 1 TO gv_05.
    ENDIF.
  ENDLOOP.

  WRITE gv_04 TO gv_04c DECIMALS 0.
  CONDENSE gv_04c NO-GAPS.
  WRITE gv_05 TO gv_05c DECIMALS 0.
  CONDENSE gv_05c NO-GAPS.

  SORT lt_count BY min.
  READ TABLE lt_count INDEX 1.
  IF sy-subrc = 0.
    WRITE lt_count-min TO gv_07c UNIT lt_count-meins.
    CONDENSE gv_07c NO-GAPS.
    PERFORM f_meins_conversion USING lt_count-meins
                               CHANGING lv_meins.
    CONCATENATE gv_07c lv_meins INTO gv_07c
    SEPARATED BY space.
    gv_06c  = lt_count-lgpla.
  ENDIF.

  SORT lt_count BY max DESCENDING.
  READ TABLE lt_count INDEX 1.
  IF sy-subrc = 0.
    WRITE lt_count-max TO gv_09c UNIT lt_count-meins.
    CONDENSE gv_09c NO-GAPS.
    PERFORM f_meins_conversion USING lt_count-meins
                               CHANGING lv_meins.
    CONCATENATE gv_09c lv_meins INTO gv_09c
    SEPARATED BY space.
    gv_08c  = lt_count-lgpla.
  ENDIF.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&ALL1'.
      PERFORM f_select USING 'X'.
    WHEN '&SAL1'.
      PERFORM f_select USING ''.
    WHEN '&LOG'.
      CALL SCREEN 101 STARTING AT 10 10 ENDING AT 130 22.
    WHEN '&POS'.
      PERFORM f_post_entries.
      CHECK gt_error[] IS INITIAL.
      LEAVE TO SCREEN 0.
    WHEN '&SN'.
      PERFORM f_final_sn.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.
  DATA : lt_out   LIKE gt_out OCCURS 0 WITH HEADER LINE,
         lv_subrc TYPE sy-subrc.

  CLEAR : gt_error[], gt_error.

  CALL METHOD ref_grid->check_changed_data.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE check IS INITIAL.
  DELETE lt_out WHERE senum IS INITIAL.
  IF lt_out[] IS INITIAL.
    gt_error-icon   = icon_led_red.
    gt_error-mess   = 'Finalized SN first'.
    APPEND gt_error.
    CLEAR gt_error.
  ENDIF.
  SORT lt_out BY ivnum.
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING ivnum.

  LOOP AT lt_out.
    CLEAR lv_subrc.
    LOOP AT gt_out WHERE ivnum = lt_out-ivnum.
      IF gt_out-check IS INITIAL OR
        gt_out-senum IS INITIAL.
        PERFORM f_isi_error USING gt_out-lgnum gt_out-lgtyp
                                  gt_out-lgpla gt_out-ivnum
                                  'Calculation unfinised'.
        lv_subrc = 4.
        EXIT.
      ENDIF.
      IF gt_out-icon = icon_led_yellow.
        CONTINUE.
      ELSE.
        PERFORM f_isi_error USING gt_out-lgnum gt_out-lgtyp
                                  gt_out-lgpla gt_out-ivnum
                                  'Calculation unfinised'.
        lv_subrc  = 4.
        EXIT.
      ENDIF.
    ENDLOOP.

    CHECK lv_subrc IS INITIAL.

    UPDATE zbpc0005 SET zfindt = sy-datum
                        zfinzt = sy-uzeit
                        zfinun = sy-uname
                        zfinal = 'X'
                    WHERE ivnum = lt_out-ivnum.
  ENDLOOP.

  IF gt_error[] IS NOT INITIAL.
    MESSAGE s000(zab) WITH 'Process is completed with errors'
                      DISPLAY LIKE 'E'.
  ELSE .
    MESSAGE s000(zab) WITH 'Data already processed'.
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
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'WHS' '' '0'.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'LGN' '' '0',
                                      'LGT' '' '0'.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA : lv_mess(100).

  CASE 'X'.
    WHEN radio1.
      IF so_lgnum[] IS INITIAL.
        PERFORM f_screen_error USING 'LGN' ''.
      ELSE.
        AUTHORITY-CHECK OBJECT 'L_LGNUM'
          ID 'LGNUM' FIELD so_lgnum-low.
        IF sy-subrc <> 0.
          CONCATENATE 'You are not authorized for WH' so_lgnum-low
          INTO lv_mess
          SEPARATED BY space.
          PERFORM f_screen_error USING 'LGN' lv_mess.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_select.
  LOOP AT gt_out.
    IF gt_out-icon <> icon_led_green.
      gt_out-check = fu_select.
      MODIFY gt_out TRANSPORTING check.
    ENDIF.
    CLEAR : gt_out.
  ENDLOOP.

  CALL METHOD ref_grid->refresh_table_display.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_ISI_ERROR
*&---------------------------------------------------------------------*
FORM f_isi_error  USING    fu_lgnum fu_lgtyp fu_lgpla fu_ivnum fu_mess.
  gt_error-icon   = icon_led_red.
  gt_error-lgnum  = fu_lgnum.
  gt_error-lgtyp  = fu_lgtyp.
  gt_error-lgpla  = fu_lgpla.
  gt_error-ivnum  = fu_ivnum.
  gt_error-mess   = fu_mess.
  APPEND gt_error.
  CLEAR gt_error.
ENDFORM.                    " F_ISI_ERROR

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_0101  OUTPUT
*&---------------------------------------------------------------------*
MODULE list_processing_0101 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_error_list.
ENDMODULE.                 " LIST_PROCESSING_0101  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LIST
*&---------------------------------------------------------------------*
FORM f_error_list .
  DATA : lv_zebra(1).

  ULINE AT /(99).
  FORMAT COLOR COL_HEADING.
  WRITE: /  sy-vline NO-GAP, (4) 'Sts.' NO-GAP,
            sy-vline NO-GAP, (4) 'Whse' NO-GAP,
            sy-vline NO-GAP, (4) 'Typ' NO-GAP,
            sy-vline NO-GAP, (10) 'Stor. Bin' NO-GAP,
            sy-vline NO-GAP, (10) 'Inv.No.' NO-GAP,
            sy-vline NO-GAP, (60) 'Message' NO-GAP,
            sy-vline.
  ULINE AT /(99).
  LOOP AT gt_error.
    PERFORM f_zebra CHANGING lv_zebra.
    WRITE: /  sy-vline NO-GAP, (4) gt_error-icon NO-GAP,
              sy-vline NO-GAP, (4) gt_error-lgnum NO-GAP,
              sy-vline NO-GAP, (4) gt_error-lgtyp NO-GAP,
              sy-vline NO-GAP, (10) gt_error-lgpla NO-GAP,
              sy-vline NO-GAP, (10) gt_error-ivnum NO-GAP,
              sy-vline NO-GAP, gt_error-mess(60) NO-GAP,
              sy-vline NO-GAP.
  ENDLOOP.
  ULINE AT /(99).
ENDFORM.                    " F_ERROR_LIST

*&---------------------------------------------------------------------*
*&      Form  F_ZEBRA
*&---------------------------------------------------------------------*
FORM f_zebra  CHANGING fc_zebra.
  FORMAT INTENSIFIED OFF.
  IF fc_zebra IS INITIAL.
    fc_zebra = 'X'.
    FORMAT COLOR COL_HEADING.
  ELSE.
    CLEAR : fc_zebra.
    FORMAT COLOR COL_NORMAL.
  ENDIF.
ENDFORM.                    " F_ZEBRA

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_ERROR
*&---------------------------------------------------------------------*
FORM f_screen_error  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_SCREEN_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_SUMMARY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1216   text
*      -->P_1217   text
*      -->P_GV_01  text
*----------------------------------------------------------------------*
FORM f_summary_data  USING    fu_typ fu_value fu_bin fu_count.
  DATA : lt_line      LIKE wa_header-info,
         lv_space(10).

  CONCATENATE fu_value fu_bin fu_count INTO lt_line
  SEPARATED BY space.
  wa_header-typ   = fu_typ.
*  wa_header-key   = fu_value.
  wa_header-info  = lt_line.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.
ENDFORM.                    " F_SUMMARY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_MEINS_CONVERSION
*&---------------------------------------------------------------------*
FORM f_meins_conversion  USING    fu_meins
                         CHANGING fc_meins.
  CLEAR fc_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_meins
    IMPORTING
      output         = fc_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_MEINS_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_GET_GUDANG
*&---------------------------------------------------------------------*
FORM f_get_gudang  CHANGING fc_whse.
  DATA : lt_0006   LIKE zbpc0006 OCCURS 0 WITH HEADER LINE,
         lt_rettab TYPE TABLE OF ddshretval  WITH HEADER LINE.

  SELECT *
    FROM zbpc0006
    INTO CORRESPONDING FIELDS OF TABLE lt_0006.

  CHECK lt_0006[] IS NOT INITIAL.

  CLEAR : lt_rettab[], lt_rettab.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'GUDANG'
      value_org       = 'S'
    TABLES
      value_tab       = lt_0006
      return_tab      = lt_rettab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  fc_whse = lt_rettab-fieldval.
ENDFORM.                    " F_GET_GUDANG

*&---------------------------------------------------------------------*
*&      Form  F_FINAL_SN
*&---------------------------------------------------------------------*
FORM f_final_sn .
  TYPES : BEGIN OF ty_key,
            docat TYPE zaccdtd-docat,
            docno TYPE zaccdtd-docno,
            posnr TYPE zaccdtd-posnr,
          END OF ty_key.

  DATA : lt_out   LIKE gt_out OCCURS 0 WITH HEADER LINE,
         ls_out   LIKE LINE OF lt_out,
         lv_subrc TYPE sy-subrc.
  DATA : lt_zaccdtm TYPE STANDARD TABLE OF zaccdtm,
         ls_zaccdtm LIKE LINE OF lt_zaccdtm,
         lt_key     TYPE STANDARD TABLE OF ty_key,
         ls_key     LIKE LINE OF lt_key,
         lt_zaccdtd TYPE STANDARD TABLE OF zaccdtd,
         ls_zaccdtd LIKE LINE OF lt_zaccdtd.

  CLEAR : gt_error[], gt_error.

  CALL METHOD ref_grid->check_changed_data.

  LOOP AT gt_out INTO ls_out WHERE check IS NOT INITIAL.
    ls_out-senum  = icon_led_green.
    CONDENSE ls_out-senum NO-GAPS.
    MODIFY gt_out FROM ls_out TRANSPORTING senum.

    UPDATE zbpc0005 SET senum  = ls_out-senum
                    WHERE ivnum = ls_out-ivnum
                      AND ivpos = ls_out-ivpos.

    CONCATENATE 'D' ls_out-lgnum INTO ls_key-docat.
    ls_key-docno  = ls_out-ivnum.
    ls_key-posnr  = ls_out-ivpos.
    APPEND ls_key TO lt_key.
    CLEAR ls_key.
    APPEND ls_out TO lt_out.
    CLEAR ls_out.
  ENDLOOP.

  IF lt_key[] IS NOT INITIAL.
    SELECT *
      FROM zaccdtd
      INTO CORRESPONDING FIELDS OF TABLE lt_zaccdtd
      FOR ALL ENTRIES IN lt_key
      WHERE docat = lt_key-docat
        AND docno = lt_key-docno
        AND posnr = lt_key-posnr.
  ENDIF.

  IF lt_zaccdtd[] IS NOT INITIAL.
    SELECT *
      FROM zaccdtm
      INTO CORRESPONDING FIELDS OF TABLE lt_zaccdtm
      FOR ALL ENTRIES IN lt_zaccdtd
      WHERE senum = lt_zaccdtd-senum
        AND snsta IN ('EDEL', 'ECUS', 'SCRP', 'ESTO').

    LOOP AT lt_zaccdtm INTO ls_zaccdtm.
      CLEAR ls_zaccdtd.
      READ TABLE lt_zaccdtd INTO ls_zaccdtd
                            WITH KEY senum = ls_zaccdtm-senum.
      CLEAR ls_out.
      READ TABLE gt_out INTO ls_out
                        WITH KEY ivnum = ls_zaccdtd-docno
                                 ivpos = ls_zaccdtd-posnr.
      TRY .
          UPDATE zaccdtm SET werks = ls_out-werks
                             lgort = ls_out-lgort
                             snsta = 'ESTO'
                         WHERE matnr = ls_zaccdtm-matnr
                           AND charg = ls_zaccdtm-charg
                           AND senum = ls_zaccdtm-senum.
        CATCH cx_sy_conversion_no_number.
      ENDTRY.
    ENDLOOP.
  ENDIF.

  CALL METHOD ref_grid->refresh_table_display.

ENDFORM.                    " F_FINAL_SN
