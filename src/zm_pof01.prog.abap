*----------------------------------------------------------------------*
*   INCLUDE ZM_POF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  gv_bsart = pa_bsart.

  IF radio3 IS NOT INITIAL.
    so_ebeln[] = so_pon2[].
  ELSEIF radio4 IS NOT INITIAL OR
     radio5 IS NOT INITIAL.
    pa_bsart = 'ZSUB'.
    so_ebeln[] = so_pon1[].
  ELSE.
    IF pa_bukrs = '8380'.
      pa_bsart = 'ZB'.
    ELSE.
      pa_bsart = 'ZICO'.
    ENDIF.
    IF radio1 IS NOT INITIAL.
      IF pa_bukrs = '8020'.
        ls_bsart-sign = 'I'.
        ls_bsart-option = 'EQ'.
        ls_bsart-low = 'ZB'.
        APPEND ls_bsart TO lr_bsart.
        CLEAR: ls_bsart.

        ls_bsart-sign = 'I'.
        ls_bsart-option = 'EQ'.
        ls_bsart-low = 'ZICO'.
        APPEND ls_bsart TO lr_bsart.
        CLEAR: ls_bsart.
*        pa_bsart = 'ZB'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA : lv_bedat   TYPE sy-datum.
  DATA : lr_bedat TYPE RANGE OF sy-datum,
         ls_bedat LIKE LINE OF lr_bedat.

  CASE 'X'.
    WHEN radio3.
      IF so_vstel[] IS NOT INITIAL.
        lr_bedat[]  = so_bedat[].

        READ TABLE lr_bedat INTO ls_bedat INDEX 1.
        IF ls_bedat-option = 'LT'.
        ELSE.
          CONCATENATE ls_bedat-low(6) '01' INTO lv_bedat.
          lv_bedat  = lv_bedat - 1.
          CONCATENATE lv_bedat(6) '01' INTO ls_bedat-low.
          MODIFY lr_bedat FROM ls_bedat INDEX 1 TRANSPORTING low.
        ENDIF.

        SELECT *
          FROM vetvg
          INTO CORRESPONDING FIELDS OF TABLE gt_vetvg
          WHERE vstel IN so_vstel
            AND ledat IN lr_bedat
            AND vbeln IN so_ebeln
            AND vkorg = pa_bukrs
            AND auart = pa_bsart.

        IF gt_vetvg[] IS NOT INITIAL.
          SELECT ebeln bsart lifnr
            FROM ekko
            INTO CORRESPONDING FIELDS OF TABLE gt_ekko
            FOR ALL ENTRIES IN gt_vetvg
            WHERE ebeln = gt_vetvg-vbeln
              AND bedat IN so_bedat
              AND bukrs = pa_bukrs
              AND ekorg = pa_ekorg
              AND bsart = pa_bsart.

          IF gt_ekko[] IS NOT INITIAL.
            IF pa_delco IS NOT INITIAL.
              SELECT ebeln ebelp matnr werks menge meins
                FROM ekpo
                INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
                FOR ALL ENTRIES IN gt_ekko
                WHERE ebeln EQ gt_ekko-ebeln
                  AND ( loekz EQ space
                   OR loekz EQ 'S' )
                  AND elikz EQ space
                  AND inco1 <> 'DDC'.
            ELSE.
              SELECT ebeln ebelp matnr werks menge meins
                FROM ekpo
                INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
                FOR ALL ENTRIES IN gt_ekko
                WHERE ebeln EQ gt_ekko-ebeln
                  AND ( loekz EQ space
                   OR loekz EQ 'S' )
                  AND inco1 <> 'DDC'.
            ENDIF.

            IF gt_ekpo[] IS NOT INITIAL.
              SELECT ebeln ebelp eindt menge wemng wamng glmng mng02
                FROM eket
                INTO CORRESPONDING FIELDS OF TABLE gt_eket
                FOR ALL ENTRIES IN gt_ekpo
                WHERE ebeln EQ gt_ekpo-ebeln
                  AND ebelp EQ gt_ekpo-ebelp
                  AND eindt IN so_eindt.

              SELECT *
                FROM ekbe
                INTO CORRESPONDING FIELDS OF TABLE gt_ekbe
                FOR ALL ENTRIES IN gt_ekpo
                WHERE ebeln EQ gt_ekpo-ebeln
                  AND ebelp EQ gt_ekpo-ebelp
                  AND vgabe EQ '8'
                  AND gjahr EQ '0000'
                  AND bewtp EQ 'L'.

              SELECT *
                FROM zmpo
                INTO CORRESPONDING FIELDS OF TABLE gt_zmpo
                FOR ALL ENTRIES IN gt_ekpo
                WHERE ebeln EQ gt_ekpo-ebeln
                  AND ebelp EQ gt_ekpo-ebelp.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        SELECT ebeln bsart lifnr
          FROM ekko
          INTO CORRESPONDING FIELDS OF TABLE gt_ekko
          WHERE ebeln IN so_ebeln
            AND bedat IN so_bedat
            AND bukrs = pa_bukrs
            AND ekorg = pa_ekorg
            AND bsart = pa_bsart.

        IF gt_ekko[] IS NOT INITIAL.
          IF pa_delco IS NOT INITIAL.
            SELECT ebeln ebelp matnr werks menge meins
              FROM ekpo
              INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
              FOR ALL ENTRIES IN gt_ekko
              WHERE ebeln EQ gt_ekko-ebeln
                AND loekz EQ space
                AND elikz EQ space
                AND inco1 <> 'DDC'.
          ELSE.
            SELECT ebeln ebelp matnr werks menge meins
              FROM ekpo
              INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
              FOR ALL ENTRIES IN gt_ekko
              WHERE ebeln EQ gt_ekko-ebeln
                AND loekz EQ space
                AND inco1 <> 'DDC'.
          ENDIF.

          IF gt_ekpo[] IS NOT INITIAL.
            SELECT ebeln ebelp eindt menge wemng wamng glmng mng02
              FROM eket
              INTO CORRESPONDING FIELDS OF TABLE gt_eket
              FOR ALL ENTRIES IN gt_ekpo
              WHERE ebeln EQ gt_ekpo-ebeln
                AND ebelp EQ gt_ekpo-ebelp
                AND eindt IN so_eindt.

            SELECT *
              FROM ekbe
              INTO CORRESPONDING FIELDS OF TABLE gt_ekbe
              FOR ALL ENTRIES IN gt_ekpo
              WHERE ebeln EQ gt_ekpo-ebeln
                AND ebelp EQ gt_ekpo-ebelp
                AND vgabe EQ '8'
                AND gjahr EQ '0000'
                AND bewtp EQ 'L'.

            SELECT *
              FROM zmpo
              INTO CORRESPONDING FIELDS OF TABLE gt_zmpo
              FOR ALL ENTRIES IN gt_ekpo
              WHERE ebeln EQ gt_ekpo-ebeln
                AND ebelp EQ gt_ekpo-ebelp.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN radio4 OR radio5.
      SELECT ebeln bsart lifnr
        FROM ekko
        INTO CORRESPONDING FIELDS OF TABLE gt_ekko
        WHERE ebeln IN so_ebeln.

      IF gt_ekko[] IS NOT INITIAL.
        SELECT ebeln ebelp matnr werks menge meins
          FROM ekpo
          INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
          FOR ALL ENTRIES IN gt_ekko
          WHERE ebeln EQ gt_ekko-ebeln
            AND loekz EQ space.
      ENDIF.

      IF radio5 IS NOT INITIAL.
        SELECT ebeln ebelp eindt
          FROM eket
          INTO CORRESPONDING FIELDS OF TABLE gt_eket
          FOR ALL ENTRIES IN gt_ekko
          WHERE ebeln EQ gt_ekko-ebeln.
      ENDIF.

    WHEN OTHERS.
      SELECT ebeln bsart lifnr
         FROM ekko
         INTO CORRESPONDING FIELDS OF TABLE gt_ekko
         WHERE ebeln IN so_ebeln
           AND bukrs EQ pa_bukrs
           AND bsart EQ pa_bsart
           AND bedat IN so_bedat.

      IF radio1 IS NOT INITIAL.
        IF pa_bukrs = '8020'.
          SELECT ebeln bsart lifnr
            FROM ekko
            INTO CORRESPONDING FIELDS OF TABLE gt_ekko
            WHERE ebeln IN so_ebeln
              AND bukrs EQ pa_bukrs
              AND bsart IN lr_bsart"EQ pa_bsart
              AND bedat IN so_bedat.
        ENDIF.
      ENDIF.

      IF gt_ekko[] IS NOT INITIAL.
        SELECT ebeln ebelp matnr werks lgort menge meins
          FROM ekpo
          INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
          FOR ALL ENTRIES IN gt_ekko
          WHERE ebeln EQ gt_ekko-ebeln
            AND loekz EQ space
            AND werks IN so_werks.
      ENDIF.
  ENDCASE.
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
  PERFORM f_fieldcatg USING ft_report:
    'EBELN' 'EKKO' 'EBELN' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
    'EBELP' 'EKPO' 'EBELP' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MATNR' 'EKPO' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WERKS' 'EKPO' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  CASE 'X'.
    WHEN radio3.
      PERFORM f_fieldcatg USING ft_report:
        'MENGE' 'EKPO' 'MENGE' '' '' '' '' '' '' '' '' '' 'MEINS' '' '' '',
        'MEINS' 'EKPO' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR' 'EKBE' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    WHEN radio4.
      PERFORM f_fieldcatg USING ft_report:
        'MENGE' 'EKPO' 'MENGE' '' '' '' '' '' '' '' '' '' 'MEINS' '' 'X' '',
        'MEINS' 'EKPO' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    WHEN radio5.
      PERFORM f_fieldcatg USING ft_report:
        'MENGE' 'EKPO' 'MENGE' '' '' '' '' '' '' '' '' '' 'MEINS' '' '' '',
        'MEINS' 'EKPO' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'EINDT' 'EKET' 'EINDT' '' '' '' '' '' '' '' '' '' '' '' 'X' ''.
    WHEN OTHERS.
      PERFORM f_fieldcatg USING ft_report:
        'MENGE' 'EKPO' 'MENGE' '' '' '' '' '' '' '' '' '' 'MEINS' '' '' '',
        'MEINS' 'EKPO' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'EBELN1' 'EKKO' 'EBELN' '' '' 'PO Pabrik' '' 'X' '' '' '' '' '' '' '' ''.
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
  ld_sort-fieldname = 'EBELN'.
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
    WHEN radio1 OR radio3 OR radio4 OR radio5.
      IF gv_status IS INITIAL.
        SET PF-STATUS 'TOEXECUTE'.
      ELSE.
        SET PF-STATUS 'ERRORLOG'.
      ENDIF.
    WHEN radio2.
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
  DATA: lv_flag(1),
        lv_subrc   TYPE sy-subrc,
        lv_ebeln   TYPE ebeln,
        ls_vetvg   TYPE vetvg,
        lv_wamng   TYPE eket-wamng,
        ls_zmpo    LIKE LINE OF gt_zmpo.

  SORT gt_ekko BY ebeln.
  SORT gt_ekpo BY ebeln ebelp.
  SORT gt_eket BY ebeln ebelp.

  LOOP AT gt_ekko.
    PERFORM f_check_header_text USING gt_ekko-ebeln
                                CHANGING lv_subrc lv_ebeln.

    IF radio2 EQ 'X' OR
      radio3 EQ 'X' OR
      radio4 EQ 'X' OR
      radio5 EQ 'X'.
      CLEAR lv_subrc.
    ENDIF.

    IF lv_subrc IS INITIAL.
      gt_out-bsart    = gt_ekko-bsart.
      gt_out-lifnr    = gt_ekko-lifnr.
      LOOP AT gt_ekpo WHERE ebeln EQ gt_ekko-ebeln.
        IF radio3 IS INITIAL AND
          radio5 IS INITIAL.
          IF lv_flag IS INITIAL.
            lv_flag = 1.
            gt_out-ebeln1 = lv_ebeln.
          ELSE.
            gt_out-check  = '2'.
          ENDIF.
        ENDIF.
        gt_out-ebeln  = gt_ekpo-ebeln.
        gt_out-ebelp  = gt_ekpo-ebelp.
        gt_out-matnr  = gt_ekpo-matnr.
        gt_out-werks  = gt_ekpo-werks.
        gt_out-lgort  = gt_ekpo-lgort.
        gt_out-menge  = gt_ekpo-menge.
        gt_out-meins  = gt_ekpo-meins.

        IF radio3 IS NOT INITIAL.
          READ TABLE gt_ekbe WITH KEY ebeln = gt_ekpo-ebeln
                                      ebelp = gt_ekpo-ebelp.
          IF sy-subrc = 0.
            gt_out-belnr    = gt_ekbe-belnr.
          ENDIF.

          CLEAR lv_wamng.
          IF pa_reqty IS INITIAL.
            LOOP AT gt_eket WHERE ebeln = gt_ekpo-ebeln
                              AND ebelp = gt_ekpo-ebelp.
              gt_seket = gt_eket.
              COLLECT gt_seket.
              ADD gt_seket-glmng  TO lv_wamng.
            ENDLOOP.
            gt_out-wamng  = lv_wamng.
