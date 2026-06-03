*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM f_init_data                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA: ld_complete_filename LIKE pcfile-path.

* Split filename
  ld_complete_filename = work_di1.
  CALL FUNCTION 'PC_SPLIT_COMPLETE_FILENAME'
    EXPORTING
      complete_filename = ld_complete_filename
    IMPORTING
      extension         = gd_extension
    EXCEPTIONS
      invalid_drive     = 1
      invalid_extension = 2
      invalid_name      = 3
      invalid_path      = 4
      OTHERS            = 5.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*  -->  FU_EXTENSION                                                  *
*---------------------------------------------------------------------*
FORM f_get_data USING fu_extension.
  DATA: lt_upload   LIKE t_upload OCCURS 0 WITH HEADER LINE,
        lt_rout     LIKE t_upload OCCURS 0 WITH HEADER LINE,
        ld_strlen   TYPE i,
        ld_numc(10) TYPE n.

  CASE fu_extension.
    WHEN 'XLS' OR 'xls'.
      CALL SELECTION-SCREEN 500 STARTING AT 10 5.
      IF sy-subrc = 0.
        PERFORM f_upload_xls TABLES t_upload
                             USING  work_di1.
      ENDIF.
    WHEN 'CSV' OR 'csv' OR 'TXT' OR 'txt'.
      PERFORM f_upload_csv TABLES t_upload
                           USING  work_di1.
    WHEN OTHERS.
      MESSAGE 'File extension not supported' TYPE 'I'.
      STOP.
  ENDCASE.

  IF t_upload[] IS INITIAL.
    MESSAGE 'No Data' TYPE 'S'.
    STOP.
  ENDIF.

* Koreksi KUNNR ('0') dan collect kunnr
  LOOP AT t_upload.
    ld_strlen = strlen( t_upload-kunnr ).
    IF ld_strlen = 9.
      CONCATENATE '0' t_upload-kunnr INTO t_upload-kunnr.
    ENDIF.

    lt_upload-kunnr = t_upload-kunnr.
    COLLECT lt_upload. CLEAR lt_upload.

    IF t_upload-kunn2 CA gc_alfabet1 OR
       t_upload-kunn2 CA gc_alfabet2.
      lt_rout-kunnr = t_upload-kunn2.
    ELSE.
      ld_numc = t_upload-kunn2.
      lt_rout-kunnr = ld_numc.
      t_upload-kunn2 = lt_rout-kunnr.
*    lt_rout-kunnr = t_upload-kunn2.
    ENDIF.
    CLEAR: ld_numc.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = t_upload-kunn2
      IMPORTING
        output = ld_numc.
    IF sy-subrc EQ 0.
      t_upload-kunn2 = ld_numc.
    ENDIF.

    COLLECT lt_rout. CLEAR: lt_rout,ld_numc.

    MODIFY t_upload TRANSPORTING kunnr kunn2.

    PERFORM f_change_flag USING t_upload-sun1.
    PERFORM f_change_flag USING t_upload-mon1.
    PERFORM f_change_flag USING t_upload-tue1.
    PERFORM f_change_flag USING t_upload-wed1.
    PERFORM f_change_flag USING t_upload-thu1.
    PERFORM f_change_flag USING t_upload-fri1.
    PERFORM f_change_flag USING t_upload-sat1.
    PERFORM f_change_flag USING t_upload-sun2.
    PERFORM f_change_flag USING t_upload-mon2.
    PERFORM f_change_flag USING t_upload-tue2.
    PERFORM f_change_flag USING t_upload-wed2.
    PERFORM f_change_flag USING t_upload-thu2.
    PERFORM f_change_flag USING t_upload-fri2.
    PERFORM f_change_flag USING t_upload-sat2.
    PERFORM f_change_flag USING t_upload-sun3.
    PERFORM f_change_flag USING t_upload-mon3.
    PERFORM f_change_flag USING t_upload-tue3.
    PERFORM f_change_flag USING t_upload-wed3.
    PERFORM f_change_flag USING t_upload-thu3.
    PERFORM f_change_flag USING t_upload-fri3.
    PERFORM f_change_flag USING t_upload-sat3.
    PERFORM f_change_flag USING t_upload-sun4.
    PERFORM f_change_flag USING t_upload-mon4.
    PERFORM f_change_flag USING t_upload-tue4.
    PERFORM f_change_flag USING t_upload-wed4.
    PERFORM f_change_flag USING t_upload-thu4.
    PERFORM f_change_flag USING t_upload-fri4.
    PERFORM f_change_flag USING t_upload-sat4.
    PERFORM f_change_flag USING t_upload-sun5.
    PERFORM f_change_flag USING t_upload-mon5.
    PERFORM f_change_flag USING t_upload-tue5.
    PERFORM f_change_flag USING t_upload-wed5.
    PERFORM f_change_flag USING t_upload-thu5.
    PERFORM f_change_flag USING t_upload-fri5.
    PERFORM f_change_flag USING t_upload-sat5.

    MODIFY t_upload TRANSPORTING sun1 mon1 tue1 wed1 thu1 fri1 sat1
                                 sun2 mon2 tue2 wed2 thu2 fri2 sat2
                                 sun3 mon3 tue3 wed3 thu3 fri3 sat3
                                 sun4 mon4 tue4 wed4 thu4 fri4 sat4
                                 sun5 mon5 tue5 wed5 thu5 fri5 sat5.
  ENDLOOP.

  IF lt_upload[] IS NOT INITIAL.
