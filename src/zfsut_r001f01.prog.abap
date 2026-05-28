*----------------------------------------------------------------------*
*   INCLUDE ZFSUT_R001F01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA: BEGIN OF lt_skat OCCURS 0,
          saknr   TYPE saknr,
        END OF lt_skat.
  DATA: lv_budat    TYPE budat,
        lr_budln    LIKE LINE OF gr_budat,
        lr_vkbln    LIKE LINE OF gr_vkbur.

  SELECT saknr
    FROM skat
    INTO TABLE lt_skat
    WHERE saknr IN so_hkont.

  LOOP AT lt_skat.
    gt_key-bukrs  = pa_bukrs.
    gt_key-hkont  = lt_skat-saknr.
    APPEND gt_key.
  ENDLOOP.

  CONCATENATE pa_gjahr pa_monat '01' INTO lr_budln-low.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lr_budln-low
    IMPORTING
      last_day_of_month = lr_budln-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  lr_budln-sign   = 'I'.
  lr_budln-option = 'BT'.
  APPEND lr_budln TO gr_budat.

  gv_budat  = lr_budln-high.

  SELECT bukrs werks live
    FROM zplbc
    INTO TABLE gt_zplbc
    WHERE bukrs EQ pa_bukrs
      AND werks IN so_gsber
      AND live  EQ 'X'.

  LOOP AT gt_zplbc.
    lr_vkbln-low    = gt_zplbc-werks.
    lr_vkbln-sign   = 'I'.
    lr_vkbln-option = 'EQ'.
    APPEND lr_vkbln TO gr_vkbur.
    CLEAR lr_vkbln.
  ENDLOOP.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: lt_mara   LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
        lt_eine   LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
        lt_tgsbt  LIKE gt_bseg OCCURS 0 WITH HEADER LINE.

  CHECK gt_key[] IS NOT INITIAL.

  SELECT bukrs hkont augdt augbl zuonr gjahr belnr buzei
         budat bldat waers xblnr
    FROM bsis
     INTO TABLE gt_vdata
     FOR ALL ENTRIES IN gt_key
     WHERE bukrs EQ gt_key-bukrs
       AND hkont EQ gt_key-hkont
       AND gjahr EQ pa_gjahr
       AND budat IN gr_budat
       AND gsber IN so_gsber
       AND monat EQ pa_monat.

  IF pa_histo IS NOT INITIAL.
    SELECT bukrs hkont augdt augbl zuonr gjahr belnr buzei
           budat bldat waers xblnr
      FROM bsas
      APPENDING CORRESPONDING FIELDS OF TABLE gt_vdata
      FOR ALL ENTRIES IN gt_key
      WHERE bukrs EQ gt_key-bukrs
        AND hkont EQ gt_key-hkont
        AND gjahr EQ pa_gjahr
        AND budat LT gv_budat
        AND augdt GE gv_budat
        AND gsber IN so_gsber
        AND monat EQ pa_monat.
  ENDIF.

  CHECK gt_vdata[] IS NOT INITIAL.

  SELECT bukrs belnr gjahr buzei shkzg gsber dmbtr hkont
         matnr werks prctr
    FROM bseg
    INTO TABLE gt_bseg
    FOR ALL ENTRIES IN gt_vdata
    WHERE bukrs EQ gt_vdata-bukrs
      AND belnr EQ gt_vdata-belnr
      AND gjahr EQ gt_vdata-gjahr
      AND buzei EQ gt_vdata-buzei
      AND matnr IN so_matnr.

  PERFORM f_get_gsber.

  PERFORM f_get_matnr USING '1'.

  PERFORM f_get_lifnr.

  IF pa_c IS NOT INITIAL OR
    pa_e IS NOT INITIAL.
    PERFORM f_get_s703.
  ENDIF.

  IF pa_c IS NOT INITIAL.
    PERFORM f_pembebanan_disc_c.

    PERFORM f_get_matnr USING '2'.
  ENDIF.

  IF pa_e IS NOT INITIAL.
    PERFORM f_pembebanan_disc_e.

    PERFORM f_get_matnr USING '3'.
  ENDIF.

  SORT gt_mara BY matnr.
  DELETE ADJACENT DUPLICATES FROM gt_mara COMPARING matnr.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  IF pa_sum = ''.
  PERFORM f_alv TABLES gt_out.
  ELSE.
  PERFORM f_alv TABLES gt_outs.
  ENDIF.
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
    'BUKRS' 'BSEG' 'BUKRS' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
    'GSBER' 'BSEG' 'GSBER' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
    'GSBERT' '' '' '' '30' 'Business area' '' '' '' '' '' '' '' '' '' ''.

  IF pa_sum IS INITIAL.
  IF pa_c IS INITIAL AND
    pa_e IS INITIAL.
    PERFORM f_fieldcatg USING ft_report:
      'LIFNR' 'LFA1' 'LIFNR' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
      'NAME1' 'LFA1' 'NAME1' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
      'MATNR' 'MARA' 'MATNR' ' ' '' '' '' '' '' '' '' '' '' '' '' '',
      'MAKTX' 'MAKT' 'MAKTX' ' ' '' '' '' '' '' '' '' '' '' '' '' '',
      'MATKL' 'MARA' 'MATKL' ' ' '' '' '' '' '' '' '' '' '' '' '' '',
      'PRCTR' 'BSEG' 'PRCTR' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
      'BUDAT' 'BSIS' 'BUDAT' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
      'BLDAT' 'BSIS' 'BLDAT' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
      'GJAHR' 'BSIS' 'GJAHR' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
      'BELNR' 'BSIS' 'BELNR' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
      'BUZEI' 'BSIS' 'BUZEI' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'ZUONR' 'BSEG' 'ZUONR' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
      'XBLNR' 'BSIS' 'XBLNR' 'X' '' '' '' '' '' '' '' '' '' '' '' ''.
  ELSE.
    PERFORM f_fieldcatg USING ft_report:
      'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
      'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDIF.
  ELSE.
    PERFORM f_fieldcatg USING ft_report:
      'EXTWG' 'MARA' 'EXTWG' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  ENDIF.
  PERFORM f_fieldcatg USING ft_report:
    'WAERS' 'BKPF' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'DISCA' 'BSEG' 'DMBTR' '' '' 'DiscA' 'X' '' '' '' '' 'WAERS' '' '' '' '',
    'DISCB' 'BSEG' 'DMBTR' '' '' 'DiscB' 'X' '' '' '' '' 'WAERS' '' '' '' '',
    'DISCC' 'BSEG' 'DMBTR' '' '' 'DiscC' 'X' '' '' '' '' 'WAERS' '' '' '' '',
    'DISCD' 'BSEG' 'DMBTR' '' '' 'DiscD' 'X' '' '' '' '' 'WAERS' '' '' '' '',
    'DISCE' 'BSEG' 'DMBTR' '' '' 'DiscE' 'X' '' '' '' '' 'WAERS' '' '' '' '',
    'DISCF' 'BSEG' 'DMBTR' '' '' 'DiscF' 'X' '' '' '' '' 'WAERS' '' '' '' '',
    'DISVO' 'BSEG' 'DMBTR' '' '' 'Volume Disc.' 'X' '' '' '' '' 'WAERS' '' '' '' '',
    'TOTAL' 'BSEG' 'DMBTR' '' '' 'Total' 'X' '' '' '' '' 'WAERS' '' '' '' ''.
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
  ld_sort-fieldname = 'GSBERT'.
  ld_sort-up        = 'X'.
  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
  IF pa_sum IS INITIAL.
  IF pa_c IS INITIAL AND
    pa_e IS INITIAL.
    CLEAR ld_sort.
    ld_sort-fieldname = 'BELNR'.
    ld_sort-up        = 'X'.
    APPEND ld_sort TO fu_sort.

    CLEAR ld_sort.
    ld_sort-fieldname = 'BUZEI'.
    ld_sort-up        = 'X'.
