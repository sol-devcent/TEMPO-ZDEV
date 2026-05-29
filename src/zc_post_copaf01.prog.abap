*----------------------------------------------------------------------*
*   INCLUDE ZC_POST_COPAF01
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
  DATA : lr_budat     TYPE RANGE OF budat,
         lr_budatln   LIKE LINE OF lr_budat,
         lv_paledger  TYPE ledbo.

  DATA : lt_bseg  LIKE gt_bseg OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF lt_tvgat OCCURS 0,
           vrgar    TYPE rke_vrgar,
           vrgarx	  TYPE rke_vrgarx,
         END OF lt_tvgat.

  DATA : BEGIN OF lt_key OCCURS 0,
           paledger	TYPE ledbo,
           vrgar    TYPE rke_vrgar,
           versi    TYPE rkeversi,
           perio    TYPE jahrper,
           paobjnr  TYPE rkeobjnr,
         END OF lt_key.

  SELECT vrgar vrgarx
    FROM tvgat
    INTO TABLE lt_tvgat
    WHERE spras EQ sy-langu
      AND vrgar BETWEEN 'B' AND 'F'.

  CONCATENATE pa_gjahr pa_monat '01' INTO lr_budatln-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lr_budatln-low
    IMPORTING
      last_day_of_month = lr_budatln-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  lr_budatln-sign   = 'I'.
  lr_budatln-option = 'BT'.
  APPEND lr_budatln TO lr_budat.

  SELECT bukrs hkont augdt augbl zuonr gjahr belnr buzei
    FROM bsis
     INTO TABLE gt_bsis
     WHERE bukrs EQ pa_bukrs
       AND hkont EQ gc_hkont
       AND gjahr EQ pa_gjahr
       AND budat IN lr_budat
       AND monat EQ pa_monat.

  SELECT bukrs hkont augdt augbl zuonr gjahr belnr buzei
    FROM bsas
    APPENDING CORRESPONDING FIELDS OF TABLE gt_bsis
    WHERE bukrs EQ pa_bukrs
      AND hkont EQ gc_hkont
      AND gjahr EQ pa_gjahr
      AND budat LT lr_budatln-high
      AND augdt GE lr_budatln-high
      AND monat EQ pa_monat.

  IF gt_bsis[] IS NOT INITIAL.
    SELECT bukrs gjahr belnr matnr
      FROM zccopa
      INTO CORRESPONDING FIELDS OF TABLE gt_zccopa
      FOR ALL ENTRIES IN gt_bsis
      WHERE bukrs EQ pa_bukrs
        AND gjahr EQ pa_gjahr
        AND belnr EQ gt_bsis-belnr.

    SELECT bukrs belnr gjahr buzei shkzg pswbt pswsl paobjnr
      FROM bseg
      INTO TABLE gt_bseg
      FOR ALL ENTRIES IN gt_bsis
      WHERE bukrs EQ pa_bukrs
        AND belnr EQ gt_bsis-belnr
        AND gjahr EQ pa_gjahr
        AND buzei EQ gt_bsis-buzei.

    lt_bseg[] = gt_bseg[].
    SORT lt_bseg BY belnr.
    DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING belnr.
    IF lt_bseg[] IS NOT INITIAL.
      SELECT bukrs belnr gjahr budat
        FROM bkpf
        INTO TABLE gt_bkpf
        FOR ALL ENTRIES IN lt_bseg
        WHERE bukrs EQ pa_bukrs
          AND belnr EQ lt_bseg-belnr
          AND gjahr EQ pa_gjahr.
    ENDIF.

    IF gt_bseg[] IS NOT INITIAL.
      SELECT aktbo paobjnr pasubnr kndnr artnr bukrs werks
             gsber spart prctr ce4key matkl extwg wwprc wwprr wwprd
        FROM ce48010_acct
        INTO TABLE gt_ce48010_acct
        FOR ALL ENTRIES IN gt_bseg
        WHERE aktbo EQ 'X'
          AND paobjnr EQ gt_bseg-paobjnr
          AND pasubnr EQ '0001'.

      CALL FUNCTION 'CONVERSION_EXIT_LEDBO_INPUT'
        EXPORTING
          input         = 'B0'
        IMPORTING
          output        = lv_paledger
        EXCEPTIONS
          invalid_input = 1
          OTHERS        = 2.

      SORT gt_ce48010_acct BY ce4key.
      LOOP AT lt_tvgat.
        lt_key-paledger = lv_paledger.
        lt_key-vrgar    = lt_tvgat-vrgar.
        lt_key-versi    = space.
        CONCATENATE pa_gjahr '0' pa_monat  INTO lt_key-perio.
        LOOP AT gt_ce48010_acct.
          lt_key-paobjnr  = gt_ce48010_acct-ce4key.
          COLLECT lt_key.
        ENDLOOP.
      ENDLOOP.

      IF lt_key[] IS NOT INITIAL.
        SELECT paledger vrgar versi perio paobjnr pasubnr
               belnr posnr rbeln
          FROM ce18010
          INTO TABLE gt_ce18010
          FOR ALL ENTRIES IN lt_key
          WHERE paledger  EQ lt_key-paledger
            AND vrgar     EQ lt_key-vrgar
            AND versi     EQ lt_key-versi
            AND perio     EQ lt_key-perio
            AND paobjnr   EQ lt_key-paobjnr.
      ENDIF.
    ENDIF.
  ENDIF.
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
    'BELNR' 'BSIS' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BUDAT' 'BSIS' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PERIO' 'CE18010' 'PERIO' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VRGAR' 'CE18010' 'VRGAR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KNDNR' 'CE18010' 'KNDNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BUKRS' 'CE18010' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'ARTNR' 'CE18010' 'ARTNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WERKS' 'CE18010' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PRCTR' 'CE18010' 'PRCTR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'GSBER' 'CE18010' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'SPART' 'CE18010' 'SPART' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MATKL' 'CE18010' 'MATKL' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'EXTWG' 'CE18010' 'EXTWG' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WWPRC' 'CE18010' 'WWPRC' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WWPRR' 'CE18010' 'WWPRR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'WWPRD' 'CE18010' 'WWPRD' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'PSWSL' 'BSEG' 'PSWSL' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VV852' 'CE18010' 'VV852' '' '' '' '' '' '' '' '' 'PSWSL' '' '' '' ''.
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
  ld_sort-fieldname = 'BELNR'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
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
  SET PF-STATUS 'TOEXECUTE'.
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
  SORT gt_bseg BY paobjnr.
  SORT gt_ce48010_acct BY paobjnr.

  LOOP AT gt_bseg.
    READ TABLE gt_ce48010_acct WITH KEY paobjnr = gt_bseg-paobjnr
                               BINARY SEARCH.
    IF sy-subrc EQ 0.
      READ TABLE gt_ce18010 WITH KEY paobjnr = gt_ce48010_acct-ce4key
                                     rbeln   = gt_bseg-belnr.
      IF sy-subrc EQ 0.
        CONTINUE.
      ELSE.
        gt_out-belnr   = gt_bseg-belnr.
        READ TABLE gt_bkpf WITH KEY belnr = gt_bseg-belnr.
        IF sy-subrc EQ 0.
          gt_out-budat   = gt_bkpf-budat.
        ENDIF.
        CONCATENATE pa_gjahr '0' pa_monat  INTO gt_out-perio.
        gt_out-vrgar   = 'B'.
        gt_out-kndnr   = gt_ce48010_acct-kndnr.
        gt_out-bukrs   = gt_ce48010_acct-bukrs.
        gt_out-artnr   = gt_ce48010_acct-artnr.
        gt_out-werks   = gt_ce48010_acct-werks.
        gt_out-prctr   = gt_ce48010_acct-prctr.
        gt_out-gsber   = gt_ce48010_acct-gsber.
        gt_out-spart   = gt_ce48010_acct-spart.
        gt_out-matkl   = gt_ce48010_acct-matkl.
        gt_out-extwg   = gt_ce48010_acct-extwg.
        gt_out-wwprc   = gt_ce48010_acct-wwprc.
        gt_out-wwprr   = gt_ce48010_acct-wwprr.
        gt_out-wwprd   = gt_ce48010_acct-wwprd.
        gt_out-pswsl   = gt_bseg-pswsl.
        IF gt_bseg-shkzg EQ 'S'.
          gt_out-vv852   = gt_bseg-pswbt.
        ELSE.
          gt_out-vv852   = gt_bseg-pswbt * -1.
        ENDIF.
        READ TABLE gt_zccopa WITH KEY belnr = gt_bseg-belnr
                                      matnr = gt_ce48010_acct-artnr.
        IF sy-subrc EQ 0.
          DELETE gt_zccopa WHERE belnr EQ gt_bseg-belnr
                             AND matnr EQ gt_ce48010_acct-artnr.
          CONTINUE.
        ELSE.
          APPEND gt_out.
        ENDIF.
      ENDIF.
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
      PERFORM f_post_entries USING ''.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries  USING    fu_check.
  DATA : lt_ipdata    TYPE TABLE OF bapi_copa_data,
         lt_flist     TYPE TABLE OF bapi_copa_field,
         lt_ret       TYPE TABLE OF bapiret2 WITH HEADER LINE.

  DATA : lt_out  LIKE gt_out OCCURS 0 WITH HEADER LINE.
  DATA : lv_rec(6).

  lt_out[]  = gt_out[].
  IF fu_check IS INITIAL.
    DELETE lt_out WHERE check IS INITIAL.
  ENDIF.

  LOOP AT lt_out.
    lv_rec  = '000001'.
    PERFORM f_post_data TABLES lt_ipdata lt_flist lt_ret
                        USING:
      'KOKRS' '8010' lv_rec '' '',
      'BUDAT' lt_out-budat lv_rec '' '',
      'PERIO' lt_out-perio lv_rec '' '',
      'VRGAR' lt_out-vrgar lv_rec '' '',
      'KNDNR' lt_out-kndnr lv_rec '' '',
      'BUKRS' lt_out-bukrs lv_rec '' '',
      'ARTNR' lt_out-artnr lv_rec '' '',
      'WERKS' lt_out-werks lv_rec '' '',
      'PRCTR' lt_out-prctr lv_rec '' '',
      'GSBER' lt_out-gsber lv_rec '' '',
      'SPART' lt_out-spart lv_rec '' '',
      'MATKL' lt_out-matkl lv_rec '' '',
      'EXTWG' lt_out-extwg lv_rec '' '',
      'WWPRC' lt_out-wwprc lv_rec '' '',
      'WWPRR' lt_out-wwprr lv_rec '' '',
      'WWPRD' lt_out-wwprd lv_rec '' '',
      'WWPRD' lt_out-wwprd lv_rec '' '',
      'VV852' lt_out-vv852 lv_rec '1' lt_out-pswsl.

    CALL FUNCTION 'BAPI_COPAACTUALS_POSTCOSTDATA'
      EXPORTING
        operatingconcern = '8010'
        testrun          = space
      TABLES
        inputdata        = lt_ipdata
        fieldlist        = lt_flist
        return           = lt_ret.

    READ TABLE lt_ret WITH KEY type = 'E'.
    IF sy-subrc EQ 0.
      gt_status-belnr   = lt_out-belnr.
      gt_status-matnr   = lt_out-artnr.
      gt_status-message = lt_ret-message.
      APPEND gt_status.
    ELSE.
      READ TABLE lt_ret WITH KEY type = 'A'.
      IF sy-subrc EQ 0.
        gt_status-belnr   = lt_out-belnr.
        gt_status-matnr   = lt_out-artnr.
        gt_status-message = lt_ret-message.
        APPEND gt_status.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        gt_status-belnr   = lt_out-belnr.
        gt_status-matnr   = lt_out-artnr.
        gt_status-message = 'Success'.
        APPEND gt_status.

        gt_zccopa-bukrs   = pa_bukrs.
        gt_zccopa-gjahr   = pa_gjahr.
        gt_zccopa-belnr   = lt_out-belnr.
        gt_zccopa-matnr   = lt_out-artnr.
        gt_zccopa-zuser   = sy-uname.
        gt_zccopa-tglprs  = sy-datum.
        APPEND gt_zccopa.
      ENDIF.
    ENDIF.

    CLEAR: lt_ipdata, lt_ipdata[],
           lt_flist, lt_flist[],
           lt_ret, lt_ret[].
  ENDLOOP.

  SET PF-STATUS 'STANDARD'.

  IF gt_status[] IS NOT INITIAL.
    WRITE : / 'Hasil Proses Data Upload CO'.
    SKIP.
    WRITE : / 'Tanggal      : ', sy-datum,
            / 'Jam          : ', sy-uzeit,
            / 'User Id      : ', sy-uname.
    SKIP.
    WRITE:/ sy-uline(100).
    WRITE:/ sy-vline, 'DocumentNo',
            sy-vline, (12) 'Material',
            sy-vline, (68) 'Message',
            sy-vline.
    WRITE:/ sy-uline(100).

    LOOP AT gt_status.
      WRITE: / sy-vline, gt_status-belnr,
               sy-vline, (12) gt_status-matnr,
               sy-vline, (68) gt_status-message(68),
               sy-vline.
    ENDLOOP.

    WRITE:/ sy-uline(100).
  ENDIF.

  INSERT zccopa FROM TABLE gt_zccopa.
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
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .

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
      lv_mess = 'Processing must in same period'.
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
*&      Form  F_POST_DATA
*&---------------------------------------------------------------------*
FORM f_post_data  TABLES   ft_ipdata STRUCTURE bapi_copa_data
                           ft_flist STRUCTURE bapi_copa_field
                           ft_ret STRUCTURE bapiret2
                  USING    fu_fieldname fu_value
                           fu_rec fu_flag fu_waers.
  DATA : lwa_ipdata   LIKE LINE OF ft_ipdata,
         lwa_flist    LIKE LINE OF ft_flist.

  DATA: lv_value(50).

  CLEAR sy-subrc.

  CASE fu_flag.
    WHEN 1.
      WRITE fu_value TO lv_value CURRENCY fu_waers.
      WHILE sy-subrc EQ 0.
        REPLACE '.' WITH space INTO lv_value.
      ENDWHILE.
      CONDENSE lv_value NO-GAPS.
  ENDCASE.

  CLEAR: lwa_ipdata.
  lwa_ipdata-record_id = fu_rec.
  lwa_ipdata-fieldname = fu_fieldname.

  CASE fu_flag.
    WHEN 1.
      lwa_ipdata-value     = lv_value.
      lwa_ipdata-currency  = fu_waers.
    WHEN OTHERS.
      lwa_ipdata-value     = fu_value.
  ENDCASE.

  APPEND lwa_ipdata TO ft_ipdata.
  lwa_flist-fieldname  = lwa_ipdata-fieldname.
  APPEND lwa_flist TO ft_flist.
ENDFORM.                    " F_POST_DATA