* Get customer name
    SELECT kunnr name1 vkbur INTO TABLE t_kna1
      FROM kna1vv
      FOR ALL ENTRIES IN lt_upload
      WHERE kunnr = lt_upload-kunnr
        AND vkbur = pa_vkbur.

* Get customer routelist
    SELECT * INTO TABLE t_rout
      FROM knvp
      FOR ALL ENTRIES IN lt_upload
      WHERE kunnr = lt_upload-kunnr
        AND vkorg = pa_vkorg
        AND vtweg = pa_vtweg
        AND spart = pa_spart
        AND parvw = 'ZS'.
  ENDIF.

  IF lt_rout[] IS NOT INITIAL.
* Get routelist salesman
    SELECT * INTO TABLE t_slsmn
      FROM knvp
      FOR ALL ENTRIES IN lt_rout
      WHERE kunnr = lt_rout-kunnr
        AND vkorg = pa_vkorg
        AND vtweg = pa_vtweg
        AND spart = pa_spart
        AND parvw = 'VE'.
  ENDIF.
ENDFORM.                    "f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA : lt_count LIKE t_upload OCCURS 0 WITH HEADER LINE,
         lv_lines TYPE int4.

  SORT t_upload BY kunnr kunn2.
  SORT t_kna1 BY kunnr.
  SORT t_rout BY kunnr kunn2.
  SORT t_slsmn BY kunnr.

  lt_count[] = t_upload[].

  LOOP AT t_upload.
    CLEAR t_kna1.
    READ TABLE t_kna1 WITH KEY kunnr = t_upload-kunnr BINARY SEARCH.
    MOVE-CORRESPONDING t_upload TO t_out.
    t_out-name1 = t_kna1-name1.
    t_out-vkbur = t_kna1-vkbur.
    t_out-vkorg = pa_vkorg.
    t_out-vtweg = pa_vtweg.
    t_out-spart = pa_spart.

* Cek routelist
    CLEAR: t_rout,t_slsmn,t_out-msg,t_out-icon.
    READ TABLE t_rout WITH KEY kunnr = t_upload-kunnr
                               kunn2 = t_upload-kunn2 BINARY SEARCH.
    IF sy-subrc = 0.
      t_out-icon = '@08@'.