*            IF gt_out-menge = lv_wamng.
*              CONTINUE.
*            ENDIF.
            LOOP AT gt_ekbe WHERE ebeln = gt_ekpo-ebeln
                              AND ebelp = gt_ekpo-ebelp.
              CONCATENATE gt_out-deliv_no gt_ekbe-belnr INTO gt_out-deliv_no.
            ENDLOOP.
          ELSE.
            LOOP AT gt_zmpo INTO ls_zmpo
                           WHERE ebeln = gt_ekpo-ebeln
                             AND ebelp = gt_ekpo-ebelp.
              ADD ls_zmpo-menge TO lv_wamng.
            ENDLOOP.
            IF lv_wamng IS INITIAL.
              LOOP AT gt_eket WHERE ebeln = gt_ekpo-ebeln
                                AND ebelp = gt_ekpo-ebelp.
                gt_seket = gt_eket.
                COLLECT gt_seket.
                ADD gt_seket-mng02  TO lv_wamng.
              ENDLOOP.
            ENDIF.
            IF lv_wamng IS NOT INITIAL.
              gt_out-wamng  = lv_wamng.
            ELSE.
              gt_out-wamng = gt_out-menge.
            ENDIF.

            IF gt_out-menge = gt_out-wamng.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.

        IF radio5 IS NOT INITIAL.
          READ TABLE gt_eket WITH KEY ebeln = gt_ekpo-ebeln
                                      ebelp = gt_ekpo-ebelp
                             BINARY SEARCH.
          IF sy-subrc EQ 0.
            gt_out-eindt  = gt_eket-eindt.
          ENDIF.
        ENDIF.

        APPEND gt_out.
        CLEAR gt_out.
      ENDLOOP.
    ENDIF.
    CLEAR: lv_flag, lv_subrc, lv_ebeln.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  DATA: lv_ebeln  TYPE ebeln.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&IC1'.
      IF fu_selfield-value IS NOT INITIAL.
        CASE fu_selfield-sel_tab_field.
          WHEN 'GT_OUT-EBELN'.
            lv_ebeln  = fu_selfield-value.
            SET PARAMETER ID 'BES' FIELD lv_ebeln.
            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
          WHEN 'GT_OUT-EBELN1'.
            lv_ebeln  = fu_selfield-value.
            SET PARAMETER ID 'BES' FIELD lv_ebeln.
            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
        ENDCASE.
      ENDIF.

    WHEN '&POS'.
      CASE 'X'.
        WHEN radio1.
          PERFORM f_post_entries.
          IF gv_status IS INITIAL.
            MESSAGE s000(zab)
            WITH 'Data already processed'.
            LEAVE TO SCREEN 0.
          ELSE.
            PERFORM f_alv TABLES gt_out.
            LEAVE TO SCREEN 0.
          ENDIF.
        WHEN radio3.
          PERFORM f_change_status.
          MESSAGE s000(zab)
          WITH 'Data already processed'.
          LEAVE TO SCREEN 0.
        WHEN radio4.
          PERFORM f_change_qty.
          IF gv_status IS INITIAL.
            MESSAGE s000(zab)
            WITH 'Data already processed'.
            LEAVE TO SCREEN 0.
          ELSE.
            PERFORM f_alv TABLES gt_out.
            LEAVE TO SCREEN 0.
          ENDIF.
        WHEN radio5.
          PERFORM f_change_deliv_date.
          MESSAGE s000(zab)
          WITH 'Data already processed'.
          LEAVE TO SCREEN 0.
      ENDCASE.

    WHEN '&LOG'.
      CALL SCREEN 500 STARTING AT 10 10 ENDING AT 132 22.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.
  DATA: lt_out         LIKE gt_out OCCURS 0 WITH HEADER LINE.

  DATA: lwa_poheader  LIKE bapimepoheader,
        lwa_poheaderx LIKE bapimepoheaderx.

  DATA: lv_ebeln LIKE bapimepoheader-po_number,
        lv_reswk TYPE reswk.
  DATA: lt_poitem     LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
        lt_poschedule LIKE bapimeposchedule OCCURS 0 WITH HEADER LINE,
        lt_return     LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check NE 'X'.
  LOOP AT lt_out.
    PERFORM f_po_detail TABLES lt_poitem
                               lt_poschedule
                               lt_return
                        USING lt_out-ebeln
                        CHANGING lwa_poheader lwa_poheaderx
                                 lv_reswk.

    CLEAR: lt_return[], lt_return.
    PERFORM f_po_create TABLES lt_poitem
                               lt_poschedule
                               lt_return
                        USING lwa_poheader lwa_poheaderx
                              lt_out-ebeln lt_out-bsart lt_out-lifnr
                              lv_reswk
                        CHANGING lv_ebeln.

    READ TABLE lt_return WITH KEY type = 'E'.
    IF sy-subrc EQ 0.
      gv_status = 1.
      LOOP AT lt_return WHERE type EQ 'E'.
        gt_error-type   = lt_return-type.
        gt_error-ebeln  = lt_out-ebeln.
        gt_error-msg    = lt_return-message.
        APPEND gt_error.
      ENDLOOP.
    ELSE.
      PERFORM f_header_text TABLES lt_poitem
                            USING lt_out-ebeln lv_ebeln.
    ENDIF.

    CLEAR: lt_poitem[], lt_poitem, lt_poschedule[], lt_poschedule,
           lv_ebeln.
  ENDLOOP.
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
*&      Form  F_CHECK_HEADER_TEXT
*&---------------------------------------------------------------------*
FORM f_check_header_text  USING    fu_ebeln
                          CHANGING fc_subrc fc_ebeln.
  DATA: lv_name  TYPE tdobname,
        lt_lines LIKE tline OCCURS 0 WITH HEADER LINE.

  lv_name = fu_ebeln.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'F01'
      language                = sy-langu
      name                    = lv_name
      object                  = 'EKKO'
    TABLES
      lines                   = lt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  IF lt_lines[] IS NOT INITIAL.
    fc_subrc = 4.
    READ TABLE lt_lines INDEX 1.
    IF sy-subrc EQ 0.
      fc_ebeln  = lt_lines-tdline(10).
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_HEADER_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_PO_DETAIL
*&---------------------------------------------------------------------*
FORM f_po_detail  TABLES   ft_poitem STRUCTURE bapimepoitem
                           ft_poschedule STRUCTURE bapimeposchedule
                           ft_return STRUCTURE bapiret2
                  USING    fu_ebeln
                  CHANGING fwa_poheader STRUCTURE bapimepoheader
                           fwa_poheaderx STRUCTURE bapimepoheaderx
                           fc_reswk.

  DATA: lwa_poheader  LIKE bapimepoheader.

  CALL FUNCTION 'BAPI_PO_GETDETAIL1'
    EXPORTING
      purchaseorder = fu_ebeln
    IMPORTING
      poheader      = lwa_poheader
    TABLES
      return        = ft_return
      poitem        = ft_poitem
      poschedule    = ft_poschedule.

  IF sy-subrc EQ 0.
    PERFORM f_get_company_code USING lwa_poheader-suppl_plnt
                               CHANGING fwa_poheader-comp_code.
