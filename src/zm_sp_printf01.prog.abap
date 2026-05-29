*----------------------------------------------------------------------*
*   INCLUDE ZM_SP_PRINTF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  SELECT *
    FROM zmpsiko
    INTO CORRESPONDING FIELDS OF TABLE gt_zmpsiko.

  SELECT *
    FROM zmpsiko1
    INTO CORRESPONDING FIELDS OF TABLE gt_zmpsiko1.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA : lt_mara  LIKE gt_lips OCCURS 0 WITH HEADER LINE,
         lt_lips  LIKE gt_lips OCCURS 0 WITH HEADER LINE,
         lt_zplbc LIKE gt_likp OCCURS 0 WITH HEADER LINE.

  DATA : lt_zmpsikor1 LIKE zmpsikor1 OCCURS 0 WITH HEADER LINE.

  CASE 'X'.
    WHEN radio1.
      SELECT vbeln erdat vstel vkorg lfart kunnr wadat_ist werks abssc
        stzzu tpgrp
        FROM likp
        INTO TABLE gt_likp
        WHERE vbeln IN so_vbeln
          AND vstel = pa_vstel
          AND vkorg = pa_vkorg
          AND lfart = 'NLCC'
          AND kunnr = pa_kunnr
          AND wadat_ist IN so_wadat
          AND tpgrp = space.

    WHEN radio2.
      SELECT vbeln erdat vstel vkorg lfart kunnr wadat_ist werks abssc
        stzzu tpgrp
        FROM likp
        INTO TABLE gt_likp
        WHERE vbeln IN so_vbeln
          AND vstel = pa_vstel
          AND vkorg = pa_vkorg
          AND lfart = 'NLCC'
          AND wadat_ist IN so_wadat
          AND tpgrp IN so_tpgrp.

      DELETE gt_likp WHERE tpgrp IS INITIAL.
      READ TABLE gt_likp INDEX 1.
      IF sy-subrc = 0.
        pa_kunnr  = gt_likp-kunnr.
      ENDIF.

    WHEN radio3.
      SELECT vbeln erdat vstel vkorg lfart kunnr wadat_ist werks abssc
        stzzu tpgrp
        FROM likp
        INTO TABLE gt_likp
        WHERE vstel = pa_vstel
          AND erdat IN so_erdat
          AND vbeln IN so_vbeln
          AND vkorg = pa_vkorg
          AND lfart = 'NLCC'
          AND tpgrp IN so_tpgrp.
  ENDCASE.

  IF gt_likp[] IS NOT INITIAL.
    lt_zplbc[] = gt_likp[].
    SORT lt_zplbc BY vstel.
    DELETE ADJACENT DUPLICATES FROM lt_zplbc COMPARING vstel.
    IF lt_zplbc[] IS NOT INITIAL.
      SELECT *
        FROM zplbc
        INTO CORRESPONDING FIELDS OF TABLE gt_zplbc
        FOR ALL ENTRIES IN lt_zplbc
        WHERE reswk = lt_zplbc-vstel.
    ENDIF.

    SELECT vbeln posnr matnr meins kcmeng
      FROM lips
      INTO TABLE gt_lips
      FOR ALL ENTRIES IN gt_likp
      WHERE vbeln = gt_likp-vbeln.

    lt_lips[] = gt_lips[].
    SORT lt_lips BY vbeln matnr.
    DELETE ADJACENT DUPLICATES FROM lt_lips COMPARING vbeln matnr.
    IF lt_lips[] IS NOT INITIAL.
      SELECT *
        FROM zmpsikor1
        INTO CORRESPONDING FIELDS OF TABLE lt_zmpsikor1
        FOR ALL ENTRIES IN lt_lips
        WHERE vbeln = lt_lips-vbeln
          AND matnr = lt_lips-matnr.

      SORT gt_lips BY vbeln matnr.
      SORT lt_zmpsikor1 BY vbeln matnr.
      LOOP AT gt_lips.
        READ TABLE lt_zmpsikor1 WITH KEY vbeln = gt_lips-vbeln
                                         matnr = gt_lips-matnr
                                BINARY SEARCH.
        IF sy-subrc = 0.
          DELETE gt_lips.
        ENDIF.
      ENDLOOP.
    ENDIF.

    lt_mara[] = gt_lips[].
    SORT lt_mara BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING matnr.

    IF lt_mara[] IS NOT INITIAL.
      SELECT mara~matnr normt maktx
        FROM mara JOIN makt ON mara~matnr = makt~matnr
        INTO TABLE gt_makt
        FOR ALL ENTRIES IN lt_mara
        WHERE mara~matnr = lt_mara-matnr
          AND spras = sy-langu.

      SELECT matnr meins zaun umrez umren
        FROM zmsutdt005
        INTO TABLE gt_zmsutdt005
        FOR ALL ENTRIES IN lt_mara
        WHERE bukrs EQ pa_vkorg
          AND matnr EQ lt_mara-matnr.
    ENDIF.
  ENDIF.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  CASE 'X'.
    WHEN radio3.
      PERFORM f_alv TABLES gt_out.
    WHEN OTHERS.
      IF gt_error[] IS NOT INITIAL.
        MESSAGE s000(zab)
        WITH 'Material different in a DO, check in error log'
        DISPLAY LIKE 'E'.
      ENDIF.
      PERFORM f_alv TABLES gt_detail.
  ENDCASE.
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
    WHEN radio3.
      PERFORM f_fieldcatg USING 'GT_OUT' :
        'TPGRP' 'LIKP' 'TPGRP' '' '' 'Nomor SP' '' '' '' '' '' '' ''
        '' '' '',
        'VBELN' 'LIKP' 'VBELN' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ERDAT' 'LIKP' 'ERDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MEINS' 'MARA' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KCMENG' 'LIPS' 'KCMENG' '' '' 'Quantity' '' '' '' '' '' ''
        'MEINS' '' '' ''.
    WHEN OTHERS.
      PERFORM f_fieldcatg USING 'GT_DETAIL' :
        'TPGRP' 'LIKP' 'TPGRP' '' '' 'Nomor SP' '' '' '' '' '' '' ''
        '' '' '',
        'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'MEINS' 'MARA' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KCMENG' 'LIPS' 'KCMENG' '' '' 'Quantity' '' '' '' '' '' ''
        'MEINS' '' '' ''.
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
  CASE 'X'.
    WHEN radio3.
      CLEAR ld_sort.
      ld_sort-fieldname = 'TPGRP'.
      ld_sort-up        = 'X'.
      ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.
    WHEN OTHERS.
  ENDCASE.
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
    WHEN radio3.
      SET PF-STATUS 'STANDARD'.
    WHEN OTHERS.
      SET PF-STATUS 'TOEXECUTE'.
  ENDCASE.

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
  DATA : lv_langu   TYPE sy-langu VALUE 'id',
         in_words   LIKE spell,
         lv_znou    TYPE posnr_vl,
         lv_werks   TYPE werks_d.

  CASE 'X'.
    WHEN radio3.
      LOOP AT gt_lips.
        gt_out-vbeln  = gt_lips-vbeln.
        gt_out-matnr  = gt_lips-matnr.
        READ TABLE gt_makt WITH KEY matnr = gt_lips-matnr.
        IF sy-subrc = 0.
          gt_out-maktx  = gt_makt-maktx.
        ENDIF.
        READ TABLE gt_likp WITH KEY vbeln = gt_lips-vbeln.
        IF sy-subrc = 0.
          gt_out-erdat  = gt_likp-erdat.
          gt_out-tpgrp  = gt_likp-tpgrp.
        ENDIF.
        gt_out-meins   = gt_lips-meins.
        gt_out-kcmeng  = gt_lips-kcmeng.
        COLLECT gt_out.
        CLEAR gt_out.
      ENDLOOP.
    WHEN OTHERS.
      PERFORM f_validasi_material.

      SORT gt_likp BY type tpgrp.
      SORT gt_lips BY matnr.
      LOOP AT gt_likp.
        IF radio1 IS NOT INITIAL.
          ON CHANGE OF gt_likp-type.
            PERFORM f_get_sp_number USING    gt_likp-erdat gt_likp-werks
                                    CHANGING gv_number.
          ENDON.
          gt_likp-tpgrp = gv_number.
        ENDIF.

        LOOP AT gt_lips WHERE vbeln = gt_likp-vbeln.
          gt_detail-tpgrp   = gt_likp-tpgrp.
          gt_detail-matnr   = gt_lips-matnr.
          READ TABLE gt_makt WITH KEY matnr = gt_lips-matnr.
          IF sy-subrc = 0.
            gt_detail-normt    = gt_makt-normt.
            gt_detail-maktx    = gt_makt-maktx.
          ENDIF.

          CASE gt_lips-type.
            WHEN 1.
              READ TABLE gt_zmpsiko INTO wa_zmpsiko
                                    WITH KEY matnr = gt_lips-matnr.
              IF sy-subrc = 0.
                gt_detail-zaktif  = wa_zmpsiko-zaktif.
                gt_detail-zkuat   = wa_zmpsiko-zkuat.
              ENDIF.
            WHEN 2.
              READ TABLE gt_zmpsiko1 INTO wa_zmpsiko1
                                     WITH KEY matnr = gt_lips-matnr.
              IF sy-subrc = 0.
                gt_detail-zaktif  = wa_zmpsiko1-zaktif.
                gt_detail-zkuat   = wa_zmpsiko1-zkuat.
              ENDIF.
            WHEN 3.
          ENDCASE.

          gt_detail-meins   = gt_lips-meins.
          gt_detail-kcmeng  = gt_lips-kcmeng.
          COLLECT gt_detail.
          CLEAR gt_detail.
        ENDLOOP.

        IF radio1 IS NOT INITIAL.
          MODIFY gt_likp TRANSPORTING tpgrp.
        ENDIF.
      ENDLOOP.

      SORT gt_detail BY tpgrp.
      LOOP AT gt_detail.
        ON CHANGE OF gt_detail-tpgrp.
          CLEAR lv_znou.
        ENDON.

        ADD 1 TO lv_znou.
        gt_detail-znou = lv_znou.

        WRITE gt_detail-kcmeng TO gt_detail-kcmengt UNIT gt_detail-meins.

        PERFORM f_split_quantity USING gt_detail-tpgrp gt_detail-matnr
                                       gt_detail-kcmeng gt_detail-meins
                                 CHANGING gt_detail-kcmengt gt_detail-meinst
                                          gt_detail-quantity.

        CALL FUNCTION 'SPELL_AMOUNT'
          EXPORTING
            amount    = gt_detail-kcmengt
            language  = lv_langu
          IMPORTING
            in_words  = in_words
          EXCEPTIONS
            not_found = 1
            too_large = 2
            OTHERS    = 3.

        IF sy-subrc = 0.
          gt_detail-qtytxt  = in_words-word.
        ENDIF.
        MODIFY gt_detail TRANSPORTING znou kcmengt qtytxt meinst quantity.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&LOG'.
      SET TITLEBAR 'LOG'.
      CALL SCREEN 501 STARTING AT 10 10 ENDING AT 130 22.
    WHEN '&PREV'.
      IF gt_error[] IS INITIAL.
        PERFORM f_print_form USING '' 'X'.
      ELSE.
        MESSAGE s000(zab)
        WITH 'Material different in a DO, check in error log'
        DISPLAY LIKE 'E'.
      ENDIF.
    WHEN '&PRNT'.
      IF gt_error[] IS INITIAL.
        PERFORM f_print_form USING 'X' ''.
        IF radio1 IS NOT INITIAL.
          PERFORM f_update_tpgrp.
        ENDIF.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE s000(zab)
        WITH 'Material different in a DO, check in error log'
        DISPLAY LIKE 'E'.
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
      PERFORM f_modify_screen USING : 'ABS' '0' '',
                                      'ERD' '0' ''.
    WHEN radio2.
      PERFORM f_modify_screen USING : 'KUN' '0' '',
                                      'ERD' '0' ''.
    WHEN radio3.
      PERFORM f_modify_screen USING : 'PDE' '0' '',
                                      'WAD' '0' '',
                                      'KUN' '0' ''.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF pa_vkorg IS INITIAL.
    PERFORM f_screen_error USING 'VKO' ''.
  ENDIF.
  IF pa_vstel IS INITIAL.
    PERFORM f_screen_error USING 'VST' ''.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      IF pa_kunnr IS INITIAL.
        PERFORM f_screen_error USING 'KUN' ''.
      ENDIF.
      IF so_wadat[] IS INITIAL.
        PERFORM f_screen_error USING 'WAD' ''.
      ELSE.
        IF so_wadat-high IS NOT INITIAL.
          IF so_wadat-low(6) <> so_wadat-high(6).
            PERFORM f_screen_error USING 'WAD' '1'.
          ENDIF.
        ELSE.
          PERFORM f_screen_error USING 'WAD' '0'.
        ENDIF.
      ENDIF.
      IF pa_pdest IS INITIAL.
        PERFORM f_screen_error USING 'PDE' ''.
      ENDIF.
    WHEN radio2.
      IF so_wadat[] IS INITIAL.
        PERFORM f_screen_error USING 'WAD' ''.
      ELSE.
        IF so_wadat-high IS NOT INITIAL.
          IF so_wadat-low(6) <> so_wadat-high(6).
            PERFORM f_screen_error USING 'WAD' '1'.
          ENDIF.
        ELSE.
          PERFORM f_screen_error USING 'WAD' '0'.
        ENDIF.
      ENDIF.
      IF pa_pdest IS INITIAL.
        PERFORM f_screen_error USING 'PDE' ''.
      ENDIF.
  ENDCASE.

ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  f_determine_smrt_funcmod
*&---------------------------------------------------------------------*
FORM f_determine_smrt_funcmod USING    fu_tdform  TYPE  tdsfname
                              CHANGING fc_funcmod TYPE  rs38l_fnam
                                       fc_subrc.

  CLEAR: fc_funcmod, fc_subrc.
  CLEAR: d_ctrl_param,
         d_output_opt,
         d_smrt_funcmod,
         d_ssfscreen.

  IF fu_tdform IS INITIAL.
    fc_subrc = 8.
  ELSE.
    SET PARAMETER ID 'SSFNAME' FIELD fu_tdform.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname                 = fu_tdform