*  ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.
  ELSE.
    CLEAR ld_sort.
    ld_sort-fieldname = 'MATNR'.
    ld_sort-up        = 'X'.
    APPEND ld_sort TO fu_sort.
  ENDIF.
  ENDIF.
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
  DATA: lt_s700      LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
        lt_s703      LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
        lt_s700sum   LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
        lt_s703sum   LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
        lt_out       LIKE gt_out OCCURS 0 WITH HEADER LINE.

  sort gt_lfa1 by lifnr.
  sort gt_tgsbt by gsber.
  sort gt_mara by matnr.

  sort gt_vdata by bukrs belnr gjahr buzei.

  IF pa_c IS INITIAL AND
    pa_e IS INITIAL.
    PERFORM f_normal_process.
  ELSE.
    PERFORM f_append_bseg TABLES lt_out lt_s700 lt_s703.

    IF pa_c IS NOT INITIAL.
      IF gt_s700[] IS INITIAL.
        PERFORM f_back_data TABLES lt_out lt_s700
                            USING 'S700'.
      ELSE.
        PERFORM f_append_s700 TABLES lt_out lt_s700sum.
      ENDIF.
    ENDIF.

    IF pa_e IS NOT INITIAL.
      IF gt_s703[] IS INITIAL.
        PERFORM f_back_data TABLES lt_out lt_s703
                            USING 'S703'.
      ELSE.
        PERFORM f_append_s703 TABLES lt_out lt_s703sum.
      ENDIF.
    ENDIF.

    PERFORM f_add_selisih TABLES lt_out lt_s700sum lt_s703sum.

    SORT lt_out BY gsber matnr.
    LOOP AT lt_out.
      gt_out  = lt_out.
      PERFORM f_get_gsber_name USING lt_out-gsber
                               CHANGING gt_out-gsbert.

      PERFORM f_get_mara USING lt_out-matnr
                         CHANGING gt_out-matkl gt_out-maktx.

      gt_out-total  = lt_out-disca + lt_out-discb + lt_out-discc +
                      lt_out-discd + lt_out-disce + lt_out-discf +
                      lt_out-disvo.

      COLLECT gt_out.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE,
        ffield(20),
        fvalue(20),
        lwa_out        LIKE gt_out.

  GET CURSOR FIELD ffield VALUE fvalue.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&IC1'.
      IF ffield EQ 'GT_OUT-BELNR'.
        READ TABLE gt_out INDEX fu_selfield-tabindex INTO lwa_out.
        SET PARAMETER ID 'BLN' FIELD fvalue.
        SET PARAMETER ID 'BUK' FIELD pa_bukrs.
        SET PARAMETER ID 'GJR' FIELD lwa_out-gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.

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
*  LOOP AT SCREEN.
*    CASE screen-group1.
*      WHEN 'HKO'.
*        screen-input  = 0.
*    ENDCASE.
*    MODIFY SCREEN.
*  ENDLOOP.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF pa_bukrs IS INITIAL.
    PERFORM f_error_selection_screen USING 'BUK' ''.
  ENDIF.
  IF pa_monat IS INITIAL.
    PERFORM f_error_selection_screen USING 'MON' ''.
  ENDIF.
  IF pa_gjahr IS INITIAL.
    PERFORM f_error_selection_screen USING 'GJA' ''.
  ENDIF.
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
*&      Form  F_GET_EINA
*----------------------------------------------------------------------*
FORM f_get_eina  USING    fu_bukrs fu_matnr
                 CHANGING fc_lifnr fc_name1.

  DATA lv_lifnr TYPE lifnr.

  SORT gt_eina BY infnr.
  LOOP AT gt_eina WHERE matnr EQ fu_matnr.
    lv_lifnr  = gt_eina-lifnr.
    AT END OF infnr.
      fc_lifnr  = lv_lifnr.
      READ TABLE gt_lfa1 WITH KEY lifnr = lv_lifnr BINARY SEARCH.
      IF sy-subrc EQ 0.
        fc_name1  = gt_lfa1-name1.
      ENDIF.
    ENDAT.
    CLEAR lv_lifnr.
  ENDLOOP.
