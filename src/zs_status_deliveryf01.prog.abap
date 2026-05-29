*----------------------------------------------------------------------*
*   INCLUDE ZS_STATUS_DELIVERYF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  SELECT *
    FROM zmshphistr
    INTO CORRESPONDING FIELDS OF TABLE gt_zsdnstat.

  CASE 'X'.
    WHEN pa_std.

    WHEN pa_ext OR pa_conv.
      SELECT *
        FROM zsextrecreas
        INTO CORRESPONDING FIELDS OF TABLE gt_zsextrecreas.
  ENDCASE.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA : lt_vttp LIKE gt_vttp OCCURS 0 WITH HEADER LINE,
         lt_likp LIKE gt_likp OCCURS 0 WITH HEADER LINE.

  CASE 'X'.
    WHEN pa_std.
      SELECT tknum add04 sttrg
        FROM vttk
        INTO CORRESPONDING FIELDS OF TABLE gt_vttk
        WHERE tknum IN so_tknum.

      CHECK gt_vttk[] IS NOT INITIAL.

      SELECT tknum tpnum vbeln erdat
        FROM vttp
        INTO TABLE gt_vttp
        FOR ALL ENTRIES IN gt_vttk
        WHERE tknum EQ gt_vttk-tknum.

      CHECK gt_vttp[] IS NOT INITIAL.

      SELECT vbss~sammg vbeln
        FROM vbss JOIN vbsk ON vbss~sammg = vbsk~sammg
        INTO TABLE gt_vbss
        FOR ALL ENTRIES IN gt_vttp
        WHERE vbeln EQ gt_vttp-vbeln
          AND smart EQ 'C'.

      SELECT vbeln tpgrp wadat_ist
        FROM likp
        INTO CORRESPONDING FIELDS OF TABLE gt_likp
        FOR ALL ENTRIES IN gt_vttp
        WHERE vbeln EQ gt_vttp-vbeln
          AND vstel EQ pa_vstel.

      SELECT vbeln crdat crtim predat pretim
        FROM zmm_cust_rec
        INTO TABLE gt_cust
        FOR ALL ENTRIES IN gt_vttp
        WHERE vbeln EQ gt_vttp-vbeln.

    WHEN pa_ext.
      SELECT tknum tpnum vbeln erdat
        FROM vttp
        INTO TABLE gt_vttp
        WHERE vbeln IN so_vbeln.

      lt_vttp[] = gt_vttp[].
      SORT lt_vttp BY vbeln.
      IF lt_vttp[] IS NOT INITIAL.
        SELECT vbeln crdat crtim predat pretim
          FROM zmm_cust_rec
          INTO TABLE gt_cust
          FOR ALL ENTRIES IN lt_vttp
          WHERE vbeln EQ lt_vttp-vbeln.

        SELECT *
          FROM zsextrec
          INTO CORRESPONDING FIELDS OF TABLE gt_zsextrec
          FOR ALL ENTRIES IN lt_vttp
          WHERE vbeln = lt_vttp-vbeln.

        SELECT tknum add04
          FROM vttk
          INTO CORRESPONDING FIELDS OF TABLE gt_vttk
          FOR ALL ENTRIES IN lt_vttp
          WHERE tknum = lt_vttp-tknum.

        SELECT vbeln vstel kunnr wadat_ist
          FROM likp
          INTO CORRESPONDING FIELDS OF TABLE gt_likp
          FOR ALL ENTRIES IN lt_vttp
          WHERE vbeln = lt_vttp-vbeln
            AND vstel = pa_vstel.

        lt_likp[] = gt_likp[].
        SORT lt_likp BY kunnr.
        DELETE ADJACENT DUPLICATES FROM lt_likp COMPARING kunnr.

        IF lt_likp[] IS NOT INITIAL.
          SELECT kunnr name1
            FROM kna1
            INTO TABLE gt_kna1
            FOR ALL ENTRIES IN lt_likp
            WHERE kunnr = lt_likp-kunnr.
        ENDIF.
      ENDIF.

    WHEN pa_conv.
      SELECT *
        FROM zsextrec
        INTO CORRESPONDING FIELDS OF TABLE gt_zsextrec
        WHERE vbeln IN so_vbeln.

      IF sy-subrc = 0.
        SELECT tknum tpnum vbeln erdat
          FROM vttp
          INTO CORRESPONDING FIELDS OF TABLE gt_vttp
          FOR ALL ENTRIES IN gt_zsextrec
          WHERE vbeln = gt_zsextrec-vbeln.

        SELECT vbeln vstel kunnr wadat_ist
          FROM likp
          INTO CORRESPONDING FIELDS OF TABLE gt_likp
          FOR ALL ENTRIES IN gt_vttp
          WHERE vbeln = gt_vttp-vbeln
            AND vstel = pa_vstel.

        lt_likp[] = gt_likp[].
        SORT lt_likp BY kunnr.
        DELETE ADJACENT DUPLICATES FROM lt_likp COMPARING kunnr.

        IF lt_likp[] IS NOT INITIAL.
          SELECT kunnr name1
            FROM kna1
            INTO TABLE gt_kna1
            FOR ALL ENTRIES IN lt_likp
            WHERE kunnr = lt_likp-kunnr.
        ENDIF.

      ELSE.
        MESSAGE 'No Data' TYPE 'I' DISPLAY LIKE 'E'.
        STOP.
      ENDIF.
  ENDCASE.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  CASE 'X'.
    WHEN pa_std.
      PERFORM f_alv TABLES gt_out.
    WHEN pa_ext OR pa_conv.
      gt_xout[] = gt_out[].
      CALL SCREEN 100.
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
    WHEN pa_std.
      PERFORM f_fieldcatg USING ft_report:
        'ICON' '' '' '' '4' 'Sts.' '' '' '' '' '' '' '' '' '' '',
        'TKNUM' 'VTTK' 'TKNUM' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VBELN' 'VTTP' 'VBELN' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
        'SAMMG' 'VBSS' 'SAMMG' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZSTAT' 'ZSDNSTAT' 'ZSTAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZDESC' 'ZSDNSTAT' 'ZDESC' '' '' '' '' '' '' '' '' '' '' '' '' '',
