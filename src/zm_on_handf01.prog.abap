*----------------------------------------------------------------------*
*   INCLUDE ZM_ON_HANDF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA: lr_lines  LIKE LINE OF gr_vfdat1,
        lv_vfdat  TYPE sy-datum.

* Get range aging
  CONCATENATE pa_lfgja pa_lfmon '01' INTO lv_vfdat.

  lr_lines-low    = '00000000'.
  lr_lines-high   = lv_vfdat - 1.
  lr_lines-sign   = 'I'.
  lr_lines-option = 'BT'.
  APPEND lr_lines TO gr_vfdat1.

  PERFORM f_get_month_names USING '' lr_lines-high+4(2)
                                  '' lr_lines-high(4)
                            CHANGING gv_header01.

  PERFORM f_get_aging USING aging1 '' '2'
                      CHANGING lv_vfdat.
  PERFORM f_get_aging USING aging2 aging1 '3'
                      CHANGING lv_vfdat.
  PERFORM f_get_aging USING aging3 aging2 '4'
                      CHANGING lv_vfdat.

  lr_lines-low    = lv_vfdat.
  lr_lines-high   = '99991231'.
  lr_lines-sign   = 'I'.
  lr_lines-option = 'BT'.
  APPEND lr_lines TO gr_vfdat5.
  PERFORM f_get_month_names USING lr_lines-low+4(2) ''
                                  lr_lines-low(4) ''
                            CHANGING gv_header05.

  SELECT werks
    FROM t001w
    INTO TABLE gt_t001w
    WHERE werks IN so_werks.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: lr_lines  LIKE LINE OF gr_werks,
        lv_spmon  TYPE spmon.

  DATA: lt_mchb   LIKE gt_mchb OCCURS 0 WITH HEADER LINE.

  CONCATENATE pa_lfgja pa_lfmon INTO lv_spmon.

  LOOP AT gt_t001w.
    AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
       ID 'ACTVT' FIELD '03'
       ID 'WERKS' FIELD gt_t001w-werks.
    IF sy-subrc EQ 0.
      lr_lines-low    = gt_t001w-werks.
      lr_lines-sign   = 'I'.
      lr_lines-option = 'EQ'.
      APPEND lr_lines TO gr_werks.
    ENDIF.
  ENDLOOP.

  SELECT a~matnr werks lgort meins ean11 bismt maktx
    FROM mard AS a JOIN mara AS b ON a~matnr EQ b~matnr
                   JOIN makt AS c ON a~matnr EQ c~matnr
    INTO TABLE gt_mara
    WHERE a~matnr IN so_matnr AND
          werks   IN gr_werks AND
          lgort   IN so_lgort AND
          a~lvorm EQ space    AND
          spras   EQ sy-langu.

  CHECK gt_mara[] IS NOT INITIAL.

**  LOOP AT gt_mara.
**    CALL FUNCTION 'ZGET_MEAN'
**      EXPORTING
**        zmatnr = gt_mara-matnr
**      IMPORTING
**        zean11 = gt_mara-ean11.
**    MODIFY gt_mara TRANSPORTING ean11.
**    CLEAR gt_mara.
**  ENDLOOP.

  SELECT a~matnr werks lgort a~charg lfgja lfmon
    clabs cinsm cspem vfdat
    FROM mchb AS a JOIN mch1 AS b ON a~matnr EQ b~matnr AND
                                     a~charg EQ b~charg
    INTO TABLE gt_mchb
    FOR ALL ENTRIES IN gt_mara
    WHERE a~matnr EQ gt_mara-matnr AND
          werks   EQ gt_mara-werks AND
          lgort   EQ gt_mara-lgort.

  SELECT * INTO TABLE gt_mean
    FROM mean FOR ALL ENTRIES IN gt_mara
    WHERE matnr EQ gt_mara-matnr
      AND eantp EQ 'Z1'
      AND hpean EQ space.