ENDFORM.                    " F_GET_EINA

*&---------------------------------------------------------------------*
*&      Form  F_GET_BSEG
*&---------------------------------------------------------------------*
FORM f_get_bseg  USING    fu_bukrs fu_belnr fu_gjahr fu_buzei
                 CHANGING fc_matnr fc_werks fc_gsber fc_prctr
                          fc_disca fc_discb fc_discc fc_discd
                          fc_disce fc_discf fc_disvo fc_total.

  DATA: lv_dmbtr    TYPE dmbtr.
  READ TABLE gt_bseg WITH KEY bukrs = fu_bukrs
                              belnr = fu_belnr
                              gjahr = fu_gjahr
                              buzei = fu_buzei
                              BINARY SEARCH.
  IF sy-subrc EQ 0.
    fc_matnr    = gt_bseg-matnr.
    fc_gsber    = gt_bseg-gsber.
    fc_prctr    = gt_bseg-prctr.

    IF fu_bukrs EQ '8020'.
      fc_werks    = '0200'.
    ELSE.
      fc_werks    = gt_bseg-werks.
    ENDIF.

    IF gt_bseg-shkzg EQ 'H'.
      lv_dmbtr  = gt_bseg-dmbtr * -1.
    ELSE.
      lv_dmbtr  = gt_bseg-dmbtr.
    ENDIF.

    CASE gt_bseg-hkont.
      WHEN '0731110010' OR '0731110011'.
        fc_disca  = lv_dmbtr.
      WHEN '0731110020' OR '0731110021'.
        fc_discb  = lv_dmbtr.
      WHEN '0731110030' OR '0731110031'.
        fc_discc  = lv_dmbtr.
      WHEN '0731110052' OR '0731110060' OR '0731110061'.
        fc_discd  = lv_dmbtr.
      WHEN '0731110040' OR '0731110041'.
        fc_disce  = lv_dmbtr.
      WHEN '0731110050' OR '0731110051'.
        fc_discf  = lv_dmbtr.
      WHEN '0731110070' OR '0731110071' OR '0731110090'.
        fc_disvo  = lv_dmbtr.
    ENDCASE.

    fc_total  = lv_dmbtr.
  ENDIF.