*    'CRDAT' 'ZMM_CUST_REC' 'CRDAT' '' '' 'Conf. Date' '' '' '' '' '' ''
*    '' '' '' '',
*    'CRTIM' 'ZMM_CUST_REC' 'CRTIM' '' '' '' '' '' '' '' '' '' '' '' ''
*    '',
        'PREDAT' 'ZMM_CUST_REC' 'PREDAT' '' '' '' '' '' '' '' '' ''
        '' '' '' '',
        'PRETIM' 'ZMM_CUST_REC' 'PRETIM' '' '' '' '' '' '' '' '' '' '' '' ''
        '',
        'DELVGRP' '' '' '' '8' 'Delv.Grp' '' '' '' '' '' '' '' 'X' '' ''.

    WHEN pa_ext OR pa_conv.
      PERFORM f_fieldcatg USING ft_report:
        'ICON' '' '' '' '4' 'Sts.' '' '' '' '' '' '' '' '' '' '',
        'VBELN' 'VTTP' 'VBELN' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'KNA1' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NAME1' 'KNA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'TKNUM' 'VTTK' 'TKNUM' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'CRDAT' 'ZSEXTREC' 'CRDAT' '' '12' 'Receipt Date' '' '' '' ''
        '' '' '' '' 'X' '',
        'CRTIM' 'ZSEXTREC' 'CRTIM' '' '12' 'Receipt Time' '' '' '' ''
        '' '' '' '' 'X' ''.
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
  ld_sort-fieldname = 'SORTF'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
  CLEAR ld_sort.
  ld_sort-fieldname = 'VBELN'.
  ld_sort-up        = 'X'.
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
    WHEN pa_std.
      SET PF-STATUS 'TOEXECUTE'.
    WHEN pa_ext OR pa_conv.
      SET PF-STATUS 'TOEXECUTE' EXCLUDING '&CHG'.
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
  DATA : lv_sortf  TYPE numc4.

  CASE 'X'.
    WHEN pa_std.
      LOOP AT gt_vttk.
        IF gt_vttk-sttrg < 6.
          gv_subrc = 4.
          MESSAGE s000(zab) WITH 'Ada status shipment yang belum shipment start'
                            DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.
      ENDLOOP.

      CHECK gv_subrc IS INITIAL.

      CLEAR gt_dn.
      IF pa_mds IS INITIAL.
        DO 1000 TIMES.
          ADD 1 TO gt_dn-sortf.
          APPEND gt_dn.
        ENDDO.
        CALL SCREEN 500 STARTING AT 10 10.
      ELSE.
        LOOP AT gt_vttp.
          ADD 1 TO gt_dn-sortf.
          gt_dn-vbeln = gt_vttp-vbeln.
          APPEND gt_dn.
        ENDLOOP.
        save_ok = '&POS'.
      ENDIF.

      IF save_ok = '&POS'.

        CHECK gt_dn[] IS NOT INITIAL.

        PERFORM f_get_shphist.

        SORT gt_vttp BY tknum vbeln.
        SORT gt_vbss BY vbeln.
        SORT gt_likp BY vbeln.
        SORT gt_cust BY vbeln.
        SORT gt_dn BY vbeln.
        SORT gt_zmshphist BY tknum vbeln zcount DESCENDING.

        LOOP AT gt_vttp.
          gt_out-tknum  = gt_vttp-tknum.
          gt_out-vbeln  = gt_vttp-vbeln.

          READ TABLE gt_likp WITH KEY vbeln = gt_vttp-vbeln.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          READ TABLE gt_vbss WITH KEY vbeln = gt_vttp-vbeln.
          IF sy-subrc = 0.
            gt_out-sammg    = gt_vbss-sammg.
            gt_out-check    = 2.
          ENDIF.

*      READ TABLE gt_likp WITH KEY vbeln = gt_vttp-vbeln
*                         BINARY SEARCH.
*      IF sy-subrc = 0.
*        gt_out-zstat  = gt_likp-tpgrp.
*        READ TABLE gt_zsdnstat WITH KEY zstat = gt_likp-tpgrp.
*        IF sy-subrc = 0.
*          gt_out-zdesc  = gt_zsdnstat-zdesc.
*        ENDIF.
*      ENDIF.

          READ TABLE gt_zmshphist WITH KEY tknum = gt_vttp-tknum
                                           vbeln = gt_vttp-vbeln
                                  BINARY SEARCH.
          IF sy-subrc = 0.
            gt_out-zstat  = gt_zmshphist-zreason.
            READ TABLE gt_zmshphistr WITH KEY zreason = gt_zmshphist-zreason.
            IF sy-subrc = 0.
              gt_out-zdesc  = gt_zmshphistr-zreason1.
            ENDIF.
          ENDIF.

          READ TABLE gt_cust WITH KEY vbeln = gt_vttp-vbeln.
          IF sy-subrc = 0.
            gt_out-predat  = gt_cust-predat.
            gt_out-pretim  = gt_cust-pretim.
          ENDIF.

          READ TABLE gt_dn WITH KEY vbeln = gt_vttp-vbeln.
          IF sy-subrc = 0.
            gt_out-delvgrp  = 'X'.
            gt_out-sortf    = gt_dn-sortf.
          ENDIF.

          APPEND gt_out.
          CLEAR gt_out.
        ENDLOOP.

        READ TABLE gt_out WITH KEY delvgrp = 'X'.
        IF sy-subrc <> 0.
          CLEAR gt_out[].
        ENDIF.

      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN pa_ext.
      PERFORM f_get_shphist.

      SORT gt_zmshphist BY vbeln zcount DESCENDING.
      SORT gt_likp BY vbeln.
      SORT gt_vttp BY vbeln.
      LOOP AT gt_likp.
        CLEAR: gt_zmshphist,gt_zmshphistr.
        READ TABLE gt_zmshphist WITH KEY vbeln = gt_likp-vbeln.
        IF sy-subrc = 0 AND gt_zmshphist-zreason NE '99'.
          gt_out-zreason = gt_zmshphist-zreason.
          READ TABLE gt_zmshphistr WITH KEY zreason = gt_out-zreason.
          gt_out-zreason1 = gt_zmshphistr-zreason1.
        ENDIF.
        gt_out-vbeln  = gt_likp-vbeln.
        gt_out-kunnr  = gt_likp-kunnr.
        READ TABLE gt_kna1 WITH KEY kunnr = gt_likp-kunnr.
        IF sy-subrc = 0.
          gt_out-name1  = gt_kna1-name1.
        ENDIF.

        READ TABLE gt_vttp WITH KEY vbeln = gt_likp-vbeln
                           BINARY SEARCH.
        IF sy-subrc = 0.
          gt_out-tknum  = gt_vttp-tknum.
          READ TABLE gt_vttk WITH KEY tknum = gt_vttp-tknum.
          IF sy-subrc = 0.
            IF gt_vttk-add04(3) = 'EXT'.
              CLEAR : gt_out-crdat, gt_out-crtim, gt_out-crexrsdesc.
              READ TABLE gt_zsextrec WITH KEY vbeln = gt_likp-vbeln.
              IF sy-subrc = 0.
