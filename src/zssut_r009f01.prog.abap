*----------------------------------------------------------------------*
*   INCLUDE ZTDSFORMTEMPF01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_process_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_report.
  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_process_data.
  PERFORM f_print_data.

  PERFORM f_free_memory.
ENDFORM.                    " f_process_report
*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    " f_init_data
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA: lt_025  LIKE gt_025 OCCURS 0 WITH HEADER LINE,
        lt_kna1 LIKE gt_026 OCCURS 0 WITH HEADER LINE.

  SELECT vkorg vkbur pernr umjah sdate daily_call_num zrelease zprint
    FROM zssutdt025
    INTO TABLE gt_025
    WHERE vkorg EQ p_vkorg
      AND vkbur EQ p_vkbur
      AND pernr IN s_pernr
      AND sdate IN s_datum
      AND daily_call_num IN s_daily
      AND zrelease EQ 'X'.

  lt_025[]  = gt_025[].
  SORT lt_025 BY vkbur daily_call_num umjah.
  DELETE ADJACENT DUPLICATES FROM lt_025 COMPARING vkbur daily_call_num umjah.
  IF lt_025[] IS NOT INITIAL.
    SELECT vkbur daily_call_num kunnr umjah kunn2 eff_call_stat vbeln
      no_call_stat reason_call_id master_stat_indi bistat_indi
      bill_date
      FROM zssutdt026
      INTO TABLE gt_026
      FOR ALL ENTRIES IN lt_025
      WHERE vkbur EQ lt_025-vkbur
        AND daily_call_num  EQ lt_025-daily_call_num
        AND umjah EQ lt_025-umjah.

    lt_kna1[] = gt_026[].
    SORT lt_kna1 BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_kna1 COMPARING kunnr.
    IF lt_kna1[] IS NOT INITIAL.
      SELECT kunnr name1 name2 stras
        FROM kna1
        INTO TABLE gt_kna1
        FOR ALL ENTRIES IN lt_kna1
        WHERE kunnr EQ lt_kna1-kunnr.
    ENDIF.
  ENDIF.

  IF gt_026[] IS NOT INITIAL.
    SELECT vkorg vtweg spart kunnr vkbur kunn2 counter
      FROM zssutdt022
      INTO CORRESPONDING FIELDS OF TABLE gt_022
      FOR ALL ENTRIES IN gt_026
      WHERE vkorg = p_vkorg
        AND vtweg = '10'
        AND spart = '00'
        AND kunnr = gt_026-kunnr
        AND vkbur = p_vkbur
        AND kunn2 = gt_026-kunn2.
  ENDIF.
ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.

ENDFORM.                    " f_validate_data
*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  LOOP AT gt_026.
    READ TABLE gt_022 WITH KEY vkbur = gt_026-vkbur
                               kunnr = gt_026-kunnr
                               kunn2 = gt_026-kunn2.
    IF sy-subrc = 0.
      gt_026-counter = gt_022-counter.
      MODIFY gt_026 TRANSPORTING counter.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  PERFORM f_alv TABLES gt_025.
ENDFORM.                    "F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
FORM f_print_form  USING fu_ucomm.
  DATA: lv_total  TYPE char2,
        lv_count  TYPE char2,
        lt_025    LIKE gt_025 OCCURS 0 WITH HEADER LINE.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
