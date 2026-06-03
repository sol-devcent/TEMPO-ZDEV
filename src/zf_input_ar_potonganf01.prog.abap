*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM  f_get_data.
  CASE 'X'.
    WHEN p_revrs.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zfarpoth
        FROM zfarpoth
        WHERE bukrs = p_bukrs  AND
              gsber = p_gsber  AND
              vkbur = p_vkbur  AND
              noarp IN s_noarp AND
              mjahr = p_mjahr  AND
              belnr IN s_belnr AND
              budat IN s_budat AND
              belnr NE space   AND
              belnrrev = space AND
              daterev = '00000000'  AND
              userrev = space.

    WHEN p_lapor.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zfarpoth
        FROM zfarpoth
        WHERE bukrs = p_bukrs  AND
              gsber = p_gsber  AND
              vkbur = p_vkbur  AND
              noarp IN s_noarp AND
              mjahr = p_mjahr  AND
              belnr IN s_belnr AND
              budat IN s_budat.
  ENDCASE.

  IF gt_zfarpoth[] IS NOT INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zfarpotd
      FROM zfarpotd AS a JOIN kna1 AS b ON a~kunnr = b~kunnr
      FOR ALL ENTRIES IN gt_zfarpoth
      WHERE bukrs = p_bukrs AND
            gsber = p_gsber AND
            vkbur = p_vkbur AND
            noarp = gt_zfarpoth-noarp AND
            mjahr = gt_zfarpoth-mjahr.
  ENDIF.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
*  PERFORM f_alv TABLES gt_mara.
  SORT gt_zfarpoth BY bukrs gsber vkbur noarp mjahr.
  SORT gt_zfarpotd BY bukrs gsber vkbur noarp mjahr posnr.
  PERFORM f_alv_hierarchy TABLES gt_zfarpoth gt_zfarpotd.
ENDFORM.                    "f_print_data

*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
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

  IF pa_grid IS NOT INITIAL.
    lv_func    = 'REUSE_ALV_GRID_DISPLAY'.
    lv_title   = sy-title.
  ELSE.
    PERFORM f_build_event       TABLES  t_alv_event[].
    lv_func    = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

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
ENDFORM.                    "f_alv