*                gt_out-crdat      = gt_zsextrec-crdat.
*                gt_out-crtim      = gt_zsextrec-crtim.
                gt_out-crdat      = gt_zsextrec-crdat_tmp.
                gt_out-crtim      = gt_zsextrec-crtim_tmp.
                gt_out-crexrsdesc = gt_zsextrec-crexdesc.
              ENDIF.
              APPEND gt_out.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

    WHEN pa_conv.
      PERFORM f_get_shphist.

      SORT gt_zsextrec BY vbeln.
      SORT gt_zmshphist BY vbeln zcount DESCENDING.
      SORT gt_likp BY vbeln.
      SORT gt_vttp BY vbeln.

      LOOP AT gt_zsextrec.
        CLEAR: gt_zmshphist,gt_zmshphistr,gt_likp,gt_kna1,gt_vttp.

        READ TABLE gt_vttp WITH KEY vbeln = gt_zsextrec-vbeln
                           BINARY SEARCH.
        READ TABLE gt_likp WITH KEY vbeln = gt_zsextrec-vbeln
                           BINARY SEARCH.
        READ TABLE gt_kna1 WITH KEY kunnr = gt_likp-kunnr.

        gt_out-vbeln      = gt_zsextrec-vbeln.
        gt_out-kunnr      = gt_likp-kunnr.
        gt_out-name1      = gt_kna1-name1.
        gt_out-tknum      = gt_vttp-tknum.
        gt_out-crexrsdesc = gt_zsextrec-crexdesc.

        IF gt_zsextrec-crdat IS INITIAL.
          gt_out-crdat      = gt_zsextrec-crdat_tmp.
          gt_out-crtim      = gt_zsextrec-crtim_tmp.
        ELSE.
          gt_out-crdat      = gt_zsextrec-crdat.
          gt_out-crtim      = gt_zsextrec-crtim.
        ENDIF.

        READ TABLE gt_zmshphist WITH KEY vbeln = gt_zsextrec-vbeln
                                BINARY SEARCH.
        IF sy-subrc = 0 AND gt_zmshphist-zreason NE '99'.
          gt_out-zreason = gt_zmshphist-zreason.
          READ TABLE gt_zmshphistr WITH KEY zreason = gt_out-zreason.
          gt_out-zreason1 = gt_zmshphistr-zreason1.
        ENDIF.

        APPEND gt_out.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread   LIKE dynpread OCCURS 0 WITH HEADER LINE,
        lwa_out       LIKE gt_out,
        ffield(20),
        fvalue(20),
        lv_error(100).

  GET CURSOR FIELD ffield VALUE fvalue.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&IC1'.
      IF ffield EQ 'GT_OUT-VBELN'.
        CLEAR : gv_flag, pa_zstat.
        READ TABLE gt_out INDEX fu_selfield-tabindex INTO lwa_out.
        IF lwa_out-zstat IS NOT INITIAL.
          pa_zstat = lwa_out-zstat.
        ENDIF.
        IF lwa_out-predat IS INITIAL.
          pa_preda  = sy-datum.
        ELSE.
          pa_preda  = lwa_out-predat.
        ENDIF.
        IF lwa_out-pretim IS INITIAL.
          pa_preti  = sy-uzeit.
        ELSE.
          pa_preti  = lwa_out-pretim.
        ENDIF.
        READ TABLE gt_vttk WITH KEY tknum = gt_out-tknum.
        IF gt_vttk-add04(3) = 'EXT'.
          gv_flag = 'X'.
        ENDIF.
        CALL SELECTION-SCREEN 900 STARTING AT 10 10.
        IF sy-subrc EQ 0.
          IF pa_zstat IS NOT INITIAL.
            READ TABLE gt_zsdnstat WITH KEY zreason = pa_zstat.
            IF sy-subrc EQ 0.
              gt_out-icon    = icon_led_green.
              gt_out-zstat   = pa_zstat.
              gt_out-zdesc   = gt_zsdnstat-zreason1.
              gt_out-predat  = pa_preda.
              gt_out-pretim  = pa_preti.
              MODIFY gt_out TRANSPORTING icon zstat zdesc predat pretim
                            WHERE vbeln EQ lwa_out-vbeln.
            ELSE.
              CONCATENATE 'Status DN' pa_zstat 'not found' INTO lv_error
              SEPARATED BY space.
              MESSAGE e000(zab) WITH lv_error.
            ENDIF.
          ELSE.
            gt_out-icon    = icon_led_green.
            CLEAR : gt_out-zstat, gt_out-zdesc.
            gt_out-predat  = pa_preda.
            gt_out-pretim  = pa_preti.
            MODIFY gt_out TRANSPORTING icon zstat zdesc predat pretim
                          WHERE vbeln EQ lwa_out-vbeln.
          ENDIF.
        ENDIF.
        PERFORM f_alv TABLES gt_out.
        LEAVE TO SCREEN 0.
      ENDIF.

    WHEN '&POS'.
      PERFORM f_post_entries.

    WHEN '&CHG'.
      PERFORM f_change_status.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.
  DATA : lt_out   LIKE gt_out OCCURS 0 WITH HEADER LINE,
         lwa_out  LIKE gt_out,
         lv_subrc TYPE sy-subrc,
         ls_vbsk  LIKE vbsk.

  DATA : iv_lgnum        TYPE leint_lgnum VALUE space,
         iv_group_type   TYPE leint_grpty VALUE 'C',
         iv_text         TYPE lxhme_text30,
         iv_cdsto        TYPE leint_cdsto,
         is_release_date TYPE lxhme_rlse_date,
         it_delivery     TYPE STANDARD TABLE OF lxdckm_outdlv_header,
         wa_delivery     LIKE LINE OF it_delivery.

  CLEAR lv_subrc.

  lt_out[] = gt_out[].

  DELETE lt_out WHERE check <> 'X'.

  LOOP AT lt_out INTO lwa_out.
    PERFORM f_update_table USING    lwa_out
                           CHANGING lv_subrc.
    IF lwa_out-delvgrp IS NOT INITIAL.
      IF lwa_out-sammg IS INITIAL.
        wa_delivery-docnr   = lwa_out-vbeln.
        APPEND wa_delivery TO it_delivery.
      ENDIF.
    ELSE.
      IF lwa_out-sammg IS INITIAL.
        lv_subrc = 4.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lv_subrc IS INITIAL.
    IF it_delivery[] IS NOT INITIAL.
      CALL FUNCTION 'ZLEINT_GROUP_CREATE'
        EXPORTING
          iv_lgnum        = iv_lgnum
          iv_group_type   = iv_group_type
          iv_text         = iv_text
          iv_cdsto        = iv_cdsto
          is_release_date = is_release_date
          it_delivery     = it_delivery
        IMPORTING
          es_vbsk         = ls_vbsk.
    ENDIF.

    IF sy-subrc IS INITIAL.
      lv_subrc = sy-subrc.
    ELSE.
      lv_subrc  = 3.
    ENDIF.

    IF lv_subrc IS INITIAL.
      COMMIT WORK AND WAIT.
      PERFORM f_change_sortf TABLES lt_out
                             USING  ls_vbsk-sammg.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

  CASE lv_subrc.
    WHEN 0.
      MESSAGE s000(zab) WITH 'Group' ls_vbsk-sammg 'created'.
      LEAVE TO SCREEN 0.
    WHEN 1.
      MESSAGE e000(zab) WITH 'Error when update DN status'.
    WHEN 2.
      MESSAGE e000(zab) WITH 'Error when update CR Date or CR Time'.
    WHEN 3.
      MESSAGE e000(zab) WITH 'Group creation failed'.
    WHEN 4.
      MESSAGE e000(zab) WITH 'DN not found'.
  ENDCASE.
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
    WHEN pa_std.
      PERFORM f_modify_screen USING : 'SVB' '0' ''.
    WHEN pa_ext OR pa_conv.
      PERFORM f_modify_screen USING : 'STK' '0' '',
                                      'MDS' '0' ''.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA : lv_value   TYPE zscust_control-field_value.

  IF pa_vstel IS INITIAL.
    PERFORM f_screen_error USING 'PVS' ''.
  ENDIF.

  CASE 'X'.
    WHEN pa_std.
      IF so_tknum[] IS INITIAL.
        PERFORM f_screen_error USING 'STK' ''.
      ENDIF.

      lv_value  = pa_vstel.

      SELECT SINGLE *
        INTO gs_cntrl
        FROM zscust_control
        WHERE cek         = 'MDS'
          AND field_name  = 'VSTEL'
          AND field_value = lv_value
          AND datab <= sy-datum.

      IF sy-subrc <> 0.
        IF pa_mds IS NOT INITIAL.
          PERFORM f_screen_error USING 'MDS' ''.
        ENDIF.
      ENDIF.

    WHEN pa_ext OR pa_conv.
      IF so_vbeln[] IS INITIAL.
        PERFORM f_screen_error USING 'SVB' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_TABLE