ENDFORM.                    " F_GET_BSEG

*&---------------------------------------------------------------------*
*&      Form  F_GET_MARA
*&---------------------------------------------------------------------*
FORM f_get_mara  USING    fu_matnr
                 CHANGING fc_matkl fc_maktx.
  READ TABLE gt_mara WITH KEY matnr = fu_matnr BINARY SEARCH.
  IF sy-subrc EQ 0.
    fc_matkl  = gt_mara-matkl.
    fc_maktx  = gt_mara-maktx.
  ENDIF.
ENDFORM.                    " F_GET_MARA

*&---------------------------------------------------------------------*
*&      Form  F_GET_GSBER
*&---------------------------------------------------------------------*
FORM f_get_gsber  .
  SELECT gsber gtext
    FROM tgsbt
    INTO TABLE gt_tgsbt
    WHERE spras EQ sy-langu
      AND gsber IN so_gsber.
ENDFORM.                    " F_GET_GSBER

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATNR
*&---------------------------------------------------------------------*
FORM f_get_matnr  USING fu_flag.
  DATA: lt_bseg   LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
        lt_s700   LIKE gt_s700 OCCURS 0 WITH HEADER LINE,
        lt_s703   LIKE gt_s703 OCCURS 0 WITH HEADER LINE.

  CASE fu_flag.
    WHEN '1'.
      lt_bseg[]   = gt_bseg[].
      SORT lt_bseg BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING matnr.

      IF lt_bseg[] IS NOT INITIAL.
        SELECT a~matnr matkl maktx
          FROM mara AS a JOIN makt AS b ON a~matnr EQ b~matnr
          INTO TABLE gt_mara
          FOR ALL ENTRIES IN lt_bseg
          WHERE a~matnr EQ lt_bseg-matnr
            AND spras EQ sy-langu.
      ENDIF.

    WHEN '2'.
      lt_s700[]   = gt_s700[].
      SORT lt_s700 BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_s700 COMPARING matnr.
      READ TABLE lt_s700 WITH KEY matnr = '001-00-03'.
      IF sy-subrc NE 0.
        lt_s700-matnr = '001-00-03'.
        APPEND lt_s700.
      ENDIF.
      IF lt_s700[] IS NOT INITIAL.
        SELECT a~matnr matkl maktx
          FROM mara AS a JOIN makt AS b ON a~matnr EQ b~matnr
          APPENDING TABLE gt_mara
          FOR ALL ENTRIES IN lt_s700
          WHERE a~matnr EQ lt_s700-matnr
            AND spras EQ sy-langu.
      ENDIF.

    WHEN '3'.
      lt_s703[]   = gt_s703[].
      SORT lt_s703 BY matnr.
      DELETE ADJACENT DUPLICATES FROM lt_s703 COMPARING matnr.
      READ TABLE lt_s703 WITH KEY matnr = '001-00-03'.
      IF sy-subrc NE 0.
        lt_s703-matnr = '001-00-03'.
        APPEND lt_s703.
      ENDIF.

      IF lt_s703[] IS NOT INITIAL.
        SELECT a~matnr matkl maktx
          FROM mara AS a JOIN makt AS b ON a~matnr EQ b~matnr
          APPENDING TABLE gt_mara
          FOR ALL ENTRIES IN lt_s703
          WHERE a~matnr EQ lt_s703-matnr
            AND spras EQ sy-langu.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_MATNR