*   VARIANT                  = ' '
*   DIRECT_CALL              = ' '
     IMPORTING
       fm_name                  = fc_funcmod
     EXCEPTIONS
       no_form                  = 1
       no_function_module       = 2
       OTHERS                   = 3.

    fc_subrc = sy-subrc.
  ENDIF.

* set output options
  d_output_opt-tddest    = pa_pdest.
  CLEAR: d_output_opt-tdimmed.
  IF p_disp IS INITIAL.
    d_output_opt-tdimmed   = 'X'.
  ENDIF.

  d_output_opt-tdnewid   = 'X'.

  d_ctrl_param-preview   = p_disp.
  d_ctrl_param-no_dialog = 'X'.

  d_ssfscreen-fname = fu_tdform.
ENDFORM.                    " f_determine_smrt_funcmod

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form USING    fu_tdnoprev fu_tdnoprint.
  DATA : lt_header  LIKE gt_likp OCCURS 0 WITH HEADER LINE.
  DATA : lt_detail  LIKE gt_detail OCCURS 0 WITH HEADER LINE.

  DATA : lv_flag(1).

  lt_header[] = gt_likp[].
  SORT lt_header BY tpgrp.
  DELETE ADJACENT DUPLICATES FROM lt_header COMPARING tpgrp.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
    d_output_opt-tdnoprev   = fu_tdnoprev.
    d_output_opt-tdnoprint  = fu_tdnoprint.
    d_output_opt-tdimmed    = 'X'.
    d_output_opt-tddelete   = 'X'.
    d_output_opt-tdcopies   = 1.

    LOOP AT lt_header.
      AT FIRST.
        d_ctrl_param-no_close = 'X'.
      ENDAT.

      AT LAST.
        d_ctrl_param-no_close = space.
      ENDAT.

      CLEAR gs_header.
      PERFORM f_write_header USING lt_header.
      PERFORM f_get_title_form USING lt_header-type.

      CLEAR : lt_detail[], lt_detail, lv_flag.
      LOOP AT gt_detail WHERE tpgrp = lt_header-tpgrp.
        lt_detail = gt_detail.
        COLLECT lt_detail.
      ENDLOOP.

      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          gs_header          = gs_header
        TABLES
          gt_detail          = lt_detail.

      d_ctrl_param-no_open = 'X'.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_GET_WERKS_FR_T001L