*&---------------------------------------------------------------------*
FORM f_update_table  USING    fwa_out STRUCTURE gt_out
                     CHANGING fc_subrc.

  DATA : ls_zmshphist TYPE zmshphist. " OCCURS 0 WITH HEADER LINE,
  DATA : lt_zmshphist LIKE zmshphist OCCURS 0 WITH HEADER LINE,
         lv_subrc     TYPE sy-subrc.

*  UPDATE likp   SET tpgrp = fwa_out-zstat
*              WHERE vbeln EQ fwa_out-vbeln.
*
*  IF sy-subrc IS INITIAL.
*    fc_subrc  = sy-subrc.
*  ELSE.
*    fc_subrc  = 1.
*  ENDIF.
*
*  CHECK fc_subrc IS INITIAL.

  CLEAR : lv_subrc.
  IF fwa_out-vbeln IS INITIAL OR fwa_out-tknum IS INITIAL.
    MESSAGE s000(zab) WITH 'No shipment atau No DN tidak ditemukan' DISPLAY LIKE 'E'.
    fc_subrc = 2.
    RETURN.
  ENDIF.

  "Replace, for handling error when insert table
*  SORT gt_zmshphist BY tknum vbeln zcount DESCENDING.
*  READ TABLE gt_zmshphist WITH KEY tknum = fwa_out-tknum
*                                   vbeln = fwa_out-vbeln.
*  IF sy-subrc <> 0.
*    lt_zmshphist-zcount   = 1.
*  ELSE.
*    lt_zmshphist-zcount   = gt_zmshphist-zcount   + 1.
  SELECT MAX( zcount ) INTO @DATA(lv_zcount)
    FROM zmshphist WHERE tknum = @fwa_out-tknum
                     AND vbeln = @fwa_out-vbeln.
  ls_zmshphist-zcount = lv_zcount   + 1.

*  IF gt_zmshphist-zreason = fwa_out-zstat.
  IF fwa_out-zreason = fwa_out-zstat.
    lv_subrc  = 1.
  ENDIF.