* Cek salesman
      READ TABLE t_slsmn WITH KEY kunnr = t_rout-kunn2
                                  pernr = t_upload-pernr.
      IF sy-subrc = 0.
        t_out-icon = '@08@'.
      ELSE.
        t_out-msg = '2'.            "2. Salesman salah
        t_out-icon = '@0A@'.
      ENDIF.
    ELSE.
      t_out-msg = '1'.              "1. Routelist salah
      t_out-icon = '@0A@'.
    ENDIF.

    IF t_out-msg IS INITIAL.
      t_out-icon = '@08@'.
      IF t_out-counter IS INITIAL.
        t_out-msg = '3'.              "3. Counter kosong
        t_out-icon = '@0A@'.
      ENDIF.
    ENDIF.

    IF t_out-msg IS INITIAL.
      t_out-icon = '@08@'.
      CLEAR lv_lines.
      LOOP AT lt_count WHERE counter = t_out-counter.
        ADD 1 TO lv_lines.
      ENDLOOP.
      IF lv_lines > 1.
        t_out-msg = '4'.              "4. Double counter
        t_out-icon = '@0A@'.
      ENDIF.
    ENDIF.

    t_out-zuser = sy-uname.
    t_out-zdatum = sy-datum.

    APPEND t_out.
  ENDLOOP.
ENDFORM.                    " f_process_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  PERFORM f_alv TABLES t_out.
ENDFORM.                    "f_print_data