*&---------------------------------------------------------------------*
FORM f_get_werks_fr_t001l  USING    fu_kunnr fu_werks
                           CHANGING fc_werks.
  CLEAR fc_werks.

  SELECT SINGLE vstel
    FROM t001l
    INTO fc_werks
    WHERE kunnr = fu_kunnr.

  IF sy-subrc <> 0.
    fc_werks  = fu_werks.
  ENDIF.
ENDFORM.                    " F_GET_WERKS_FR_T001L

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_ERROR
*&---------------------------------------------------------------------*
FORM f_screen_error  USING    fu_group fu_error.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  CASE fu_error.
    WHEN 1.
      MESSAGE e000(zab) WITH 'GI dates must be in the same period'.
    WHEN OTHERS.
      MESSAGE e000(zab) WITH lv_mess.
  ENDCASE.
ENDFORM.                    " F_SCREEN_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_GET_NUMBER_SP
*&---------------------------------------------------------------------*
FORM f_get_number_sp  USING    p_gt_likp_werks.
*    SELECT SINGLE nrlevel
*      FROM nriv
*      INTO gv_number
*      WHERE object     = 'ZGDSPU'
*        AND subobject  = fu_werks
*        AND nrrangenr  = '01'
*        AND toyear     = fu_gjahr.
*    gv_number = gv_number + 1.
ENDFORM.                    " F_GET_NUMBER_SP

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1093   text
*      -->P_1094   text
*      -->P_1095   text
*----------------------------------------------------------------------*
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
*&      Form  F_GET_TITLE_FORM
*&---------------------------------------------------------------------*
FORM f_get_title_form  USING    fu_type.
  CASE fu_type.
    WHEN 1.
      gs_header-repti  = 'SURAT PESANAN OBAT JADI PREKURSOR FARMASI'.
      gs_header-repti1 = 'Obat Jadi Prekursor Farmasi'.
    WHEN 2.
      gs_header-repti  = 'SURAT PESANAN PSIKOTROPIKA'.
      gs_header-repti1 = 'Psikotropika'.
    WHEN 3.
      gs_header-repti  = 'SURAT PESANAN'.
      gs_header-repti1 = 'Produk'.
  ENDCASE.