*  ENDIF.

  IF lv_subrc IS INITIAL.
    ls_zmshphist-tknum    = fwa_out-tknum.
    ls_zmshphist-vbeln    = fwa_out-vbeln.
    ls_zmshphist-zreason  = fwa_out-zstat.
    ls_zmshphist-zdate    = sy-datum.
    ls_zmshphist-ztime    = sy-uzeit.
    ls_zmshphist-zuser    = sy-uname.
    APPEND ls_zmshphist TO lt_zmshphist.

    IF fwa_out-zstat IS NOT INITIAL.
      SELECT SINGLE tknum, vbeln, zcount INTO CORRESPONDING FIELDS OF @ls_zmshphist
        FROM zmshphist WHERE tknum  = @ls_zmshphist-tknum "@fwa_out-tknum
                         AND vbeln  = @ls_zmshphist-vbeln "@fwa_out-vbeln
                         AND zcount = @ls_zmshphist-zcount.
      IF sy-subrc = 0.
        fc_subrc  = 2.
        MESSAGE s000(zab) WITH 'Duplicate Keys in ZMSHPHIST' DISPLAY LIKE 'E'.
      ELSE.
        INSERT zmshphist FROM  ls_zmshphist.
      ENDIF.
    ENDIF.
  ENDIF.

  IF sy-subrc IS INITIAL.
    UPDATE zmm_cust_rec   SET predat = fwa_out-predat
                              pretim = fwa_out-pretim
                        WHERE vbeln EQ fwa_out-vbeln.

    IF sy-subrc IS INITIAL.
      fc_subrc  = sy-subrc.
    ELSE.
      fc_subrc  = 2.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_UPDATE_TABLE

*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
  SET PF-STATUS 'STATUS_500'.
  DESCRIBE TABLE gt_dn LINES fill.

ENDMODULE.                 " STATUS_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_table_control OUTPUT.
  CASE 'X'.
    WHEN pa_std.
      READ TABLE gt_dn INTO wa_dn INDEX tc_dn-current_line.
    WHEN pa_ext OR pa_conv.
      READ TABLE gt_zsextrec WITH KEY vbeln = gs_out-vbeln.
      IF sy-subrc = 0.
        CLEAR: gv_disable,gv_enable.
        IF gt_zsextrec-crdat IS INITIAL.
          gv_enable = 'X'.
        ELSE.
          gv_disable = 'X'.
        ENDIF.
        PERFORM disable.
      ENDIF.

      READ TABLE gt_out INTO gs_out INDEX tc_out-current_line.
      IF gs_out-crdat IS NOT INITIAL.
        READ TABLE gt_xout WITH KEY vbeln = gs_out-vbeln.
        IF sy-subrc = 0.
          IF gs_out-crdat <> gt_xout-crdat.
            IF gs_out-crdat > sy-datum.
              MESSAGE s000(zab) WITH 'Ext CR Date > system date'
                                DISPLAY LIKE 'E'.
            ELSE.
              READ TABLE gt_likp WITH KEY vbeln = gs_out-vbeln.
              IF sy-subrc = 0.
                IF gs_out-crdat < gt_likp-wadat_ist.
                  MESSAGE s000(zab) WITH 'Ext CR Date < GI Date'
                                    DISPLAY LIKE 'E'.
                ENDIF.
              ENDIF.

              READ TABLE gt_cust WITH KEY vbeln = gs_out-vbeln.
              IF sy-subrc = 0.
                IF gs_out-crdat < gt_cust-crdat.
                  MESSAGE s000(zab) WITH 'Ext CR Date < Int CR date'
                                    DISPLAY LIKE 'E'.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      g_tc_out_lines = sy-loopc.
  ENDCASE.
ENDMODULE.                 " FILL_TABLE_CONTROL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CURSOR  OUTPUT
*&---------------------------------------------------------------------*
MODULE cursor OUTPUT.
  DATA : lv_linno     TYPE sy-linno,
         lv_field(20).

  SET CURSOR FIELD lv_field LINE lv_linno.
ENDMODULE.                 " CURSOR  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
MODULE read_table_control INPUT.
  DATA : ls_zmshphist   LIKE LINE OF gt_zmshphist.

  lines = sy-loopc.
  CASE 'X'.
    WHEN pa_std.
      MODIFY gt_dn FROM wa_dn INDEX tc_dn-current_line.
    WHEN pa_ext OR pa_conv.
      IF gs_out-zreason IS NOT INITIAL.
        READ TABLE gt_zmshphist INTO ls_zmshphist
                                WITH KEY tknum = gs_out-tknum
                                         vbeln = gs_out-vbeln.
        IF sy-subrc <> 0.
          MESSAGE s000(zab) WITH 'Mohon isi reason di status delivery'
                            DISPLAY LIKE 'E'.
        ELSE.
          MODIFY gt_out FROM gs_out INDEX tc_out-current_line.
        ENDIF.
      ELSE.
        MODIFY gt_out FROM gs_out INDEX tc_out-current_line.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " READ_TABLE_CONTROL  INPUT

*&---------------------------------------------------------------------*
*&      Module  CURSOR  INPUT
*&---------------------------------------------------------------------*
MODULE cursor INPUT.
  GET CURSOR LINE lv_linno.
  lv_linno = lv_linno + 1.
  GET CURSOR FIELD lv_field.

  CASE 'X'.
    WHEN pa_std.
      IF lv_linno EQ 10.
        tc_dn-top_line = tc_dn-top_line + 1.
        lv_linno       = 9.
      ENDIF.
    WHEN pa_ext OR pa_conv.
      IF lv_linno EQ 10.
        tc_out-top_line = tc_out-top_line + 1.
        lv_linno       = 9.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " CURSOR  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0500 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN '&POS'.
      DELETE gt_dn WHERE vbeln IS INITIAL.
      LEAVE TO SCREEN 0.

    WHEN '&DEL'.
      LOOP AT gt_dn WHERE check EQ 'X'.
        DELETE gt_dn.
      ENDLOOP.

    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0500  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_GET_SHPHIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_shphist .
  IF gt_vttp[] IS NOT INITIAL.
    SELECT * INTO TABLE gt_zmshphist FROM zmshphist
      FOR ALL ENTRIES IN gt_vttp