*    IF pa_bsart IS INITIAL.
*      pa_bsart = 'ZSUB'.
*    ENDIF.

    IF pa_bukrs = '8380'.
      gv_bsart = 'ZB'.
    ELSEIF pa_bukrs = '8020'.
    ELSE.
      gv_bsart = 'ZICO'.
    ENDIF.

    fwa_poheaderx-comp_code  = 'X'.
    fwa_poheader-doc_type    = gv_bsart. "'ZSUB'.
    fwa_poheaderx-doc_type   = 'X'.
    fwa_poheader-vendor      = 'TSB3600'.
    fwa_poheaderx-vendor     = 'X'.
    fwa_poheader-purch_org   = 'FAC'.
    fwa_poheaderx-purch_org  = 'X'.
    fwa_poheader-pur_group   = 'FAC'.
    fwa_poheaderx-pur_group  = 'X'.
    fwa_poheader-doc_date    = lwa_poheader-doc_date.
    fwa_poheaderx-doc_date   = 'X'.
    fc_reswk = lwa_poheader-suppl_plnt.

    SELECT eina~infnr INTO TABLE @DATA(it_ekpo_eina) FROM ekpo
      JOIN eina ON ekpo~matnr = eina~matnr
      WHERE ebeln = @fu_ebeln.

    IF it_ekpo_eina[] IS NOT INITIAL.
      IF gv_bsart = 'ZSUB'.
        SELECT infnr INTO TABLE @DATA(it_eina_eine) FROM eine
          FOR ALL ENTRIES IN @it_ekpo_eina
          WHERE infnr = @it_ekpo_eina-infnr
          AND ekorg = 'FAC'
          AND esokz = '3'.
      ELSEIF gv_bsart = 'ZB'.
        SELECT infnr INTO TABLE it_eina_eine FROM eine
          FOR ALL ENTRIES IN it_ekpo_eina
          WHERE infnr = it_ekpo_eina-infnr
          AND ekorg = 'FAC'
          AND esokz = '0'.
      ENDIF.
    ENDIF.

    IF it_eina_eine[] IS NOT INITIAL.
      SELECT eina~lifnr INTO TABLE @DATA(it_eina) FROM eina
        FOR ALL ENTRIES IN @it_eina_eine
        WHERE infnr = @it_eina_eine-infnr.

      fwa_poheader-vendor = it_eina[ 1 ]-lifnr.
    ENDIF.


  ENDIF.