ENDFORM.                    " F_GET_TITLE_FORM

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_HEADER
*&---------------------------------------------------------------------*
FORM f_write_header USING    fwa_header STRUCTURE gt_likp.
  CASE 'X'.
    WHEN radio1.
      CLEAR : gs_header-vstat.
    WHEN radio2.
      gs_header-vstat = 1.
  ENDCASE.

  gs_header-nomor     = fwa_header-tpgrp.
  gs_header-werks     = fwa_header-werks.
  gs_header-monat     = fwa_header-erdat+4(2).
  gs_header-gjahr     = fwa_header-erdat(4).
  gs_header-wadat_ist = fwa_header-wadat_ist.
  gs_header-jabatan   = 'Penanggung Jawab PBF'.
  gs_header-seldt     = so_wadat-low.
  CONCATENATE so_wadat-low+6(2) '-' so_wadat-high+6(2)
  INTO gs_header-prefix.

  SELECT SINGLE street post_code1 city1 tel_number
    FROM twlad JOIN adrc ON twlad~adrnr = adrc~addrnumber
    INTO (gs_header-street, gs_header-post_code1, gs_header-city1,
    gs_header-tel_number)
    WHERE werks = pa_vstel
      AND lgort = '1000'.

  READ TABLE gt_zplbc WITH KEY reswk = fwa_header-vstel.
  IF sy-subrc = 0.
    IF fwa_header-lfart = 'NLCC'.
      IF fwa_header-werks(2) = '07'.
        gs_header-united = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT SINGLE kna1~name1 adrc~city1 name_co str_suppl1 str_suppl2
    adrc~name1 adrc~name2 kna1~name3 adrc~street mcod1 mcod2
    FROM kna1 JOIN adrc ON kna1~adrnr = adrc~addrnumber
    INTO (gs_header-name1, gs_header-ort01, gs_header-name_co,
    gs_header-str_suppl1, gs_header-str_suppl2, gs_header-name1_ad,
    gs_header-name2_ad, gs_header-name3, gs_header-street_ad,
    gs_header-mcod1, gs_header-mcod2)
    WHERE kunnr = pa_kunnr.

  IF pa_kunnr = 'TBA0201'.
    gs_header-name_co = 'Jakarta 1 Branch'.
  ENDIF.

  CLEAR gs_header-pbfno.
  IF gs_header-united IS NOT INITIAL.
    PERFORM f_header_for_united.
  ELSE.
    PERFORM f_header_for_non_united USING fwa_header.
  ENDIF.

  CONCATENATE gs_header-name1 gs_header-ort01 INTO gs_header-cabang
  SEPARATED BY space.
  TRANSLATE gs_header-cabang TO UPPER CASE.

  SELECT SINGLE vtext
    FROM tvkot
    INTO gs_header-vtext
    WHERE spras = sy-langu
      AND vkorg = pa_vkorg.

  CONCATENATE 'PT' gs_header-vtext INTO gs_header-vtext
  SEPARATED BY space.

  TRANSLATE gs_header-vtext TO UPPER CASE.