*    d_output_opt-tdimmed  = nast-dimme.
*    d_output_opt-tddelete = nast-delet.
*    d_output_opt-tdcopies = nast-anzal.

    CASE fu_ucomm.
      WHEN '&POS'.
        d_output_opt-tdnoprev = 'X'.
      WHEN '&PREV'.
        d_output_opt-tdnoprint = 'X'.
    ENDCASE.

    d_ctrl_param-no_dialog = space.

    LOOP AT gt_025 WHERE check IS NOT INITIAL.
      lt_025  = gt_025.
      APPEND lt_025.
    ENDLOOP.

    LOOP AT lt_025 WHERE check IS NOT INITIAL.
      AT FIRST.
        d_ctrl_param-no_close = 'X'.
      ENDAT.

      AT LAST.
        d_ctrl_param-no_close = space.
      ENDAT.

      gs_header-vkorg = p_vkorg.

      SELECT SINGLE vtext FROM tvkot INTO gs_header-company WHERE vkorg = p_vkorg AND spras = 'E'.
      SELECT SINGLE bezei FROM tvkbt INTO gs_header-cabang WHERE vkbur = p_vkbur AND spras = 'E'.

      gs_header-tanggal = lt_025-sdate.
      PERFORM f_get_dayname USING lt_025-sdate 'FULL' CHANGING gs_header-hari.

      SELECT SINGLE cname FROM pa0002 INTO gs_header-nama_salesman WHERE pernr = lt_025-pernr.
      gs_header-kode_salesman = lt_025-pernr.

      gs_header-daily_call_num = lt_025-daily_call_num.

      gs_header-reprint = lt_025-zprint.

      PERFORM f_populate_data USING lt_025-daily_call_num lt_025-sdate
                              CHANGING lv_total lv_count.

      IF lv_total GT 25.
        d_ctrl_param-no_close = space.
        gv_end  = 'X'.
        gv_page = '2'.
        gv_pages = '2'.
        CALL FUNCTION d_smrt_funcmod
          EXPORTING
            control_parameters = d_ctrl_param
            output_options     = d_output_opt
            user_settings      = space
            gs_header          = gs_header
            gv_end             = gv_end
            gv_page            = gv_page
            gv_pages           = gv_pages.

        CLEAR: gs_header.
      ENDIF.

      IF fu_ucomm EQ '&POS'.
        UPDATE zssutdt025 SET zprint = 'X'
                        WHERE vkorg EQ lt_025-vkorg
                          AND vkbur EQ lt_025-vkbur
                          AND pernr EQ lt_025-pernr
                          AND umjah EQ lt_025-umjah
                          AND sdate EQ lt_025-sdate
                          AND daily_call_num EQ lt_025-daily_call_num.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_print_form
*&---------------------------------------------------------------------*
*&      Form  f_free_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
  CLEAR:  gt_detail, gt_detail[], wa_header.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF p_vkbur IS NOT INITIAL.
    AUTHORITY-CHECK OBJECT  'V_VBKA_VKO'
            ID 'VKBUR' FIELD p_vkbur
            ID 'ACTVT' FIELD '01'.
    IF sy-subrc NE 0.
      MESSAGE e000(zab) WITH
      'You have no authorization for Sales Office' p_vkbur.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_GET_DAYNAME
*&---------------------------------------------------------------------*
FORM f_get_dayname USING date mode CHANGING weekday.
  DATA: day_p TYPE p.

  day_p = date MOD 7.
* DAY_P enthält 0 für Samstag, 1 für Sonntag, etc.. und muß
* der Kalendernotation: 1 für Montag, 2 für Dienstag, etc.,
* angepaßt werden.
  IF day_p > 1.
    day_p = day_p - 1.
  ELSE.
    day_p = day_p + 6.
  ENDIF.

  CASE day_p.
    WHEN 1.
      weekday = 'mon'.
      IF mode = 'FULL'.
        weekday = 'Senin'.
      ENDIF.
    WHEN 2.
      weekday = 'tue'.
      IF mode = 'FULL'.
        weekday = 'Selasa'.
      ENDIF.
    WHEN 3.
      weekday = 'wed'.
      IF mode = 'FULL'.
        weekday = 'Rabu'.
      ENDIF.
    WHEN 4.
      weekday = 'thu'.
      IF mode = 'FULL'.
        weekday = 'Kamis'.
      ENDIF.
    WHEN 5.
      weekday = 'fri'.
      IF mode = 'FULL'.
        weekday = 'Jumat'.
      ENDIF.
    WHEN 6.
      weekday = 'sat'.
      IF mode = 'FULL'.
        weekday = 'Sabtu'.
      ENDIF.
    WHEN 7.
      weekday = 'sun'.
      IF mode = 'FULL'.
        weekday = 'Minggu'.
      ENDIF.
  ENDCASE.
  TRANSLATE weekday TO UPPER CASE.
ENDFORM.                    " F_GET_DAYNAME