ENDFORM.                    " F_PO_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_GET_COMPANY_CODE
*&---------------------------------------------------------------------*
FORM f_get_company_code  USING    fu_plant
                         CHANGING fu_bukrs.
  SELECT SINGLE bukrs
    FROM t001k
    INTO fu_bukrs
    WHERE bwkey EQ fu_plant.
ENDFORM.                    " F_GET_COMPANY_CODE

*&---------------------------------------------------------------------*
*&      Form  F_PO_CREATE
*&---------------------------------------------------------------------*
FORM f_po_create  TABLES   ft_poitem STRUCTURE bapimepoitem
                           ft_poschedule STRUCTURE bapimeposchedule
                           ft_return STRUCTURE bapiret2
                  USING    fwa_poheader STRUCTURE bapimepoheader
                           fwa_poheaderx STRUCTURE bapimepoheaderx
                           fu_ebeln fu_bsart fu_lifnr fu_reswk
                  CHANGING fc_ebeln.

  DATA: lt_poitem      LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
        lt_poitemx     LIKE bapimepoitemx OCCURS 0 WITH HEADER LINE,
        lt_poschedule  LIKE bapimeposchedule OCCURS 0 WITH HEADER LINE,
        lt_poschedulex LIKE bapimeposchedulx OCCURS 0 WITH HEADER LINE.

  DATA: lv_loggr LIKE marc-loggr,
        lv_werks LIKE t001w-werks.

  LOOP AT ft_poitem.
    lt_poitem-po_item      = ft_poitem-po_item.
    lt_poitemx-po_item     = ft_poitem-po_item.
    lt_poitem-delete_ind   = ft_poitem-delete_ind.
    lt_poitemx-delete_ind  = 'X'.
    lt_poitem-material     = ft_poitem-material.
    lt_poitemx-material    = 'X'.
    lt_poitem-plant        = fu_reswk.
    lt_poitemx-plant       = 'X'.
    lt_poitem-trackingno   = fu_ebeln.
    lt_poitemx-trackingno  = 'X'.
    lt_poitem-quantity     = ft_poitem-quantity.
    lt_poitemx-quantity    = 'X'.
    lt_poitem-gr_to_date   = ft_poitem-gr_to_date.
    lt_poitemx-gr_to_date  = 'X'.
    IF fu_lifnr = 'TSB0102' AND
      fu_bsart = 'ZICO'.
      CASE ft_poitem-stge_loc.
        WHEN '1000'.