ENDFORM.                    " F_WRITE_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_GET_TYPE_REPORT
*&---------------------------------------------------------------------*
FORM f_get_type_report  USING    fu_matnr
                        CHANGING fc_type.
  READ TABLE gt_zmpsiko INTO wa_zmpsiko
                        WITH KEY bukrs = pa_vkorg
                                 matnr = fu_matnr.
  IF sy-subrc = 0.
    fc_type  = 1.
  ELSE.
    READ TABLE gt_zmpsiko1 INTO wa_zmpsiko1
                           WITH KEY bukrs = pa_vkorg
                                    matnr = fu_matnr.
    IF sy-subrc = 0.
      fc_type  = 2.
    ELSE.
      fc_type  = 3.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_TYPE_REPORT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_MATERIAL
*&---------------------------------------------------------------------*
FORM f_validasi_material .
  DATA : lv_count   TYPE int4.

  DATA : lt_lips    LIKE gt_lips OCCURS 0 WITH HEADER LINE.

  LOOP AT gt_lips.
    PERFORM f_get_type_report USING    gt_lips-matnr
                              CHANGING gt_lips-type.
    MODIFY gt_lips TRANSPORTING type.

    lt_lips-vbeln   = gt_lips-vbeln.
    lt_lips-matnr   = gt_lips-matnr.
    lt_lips-type    = gt_lips-type.
    APPEND lt_lips.
  ENDLOOP.

  SORT lt_lips BY vbeln type.
  DELETE ADJACENT DUPLICATES FROM lt_lips COMPARING vbeln type.

  LOOP AT gt_likp.
    CLEAR lv_count.
    LOOP AT lt_lips WHERE vbeln = gt_likp-vbeln.
      ADD 1 TO lv_count.
      IF radio1 IS NOT INITIAL.
        gt_error-vbeln  = lt_lips-vbeln.
        gt_error-matnr  = lt_lips-matnr.
        CASE lt_lips-type.
          WHEN 1.
            gt_error-jenis = 'Obat Jadi Prekursor Farmasi'.
          WHEN 2.
            gt_error-jenis = 'Psikotropika'.
          WHEN 3.
            gt_error-jenis = 'Produk'.
        ENDCASE.
        APPEND gt_error.
        CLEAR gt_error.
      ENDIF.
      gt_likp-type  = lt_lips-type.
    ENDLOOP.
    IF lv_count > 1.
      EXIT.
    ELSE.
      CLEAR : gt_error[], gt_error.
      MODIFY gt_likp TRANSPORTING type.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_VALIDASI_MATERIAL