*      WHERE vbeln EQ gt_vttp-vbeln.
      WHERE tknum EQ gt_vttp-tknum
        AND vbeln EQ gt_vttp-vbeln.

    SELECT * INTO TABLE gt_zmshphistr FROM zmshphistr.
  ENDIF.
ENDFORM.                    " F_GET_SHPHIST

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_STATUS
*&---------------------------------------------------------------------*
FORM f_change_status .
  LOOP AT gt_out.
    IF gt_out-delvgrp IS NOT INITIAL.
      CLEAR gt_out-check.
      MODIFY gt_out TRANSPORTING check.
    ENDIF.
  ENDLOOP.

  PERFORM f_alv TABLES gt_out.
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_CHANGE_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_SORTF
*&---------------------------------------------------------------------*
FORM f_change_sortf  TABLES   ft_out  STRUCTURE gt_out
                     USING    fu_sammg.
  DATA : lt_vbss  LIKE vbss OCCURS 0 WITH HEADER LINE.

  SELECT sammg vbeln sortf
    FROM vbss
    INTO CORRESPONDING FIELDS OF TABLE lt_vbss
    WHERE sammg = fu_sammg.

  SORT ft_out BY vbeln.
  SORT lt_vbss BY vbeln.

  LOOP AT lt_vbss.
    READ TABLE ft_out WITH KEY vbeln = lt_vbss-vbeln
                      BINARY SEARCH.
    IF sy-subrc = 0.
      lt_vbss-sortf = ft_out-sortf.
      MODIFY lt_vbss TRANSPORTING sortf.
    ENDIF.
  ENDLOOP.

  UPDATE vbss FROM TABLE lt_vbss.
ENDFORM.                    " F_CHANGE_SORTF

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_ERROR
*&---------------------------------------------------------------------*
FORM f_screen_error  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  CASE 'X'.
    WHEN pa_std.
      IF fu_mess IS NOT INITIAL.
        lv_mess = fu_mess.
        MESSAGE e000(zab) WITH lv_mess.
      ELSE.
        MESSAGE e000(zab) WITH 'Shipping Point' pa_vstel 'belum MDS'.
      ENDIF.

    WHEN pa_ext OR pa_conv.
      MESSAGE e000(zab) WITH lv_mess.
  ENDCASE.
ENDFORM.                    " F_SCREEN_ERROR

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
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  SET PF-STATUS 'STATUS_100'.
  CASE 'X'.
    WHEN pa_ext.
      SET TITLEBAR 'TITLE_100'.
    WHEN pa_conv.
      SET TITLEBAR 'TITLE_110'.
  ENDCASE.

  DESCRIBE TABLE gt_out LINES fill.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : lv_ok    TYPE sy-ucomm,
         lv_subrc TYPE sy-subrc.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'TOP'.
      lv_ok = 'P--'.
      PERFORM compute_scrolling_in_tc USING 'TC_OUT'
                                            lv_ok.
    WHEN 'PREV'.
      lv_ok = 'P-'.
      PERFORM compute_scrolling_in_tc USING 'TC_OUT'
                                            lv_ok.
    WHEN 'NEXT'.
      lv_ok = 'P+'.
      PERFORM compute_scrolling_in_tc USING 'TC_OUT'
                                            lv_ok.
    WHEN 'BOTTOM'.
      lv_ok = 'P++'.
      PERFORM compute_scrolling_in_tc USING 'TC_OUT'
                                            lv_ok.
    WHEN '&POS'.
*      break tds_dev01.
      CLEAR lv_subrc.
      PERFORM f_validasi_data CHANGING lv_subrc.
      CASE lv_subrc.
        WHEN 1.
          MESSAGE s000(zab) WITH 'Keterangan tidak sesuai' DISPLAY LIKE 'E'.
        WHEN 2.
          MESSAGE s000(zab) WITH 'Keterangan harus kosong' DISPLAY LIKE 'E'.
        WHEN 3.
          MESSAGE s000(zab) WITH 'Ext CR Date > system date' DISPLAY LIKE 'E'.
        WHEN 4.
          MESSAGE s000(zab) WITH 'Ext CR Date < GI Date' DISPLAY LIKE 'E'.
        WHEN 5.
          MESSAGE s000(zab) WITH 'Ext CR Time Must Be Entries' DISPLAY LIKE 'E'.
        WHEN OTHERS.
          PERFORM f_save_to_table_zsextrec.
          MESSAGE s000(zab) WITH 'Data already saved'.
          LEAVE TO SCREEN 0.
      ENDCASE.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TO_TABLE_ZSEXTREC
*&---------------------------------------------------------------------*
FORM f_save_to_table_zsextrec .
  DATA : ls_zsextrec  TYPE zsextrec.
  LOOP AT gt_out.
*    IF gt_out-crdat IS NOT INITIAL.
    ls_zsextrec-vbeln     = gt_out-vbeln.
    ls_zsextrec-crdat     = gt_out-crdat.
    ls_zsextrec-crtim     = gt_out-crtim.
    ls_zsextrec-uname     = sy-uname.
    ls_zsextrec-datum     = sy-datum.
    ls_zsextrec-crexdesc  = gt_out-crexrsdesc.

    CASE 'X'.
      WHEN pa_ext.

        READ TABLE gt_zsextrec WITH KEY vbeln = gt_out-vbeln.
        IF sy-subrc = 0.

          READ TABLE gt_xout WITH KEY vbeln = gt_out-vbeln.
          IF sy-subrc = 0.

            IF gt_out-crdat <> gt_xout-crdat OR
              gt_out-crtim  <> gt_xout-crtim OR
              gt_out-crexrsdesc <> gt_xout-crexrsdesc.

              UPDATE zsextrec SET crdat_tmp = ls_zsextrec-crdat
                                  crtim_tmp = ls_zsextrec-crtim
                                  uname_tmp = ls_zsextrec-uname
                                  datum_tmp = ls_zsextrec-datum
                                  chgdatum  = sy-datum
                                  chguzeit  = sy-uzeit
                                  chguname  = sy-uname
                                  datum     = ls_zsextrec-datum
                                  crexdesc  = ls_zsextrec-crexdesc
                              WHERE vbeln = ls_zsextrec-vbeln.
            ENDIF.
          ENDIF.
        ELSE.
          IF gt_out-crdat IS INITIAL AND
            gt_out-crtim IS INITIAL AND
            gt_out-crexrsdesc IS INITIAL.
            CONTINUE.
          ELSE.
            ls_zsextrec-crdat_tmp = ls_zsextrec-crdat.
            ls_zsextrec-crtim_tmp = ls_zsextrec-crtim.
            ls_zsextrec-uname_tmp = ls_zsextrec-uname.
            ls_zsextrec-datum_tmp = ls_zsextrec-datum.
            CLEAR: ls_zsextrec-crdat,ls_zsextrec-crtim,ls_zsextrec-uname.
            INSERT zsextrec FROM ls_zsextrec.
          ENDIF.
        ENDIF.