*&---------------------------------------------------------------------*
*&      Form  F_ALV_HIERARCHY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_HDR  text
*      -->P_T_OUT  text
*----------------------------------------------------------------------*
FORM f_alv_hierarchy  TABLES   ft_hdr
                               ft_out.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat_hierarchy TABLES ft_hdr ft_out.
  PERFORM f_build_layout_hierarchy   USING  d_layout.
  PERFORM f_build_sortfield          USING  t_alv_isort[].
  PERFORM f_build_event              TABLES t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_key                USING  d_alv_keyinfo.
  PERFORM f_build_print              USING  d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
      it_sort                  = t_alv_isort[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = d_alv_variant
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      i_tabname_header         = 'GT_ZFARPOTH'
      i_tabname_item           = 'GT_ZFARPOTD'
      is_keyinfo               = d_alv_keyinfo
      is_print                 = d_print
    TABLES
      t_outtab_header          = ft_hdr
      t_outtab_item            = ft_out
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_ALV_HIERARCHY

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
    'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'MATKL' 'MARA' 'MATKL' '' '' '' '' '' '' '' '' '' '' '' '',
    'MEINS' 'MARA' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTG' 'MAKT' 'MAKTG' '' '' '' '' '' '' '' '' '' '' '' '',
    'BRGEW' 'MARA' 'BRGEW' '' '' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_FIELDCAT

*---------------------------------------------------------------------*
*       FORM f_fieldcat_hierarchy                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat_hierarchy TABLES ft_hdr ft_out.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING 'GT_ZFARPOTH':
    'BUKRS' 'ZFARPOTH' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '',
    'GSBER' 'ZFARPOTH' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'ZFARPOTH' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '',
    'NOARP' 'ZFARPOTH' 'NOARP' '' '' '' '' '' '' '' '' '' '' '' '',
    'MJAHR' 'ZFARPOTH' 'MJAHR' '' '' '' '' '' '' '' '' '' '' '' '',
    'ERDAT' 'ZFARPOTH' 'ERDAT' '' '' '' '' '' '' '' '' '' '' '' '',
    'BUDAT' 'ZFARPOTH' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '',
    'BLDAT' 'ZFARPOTH' 'BLDAT' '' '' '' '' '' '' '' '' '' '' '' '',
    'NODPY' 'ZFARPOTH' 'NODPY' '' '' '' '' '' '' '' '' '' '' '' '',
    'HKONT' 'ZFARPOTH' 'HKONT' '' '' '' '' '' '' '' '' '' '' '' '',
    'VOUCR' 'ZFARPOTH' 'VOUCR' '' '' '' '' '' '' '' '' '' '' '' '',
    'TXARP' 'ZFARPOTH' 'TXARP' '' '' '' '' '' '' '' '' '' '' '' '',
    'BBELN' 'ZFARPOTH' 'BBELN' '' '' '' '' '' '' '' '' '' '' '' '',
    'AMOUNT' 'ZFARPOTH' 'AMOUNT' '' '' '' '' '' '' 'IDR' '' '' '' '' '',
    'BELNR' 'ZFARPOTH' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'GJAHR' 'ZFARPOTH' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '',
    'BELNRREV' 'ZFARPOTH' 'BELNRREV' '' '' '' '' '' '' '' '' '' '' '' '',
    'DATEREV' 'ZFARPOTH' 'DATEREV' '' '' '' '' '' '' '' '' '' '' '' '',
    'USERREV' 'ZFARPOTH' 'USERREV' '' '' '' '' '' '' '' '' '' '' '' ''.

  PERFORM f_fieldcatg USING 'GT_ZFARPOTD':
    'POSNR' 'ZFARPOTD' 'POSNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'RTVTYP' 'ZFARPOTD' 'RTVTYP' '' '' '' '' '' '' '' '' '' '' '' '',
    'KUNNR' 'ZFARPOTD' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '',
    'RTVNR' 'ZFARPOTD' 'RTVNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'RTVDT' 'ZFARPOTD' 'RTVDT' '' '' '' '' '' '' '' '' '' '' '' '',
    'RTVAMT' 'ZFARPOTD' 'RTVAMT' '' '' '' '' '' '' 'IDR' '' '' '' '' '',
    'POSAMT' 'ZFARPOTD' 'POSAMT' '' '' '' '' '' '' 'IDR' '' '' '' '' '',
    'RTVKET' 'ZFARPOTD' 'RTVKET' '' '' '' '' '' '' '' '' '' '' '' '',
    'BELNR' 'ZFARPOTD' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'GJAHR' 'ZFARPOTD' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '',
    'BELNRREV' 'ZFARPOTD' 'BELNRREV' '' '' '' '' '' '' '' '' '' '' '' '',
    'DATEREV' 'ZFARPOTD' 'DATEREV' '' '' '' '' '' '' '' '' '' '' '' '',
    'USERREV' 'ZFARPOTD' 'USERREV' '' '' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_FIELDCAT_hierarchy

*---------------------------------------------------------------------*
*       FORM f_fieldcats                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_FNAME                                                      *
*  -->  FU_OUTLEN                                                     *
*  -->  FU_NOSIGN                                                     *
*  -->  FU_NOOUT                                                      *
*  -->  FU_TEXT                                                       *
*  -->  FU_REFTB                                                      *
*  -->  FU_REFFNAME                                                   *
*  -->  FU_DECIMALS                                                   *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
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
                          VALUE(fu_input).

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
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_event                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.
  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.
ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
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
ENDFORM.                    "f_build_event_exit

*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
*  fu_layout-box_fieldname      = 'CHECK'.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_layout_hierarchy                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout_hierarchy USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
  fu_layout-expand_fieldname  = 'EXPAND'.
  fu_layout-expand_all         = 'X'.
  IF p_revrs = 'X'.
    fu_layout-box_fieldname      = 'CHECK'.
  ENDIF.
ENDFORM.                    "f_build_layout_hierarchy

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_KEY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_D_ALV_KEYINFO  text
*----------------------------------------------------------------------*
FORM f_build_key  USING fd_alv_keyinfo TYPE slis_keyinfo_alv.
  fd_alv_keyinfo-header01 = 'NOARP'.
  fd_alv_keyinfo-item01   = 'NOARP'.
  fd_alv_keyinfo-header02 = 'MJAHR'.
  fd_alv_keyinfo-item02   = 'MJAHR'.
ENDFORM.                    " F_BUILD_KEY

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'BUKRS'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'GSBER'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'VKBUR'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'NOARP'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'MJAHR'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  DATA: ld_title(100).

  CASE 'X'.
    WHEN p_revrs.
      CONCATENATE 'Reverse' sy-title INTO ld_title SEPARATED BY space.
    WHEN p_lapor.
      CONCATENATE 'Report' sy-title INTO ld_title SEPARATED BY space.
  ENDCASE.
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING ld_title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.
  CLEAR: gt_zfarpoth, gt_zfarpoth[].
ENDFORM.                    " F_FREE_MEMORY
*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
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
ENDFORM.                    " f_clear_alv_data

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  CASE 'X'.
    WHEN p_revrs.
      SET PF-STATUS 'REVERSE'.
    WHEN p_lapor.
      SET PF-STATUS 'STANDARD'.
  ENDCASE.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "f_gui_message

*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA: ld_error(1).

  IF p_revrs = 'X'.
    LOOP AT gt_zfarpoth.
      LOOP AT gt_zfarpotd WHERE bukrs = gt_zfarpoth-bukrs AND
                                gsber = gt_zfarpoth-gsber AND
                                vkbur = gt_zfarpoth-vkbur AND
                                noarp = gt_zfarpoth-noarp AND
                                mjahr = gt_zfarpoth-mjahr.
        CLEAR ld_error.
        IF gt_zfarpotd-belnr IS NOT INITIAL AND
           gt_zfarpotd-belnrrev IS INITIAL.
          ld_error = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF ld_error = 'X'.
        DELETE gt_zfarpoth.
        DELETE gt_zfarpotd WHERE bukrs = gt_zfarpoth-bukrs AND
                                 gsber = gt_zfarpoth-gsber AND
                                 vkbur = gt_zfarpoth-vkbur AND
                                 noarp = gt_zfarpoth-noarp AND
                                 mjahr = gt_zfarpoth-mjahr.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.
    WHEN '&RVS'.
      PERFORM f_reverse_posting.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.                    "f_user_command

*&---------------------------------------------------------------------*
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_entries.

ENDFORM.                    " f_post_entries

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA : lv_subrc   TYPE sy-subrc.
  IF sy-ucomm = 'ENTER'.
    IF gt_verror[] IS INITIAL.
      PERFORM f_cek_data CHANGING lv_subrc.
      IF lv_subrc IS INITIAL.
        SET PF-STATUS 'STAT100'.
      ELSE.
        SET PF-STATUS 'STAT100' EXCLUDING 'SAVE'.
      ENDIF.
    ELSE.
      SET PF-STATUS 'STAT100' EXCLUDING 'SAVE'.
    ENDIF.
  ELSE.
    SET PF-STATUS 'STAT100' EXCLUDING 'SAVE'.
  ENDIF.
  SET TITLEBAR '001'.
  DESCRIBE TABLE gt_vdata LINES fill.
  input-lines = fill.
ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  save_ok = ok_code.
  CLEAR: ok_code.
  CASE save_ok.
    WHEN 'ENTER'.
      PERFORM f_validate_data.
    WHEN 'SAVE'.
      PERFORM f_validate_data.
      PERFORM f_save_data.
    WHEN '&LOG'.
      PERFORM f_log_screen.
    WHEN '&DEL'.
      PERFORM fcode_delete_row USING  'INPUT'
                                      'GT_VDATA'
                                      'FLAG'.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCL'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control OUTPUT.
  READ TABLE gt_vdata INTO gt_zfarpotd INDEX input-current_line.
  IF sy-subrc = 0 AND
    gt_verror[] IS INITIAL AND
    gt_zfarpotd-kunnr IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-name = 'GT_ZFARPOTD-KUNNR'.
        screen-input = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " FILL_TABLE_CONTROL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_table_control INPUT.
  SELECT SINGLE name1 INTO gt_zfarpotd-name1
    FROM kna1 WHERE kunnr = gt_zfarpotd-kunnr.

  MODIFY gt_vdata FROM gt_zfarpotd INDEX input-current_line.
ENDMODULE.                 " READ_TABLE_CONTROL  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data .
  DATA: BEGIN OF lt_vdata OCCURS 0.
          INCLUDE STRUCTURE zfarpotd.
          DATA:   key(40),
        END OF lt_vdata.

  DATA: BEGIN OF lt_duplicate OCCURS 0.
  DATA:   key(40),
          count TYPE int4.
  DATA: END OF lt_duplicate.

  DATA: ld_kunnr  LIKE kna1-kunnr,
        ld_amount LIKE zfarpoth-amount.

  DATA: BEGIN OF lt_knvv OCCURS 0,
          kunnr LIKE knvv-kunnr,
          vkorg LIKE knvv-vkorg,
          vtweg LIKE knvv-vtweg,
          spart LIKE knvv-spart,
          zterm LIKE knvv-zterm,
          kvgr3 LIKE knvv-kvgr3,
        END OF lt_knvv.

  DATA: lt_vdata2 LIKE lt_vdata OCCURS 0 WITH HEADER LINE.
  DATA: lt_zscust_control TYPE TABLE OF zscust_control WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_vdata> LIKE gt_vdata.

  SELECT * INTO TABLE lt_zscust_control
    FROM zscust_control
    WHERE vkorg = p_bukrs
      AND cek   = 'ARP'
      AND field_name = 'KVGR3'
      AND datab LE sy-datum
      AND datbi GE sy-datum.

  CLEAR: gt_verror.
  REFRESH: gt_verror.

  lt_vdata[] = gt_vdata[].

  LOOP AT lt_vdata.
    IF lt_vdata IS INITIAL.
      DELETE lt_vdata.
    ELSE.
      ADD lt_vdata-rtvamt TO ld_amount.
      CONCATENATE lt_vdata-rtvtyp lt_vdata-kunnr lt_vdata-rtvnr INTO lt_vdata-key.
      MODIFY lt_vdata TRANSPORTING key.

      lt_duplicate-key = lt_vdata-key.
      lt_duplicate-count = 1.
      COLLECT lt_duplicate.
      CLEAR: lt_vdata,lt_duplicate.
    ENDIF.
  ENDLOOP.

  "Change TOP
  IF lt_vdata[] IS NOT INITIAL.
    lt_vdata2[] = lt_vdata[].
    DELETE lt_vdata2 WHERE zterm NE space.
    IF lt_vdata2[] IS NOT INITIAL.
      SELECT kunnr vkorg vtweg spart zterm kvgr3
        INTO CORRESPONDING FIELDS OF TABLE lt_knvv
        FROM knvv FOR ALL ENTRIES IN lt_vdata2
        WHERE kunnr = lt_vdata2-kunnr
          AND vkorg = p_bukrs
          AND vtweg = '10'
          AND spart = '00'.
    ENDIF.
  ENDIF.

  LOOP AT lt_vdata.
    CLEAR gt_verror.
* Cek Type
    IF lt_vdata-rtvtyp NE 'DO' AND
       lt_vdata-rtvtyp NE 'CN'.
      MOVE-CORRESPONDING lt_vdata TO gt_verror.
      gt_verror-text = 'Type'.
    ENDIF.
* Cek Customer
    SELECT SINGLE kunnr INTO ld_kunnr
      FROM kna1 WHERE kunnr = lt_vdata-kunnr.
    IF sy-subrc NE 0.
      IF gt_verror IS INITIAL.
        MOVE-CORRESPONDING lt_vdata TO gt_verror.
        CONCATENATE 'Customer' lt_vdata-kunnr 'tidak ada'
        INTO gt_verror-text
        SEPARATED BY space.
      ELSE.
        CONCATENATE gt_verror-text 'Customer' INTO gt_verror-text
           SEPARATED BY ','.
      ENDIF.
    ELSE.
      SELECT SINGLE kunnr INTO ld_kunnr
        FROM knvv WHERE kunnr = lt_vdata-kunnr
                    AND vkbur = vkbur.
      IF sy-subrc NE 0.
        IF gt_verror IS INITIAL.
          MOVE-CORRESPONDING lt_vdata TO gt_verror.
          CONCATENATE 'Customer' lt_vdata-kunnr 'tidak ada di SOff' vkbur
          INTO gt_verror-text
          SEPARATED BY space.
        ELSE.
          CONCATENATE gt_verror-text 'Customer' INTO gt_verror-text
             SEPARATED BY ','.
        ENDIF.
      ENDIF.
    ENDIF.
* Cek No RTV/Invoice
    IF lt_vdata-rtvnr IS INITIAL.
      MOVE-CORRESPONDING lt_vdata TO gt_verror.
      gt_verror-text = 'No RTV/Invoice'.
    ENDIF.
* Cek Duplikasi
    CLEAR lt_duplicate.
    READ TABLE lt_duplicate WITH KEY key = lt_vdata-key.
    IF lt_duplicate-count GT 1.
      IF gt_verror IS INITIAL.
        MOVE-CORRESPONDING lt_vdata TO gt_verror.
        gt_verror-text = 'Duplicated record'.
      ELSE.
        CONCATENATE gt_verror-text 'Duplicated record' INTO gt_verror-text
           SEPARATED BY ','.
      ENDIF.
    ENDIF.
* Cek TOP
    IF lt_vdata-zterm IS INITIAL.
      CLEAR: lt_knvv,lt_zscust_control.
      READ TABLE lt_knvv WITH KEY kunnr = lt_vdata-kunnr
                                  vkorg = p_bukrs.
      READ TABLE lt_zscust_control WITH KEY field_value = lt_knvv-kvgr3.
      READ TABLE gt_vdata ASSIGNING <fs_vdata>
                          WITH KEY kunnr = lt_vdata-kunnr
                                   rtvtyp = lt_vdata-rtvtyp
                                   rtvnr = lt_vdata-rtvnr
                                   rtvdt = lt_vdata-rtvdt.
      IF sy-subrc = 0.
        IF lt_zscust_control-field_value2 IS NOT INITIAL.
          <fs_vdata>-zterm = lt_zscust_control-field_value2.
        ELSE.
          <fs_vdata>-zterm = lt_knvv-zterm.
        ENDIF.
      ENDIF.
    ELSE.
      READ TABLE gt_tvzbt WITH KEY zterm = lt_vdata-zterm TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        IF gt_verror IS INITIAL.
          MOVE-CORRESPONDING lt_vdata TO gt_verror.
          gt_verror-text = 'TOP salah'.
        ELSE.
          CONCATENATE gt_verror-text 'TOP salah' INTO gt_verror-text
             SEPARATED BY ','.
        ENDIF.
      ENDIF.
    ENDIF.
* Cek Posting month
*    IF lt_vdata-rtvdt(6) NE budat(6).
*      IF gt_verror IS INITIAL.
*        MOVE-CORRESPONDING lt_vdata TO gt_verror.
*        gt_verror-text = 'Tanggal salah'.
*      ELSE.
*        CONCATENATE gt_verror-text 'Tanggal salah' INTO gt_verror-text
*           SEPARATED BY ','.
*      ENDIF.
*    ENDIF.

    IF gt_verror IS INITIAL.
    ELSE.
      APPEND gt_verror. CLEAR gt_verror.
    ENDIF.
  ENDLOOP.

  IF lt_vdata[] IS INITIAL.
    MESSAGE 'No Data...' TYPE 'S'.
  ELSE.
    IF gt_verror[] IS INITIAL.
* Cek Amount
      IF ld_amount = amount.
* Cek Account Bank
        PERFORM f_cek_hkont USING hkont.
        IF gv_error IS INITIAL.
          MESSAGE 'Data Okay...' TYPE 'S'.
          PERFORM f_move_to_itab_save TABLES lt_vdata.
        ELSE.
          gt_verror-text = 'G/L Acct. Cash/Bank Salah'.
          APPEND gt_verror. CLEAR gt_verror.
          MESSAGE 'Data Error... cek error log' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ELSE.
        gt_verror-text = 'Total amount salah'.
        APPEND gt_verror. CLEAR gt_verror.
        MESSAGE 'Data Error... cek error log' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    ELSE.
      MESSAGE 'Data Error... cek error log' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_data .
*  IF gt_zfarpotd_sv[] IS INITIAL.
*    MESSAGE 'No Data...' TYPE 'S'.
*  ELSE.
  IF gt_verror[] IS INITIAL.
    PERFORM f_modify_itab.
    PERFORM f_posting_bdc.
    LEAVE TO SCREEN 0.
  ELSE.
    MESSAGE 'Data Error... cek error log' TYPE 'S'.
  ENDIF.
*  ENDIF.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_INIT_SCREEN_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_screen_100 .
  bukrs = p_bukrs.
  gsber = p_gsber.
  vkbur = p_vkbur.
  mjahr = p_mjahr.

*  hkont = p_hkont.
*  erdat = sy-datum.

*  CALL FUNCTION 'NUMBER_GET_NEXT'
*    EXPORTING
*      nr_range_nr             = '01'
*      object                  = 'ZFARPOTONG'
*      subobject               = bukrs
*      toyear                  = mjahr
*    IMPORTING
*      number                  = noarp
*    EXCEPTIONS
*      interval_not_found      = 1
*      number_range_not_intern = 2
*      object_not_found        = 3
*      quantity_is_0           = 4
*      quantity_is_not_1       = 5
*      interval_overflow       = 6
*      buffer_overflow         = 7
*      OTHERS                  = 8.

  DO 500 TIMES.
    APPEND INITIAL LINE TO gt_vdata.
  ENDDO.
ENDFORM.                    " F_INIT_SCREEN_100

*&---------------------------------------------------------------------*
*&      Form  F_LOG_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_log_screen .
  CALL SCREEN 101 STARTING AT 10 10 ENDING AT 150 22.
ENDFORM.                    " F_LOG_SCREEN

*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS_0101  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE list_processing_0101 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_print_error_log.
ENDMODULE.                 " LIST_PROCESSING_0101  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_ERROR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_error_log .
  IF gt_verror[] IS INITIAL.
    SKIP 1.
    WRITE: /13 'No error occurs'.
  ELSE.
    ULINE AT /(163).
    WRITE:/ sy-vline NO-GAP, (5) 'Type' NO-GAP,
            sy-vline NO-GAP, (10) 'Customer' NO-GAP,
            sy-vline NO-GAP, (20) 'Nomor RTV' NO-GAP,
            sy-vline NO-GAP, (10) 'Tanggal RTV' NO-GAP,
            sy-vline NO-GAP, (4) 'TOP' NO-GAP,
            sy-vline NO-GAP, (15) 'Nilai RTV' NO-GAP,
            sy-vline NO-GAP, (30) 'Keterangan RTV' NO-GAP,
            sy-vline NO-GAP, (60) 'E R R O R' NO-GAP,
            sy-vline NO-GAP.
    ULINE AT /(163).
    LOOP AT gt_verror.
      WRITE:/ sy-vline NO-GAP, (5) gt_verror-rtvtyp NO-GAP,
              sy-vline NO-GAP, (10) gt_verror-kunnr NO-GAP,
              sy-vline NO-GAP, (20) gt_verror-rtvnr NO-GAP,
              sy-vline NO-GAP, (10) gt_verror-rtvdt NO-GAP,
              sy-vline NO-GAP, (4) gt_verror-zterm NO-GAP,
              sy-vline NO-GAP, (15) gt_verror-rtvamt NO-GAP,
              sy-vline NO-GAP, (30) gt_verror-rtvket NO-GAP,
              sy-vline NO-GAP, (60) gt_verror-text NO-GAP,
              sy-vline NO-GAP.
    ENDLOOP.
    ULINE AT /(163).
  ENDIF.
ENDFORM.                    " F_PRINT_ERROR_LOG

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      APPEND INITIAL LINE TO <table>.
*      IF sy-subrc = 0.
*        <tc>-lines = <tc>-lines - 1.
*      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_posting_bdc .
  DATA: ld_bldat(10),
        ld_budat(10),
        ld_rtvdt(10),
        ld_wrbtr(15),
        ld_budat2      TYPE datum,
        ld_zfbdt       TYPE datum,
        ld_zfbdt_c(10).

  CLEAR: gt_zfarpoth_sv,t_bdcdata,t_bdcmsg.
  REFRESH: t_bdcdata, t_bdcmsg.

  READ TABLE gt_zfarpoth_sv INDEX 1.
  WRITE gt_zfarpoth_sv-bldat TO ld_bldat.
  WRITE gt_zfarpoth_sv-budat TO ld_budat.
  ld_budat2 = gt_zfarpoth_sv-budat.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPMF05A'      '0100',
       ' '  'BDC_OKCODE'    '/00',
       ' '  'BKPF-BLDAT'    ld_bldat,
       ' '  'BKPF-BLART'    'DA',
       ' '  'BKPF-BUKRS'    gt_zfarpoth_sv-bukrs,
       ' '  'BKPF-BUDAT'    ld_budat,
       ' '  'BKPF-MONAT'    gt_zfarpoth_sv-budat+4(2),
       ' '  'BKPF-WAERS'    'IDR',
       ' '  'BKPF-XBLNR'    gt_zfarpoth_sv-nodpy,
       ' '  'BKPF-BKTXT'    gt_zfarpoth_sv-txarp,
       ' '  'FS006-DOCID'   '*'.

  LOOP AT gt_zfarpotd_sv.
    CLEAR: ld_rtvdt,ld_wrbtr,ld_zfbdt,ld_zfbdt_c,gt_tvzbt.
    WRITE gt_zfarpotd_sv-rtvdt TO ld_rtvdt.
    WRITE gt_zfarpotd_sv-rtvamt TO ld_wrbtr DECIMALS 0.
    REPLACE ',' WITH '' INTO ld_wrbtr.
    REPLACE '.' WITH '' INTO ld_wrbtr.
    REPLACE '.' WITH '' INTO ld_wrbtr.
    REPLACE '.' WITH '' INTO ld_wrbtr.
    REPLACE '.' WITH '' INTO ld_wrbtr.
    CONDENSE ld_wrbtr NO-GAPS.

    READ TABLE gt_tvzbt WITH KEY zterm = gt_zfarpotd_sv-zterm.
    ld_zfbdt = ld_budat2 + gt_tvzbt-ztag1.
    WRITE ld_zfbdt TO ld_zfbdt_c.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
         ' '  'RF05A-NEWBS'   '09',
         ' '  'RF05A-NEWKO'   gt_zfarpotd_sv-kunnr,
         ' '  'RF05A-NEWUM'   'V'.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
         'X'  'SAPMF05A'      '0303',
         ' '  'BDC_OKCODE'    '/00',
         ' '  'BSEG-WRBTR'    ld_wrbtr,
         ' '  'BSEG-GSBER'    gt_zfarpoth_sv-gsber,
*         ' '  'BSEG-ZFBDT'    ld_rtvdt,
*         ' '  'BSEG-ZFBDT'    ld_budat,
         ' '  'BSEG-ZFBDT'    ld_zfbdt_c,
         ' '  'BSEG-ZUONR'    gt_zfarpotd_sv-rtvnr,
         ' '  'BSEG-SGTXT'    gt_zfarpotd_sv-rtvket.
  ENDLOOP.

  CLEAR: ld_wrbtr.
  WRITE gt_zfarpoth_sv-amount TO ld_wrbtr DECIMALS 0.
  REPLACE ',' WITH '' INTO ld_wrbtr.
  REPLACE '.' WITH '' INTO ld_wrbtr.
  REPLACE '.' WITH '' INTO ld_wrbtr.
  REPLACE '.' WITH '' INTO ld_wrbtr.
  REPLACE '.' WITH '' INTO ld_wrbtr.
  CONDENSE ld_wrbtr NO-GAPS.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       ' '  'RF05A-NEWBS'   '50',
       ' '  'RF05A-NEWKO'   gt_zfarpoth_sv-hkont.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPMF05A'      '0300',
       ' '  'BDC_OKCODE'    '=AB',
       ' '  'BSEG-WRBTR'    ld_wrbtr,
       ' '  'BSEG-ZUONR'    gt_zfarpoth_sv-voucr,
*       ' '  'BSEG-ZFBDT'    ld_erdat,
       ' '  'BSEG-SGTXT'    gt_zfarpoth_sv-txarp.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPLKACB'      '0002',
       ' '  'BDC_OKCODE'    '=ENTE',
       ' '  'COBL-GSBER'    gt_zfarpoth_sv-vkbur.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPMF05A'      '0700',
       ' '  'BDC_OKCODE'    '=BU',
       ' '  'BKPF-XBLNR'    gt_zfarpoth_sv-nodpy,
       ' '  'BKPF-BKTXT'    gt_zfarpoth_sv-txarp.

  CALL TRANSACTION 'F-21' USING t_bdcdata
                          MODE gv_mode
                          UPDATE 'S'
                          MESSAGES INTO t_bdcmsg.

  READ TABLE t_bdcmsg WITH KEY msgtyp = 'E'.
  IF sy-subrc = 0.
    ROLLBACK WORK.
  ELSE.
    READ TABLE t_bdcmsg WITH KEY msgtyp = 'S'
                                 msgid  = 'F5'
                                 msgnr  = '312'.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
      PERFORM f_save_to_table.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_POSTING_BDC

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_TO_ITAB_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_VDATA  text
*----------------------------------------------------------------------*
FORM f_move_to_itab_save  TABLES  ft_vdata STRUCTURE zfarpotd.
  CLEAR: gt_zfarpotd_sv,gt_zfarpoth_sv.
  REFRESH: gt_zfarpotd_sv,gt_zfarpoth_sv.

  gt_zfarpoth_sv-bukrs = bukrs.
  gt_zfarpoth_sv-gsber = gsber.
  gt_zfarpoth_sv-vkbur = vkbur.
*  gt_zfarpoth_sv-noarp = noarp.
  gt_zfarpoth_sv-mjahr = mjahr.
  gt_zfarpoth_sv-erdat = sy-datum.
  gt_zfarpoth_sv-erzet = sy-uzeit.
  gt_zfarpoth_sv-txarp = txarp.
  gt_zfarpoth_sv-voucr = voucr.
  gt_zfarpoth_sv-hkont = hkont.
  gt_zfarpoth_sv-amount = amount.
  gt_zfarpoth_sv-budat = budat.
  gt_zfarpoth_sv-bbeln = bbeln.
  gt_zfarpoth_sv-buzet = sy-uzeit.
  gt_zfarpoth_sv-bunam = sy-uname.
  gt_zfarpoth_sv-bldat = bldat.
  gt_zfarpoth_sv-nodpy = nodpy.
  APPEND gt_zfarpoth_sv.

  SORT ft_vdata BY bukrs gsber vkbur mjahr kunnr.
  LOOP AT ft_vdata.
    gt_zfarpotd_sv-bukrs = bukrs.
    gt_zfarpotd_sv-gsber = gsber.
    gt_zfarpotd_sv-vkbur = vkbur.
*    gt_zfarpotd_sv-noarp = noarp.
    gt_zfarpotd_sv-mjahr = mjahr.
    ADD 10 TO gt_zfarpotd_sv-posnr.
    gt_zfarpotd_sv-kunnr = ft_vdata-kunnr.
    gt_zfarpotd_sv-rtvtyp = ft_vdata-rtvtyp.
    gt_zfarpotd_sv-rtvnr = ft_vdata-rtvnr.
    gt_zfarpotd_sv-rtvdt = ft_vdata-rtvdt.
    gt_zfarpotd_sv-rtvamt = ft_vdata-rtvamt.
    gt_zfarpotd_sv-rtvket = ft_vdata-rtvket.
    gt_zfarpotd_sv-xblnr = nodpy.
    gt_zfarpotd_sv-hkont = hkont.
    gt_zfarpotd_sv-zterm = ft_vdata-zterm.
*    gt_zfarpotd_sv-budat = budat.
*    gt_zfarpotd_sv-buzet = sy-uzeit.
*    gt_zfarpotd_sv-bunam = sy-uname.
    APPEND gt_zfarpotd_sv.
  ENDLOOP.

  CLEAR: gt_zfarpotd_sv,gt_zfarpoth_sv.
ENDFORM.                    " F_MOVE_TO_ITAB_SAVE

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TO_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_to_table .
  DATA: lt_zfarpoth LIKE zfarpoth OCCURS 0 WITH HEADER LINE.

  CLEAR t_bdcmsg.
  READ TABLE t_bdcmsg WITH KEY msgtyp = 'S'
                               msgid  = 'F5'
                               msgnr  = '312'.

  CASE 'X'.
    WHEN p_input.
      LOOP AT gt_zfarpoth_sv.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = t_bdcmsg-msgv1
          IMPORTING
            output = gt_zfarpoth_sv-belnr.
        gt_zfarpoth_sv-gjahr = gt_zfarpoth_sv-budat(4).
        gt_zfarpoth_sv-amount = gt_zfarpoth_sv-amount / 100.
        MODIFY gt_zfarpoth_sv TRANSPORTING belnr gjahr amount.
        LOOP AT gt_zfarpotd_sv WHERE noarp = gt_zfarpoth_sv-noarp AND
                                     mjahr = gt_zfarpoth_sv-mjahr.
          gt_zfarpotd_sv-rtvamt = gt_zfarpotd_sv-rtvamt / 100.
          MODIFY gt_zfarpotd_sv TRANSPORTING belnr gjahr rtvamt.
        ENDLOOP.
      ENDLOOP.

      MODIFY zfarpoth FROM TABLE gt_zfarpoth_sv.
      MODIFY zfarpotd FROM TABLE gt_zfarpotd_sv.

      CONCATENATE 'AR Potongan' gt_zfarpoth_sv-noarp 'terposting dg no.'
        gt_zfarpoth_sv-belnr INTO gv_message SEPARATED BY space.

    WHEN p_revrs.
      LOOP AT gt_zfarpoth WHERE check = 'X'.
        MOVE-CORRESPONDING gt_zfarpoth TO lt_zfarpoth.
        APPEND lt_zfarpoth.
      ENDLOOP.

      IF lt_zfarpoth[] IS NOT INITIAL.
        MODIFY zfarpoth FROM TABLE lt_zfarpoth.
        CONCATENATE 'AR Potongan' lt_zfarpoth-noarp 'terreverse dg no.'
          lt_zfarpoth-belnrrev INTO gv_message SEPARATED BY space.
      ENDIF.
  ENDCASE.

  MESSAGE gv_message TYPE 'S'.
ENDFORM.                    " F_SAVE_TO_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_REVERSE_POSTING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_reverse_posting .
  LOOP AT gt_zfarpoth WHERE check = 'X'.
    CLEAR: t_bdcdata,t_bdcmsg.
    REFRESH: t_bdcdata, t_bdcmsg.

    PERFORM f_bdc_data TABLES t_bdcdata USING:
         'X'  'SAPMF05A'      '0105',
         ' '  'BDC_OKCODE'    '=BU',
         ' '  'RF05A-BELNS'   gt_zfarpoth-belnr,
         ' '  'BKPF-BUKRS'    gt_zfarpoth-bukrs,
         ' '  'RF05A-GJAHS'   gt_zfarpoth-gjahr,
         ' '  'UF05A-STGRD'   '01'.

    CALL TRANSACTION 'FB08' USING t_bdcdata
                            MODE 'E'
                            UPDATE 'S'
                            MESSAGES INTO t_bdcmsg.

    READ TABLE t_bdcmsg WITH KEY msgtyp = 'E'.
    IF sy-subrc = 0.
      ROLLBACK WORK.
    ELSE.
      READ TABLE t_bdcmsg WITH KEY msgtyp = 'S'.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
        gt_zfarpoth-belnrrev = t_bdcmsg-msgv1.
        gt_zfarpoth-daterev = sy-datum.
        gt_zfarpoth-userrev = sy-uname.
        MODIFY gt_zfarpoth TRANSPORTING belnrrev daterev userrev.
      ENDIF.
    ENDIF.
  ENDLOOP.

  PERFORM f_save_to_table.
ENDFORM.                    " F_REVERSE_POSTING

*&---------------------------------------------------------------------*
*&      Form  F_CEK_HKONT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_HKONT  text
*----------------------------------------------------------------------*
FORM f_cek_hkont  USING  fu_hkont.
  DATA: ld_saknr LIKE zfacct-saknr.

  CLEAR gv_error.
  SELECT SINGLE saknr INTO ld_saknr
    FROM zfacct
    WHERE bukrs = p_bukrs AND
          vtart = 'BI'    AND
          saknr = fu_hkont.
  IF sy-subrc = 0.
    SELECT SINGLE txt20 INTO txt20
      FROM skat
      WHERE spras = sy-langu  AND
            ktopl = 'TSPC'    AND
            saknr = ld_saknr.
  ELSE.
    gv_error = 'X'.
  ENDIF.
ENDFORM.                    " F_CEK_HKONT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_modify_itab .
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZFARPOTONG'
      subobject               = bukrs
      toyear                  = mjahr
    IMPORTING
      number                  = noarp
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

  gt_zfarpoth_sv-noarp = noarp.
  MODIFY gt_zfarpoth_sv TRANSPORTING noarp WHERE noarp = space.
  gt_zfarpotd_sv-noarp = noarp.
  MODIFY gt_zfarpotd_sv TRANSPORTING noarp WHERE noarp = space.
ENDFORM.                    " F_MODIFY_ITAB

*&---------------------------------------------------------------------*
*&      Form  F_GET_ZTERM
*&---------------------------------------------------------------------*
FORM f_get_zterm .
  SELECT a~zterm a~vtext b~ztag1
    INTO CORRESPONDING FIELDS OF TABLE gt_tvzbt
    FROM tvzbt AS a INNER JOIN t052 AS b ON b~zterm = a~zterm
    WHERE a~spras EQ sy-langu.
ENDFORM.                    " F_GET_ZTERM

*&---------------------------------------------------------------------*
*&      Module  VALUE_ZTERM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_zterm INPUT.
  DATA : lv_zterm TYPE help_info-dynprofld.

*  lv_zterm = 'GT_ZFARPOTD-ZTERM'.
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      retfield    = 'ZTERM'
*      dynpprog    = sy-repid
*      dynpnr      = sy-dynnr
*      dynprofield = lv_zterm
*      value_org   = 'S'
*    TABLES
*      value_tab   = gt_tvzbt.
ENDMODULE.                 " VALUE_ZTERM  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_CEK_DATA
*&---------------------------------------------------------------------*
FORM f_cek_data  CHANGING fc_subrc.
  DATA : lt_vdata   LIKE gt_vdata OCCURS 0 WITH HEADER LINE.

  lt_vdata[] = gt_vdata[].

  LOOP AT lt_vdata.
    IF lt_vdata IS INITIAL.
      DELETE lt_vdata.
    ENDIF.
  ENDLOOP.

  IF lt_vdata[] IS INITIAL.
    fc_subrc = 4.
  ELSE.
    CLEAR fc_subrc.
  ENDIF.
ENDFORM.                    " F_CEK_DATA

*&---------------------------------------------------------------------*
*&      Module  CANCEL  INPUT
*&---------------------------------------------------------------------*
MODULE cancel INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " CANCEL  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_HKONT  INPUT
*&---------------------------------------------------------------------*
MODULE value_hkont INPUT.
  PERFORM f_value_hkont.
ENDMODULE.                 " VALUE_HKONT  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_HKONT
*&---------------------------------------------------------------------*
FORM f_value_hkont .
  TYPES : BEGIN OF ty_ska1,
            saknr TYPE skat-saknr,
            txt20 TYPE skat-txt20,
            txt50 TYPE skat-txt50,
          END OF ty_ska1.

  DATA : lt_ska1   TYPE STANDARD TABLE OF ty_ska1,
         ls_ska1   LIKE LINE OF lt_ska1,
         lt_zfacct TYPE STANDARD TABLE OF zfacct,
         ls_zfacct LIKE LINE OF lt_zfacct,
         lt_skat   TYPE STANDARD TABLE OF skat,
         ls_skat   LIKE LINE OF lt_skat.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : lv_subrc TYPE sy-subrc,
         lv_hkont TYPE ska1-saknr.

  SELECT *
    FROM zfacct
    INTO CORRESPONDING FIELDS OF TABLE lt_zfacct
    WHERE bukrs = p_bukrs
      AND vtart = 'BI'.

  IF lt_zfacct[] IS NOT INITIAL.
    SELECT *
      FROM skat
      INTO CORRESPONDING FIELDS OF TABLE lt_skat
      FOR ALL ENTRIES IN lt_zfacct
      WHERE spras = sy-langu
        AND saknr = lt_zfacct-saknr.
  ENDIF.

  LOOP AT lt_zfacct INTO ls_zfacct.
    ls_ska1-saknr   = ls_zfacct-saknr.
    CLEAR ls_skat.
    READ TABLE lt_skat INTO ls_skat
                       WITH KEY saknr = ls_zfacct-saknr.
    IF sy-subrc = 0.
      ls_ska1-txt20   = ls_skat-txt20.
      ls_ska1-txt50   = ls_skat-txt50.
      APPEND ls_ska1 TO lt_ska1.
    ENDIF.
    CLEAR ls_zfacct.
  ENDLOOP.

  ASSIGN lt_ska1[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'SAKNR' 'HKONT'
                          CHANGING lv_subrc.
ENDFORM.                    " F_VALUE_HKONT

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  TABLES   return_tab STRUCTURE ddshretval
                      USING    fu_retfield fu_dynprofield
                      CHANGING fc_subrc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = fu_retfield
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = fu_dynprofield
      value_org        = 'S'
      callback_program = sy-repid
      callback_form    = 'F4CALLBACK'
    TABLES
      value_tab        = <fs_tab>
      return_tab       = return_tab.
ENDFORM.                    " F_VALUE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  f4callback
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                                                    "f4callback