*&---------------------------------------------------------------------*
*&      Form  F_GET_LIFNR
*&---------------------------------------------------------------------*
FORM f_get_lifnr .
  DATA: lt_eina   LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
        lt_lfa1   LIKE gt_eina OCCURS 0 WITH HEADER LINE,
        lv_ekorg  TYPE ekorg.

  lt_eina[]   = gt_bseg[].
  SORT lt_eina BY matnr werks.

  DELETE ADJACENT DUPLICATES FROM lt_eina COMPARING matnr.

  IF lt_eina[] IS NOT INITIAL.
    SELECT infnr matnr lifnr
      FROM eina
      INTO TABLE gt_eina
      FOR ALL ENTRIES IN lt_eina
      WHERE matnr EQ lt_eina-matnr
        AND lifnr IN so_lifnr.

    lt_lfa1[] = gt_eina[].
    SORT lt_lfa1 BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_lfa1 COMPARING lifnr.

    IF lt_lfa1[] IS NOT INITIAL.
      SELECT lifnr name1
        FROM lfa1
        INTO TABLE gt_lfa1
        FOR ALL ENTRIES IN lt_lfa1
        WHERE lifnr EQ lt_lfa1-lifnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_LIFNR

*&---------------------------------------------------------------------*
*&      Form  F_GET_GSBER_NAME
*&---------------------------------------------------------------------*
FORM f_get_gsber_name  USING    fu_gsber
                       CHANGING fc_gsbert.
  READ TABLE gt_tgsbt WITH KEY gsber = fu_gsber BINARY SEARCH.
  IF sy-subrc EQ 0.
    CONCATENATE fu_gsber '-' gt_tgsbt-gtext
      INTO fc_gsbert
      SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_GET_GSBER_NAME

*&---------------------------------------------------------------------*
*&      Form  F_PEMBEBANAN_DISC_C
*&---------------------------------------------------------------------*
FORM f_pembebanan_disc_c .
  DATA: lv_spmon    TYPE spmon.

  CONCATENATE pa_gjahr pa_monat INTO lv_spmon.

  SELECT vrsio spmon pkunwe matnr waerk
         vkorg vkbur totweek
    FROM s700
    INTO TABLE gt_s700
    WHERE ssour   EQ space
      AND vrsio   EQ gc_vrsio
      AND spmon   EQ lv_spmon
      AND sptag   EQ '00000000'
      AND spwoc   EQ '000000'
      AND spbup   EQ '000000'
      AND vkorg   EQ pa_bukrs
      AND vkbur   IN gr_vkbur
      AND totweek NE 0.

  LOOP AT gt_s703 WHERE zcddo IS NOT INITIAL.
    gt_s700-vrsio    = gt_s703-vrsio.
    gt_s700-spmon    = gt_s703-spmon.
    gt_s700-pkunwe   = gt_s703-pkunwe.
    gt_s700-matnr    = gt_s703-matnr.
    gt_s700-waerk    = gt_s703-waerk.
    gt_s700-vkorg    = pa_bukrs.
    gt_s700-vkbur    = gt_s703-vkbur.
    gt_s700-totweek  = gt_s703-zcddo.
    APPEND gt_s700.
  ENDLOOP.
ENDFORM.                    " F_PEMBEBANAN_DISC_C