**  SELECT matnr werks lgort charg clabs cinsm cspem vfdat
**    INTO CORRESPONDING FIELDS OF TABLE lt_mchb
**    FROM zmchb
**    FOR ALL ENTRIES IN gt_mara
**    WHERE spmon EQ lv_spmon AND
**          matnr EQ gt_mara-matnr AND
**          werks EQ gt_mara-werks.
**
**  LOOP AT lt_mchb.
**    gt_mchb  = lt_mchb.
**    APPEND gt_mchb.
**    CLEAR gt_mchb.
**  ENDLOOP.
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
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_comment_build     USING   t_top_of_page[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  lv_func    = 'REUSE_ALV_GRID_DISPLAY'.
  lv_title   = sy-title.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
*      i_grid_title             = lv_title
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
  IF pa_summa IS INITIAL.
    PERFORM f_fieldcatg USING ft_report:
      'MATNR' 'MARD' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'WERKS' 'MARD' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'LGORT' 'MARD' 'LGORT' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'EAN11' 'MARA' 'EAN11' 'X' '' 'JDE Code' '' '' '' '' '' '' '' '' '' '',
      'BISMT' 'MARA' 'BISMT' '' '' 'Old Mat No' '' '' '' '' '' '' '' '' '' '',
      'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'CHARG' 'MCHB' 'CHARG' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'VFDAT' 'MCH1' 'VFDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'MEINS' 'MARA' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'ONHAND' '' '' '' '15' 'On Hand Qty' '' '' '' '' '' '' 'MEINS' '' '' '',
      'AGING1' '' '' '' '25' gv_header01 '' '' '' '' '' '' 'MEINS' '' '' '',
      'AGING2' '' '' '' '25' gv_header02 '' '' '' '' '' '' 'MEINS' '' '' '',
      'AGING3' '' '' '' '25' gv_header03 '' '' '' '' '' '' 'MEINS' '' '' '',
      'AGING4' '' '' '' '25' gv_header04 '' '' '' '' '' '' 'MEINS' '' '' '',
      'AGING5' '' '' '' '25' gv_header05 '' '' '' '' '' '' 'MEINS' '' '' ''.
  ELSE.
    PERFORM f_fieldcatg USING ft_report:
      'MATNR' 'MARD' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'WERKS' 'MARD' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'EAN11' 'MARA' 'EAN11' 'X' '' 'JDE Code' '' '' '' '' '' '' '' '' '' '',
      'BISMT' 'MARA' 'BISMT' '' '' 'Old Mat No' '' '' '' '' '' '' '' '' '' '',
      'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'MEINS' 'MARA' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'ONHAND' '' '' '' '15' 'On Hand Qty' '' '' '' '' '' '' 'MEINS' '' '' '',
      'AGING1' '' '' '' '25' gv_header01 '' '' '' '' '' '' 'MEINS' '' '' '',
      'AGING2' '' '' '' '25' gv_header02 '' '' '' '' '' '' 'MEINS' '' '' '',
      'AGING3' '' '' '' '25' gv_header03 '' '' '' '' '' '' 'MEINS' '' '' '',
      'AGING4' '' '' '' '25' gv_header04 '' '' '' '' '' '' 'MEINS' '' '' '',
      'AGING5' '' '' '' '25' gv_header05 '' '' '' '' '' '' 'MEINS' '' '' ''.
  ENDIF.
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
*  fu_layout-box_fieldname      = 'CHECK'.
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
  ld_sort-fieldname = 'MATNR'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
  CLEAR ld_sort.
  ld_sort-fieldname = 'EAN11'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
  CLEAR ld_sort.
  ld_sort-fieldname = 'MAKTX'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
ENDFORM.                    "F_BUILD_SORTFIELD

*&---------------------------------------------------------------------*
*&      Form  F_COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM f_comment_build USING lt_top_of_page TYPE slis_t_listheader.
  DATA: ls_line TYPE slis_listheader,
        info(60).

  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = sy-title.
  APPEND ls_line TO lt_top_of_page.

  CONCATENATE 'Period' pa_lfmon '-' pa_lfgja INTO info
  SEPARATED BY space.

  CLEAR ls_line.
  ls_line-typ  = 'A'.
  ls_line-info = info.
  APPEND ls_line TO lt_top_of_page.
ENDFORM.                    " F_COMMENT_BUILD

*---------------------------------------------------------------------*
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_top_of_page.

*  PERFORM f_hdr_uline.
*  PERFORM f_hdr_line1 USING sy-title.
*  PERFORM f_hdr_line2 USING ''.
*  PERFORM f_hdr_line3 USING ''.
*  PERFORM f_hdr_uline.
ENDFORM.                    "F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
FORM f_free_memory.
* here free all the internal table used in the program.

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
  DATA: lv_dat01    TYPE sy-datum,
        lv_dat02    TYPE sy-datum.

  CONCATENATE pa_lfgja pa_lfmon '01' INTO lv_dat01.

  SORT gt_mara BY matnr werks.
  SORT gt_mchb BY matnr werks lgort charg.
  SORT gt_mean BY matnr.

  LOOP AT gt_mchb.
    CONCATENATE gt_mchb-lfgja gt_mchb-lfmon '01' INTO lv_dat02.
    gt_vdata-matnr  = gt_mchb-matnr.
    gt_vdata-werks  = gt_mchb-werks.
    gt_vdata-lgort  = gt_mchb-lgort.
    gt_vdata-charg  = gt_mchb-charg.
    gt_vdata-vfdat  = gt_mchb-vfdat.

    READ TABLE gt_mara WITH KEY matnr = gt_mchb-matnr
                                werks = gt_mchb-werks
                       BINARY SEARCH.
    IF sy-subrc EQ 0.
      gt_vdata-bismt  = gt_mara-bismt.
      gt_vdata-meins  = gt_mara-meins.
      gt_vdata-maktx  = gt_mara-maktx.
    ENDIF.

    CLEAR gt_mean.
    READ TABLE gt_mean WITH KEY matnr = gt_mchb-matnr BINARY SEARCH.
    gt_vdata-ean11 = gt_mean-ean11.

    IF lv_dat02 LE lv_dat01.
      gt_vdata-onhand = gt_mchb-clabs + gt_mchb-cinsm + gt_mchb-cspem.
      IF gt_mchb-vfdat IS NOT INITIAL.
        IF gt_mchb-vfdat IN gr_vfdat1.
          gt_vdata-aging1 = gt_vdata-onhand.
        ELSEIF gt_mchb-vfdat IN gr_vfdat2.
          gt_vdata-aging2 = gt_vdata-onhand.
        ELSEIF gt_mchb-vfdat IN gr_vfdat3.
          gt_vdata-aging3 = gt_vdata-onhand.
        ELSEIF gt_mchb-vfdat IN gr_vfdat4.
          gt_vdata-aging4 = gt_vdata-onhand.
        ELSEIF gt_mchb-vfdat IN gr_vfdat5.
          gt_vdata-aging5 = gt_vdata-onhand.
        ENDIF.
      ELSE.
        gt_vdata-aging5 = gt_vdata-onhand.
      ENDIF.
    ELSE.
      PERFORM f_get_data_fr_mchbh USING gt_mchb-matnr gt_mchb-werks
                                        gt_mchb-lgort gt_mchb-charg
                                        pa_lfgja pa_lfmon
                                  CHANGING gt_vdata-onhand gt_vdata-aging1
                                           gt_vdata-aging2 gt_vdata-aging3
                                           gt_vdata-aging4 gt_vdata-aging5.
    ENDIF.

    APPEND gt_vdata.
    CLEAR gt_vdata.
  ENDLOOP.

*  IF pa_summa IS INITIAL.
*    gt_out[]  = gt_vdata[].
*  ELSE.
*    LOOP AT gt_vdata.
*      gt_out  = gt_vdata.
*      CLEAR: gt_out-lgort, gt_out-charg.
*      COLLECT gt_out.
*    ENDLOOP.
*  ENDIF.
  IF pa_summa IS INITIAL.
    LOOP AT gt_vdata.
      gt_out  = gt_vdata.
      IF gt_vdata-onhand = 0.
        CONTINUE.
      ENDIF.
      APPEND gt_out.
    ENDLOOP.
  ELSE.
    LOOP AT gt_vdata.
      gt_out  = gt_vdata.
      IF gt_vdata-onhand = 0.
        CONTINUE.
      ENDIF.
      CLEAR: gt_out-lgort, gt_out-charg.
      COLLECT gt_out.
    ENDLOOP.
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
    WHEN '&POS'.
      PERFORM f_post_entries.
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
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  DATA: ld_datum  TYPE sy-datum.

  IF pa_lfgja IS INITIAL AND
    pa_lfmon IS INITIAL.
    CONCATENATE sy-datum(6) '01' INTO ld_datum.
    ld_datum  = ld_datum - 1.
    pa_lfmon  = ld_datum+4(2).
    pa_lfgja  = ld_datum(4).
  ENDIF.

  LOOP AT SCREEN.
    IF screen-group1 = 'AG4'.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF pa_lfmon IS INITIAL.
    PERFORM f_error_selection_screen USING 'LFM'.
  ENDIF.
  IF pa_lfgja IS INITIAL.
    PERFORM f_error_selection_screen USING 'LFG'.
  ENDIF.
  IF aging1 IS INITIAL.
    PERFORM f_error_selection_screen USING 'AG1'.
  ENDIF.
  IF aging2 IS INITIAL.
    PERFORM f_error_selection_screen USING 'AG2'.
  ENDIF.
  IF aging3 IS INITIAL.
    PERFORM f_error_selection_screen USING 'AG3'.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group.
  DATA: lv_mess(100).

  lv_mess = 'Fill in all required entry fields'.

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
*&      Form  F_GET_DATA_FR_MCHBH
*&---------------------------------------------------------------------*
FORM f_get_data_fr_mchbh  USING    fu_matnr fu_werks fu_lgort fu_charg
                                   fu_lfgja fu_lfmon
                          CHANGING fc_onhand fc_aging1 fc_aging2 fc_aging3
                                   fc_aging4 fc_aging5.
  DATA: lt_mchbh  LIKE gt_mchb OCCURS 0 WITH HEADER LINE.

  SELECT a~matnr werks lgort a~charg lfgja lfmon
    clabs cinsm cspem vfdat
    FROM mchbh AS a JOIN mch1 AS b ON a~matnr EQ b~matnr AND
                                      a~charg EQ b~charg
    INTO TABLE lt_mchbh
    WHERE a~matnr EQ fu_matnr AND
          werks   EQ fu_werks AND
          lgort   EQ fu_lgort AND
          a~charg EQ fu_charg AND
          lfgja   LE fu_lfgja AND
          lfmon   LE fu_lfmon.

  IF sy-subrc EQ 0.
    READ TABLE lt_mchbh WITH KEY lfgja = fu_lfgja
                                 lfmon = fu_lfmon.
    IF sy-subrc = 0.
      fc_onhand = lt_mchbh-clabs + lt_mchbh-cinsm + lt_mchbh-cspem.
      IF lt_mchbh-vfdat IS NOT INITIAL.
        IF lt_mchbh-vfdat IN gr_vfdat1.
          fc_aging1 = fc_onhand.
        ELSEIF lt_mchbh-vfdat IN gr_vfdat2.
          fc_aging2 = fc_onhand.
        ELSEIF lt_mchbh-vfdat IN gr_vfdat3.
          fc_aging3 = fc_onhand.
        ELSEIF lt_mchbh-vfdat IN gr_vfdat4.
          fc_aging4 = fc_onhand.
        ELSEIF lt_mchbh-vfdat IN gr_vfdat5.
          fc_aging5 = fc_onhand.
        ENDIF.
      ELSE.
        fc_aging5 = fc_onhand.
      ENDIF.
    ELSE.
      SORT lt_mchbh BY lfgja DESCENDING lfmon DESCENDING.
      READ TABLE lt_mchbh INDEX 1.
      fc_onhand = lt_mchbh-clabs + lt_mchbh-cinsm + lt_mchbh-cspem.
      IF lt_mchbh-vfdat IS NOT INITIAL.
        IF lt_mchbh-vfdat IN gr_vfdat1.
          fc_aging1 = fc_onhand.
        ELSEIF lt_mchbh-vfdat IN gr_vfdat2.
          fc_aging2 = fc_onhand.
        ELSEIF lt_mchbh-vfdat IN gr_vfdat3.
          fc_aging3 = fc_onhand.
        ELSEIF lt_mchbh-vfdat IN gr_vfdat4.
          fc_aging4 = fc_onhand.
        ELSEIF lt_mchbh-vfdat IN gr_vfdat5.
          fc_aging5 = fc_onhand.
        ENDIF.
      ELSE.
        fc_aging5 = fc_onhand.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DATA_FR_MCHBH

*&---------------------------------------------------------------------*
*&      Form  F_GET_AGING
*&---------------------------------------------------------------------*
FORM f_get_aging  USING    fu_aging1 fu_aging2 fu_aging
                  CHANGING fc_vfdat.

  DATA: lr_lines  LIKE LINE OF gr_vfdat1,
        lv_times  TYPE i,
        lv_vfdat  TYPE sy-datum.

  lv_times        = fu_aging1 - fu_aging2 - 1.
  lr_lines-low    = fc_vfdat.
  lv_vfdat        = fc_vfdat.
  DO lv_times TIMES.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = lv_vfdat
      IMPORTING
        last_day_of_month = lv_vfdat.
    lv_vfdat  = lv_vfdat + 1.
  ENDDO.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_vfdat
    IMPORTING
      last_day_of_month = lr_lines-high.
  lr_lines-sign     = 'I'.
  lr_lines-option   = 'BT'.
  fc_vfdat  = lr_lines-high + 1.

  CASE fu_aging.
    WHEN '2'.
      APPEND lr_lines TO gr_vfdat2.
      PERFORM f_get_month_names USING lr_lines-low+4(2) lr_lines-high+4(2)
                                      lr_lines-low(4) lr_lines-high(4)
                                CHANGING gv_header02.
    WHEN '3'.
      APPEND lr_lines TO gr_vfdat3.
      PERFORM f_get_month_names USING lr_lines-low+4(2) lr_lines-high+4(2)
                                      lr_lines-low(4) lr_lines-high(4)
                                CHANGING gv_header03.
    WHEN '4'.
      APPEND lr_lines TO gr_vfdat4.
      PERFORM f_get_month_names USING lr_lines-low+4(2) lr_lines-high+4(2)
                                      lr_lines-low(4) lr_lines-high(4)
                                CHANGING gv_header04.
  ENDCASE.
ENDFORM.                    " F_GET_AGING

**&---------------------------------------------------------------------*
**&      Form  F_GET_HEADER
**&---------------------------------------------------------------------*
*FORM f_get_header  USING    fu_lines
*                   CHANGING fc_header.
*  DATA: lv_mnr   TYPE fcmnr,
*        lv_ktx   TYPE fcktx.
*
*  lv_mnr    = fu_lines-low.
*  SELECT SINGLE ktx
*    FROM t247
*    INTO lv_ktx
*    WHERE spras EQ sy-langu AND
*          mnr   EQ lv_mnr.
*
*ENDFORM.                    " F_GET_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_GET_MONTH_NAMES
*&---------------------------------------------------------------------*
FORM f_get_month_names  USING    fu_mnrlow fu_mnrhigh fu_gjalow fu_gjahigh
                        CHANGING fc_header.

  DATA: lv_ktxlow   TYPE fcktx,
        lv_ktxhigh  TYPE fcktx.

  SELECT SINGLE ktx
    FROM t247
    INTO lv_ktxlow
    WHERE spras EQ sy-langu AND
          mnr   EQ fu_mnrlow.

  SELECT SINGLE ktx
    FROM t247
    INTO lv_ktxhigh
    WHERE spras EQ sy-langu AND
          mnr   EQ fu_mnrhigh.

  IF fu_gjahigh IS INITIAL.
    CONCATENATE lv_ktxlow fu_gjalow 'dst'
    INTO fc_header
    SEPARATED BY space.
  ELSEIF fu_gjalow IS INITIAL.
    CONCATENATE '<=' lv_ktxhigh fu_gjahigh
    INTO fc_header
    SEPARATED BY space.
  ELSE.
    CONCATENATE lv_ktxlow fu_gjalow '-' lv_ktxhigh fu_gjahigh
    INTO fc_header
    SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_GET_MONTH_NAMES