*    ENDIF.

      WHEN pa_conv.
        UPDATE zsextrec SET crdat     = ls_zsextrec-crdat
                            crtim     = ls_zsextrec-crtim
                            uname     = sy-uname
                            chgdatum  = sy-datum
                            chguzeit  = sy-uzeit
                            chguname  = sy-uname
*                            datum     = ls_zsextrec-datum
*                            crexdesc  = ls_zsextrec-crexdesc
                        WHERE vbeln = ls_zsextrec-vbeln.
    ENDCASE.

    CLEAR ls_zsextrec.
  ENDLOOP.
ENDFORM.                    " F_SAVE_TO_TABLE_ZSEXTREC

*&---------------------------------------------------------------------*
*&      Module  VALUE-FIELD  INPUT
*&---------------------------------------------------------------------*
MODULE value-field INPUT.
  DATA : lv_zsextrecreas   TYPE help_info-dynprofld.

  DATA : BEGIN OF lt_zsextrecreas OCCURS 0,
           crexrscode TYPE zsextrecreas-crexrscode,
           crexrsdesc TYPE zsextrecreas-crexrsdesc,
         END OF lt_zsextrecreas.

  IF pa_conv IS INITIAL.
    lv_zsextrecreas = 'GS_OUT-CREXRSDESC'.

    CLEAR : lt_zsextrecreas[], lt_zsextrecreas.
    LOOP AT gt_zsextrecreas.
      lt_zsextrecreas-crexrscode = gt_zsextrecreas-crexrscode.
      lt_zsextrecreas-crexrsdesc = gt_zsextrecreas-crexrsdesc.
      APPEND lt_zsextrecreas.
      CLEAR lt_zsextrecreas.
    ENDLOOP.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield    = 'CREXRSDESC'
        dynpprog    = sy-repid
        dynpnr      = sy-dynnr
        dynprofield = lv_zsextrecreas
        value_org   = 'S'
      TABLES
        value_tab   = lt_zsextrecreas.
  ENDIF.
ENDMODULE.                 " VALUE-FIELD  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_DATA
*&---------------------------------------------------------------------*
FORM f_validasi_data  CHANGING fc_subrc.
  DATA : lt_zmshphist   LIKE zmshphist OCCURS 0 WITH HEADER LINE.

  LOOP AT gt_out.
    IF gt_out-zreason IS NOT INITIAL.
      lt_zmshphist-tknum    = gt_out-tknum.
      lt_zmshphist-vbeln    = gt_out-vbeln.
      lt_zmshphist-zreason  = gt_out-zreason.
      lt_zmshphist-zdate    = sy-datum.
      lt_zmshphist-ztime    = sy-uzeit.
      lt_zmshphist-zuser    = sy-uname.
      APPEND lt_zmshphist.
    ENDIF.

    IF gt_out-crexrsdesc IS NOT INITIAL.
      READ TABLE gt_zsextrecreas WITH KEY crexrsdesc = gt_out-crexrsdesc.
      IF sy-subrc = 0.
        IF gt_out-crdat IS NOT INITIAL AND
          gt_out-crtim IS NOT INITIAL.
          fc_subrc = 2.
          EXIT.
        ENDIF.
      ELSE.
        fc_subrc = 1.
        EXIT.
      ENDIF.
    ENDIF.

    IF gt_out-crdat IS NOT INITIAL.
      READ TABLE gt_xout WITH KEY vbeln = gt_out-vbeln.
      IF sy-subrc = 0.
        IF gt_out-crdat <> gt_xout-crdat.
          IF gt_out-crdat > sy-datum.
            fc_subrc = 3.
            EXIT.

          ELSE.
            READ TABLE gt_likp WITH KEY vbeln = gt_out-vbeln.
            IF sy-subrc = 0.
              IF gt_out-crdat < gt_likp-wadat_ist.
                fc_subrc = 4.
                EXIT.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      IF gt_out-crtim IS INITIAL.
        fc_subrc = 5.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF fc_subrc IS INITIAL.
    IF pa_ext IS NOT INITIAL.
      SORT gt_zmshphist BY tknum vbeln zcount DESCENDING.
      LOOP AT lt_zmshphist.
        READ TABLE gt_zmshphist WITH KEY tknum = lt_zmshphist-tknum
                                         vbeln = lt_zmshphist-vbeln.
        IF sy-subrc <> 0.
          lt_zmshphist-zcount   = 1.
        ELSE.
          "Replace, for handling error when insert table
*          lt_zmshphist-zcount   = gt_zmshphist-zcount   + 1.
          SELECT MAX( zcount ) INTO @DATA(lv_zcount)
            FROM zmshphist WHERE tknum = @lt_zmshphist-tknum
                             AND vbeln = @lt_zmshphist-vbeln.
          lt_zmshphist-zcount = lv_zcount + 1.
          "End Replace
        ENDIF.

        MODIFY lt_zmshphist TRANSPORTING zcount.
        INSERT zmshphist FROM lt_zmshphist.
      ENDLOOP.
*      INSERT zmshphist FROM TABLE lt_zmshphist.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDASI_DATA

