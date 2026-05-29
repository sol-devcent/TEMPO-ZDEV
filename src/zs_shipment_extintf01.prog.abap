*----------------------------------------------------------------------*
*   INCLUDE ZS_SHIPMENT_EXTINTF01
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
  DATA : BEGIN OF lt_ttdst OCCURS 0,
           tplst    TYPE tplst,
         END OF lt_ttdst.
  DATA : BEGIN OF lt_vttp OCCURS 0,
           tknum    TYPE tknum,
         END OF lt_vttp.
  DATA : lt_likp LIKE gt_vttp OCCURS 0 WITH HEADER LINE.
  DATA : lt_kna1 LIKE gt_likp OCCURS 0 WITH HEADER LINE.

  SELECT tknum shtyp tplst erdat route signi exti1 datbg add04
    dalbg ualbg dalen ualen
    FROM vttk
    INTO CORRESPONDING FIELDS OF TABLE gt_vttk
    WHERE tplst IN so_tplst
      AND shtyp IN so_shtyp
      AND erdat IN so_erdat
      AND route IN so_route.

  IF gt_vttk[] IS NOT INITIAL.
    SELECT *
      FROM zwmdt003
      INTO CORRESPONDING FIELDS OF TABLE gt_zwmdt003
      FOR ALL ENTRIES IN gt_vttk
      WHERE tknum = gt_vttk-tknum.
  ENDIF.

  LOOP AT gt_vttk.
    lt_ttdst-tplst  = gt_vttk-tplst.
    APPEND lt_ttdst.
    CLEAR lt_ttdst.
    lt_vttp-tknum  = gt_vttk-tknum.
    APPEND lt_vttp.
    CLEAR lt_vttp.
  ENDLOOP.

  SORT lt_ttdst BY tplst.
  DELETE ADJACENT DUPLICATES FROM lt_ttdst COMPARING tplst.
  SORT lt_vttp BY tknum.
  DELETE ADJACENT DUPLICATES FROM lt_vttp COMPARING tknum.

  IF lt_ttdst[] IS NOT INITIAL.
    SELECT tplst bezei
      FROM ttdst
      INTO TABLE gt_ttdst
      FOR ALL ENTRIES IN lt_ttdst
      WHERE tplst = lt_ttdst-tplst.
  ENDIF.

  IF lt_vttp[] IS NOT INITIAL.
    IF pa_hist IS INITIAL.
      SELECT tknum tpnum vbeln
        FROM vttp
        INTO TABLE gt_vttp
        FOR ALL ENTRIES IN lt_vttp
        WHERE tknum = lt_vttp-tknum.
    ELSE.
      SELECT tknum vbeln
        FROM zmshphist
        INTO CORRESPONDING FIELDS OF TABLE gt_vttp
        FOR ALL ENTRIES IN lt_vttp
        WHERE tknum = lt_vttp-tknum
          AND zcount = '001'.
    ENDIF.

    SELECT tknum vbeln zcount zreason
      FROM zmshphist
      INTO TABLE gt_zmshphist
      FOR ALL ENTRIES IN lt_vttp
      WHERE tknum = lt_vttp-tknum.

    IF pa_hist IS INITIAL.
      SORT gt_zmshphist BY tknum vbeln zcount DESCENDING.
    ELSE.
      SORT gt_zmshphist BY tknum vbeln zcount.
    ENDIF.

    DELETE ADJACENT DUPLICATES FROM gt_zmshphist COMPARING tknum vbeln.
  ENDIF.

  lt_likp[] = gt_vttp[].
  SORT lt_likp BY vbeln.
  DELETE ADJACENT DUPLICATES FROM lt_likp COMPARING vbeln.

  IF lt_likp[] IS NOT INITIAL.
    SELECT * INTO TABLE gt_zsextrec
      FROM zsextrec FOR ALL ENTRIES IN lt_likp
      WHERE vbeln = lt_likp-vbeln.

    SELECT vbeln kunnr route btgew gewei volum voleh wadat_ist
      FROM likp
      INTO TABLE gt_likp
      FOR ALL ENTRIES IN lt_likp
      WHERE vbeln = lt_likp-vbeln.

    SELECT vbeln posnr kvgr3 vgbel vgpos matnr werks lgort charg lfimg
      FROM lips
      INTO TABLE gt_lips
      FOR ALL ENTRIES IN lt_likp
      WHERE vbeln = lt_likp-vbeln.

    IF gt_lips[] IS NOT INITIAL.