*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
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
      is_print                 = d_print
    TABLES
      t_outtab                 = ft_report
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
ENDFORM.                    "f_alv

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
*    'CHKBOX' '' '' '' '1' '' '' '' '' '' '' '' '' 'X' '' 'X' 'X' '',
    'ICON' '' '' '' '6' 'Status' '' '' '' '' '' '' '' '' 'X' '' '' 'X',
    'PERNR' 'ZSSUTDT022' 'PERNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KUNN2' 'ZSSUTDT022' 'KUNN2' '' '' 'Routelist' '' '' '' '' '' '' '' '' '' '' '' '',
    'KUNNR' 'ZSSUTDT022' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VKBUR' 'KNVV' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SUN1' 'ZSSUTDT022' 'SUN1' '' '' 'Sun1' '' '' '' '' '' '' '' '' '' '' '' '',
    'MON1' 'ZSSUTDT022' 'MON1' '' '' 'Mon1' '' '' '' '' '' '' '' '' '' '' '' '',
    'TUE1' 'ZSSUTDT022' 'TUE1' '' '' 'Tue1' '' '' '' '' '' '' '' '' '' '' '' '',
    'WED1' 'ZSSUTDT022' 'WED1' '' '' 'Wed1' '' '' '' '' '' '' '' '' '' '' '' '',
    'THU1' 'ZSSUTDT022' 'THU1' '' '' 'Thu1' '' '' '' '' '' '' '' '' '' '' '' '',
    'FRI1' 'ZSSUTDT022' 'FRI1' '' '' 'Fri1' '' '' '' '' '' '' '' '' '' '' '' '',
    'SAT1' 'ZSSUTDT022' 'SAT1' '' '' 'Sat1' '' '' '' '' '' '' '' '' '' '' '' '',
    'SUN2' 'ZSSUTDT022' 'SUN2' '' '' 'Sun2' '' '' '' '' '' '' '' '' '' '' '' '',
    'MON2' 'ZSSUTDT022' 'MON2' '' '' 'Mon2' '' '' '' '' '' '' '' '' '' '' '' '',
    'TUE2' 'ZSSUTDT022' 'TUE2' '' '' 'Tue2' '' '' '' '' '' '' '' '' '' '' '' '',
    'WED2' 'ZSSUTDT022' 'WED2' '' '' 'Wed2' '' '' '' '' '' '' '' '' '' '' '' '',
    'THU2' 'ZSSUTDT022' 'THU2' '' '' 'Thu2' '' '' '' '' '' '' '' '' '' '' '' '',
    'FRI2' 'ZSSUTDT022' 'FRI2' '' '' 'Fri2' '' '' '' '' '' '' '' '' '' '' '' '',
    'SAT2' 'ZSSUTDT022' 'SAT2' '' '' 'Sat2' '' '' '' '' '' '' '' '' '' '' '' '',
    'SUN3' 'ZSSUTDT022' 'SUN3' '' '' 'Sun3' '' '' '' '' '' '' '' '' '' '' '' '',
    'MON3' 'ZSSUTDT022' 'MON3' '' '' 'Mon3' '' '' '' '' '' '' '' '' '' '' '' '',
    'TUE3' 'ZSSUTDT022' 'TUE3' '' '' 'Tue3' '' '' '' '' '' '' '' '' '' '' '' '',
    'WED3' 'ZSSUTDT022' 'WED3' '' '' 'Wed3' '' '' '' '' '' '' '' '' '' '' '' '',
    'THU3' 'ZSSUTDT022' 'THU3' '' '' 'Thu3' '' '' '' '' '' '' '' '' '' '' '' '',
    'FRI3' 'ZSSUTDT022' 'FRI3' '' '' 'Fri3' '' '' '' '' '' '' '' '' '' '' '' '',
    'SAT3' 'ZSSUTDT022' 'SAT3' '' '' 'Sat3' '' '' '' '' '' '' '' '' '' '' '' '',
    'SUN4' 'ZSSUTDT022' 'SUN4' '' '' 'Sun4' '' '' '' '' '' '' '' '' '' '' '' '',
    'MON4' 'ZSSUTDT022' 'MON4' '' '' 'Mon4' '' '' '' '' '' '' '' '' '' '' '' '',
    'TUE4' 'ZSSUTDT022' 'TUE4' '' '' 'Tue4' '' '' '' '' '' '' '' '' '' '' '' '',
    'WED4' 'ZSSUTDT022' 'WED4' '' '' 'Wed4' '' '' '' '' '' '' '' '' '' '' '' '',
    'THU4' 'ZSSUTDT022' 'THU4' '' '' 'Thu4' '' '' '' '' '' '' '' '' '' '' '' '',
    'FRI4' 'ZSSUTDT022' 'FRI4' '' '' 'Fri4' '' '' '' '' '' '' '' '' '' '' '' '',
    'SAT4' 'ZSSUTDT022' 'SAT4' '' '' 'Sat4' '' '' '' '' '' '' '' '' '' '' '' '',
    'SUN4' 'ZSSUTDT022' 'SUN5' '' '' 'Sun5' '' '' '' '' '' '' '' '' '' '' '' '',
    'MON5' 'ZSSUTDT022' 'MON5' '' '' 'Mon5' '' '' '' '' '' '' '' '' '' '' '' '',
    'TUE5' 'ZSSUTDT022' 'TUE5' '' '' 'Tue5' '' '' '' '' '' '' '' '' '' '' '' '',
    'WED5' 'ZSSUTDT022' 'WED5' '' '' 'Wed5' '' '' '' '' '' '' '' '' '' '' '' '',
    'THU5' 'ZSSUTDT022' 'THU5' '' '' 'Thu5' '' '' '' '' '' '' '' '' '' '' '' '',
    'FRI5' 'ZSSUTDT022' 'FRI5' '' '' 'Fri5' '' '' '' '' '' '' '' '' '' '' '' '',
    'SAT5' 'ZSSUTDT022' 'SAT5' '' '' 'Sat5' '' '' '' '' '' '' '' '' '' '' '' '',
    'COUNTER' 'ZSSUTDT022' 'COUNTER' '' '' 'Counter' '' '' '' '' '' '' '' '' ''
    '' '' ''.
ENDFORM.                    " F_FIELDCAT

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
                          VALUE(fu_icon)
                          VALUE(fu_input)
                          VALUE(fu_edit)
                          VALUE(fu_hotspot).

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
  ld_fieldcat-icon              = fu_icon.
  ld_fieldcat-input             = fu_input.
  ld_fieldcat-edit              = fu_edit.
  ld_fieldcat-hotspot           = fu_hotspot.
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
  fu_layout-box_fieldname      = 'CHKBOX'.
ENDFORM.                    "f_build_layout

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
  ld_sort-fieldname = 'COUNTER'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'PERNR'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'KUNN2'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'KUNNR'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  DATA: ld_text(50).