*&---------------------------------------------------------------------*
*&      Form  F_PEMBEBANAN_DISC_E
*&---------------------------------------------------------------------*
FORM f_pembebanan_disc_e .

  DELETE gt_s703 WHERE zoppout IS INITIAL.

ENDFORM.                    " F_PEMBEBANAN_DISC_E

*&---------------------------------------------------------------------*
*&      Form  F_NORMAL_PROCESS
*&---------------------------------------------------------------------*
FORM f_normal_process .
  DATA: lv_werks    TYPE werks_d.

  sort gt_bseg by bukrs belnr gjahr buzei.

  LOOP AT gt_vdata.
    gt_out-bukrs  = gt_vdata-bukrs.
    gt_out-budat  = gt_vdata-budat.
    gt_out-bldat  = gt_vdata-bldat.
    gt_out-gjahr  = gt_vdata-gjahr.
    gt_out-belnr  = gt_vdata-belnr.
    gt_out-buzei  = gt_vdata-buzei.
    gt_out-waers  = gt_vdata-waers.
    gt_out-zuonr  = gt_vdata-zuonr.
    gt_out-xblnr  = gt_vdata-xblnr.

    PERFORM f_get_bseg USING gt_vdata-bukrs gt_vdata-belnr
                             gt_vdata-gjahr gt_vdata-buzei
                       CHANGING gt_out-matnr lv_werks gt_out-gsber gt_out-prctr
                                gt_out-disca gt_out-discb gt_out-discc
                                gt_out-discd gt_out-disce gt_out-discf
                                gt_out-disvo gt_out-total.

    CHECK sy-subrc EQ 0.

    PERFORM f_get_gsber_name USING gt_out-gsber
                             CHANGING gt_out-gsbert.

    PERFORM f_get_eina USING gt_vdata-bukrs gt_out-matnr
                        CHANGING gt_out-lifnr gt_out-name1.

*    CHECK sy-subrc EQ 0.

    PERFORM f_get_mara USING gt_out-matnr
                       CHANGING gt_out-matkl gt_out-maktx.

    If pa_sum = 'X'.
       MOVE-CORRESPONDING gt_out to gt_outs.
       gt_outs-extwg = gt_out-matkl(3).
       collect gt_outs.
    Else.
    APPEND gt_out.
    Endif.
    CLEAR gt_out.
  ENDLOOP.
ENDFORM.                    " F_NORMAL_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_S700
*&---------------------------------------------------------------------*
FORM f_append_s700  TABLES   ft_out STRUCTURE gt_out
                             ft_s700 STRUCTURE gt_bseg.
  SORT gt_s700 BY vkbur matnr.
  LOOP AT gt_s700.
    IF gt_s700-totweek IS NOT INITIAL.
      ft_s700-gsber   = gt_s700-vkbur.
      ft_s700-dmbtr   = gt_s700-totweek.
      COLLECT ft_s700.

      ft_out-gsber    = gt_s700-vkbur.
      ft_out-matnr    = gt_s700-matnr.
      ft_out-waers    = gt_s700-waerk.
      ft_out-discc    = gt_s700-totweek.
      APPEND ft_out.
      CLEAR ft_out.
    ENDIF.
    CLEAR ft_s700.
  ENDLOOP.
ENDFORM.                    " F_APPEND_S700

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_S703
*&---------------------------------------------------------------------*
FORM f_append_s703  TABLES   ft_out STRUCTURE gt_out
                             ft_s703 STRUCTURE gt_bseg.
  SORT gt_s703 BY vkbur matnr.
  LOOP AT gt_s703.
    IF gt_s703-zoppout IS NOT INITIAL.
      ft_s703-gsber   = gt_s703-vkbur.
      ft_s703-dmbtr   = gt_s703-zoppout.
      COLLECT ft_s703.

      ft_out-gsber    = gt_s703-vkbur.
      ft_out-matnr    = gt_s703-matnr.
      ft_out-waers    = gt_s703-waerk.
      ft_out-disce    = gt_s703-zoppout.
      APPEND ft_out.
      CLEAR ft_out.
    ENDIF.
    CLEAR ft_s703.
  ENDLOOP.