*{   REPLACE        P01K910371                                        1
*\      SELECT vbeln posnr
*\        FROM vbap
*\        INTO TABLE gt_vbap
*\        FOR ALL ENTRIES IN gt_lips
*\        WHERE vbeln = gt_lips-vgbel
*\          AND posnr = gt_lips-vgpos.
      "Start SOH: Shell SCI Adjustment 20240222 RZL
      SELECT vbeln posnr
        FROM vbap
        INTO TABLE gt_vbap
        FOR ALL ENTRIES IN gt_lips
        WHERE vbeln = gt_lips-vgbel
          AND posnr = gt_lips-vgpos ORDER BY PRIMARY KEY.
     "End SOH: Shell SCI Adjustment 20240222 RZL
*}   REPLACE
    ENDIF.

    DELETE ADJACENT DUPLICATES FROM gt_vbap COMPARING vbeln.

    IF gt_vbap[] IS NOT INITIAL.
      SELECT vbeln netwr waerk
        FROM vbak
        INTO TABLE gt_vbak
        FOR ALL ENTRIES IN gt_vbap
        WHERE vbeln = gt_vbap-vbeln.
    ENDIF.
  ENDIF.

  lt_kna1[] = gt_likp[].
  SORT lt_kna1 BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_kna1 COMPARING kunnr.

  IF lt_kna1[] IS NOT INITIAL.
    SELECT kunnr name1 katr1
      FROM kna1
      INTO TABLE gt_kna1
      FOR ALL ENTRIES IN lt_kna1
      WHERE kunnr = lt_kna1-kunnr.
  ENDIF.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_print       USING   d_print.
  PERFORM f_alv_variant_exist USING   pa_varnt
                                      d_alv_variant.

  PERFORM f_build_event       TABLES  t_alv_event[].
  lv_func    = 'REUSE_ALV_LIST_DISPLAY'.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = sy-repid
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
      t_outtab                 = <fs_itab>.
ENDFORM.                    "F_PRINT_DATA

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
*       FORM F_BUILD_LAYOUT
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = 'X'.
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
*       FORM F_TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM f_top_of_page.
  DATA: lv_hist TYPE char20.

  IF pa_hist IS NOT INITIAL.
    lv_hist = 'Read History'.
  ENDIF.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING lv_hist.
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
  DATA : lv_tknum   TYPE tknum,
         lv_kunnr   TYPE kunnr,
         lv_tabix   TYPE sy-tabix.

  DATA : lv_jmlshp(1).

  DATA : BEGIN OF lt_jmldp OCCURS 0,
           kunnr    TYPE kunnr,
           tknum    TYPE tknum,
         END OF lt_jmldp.

  DATA : ls_zwmdt003    LIKE LINE OF gt_zwmdt003.
  DATA : lv_btgew       TYPE gsgew,
         lv_gewei       TYPE gewei,
         lv_btgew_gr    TYPE gsgew,
         lv_meins       TYPE gewei.

  LOOP AT gt_vttk.
    CLEAR : lv_tknum.
    ASSIGN COMPONENT 'DATBG' OF STRUCTURE <fs_wa> TO <fs>.
    <fs>  = gt_vttk-datbg.
    ASSIGN COMPONENT 'TKNUM' OF STRUCTURE <fs_wa> TO <fs>.
    <fs>  = gt_vttk-tknum.
    lt_jmldp-tknum  = gt_vttk-tknum.
    ASSIGN COMPONENT 'ADD04' OF STRUCTURE <fs_wa> TO <fs>.
    <fs>  = gt_vttk-add04.