*  CONCATENATE 'Paket:' pa_paket INTO ld_text SEPARATED BY space.
*  IF pa_rewrd IS NOT INITIAL.
*    CONCATENATE ld_text 'Point Reward' INTO ld_text SEPARATED BY ' - '.
*  ENDIF.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ld_text.
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
  REFRESH: t_upload,t_out.
  CLEAR: t_upload,t_out.
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
  SET PF-STATUS 'STANDARD'.
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

    WHEN '&LOG'.
      PERFORM f_error_log.
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
  DATA: lt_out LIKE t_out OCCURS 0 WITH HEADER LINE.

  lt_out[] = t_out[].
  DELETE lt_out WHERE chkbox IS INITIAL.
  DELETE lt_out WHERE msg NE space.

  IF lt_out[] IS INITIAL.
    MESSAGE 'No data uploaded' TYPE 'S'.
  ELSE.
    PERFORM f_modify_table TABLES lt_out.

    MODIFY zssutdt022 FROM TABLE lt_out.

    IF sy-subrc = 0.
      PERFORM f_submit_zsfasd_i0010.

      MESSAGE 'Successfully uploaded' TYPE 'S'.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
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
*&      Form  F_CHECK_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WORK_DI1  text
*----------------------------------------------------------------------*
FORM f_check_filename USING p_work_di1.
  DATA: ld_work_di1 LIKE work_di1.

  ld_work_di1  = p_work_di1.
  TRANSLATE ld_work_di1 TO UPPER CASE.
  FIND '.CSV' IN ld_work_di1.
  IF sy-subrc NE 0.
    MESSAGE e000(zab) WITH 'File Upload harus dalam format CSV (Tab Delimited)'.
  ENDIF.
ENDFORM.                    " F_CHECK_FILENAME

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_CSV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_UPLOAD  text
*      -->P_WORK_DI1  text
*----------------------------------------------------------------------*
FORM f_upload_csv  TABLES   p_t_upload STRUCTURE t_upload
                   USING    p_work_di1.
  DATA: ld_filelength TYPE i,
        ld_filename   TYPE string.

  ld_filename = p_work_di1.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = ld_filename
      filetype                = 'ASC'
      has_field_separator     = 'X'
    IMPORTING
      filelength              = ld_filelength
    TABLES
      data_tab                = p_t_upload
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

  IF sy-subrc = 0.
    DELETE p_t_upload WHERE pernr IS INITIAL.
  ELSE.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " F_UPLOAD_CSV

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_XLS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_UPLOAD  text
*      -->P_WORK_DI1  text
*----------------------------------------------------------------------*
FORM f_upload_xls  TABLES   p_t_upload STRUCTURE t_upload
                   USING    p_work_di1.

  REFRESH i_excel.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_work_di1                "INPUT FROM SELECTION SCREEN
      i_begin_col             = pa_col
      i_begin_row             = pa_row
      i_end_col               = 39
      i_end_row               = 60000
    TABLES
      intern                  = i_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF i_excel[] IS INITIAL.
    EXIT.
  ENDIF.

  CLEAR wa_excel.
  SORT i_excel BY row col value.

  LOOP AT i_excel INTO wa_excel.
    CASE wa_excel-col.
      WHEN '0001'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-pernr.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO DATA(err).
        ENDTRY.
      WHEN '0002'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-kunn2.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0003'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-kunnr.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0004'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-sun1.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0005'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-mon1.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0006'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-tue1.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0007'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-wed1.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0008'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-thu1.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0009'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-fri1.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0010'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-sat1.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0011'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-sun2.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0012'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-mon2.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0013'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-tue2.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0014'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-wed2.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0015'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-thu2.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0016'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-fri2.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0017'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-sat2.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0018'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-sun3.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0019'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-mon3.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0020'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-tue3.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0021'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-wed3.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0022'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-thu3.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0023'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-fri3.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0024'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-sat3.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0025'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-sun4.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0026'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-mon4.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0027'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-tue4.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0028'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-wed4.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0029'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-thu4.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0030'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-fri4.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0031'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-sat4.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0032'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-sun5.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0033'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-mon5.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0034'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-tue5.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0035'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-wed5.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0036'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-thu5.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0037'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-fri5.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0038'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-sat5.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
        ENDTRY.
      WHEN '0039'.
        TRY.
            MOVE wa_excel-value TO p_t_upload-counter.
            "p_t_upload-counter = wa_excel-value.
          CATCH cx_sy_conversion_exact_not_sup
            cx_sy_conversion_error INTO err.
            "            cx_sy_move_cast_error.
        ENDTRY.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
    CLEAR wa_excel.
    AT END OF row.
      APPEND p_t_upload. CLEAR  p_t_upload.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " F_UPLOAD_XLS