*&---------------------------------------------------------------------*
*&      Module  STATUS_0501  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0501 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS_0501  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_0501  OUTPUT
*&---------------------------------------------------------------------*
MODULE list_processing_0501 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_error_list.
ENDMODULE.                 " LIST_PROCESSING_0501  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LIST
*&---------------------------------------------------------------------*
FORM f_error_list .
  DATA: lv_zebra  TYPE i.
  WRITE: / sy-uline(80).
  FORMAT COLOR 1.
  WRITE: / sy-vline, (10) 'Document',
           sy-vline, (10) 'Material',
           sy-vline, (50) 'Jenis Material',
           sy-vline.
  WRITE: / sy-uline(80).
  FORMAT COLOR OFF.
  SORT gt_error BY vbeln.
  LOOP AT gt_error.
    IF lv_zebra IS INITIAL.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED ON.
      lv_zebra  = 1.
    ELSE.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
      lv_zebra  = 0.
    ENDIF.
    WRITE: / sy-vline, gt_error-vbeln,
             sy-vline, (10) gt_error-matnr,
             sy-vline, gt_error-jenis,
             sy-vline.
  ENDLOOP.
  WRITE : / sy-uline(80).
ENDFORM.                    " F_ERROR_LIST

*&---------------------------------------------------------------------*
*&      Form  F_GET_SP_NUMBER
*&---------------------------------------------------------------------*
FORM f_get_sp_number  USING    fu_erdat fu_werks
                      CHANGING fc_number.
  DATA : lv_gjahr   TYPE gjahr.

  CHECK gt_error[] IS INITIAL.

  IF fc_number IS INITIAL.
    lv_gjahr = fu_erdat(4).
    SELECT SINGLE nrlevel
      FROM nriv
      INTO fc_number
      WHERE object     = 'ZGDSPU'
        AND subobject  = fu_werks
        AND nrrangenr  = '01'
        AND toyear     = lv_gjahr.
  ENDIF.
  fc_number = fc_number + 1.