*    ASSIGN COMPONENT 'ROUTE' OF STRUCTURE <fs_wa> TO <fs>.
*    <fs>  = gt_vttk-route.
    ASSIGN COMPONENT 'EXTI1' OF STRUCTURE <fs_wa> TO <fs>.
    <fs>  = gt_vttk-exti1.
    ASSIGN COMPONENT 'SIGNI' OF STRUCTURE <fs_wa> TO <fs>.
    <fs>  = gt_vttk-signi.

    ASSIGN COMPONENT 'TPLST' OF STRUCTURE <fs_wa> TO <fs>.
    <fs> = gt_vttk-tplst.
    READ TABLE gt_ttdst WITH KEY tplst = gt_vttk-tplst.
    IF sy-subrc = 0.
      ASSIGN COMPONENT 'BEZEI' OF STRUCTURE <fs_wa> TO <fs>.
      <fs> = gt_ttdst-bezei.
    ENDIF.

    ASSIGN COMPONENT 'DALBG' OF STRUCTURE <fs_wa> TO <fs>.
    <fs>  = gt_vttk-dalbg.
    ASSIGN COMPONENT 'UALBG' OF STRUCTURE <fs_wa> TO <fs>.
    <fs>  = gt_vttk-ualbg.
    ASSIGN COMPONENT 'DALEN' OF STRUCTURE <fs_wa> TO <fs>.
    <fs>  = gt_vttk-dalen.
    ASSIGN COMPONENT 'UALEN' OF STRUCTURE <fs_wa> TO <fs>.
    <fs>  = gt_vttk-ualen.

    CLEAR ls_zwmdt003.
    READ TABLE gt_zwmdt003 INTO ls_zwmdt003
                           WITH KEY tknum = gt_vttk-tknum.
    IF sy-subrc = 0.
      ASSIGN COMPONENT 'ERNAM' OF STRUCTURE <fs_wa> TO <fs>.
      <fs>  = ls_zwmdt003-ernam.
    ENDIF.

    CLEAR : lv_jmlshp.

    LOOP AT gt_vttp WHERE tknum = gt_vttk-tknum.
      ASSIGN COMPONENT 'JMLSHP' OF STRUCTURE <fs_wa> TO <fs>.
      PERFORM f_count CHANGING lv_jmlshp <fs>.

      ASSIGN COMPONENT 'VBELN' OF STRUCTURE <fs_wa> TO <fs>.
      <fs> = gt_vttp-vbeln.
      ASSIGN COMPONENT 'JMLDN' OF STRUCTURE <fs_wa> TO <fs>.
      <fs> = 1.

      READ TABLE gt_zsextrec WITH KEY vbeln = gt_vttp-vbeln.
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'CRDAT' OF STRUCTURE <fs_wa> TO <fs>.
        <fs> = gt_zsextrec-crdat.
        ASSIGN COMPONENT 'CRTIM' OF STRUCTURE <fs_wa> TO <fs>.
        <fs> = gt_zsextrec-crtim.
        ASSIGN COMPONENT 'CREXDESC' OF STRUCTURE <fs_wa> TO <fs>.
        <fs> = gt_zsextrec-crexdesc.
      ELSE.
        ASSIGN COMPONENT 'CRDAT' OF STRUCTURE <fs_wa> TO <fs>.
        CLEAR <fs>.
        ASSIGN COMPONENT 'CRTIM' OF STRUCTURE <fs_wa> TO <fs>.
        CLEAR <fs>.
        ASSIGN COMPONENT 'CREXDESC' OF STRUCTURE <fs_wa> TO <fs>.
        CLEAR <fs>.
      ENDIF.

      READ TABLE gt_likp WITH KEY vbeln = gt_vttp-vbeln.
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'WADAT' OF STRUCTURE <fs_wa> TO <fs>.
        <fs> = gt_likp-wadat_ist.
        ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <fs_wa> TO <fs>.
        <fs> = gt_likp-kunnr.
        lt_jmldp-kunnr  = gt_likp-kunnr.
        APPEND lt_jmldp.
        ASSIGN COMPONENT 'ROUTE' OF STRUCTURE <fs_wa> TO <fs>.
        <fs>  = gt_likp-route.

        ASSIGN COMPONENT 'BTGEW' OF STRUCTURE <fs_wa> TO <fs>.
        <fs> = gt_likp-btgew.
        ASSIGN COMPONENT 'GEWEI' OF STRUCTURE <fs_wa> TO <fs>.
        <fs> = gt_likp-gewei.
        ASSIGN COMPONENT 'VOLUM' OF STRUCTURE <fs_wa> TO <fs>.
        <fs> = gt_likp-volum.
        ASSIGN COMPONENT 'VOLEH' OF STRUCTURE <fs_wa> TO <fs>.
        <fs> = gt_likp-voleh.

        READ TABLE gt_kna1 WITH KEY kunnr = gt_likp-kunnr.
        IF sy-subrc = 0.
          ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_wa> TO <fs>.
          <fs> = gt_kna1-name1.
          ASSIGN COMPONENT 'KATR1' OF STRUCTURE <fs_wa> TO <fs>.
          <fs> = gt_kna1-katr1.
        ENDIF.

        CLEAR: lv_btgew,lv_gewei,lv_meins,lv_btgew_gr.
        lv_btgew    = gt_likp-btgew.
        lv_gewei    = gt_likp-gewei.
        lv_meins    = 'G'.