**          "Change default iss. sloc to 3000 JR RF/TDS/070/V/21
***          lt_poitem-suppl_stloc  = '3002'.
**          lt_poitem-suppl_stloc  = '3000'.
**          "Endof Change RF/TDS/070/V/21.
**          lt_poitemx-suppl_stloc = 'X'.
**          lt_poitem-stge_loc     = '2004'.
**          lt_poitemx-stge_loc    = 'X'.

          "RF/TDS/25/653..17.01.2025
          lv_werks = fwa_poheader-vendor+3(4).
          SELECT SINGLE loggr FROM marc
            INTO lv_loggr
            WHERE matnr = ft_poitem-material
              AND werks = lv_werks.
          IF sy-subrc = 0 AND lv_loggr = 'WH02'.
            lt_poitem-suppl_stloc  = '3010'.
          ELSE.
            lt_poitem-suppl_stloc  = '3000'.
          ENDIF.

          lt_poitemx-suppl_stloc = 'X'.
          lt_poitem-stge_loc     = '2009'.
          lt_poitemx-stge_loc    = 'X'.
          "Endof RF/TDS/25/653
        WHEN '1001'.
          "Change default iss. sloc to 3000 JR RF/TDS/070/V/21
*          lt_poitem-suppl_stloc  = '3005'.
          lv_werks = fwa_poheader-vendor+3(4).
          SELECT SINGLE loggr FROM marc
            INTO lv_loggr
            WHERE matnr = ft_poitem-material
              AND werks = lv_werks.
          IF sy-subrc = 0 AND lv_loggr = 'WH02'.
            lt_poitem-suppl_stloc  = '3010'.
          ELSE.
            lt_poitem-suppl_stloc  = '3000'.
          ENDIF.
          "Endof Change RF/TDS/070/V/21.
          lt_poitemx-suppl_stloc = 'X'.
          lt_poitem-stge_loc     = '2005'.
          lt_poitemx-stge_loc    = 'X'.
        WHEN '1003'.
          lv_werks = fwa_poheader-vendor+3(4).
          SELECT SINGLE loggr FROM marc
            INTO lv_loggr
            WHERE matnr = ft_poitem-material
              AND werks = lv_werks.
          IF sy-subrc = 0 AND lv_loggr = 'WH02'.
            lt_poitem-suppl_stloc  = '3010'.
            lt_poitemx-suppl_stloc = 'X'.
            lt_poitem-stge_loc     = '2004'.
            lt_poitemx-stge_loc    = 'X'.
          ELSE.
            "Change default iss. sloc to 3000 JR RF/TDS/070/V/21
*            lt_poitem-suppl_stloc  = '3002'.
            lt_poitem-suppl_stloc  = '3000'.
            "Endof Change RF/TDS/070/V/21.
            lt_poitemx-suppl_stloc = 'X'.
            lt_poitem-stge_loc     = '2004'.
            lt_poitemx-stge_loc    = 'X'.
          ENDIF.
        WHEN '1008'.
          "Change default iss. sloc to 3000 JR RF/TDS/070/V/21
*          lt_poitem-suppl_stloc  = '3008'.
          lv_werks = fwa_poheader-vendor+3(4).
          SELECT SINGLE loggr FROM marc
            INTO lv_loggr
            WHERE matnr = ft_poitem-material
              AND werks = lv_werks.
          IF sy-subrc = 0 AND lv_loggr = 'WH02'.
            lt_poitem-suppl_stloc  = '3010'.
          ELSE.
            lt_poitem-suppl_stloc  = '3000'.
          ENDIF.
          "Endof Change RF/TDS/070/V/21.
          lt_poitemx-suppl_stloc = 'X'.
          lt_poitem-stge_loc     = '2008'.
          lt_poitemx-stge_loc    = 'X'.
        WHEN OTHERS.
          lt_poitem-suppl_stloc  = pa_reslo.
          lt_poitemx-suppl_stloc = 'X'.
          lt_poitem-stge_loc     = pa_lgort.
          lt_poitemx-stge_loc    = 'X'.
      ENDCASE.
    ELSE.
      lt_poitem-suppl_stloc  = pa_reslo.
      lt_poitemx-suppl_stloc = 'X'.
      lt_poitem-stge_loc     = pa_lgort.
      lt_poitemx-stge_loc    = 'X'.
    ENDIF.
    APPEND lt_poitem.
    APPEND lt_poitemx.
  ENDLOOP.

  LOOP AT ft_poschedule.
    lt_poschedule-po_item         = ft_poschedule-po_item.
    lt_poschedulex-po_item        = ft_poschedule-po_item.
    lt_poschedule-delivery_date   = ft_poschedule-delivery_date.
    lt_poschedulex-delivery_date  = 'X'.
    APPEND lt_poschedule.
    APPEND lt_poschedulex.
  ENDLOOP.

  SELECT SINGLE werks
    FROM lfa1
    INTO fwa_poheader-suppl_plnt
    WHERE lifnr = fwa_poheader-vendor.
  IF fwa_poheader-suppl_plnt IS NOT INITIAL.
    fwa_poheaderx-suppl_plnt  = 'X'.
  ENDIF.

  CALL FUNCTION 'BAPI_PO_CREATE1'
    EXPORTING
      poheader         = fwa_poheader
      poheaderx        = fwa_poheaderx
    IMPORTING
      exppurchaseorder = fc_ebeln
    TABLES
      return           = ft_return
      poitem           = lt_poitem
      poitemx          = lt_poitemx
      poschedule       = lt_poschedule
      poschedulex      = lt_poschedulex.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.
ENDFORM.                    " F_PO_CREATE

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_TEXT
*&---------------------------------------------------------------------*
FORM f_header_text  TABLES   ft_poitem STRUCTURE bapimepoitem
                    USING    fu_ebeln1 fu_ebeln2.
  DATA: text_lines LIKE ibiptextln OCCURS 0 WITH HEADER LINE,
        lt_return  LIKE  bapiret2 OCCURS 0 WITH HEADER LINE,
        lt_poitem  LIKE  bapimepoitem OCCURS 0 WITH HEADER LINE,
        lt_poitemx LIKE  bapimepoitemx OCCURS 0 WITH HEADER LINE.

  text_lines-tdobject   = 'EKKO'.
  text_lines-tdname     = fu_ebeln1.
  text_lines-tdid       = 'F01'.
  text_lines-tdspras    = sy-langu.
  text_lines-tdline     = fu_ebeln2.
  APPEND text_lines.

  CALL FUNCTION 'RFC_SAVE_TEXT'
    TABLES
      text_lines = text_lines.

  CLEAR: text_lines[], text_lines.

  text_lines-tdobject   = 'EKKO'.
  text_lines-tdname     = fu_ebeln2.
  text_lines-tdid       = 'F01'.
  text_lines-tdspras    = sy-langu.
  text_lines-tdline     = fu_ebeln1.
  APPEND text_lines.

  CALL FUNCTION 'RFC_SAVE_TEXT'
    TABLES
      text_lines = text_lines.

  LOOP AT ft_poitem.
    lt_poitem-po_item      = ft_poitem-po_item.
    lt_poitemx-po_item     = ft_poitem-po_item.
    lt_poitem-trackingno   = fu_ebeln2.
    lt_poitemx-trackingno  = 'X'.
    APPEND lt_poitem.
    APPEND lt_poitemx.
  ENDLOOP.

  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      purchaseorder = fu_ebeln1
    TABLES
      return        = lt_return
      poitem        = lt_poitem
      poitemx       = lt_poitemx.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.
  SELECT SINGLE * FROM ekko WHERE ebeln EQ fu_ebeln2 AND bsart = 'ZSUB'.
  IF sy-subrc EQ 0.
    UPDATE ekpo SET pstyp = 3
                WHERE ebeln EQ fu_ebeln2.
  ENDIF.