*&---------------------------------------------------------------------*
*&      Form  F_VR_ZREASON
*&---------------------------------------------------------------------*
FORM f_vr_zreason USING fu_field fu_field1 fu_lines.
  DATA : BEGIN OF lt_reason OCCURS 0,
           zreason  TYPE zmshphistr-zreason,
           zreason1 TYPE zmshphistr-zreason1,
         END OF lt_reason.
  DATA : lv_subrc    TYPE sy-subrc,
         lv_zreason  TYPE zmshphistr-zreason,
         lv_zreason1 TYPE zmshphistr-zreason1.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  IF fu_lines IS NOT INITIAL.
    LOOP AT gt_zsdnstat.
      lt_reason-zreason  = gt_zsdnstat-zreason.
      lt_reason-zreason1 = gt_zsdnstat-zreason1.
      APPEND lt_reason.
    ENDLOOP.
  ELSE.
    IF gv_flag IS NOT INITIAL.
      LOOP AT gt_zsdnstat WHERE zreason = '99'.
        lt_reason-zreason  = gt_zsdnstat-zreason.
        lt_reason-zreason1 = gt_zsdnstat-zreason1.
        APPEND lt_reason.
      ENDLOOP.
    ELSE.
      LOOP AT gt_zsdnstat WHERE zreason NE '99'.
        lt_reason-zreason  = gt_zsdnstat-zreason.
        lt_reason-zreason1 = gt_zsdnstat-zreason1.
        APPEND lt_reason.
      ENDLOOP.
    ENDIF.
  ENDIF.

  ASSIGN lt_reason[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'ZREASON' fu_field
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      lv_zreason  = ls_return-fieldval.
      READ TABLE gt_zsdnstat WITH KEY zreason = lv_zreason.
      IF sy-subrc = 0.
        lv_zreason1 = gt_zsdnstat-zreason1.
      ENDIF.
      PERFORM f_dynpfield TABLES dynpfields
                          USING fu_field lv_zreason '' fu_lines.
      PERFORM f_dynpfield TABLES dynpfields
                          USING fu_field1 lv_zreason1 '' fu_lines.
    ENDIF.
    PERFORM f_dyn_values_update.
  ENDIF.
ENDFORM.                    " F_VR_ZREASON

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

  fc_subrc  = sy-subrc.
ENDFORM.                    " F_VALUE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  F_DYNPFIELD
*&---------------------------------------------------------------------*
FORM f_dynpfield  TABLES   dynpfields STRUCTURE dynpread
                  USING    fieldname fieldvalue fu_waers fu_lines.

  DATA : ls_dynpfields  LIKE LINE OF dynpfields.

  ls_dynpfields-fieldname  = fieldname.
  IF fu_waers IS NOT INITIAL.
    ls_dynpfields-fieldvalue = fieldvalue.
    TRANSLATE ls_dynpfields-fieldvalue USING '. '.
    CONDENSE ls_dynpfields-fieldvalue NO-GAPS.
  ELSE.
    ls_dynpfields-fieldvalue = fieldvalue.
  ENDIF.

  ls_dynpfields-stepl        = fu_lines.
  APPEND ls_dynpfields TO dynpfields.
ENDFORM.                    " F_DYNPFIELD

*&---------------------------------------------------------------------*
*&      Form  F_DYN_VALUES_UPDATE
*&---------------------------------------------------------------------*
FORM f_dyn_values_update .
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
ENDFORM.                    " F_DYN_VALUES_UPDATE

*&---------------------------------------------------------------------*
*&      Module  VALUE_REASON  INPUT
*&---------------------------------------------------------------------*
MODULE value_reason INPUT.
  DATA : lin    TYPE int4.

  IF pa_conv IS INITIAL.
    GET CURSOR LINE lin.
    READ TABLE gt_out INDEX lin.
    IF sy-subrc = 0.
      READ TABLE gt_vttk WITH KEY tknum = gt_out-tknum.
      IF gt_vttk-add04(3) = 'EXT'.
        gv_flag = 'X'.
      ENDIF.
    ENDIF.

    PERFORM f_vr_zreason  USING 'GS_OUT-ZREASON' 'GS_OUT-ZREASON1' lin.
  ENDIF.
ENDMODULE.                 " VALUE_REASON  INPUT

*&---------------------------------------------------------------------*
*&      Module  DISABLE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE disable OUTPUT.
  IF pa_conv = 'X'.
*    IF sy-stepl <> 1.
    LOOP AT SCREEN.
      CASE screen-name.
*          WHEN 'GS_OUT-CRDAT'.
*            screen-input = 0.
*            MODIFY SCREEN.
*          WHEN 'GS_OUT-CRTIM'.
*            screen-input = 0.
*            MODIFY SCREEN.
        WHEN 'GS_OUT-CREXRSDESC'.
          screen-input = 0.
          MODIFY SCREEN.
        WHEN 'GS_OUT-ZREASON'.
          screen-input = 0.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
*    ENDIF.
  ENDIF.
ENDMODULE.                 " DISABLE  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  DISABLE
*&---------------------------------------------------------------------*
FORM disable .
  IF pa_ext = 'X'.
*    IF sy-stepl <> 1.
    LOOP AT SCREEN.
      CASE 'X'.
        WHEN gv_disable.
          CASE screen-name.
            WHEN 'GS_OUT-CRDAT'.
              screen-input = 0.
            WHEN 'GS_OUT-CRTIM'.
              screen-input = 0.
            WHEN 'GS_OUT-CREXRSDESC'.
              screen-input = 0.
*            WHEN 'GS_OUT-ZREASON'.
*              screen-input = 0.
          ENDCASE.
          MODIFY SCREEN.

        WHEN gv_enable.
          CASE screen-name.
            WHEN 'GS_OUT-CRDAT'.
              screen-input = 1.
            WHEN 'GS_OUT-CRTIM'.
              screen-input = 1.
            WHEN 'GS_OUT-CREXRSDESC'.
              screen-input = 1.
*            WHEN 'GS_OUT-ZREASON'.
*              screen-input = 1.
          ENDCASE.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
*    ENDIF.
  ENDIF.
ENDFORM.                    " DISABLE