*        lv_btgew_gr =
        CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
          EXPORTING
            input                      = lv_btgew
*           NO_TYPE_CHECK              = 'X'
*           ROUND_SIGN                 = ' '
            unit_in                    = lv_gewei
            unit_out                   = lv_meins
          IMPORTING
            output                     = lv_btgew_gr
          EXCEPTIONS
            conversion_not_found       = 1
            division_by_zero           = 2
            input_invalid              = 3
            output_invalid             = 4
            overflow                   = 5
            type_invalid               = 6
            units_missing              = 7
            unit_in_not_found          = 8
            unit_out_not_found         = 9
            OTHERS                     = 10.
        IF sy-subrc = 0.
          ASSIGN COMPONENT 'BTGEW_GR' OF STRUCTURE <fs_wa> TO <fs>.
          <fs> = lv_btgew_gr.
          ASSIGN COMPONENT 'MEINS' OF STRUCTURE <fs_wa> TO <fs>.
          <fs> = lv_meins.
        ENDIF.
      ENDIF.

      READ TABLE gt_lips WITH KEY vbeln = gt_vttp-vbeln.
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'KVGR3' OF STRUCTURE <fs_wa> TO <fs>.
        <fs> = gt_lips-kvgr3.
        READ TABLE gt_vbap WITH KEY vbeln = gt_lips-vgbel.
        IF sy-subrc = 0.
          READ TABLE gt_vbak WITH KEY vbeln = gt_vbap-vbeln.
          IF sy-subrc = 0.
            ASSIGN COMPONENT 'NETWR' OF STRUCTURE <fs_wa> TO <fs>.
            <fs> = gt_vbak-netwr * ( 11 / 10 ).
            ASSIGN COMPONENT 'WAERK' OF STRUCTURE <fs_wa> TO <fs>.
            <fs> = gt_vbak-waerk.
          ENDIF.
        ENDIF.
      ENDIF.

      CLEAR lv_tabix.
      READ TABLE gt_zmshphist WITH KEY tknum = lv_tknum
                                       vbeln = gt_vttp-vbeln.
      IF sy-subrc = 0.
        lv_tabix  = sy-tabix.
        CASE gt_zmshphist-zreason.
          WHEN '52'.
            ASSIGN COMPONENT 'PARTR' OF STRUCTURE <fs_wa> TO <fs>.
            <fs> = 1.
          WHEN '53' OR '56'.
            ASSIGN COMPONENT 'OTHERS' OF STRUCTURE <fs_wa> TO <fs>.
            <fs> = 1.
          WHEN space.
          WHEN OTHERS.
            ASSIGN COMPONENT 'FULLR' OF STRUCTURE <fs_wa> TO <fs>.
            <fs> = 1.
        ENDCASE.
        DELETE gt_zmshphist INDEX lv_tabix.
      ELSE.
        ASSIGN COMPONENT 'FULLR' OF STRUCTURE <fs_wa> TO <fs>.
        IF gt_vttk-datbg IS NOT INITIAL.
          <fs> = 1.
        ELSE.
          <fs> = 0.
        ENDIF.
        ASSIGN COMPONENT 'PARTR' OF STRUCTURE <fs_wa> TO <fs>.
        <fs> = 0.
        ASSIGN COMPONENT 'OTHERS' OF STRUCTURE <fs_wa> TO <fs>.
        <fs> = 0.
      ENDIF.

      READ TABLE gt_karton WITH KEY vbeln = gt_vttp-vbeln.
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'KARTON' OF STRUCTURE <fs_wa> TO <fs>.
        <fs> = gt_karton-karton.
      ENDIF.

      APPEND <fs_wa> TO <fs_itab>.
    ENDLOOP.
  ENDLOOP.

  SORT lt_jmldp BY tknum kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_jmldp COMPARING tknum kunnr.

  LOOP AT <fs_itab> ASSIGNING <fs_wa>.
    CLEAR : lv_tabix, lv_tknum, lv_kunnr.

    ASSIGN COMPONENT 'TKNUM' OF STRUCTURE <fs_wa> TO <fs>.
    lv_tknum  = <fs>.
    ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <fs_wa> TO <fs>.
    lv_kunnr  = <fs>.

    READ TABLE lt_jmldp WITH KEY tknum = lv_tknum
                                 kunnr = lv_kunnr.
    IF sy-subrc = 0.
      lv_tabix  = sy-tabix.
      ASSIGN COMPONENT 'JMLDP' OF STRUCTURE <fs_wa> TO <fs>.
      <fs> = 1.
      DELETE lt_jmldp INDEX lv_tabix.
    ENDIF.
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

ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_CRT_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_crt_dyn_int_table .
  DATA : dfies_tab    TYPE STANDARD TABLE OF dfies,
         wa_dfies     LIKE dfies.

  DATA : lv_tabname   TYPE ddobjname VALUE 'ZSHPEXTINT',
         lv_pos       TYPE int4.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = lv_tabname
    TABLES
      dfies_tab      = dfies_tab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.

  LOOP AT dfies_tab INTO wa_dfies FROM 3.
    lv_pos = lv_pos + 1.
    MOVE-CORRESPONDING wa_dfies TO wa_dyn_fcat.