ENDFORM.                    " F_APPEND_S703

*&---------------------------------------------------------------------*
*&      Form  F_APPEND_BSEG
*&---------------------------------------------------------------------*
FORM f_append_bseg  TABLES   ft_out STRUCTURE gt_out
                             ft_s700 STRUCTURE gt_bseg
                             ft_s703 STRUCTURE gt_bseg.

  DATA: lt_bseg   LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
        lr_hkont  TYPE RANGE OF hkont,
        lr_s700   TYPE RANGE OF hkont,
        lr_s703   TYPE RANGE OF hkont,
        lr_hkoln  LIKE LINE OF lr_hkont.

  DATA: lv_dmbtr    TYPE dmbtr,
        lv_selisih  TYPE ztotweek.

  lr_hkoln-low    = '0731110030'.
  lr_hkoln-high   = '0731110031'.
  lr_hkoln-sign   = 'I'.
  lr_hkoln-option = 'BT'.
  APPEND lr_hkoln TO lr_hkont.
  APPEND lr_hkoln TO lr_s700.
  lr_hkoln-low    = '0731110040'.
  lr_hkoln-high   = '0731110041'.
  lr_hkoln-sign   = 'I'.
  lr_hkoln-option = 'BT'.
  APPEND lr_hkoln TO lr_hkont.
  APPEND lr_hkoln TO lr_s703.

  SORT gt_bseg BY gsber hkont matnr.

  LOOP AT gt_bseg.
    IF gt_bseg-hkont IN lr_hkont.
      IF gt_bseg-hkont IN lr_s700.
        PERFORM f_get_summary_bseg TABLES ft_s700
                                   USING 'S700'.
      ENDIF.

      IF gt_bseg-hkont IN lr_s703.
        PERFORM f_get_summary_bseg TABLES ft_s703
                                   USING 'S703'.
      ENDIF.
    ELSE.
      READ TABLE gt_vdata WITH KEY bukrs = gt_bseg-bukrs
                                   belnr = gt_bseg-belnr
                                   gjahr = gt_bseg-gjahr
                                   buzei = gt_bseg-buzei
                                   BINARY SEARCH.
      IF sy-subrc EQ 0.
        ft_out-waers  = gt_vdata-waers.
      ENDIF.

      ft_out-gsber  = gt_bseg-gsber.
      ft_out-matnr  = gt_bseg-matnr.
      IF gt_bseg-shkzg EQ 'H'.
        lv_dmbtr = gt_bseg-dmbtr * -1.
      ELSE.
        lv_dmbtr = gt_bseg-dmbtr.
      ENDIF.

      CASE gt_bseg-hkont.
        WHEN '0731110010' OR '0731110011'.
          ft_out-disca  = lv_dmbtr.
        WHEN '0731110020' OR '0731110021'.
          ft_out-discb  = lv_dmbtr.
        WHEN '0731110030' OR '0731110031'.
          ft_out-discc  = lv_dmbtr.
        WHEN '0731110052' OR '0731110060' OR '0731110061'.
          ft_out-discd  = lv_dmbtr.
        WHEN '0731110040' OR '0731110041'.
          ft_out-disce  = lv_dmbtr.
        WHEN '0731110050' OR '0731110051'.
          ft_out-discf  = lv_dmbtr.
        WHEN '0731110070' OR '0731110071' OR '0731110090'.
          ft_out-disvo  = lv_dmbtr.
      ENDCASE.
      APPEND ft_out.
      CLEAR: ft_out, lv_dmbtr.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_APPEND_BSEG

*&---------------------------------------------------------------------*
*&      Form  F_GET_SUMMARY_BSEG
*&---------------------------------------------------------------------*
FORM f_get_summary_bseg  TABLES   ft_bseg STRUCTURE gt_bseg
                         USING    fu_value.
  CASE fu_value.
    WHEN 'S700'.
      gt_sum1-gsber = gt_bseg-gsber.
      IF gt_bseg-shkzg EQ 'H'.
        gt_sum1-dmbtr = gt_bseg-dmbtr * -1.
      ELSE.
        gt_sum1-dmbtr = gt_bseg-dmbtr.
      ENDIF.
      COLLECT gt_sum1.
      CLEAR gt_sum1.

    WHEN 'S703'.
      gt_sum2-gsber = gt_bseg-gsber.
      IF gt_bseg-shkzg EQ 'H'.
        gt_sum2-dmbtr = gt_bseg-dmbtr * -1.
      ELSE.
        gt_sum2-dmbtr = gt_bseg-dmbtr.
      ENDIF.
      COLLECT gt_sum2.
      CLEAR gt_sum2.
  ENDCASE.

  ft_bseg    = gt_bseg.
  APPEND ft_bseg.
  CLEAR ft_bseg.