ENDFORM.                    " F_HEADER_TEXT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_0500  OUTPUT
*&---------------------------------------------------------------------*
MODULE list_processing_0500 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_error_log.
ENDMODULE.                 " LIST_PROCESSING_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LOG
*&---------------------------------------------------------------------*
FORM f_error_log .
  DATA: lv_zebra  TYPE i.

  WRITE: / sy-uline(121).
  FORMAT COLOR 1.
  WRITE: / sy-vline, (20) 'Document',
           sy-vline, (94) 'Message',
           sy-vline.
  WRITE: / sy-uline(121).
  FORMAT COLOR OFF.
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
    WRITE: / sy-vline, (20) gt_error-ebeln,
             sy-vline, (94) gt_error-msg,
             sy-vline.
  ENDLOOP.
  WRITE: / sy-uline(121).
ENDFORM.                    " F_ERROR_LOG

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_mod_screen USING : 'PO1', 'PO2', 'CHK', 'SVS',
                                   'EKO', 'SEI', 'PDE', 'REQ'.

    WHEN radio2.
      PERFORM f_mod_screen USING : 'LGO', 'PO1', 'PO2', 'CHK', 'BSA',
                                   'SVS', 'EKO', 'SEI', 'PDE', 'RES',
                                   'REQ'.

    WHEN radio3.
      PERFORM f_mod_screen USING : 'LGO', 'WER', 'EBE', 'PO1', 'RES'.

    WHEN radio4 OR radio5.
      PERFORM f_mod_screen USING : 'LGO', 'BUK', 'WER',
                                   'EBE', 'BED', 'PO2', 'CHK', 'BSA',
                                   'SVS', 'EKO', 'SEI', 'PDE', 'RES',
                                   'REQ'.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  CASE 'X'.
    WHEN radio1.
      IF pa_bukrs IS INITIAL.
        PERFORM f_error_selection_screen USING 'BUK' '0'.
      ENDIF.
      IF pa_lgort IS INITIAL.
        PERFORM f_error_selection_screen USING 'LGO' '0'.
      ENDIF.
      IF pa_reslo IS INITIAL.
        PERFORM f_error_selection_screen USING 'RES' '0'.
      ENDIF.
      IF pa_bsart IS INITIAL.
        PERFORM f_error_selection_screen USING 'BSA' '0'.
      ENDIF.

    WHEN radio2.
      IF pa_bukrs IS INITIAL.
        PERFORM f_error_selection_screen USING 'BUK' '0'.
      ENDIF.

    WHEN radio3.
      IF pa_bukrs IS INITIAL.
        PERFORM f_error_selection_screen USING 'BUK' '0'.
      ENDIF.
      IF pa_ekorg IS INITIAL.
        PERFORM f_error_selection_screen USING 'EKO' '0'.
      ENDIF.
      IF so_bedat[] IS INITIAL.
        PERFORM f_error_selection_screen USING 'BED' '0'.
      ENDIF.

    WHEN radio4 OR radio5.
      IF so_pon1[] IS INITIAL.
        PERFORM f_error_selection_screen USING 'PO1' '0'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
    WHEN '1'.
      lv_mess = 'Error in Posting date'.
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
*&      Form  F_CHANGE_STATUS
*&---------------------------------------------------------------------*
FORM f_change_status .
  DATA: lt_out   LIKE gt_out OCCURS 0 WITH HEADER LINE,
        lt_zmpo  TYPE STANDARD TABLE OF zmpo INITIAL SIZE 0,
        ls_zmpo  LIKE LINE OF lt_zmpo,
        lt_xzmpo TYPE STANDARD TABLE OF zmpo INITIAL SIZE 0,
        ls_xzmpo LIKE LINE OF lt_xzmpo.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check NE 'X'.
  LOOP AT lt_out.
    MOVE-CORRESPONDING lt_out TO ls_zmpo.
    APPEND ls_zmpo TO lt_zmpo.

    IF pa_delco IS INITIAL.
      IF pa_reqty IS NOT INITIAL.
        PERFORM f_bapi_po_restore USING lt_out-ebeln lt_out-ebelp lt_out-wamng.
        PERFORM f_bapi_po_delcomp USING lt_out-ebeln lt_out-ebelp.
      ELSE.
*      PERFORM f_bapi_po_change USING lt_out-ebeln lt_out-ebelp lt_out-menge.
        PERFORM f_bapi_po_change_new USING lt_out-ebeln lt_out-ebelp lt_out-menge.
      ENDIF.
    ELSE.
      UPDATE ekpo   SET elikz = 'X'
                  WHERE ebeln EQ lt_out-ebeln
                    AND ebelp EQ lt_out-ebelp.
    ENDIF.
  ENDLOOP.

  IF lt_zmpo[] IS NOT INITIAL.
    SELECT *
      FROM zmpo
      INTO CORRESPONDING FIELDS OF TABLE lt_xzmpo
      FOR ALL ENTRIES IN lt_zmpo
      WHERE ebeln = lt_zmpo-ebeln
        AND ebelp = lt_zmpo-ebelp.

    SORT lt_zmpo  BY ebeln ebelp.
    SORT lt_xzmpo BY ebeln ebelp.
    CLEAR ls_zmpo.
    LOOP AT lt_zmpo INTO ls_zmpo.
      READ TABLE lt_xzmpo INTO ls_xzmpo
                          WITH KEY ebeln = ls_zmpo-ebeln
                                   ebelp = ls_zmpo-ebelp
                          BINARY SEARCH.
      IF sy-subrc = 0.
        UPDATE zmpo SET wamng = ls_zmpo-wamng
                    WHERE ebeln = ls_zmpo-ebeln
                      AND ebelp = ls_zmpo-ebelp.
      ELSE.
        INSERT zmpo FROM ls_zmpo.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_CHANGE_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_MOD_SCREEN