*Begin insert Unicode conversion - DEVK966044
*17.03.2020 - SOL_FELIX
    wa_dyn_fcat-intlen = wa_dfies-leng.
*End insert Unicode conversion - DEVK966044
    wa_dyn_fcat-col_pos     = lv_pos.
    wa_dyn_fcat-ref_field   = wa_dfies-fieldname.
    wa_dyn_fcat-ref_table   = wa_dfies-tabname.
    APPEND wa_dyn_fcat TO gt_dyn_fcat.
    CLEAR wa_dyn_fcat.
  ENDLOOP.

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
    ASSIGN gt_dyn_table->* TO <fs_itab>.
    CREATE DATA wa_line LIKE LINE OF <fs_itab>.
    ASSIGN wa_line->* TO <fs_wa>.
  ENDIF.

* Create ALV Fieldcat
  CLEAR : lv_pos.
  LOOP AT gt_dyn_fcat INTO wa_dyn_fcat.
    lv_pos = lv_pos + 1.
    MOVE-CORRESPONDING wa_dyn_fcat TO d_alv_fieldcat.
    d_alv_fieldcat-col_pos       = lv_pos.
    d_alv_fieldcat-ddictxt       = 'L'.
    CASE lv_pos.
      WHEN 1.
        d_alv_fieldcat-seltext_l  = 'Tgl.Shipment'.
      WHEN 2.
        d_alv_fieldcat-seltext_l  = 'No.Shipment'.
      WHEN 3.
        d_alv_fieldcat-seltext_l  = 'Kode Cab'.
      WHEN 4.
        d_alv_fieldcat-seltext_l  = 'Cabang'.
      WHEN 5.
        d_alv_fieldcat-seltext_l  = 'Int/Ext'.
      WHEN 6.
        d_alv_fieldcat-seltext_l  = 'Route'.
      WHEN 7.
        d_alv_fieldcat-seltext_l  = 'Nama Deliveryman'.
      WHEN 8.
        d_alv_fieldcat-seltext_l  = 'No Pol Kendaraan'.
      WHEN 9.
        d_alv_fieldcat-seltext_l  = 'No.DN'.
      WHEN 10.
        d_alv_fieldcat-seltext_l  = 'Tgl.DN'.
      WHEN 11.
        d_alv_fieldcat-seltext_l  = 'Ship to Party'.
      WHEN 12.
        d_alv_fieldcat-seltext_l  = 'Ship to Party name'.
      WHEN 13.
        d_alv_fieldcat-seltext_l  = 'DK/LK'.
      WHEN 14.
        d_alv_fieldcat-seltext_l  = 'Sub CG'.
      WHEN 15.
        d_alv_fieldcat-seltext_l  = 'Berat'.
        d_alv_fieldcat-qfieldname = 'GEWEI'.
      WHEN 16.
        d_alv_fieldcat-seltext_l  = 'Sat.Berat'.
      WHEN 17.
        d_alv_fieldcat-seltext_l  = 'Volume'.
        d_alv_fieldcat-qfieldname = 'VOLEH'.
      WHEN 18.
        d_alv_fieldcat-seltext_l  = 'Sat.Volume'.
      WHEN 19.
        d_alv_fieldcat-seltext_l  = 'Net Value (Incl.Tax)'.
        d_alv_fieldcat-cfieldname = 'WAERK'.
      WHEN 20.
        d_alv_fieldcat-seltext_l  = 'Curr'.
      WHEN 21.
        d_alv_fieldcat-seltext_l  = 'Juml.Shipment'.
      WHEN 22.
        d_alv_fieldcat-seltext_l  = 'Juml.DN'.
      WHEN 23.
        d_alv_fieldcat-seltext_l  = 'Juml.Drop Point'.
      WHEN 24.
        d_alv_fieldcat-seltext_l  = 'Full Receipt'.
      WHEN 25.
        d_alv_fieldcat-seltext_l  = 'Partial Receipt'.
      WHEN 26.
        d_alv_fieldcat-seltext_l  = 'Others'.
      WHEN 27.
        d_alv_fieldcat-seltext_l  = 'CustRecExt Date'.
      WHEN 28.
        d_alv_fieldcat-seltext_l  = 'CustRecExt Time'.
      WHEN 29.
        d_alv_fieldcat-seltext_l  = 'CustRecExt Reason'.
      WHEN 30.
        d_alv_fieldcat-seltext_s  = 'Karton'.
        d_alv_fieldcat-seltext_m  = 'Karton'.
        d_alv_fieldcat-seltext_l  = 'Karton'.
      WHEN 31.
        d_alv_fieldcat-seltext_l  = 'ActLoadStr'.
      WHEN 32.
        d_alv_fieldcat-seltext_l  = 'ActLoadStT'.
      WHEN 33.
        d_alv_fieldcat-seltext_l  = 'ActLoadEnd'.
      WHEN 34.
        d_alv_fieldcat-seltext_l  = 'AcLoadEnTm'.
      WHEN 35.
        d_alv_fieldcat-seltext_l  = 'User'.
      WHEN 36.
        d_alv_fieldcat-seltext_l  = 'Berat (gram)'.
        d_alv_fieldcat-qfieldname = 'MEINS'.
        d_alv_fieldcat-col_pos    = 16.
      WHEN 37.
        d_alv_fieldcat-seltext_l  = 'Sat. (g)'.
        d_alv_fieldcat-col_pos    = 16.
    ENDCASE.
    APPEND d_alv_fieldcat TO t_alv_fieldcat.
    CLEAR d_alv_fieldcat.
  ENDLOOP.