*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_DATA
*&---------------------------------------------------------------------*
FORM f_populate_data USING fu_daily fu_sdate
                     CHANGING fc_total fc_count.
  DATA: lv_ctabi    TYPE char2,
        lv_count    TYPE char2,
        lv_fname    TYPE char30,
        lv_lines    TYPE i,
        lwa_header  TYPE zssutst010.

  FIELD-SYMBOLS <fs>.

  CLEAR: gt_itab, gt_itab[].

  SORT gt_026 BY daily_call_num counter.
  LOOP AT gt_026 WHERE daily_call_num EQ fu_daily.
    CLEAR gt_itab.
    MOVE-CORRESPONDING gt_026 TO gt_itab.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gt_itab-kunnr
      IMPORTING
        output = gt_itab-kunnr.
    READ TABLE gt_kna1 WITH KEY kunnr = gt_026-kunnr.
    IF sy-subrc = 0.
      gt_itab-name1 = gt_kna1-name1.
      IF gt_kna1-name2 IS NOT INITIAL.
        gt_itab-addrs = gt_kna1-name2.
      ELSE.
        gt_itab-addrs = gt_kna1-stras.
      ENDIF.
    ENDIF.
    APPEND gt_itab.
    CLEAR gt_itab.
  ENDLOOP.

  DESCRIBE TABLE gt_itab LINES fc_total.
  IF fc_total LT 25.
    lv_lines  = 25 - fc_total.
    DO lv_lines TIMES.
      APPEND gt_itab.
    ENDDO.
  ELSEIF fc_total GT 25.
    lv_lines  = 50 - fc_total.
    DO lv_lines TIMES.
      APPEND gt_itab.
    ENDDO.
  ENDIF.

  gs_header-total_call = fc_total.
  CONCATENATE p_vkbur '-' fu_sdate(4) '-' fu_daily INTO gs_header-kode_dok.

  lwa_header  = gs_header.

  LOOP AT gt_itab.
    ADD 1 TO lv_ctabi.
    ADD 1 TO lv_count.

    CONCATENATE 'GS_HEADER-NOU' lv_count INTO lv_fname. CONDENSE lv_fname.
    ASSIGN (lv_fname) TO <fs>.
    <fs> = lv_ctabi.
    CONCATENATE 'GS_HEADER-NAMA_TOKO' lv_count INTO lv_fname. CONDENSE lv_fname.
    ASSIGN (lv_fname) TO <fs>.
    <fs> = gt_itab-name1.
    CONCATENATE 'GS_HEADER-KODE_TOKO' lv_count INTO lv_fname. CONDENSE lv_fname.
    ASSIGN (lv_fname) TO <fs>.
    <fs> = gt_itab-kunnr.
    CONCATENATE 'GS_HEADER-KODE_ROUTE_LIST' lv_count INTO lv_fname. CONDENSE lv_fname.
    ASSIGN (lv_fname) TO <fs>.
    <fs> = gt_itab-kunn2.

    IF fc_total GT 25.
      d_ctrl_param-no_close = 'X'.
      fc_count  = lv_count.
      CLEAR gv_end.
      gv_page   = '1'.
      gv_pages  = '2'.
    ELSE.
      gv_end   = 'X'.
      gv_page   = '1'.
      gv_pages  = '1'.
    ENDIF.

    IF lv_ctabi EQ 25.
      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          gs_header          = gs_header
          gv_end             = gv_end
          gv_page            = gv_page
          gv_pages           = gv_pages.

      d_ctrl_param-no_open = 'X'.
      CLEAR: gs_header, lv_count.
      gs_header = lwa_header.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_POPULATE_DATA

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
*       FORM F_FIELDCAT
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING ft_report:
    'DAILY_CALL_NUM' '' '' '' '12' 'Daily Call#' '' '' '' '' '' '' '' '' '' '',
    'PERNR' 'ZSSUTDT025' 'PERNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SDATE' 'ZSSUTDT025' 'SDATE' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ZRELEASE' '' '' '' '8' 'Released' '' '' '' '' '' '' '' '' '' '',
    'ZPRINT' '' '' '' '7' 'Printed' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.                    " F_FIELDCAT

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
  ld_sort-fieldname = 'DAILY_CALL_NUM'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "F_BUILD_SORTFIELD

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

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'TOEXECUTE'.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_print_form USING fu_ucomm.
      LEAVE TO SCREEN 0.
    WHEN '&PREV'.
      PERFORM f_print_form USING fu_ucomm.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

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