ENDFORM.                    " F_GET_SP_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_FOR_UNITED
*&---------------------------------------------------------------------*
FORM f_header_for_united .
  SELECT SINGLE pbfno
    FROM zpbf
    INTO gs_header-pbfno
    WHERE vkbur = '0700'.

  SELECT SINGLE user_name no_sk object_name
    FROM zsign
    INTO (gs_header-user_name, gs_header-no_sk, gs_header-object)
    WHERE s_point = '0700'.

  gs_header-name_co     = gs_header-name1_ad.
  gs_header-str_suppl1  = gs_header-mcod1.
  gs_header-str_suppl2  = gs_header-mcod2.
ENDFORM.                    " F_HEADER_FOR_UNITED

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_FOR_NON_UNITED
*&---------------------------------------------------------------------*
FORM f_header_for_non_united USING    fwa_header STRUCTURE gt_likp.
  SELECT SINGLE pbfno
    FROM zpbf
    INTO gs_header-pbfno
    WHERE vkbur = fwa_header-werks.

  SELECT SINGLE user_name no_sk object_name
    FROM zsign
    INTO (gs_header-user_name, gs_header-no_sk, gs_header-object)
    WHERE s_point = fwa_header-werks.
ENDFORM.                    " F_HEADER_FOR_NON_UNITED

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_TPGRP
*&---------------------------------------------------------------------*
FORM f_update_tpgrp .
  DATA : lt_likp     LIKE gt_likp OCCURS 0 WITH HEADER LINE.
  DATA : lv_nrlevel  TYPE nrlevel,
         lv_count    TYPE i,
         lv_werks    TYPE werks_d,
         lv_gjahr    TYPE gjahr.

  lv_nrlevel  = gv_number.

  lt_likp[] = gt_likp[].
  SORT lt_likp BY tpgrp.
  DELETE ADJACENT DUPLICATES FROM lt_likp COMPARING tpgrp.
  DESCRIBE TABLE lt_likp LINES lv_count.

  READ TABLE gt_likp INDEX 1.
  IF sy-subrc = 0.
    lv_werks  = gt_likp-werks.
    lv_gjahr  = gt_likp-erdat(4).
  ENDIF.

  LOOP AT gt_likp.
    UPDATE likp SET tpgrp = gt_likp-tpgrp
                WHERE vbeln = gt_likp-vbeln.
  ENDLOOP.

  DO lv_count TIMES.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = 'ZGDSPU'
        subobject               = lv_werks
        toyear                  = lv_gjahr
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
  ENDDO.
ENDFORM.                    " F_UPDATE_TPGRP

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_QUANTITY
*&---------------------------------------------------------------------*
FORM f_split_quantity  USING    fu_tpgrp fu_matnr fu_kcmeng fu_meins
                       CHANGING fc_kcmengt fc_meins fc_quantity.

  DATA : lv_car   TYPE kcmeng,
         lv_uom   TYPE kcmeng,
         lv_cart  TYPE tdline,
         lv_uomt  TYPE tdline.

  READ TABLE gt_likp WITH KEY tpgrp = fu_tpgrp.
  IF sy-subrc = 0.
    CASE gt_likp-type.
      WHEN 1.
        fc_meins  = fu_meins.
      WHEN 2.
        fc_meins  = fu_meins.
      WHEN 3.
        fc_meins  = 'KAR'.
        READ TABLE gt_zmsutdt005 WITH KEY matnr = fu_matnr
                                          zaun  = 'KAR'.
        IF sy-subrc = 0.
          lv_car = fu_kcmeng DIV gt_zmsutdt005-umrez.
          lv_uom = fu_kcmeng MOD gt_zmsutdt005-umrez.

          IF lv_uom <> 0.
            lv_car  = lv_car + 1.
            WRITE lv_car TO fc_kcmengt UNIT 'KAR'.
          ELSE.
            WRITE lv_car TO fc_kcmengt UNIT 'KAR'.
          ENDIF.
        ELSE.
          lv_car  = 0.
          WRITE lv_car TO fc_kcmengt UNIT 'KAR'.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_SPLIT_QUANTITY