*&---------------------------------------------------------------------*
*&      Form  F_INIT_VKORG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_vkorg .
  SELECT SINGLE parva
    FROM usr05
    INTO pa_vkorg
    WHERE bname EQ sy-uname AND
          parid EQ 'VKO'.

  SELECT SINGLE parva
    FROM usr05
    INTO pa_vkbur
    WHERE bname EQ sy-uname AND
          parid EQ 'GSB'.
ENDFORM.                    " F_INIT_VKORG

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_FLAG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_FLAG  text
*----------------------------------------------------------------------*
FORM f_change_flag  USING    fu_flag.
  IF fu_flag IS NOT INITIAL AND fu_flag NE 'X'.
    fu_flag = 'X'.
  ENDIF.
ENDFORM.                    " F_CHANGE_FLAG

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data  TABLES   ft_upload STRUCTURE t_upload
                      CHANGING fc_subrc.


ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LOG
*&---------------------------------------------------------------------*
FORM f_error_log .
  CALL SCREEN 100 STARTING AT 10 10 ENDING AT 130 22.
ENDFORM.                    " F_ERROR_LOG

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING  OUTPUT
*&---------------------------------------------------------------------*
MODULE list_processing OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_error_list.
ENDMODULE.                 " LIST_PROCESSING  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LIST
*&---------------------------------------------------------------------*
FORM f_error_list .
  DATA : lv_zebra(1),
         lv_mess(60).

  ULINE AT /(98).
  FORMAT COLOR COL_HEADING.
  WRITE: /  sy-vline NO-GAP, (4) 'Sts.' NO-GAP,
            sy-vline NO-GAP, (30) 'Customer No.' NO-GAP,
            sy-vline NO-GAP, (60) 'Error message' NO-GAP,
            sy-vline.
  ULINE AT /(98).
  LOOP AT t_out.
    IF t_out-msg IS NOT INITIAL.
      PERFORM f_zebra CHANGING lv_zebra.
      CASE t_out-msg.
        WHEN 1.
          lv_mess = 'Routelist salah'.
          WRITE: /  sy-vline NO-GAP, (4) icon_led_red NO-GAP,
                    sy-vline NO-GAP, (30) t_out-kunnr NO-GAP,
                    sy-vline NO-GAP, lv_mess(60) NO-GAP,
                    sy-vline NO-GAP.
        WHEN 2.
          lv_mess = 'Salesman salah'.
          WRITE: /  sy-vline NO-GAP, (4) icon_led_red NO-GAP,
                    sy-vline NO-GAP, (30) t_out-kunnr NO-GAP,
                    sy-vline NO-GAP, lv_mess(60) NO-GAP,
                    sy-vline NO-GAP.
        WHEN 3.
          lv_mess = 'Counter kosong / blank'.
          WRITE: /  sy-vline NO-GAP, (4) icon_led_red NO-GAP,
                    sy-vline NO-GAP, (30) t_out-kunnr NO-GAP,
                    sy-vline NO-GAP, lv_mess(60) NO-GAP,
                    sy-vline NO-GAP.
        WHEN 4.
          lv_mess = 'Double counter'.
          WRITE: /  sy-vline NO-GAP, (4) icon_led_red NO-GAP,
                    sy-vline NO-GAP, (30) t_out-kunnr NO-GAP,
                    sy-vline NO-GAP, lv_mess(60) NO-GAP,
                    sy-vline NO-GAP.
      ENDCASE.
    ENDIF.
  ENDLOOP.
  ULINE AT /(98).
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
*&      Form  F_CHECK_DATA
*&---------------------------------------------------------------------*
FORM f_check_data .
  DATA : lt_out   LIKE t_out OCCURS 0.

  lt_out[]  = t_out[].
  SORT lt_out BY vkorg vtweg spart kunnr vkbur.
  DELETE ADJACENT DUPLICATES FROM lt_out
  COMPARING vkorg vtweg spart kunnr vkbur.

  IF lt_out[] IS NOT INITIAL.
    SELECT *
      FROM zssutdt022
      INTO CORRESPONDING FIELDS OF TABLE gt_022
      FOR ALL ENTRIES IN lt_out
      WHERE vkorg = lt_out-vkorg
        AND vtweg = lt_out-vtweg
        AND spart = lt_out-spart
        AND kunnr = lt_out-kunnr
        AND vkbur = lt_out-vkbur.
  ENDIF.