*&---------------------------------------------------------------------*
FORM f_mod_screen  USING    fu_modif.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN fu_modif.
        screen-active  = 0.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.                    " F_MOD_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_QTY
*&---------------------------------------------------------------------*
FORM f_change_qty .
  DATA : lt_out     LIKE gt_out OCCURS 0 WITH HEADER LINE,
         lt_poitem  LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
         lt_return  LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
         lt_poitemx LIKE bapimepoitemx OCCURS 0 WITH HEADER LINE.

  DATA : lv_ebeln1    TYPE ebeln,
         lv_ebeln2    TYPE ebeln,
         lwa_poheader LIKE bapimepoheader.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check NE 'X'.
  READ TABLE lt_out INDEX 1.
  lv_ebeln1 = lt_out-ebeln.

*  PERFORM f_read_text USING lv_ebeln1
*                      CHANGING lv_ebeln2.
*
*  lt_out-ebeln = lv_ebeln2.
*  APPEND lt_out.

  LOOP AT lt_out.
    CLEAR : lwa_poheader, lt_return, lt_return[],
            lt_poitem, lt_poitem[], lt_poitemx, lt_poitemx[].

    CHECK gv_status IS INITIAL.

    CALL FUNCTION 'BAPI_PO_GETDETAIL1'
      EXPORTING
        purchaseorder = lt_out-ebeln
      IMPORTING
        poheader      = lwa_poheader
      TABLES
        return        = lt_return
        poitem        = lt_poitem.

    UPDATE ekpo   SET pstyp = 0
                WHERE ebeln EQ lt_out-ebeln.

    LOOP AT lt_poitem.
      READ TABLE gt_out WITH KEY ebelp = lt_poitem-po_item
                                 matnr = lt_poitem-material.
      IF sy-subrc EQ 0.
        lt_poitem-quantity  = gt_out-menge.
        MODIFY lt_poitem TRANSPORTING quantity.
        lt_poitemx-po_item   = lt_poitem-po_item.
        lt_poitemx-quantity  = 'X'.
        APPEND lt_poitemx.
      ENDIF.
    ENDLOOP.

    CLEAR : lt_return, lt_return[].

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        purchaseorder = lt_out-ebeln
      TABLES
        return        = lt_return
        poitem        = lt_poitem
        poitemx       = lt_poitemx.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    READ TABLE lt_return WITH KEY type = 'E'.
    IF sy-subrc EQ 0.
      gv_status = 1.
      LOOP AT lt_return WHERE type EQ 'E'.
        gt_error-type   = lt_return-type.
        gt_error-ebeln  = lt_out-ebeln.
        gt_error-msg    = lt_return-message.
        APPEND gt_error.
      ENDLOOP.
    ENDIF.

    UPDATE ekpo   SET pstyp = 3
              WHERE ebeln EQ lt_out-ebeln.

    CLEAR lt_out.
  ENDLOOP.
ENDFORM.                    " F_CHANGE_QTY

*&---------------------------------------------------------------------*
*&      Form  F_READ_TEXT
*&---------------------------------------------------------------------*
FORM f_read_text  USING    fu_ebeln
                  CHANGING fc_ebeln.
  DATA : lv_name  TYPE tdobname,
         lt_lines LIKE tline OCCURS 0 WITH HEADER LINE.

  lv_name = fu_ebeln.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'F01'
      language                = sy-langu
      name                    = lv_name
      object                  = 'EKKO'
    TABLES
      lines                   = lt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  READ TABLE lt_lines INDEX 1.
  fc_ebeln  = lt_lines-tdline.
ENDFORM.                    " F_READ_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DELIV_DATE
*&---------------------------------------------------------------------*
FORM f_change_deliv_date .
  DATA: lt_out         LIKE gt_out OCCURS 0 WITH HEADER LINE.

  lt_out[]  = gt_out[].
  DELETE lt_out WHERE check NE 'X'.
  LOOP AT lt_out.
    UPDATE eket   SET eindt = lt_out-eindt
                WHERE ebeln EQ lt_out-ebeln
                  AND ebelp EQ lt_out-ebelp.
  ENDLOOP.

ENDFORM.                    " F_CHANGE_DELIV_DATE

*&---------------------------------------------------------------------*
*&      Form  F_BACKGROUND_PROCESS
*&---------------------------------------------------------------------*
FORM f_background_process .
  DATA: lt_out   LIKE gt_out OCCURS 0 WITH HEADER LINE,
        lt_zmpo  TYPE STANDARD TABLE OF zmpo INITIAL SIZE 0,
        ls_zmpo  LIKE LINE OF lt_zmpo,
        lt_xzmpo TYPE STANDARD TABLE OF zmpo INITIAL SIZE 0,
        ls_xzmpo LIKE LINE OF lt_zmpo.

  lt_out[]  = gt_out[].
  LOOP AT lt_out.
    MOVE-CORRESPONDING lt_out TO ls_zmpo.
    APPEND ls_zmpo TO lt_zmpo.
    IF pa_delco IS INITIAL.
      IF pa_reqty IS NOT INITIAL.
        PERFORM f_bapi_po_restore USING lt_out-ebeln lt_out-ebelp lt_out-wamng.
        PERFORM f_bapi_po_delcomp USING lt_out-ebeln lt_out-ebelp.
      ELSE.