ENDFORM.                    " F_CRT_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_COUNT
*&---------------------------------------------------------------------*
FORM f_count  CHANGING fc_flag fc_value.
  IF fc_flag IS INITIAL.
    fc_flag = 'X'.
    fc_value = 1.
  ELSE.
    fc_value = 0.
  ENDIF.
ENDFORM.                    " F_COUNT

*&---------------------------------------------------------------------*
*&      Form  F_VARIANT_F4
*&---------------------------------------------------------------------*
FORM f_variant_f4  CHANGING fu_varnt.
  d_alv_variant-report  = sy-repid.

  CALL FUNCTION 'LVC_VARIANT_SAVE_LOAD'
    EXPORTING
      i_save_load = 'F'
      i_tabname   = '1'
    CHANGING
      cs_variant  = d_alv_variant
      ct_fieldcat = xfield[].

  fu_varnt = d_alv_variant-variant.
ENDFORM.                    " F_VARIANT_F4

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_KARTON
*&---------------------------------------------------------------------*
FORM f_get_data_karton .
  DATA: lt_marm TYPE TABLE OF marm WITH HEADER LINE,
        lt_lips LIKE gt_lips OCCURS 0 WITH HEADER LINE.

  IF gt_lips[] IS NOT INITIAL.
    LOOP AT gt_lips.
      lt_lips-vbeln = gt_lips-vbeln.
      lt_lips-matnr = gt_lips-matnr.
      lt_lips-lfimg = gt_lips-lfimg.
      COLLECT lt_lips.
    ENDLOOP.

    SELECT matnr meinh umrez umren
      INTO CORRESPONDING FIELDS OF TABLE lt_marm
      FROM marm FOR ALL ENTRIES IN lt_lips
      WHERE matnr = lt_lips-matnr
        AND meinh = 'KAR'.

    SORT: lt_lips BY matnr vbeln,
          lt_marm BY matnr.

    LOOP AT lt_lips.
      CLEAR lt_marm.
      READ TABLE lt_marm WITH KEY matnr = lt_lips-matnr BINARY SEARCH.

      gt_karton-vbeln  = lt_lips-vbeln.
      gt_karton-karton = lt_lips-lfimg * ( lt_marm-umren / lt_marm-umrez ).
      COLLECT gt_karton.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_DATA_KARTON