ENDFORM.                    " F_GET_SUMMARY_BSEG

*&---------------------------------------------------------------------*
*&      Form  F_BACK_DATA
*&---------------------------------------------------------------------*
FORM f_back_data  TABLES   ft_out STRUCTURE gt_out
                           ft_bseg STRUCTURE gt_bseg
                  USING fu_value.
  DATA: lv_dmbtr    TYPE dmbtr.

  LOOP AT ft_bseg.
    READ TABLE gt_vdata WITH KEY bukrs = ft_bseg-bukrs
                                 belnr = ft_bseg-belnr
                                 gjahr = ft_bseg-gjahr
                                 buzei = ft_bseg-buzei
                                 BINARY SEARCH.
    IF sy-subrc EQ 0.
      ft_out-waers  = gt_vdata-waers.
    ENDIF.

    ft_out-gsber    = ft_bseg-gsber.
    ft_out-matnr    = ft_bseg-matnr.

    IF ft_bseg-shkzg EQ 'H'.
      lv_dmbtr = ft_bseg-dmbtr * -1.
    ELSE.
      lv_dmbtr = ft_bseg-dmbtr.
    ENDIF.

    CASE fu_value.
      WHEN 'S700'.
        ft_out-discc    = lv_dmbtr.
      WHEN 'S703'.
        ft_out-disce    = lv_dmbtr.
    ENDCASE.
    APPEND ft_out.
    CLEAR ft_out.
  ENDLOOP.
ENDFORM.                    " F_BACK_DATA

*&---------------------------------------------------------------------*
*&      Form  F_ADD_SELISIH
*&---------------------------------------------------------------------*
FORM f_add_selisih  TABLES   ft_out STRUCTURE gt_out
                             ft_s700sum STRUCTURE gt_bseg
                             ft_s703sum STRUCTURE gt_bseg.

  LOOP AT gt_sum1.
    READ TABLE ft_s700sum WITH KEY gsber = gt_sum1-gsber.
    IF sy-subrc EQ 0.
      ft_out-gsber    = gt_sum1-gsber.
      ft_out-matnr    = '001-00-03'.
      ft_out-waers    = 'IDR'.
      ft_out-discc  = gt_sum1-dmbtr - ft_s700sum-dmbtr.
      APPEND ft_out.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_sum2.
    READ TABLE ft_s703sum WITH KEY gsber = gt_sum2-gsber.
    IF sy-subrc EQ 0.
      ft_out-gsber    = gt_sum2-gsber.
      ft_out-matnr    = '001-00-03'.
      ft_out-waers    = 'IDR'.
      ft_out-disce  = gt_sum2-dmbtr - ft_s703sum-dmbtr.
      APPEND ft_out.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_ADD_SELISIH

*&---------------------------------------------------------------------*
*&      Form  F_GET_S703
*&---------------------------------------------------------------------*
FORM f_get_s703 .
  DATA: lv_spmon    TYPE spmon.

  CONCATENATE pa_gjahr pa_monat INTO lv_spmon.

  SELECT vrsio spmon pkunwe matnr waerk
         vkbur zoppout zcddo
    FROM s703
    INTO CORRESPONDING FIELDS OF TABLE gt_s703
    WHERE ssour   EQ space
      AND vrsio   EQ gc_vrsio
      AND spmon   EQ lv_spmon
      AND sptag   EQ '00000000'
      AND spwoc   EQ '000000'
      AND spbup   EQ '000000'
      AND zpaket  EQ 'OPP'
      AND vkbur   IN gr_vkbur
      AND ( zoppout NE 0
       OR   zcddo   NE 0 ).
ENDFORM.                    " F_GET_S703