*      PERFORM f_bapi_po_change USING lt_out-ebeln lt_out-ebelp lt_out-menge.
        PERFORM f_bapi_po_change_new USING lt_out-ebeln lt_out-ebelp lt_out-menge.
      ENDIF.
    ELSE.
      UPDATE ekpo   SET elikz = 'X'
                  WHERE ebeln EQ lt_out-ebeln
                    AND ebelp EQ lt_out-ebelp.
    ENDIF.
  ENDLOOP.

  IF lt_zmpo[] IS NOT INITIAL.
    SELECT *
      FROM zmpo
      INTO CORRESPONDING FIELDS OF TABLE lt_xzmpo
      FOR ALL ENTRIES IN lt_zmpo
      WHERE ebeln = lt_zmpo-ebeln
        AND ebelp = lt_zmpo-ebelp.

    SORT lt_zmpo  BY ebeln ebelp.
    SORT lt_xzmpo BY ebeln ebelp.
    CLEAR ls_zmpo.
    LOOP AT lt_zmpo INTO ls_zmpo.
      READ TABLE lt_xzmpo INTO ls_xzmpo
                          WITH KEY ebeln = ls_zmpo-ebeln
                                   ebelp = ls_zmpo-ebelp
                          BINARY SEARCH.
      IF sy-subrc = 0.
        UPDATE zmpo SET wamng = ls_zmpo-wamng
                    WHERE ebeln = ls_zmpo-ebeln
                      AND ebelp = ls_zmpo-ebelp.
      ELSE.
        INSERT zmpo FROM ls_zmpo.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_BACKGROUND_PROCESS

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_PO_CHANGE
*&---------------------------------------------------------------------*
FORM f_bapi_po_change  USING    fu_ebeln fu_ebelp fu_menge.
  DATA : return  LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
         poitem  LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
         poitemx LIKE bapimepoitemx OCCURS 0 WITH HEADER LINE.

  READ TABLE gt_seket WITH KEY ebeln = fu_ebeln
                               ebelp = fu_ebelp.
  IF sy-subrc = 0.
    IF gt_seket-glmng = 0.
*      UPDATE ekpo   SET elikz = 'X'
*                  WHERE ebeln EQ fu_ebeln
*                    AND ebelp EQ fu_ebelp.
      poitem-po_item      = fu_ebelp.
      poitem-no_more_gr   = 'X'.
      APPEND poitem.
      poitemx-po_item     = fu_ebelp.
      poitemx-no_more_gr  = 'X'.
      APPEND poitemx.

      CALL FUNCTION 'BAPI_PO_CHANGE'
        EXPORTING
          purchaseorder = fu_ebeln
        TABLES
          return        = return
          poitem        = poitem
          poitemx       = poitemx.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ELSE.
      IF fu_menge <> gt_seket-glmng.
        poitem-po_item    = fu_ebelp.
        poitem-quantity   = gt_seket-glmng.
        APPEND poitem.
        poitemx-po_item   = fu_ebelp.
        poitemx-quantity  = 'X'.
        APPEND poitemx.

        CALL FUNCTION 'BAPI_PO_CHANGE'
          EXPORTING
            purchaseorder = fu_ebeln
          TABLES
            return        = return
            poitem        = poitem
            poitemx       = poitemx.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        UPDATE eket SET mng02 = fu_menge
                    WHERE ebeln = fu_ebeln
                      AND ebelp = fu_ebelp.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_BAPI_PO_CHANGE

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_PO_CHANGE_NEW
*&---------------------------------------------------------------------*
FORM f_bapi_po_change_new  USING    fu_ebeln fu_ebelp fu_menge.
  DATA : return  LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
         poitem  LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
         poitemx LIKE bapimepoitemx OCCURS 0 WITH HEADER LINE.

  poitem-po_item      = fu_ebelp.
  poitem-no_more_gr   = 'X'.
  APPEND poitem.
  poitemx-po_item     = fu_ebelp.
  poitemx-no_more_gr  = 'X'.
  APPEND poitemx.

  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      purchaseorder = fu_ebeln
    TABLES
      return        = return
      poitem        = poitem
      poitemx       = poitemx.

  READ TABLE return WITH KEY type = 'E'.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    CLEAR: poitem, poitem[], poitemx, poitemx[], return, return[].
    REFRESH: poitem, poitem[], poitemx, poitemx[], return, return[].

    READ TABLE gt_seket WITH KEY ebeln = fu_ebeln
                                 ebelp = fu_ebelp.
    IF sy-subrc = 0.
      IF fu_menge <> gt_seket-glmng.
        poitem-po_item    = fu_ebelp.
        poitem-quantity   = gt_seket-glmng.
        APPEND poitem.
        poitemx-po_item   = fu_ebelp.
        poitemx-quantity  = 'X'.
        APPEND poitemx.

        CALL FUNCTION 'BAPI_PO_CHANGE'
          EXPORTING
            purchaseorder = fu_ebeln
          TABLES
            return        = return
            poitem        = poitem
            poitemx       = poitemx.

        READ TABLE return WITH KEY type = 'E'.
        IF sy-subrc NE 0.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

          UPDATE eket SET mng02 = fu_menge
                      WHERE ebeln = fu_ebeln
                        AND ebelp = fu_ebelp.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.
ENDFORM.                    " F_BAPI_PO_CHANGE_NEW

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_PO_RESTORE
*&---------------------------------------------------------------------*
FORM f_bapi_po_restore  USING    fu_ebeln fu_ebelp fu_menge.
  DATA : return  LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
         poitem  LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
         poitemx LIKE bapimepoitemx OCCURS 0 WITH HEADER LINE.

  CLEAR: poitem, poitem[], poitemx, poitemx[], return, return[].

*  READ TABLE gt_seket WITH KEY ebeln = fu_ebeln
*                               ebelp = fu_ebelp.
*  IF sy-subrc = 0.
  poitem-po_item    = fu_ebelp.
  poitem-quantity   = fu_menge.
  APPEND poitem.
  poitemx-po_item   = fu_ebelp.
  poitemx-quantity  = 'X'.
  APPEND poitemx.

  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      purchaseorder = fu_ebeln
    TABLES
      return        = return
      poitem        = poitem
      poitemx       = poitemx.

  READ TABLE return WITH KEY type = 'E'.
  IF sy-subrc NE 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.
*  ENDIF.
ENDFORM.                    " F_BAPI_PO_RESTORE

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_PO_DELCOMP
*&---------------------------------------------------------------------*
FORM f_bapi_po_delcomp  USING    fu_ebeln fu_ebelp.
  DATA : return  LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
         poitem  LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
         poitemx LIKE bapimepoitemx OCCURS 0 WITH HEADER LINE.

  CLEAR: poitem, poitem[], poitemx, poitemx[], return, return[].

  poitem-po_item      = fu_ebelp.
  poitem-no_more_gr   = 'X'.
  APPEND poitem.
  poitemx-po_item     = fu_ebelp.
  poitemx-no_more_gr  = 'X'.
  APPEND poitemx.

  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      purchaseorder = fu_ebeln
    TABLES
      return        = return
      poitem        = poitem
      poitemx       = poitemx.

  READ TABLE return WITH KEY type = 'E'.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    UPDATE ekpo   SET elikz = 'X'
                WHERE ebeln EQ fu_ebeln
                  AND ebelp EQ fu_ebelp.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.
ENDFORM.                    " F_BAPI_PO_DELCOMP