ENDFORM.                    " F_CHECK_DATA

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TABLE
*&---------------------------------------------------------------------*
FORM f_modify_table  TABLES  ft_out STRUCTURE t_out.
  DATA : ls_022   LIKE LINE OF gt_022.

  LOOP AT ft_out.
    READ TABLE gt_022 INTO ls_022 WITH KEY vkorg = ft_out-vkorg
                                           vtweg = ft_out-vtweg
                                           spart = ft_out-spart
                                           kunnr = ft_out-kunnr
                                           vkbur = ft_out-vkbur.
    IF sy-subrc = 0.
      IF ls_022-kunn2 <> ft_out-kunn2.
        ft_out-xkunn2 = ls_022-kunn2.
      ELSE.
        ft_out-xkunn2 = ls_022-xkunn2.
      ENDIF.
      IF ls_022-pernr <> ft_out-pernr.
        ft_out-xpernr = ls_022-pernr.
      ELSE.
        ft_out-xpernr = ls_022-xpernr.
      ENDIF.
      MODIFY ft_out TRANSPORTING xkunn2 xpernr.

      DELETE FROM zssutdt022 WHERE vkorg = ft_out-vkorg
                               AND vtweg = ft_out-vtweg
                               AND spart = ft_out-spart
                               AND kunnr = ft_out-kunnr
                               AND vkbur = ft_out-vkbur.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_SUBMIT_ZSFASD_I0010
*&---------------------------------------------------------------------*
FORM f_submit_zsfasd_i0010 .
  DATA : rspar_tab  TYPE TABLE OF rsparams,
         rspar_line LIKE LINE OF rspar_tab.

  rspar_line-selname = 'P_VKORG'.
  rspar_line-kind    = 'P'.
  rspar_line-sign    = 'I'.
  rspar_line-option  = 'EQ'.
  rspar_line-low     = pa_vkorg.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.
  rspar_line-selname = 'P_VTWEG'.
  rspar_line-kind    = 'P'.
  rspar_line-sign    = 'I'.
  rspar_line-option  = 'EQ'.
  rspar_line-low     = pa_vtweg.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.
  rspar_line-selname = 'P_SPART'.
  rspar_line-kind    = 'P'.
  rspar_line-sign    = 'I'.
  rspar_line-option  = 'EQ'.
  rspar_line-low     = pa_spart.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.
  rspar_line-selname = 'P_VKBUR'.
  rspar_line-kind    = 'P'.
  rspar_line-sign    = 'I'.
  rspar_line-option  = 'EQ'.
  rspar_line-low     = pa_vkbur.
  APPEND rspar_line TO rspar_tab.
  CLEAR rspar_line.

  SUBMIT zsfasd_i0010 WITH SELECTION-TABLE rspar_tab AND RETURN.
ENDFORM.                    " F_SUBMIT_ZSFASD_I0010
