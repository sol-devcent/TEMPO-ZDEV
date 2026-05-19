*----------------------------------------------------------------------*
*   INCLUDE ZF_GSCABF01                                                *
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD handle_toolbar.
    DATA: ls_toolbar TYPE stb_button.

    " Separator
    CLEAR ls_toolbar.
    ls_toolbar-butn_type = 3.
    APPEND ls_toolbar TO e_object->mt_toolbar. CLEAR ls_toolbar.

    " Tombol Select All
    ls_toolbar-function = '&SALL'.
    ls_toolbar-icon     = icon_select_all.
    ls_toolbar-text     = 'Select All'.
    APPEND ls_toolbar TO e_object->mt_toolbar. CLEAR ls_toolbar.

    " Tombol Deselect All
    ls_toolbar-function = '&DSAL'.
    ls_toolbar-icon     = icon_deselect_all.
    ls_toolbar-text     = 'Deselect All'.
    APPEND ls_toolbar TO e_object->mt_toolbar. CLEAR ls_toolbar.

    " Separator
    CLEAR ls_toolbar.
    ls_toolbar-butn_type = 3.
    APPEND ls_toolbar TO e_object->mt_toolbar. CLEAR ls_toolbar.

    " Tombol Execute
    ls_toolbar-function = '&EXEC'.
    ls_toolbar-icon     = icon_execute_object.
    ls_toolbar-text     = 'Execute'.
    APPEND ls_toolbar TO e_object->mt_toolbar. CLEAR ls_toolbar.

    " Tombol Back
*    ls_toolbar-function = '&BACK'.
*    ls_toolbar-icon     = icon_arrow_left.
*    ls_toolbar-text     = 'Back'.
*    APPEND ls_toolbar TO e_object->mt_toolbar. CLEAR ls_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN '&SALL'.
        " Memilih semua baris secara visual
*        DATA: lt_rows TYPE lvc_t_row,
*              ls_row  TYPE lvc_s_row.
*        LOOP AT gt_clno TRANSPORTING NO FIELDS.
*          ls_row-index = sy-tabix.
*          APPEND ls_row TO lt_rows.
*        ENDLOOP.
*        g_grid->set_selected_rows( it_row_no = lt_rows ).
        PERFORM select_all_checkboxes USING 'X'.

      WHEN '&DSAL'.
        " Menghapus semua pilihan
*        CLEAR lt_rows.
*        g_grid->set_selected_rows( it_row_no = lt_rows ).
*        PERFORM deselect_all_checkboxes.
        PERFORM select_all_checkboxes USING ' '.

*      WHEN '&EXEC'.
*        " Logika proses Anda di sini
*        MESSAGE 'Proses Execute dijalankan' TYPE 'I'.
*        " Contoh: Ambil baris yang terpilih
*        g_grid->get_selected_rows( IMPORTING et_index_rows = lt_rows ).
        " ... lakukan loop pada lt_rows untuk proses data ...

      WHEN '&EXEC' OR '&BACK'.
        " Bersihkan objek agar tidak CNTL_ERROR saat panggil ulang
        g_grid->free( ).
        g_custom_container->free( ).
        FREE: g_grid, g_custom_container.
        SET SCREEN 0. LEAVE SCREEN.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  SELECT bschl shkzg koart
    FROM tbsl
    INTO TABLE gt_tbsl.

  SELECT SINGLE city1 bezei
    FROM tvbur AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
                    JOIN tvkbt AS c ON a~vkbur EQ c~vkbur
    INTO (gv_city1, gv_bezei)
    WHERE a~vkbur EQ pa_gsber AND
          spras   EQ sy-langu.

  SELECT SINGLE fname petugas1 jabat1 petugas2 jabat2
    FROM zfgstt
    INTO (gv_fname, p_jabat1, gv_jabat1, p_jabat2, gv_jabat2)
    WHERE gsber   EQ pa_gsber AND
          ztype   EQ pa_ztype AND
          zform   EQ 'GS'.

  SELECT SINGLE butxt
    FROM t001
    INTO gv_butxt
    WHERE bukrs EQ pa_bukrs.

  SELECT SINGLE flag
    FROM zfgsflagtype
    INTO gv_flag
    WHERE bukrs     = pa_bukrs
      AND ztype     = pa_ztype
      AND zsubtype  = pa_subty.

ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: lt_zfgstype LIKE gt_zfgstype OCCURS 0 WITH HEADER LINE,
        lt_bkpf     LIKE gt_bsis OCCURS 0 WITH HEADER LINE,
        lt_bsis     LIKE gt_bsis OCCURS 0 WITH HEADER LINE,
        lt_zfgscab  LIKE gt_zfgscab OCCURS 0 WITH HEADER LINE,
        lr_budat    TYPE RANGE OF budat,
        lr_line     LIKE LINE OF lr_budat.

  CONCATENATE pa_spmon '01' INTO lr_line-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lr_line-low
    IMPORTING
      last_day_of_month = lr_line-high.
  lr_line-sign    = 'I'.
  lr_line-option  = 'BT'.
  APPEND lr_line TO lr_budat.

  CASE 'X'.
    WHEN radio1.
      SELECT ztype zsubtype hkont
        FROM zfgstype
        INTO TABLE gt_zfgstype
        WHERE ztype     EQ pa_ztype AND
              zsubtype  EQ pa_subty.

      gv_bschl = '40'.

      lt_zfgstype[] = gt_zfgstype[].
      SORT lt_zfgstype BY hkont.
      DELETE ADJACENT DUPLICATES FROM lt_zfgstype COMPARING hkont.
      IF lt_zfgstype[] IS NOT INITIAL.
        SELECT bukrs hkont augdt augbl zuonr gjahr belnr buzei
               budat bldat waers xblnr blart bschl shkzg gsber
               wrbtr sgtxt vbund
          FROM bsis
          INTO TABLE gt_bsis
          FOR ALL ENTRIES IN lt_zfgstype
          WHERE bukrs EQ pa_bukrs          AND
                hkont EQ lt_zfgstype-hkont AND
                belnr IN so_belnr          AND
                budat IN lr_budat          AND
                bschl EQ gv_bschl          AND
                gsber EQ pa_gsber.

        IF sy-subrc EQ 0.
          lt_bsis[] = gt_bsis[].
          SORT lt_bsis BY vbund.
          DELETE ADJACENT DUPLICATES FROM lt_bsis COMPARING vbund.
          IF lt_bsis[] IS NOT INITIAL.
            SELECT kunnr vbund
              FROM zfgskunnr
              INTO CORRESPONDING FIELDS OF TABLE gt_kna1
              FOR ALL ENTRIES IN lt_bsis
              WHERE vbund EQ lt_bsis-vbund.
          ENDIF.
          lt_bkpf[] = gt_bsis[].
          SORT lt_bkpf BY bukrs belnr gjahr.
          DELETE ADJACENT DUPLICATES FROM lt_bkpf COMPARING bukrs belnr gjahr.
          IF lt_bkpf[] IS NOT INITIAL.
            SELECT bukrs belnr gjahr stblg
              FROM bkpf
              INTO TABLE gt_bkpf
              FOR ALL ENTRIES IN lt_bkpf
              WHERE bukrs EQ lt_bkpf-bukrs AND
                    belnr EQ lt_bkpf-belnr AND
                    gjahr EQ lt_bkpf-gjahr.
          ENDIF.
        ENDIF.
      ENDIF.

      SORT gt_bsis BY bukrs belnr gjahr.
      SORT gt_bkpf BY bukrs belnr gjahr.
      LOOP AT gt_bsis.
        READ TABLE gt_bkpf WITH KEY bukrs = gt_bsis-bukrs
                                    belnr = gt_bsis-belnr
                                    gjahr = gt_bsis-gjahr
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          IF gt_bkpf-stblg IS NOT INITIAL.
            DELETE gt_bsis.
          ENDIF.
        ENDIF.
      ENDLOOP.

      SELECT bukrs gsber belnr gjahr buzei budat bldat xblnr zuonr
             sgtxt zgsno ztype zsubtype vbund kunnr waers shkzg wrbtr
             hkont txt1 txt2 txt3 txt4 belnrgs usergs tglgs jamgs belnrrevgs
             userrevgs tglrevgs jamrevgs belnrpost gjahrpost userpost postdt
             tglpost jampost belnrrev userrev tglrev
        FROM zfgscab
        INTO CORRESPONDING FIELDS OF TABLE gt_zfgscab
        WHERE bukrs      EQ pa_bukrs AND
              gsber      EQ pa_gsber AND
              belnr      IN so_belnr AND
              belnrgs    NE space    AND
              belnrrevgs EQ space.

    WHEN radio2.
      SELECT bukrs gsber belnr gjahr buzei budat bldat xblnr zuonr
             sgtxt zgsno ztype zsubtype vbund kunnr waers shkzg wrbtr
             hkont txt1 txt2 txt3 txt4 belnrgs usergs tglgs jamgs belnrrevgs
             userrevgs tglrevgs jamrevgs belnrpost gjahrpost userpost postdt
             tglpost jampost belnrrev userrev tglrev kuntm perfr perto
        FROM zfgscab
        INTO CORRESPONDING FIELDS OF TABLE gt_zfgscab
        WHERE bukrs      EQ pa_bukrs AND
              gsber      EQ pa_gsber AND
              belnr      IN so_belnr AND
              budat      IN lr_budat AND
              ztype      EQ pa_ztype AND
              zsubtype   EQ pa_subty AND
              belnrrevgs EQ space    AND
              belnrpost  EQ space    AND
              belnrdn    EQ space.

      IF gt_zfgscab[] IS NOT INITIAL.
        SELECT * INTO TABLE gt_zfgscab_cl
          FROM zfgscab_cl FOR ALL ENTRIES IN gt_zfgscab
          WHERE belnr = gt_zfgscab-belnrgs
            AND gjahr = gt_zfgscab-gjahr
            AND zgsno = gt_zfgscab-zgsno.

        SELECT * INTO TABLE gt_zfgscab_add
          FROM zfgscab_add FOR ALL ENTRIES IN gt_zfgscab
          WHERE bukrs = gt_zfgscab-bukrs AND
                gsber = gt_zfgscab-gsber AND
                belnr = gt_zfgscab-belnr AND
                gjahr = gt_zfgscab-gjahr AND
                zgsno = gt_zfgscab-zgsno.

        lt_zfgscab[] = gt_zfgscab[].
        SORT lt_zfgscab BY vbund.
        DELETE ADJACENT DUPLICATES FROM lt_bsis COMPARING vbund.
        IF lt_zfgscab[] IS NOT INITIAL.
          SELECT kunnr vbund
            FROM zfgskunnr
            INTO CORRESPONDING FIELDS OF TABLE gt_kna1
            FOR ALL ENTRIES IN lt_zfgscab
            WHERE vbund EQ lt_zfgscab-vbund.
        ENDIF.
      ENDIF.

    WHEN radio7.
      SELECT bukrs gsber belnr gjahr buzei budat bldat xblnr zuonr
             sgtxt zgsno ztype zsubtype vbund kunnr waers shkzg wrbtr
             hkont txt1 txt2 txt3 txt4 belnrgs usergs tglgs jamgs belnrrevgs
             userrevgs tglrevgs jamrevgs belnrpost gjahrpost userpost postdt
             tglpost jampost belnrrev userrev tglrev
        FROM zfgscab
        INTO CORRESPONDING FIELDS OF TABLE gt_zfgscab
        WHERE bukrs      EQ pa_bukrs AND
              gsber      EQ pa_gsber AND
              belnrgs    IN so_belnr AND
              budat      IN lr_budat AND
              ztype      EQ pa_ztype AND
              zsubtype   EQ pa_subty AND
              belnrpost  EQ space    AND
              belnrdn    EQ space.

    WHEN radio3.
      SELECT bukrs gsber belnr gjahr buzei budat bldat xblnr zuonr
             sgtxt zgsno ztype zsubtype vbund kunnr waers shkzg wrbtr
             hkont txt1 txt2 txt3 txt4 belnrgs usergs tglgs jamgs belnrrevgs
             userrevgs tglrevgs jamrevgs belnrpost gjahrpost userpost postdt
             tglpost jampost belnrrev userrev tglrev belnrdn belnrrevdn xref2
             perfr perto
        FROM zfgscab
        INTO CORRESPONDING FIELDS OF TABLE gt_zfgscab
        WHERE bukrs      EQ pa_bukrs AND
              gsber      EQ pa_gsber AND
              budat      IN lr_budat AND
              ztype      EQ pa_ztype AND
              zsubtype   IN so_subty.
  ENDCASE.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  CASE 'X'.
    WHEN radio1.
      PERFORM f_alv TABLES gt_input
                    USING ''.
    WHEN radio2.
      PERFORM f_alv TABLES gt_input
                    USING ''.
    WHEN radio7.
      PERFORM f_alv TABLES gt_zfgscab
                    USING ''.
    WHEN radio3.
      PERFORM f_alv TABLES gt_zfgscab
                    USING ''.
  ENDCASE.
ENDFORM.                    "F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report
           USING fu_proc.
  DATA: lv_func(22).

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report
                              USING   fu_proc.
  PERFORM f_build_layout      USING   d_layout fu_proc.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  lv_func    = 'REUSE_ALV_LIST_DISPLAY'.

  CALL FUNCTION lv_func
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
ENDFORM.                    "F_ALV

*---------------------------------------------------------------------*
*       FORM F_FIELDCAT
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report
                      USING fu_proc.
  REFRESH: t_alv_fieldcat.

  CASE 'X'.
    WHEN radio1 OR radio2.
      IF fu_proc IS INITIAL.
        PERFORM f_fieldcatg USING ft_report :
          'ZTYPE' 'ZFGSCAB' 'ZTYPE' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'ZSUBTYPE' 'ZFGSCAB' 'ZSUBTYPE' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'BELNR' 'BSIS' 'BELNR' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
          'BUZEI' 'BSIS' 'BUZEI' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'BUDAT' 'BSIS' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'ZUONR' 'BSIS' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'VBUND' 'BSIS' 'VBUND' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'WAERS' 'BSIS' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'WRBTR' 'BSIS' 'WRBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' ''.
        PERFORM f_fieldcatg USING ft_report :
          'KUNTM' 'KNA1' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'ZDESC' 'ZFGSTMMT_CUST' 'ZDESC' '' '' '' '' '' '' '' '' '' '' '' '' ''.
        PERFORM f_fieldcatg USING ft_report :
          'SGTXT' 'BSIS' 'SGTXT' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'TXT1' 'ZFGSCAB' 'TXT1' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
          'TXT2' 'ZFGSCAB' 'TXT2' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
          'TXT3' 'ZFGSCAB' 'TXT3' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
          'TXT4' 'ZFGSCAB' 'TXT4' '' '' '' '' '' '' '' '' '' '' '' 'X' '',
          'PERFR' 'ZFGSCAB' 'PERFR' '' '' 'Promo from' '' '' '' '' '' '' '' '' 'X' '',
          'PERTO' 'ZFGSCAB' 'PERTO' '' '' 'Promo to' '' '' '' '' '' '' '' '' 'X' ''.
      ELSE.
        PERFORM f_fieldcatg USING ft_report :
          'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '' '',
          'BLART' 'BKPF' 'BLART' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'XBLNR' 'BKPF' 'XBLNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'BSCHL' 'BSEG' 'BSCHL' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'GSBER' 'BSEG' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'ACCOUNT' 'BSEG' 'HKONT' '' '' 'Account' '' '' '' '' '' '' '' '' '' '',
          'DESCRIPTION' '' '' '' '30' 'Description' '' '' '' '' '' '' '' '' '' '',
          'WRBTR' 'BSEG' 'WRBTR' '' '' '' 'X' '' '' 'IDR' '' '' '' '' '' ''.
      ENDIF.

    WHEN radio7.
      PERFORM f_fieldcatg USING ft_report :
        'BUKRS' 'ZFGSCAB' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'ZFGSCAB' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR' 'ZFGSCAB' 'BELNR' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
        'ZGSNO' 'ZFGSCAB' 'ZGSNO' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNRGS' 'ZFGSCAB' 'BELNRGS' '' '12' 'Doc.Post G/S' '' 'X' '' '' '' '' '' '' '' ''.

    WHEN radio3.
      PERFORM f_fieldcatg USING ft_report :
        'ZGSNO' 'ZFGSCAB' 'ZGSNO' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUDAT' 'BSIS' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR' 'BSIS' 'BELNR' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
        'ZUONR' 'BSIS' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VBUND' 'BSIS' 'VBUND' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'SGTXT' 'BSIS' 'SGTXT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'WRBTR' 'BSIS' 'WRBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' '',
        'BELNRGS' 'ZFGSCAB' 'BELNRGS' '' '' 'Doc.No GS' '' '' '' '' '' '' '' '' '' '',
        'POSTDT' 'ZFGSCAB' 'POSTDT' '' '' 'TglPost GS' '' '' '' '' '' '' '' '' '' '',
        'BELNRREVGS' 'ZFGSCAB' 'BELNRREVGS' '' '17' 'Doc.No GS Rev.' '' '' '' '' ''
        '' '' '' '' '',
        'TGLREVGS' 'ZFGSCAB' 'TGLREVGS' '' '17' 'Tgl.GS Rev.' '' '' '' '' ''
        '' '' '' '' '',
        'BUKRS' 'BSIS' 'BUKRS' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'GSBER' 'BSIS' 'GSBER' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'BSIS' 'GJAHR' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUZEI' 'BSIS' 'BUZEI' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'BLDAT' 'BSIS' 'BLDAT' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZTYPE' 'ZFGSCAB' 'ZTYPE' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZSUBTYPE' 'ZFGSCAB' 'ZSUBTYPE' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'ZFGSCAB' 'KUNNR' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'WAERS' 'BSIS' 'WAERS' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'SHKZG' 'BSIS' 'SHKZG' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'HKONT' 'BSIS' 'HKONT' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'TXT1' 'ZFGSCAB' 'TXT1' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'TXT2' 'ZFGSCAB' 'TXT2' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'TXT3' 'ZFGSCAB' 'TXT3' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'TXT4' 'ZFGSCAB' 'TXT4' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'PERFR' 'ZFGSCAB' 'PERFR' 'X' '' 'Promo from' '' '' '' '' '' '' '' '' '' '',
        'PERTO' 'ZFGSCAB' 'PERTO' 'X' '' 'Promo to' '' '' '' '' '' '' '' '' '' '',
        'BELNRPOST' 'ZFGSCAB' 'BELNRPOST' 'X' '' 'Doc.No Post' '' '' '' '' '' '' '' '' '' '',
        'XREF2' 'ZFGSCAB' 'XREF2' 'X' '' 'DN Number' '' '' '' '' '' '' '' '' '' '',
        'GJAHRPOST' 'ZFGSCAB' 'GJAHRPOST' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'USERPOST' 'ZFGSCAB' 'USERPOST' 'X' '' 'Username Post' '' '' '' '' '' '' '' '' '' '',
        'JAMPOST' 'ZFGSCAB' 'JAMPOST' 'X' '' 'JamPost' '' '' '' '' '' '' '' '' '' '',
        'BELNRREV' 'ZFGSCAB' 'BELNRREV' 'X' '' 'Doc.No Reverse' '' '' '' '' '' '' '' '' '' '',
        'USERREV' 'ZFGSCAB' 'USERREV' 'X' '' 'UserName Reverse' '' '' '' '' '' '' '' '' '' '',
        'TGLREV' 'ZFGSCAB' 'TGLREV' 'X' '' 'Tanggal Reverse' '' '' '' '' '' '' '' '' '' '',
        'BELNRDN' 'ZFGSCAB' 'BELNRDN' '' '' 'DN Number' '' '' '' '' '' '' '' '' '' '',
        'TGLPOST' 'ZFGSCAB' 'TGLPOST' 'X' '' 'TglPost' '' '' '' '' '' '' '' '' '' '',
        'BELNRREVDN' 'ZFGSCAB' 'BELNRREVDN' '' '17' 'DN Number Rev' '' '' '' '' '' '' '' '' '' ''.
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

  IF fu_types = 'GT_CLNO'.
    APPEND ld_fieldcat TO gt_alv_fieldcat.
    CLEAR ld_fieldcat.
  ELSE.
    APPEND ld_fieldcat TO t_alv_fieldcat.
    CLEAR ld_fieldcat.
  ENDIF.
ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG_LVC
*&---------------------------------------------------------------------*
FORM f_fieldcatg_lvc USING VALUE(fu_types)
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
                           VALUE(fu_edit)
                           VALUE(fu_emphasize).

  DATA: ld_fieldcat  TYPE  lvc_s_fcat.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_table         = fu_reftb.
  ld_fieldcat-ref_field         = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-scrtext_l         = fu_fltxt.
  ld_fieldcat-scrtext_m         = fu_fltxt.
  ld_fieldcat-scrtext_s         = fu_fltxt.
  ld_fieldcat-reptext           = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_o        = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-edit              = fu_edit.
  ld_fieldcat-emphasize         = fu_emphasize.

  APPEND ld_fieldcat TO gt_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG_LVC

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
FORM f_build_layout USING fu_layout TYPE slis_layout_alv
                          fu_proc.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
  IF radio1 IS NOT INITIAL.
    IF fu_proc IS INITIAL.
      fu_layout-box_fieldname      = 'CHECK'.
    ENDIF.
  ELSEIF radio2 IS NOT INITIAL OR
    radio7 IS NOT INITIAL.
    fu_layout-box_fieldname      = 'CHECK'.
  ENDIF.
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
    WHEN radio1.
      CLEAR ld_sort.
      ld_sort-fieldname = 'BELNR'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
      CLEAR ld_sort.
      ld_sort-fieldname = 'BUZEI'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
    WHEN radio3.
      CLEAR ld_sort.
      ld_sort-fieldname = 'ZGSNO'.
      ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
      APPEND ld_sort TO fu_sort.
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
  CLEAR: gt_detail, gt_detail[], gt_header, gt_header[],
         gt_vdata, gt_vdata[], gt_gsno, gt_gsno[].
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
    WHEN radio1.
      IF gv_status IS INITIAL.
        SET PF-STATUS 'TOSIMULATE'.
      ELSE.
        SET PF-STATUS 'TOEXECUTE'.
      ENDIF.
    WHEN radio2.
      SET PF-STATUS 'TOEXECUTE1'.
    WHEN radio7.
      SET PF-STATUS 'TOEXECUTE2'.
    WHEN radio3.
      SET PF-STATUS 'STANDARD'.
  ENDCASE.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS2
*---------------------------------------------------------------------*
FORM f_set_pf_status2 USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'CLNR'.
ENDFORM.                    " F_SET_PF_STATUS2

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
  CASE 'X'.
    WHEN radio1.
      SORT gt_bsis BY bukrs gsber belnr gjahr buzei.
      SORT gt_zfgscab BY bukrs gsber belnr gjahr buzei.
      LOOP AT gt_bsis.
        READ TABLE gt_zfgscab WITH KEY bukrs = gt_bsis-bukrs
                                       gsber = gt_bsis-gsber
                                       belnr = gt_bsis-belnr
                                       gjahr = gt_bsis-gjahr
                                       buzei = gt_bsis-buzei
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          CONTINUE.
        ELSE.
          gt_input-ztype      = pa_ztype.
          gt_input-zsubtype   = pa_subty.
          gt_input-belnr      = gt_bsis-belnr.
          gt_input-buzei      = gt_bsis-buzei.
          gt_input-budat      = gt_bsis-budat.
          gt_input-xblnr      = gt_bsis-xblnr.
          gt_input-zuonr      = gt_bsis-zuonr.
          gt_input-vbund      = gt_bsis-vbund.
          READ TABLE gt_kna1 WITH KEY vbund = gt_bsis-vbund.
          IF sy-subrc EQ 0.
            gt_input-kunnr = gt_kna1-kunnr.
          ENDIF.
          gt_input-waers      = gt_bsis-waers.
          IF gt_bsis-shkzg EQ 'H'.
            gt_input-wrbtr      = gt_bsis-wrbtr * -1.
          ELSE.
            gt_input-wrbtr      = gt_bsis-wrbtr.
          ENDIF.
          gt_input-sgtxt      = gt_bsis-sgtxt.

          gt_input-bukrs      = gt_bsis-bukrs.
          gt_input-gsber      = gt_bsis-gsber.
          gt_input-gjahr      = gt_bsis-gjahr.
          APPEND gt_input.
        ENDIF.
      ENDLOOP.

    WHEN radio2.
      LOOP AT gt_zfgscab.
        gt_input-ztype      = gt_zfgscab-ztype.
        gt_input-zsubtype   = gt_zfgscab-zsubtype.
        gt_input-belnr      = gt_zfgscab-belnr.
        gt_input-buzei      = gt_zfgscab-buzei.
        gt_input-budat      = gt_zfgscab-budat.
        gt_input-xblnr      = gt_zfgscab-xblnr.
        gt_input-zuonr      = gt_zfgscab-zuonr.
        gt_input-vbund      = gt_zfgscab-vbund.
        READ TABLE gt_kna1 WITH KEY vbund = gt_zfgscab-vbund.
        IF sy-subrc EQ 0.
          gt_input-kunnr = gt_kna1-kunnr.
        ENDIF.
        gt_input-waers      = gt_zfgscab-waers.
        IF gt_zfgscab-shkzg EQ 'H'.
          gt_input-wrbtr      = gt_zfgscab-wrbtr * -1.
        ELSE.
          gt_input-wrbtr      = gt_zfgscab-wrbtr.
        ENDIF.
        gt_input-sgtxt      = gt_zfgscab-sgtxt.
        gt_input-txt1       = gt_zfgscab-txt1.
        gt_input-txt2       = gt_zfgscab-txt2.
        gt_input-txt3       = gt_zfgscab-txt3.
        gt_input-txt4       = gt_zfgscab-txt4.
        gt_input-kuntm      = gt_zfgscab-kuntm.
        gt_input-perfr      = gt_zfgscab-perfr.
        gt_input-perto      = gt_zfgscab-perto.
        gt_input-kdgrp      = VALUE #( gt_zfgscab_cl[ belnr = gt_zfgscab-belnrgs
                                                      gjahr = gt_zfgscab-gjahr
                                                      zgsno = gt_zfgscab-zgsno ]-kdgrp OPTIONAL ).

        SELECT SINGLE zdesc
          FROM zfgstmmt_cust
          INTO gt_input-zdesc
          WHERE bukrs = pa_bukrs
            AND vkbur = pa_gsber
            AND kunnr = gt_zfgscab-kuntm.

        gt_input-postdt     = gt_zfgscab-postdt.

        CLEAR gt_zfgscab_add.
        READ TABLE gt_zfgscab_add WITH KEY bukrs = gt_zfgscab-bukrs
                                           gsber = gt_zfgscab-gsber
                                           belnr = gt_zfgscab-belnr
                                           gjahr = gt_zfgscab-gjahr
                                           zgsno = gt_zfgscab-zgsno.
        gt_input-promo = gt_zfgscab_add-promonr.
        gt_input-actde = gt_zfgscab_add-actdesc.
        gt_input-cust  = gt_zfgscab_add-kunnr.
        gt_input-vat   = gt_zfgscab_add-vat.
        gt_input-pph   = gt_zfgscab_add-pph.
        gt_input-fpnr  = gt_zfgscab_add-fpnr.
        gt_input-fpdat = gt_zfgscab_add-fpdat.
        gt_input-filec = gt_zfgscab_add-filecabang.

        APPEND gt_input.
      ENDLOOP.

    WHEN radio3.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread   LIKE dynpread OCCURS 0 WITH HEADER LINE,
        wa_input      LIKE gt_input,
        ffield(20),
        fvalue(20),
        lv_type       TYPE ztype_gs,
        lv_subty      TYPE zsubtype,
        lv_belnr      TYPE belnr_d,
        lv_buzei      TYPE buzei,
        lv_subrc      TYPE sy-subrc,
        lv_error(100),
        lv_spmon      TYPE spmon,
        lv_valid      TYPE c.

  GET CURSOR FIELD ffield VALUE fvalue.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&IC1'.
      IF ffield EQ 'GT_INPUT-BELNR' OR
        ffield EQ 'GT_ZFGSCAB-BELNR' OR
        ffield EQ 'GT_ZFGSCAB-BELNRGS'.
        SET PARAMETER ID 'BLN' FIELD fvalue.
        SET PARAMETER ID 'BUK' FIELD pa_bukrs.
        SET PARAMETER ID 'GJR' FIELD pa_spmon(4).
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ELSE.
        CASE 'X'.
          WHEN radio3.
          WHEN OTHERS.
            READ TABLE gt_input INDEX fu_selfield-tabindex INTO wa_input.
            pa_ztyp1  = pa_ztype.
            pa_vbund  = wa_input-vbund.
            pa_subt1  = wa_input-zsubtype.
            pa_text1  = wa_input-txt1.
            pa_text2  = wa_input-txt2.
            pa_text3  = wa_input-txt3.
            pa_text4  = wa_input-txt4.
            pa_promo  = wa_input-promo.
            pa_actde  = wa_input-actde.
            pa_cust   = wa_input-cust.
            pa_vat    = wa_input-vat.
            pa_pph    = wa_input-pph.
            pa_fpnr   = wa_input-fpnr.
            pa_fpdat  = wa_input-fpdat.
            pa_filec  = wa_input-filec.
            pa_kunnr  = wa_input-kuntm.
            gv_name1  = wa_input-zdesc.
            pa_prd1   = wa_input-perfr.
            pa_prd2   = wa_input-perto.
            gv_kdgrp = pa_kdgrp = wa_input-kdgrp.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = wa_input-belnr
              IMPORTING
                output = gv_belnr.

            CALL SELECTION-SCREEN 9000 STARTING AT 10 10.

            IF sy-subrc = 0.
              IF fvalue = '15' OR fvalue = '75'.
                PERFORM f_popup_cust.
              ENDIF.
            ENDIF.

            gt_input-zsubtype = pa_subt1.
            gt_input-txt1     = pa_text1.
            gt_input-txt2     = pa_text2.
            gt_input-txt3     = pa_text3.
            gt_input-txt4     = pa_text4.
            gt_input-promo    = pa_promo.
            gt_input-actde    = pa_actde.
            gt_input-cust     = pa_cust.
            gt_input-vat      = pa_vat.
            gt_input-pph      = pa_pph.
            gt_input-fpnr     = pa_fpnr.
            gt_input-fpdat    = pa_fpdat.
            gt_input-filec    = pa_filec.
            gt_input-kuntm    = pa_kunnr.
            gt_input-perfr    = pa_prd1.
            gt_input-perto    = pa_prd2.
            gt_input-kdgrp    = pa_kdgrp.

            SELECT SINGLE zdesc
              FROM zfgstmmt_cust
              INTO gt_input-zdesc
              WHERE bukrs = pa_bukrs
                AND vkbur = pa_gsber
                AND kunnr = pa_kunnr.

            READ TABLE gt_subtype WITH KEY zsubtype = gt_input-zsubtype.
            IF sy-subrc EQ 0.
              IF gt_subtype-loekz IS INITIAL.
                MODIFY gt_input TRANSPORTING zsubtype
                                WHERE belnr EQ wa_input-belnr.
              ELSE.
                CONCATENATE 'Sub Type' gt_input-zsubtype 'not active' INTO lv_error
                SEPARATED BY space.
                MESSAGE e000(zab) WITH lv_error.
              ENDIF.
            ELSE.
              CONCATENATE 'Sub Type' gt_input-zsubtype 'not found' INTO lv_error
              SEPARATED BY space.
              MESSAGE e000(zab) WITH lv_error.
            ENDIF.

            MODIFY gt_input TRANSPORTING txt1 txt2 txt3 txt4 promo actde cust vat
                                         pph fpnr fpdat filec kuntm zdesc perfr perto kdgrp
              WHERE belnr EQ wa_input-belnr AND
                    buzei EQ wa_input-buzei.

            CLEAR : gt_input, gt_temp[].

            gt_temp[] = gt_input[].
            fu_selfield-refresh  = 'X'.

*            PERFORM f_alv TABLES gt_input
*                          USING ''.
*            LEAVE TO SCREEN 0.
        ENDCASE.
      ENDIF.

    WHEN '&REV'.
      LOOP AT gt_zfgscab WHERE check EQ 'X'.
        PERFORM f_reverse USING gt_zfgscab-belnr gt_zfgscab-belnrgs.
      ENDLOOP.
      LEAVE TO SCREEN 0.

    WHEN '&DEL'.
      PERFORM f_delete_data.
      PERFORM f_alv TABLES gt_input
                    USING ''.
      LEAVE TO SCREEN 0.

    WHEN '&LOG'.
      CALL SCREEN 500 STARTING AT 10 10 ENDING AT 132 22.

    WHEN '&SIM'.
      PERFORM f_validasi_keterangan CHANGING lv_subrc.
      IF lv_subrc IS INITIAL.
        PERFORM f_post_entries USING fu_ucomm
                               CHANGING lv_subrc lv_spmon.

        CHECK lv_subrc EQ 0.

        PERFORM f_simulate.

        gv_status = 1.
        PERFORM f_alv TABLES gt_post
                      USING 'SIMULATE'.
        gv_status = 0.
        LEAVE TO SCREEN 0.
      ELSE.
        CASE lv_subrc.
          WHEN 1.
            MESSAGE e000(zab) WITH 'Keterangan harus diisi'.
          WHEN 2.
            MESSAGE e000(zab) WITH 'Customer TMMT harus diisi'.
        ENDCASE.
      ENDIF.

    WHEN '&PREV'.
      IF gt_error[] IS INITIAL.
        PERFORM f_post_entries USING fu_ucomm
                               CHANGING lv_subrc lv_spmon.

        CHECK lv_subrc EQ 0.

        PERFORM f_print_form USING gv_fname fu_ucomm
                             CHANGING lv_subrc.
      ELSE.
        MESSAGE e000(zab) WITH 'There is still incorrect data'.
      ENDIF.

    WHEN '&POS'.
      IF gt_error[] IS INITIAL.
        PERFORM f_post_entries USING fu_ucomm
                               CHANGING lv_subrc lv_spmon.

        CHECK lv_subrc EQ 0.

        PERFORM f_print_form USING gv_fname fu_ucomm
                             CHANGING lv_subrc.
      ELSE.
        MESSAGE e000(zab) WITH 'There is still incorrect data'.
      ENDIF.

      CHECK lv_subrc EQ 0.

      CASE 'X'.
        WHEN radio1.
          PERFORM f_save_data USING lv_spmon.
          PERFORM f_document_post.
        WHEN radio2.
          PERFORM f_update_data.
      ENDCASE.
  ENDCASE.

  PERFORM f_unlock_table USING lv_spmon.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries USING fu_ucomm
                    CHANGING fc_subrc fc_spmon.

  DATA: lwa_zfgs  LIKE gt_zfgsaccgs,
        lt_header LIKE gt_input OCCURS 0 WITH HEADER LINE,
        lt_kna1   LIKE gt_kna1 OCCURS 0 WITH HEADER LINE,
        lt_input  LIKE gt_input OCCURS 0 WITH HEADER LINE.

  DATA: lv_buzei TYPE buzei,
        lv_nomor TYPE znomor2,
        lv_lines TYPE i.

  PERFORM f_free_memory.

  PERFORM f_modify_input_data TABLES lt_header.

  DESCRIBE TABLE lt_header LINES lv_lines.

  IF lv_lines EQ 1.

    READ TABLE lt_header INDEX 1.

*    PERFORM f_get_gs_no USING pa_spmon
*                        CHANGING fc_subrc lv_nomor.

    CASE fu_ucomm.
      WHEN '&POS'.
        IF gt_temp[] IS NOT INITIAL.
          CLEAR gt_input[].
          gt_input[] = gt_temp[].
        ENDIF.

        fc_spmon  = pa_budat(6).
        PERFORM f_get_gs_no USING fc_spmon
                            CHANGING fc_subrc lv_nomor.
      WHEN '&PREV'.
        fc_spmon  = pa_budat(6).
        PERFORM f_get_gs_no USING fc_spmon
                            CHANGING fc_subrc lv_nomor.
      WHEN '&SIM'.
        IF gt_temp[] IS NOT INITIAL.
          CLEAR gt_input[].
          gt_input[] = gt_temp[].
        ENDIF.
        READ TABLE gt_input WITH KEY check = 'X'.

        PERFORM f_get_zfgsaccgs USING lt_header-zsubtype
                                CHANGING lwa_zfgs.

        IF lwa_zfgs IS NOT INITIAL.
          pa_xblnr  = lt_header-xblnr.
          lv_nomor  = lv_nomor - 1.
          CONCATENATE gv_zgsno lv_nomor INTO pa_bktxt.
          CALL SELECTION-SCREEN 9002 STARTING AT 10 10.
          IF sy-subrc EQ 0.

            fc_spmon  = pa_budat(6).
            PERFORM f_get_gs_no USING fc_spmon
                                CHANGING fc_subrc lv_nomor.

            PERFORM f_get_header USING lwa_zfgs-blart
                                 CHANGING headgs.
          ELSE.
            fc_subrc  = 5.
          ENDIF.
        ELSE.
          PERFORM f_unlock_table USING fc_spmon.
          fc_subrc  = 9.
        ENDIF.
    ENDCASE.

    IF fc_subrc EQ 0.
      SORT gt_input BY belnr buzei.
      SORT gt_bsis BY belnr buzei.
      SORT gt_gsno BY belnr.

      lt_input[]  = gt_input[].
      SORT lt_input BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_input COMPARING kunnr.
      IF lt_input[] IS NOT INITIAL.
        SELECT kunnr name1
          FROM kna1
          INTO CORRESPONDING FIELDS OF TABLE lt_kna1
          FOR ALL ENTRIES IN lt_input
          WHERE kunnr EQ lt_input-kunnr.
      ENDIF.

      CLEAR: gt_post, gt_post[], gt_save, gt_save[].
      LOOP AT gt_input WHERE check EQ 'X'.
        CASE fu_ucomm.
          WHEN '&PREV'.
          WHEN OTHERS.
            PERFORM f_move_to_save_data.
            PERFORM f_move_to_post_data TABLES lt_kna1
                                        USING gt_input lwa_zfgs
                                        CHANGING lv_buzei.
        ENDCASE.
      ENDLOOP.
    ELSE.
      IF fc_subrc EQ 9.
        CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
          EXPORTING
            popup_title  = 'Error message'
            message_text = 'Sub Type not maintained'.
      ELSEIF fc_subrc EQ 5.
      ELSE.
        CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
          EXPORTING
            popup_title  = 'Error message'
            message_text = 'Nomor Giro Sentral Cabang not maintained'.
      ENDIF.
    ENDIF.
  ELSE.
    fc_subrc  = 8.
    CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
      EXPORTING
        popup_title  = 'Error message'
        message_text = 'There are different Subtype/Reference'.
  ENDIF.
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
  CASE 'X'.
    WHEN radio1.
      LOOP AT SCREEN.
        IF screen-group1 = 'SU2'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio2.
      LOOP AT SCREEN.
        IF screen-group1 = 'SU2'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio7.
      LOOP AT SCREEN.
        IF screen-group1 = 'SU2'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio3.
      LOOP AT SCREEN.
        IF screen-group1 = 'BEL'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'SU1'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.

  IF sy-dynnr = '9000'.
    LOOP AT SCREEN.
      IF pa_subt1 EQ '21' OR pa_subt1 EQ '61'.
        IF screen-group1 = 'SUB'.
          screen-input  = 0.
          MODIFY SCREEN.
        ENDIF.
      ELSE.
        IF screen-group1 = 'SUB'.
          screen-input  = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.

      IF pa_subt1 EQ '21' OR pa_subt1 EQ '61'.
        IF screen-group1 = 'PT1' OR
           screen-group1 = 'PT2' OR
           screen-group1 = 'PT3' OR
           screen-group1 = 'PT4'.
          screen-active  = 0.
          MODIFY SCREEN.
        ENDIF.
      ELSE.
        IF screen-group1 = 'PRO' OR
           screen-group1 = 'ACT' OR
           screen-group1 = 'VAT' OR
           screen-group1 = 'PPH' OR
           screen-group1 = 'FPN' OR
           screen-group1 = 'FPD' OR
           screen-group1 = 'KUN' OR
           screen-group1 = 'FLC'.
          screen-active  = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.

      IF pa_subty = '15' OR pa_subty = '57'.
        IF screen-group1 = 'KDG'.
          IF gv_kdgrp IS NOT INITIAL.
            screen-input  = 0.
          ELSE.
            screen-input  = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.
      ELSE.
        IF screen-group1 = 'KTM'.
          screen-active  = 0.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'KDG'.
          screen-active  = 0.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'PR1'.
          screen-active  = 0.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'PR2'.
          screen-active  = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.

      IF screen-group1 = 'COM'.
        screen-intensified = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA: lv_mess(100)  VALUE 'Fill in all required entry fields',
        lv_error(100),
        lv_subtype    TYPE zsubtype.

  IF pa_bukrs IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'BUK'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.

  IF pa_gsber IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'GSB'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.

  IF pa_ztype IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'ZTY'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.

  CASE 'X'.
    WHEN radio3.
    WHEN OTHERS.
      IF pa_subty IS INITIAL.
        LOOP AT SCREEN.
          IF screen-group1 = 'SU1'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH lv_mess.
      ELSE.
        CLEAR: gt_subtype, gt_subtype[].
        SELECT zsubtype zstext loekz
          FROM zfgssubtyt
          INTO TABLE gt_subtype.
        READ TABLE gt_subtype WITH KEY zsubtype = pa_subty.
        IF sy-subrc NE 0.
          LOOP AT SCREEN.
            IF screen-group1 = 'SU1'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          CONCATENATE 'Sub Type' pa_subty 'not found' INTO lv_error
          SEPARATED BY space.
          MESSAGE e000(zab) WITH lv_error.
        ELSE.
          IF gt_subtype-loekz EQ 'X'.
            LOOP AT SCREEN.
              IF screen-group1 = 'SU1'.
                screen-input  = 1.
              ELSE.
                screen-input  = 0.
              ENDIF.
              MODIFY SCREEN.
            ENDLOOP.
            CONCATENATE 'Sub Type' pa_subty 'not active' INTO lv_error
            SEPARATED BY space.
            MESSAGE e000(zab) WITH lv_error.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.

  IF pa_spmon IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'SPM'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form USING p_formname TYPE tdsfname
                        fu_ucomm
                  CHANGING fc_subrc.
  DATA:
    l_funcname         TYPE tdsfname,
    l_total_pages      TYPE tdsffpage,
    lwa_control_option TYPE ssfctrlop,
    lwa_output_option  TYPE ssfcompop,
    lwa_doc_info       TYPE ssfcrespd,
    lwa_output_info    TYPE ssfcrescl,
    in_words           LIKE spell OCCURS 0 WITH HEADER LINE.

  DATA: lv_petugas(40),
        lv_jabatan(40),
        lv_count      TYPE i.

* Determine Smartform function module name
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = p_formname
    IMPORTING
      fm_name            = l_funcname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CASE fu_ucomm.
    WHEN '&PREV'.
      lwa_output_option-tdnoprint = 'X'.
    WHEN '&POS'.
      lwa_output_option-tdnoprev = 'X'.
  ENDCASE.

  PERFORM f_popup_signer CHANGING lv_petugas lv_jabatan fc_subrc.

  CHECK fc_subrc EQ 0.

  LOOP AT gt_header.
    AT FIRST.
      lwa_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
      lwa_control_option-no_close = space.
    ENDAT.

    READ TABLE gt_gsno WITH KEY belnr = gt_header-belnr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      CONCATENATE gv_zgsno gt_gsno-nomor INTO gt_header-zgsno.
    ENDIF.

    CALL FUNCTION 'SPELL_AMOUNT'
      EXPORTING
        amount   = gt_header-wrbtr
        currency = 'IDR'
        language = 'i'
      IMPORTING
        in_words = in_words.

    WRITE gt_header-wrbtr TO gt_header-totaltxt CURRENCY gt_header-waers.
    CONCATENATE in_words-word 'RUPIAH' INTO gt_header-terbilang SEPARATED BY space.
    TRANSLATE gt_header-terbilang TO UPPER CASE.

    IF radio2 EQ 'X'.
      pa_budat  = gt_header-budat.
    ENDIF.
    WRITE pa_budat TO gt_header-datum DD/MM/YYYY.
    gt_header-city1   = gv_city1.
    gt_header-bezei   = gv_bezei.
    gt_header-petugas = lv_petugas.
    gt_header-jabatan = lv_jabatan.

    gt_header-namapt  = gv_butxt.
    TRANSLATE gt_header-namapt TO UPPER CASE.
    CONCATENATE gv_butxt 'KANTOR PUSAT' INTO gt_header-kantorpenerima
    SEPARATED BY space.
    TRANSLATE gt_header-kantorpenerima TO UPPER CASE.

    CASE gt_header-zsubtype.
      WHEN '15' OR '57'.
        DATA(lt_clno) = gt_clno[].
        DELETE lt_clno WHERE chkbx NE 'X'.
        SORT lt_clno BY clnr.
        DELETE ADJACENT DUPLICATES FROM lt_clno COMPARING clnr.

        gt_header-kdgrp = pa_kdgrp.
        LOOP AT lt_clno INTO DATA(ls_clno) WHERE chkbx = 'X'.
          IF gt_header-clnr IS INITIAL.
            gt_header-clnr = ls_clno-clnr.
          ELSE.
            gt_header-clnr = | { gt_header-clnr }; { ls_clno-clnr } |.
          ENDIF.
        ENDLOOP.
      WHEN OTHERS.
        CLEAR: gt_header-clnr,gt_header-kdgrp.
    ENDCASE.

    MODIFY gt_header TRANSPORTING totaltxt terbilang datum city1 bezei petugas jabatan zgsno clnr.

    CLEAR: gt_detail, gt_detail[], lv_count.
    LOOP AT gt_vdata WHERE belnr EQ gt_header-belnr.
      IF lv_count IS INITIAL.
        lv_count  = 1.
        gt_detail-totaltxt  = gt_header-totaltxt.
      ENDIF.
      gt_detail-belnr  = gt_vdata-belnr.
      gt_detail-buzei  = gt_vdata-buzei.
      gt_detail-budat  = gt_vdata-budat.
      gt_detail-xblnr  = gt_vdata-xblnr.
      gt_detail-sgtxt  = gt_vdata-sgtxt.
      gt_detail-ztext1 = gt_vdata-ztext1.
      gt_detail-ztext2 = gt_vdata-ztext2.
      gt_detail-ztext3 = gt_vdata-ztext3.
      gt_detail-ztext4 = gt_vdata-ztext4.
      gt_detail-kuntm  = gt_vdata-kuntm.
      gt_detail-perfr  = gt_vdata-perfr.
      gt_detail-perto  = gt_vdata-perto.
      SELECT SINGLE zdesc
        FROM zfgstmmt_cust
        INTO gt_detail-zdesc
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_gsber
          AND kunnr = gt_vdata-kuntm.
      gt_detail-wrtxt  = gt_vdata-wrtxt.
      APPEND gt_detail.
      CLEAR gt_detail.
    ENDLOOP.

    CALL FUNCTION l_funcname
      EXPORTING
        output_options     = lwa_output_option
        control_parameters = lwa_control_option
        user_settings      = 'X'
        gt_header          = gt_header
      TABLES
        gt_detail          = gt_detail
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    lwa_control_option-no_open = 'X'.
  ENDLOOP.

  PERFORM f_free_memory.
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_TO_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_move_to_save_data .
  gt_save-bukrs      = pa_bukrs.
  gt_save-gsber      = pa_gsber.
  gt_save-belnr      = gt_input-belnr.
  gt_save-gjahr      = pa_spmon(4).
  gt_save-buzei      = gt_input-buzei.
  gt_save-budat      = gt_input-budat.
  gt_save-xblnr      = gt_input-xblnr.
  gt_save-zuonr      = gt_input-zuonr.
  gt_save-sgtxt      = gt_input-sgtxt.
  gt_save-ztype      = gt_input-ztype.
  gt_save-zsubtype   = gt_input-zsubtype.
  gt_save-wrbtr      = gt_input-wrbtr.
  gt_save-vbund      = gt_input-vbund.
  gt_save-txt1       = gt_input-txt1.
  gt_save-txt2       = gt_input-txt2.
  gt_save-txt3       = gt_input-txt3.
  gt_save-txt4       = gt_input-txt4.
  gt_save-kuntm      = gt_input-kuntm.
  gt_save-perfr      = gt_input-perfr.
  gt_save-perto      = gt_input-perto.
  gt_save-postdt     = pa_budat.

  DATA:lv_period(4), lv_actde(120).
  DATA:ls_nis TYPE zfgscab_nis.

  READ TABLE gt_gsno WITH KEY belnr = gt_input-belnr
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    CONCATENATE gv_zgsno gt_gsno-nomor INTO gt_save-zgsno.
  ENDIF.

  READ TABLE gt_bsis WITH KEY belnr = gt_input-belnr
                              buzei = gt_input-buzei
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    gt_save-bldat   = gt_bsis-bldat.
    gt_save-waers   = gt_bsis-waers.
    gt_save-shkzg   = gt_bsis-shkzg.
    gt_save-hkont   = gt_bsis-hkont.
  ENDIF.

  READ TABLE gt_kna1 WITH KEY vbund = gt_input-vbund.
  IF sy-subrc EQ 0.
    gt_save-kunnr = gt_kna1-kunnr.
  ENDIF.
  APPEND gt_save.

  gt_save_add-bukrs = gt_save-bukrs.
  gt_save_add-gsber = gt_save-gsber.
  gt_save_add-belnr = gt_save-belnr.
  gt_save_add-gjahr = gt_save-gjahr.
  gt_save_add-zgsno = gt_save-zgsno.
  gt_save_add-ztype = gt_save-ztype.
  gt_save_add-zsubtype  = gt_save-zsubtype.

*  gt_save_add-SUBACCT
  CONCATENATE 'REIMBURSEMENT' gt_input-actde INTO lv_actde SEPARATED BY space.
  gt_save_add-actdesc   = lv_actde.
  gt_save_add-promonr   = gt_input-promo.
  gt_save_add-kunnr     = gt_input-cust.

  SELECT SINGLE *
         FROM zfgscab_nis
         INTO CORRESPONDING FIELDS OF ls_nis
         WHERE promonr = gt_input-promo.
  IF sy-subrc = 0.
    gt_save_add-subacct = ls_nis-zdesc.
  ENDIF.

  CONCATENATE '20' gt_input-promo+11(2) INTO lv_period.
  gt_save_add-period = lv_period.
*  gt_save_add-FEEDESC
*  gt_save_add-FEEAMT
  gt_save_add-vat       = gt_input-vat.
  gt_save_add-pph       = gt_input-pph.
  gt_save_add-fpnr      = gt_input-fpnr.
  gt_save_add-fpdat     = gt_input-fpdat.

  PERFORM f_get_claimamt USING gt_input-vat gt_input-pph gt_input-wrbtr
                         CHANGING gt_save_add-claimamt.

  IF gt_input-vat = '0' AND gt_input-pph = '0'.
    gt_save_add-taxlvl = '10355228'.
  ENDIF.
  IF gt_input-vat = '1.1' AND gt_input-pph = '0'.
    gt_save_add-taxlvl = '00000000'.
  ENDIF.
  IF gt_input-vat = '10' AND gt_input-pph = '0'.
    gt_save_add-taxlvl = '10355229'.
  ENDIF.
  IF gt_input-vat = '10' AND gt_input-pph = '15'.
    gt_save_add-taxlvl = '10355230'.
  ENDIF.
  IF gt_input-vat = '10' AND gt_input-pph = '2'.
    gt_save_add-taxlvl = '10355231'.
  ENDIF.
  IF gt_input-vat = '10' AND gt_input-pph = '10'.
    gt_save_add-taxlvl = '10355232'.
  ENDIF.
  IF gt_input-vat = '0' AND gt_input-pph = '10'.
    gt_save_add-taxlvl = '10430038'.
  ENDIF.
  IF gt_input-vat = '0' AND gt_input-pph = '15'.
    gt_save_add-taxlvl = '10430040'.
  ENDIF.
  IF gt_input-vat = '0' AND gt_input-pph = '2'.
    gt_save_add-taxlvl = '10430041'.
  ENDIF.
  IF gt_input-vat = '11' AND gt_input-pph = '0'.
    gt_save_add-taxlvl = '10470724'.
  ENDIF.
  IF gt_input-vat = '11' AND gt_input-pph = '15'.
    gt_save_add-taxlvl = '10470725'.
  ENDIF.
  IF gt_input-vat = '11' AND gt_input-pph = '2'.
    gt_save_add-taxlvl = '10470726'.
  ENDIF.
  IF gt_input-vat = '11' AND gt_input-pph = '10'.
    gt_save_add-taxlvl = '10470727'.
  ENDIF.
  IF gt_input-vat = '0' AND gt_input-pph = '4'.
    gt_save_add-taxlvl = '10489865'.
  ENDIF.
  IF gt_input-vat = '0' AND gt_input-pph = '30'.
    gt_save_add-taxlvl = '10489866'.
  ENDIF.

  gt_save_add-filecabang = gt_input-filec.
*  gt_save_add-FILEPUSAT
  APPEND gt_save_add.

  CLEAR: gt_save,gt_save_add.
ENDFORM.                    " F_MOVE_TO_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_TO_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_move_to_print_form .
  gt_header-belnr     = gt_input-belnr.
  gt_header-waers     = gt_input-waers.
  gt_header-wrbtr     = gt_input-wrbtr.
  gt_header-ztype     = gt_input-ztype.
  gt_header-zsubtype  = gt_input-zsubtype.
  gt_header-vbund     = gt_input-vbund.
  IF radio2 EQ 'X'.
    gt_header-budat     = gt_input-postdt.
    gt_header-reprint   = 'X'.
  ENDIF.
  READ TABLE gt_subtype WITH KEY zsubtype = gt_input-zsubtype.
  IF sy-subrc EQ 0.
    gt_header-zstext  = gt_subtype-zstext.
  ENDIF.
  COLLECT gt_header.

  gt_vdata-belnr  = gt_input-belnr.
  gt_vdata-buzei  = gt_input-buzei.
  gt_vdata-budat  = gt_input-budat.
  gt_vdata-xblnr  = gt_input-xblnr.
  gt_vdata-sgtxt  = gt_input-sgtxt.
  gt_vdata-ztext1 = gt_input-txt1.
  gt_vdata-ztext2 = gt_input-txt2.
  gt_vdata-ztext3 = gt_input-txt3.
  gt_vdata-ztext4 = gt_input-txt4.
  gt_vdata-kuntm  = gt_input-kuntm.
  gt_vdata-perfr  = gt_input-perfr.
  gt_vdata-perto  = gt_input-perto.
  WRITE gt_input-wrbtr TO gt_vdata-wrtxt CURRENCY gt_input-waers.
  APPEND gt_vdata.
ENDFORM.                    " F_MOVE_TO_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_lock_table USING fu_spmon.
  DATA: ld_mess(100).

  IF radio1 EQ 'X'.
    CALL FUNCTION 'ENQUEUE_EZFGSNOMOR'
      EXPORTING
        mode_zfgsnomor = 'E'
        mandt          = sy-mandt
        gsber          = pa_gsber
        spmon          = fu_spmon
        ztype          = pa_ztype
        zform          = 'GS'
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      CONCATENATE 'Table Lock by' sy-msgv1 INTO ld_mess
      SEPARATED BY space.
      CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
        EXPORTING
          popup_title  = 'Error table locking'
          message_text = ld_mess.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_LOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_unlock_table USING fu_spmon.
  CALL FUNCTION 'DEQUEUE_EZFGSNOMOR'
    EXPORTING
      mode_zfgsnomor = 'X'
      mandt          = sy-mandt
      gsber          = pa_gsber
      spmon          = fu_spmon
      ztype          = pa_ztype
      zform          = 'GS'.
ENDFORM.                    " F_UNLOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_POPUP_SIGNER
*&---------------------------------------------------------------------*
FORM f_popup_signer CHANGING fc_petugas fc_jabatan fc_subrc.

*  CALL SELECTION-SCREEN 9001 STARTING AT 10 5.
*
*  fc_subrc  = sy-subrc.
*
*  IF sy-subrc EQ 0.
*    CASE 'X'.
*      WHEN radio4.
  fc_petugas  = p_jabat1.
  fc_jabatan  = gv_jabat1.
*      WHEN radio5.
*        fc_petugas  = p_jabat2.
*        fc_jabatan  = gv_jabat2.
*      WHEN radio6.
*        fc_petugas  = p_custom.
*    ENDCASE.
*  ENDIF.
ENDFORM.                    " F_POPUP_SIGNER

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data USING fu_spmon.
  LOOP AT gt_save_add.
    IF pa_subt1 = '61' OR pa_subt1 = '21'.
      PERFORM f_move_file_to_server USING gt_save_add-filecabang.

      READ TABLE gt_zfgscab_add WITH KEY bukrs = gt_save_add-bukrs
                                         gsber = gt_save_add-gsber
                                         belnr = gt_save_add-belnr
                                         gjahr = gt_save_add-gjahr
                                         zgsno = gt_save_add-zgsno.
      IF sy-subrc EQ 0.
        UPDATE zfgscab_add FROM gt_save_add.
      ELSE.
        INSERT zfgscab_add FROM gt_save_add.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_save.
    READ TABLE gt_zfgscab WITH KEY bukrs = gt_save-bukrs
                                   gsber = gt_save-gsber
                                   belnr = gt_save-belnr
                                   gjahr = gt_save-gjahr
                                   buzei = gt_save-buzei.
    IF sy-subrc EQ 0.
      UPDATE zfgscab FROM gt_save.
    ELSE.
      INSERT zfgscab FROM gt_save.
    ENDIF.
  ENDLOOP.

  UPDATE zfgsnomor SET nomor  = gv_lastno
  WHERE gsber EQ pa_gsber AND
        spmon EQ fu_spmon AND
        ztype EQ pa_ztype AND
        zform EQ 'GS'.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_GS_NO
*&---------------------------------------------------------------------*
FORM f_get_gs_no USING fu_spmon
                 CHANGING fc_subrc fc_nomor.
  DATA: lv_length TYPE i.

  SELECT gsber spmon ztype prefix1 prefix2 nomor
    FROM zfgsnomor
    INTO TABLE gt_zfgsnomor
    WHERE gsber EQ pa_gsber AND
          spmon EQ fu_spmon AND
          ztype EQ pa_ztype AND
          zform EQ 'GS'.

  fc_subrc  = sy-subrc.

  READ TABLE gt_zfgsnomor INDEX 1.
  IF sy-subrc EQ 0.
    CONCATENATE gt_zfgsnomor-prefix1 '/' fu_spmon+4(2) fu_spmon+2(2)
                '/' gt_zfgsnomor-prefix2 '/' INTO gv_zgsno.

    fc_nomor  = gt_zfgsnomor-nomor.

    PERFORM f_lock_table USING fu_spmon.

    SORT gt_input BY belnr.
    LOOP AT gt_input WHERE check EQ 'X'.
      gt_gsno-belnr  = gt_input-belnr.
      COLLECT gt_gsno.

      PERFORM f_move_to_print_form.
    ENDLOOP.

    SORT gt_gsno BY belnr.
    SORT gt_zfgscab BY belnr.
    LOOP AT gt_gsno.
      CASE 'X'.
        WHEN radio1.
          gt_gsno-nomor = fc_nomor.
          ADD 1 TO fc_nomor.
        WHEN radio2.
          READ TABLE gt_zfgscab WITH KEY belnr = gt_gsno-belnr
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            lv_length = strlen( gt_zfgscab-zgsno ).
            lv_length = lv_length - 4.
            gt_gsno-nomor = gt_zfgscab-zgsno+lv_length(4).
            gv_zgsno  = gt_zfgscab-zgsno(12).
          ENDIF.
      ENDCASE.
      MODIFY gt_gsno TRANSPORTING nomor.
    ENDLOOP.

    gv_lastno = fc_nomor.
  ENDIF.
ENDFORM.                    " F_GET_GS_NO

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_DATA
*&---------------------------------------------------------------------*
FORM f_update_data .
  DATA: lt_zfgscab_cl TYPE TABLE OF zfgscab_cl,
        lv_no         TYPE zeile.

  LOOP AT gt_save.
    UPDATE zfgscab SET zsubtype = gt_save-zsubtype
                       kunnr    = gt_save-kunnr
                       txt1     = gt_save-txt1
                       txt2     = gt_save-txt2
                       txt3     = gt_save-txt3
                       txt4     = gt_save-txt4
                       kuntm    = gt_save-kuntm
                       perfr    = gt_save-perfr
                       perto    = gt_save-perto
                   WHERE bukrs  EQ gt_save-bukrs AND
                         gsber  EQ gt_save-gsber AND
                         belnr  EQ gt_save-belnr AND
                         gjahr  EQ gt_save-gjahr AND
                         buzei  EQ gt_save-buzei.

    UPDATE zfgscab_add SET actdesc  = pa_actde
                           zsubtype = gt_save-zsubtype
                           promonr  = pa_promo
                           kunnr    = pa_cust
                           vat      = pa_vat
                           pph      = pa_pph
                           fpnr     = pa_fpnr
                           fpdat    = pa_fpdat
                       WHERE bukrs EQ gt_save-bukrs
                         AND gsber EQ gt_save-gsber
                         AND belnr EQ gt_save-belnr
                         AND gjahr EQ gt_save-gjahr.

* Reinsert to table ZFGSCAB_CL
    DATA(ls_zfgscab) = gt_zfgscab[ bukrs = gt_save-bukrs
                                   gsber = gt_save-gsber
                                   belnr = gt_save-belnr
                                   gjahr = gt_save-gjahr
                                   buzei = gt_save-buzei ].
    IF ls_zfgscab IS NOT INITIAL.
      "Delete ZFGSCAB_CL
      DELETE zfgscab_cl FROM TABLE gt_zfgscab_cl.
      COMMIT WORK AND WAIT.

      IF sy-subrc = 0.
        "Append ZFGSCAB_CL
        LOOP AT gt_clno INTO DATA(ls_clno) WHERE chkbx = 'X'..
          APPEND INITIAL LINE TO lt_zfgscab_cl ASSIGNING FIELD-SYMBOL(<fs_zfgscab_cl>).
          ADD 1 TO lv_no.
          <fs_zfgscab_cl>-belnr = ls_zfgscab-belnrgs.
          <fs_zfgscab_cl>-gjahr = ls_zfgscab-gjahr.
          <fs_zfgscab_cl>-zgsno = ls_zfgscab-zgsno.
          <fs_zfgscab_cl>-itmno = lv_no.
          <fs_zfgscab_cl>-kdgrp = ls_clno-kdgrp.
          <fs_zfgscab_cl>-matkl = ls_clno-matkl.
          <fs_zfgscab_cl>-clnr  = ls_clno-clnr.
        ENDLOOP.

        "Insert ZFGSCAB_CL
        IF lt_zfgscab_cl[] IS NOT INITIAL.
          INSERT zfgscab_cl FROM TABLE lt_zfgscab_cl.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  MESSAGE s000(zab) WITH 'Data already modified'.
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_UPDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_INPUT_DATA
*&---------------------------------------------------------------------*
FORM f_modify_input_data TABLES ft_header STRUCTURE gt_input.
  DATA: lt_input  LIKE gt_input OCCURS 0 WITH HEADER LINE.

  LOOP AT gt_input WHERE check EQ 'X'.
    gt_input-check  = 'X'.
    MODIFY gt_input TRANSPORTING check
                    WHERE belnr EQ gt_input-belnr.

    ft_header-ztype     = gt_input-ztype.
    ft_header-zsubtype  = gt_input-zsubtype.
    ft_header-xblnr     = gt_input-xblnr.
    ft_header-vbund     = gt_input-vbund.
    COLLECT ft_header.

    gt_temp-check       = 'X'.
    MODIFY gt_temp TRANSPORTING check
                   WHERE belnr = gt_input-belnr.
  ENDLOOP.

  LOOP AT gt_input WHERE check EQ 'X'.
    lt_input  = gt_input.
    APPEND lt_input.
  ENDLOOP.

  IF lt_input[] IS NOT INITIAL.
    SORT lt_input BY bukrs gsber belnr gjahr buzei.
    SELECT bukrs gsber belnr gjahr buzei budat bldat xblnr zuonr
           sgtxt zgsno ztype zsubtype vbund kunnr waers shkzg wrbtr
           hkont txt1 txt2 txt3 txt4 belnrgs usergs tglgs jamgs belnrrevgs
           userrevgs tglrevgs jamrevgs belnrpost gjahrpost userpost postdt
           tglpost jampost belnrrev userrev tglrev
      FROM zfgscab
      APPENDING TABLE gt_zfgscab
      FOR ALL ENTRIES IN lt_input
      WHERE bukrs EQ lt_input-bukrs AND
            gsber EQ lt_input-gsber AND
            belnr EQ lt_input-belnr AND
            gjahr EQ lt_input-gjahr AND
            buzei EQ lt_input-buzei.
  ENDIF.
ENDFORM.                    " F_MODIFY_INPUT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_DATA
*&---------------------------------------------------------------------*
FORM f_delete_data .
  DATA: answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Delete confirmation '
      text_question  = 'Delete record ?'
      text_button_1  = 'Yes'
      text_button_2  = 'No'
    IMPORTING
      answer         = answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.

  IF answer EQ '1'.
    LOOP AT gt_input WHERE check EQ 'X'.
      DELETE gt_input WHERE belnr EQ gt_input-belnr.
      DELETE FROM zfgscab WHERE belnr EQ gt_input-belnr.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_DELETE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_REVERSE
*&---------------------------------------------------------------------*
FORM f_reverse USING fu_belnr fu_belnr1.
  DATA: lv_stgrd  TYPE stgrd VALUE '01',
        lv_mode,
        lv_update.

  lv_mode   = 'N'.
  lv_update = 'S'.

  CLEAR: t_bdcdata,t_bdcmsg.
  REFRESH: t_bdcdata, t_bdcmsg.

  IF fu_belnr1 IS NOT INITIAL.
    PERFORM f_bdc_data TABLES t_bdcdata USING:
         'X'  'SAPMF05A'      '0105',
         ' '  'BDC_OKCODE'    '=BU',
         ' '  'RF05A-BELNS'   fu_belnr1,
         ' '  'BKPF-BUKRS'    gt_zfgscab-bukrs,
         ' '  'RF05A-GJAHS'   gt_zfgscab-gjahr,
         ' '  'UF05A-STGRD'   '01'.

    CALL TRANSACTION 'FB08' USING t_bdcdata
                            MODE lv_mode
                            UPDATE lv_update
                            MESSAGES INTO t_bdcmsg.

    READ TABLE t_bdcmsg WITH KEY msgtyp = 'E'.
    IF sy-subrc = 0.
      ROLLBACK WORK.
    ELSE.
      READ TABLE t_bdcmsg WITH KEY msgtyp = 'S'.
      IF sy-subrc = 0.
        COMMIT WORK AND WAIT.
        UPDATE zfgscab SET belnrgs      = space
                           belnrrevgs   = t_bdcmsg-msgv1
                           userrevgs    = sy-uname
                           tglrevgs     = sy-datum
                           jamrevgs     = sy-uzeit
                       WHERE belnrgs  EQ fu_belnr1        AND
                             bukrs    EQ gt_zfgscab-bukrs AND
                             gjahr    EQ gt_zfgscab-gjahr.

        DELETE FROM zfgscab_cl WHERE belnr = @fu_belnr1
                                 AND gjahr = @gt_zfgscab-gjahr
                                 AND zgsno = @gt_zfgscab-zgsno.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_REVERSE

*&---------------------------------------------------------------------*
*&      Form  F_GET_ZFGSACCGS
*&---------------------------------------------------------------------*
FORM f_get_zfgsaccgs USING fu_subtype
                     CHANGING lwa_zfgs STRUCTURE gt_zfgsaccgs.
  DATA: lt_skat LIKE gt_skat OCCURS 0 WITH HEADER LINE.

  SELECT ztype zsubtype gsber blart
         bschl1 hkont1 mwskz1 ztax1
         bschl2 hkont2 mwskz2 ztax2
         bschl3 hkont3 mwskz3 ztax3
         bschl4 hkont4 mwskz4 ztax4
         bschl5 hkont5 mwskz5 ztax5
         bschl6 hkont6 mwskz6 ztax6
         bschl7 hkont7 mwskz7 ztax7
         bschl8 hkont8 mwskz8 ztax8
         zpostdn zprntdn zinputppn
         zinputgsber
    FROM zfgsaccgs
    INTO TABLE gt_zfgsaccgs
    WHERE ztype    EQ pa_ztype    AND
          zsubtype EQ fu_subtype  AND
          gsber    EQ pa_gsber.

  IF sy-subrc EQ 0.
    READ TABLE gt_zfgsaccgs INTO lwa_zfgs INDEX 1.
    IF sy-subrc EQ 0.
      lt_skat-saknr = lwa_zfgs-hkont1.
      APPEND lt_skat.
      lt_skat-saknr = lwa_zfgs-hkont2.
      APPEND lt_skat.
      lt_skat-saknr = lwa_zfgs-hkont3.
      APPEND lt_skat.
      lt_skat-saknr = lwa_zfgs-hkont4.
      APPEND lt_skat.
      lt_skat-saknr = lwa_zfgs-hkont5.
      APPEND lt_skat.
      lt_skat-saknr = lwa_zfgs-hkont6.
      APPEND lt_skat.
      lt_skat-saknr = lwa_zfgs-hkont7.
      APPEND lt_skat.
      lt_skat-saknr = lwa_zfgs-hkont8.
      APPEND lt_skat.
    ENDIF.

    SORT lt_skat BY saknr.
    DELETE ADJACENT DUPLICATES FROM lt_skat COMPARING saknr.
    IF lt_skat[] IS NOT INITIAL.
      SELECT saknr txt20
        FROM skat
        INTO TABLE gt_skat
        FOR ALL ENTRIES IN lt_skat
        WHERE saknr EQ lt_skat-saknr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_ZFGSACCGS

*&---------------------------------------------------------------------*
*&      Form  F_GET_HEADER
*&---------------------------------------------------------------------*
FORM f_get_header  USING    fu_blart
                   CHANGING documentheader STRUCTURE bapiache09.
  documentheader-bus_act    = 'RFBU'.
  documentheader-username   = sy-uname.
  documentheader-comp_code  = pa_bukrs.
  documentheader-doc_date   = pa_bldat.
  documentheader-pstng_date = pa_budat.
  documentheader-doc_type   = fu_blart.
  documentheader-ref_doc_no = pa_xblnr.
  documentheader-header_txt = pa_bktxt.
ENDFORM.                    " F_GET_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_SIMULATE
*&---------------------------------------------------------------------*
FORM f_simulate .
  PERFORM f_detail_data TABLES glgs apgs args currgs extgs retgs
                               gt_post.

  PERFORM f_bapi_document_check TABLES glgs apgs args currgs extgs retgs
                                       gt_post
                                USING headgs obj_type.
ENDFORM.                    " F_SIMULATE

*&---------------------------------------------------------------------*
*&      Form  F_DOCUMENT_POST
*&---------------------------------------------------------------------*
FORM f_document_post .
  obj_type = 'BKPF'.

  PERFORM f_detail_data TABLES glgs apgs args currgs extgs retgs
                               gt_post.

  PERFORM f_bapi_document_post TABLES glgs apgs args currgs extgs retgs
                                      gt_save
                               USING headgs obj_type.

  CLEAR: gt_save, gt_save[].

  MESSAGE s000(zab) WITH 'Data already processed'.
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_DOCUMENT_POST

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_TO_POST_DATA
*&---------------------------------------------------------------------*
FORM f_move_to_post_data TABLES ft_kna1 STRUCTURE gt_kna1
                         USING lwa_input STRUCTURE gt_input
                               lwa_zfgs  STRUCTURE gt_zfgsaccgs
                         CHANGING fc_buzei.
  DATA: lv_count TYPE i,
        lv_wrbtr TYPE wrbtr,
        lv_bschl TYPE bschl,
        lv_hkont TYPE hkont,
        lv_mwskz TYPE mwskz,
        lv_ztax  TYPE ztax1.

  gt_post-blart = lwa_zfgs-blart.
  gt_post-bukrs = pa_bukrs.
  gt_post-belnr = lwa_input-belnr.
  gt_post-buzei = lwa_input-buzei.
  gt_post-gjahr = pa_budat(4).
  gt_post-xblnr = lwa_input-xblnr.
  gt_post-gsber = pa_gsber.
  gt_post-vbund = lwa_input-vbund.

  gt_post-txt1  = lwa_input-txt1.
  gt_post-txt2  = lwa_input-txt2.
  gt_post-txt3  = lwa_input-txt3.
  gt_post-txt4  = lwa_input-txt4.

  DO 8 TIMES.
    CLEAR: lv_bschl, lv_hkont, lv_mwskz, lv_ztax.
    ADD 1 TO lv_count.
    CASE lv_count.
      WHEN 1.
        lv_bschl  = lwa_zfgs-bschl1.
        lv_hkont  = lwa_zfgs-hkont1.
        lv_mwskz  = lwa_zfgs-mwskz1.
        lv_ztax   = lwa_zfgs-ztax1.
      WHEN 2.
        lv_bschl  = lwa_zfgs-bschl2.
        lv_hkont  = lwa_zfgs-hkont2.
        lv_mwskz  = lwa_zfgs-mwskz2.
        lv_ztax   = lwa_zfgs-ztax2.
      WHEN 3.
        lv_bschl  = lwa_zfgs-bschl3.
        lv_hkont  = lwa_zfgs-hkont3.
        lv_mwskz  = lwa_zfgs-mwskz3.
        lv_ztax   = lwa_zfgs-ztax3.
      WHEN 4.
        lv_bschl  = lwa_zfgs-bschl4.
        lv_hkont  = lwa_zfgs-hkont4.
        lv_mwskz  = lwa_zfgs-mwskz4.
        lv_ztax   = lwa_zfgs-ztax4.
      WHEN 5.
        lv_bschl  = lwa_zfgs-bschl5.
        lv_hkont  = lwa_zfgs-hkont5.
        lv_mwskz  = lwa_zfgs-mwskz5.
        lv_ztax   = lwa_zfgs-ztax5.
      WHEN 6.
        lv_bschl  = lwa_zfgs-bschl6.
        lv_hkont  = lwa_zfgs-hkont6.
        lv_mwskz  = lwa_zfgs-mwskz6.
        lv_ztax   = lwa_zfgs-ztax6.
      WHEN 7.
        lv_bschl  = lwa_zfgs-bschl7.
        lv_hkont  = lwa_zfgs-hkont7.
        lv_mwskz  = lwa_zfgs-mwskz7.
        lv_ztax   = lwa_zfgs-ztax7.
      WHEN 8.
        lv_bschl  = lwa_zfgs-bschl8.
        lv_hkont  = lwa_zfgs-hkont8.
        lv_mwskz  = lwa_zfgs-mwskz8.
        lv_ztax   = lwa_zfgs-ztax8.
    ENDCASE.

    lwa_input-wrbtr = abs( lwa_input-wrbtr ).
    READ TABLE gt_tbsl WITH KEY bschl = lv_bschl.
    IF gt_tbsl-shkzg EQ 'H'.
      lv_wrbtr  = lwa_input-wrbtr * -1.
    ELSE.
      lv_wrbtr  = lwa_input-wrbtr.
    ENDIF.

    IF lv_bschl IS NOT INITIAL.
      gt_post-icon  = icon_led_green.
      ADD 1 TO fc_buzei.
      gt_post-buzeipost = fc_buzei.
      gt_post-bschl     = lv_bschl.
      gt_post-sgtxt     = lwa_input-sgtxt.
      gt_post-mwskz     = lv_mwskz.
      gt_post-koart     = gt_tbsl-koart.
      IF lv_bschl EQ '01'.
        gt_post-account     = lwa_input-kunnr.
        READ TABLE ft_kna1 WITH KEY kunnr = lwa_input-kunnr.
        IF sy-subrc EQ 0.
          gt_post-description = ft_kna1-name1.
        ENDIF.
      ELSE.
        gt_post-account = lv_hkont.
        READ TABLE gt_skat WITH KEY saknr = lv_hkont.
        IF sy-subrc EQ 0.
          gt_post-description = gt_skat-txt20.
        ENDIF.
      ENDIF.
      gt_post-wrbtr  = lv_wrbtr.
      APPEND gt_post.
    ELSE.
      gt_post-icon  = icon_led_red.
    ENDIF.
  ENDDO.
ENDFORM.                    " F_MOVE_TO_POST_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_DATA
*&---------------------------------------------------------------------*
FORM f_detail_data  TABLES  accountgl         STRUCTURE bapiacgl09
                            accountpayable    STRUCTURE bapiacap09
                            accountreceivable STRUCTURE bapiacar09
                            currencyamount    STRUCTURE bapiaccr09
                            extension1        STRUCTURE bapiacextc
                            return            STRUCTURE bapiret2
                            ft_post           STRUCTURE gt_post.
  DATA : lv_datum   TYPE sy-datum.

  LOOP AT ft_post WHERE icon  EQ icon_led_green.
    CASE ft_post-koart.
      WHEN 'D'.
        accountreceivable-itemno_acc    = ft_post-buzeipost.
        accountreceivable-customer      = ft_post-account.
        accountreceivable-item_text     = ft_post-sgtxt.
        accountreceivable-bus_area      = ft_post-gsber.
        accountreceivable-tax_code      = ft_post-mwskz.
        accountreceivable-bline_date    = pa_bldat.
        accountreceivable-ref_key_3     = 'X'.
        APPEND accountreceivable.
      WHEN 'K'.
        accountpayable-itemno_acc       = ft_post-buzeipost.
        accountpayable-vendor_no        = ft_post-account.
        accountpayable-item_text        = ft_post-sgtxt.
        accountpayable-bus_area         = ft_post-gsber.
        accountpayable-tax_code         = ft_post-mwskz.
        accountpayable-bline_date       = pa_bldat.
        accountpayable-ref_key_3        = 'X'.
        APPEND accountpayable.
      WHEN 'S'.
        accountgl-itemno_acc            = ft_post-buzeipost.
        accountgl-gl_account            = ft_post-account.
        accountgl-item_text             = ft_post-sgtxt.
        accountgl-bus_area              = ft_post-gsber.
        accountgl-tax_code              = ft_post-mwskz.
        accountgl-trade_id              = ft_post-vbund.
        accountgl-ref_key_3             = 'X'.
        APPEND accountgl.
    ENDCASE.

    extension1(3)                = ft_post-buzeipost.
    extension1+3(2)              = ft_post-bschl.
    APPEND extension1.

    currencyamount-itemno_acc    = ft_post-buzeipost.
    currencyamount-curr_type     = '00'.
    currencyamount-currency      = 'IDR'.
    currencyamount-amt_doccur    = ft_post-wrbtr * 100.
    APPEND currencyamount.

    CLEAR: accountgl, accountpayable, accountreceivable,
           currencyamount, extension1.
  ENDLOOP.
ENDFORM.                    " F_DETAIL_DATA

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_DOCUMENT_CHECK
*----------------------------------------------------------------------*
FORM f_bapi_document_check  TABLES   accountgl         STRUCTURE bapiacgl09
                                     accountpayable    STRUCTURE bapiacap09
                                     accountreceivable STRUCTURE bapiacar09
                                     currencyamount    STRUCTURE bapiaccr09
                                     extension1        STRUCTURE bapiacextc
                                     return            STRUCTURE bapiret2
                                     ft_post           STRUCTURE gt_post
                            USING    documentheader    STRUCTURE bapiache09
                                     obj_type.
  DATA: lv_error  TYPE i.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
    EXPORTING
      documentheader    = documentheader
    TABLES
      accountgl         = accountgl
      accountpayable    = accountpayable
      accountreceivable = accountreceivable
      currencyamount    = currencyamount
      extension1        = extension1
      return            = return.

  LOOP AT return.
    IF return-type = 'A' OR return-type = 'E'.
      gt_error-bktxt    = pa_bktxt.
      gt_error-message  = return-message.
      lv_error          = 1.
      IF return-id NE 'RW' OR
        return-number NE '609'.
        APPEND gt_error.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lv_error IS NOT INITIAL.
    LOOP AT ft_post.
      ft_post-icon  = icon_led_red.
      MODIFY ft_post TRANSPORTING icon.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_BAPI_DOCUMENT_CHECK

*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_0500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
    WRITE: / sy-vline, (20) gt_error-bktxt,
             sy-vline, (94) gt_error-message,
             sy-vline.
  ENDLOOP.
  WRITE: / sy-uline(121).
ENDFORM.                    " F_ERROR_LOG

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_DOCUMENT_POST
*&---------------------------------------------------------------------*
FORM f_bapi_document_post  TABLES   accountgl         STRUCTURE bapiacgl09
                                    accountpayable    STRUCTURE bapiacap09
                                    accountreceivable STRUCTURE bapiacar09
                                    currencyamount    STRUCTURE bapiaccr09
                                    extension1        STRUCTURE bapiacextc
                                    return            STRUCTURE bapiret2
                                    ft_post           STRUCTURE zfgscab
                            USING   documentheader    STRUCTURE bapiache09
                                    obj_type.

  DATA: lv_zgsno TYPE zgsno,
        lv_belnr TYPE belnr_d,
        lv_gjahr TYPE gjahr.

  DATA: lt_zfgscab_cl TYPE TABLE OF zfgscab_cl,
        lv_no         TYPE zeile.

  READ TABLE ft_post INDEX 1.
  documentheader-header_txt = ft_post-zgsno.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader    = documentheader
    IMPORTING
      obj_type          = obj_type
    TABLES
      accountgl         = accountgl
      accountpayable    = accountpayable
      accountreceivable = accountreceivable
      currencyamount    = currencyamount
      extension1        = extension1
      return            = return.

  LOOP AT return.
    IF return-type = 'S'.
      lv_belnr    = return-message_v2(10).
      lv_gjahr    = return-message_v2+14(4).
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait   = 'X'
    IMPORTING
      return = return.

  PERFORM f_change_bline_date TABLES accountgl
                              USING lv_belnr pa_bukrs lv_gjahr pa_bldat.

  LOOP AT ft_post.
    UPDATE zfgscab SET belnrgs  = lv_belnr
                       usergs   = sy-uname
                       tglgs    = sy-datum
                       jamgs    = sy-uzeit
                   WHERE bukrs EQ ft_post-bukrs AND
                         belnr EQ ft_post-belnr AND
                         gjahr EQ ft_post-gjahr.

    LOOP AT gt_clno INTO DATA(ls_clno) WHERE chkbx = 'X'.
      APPEND INITIAL LINE TO lt_zfgscab_cl ASSIGNING FIELD-SYMBOL(<fs_zfgscab_cl>).
      ADD 1 TO lv_no.
      <fs_zfgscab_cl>-belnr = lv_belnr.
      <fs_zfgscab_cl>-gjahr = lv_gjahr.
      <fs_zfgscab_cl>-zgsno = ft_post-zgsno.
      <fs_zfgscab_cl>-xref2 = ft_post-xref2.
      <fs_zfgscab_cl>-itmno = lv_no.
      <fs_zfgscab_cl>-kdgrp = ls_clno-kdgrp.
      <fs_zfgscab_cl>-matkl = ls_clno-matkl.
      <fs_zfgscab_cl>-clnr  = ls_clno-clnr.
    ENDLOOP.
  ENDLOOP.

  IF lt_zfgscab_cl[] IS NOT INITIAL.
    INSERT zfgscab_cl FROM TABLE lt_zfgscab_cl.
    COMMIT WORK AND WAIT.
  ENDIF.
ENDFORM.                    " F_BAPI_DOCUMENT_POST

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_BLINE_DATE
*&---------------------------------------------------------------------*
FORM f_change_bline_date  TABLES   accountgl STRUCTURE bapiacgl09
                          USING    fu_belnr fu_bukrs fu_gjahr fu_bldat.

  DATA: lv_mode     VALUE 'N',
        lv_update   VALUE 'S',
        lv_bldat(8).

  CONCATENATE fu_bldat+6(2) fu_bldat+4(2) fu_bldat(4) INTO lv_bldat.

  LOOP AT accountgl.
    CLEAR: t_bdcdata,t_bdcmsg.
    REFRESH: t_bdcdata, t_bdcmsg.
    IF accountgl-gl_account EQ '0315300100'.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPMF05L'      '0102',
           ' '  'BDC_OKCODE'    '/00',
           ' '  'RF05L-BELNR'   fu_belnr,
           ' '  'RF05L-BUKRS'   fu_bukrs,
           ' '  'RF05L-GJAHR'   fu_gjahr,
           ' '  'RF05L-XKSAK'   'X'.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPMF05L'      '0300',
           ' '  'BDC_OKCODE'    '=AE',
           ' '  'BSEG-ZFBDT'    lv_bldat.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPLKACB'      '0002',
           ' '  'BDC_OKCODE'    '=ENTE'.

      CALL TRANSACTION 'FB09' USING t_bdcdata
                              MODE lv_mode
                              UPDATE lv_update
                              MESSAGES INTO t_bdcmsg.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHANGE_BLINE_DATE

*&---------------------------------------------------------------------*
*&      Form  F_AUTHORITY_CHECK
*&---------------------------------------------------------------------*
FORM f_authority_check  CHANGING fc_error.
  AUTHORITY-CHECK OBJECT 'ZREVZF60'
            ID 'ACTVT' FIELD '01'.
  IF sy-subrc NE 0.
    fc_error = 1.
  ENDIF.
ENDFORM.                    " F_AUTHORITY_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data .
  DATA : lv_length  TYPE int4.
  CASE 'X'.
    WHEN radio2.
      LOOP AT gt_input.
        CLEAR lv_length.
        READ TABLE gt_zfgscab WITH KEY belnr = gt_input-belnr
                                       buzei = gt_input-buzei.
        IF sy-subrc = 0.
          lv_length = strlen( gt_zfgscab-zgsno ).
          lv_length = lv_length - 1.
          IF gt_zfgscab-zgsno+lv_length(1) = 'S'.
            DELETE gt_input.
          ENDIF.
        ENDIF.
      ENDLOOP.

    WHEN radio7.
      LOOP AT gt_zfgscab.
        CLEAR lv_length.

        lv_length = strlen( gt_zfgscab-zgsno ).
        lv_length = lv_length - 1.
        IF gt_zfgscab-zgsno+lv_length(1) = 'S'.
          DELETE gt_zfgscab.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_KETERANGAN
*&---------------------------------------------------------------------*
FORM f_validasi_keterangan  CHANGING fc_subrc.
  DATA : lt_input LIKE gt_input OCCURS 0 WITH HEADER LINE.

  DATA : lv_subrc   TYPE sy-subrc.

  CLEAR : gt_error[], gt_error.

  lt_input[] = gt_input[].
  DELETE lt_input WHERE check IS INITIAL.

  LOOP AT lt_input.
    IF gv_flag IS NOT INITIAL.
      IF pa_subt1 EQ '21' OR pa_subt1 EQ '61'.
      ELSE.
        IF lt_input-txt1 IS INITIAL OR
          lt_input-txt2 IS INITIAL OR
          lt_input-txt3 IS INITIAL.
          lv_subrc = 1.
          gt_error-bktxt   = lt_input-belnr.
          gt_error-message = 'Keterangan harus diisi'.
          APPEND gt_error.
        ENDIF.
      ENDIF.
    ENDIF.

    IF gt_error[] IS INITIAL.
      IF lt_input-zsubtype = '15' OR
        lt_input-zsubtype = '57'.
        IF pa_kunnr IS INITIAL.
          lv_subrc = 2.
          gt_error-bktxt   = lt_input-belnr.
          gt_error-message = 'Customer TMMT harus diisi'.
          APPEND gt_error.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF gt_error[] IS NOT INITIAL.
    fc_subrc = lv_subrc.
  ELSE.
    fc_subrc = 0.
  ENDIF.
ENDFORM.                    " F_VALIDASI_KETERANGAN

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_9000
*&---------------------------------------------------------------------*
FORM f_validate_screen_9000 .
  DATA : lv_length   TYPE p DECIMALS 0,
         lv_text(50),
         lv_date(10),
         lv_datum    TYPE sy-datum,
         lv_string   TYPE string.

*  DATA: lv_docid      TYPE dsvasdocid,
  DATA: lv_docid     TYPE text255,
*        lv_directory  TYPE dsvasdocid,
        lv_directory TYPE text255,
*        lv_filename   TYPE dsvasdocid,
        lv_filename  TYPE text255,
*        lv_extension  TYPE dsvasdocid,
        lv_extension TYPE text255,
        lv_file(20), lv_ext(3), lv_lines TYPE i.

  DATA: ls_nis TYPE zfgscab_nis.

  IF gv_flag IS NOT INITIAL.
    IF pa_subt1 EQ '21' OR pa_subt1 EQ '61'.
      IF pa_promo IS INITIAL.
        PERFORM f_screen_modify USING 'PRO' '1'
                                      'Nomor ID Optima tidak boleh kosong'.
      ELSE.
        SELECT SINGLE *
          FROM zfgscab_nis
          INTO CORRESPONDING FIELDS OF ls_nis
          WHERE promonr = pa_promo.
        IF sy-subrc <> 0.
          PERFORM f_screen_modify USING 'PRO' '1'
                                        'Nomor ID Optima tidak terdaftar'.
        ELSE.
***          CASE pa_vbund.
***            WHEN 'NTR'.
***              IF pa_promo(3) <> 'NIS'.
***                PERFORM f_screen_modify USING 'PRO' '1'
***                                              'Nomor ID Optima harus diawali NIS'.
***              ENDIF.
***            WHEN 'SGM'.
***              IF pa_promo(3) <> 'SGM'.
***                PERFORM f_screen_modify USING 'PRO' '1'
***                                              'Nomor ID Optima harus diawali SGM'.
***              ENDIF.
***          ENDCASE.
        ENDIF.
      ENDIF.
      IF pa_actde IS INITIAL.
        PERFORM f_screen_modify USING 'ACT' '1'
                                      'Activity Desc tidak boleh kosong'.
      ELSE.
      ENDIF.
      IF pa_cust IS INITIAL.
        PERFORM f_screen_modify USING 'KUN' '1'
                                      'Kode Customer tidak boleh kosong'.
      ELSE.
      ENDIF.
      IF pa_vat IS INITIAL.
        PERFORM f_screen_modify USING 'VAT' '1'
                                      'PPN (%) tidak boleh kosong'.
      ELSE.
      ENDIF.
      IF pa_pph IS INITIAL.
        PERFORM f_screen_modify USING 'PPH' '1'
                                      'PPH (%) tidak boleh kosong'.
      ELSE.
      ENDIF.
      IF pa_fpnr IS INITIAL.
        IF pa_vat NE '0'.
          PERFORM f_screen_modify USING 'FPN' '1'
                                        'Nomor FP tidak boleh kosong'.
        ENDIF.
      ELSE.
      ENDIF.
      IF pa_fpdat IS INITIAL.
        IF pa_vat NE '0'.
          PERFORM f_screen_modify USING 'FPD' '1'
                                        'Tanggal FP tidak boleh kosong'.
        ENDIF.
      ELSE.
      ENDIF.
      IF pa_filec IS INITIAL.
        PERFORM f_screen_modify USING 'FLC' '1'
                                      'File PDF lampiran tidak boleh kosong'.

      ELSE.
        CLEAR: lv_docid,lv_directory,lv_filename,lv_extension,lv_file,lv_ext.
        lv_docid = pa_filec.
*        CALL FUNCTION 'DSVAS_DOC_FILENAME_SPLIT'
        CALL FUNCTION 'Z_DSVAS_DOC_FILENAME_SPLIT'       "SOH Adj 20240819
          EXPORTING
            pf_docid     = lv_docid
          IMPORTING
            pf_directory = lv_directory
            pf_filename  = lv_filename
            pf_extension = lv_extension.

        IF lv_extension = 'PDF' OR lv_extension = 'pdf'.
          PERFORM f_split_filename USING lv_filename
                                   CHANGING lv_file lv_ext.
          IF lv_file NE gv_belnr.
            PERFORM f_screen_modify USING 'FLC' '1'
                                          'Nama file lampiran harus sama dengan Document No.'.
          ENDIF.

        ELSE.
          PERFORM f_screen_modify USING 'FLC' '1'
                                        'File lampiran harus format PDF'.
        ENDIF.
      ENDIF.
    ELSE.
      IF pa_text1 IS INITIAL.
        PERFORM f_screen_modify USING 'PT1' '1'
                                      'Keterangan tidak boleh kosong'.
      ELSE.
      ENDIF.

      IF pa_text2 IS INITIAL.
        PERFORM f_screen_modify USING 'PT2' ''
                                      'Keterangan tidak boleh kosong'.
      ELSE.
        lv_length = strlen( pa_text2 ).

        CASE lv_length.
          WHEN 16.
            lv_string = pa_text2.
            IF lv_string CO '0123456789'.
            ELSE.
              PERFORM f_screen_modify USING 'PT2' '1'
              'Keterangan salah format'.
            ENDIF.
          WHEN 20.
            lv_text  = pa_text2.
            TRANSLATE lv_text USING '. '.
            TRANSLATE lv_text USING '- '.
            CONDENSE lv_text NO-GAPS.
            WRITE lv_text TO lv_text USING EDIT MASK '__.___.___._-___.___'.
            IF pa_text2 <> lv_text.
              PERFORM f_screen_modify USING 'PT2' '1'
              'Keterangan salah format'.
            ENDIF.
          WHEN OTHERS.
            PERFORM f_screen_modify USING 'PT2' '1'
            'Keterangan salah format'.
        ENDCASE.

*****        IF lv_length <> 20.
*****          PERFORM f_screen_modify USING 'PT2' ''
*****          'Keterangan harus 99.999.999.9-999.999'.
*****        ELSE.
*****          lv_text  = pa_text2.
*****          TRANSLATE lv_text USING '. '.
*****          TRANSLATE lv_text USING '- '.
*****          CONDENSE lv_text NO-GAPS.
*****          WRITE lv_text TO lv_text USING EDIT MASK '__.___.___._-___.___'.
*****
*****          IF pa_text2 <> lv_text.
*****            PERFORM f_screen_modify USING 'PT2' ''
*****            'Keterangan harus 99.999.999.9-999.999'.
*****          ENDIF.
*****        ENDIF.
      ENDIF.

      IF pa_text3 IS INITIAL.
        PERFORM f_screen_modify USING 'PT3' '1'
                                      'Keterangan tidak boleh kosong'.
      ELSE.
        IF pa_text3(3) <> 'FP:'.
          PERFORM f_screen_modify USING 'PT3' '1'
          'Keterangan salah format'.
        ELSE.
          SPLIT pa_text3 AT '/' INTO lv_text lv_date.
          CONCATENATE lv_date+6(4) lv_date+3(2) lv_date(2) INTO lv_datum.
          CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
            EXPORTING
              date                      = lv_datum
            EXCEPTIONS
              plausibility_check_failed = 1
              OTHERS                    = 2.
          IF sy-subrc <> 0.
            PERFORM f_screen_modify USING 'PT3' ''
            'Date error'.
          ELSE.
            SPLIT lv_text AT ':' INTO lv_text lv_string.
            lv_text = lv_string.
            TRANSLATE lv_text USING '. '.
            TRANSLATE lv_text USING '- '.
            CONDENSE lv_text NO-GAPS.
            lv_length = strlen( lv_string ).

            CASE lv_length.
              WHEN 17.
                IF lv_string CO '0123456789'.
                  CONCATENATE 'FP:' lv_text '/' lv_date INTO lv_text.
                  IF pa_text3 <> lv_text.
                    PERFORM f_screen_modify USING 'PT3' '1'
                    'Keterangan salah format'.
                  ENDIF.
                ELSE.
                  PERFORM f_screen_modify USING 'PT3' '1'
                  'Keterangan salah format'.
                ENDIF.
              WHEN 19.
                WRITE lv_text TO lv_text USING EDIT MASK '___.___-__.________'.
                CONCATENATE 'FP:' lv_text '/' lv_date INTO lv_text.
                IF pa_text3 <> lv_text.
                  PERFORM f_screen_modify USING 'PT3' '1'
                  'Keterangan salah format'.
                ENDIF.
              WHEN 21.
                WRITE lv_text TO lv_text USING EDIT MASK '__.__.__.___-________'.
                CONCATENATE 'FP:' lv_text '/' lv_date INTO lv_text.
                IF pa_text3 <> lv_text.
                  PERFORM f_screen_modify USING 'PT3' '1'
                  'Keterangan salah format'.
                ENDIF.
              WHEN OTHERS.
                PERFORM f_screen_modify USING 'PT3' '1'
                'Keterangan salah format'.
            ENDCASE.
          ENDIF.
        ENDIF.

*****        IF lv_length <> 33.
*****          PERFORM f_screen_modify USING 'PT3' ''
*****          'Keterangan harus FP:999.999-99.99999999/DD.MM.YYYY'.
*****        ELSE.
*****          lv_text  = pa_text3+3(30).
*****          CONCATENATE lv_text+26(4) lv_text+23(2) lv_text+20(2) INTO lv_datum.
*****          TRANSLATE lv_text USING '. '.
*****          TRANSLATE lv_text USING '- '.
*****          TRANSLATE lv_text USING '/ '.
*****          CONDENSE lv_text NO-GAPS.
*****          WRITE lv_text TO lv_text USING EDIT MASK '___.___-__.________/__.__._____'.
*****
*****          IF pa_text3(3) <> 'FP:'.
*****            PERFORM f_screen_modify USING 'PT3' ''
*****            'Keterangan harus FP:999.999-99.99999999/DD.MM.YYYY'.
*****          ELSEIF pa_text3+3(30) <> lv_text.
*****            PERFORM f_screen_modify USING 'PT3' ''
*****            'Keterangan harus FP:999.999-99.99999999/DD.MM.YYYY'.
*****          ELSE.
*****            CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
*****              EXPORTING
*****                date                      = lv_datum
*****              EXCEPTIONS
*****                plausibility_check_failed = 1
*****                OTHERS                    = 2.
*****            IF sy-subrc <> 0.
*****              PERFORM f_screen_modify USING 'PT3' ''
*****              'Date error'.
*****            ENDIF.
*****          ENDIF.
******        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF radio1 IS NOT INITIAL OR
    radio2 IS NOT INITIAL.
    IF pa_kunnr IS NOT INITIAL.
      SELECT SINGLE *
        FROM zfgstmmt_cust
        INTO CORRESPONDING FIELDS OF gs_cust
        WHERE bukrs = pa_bukrs
          AND vkbur = pa_gsber
          AND kunnr = pa_kunnr.
      IF sy-subrc <> 0.
        PERFORM f_screen_modify USING 'KTM' '1'
        'Cust.No. Bukan Outlet TMMT'.
      ENDIF.
    ELSE.
      IF pa_subty = '15' OR pa_subty = '57'.
        PERFORM f_screen_modify USING 'KTM' '1'
        'Fill in all required entry fields'.
      ENDIF.
    ENDIF.
    IF pa_subty = '15' OR pa_subty = '57'.
      IF pa_prd1 IS INITIAL.
        PERFORM f_screen_modify USING 'PR1' '1'
        'Periode Promo from tidak boleh kosong'.
      ELSE.
      ENDIF.
      IF pa_prd2 IS INITIAL.
        PERFORM f_screen_modify USING 'PR2' '1'
        'Periode Promo to tidak boleh kosong'.
      ELSE.
      ENDIF.
      IF pa_kdgrp IS INITIAL.
        PERFORM f_screen_modify USING 'KDG' '1'
        'Customer Group tidak boleh kosong'.
      ELSE.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_9000

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_MODIFY
*&---------------------------------------------------------------------*
FORM f_screen_modify  USING    fu_group fu_input fu_mess.
  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = fu_input.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH fu_mess.
ENDFORM.                    " F_SCREEN_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_GET_FILENAME
*&---------------------------------------------------------------------*
FORM f_get_filename .
  DATA: lv_repid LIKE sy-repid.
  lv_repid = sy-repid.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = lv_repid
      dynpro_number = sy-dynnr
      field_name    = 'PA_FILEC'
    IMPORTING
      file_name     = pa_filec
    EXCEPTIONS
      OTHERS        = 1.
  IF sy-subrc <> 0.
    CLEAR pa_filec.
  ENDIF.
ENDFORM.                    " F_GET_FILENAME

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_FILE_TO_SERVER
*&---------------------------------------------------------------------*
FORM f_move_file_to_server  USING fu_file.
  CALL FUNCTION 'ZAB_MOVE_FILE_TO_SERVER'
    EXPORTING
      local_file  = fu_file
      server_path = gc_path
    IMPORTING
      server_file = fu_file.
ENDFORM.                    " F_MOVE_FILE_TO_SERVER

*&---------------------------------------------------------------------*
*&      Form  F_GET_CLAIMAMT
*&---------------------------------------------------------------------*
FORM f_get_claimamt  USING    fu_vat
                              fu_pph
                              fu_wrbtr
                     CHANGING fu_claimamt.
  fu_claimamt = fu_wrbtr / ( ( 100 + fu_vat - fu_pph ) / 100 ).
ENDFORM.                    " F_GET_CLAIMAMT

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_FILENAME
*&---------------------------------------------------------------------*
FORM f_split_filename  USING    fu_filename
                       CHANGING fc_file
                                fc_ext.
  SPLIT fu_filename AT '.' INTO fc_file fc_ext.
ENDFORM.                    " F_SPLIT_FILENAME

*&---------------------------------------------------------------------*
*&      Form  F_GET_TMMT_KUNNR
*&---------------------------------------------------------------------*
FORM f_get_tmmt_kunnr USING   fu_field.
  TYPES : BEGIN OF ty_cust,
            kunnr TYPE zfgstmmt_cust-kunnr,
            zdesc TYPE zfgstmmt_cust-zdesc,
            kdgrp TYPE zfgstmmt_cust-kdgrp,
          END OF ty_cust.

  DATA : lt_cust  TYPE STANDARD TABLE OF ty_cust,
         ls_cust  LIKE LINE OF lt_cust,
         lv_subrc TYPE sy-subrc,
         lv_kunnr TYPE kna1-kunnr.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  SELECT *
    FROM zfgstmmt_cust
    INTO CORRESPONDING FIELDS OF TABLE lt_cust
    WHERE bukrs = pa_bukrs
      AND vkbur = pa_gsber.

  ASSIGN lt_cust[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'KUNNR' fu_field
                          CHANGING lv_subrc.

  IF lv_subrc = 0.
    READ TABLE return_tab INTO ls_return INDEX 1.
    IF sy-subrc = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_return-fieldval
        IMPORTING
          output = lv_kunnr.

      READ TABLE lt_cust INTO ls_cust WITH KEY kunnr = lv_kunnr.
      IF sy-subrc = 0.
*        gv_name1 = ls_cust-zdesc.
        PERFORM f_dynpfield TABLES dynpfields
                            USING fu_field ls_cust-kunnr ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'GV_NAME1' ls_cust-zdesc ''.
        PERFORM f_dynpfield TABLES dynpfields
                            USING 'PA_KDGRP' ls_cust-kdgrp ''.
        IF ls_cust-kdgrp IS NOT INITIAL.
          gv_kunnr = ls_cust-kunnr.
          gv_kdgrp = ls_cust-kdgrp.
        ELSE.
          CLEAR: gv_kunnr,gv_kdgrp.
        ENDIF.
      ENDIF.

      PERFORM f_dyn_values_update.

*      cl_gui_cfw=>set_new_ok_code( 'REFRESH' ).
      CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
        EXPORTING
          functioncode = 'REFRESH'
        EXCEPTIONS
          OTHERS       = 0.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_GET_TMMT_KUNNR

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
*&      Form  F_DYNPFIELD
*&---------------------------------------------------------------------*
FORM f_dynpfield  TABLES   dynpfields STRUCTURE dynpread
                  USING    fieldname fieldvalue fu_waers.

  DATA : ls_dynpfields  LIKE LINE OF dynpfields.

  ls_dynpfields-fieldname  = fieldname.
  IF fu_waers IS NOT INITIAL.
    ls_dynpfields-fieldvalue = fieldvalue.
    TRANSLATE ls_dynpfields-fieldvalue USING '. '.
    CONDENSE ls_dynpfields-fieldvalue NO-GAPS.
  ELSE.
    ls_dynpfields-fieldvalue = fieldvalue.
  ENDIF.
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
      undefind_error       = 7.
ENDFORM.                    " F_DYN_VALUES_UPDATE

*&---------------------------------------------------------------------*
*&      Form  F_POPUP_CUST
*&---------------------------------------------------------------------*
FORM f_popup_cust .
  CASE 'X'.
*    WHEN radio1.
*      CLEAR gt_clno.
*      SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_clno
*        FROM zclnumber WHERE kdgrp = pa_kdgrp
*                         AND datab BETWEEN pa_prd1 AND pa_prd2
*                         AND ( datbi BETWEEN pa_prd1 AND pa_prd2 OR datbi GT pa_prd2 )
*        ORDER BY kdgrp datbi datab matkl clnr.

    WHEN radio1 OR radio2.
      DATA(lv_kdgrp) = VALUE #( gt_clno[ 1 ]-kdgrp OPTIONAL ).
      IF gt_clno[] IS INITIAL OR lv_kdgrp NE pa_kdgrp.
        CLEAR gt_clno.
        SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_clno
          FROM zclnumber WHERE kdgrp = pa_kdgrp
                           AND ( datab BETWEEN pa_prd1 AND pa_prd2 OR datab LE pa_prd1 )
                           AND ( datbi BETWEEN pa_prd1 AND pa_prd2 OR datbi GT pa_prd2 )
          ORDER BY kdgrp datbi datab matkl clnr.

        LOOP AT gt_clno ASSIGNING FIELD-SYMBOL(<fs_clno>) WHERE chkbx = space.
          IF line_exists( gt_zfgscab_cl[ kdgrp = <fs_clno>-kdgrp
                                         matkl = <fs_clno>-matkl
                                         clnr  = <fs_clno>-clnr ] ).
            <fs_clno>-chkbx = 'X'.
          ENDIF.
        ENDLOOP.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

* Display ALV
  CALL SCREEN 100 STARTING AT 5 3
                  ENDING AT 150 20.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_GET_KDGRP
*&---------------------------------------------------------------------*
FORM f_get_kdgrp  USING    fu_field TYPE help_info-dynprofld.
  DATA: lt_return_tab TYPE STANDARD TABLE OF ddshretval.

  SELECT DISTINCT kdgrp INTO TABLE @DATA(lt_kdgrp)
    FROM zclnumber.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'KDGRP'      " Field dari tabel internal
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = fu_field     " Field di selection screen (PA_KDGRP)
      value_org       = 'S'          " S untuk struktur tabel
    TABLES
      value_tab       = lt_kdgrp
      return_tab      = lt_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc = 0.
    DATA(lv_value) = VALUE #( lt_return_tab[ 1 ]-fieldval OPTIONAL ).
    PERFORM f_dynpfield TABLES dynpfields
                        USING fu_field lv_value ''.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT_LVC
*&---------------------------------------------------------------------*
FORM f_build_fieldcat_lvc .
  REFRESH: gt_fieldcat.
  PERFORM f_fieldcatg_lvc USING 'GT_CLNO' :
    'CHKBX' 'ZSTCLNUMBER' 'CHKBX' '' '3' '' '' '' '' '' '' '' '' 'X' 'X' '',
    'KDGRP' 'ZCLNUMBER' 'KDGRP' '' '20' '' '' '' '' '' '' '' '' '' '' '',
    'DATAB' 'ZCLNUMBER' 'DATAB' '' '10' '' '' '' '' '' '' '' '' '' '' '',
    'DATBI' 'ZCLNUMBER' 'DATBI' '' '10' '' '' '' '' '' '' '' '' '' '' '',
    'MATKL' 'ZCLNUMBER' 'MATKL' '' '30' '' '' '' '' '' '' '' '' '' '' '',
    'SKPNR' 'ZCLNUMBER' 'SKPNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'CLNR'  'ZCLNUMBER' 'CLNR'  '' '' '' '' '' '' '' '' '' '' '' '' ''.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT2_LVC
*&---------------------------------------------------------------------*
FORM f_build_layout_lvc .
  gs_layout-zebra              = 'X'.
  gs_layout-cwidth_opt         = space.
  gs_layout-col_opt            = 'X'.
  gs_layout-no_headers         = space.
  gs_layout-no_rowmark         = 'X'.
  gs_layout-box_fname          = 'CHKBX'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  PBO100  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo100 OUTPUT.
  SET PF-STATUS 'STATUS_100'..

  IF g_custom_container IS INITIAL.
*  IF g_grid IS INITIAL.
    CLEAR: g_custom_container,g_grid,gs_layout,gt_fieldcat.

    PERFORM f_build_fieldcat_lvc.
    PERFORM f_build_layout_lvc.
    PERFORM f_toolbar_excluding.

* Create_object_container
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = g_container.

* Create Splitter untuk header
    CREATE OBJECT g_splitter
      EXPORTING
        parent  = g_custom_container
        rows    = 2
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_cont_top.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 2
        column    = 1
      RECEIVING
        container = g_cont_btm.

    CALL METHOD g_splitter->set_row_height
      EXPORTING
        id     = 1
        height = 10.

    CREATE OBJECT g_grid
      EXPORTING
        i_parent = g_cont_btm.


* Create_object_grid
*    CREATE OBJECT g_grid
*      EXPORTING
*        i_parent = g_custom_container.    "g_dialog.

* Create_event & handler
    DATA: lo_handler TYPE REF TO lcl_event_handler. " Variabel ini bisa didefinisikan global
    CREATE OBJECT lo_handler.
    SET HANDLER lo_handler->handle_toolbar FOR g_grid.
    SET HANDLER lo_handler->handle_user_command FOR g_grid.
*    SET HANDLER lo_handler->handle_top_of_page FOR g_grid.

* Create_display_ALV
    CALL METHOD g_grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layout
        it_toolbar_excluding = gt_exclude
        i_default            = 'X'
        i_save               = 'A'
        is_variant           = gs_variant
      CHANGING
        it_fieldcatalog      = gt_fieldcat[]
        it_outtab            = gt_clno[]
        it_sort              = gt_sort[].

* Initializing document
*    CALL METHOD dg_dyndoc_id->initialize_document.

* Processing events
*    CALL METHOD g_grid->list_processing_events
*      EXPORTING
*        i_event_name = 'TOP_OF_PAGE'
*        i_dyndoc_id  = dg_dyndoc_id.

* When edit display
    CALL METHOD g_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    PERFORM f_write_header.

  ELSE.
    CALL METHOD g_grid->refresh_table_display( ).
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  PAI100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai100 INPUT.
  CASE sy-ucomm.
    WHEN 'RW' OR 'BACK' OR 'ESC' OR 'CANCL'.
      CALL METHOD g_grid->free.
      CALL METHOD g_custom_container->free.
      FREE: g_grid,g_custom_container.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL_CHECKBOXES
*&---------------------------------------------------------------------*
FORM select_all_checkboxes USING fu_chkbx.
  DATA: lt_filtered_entries TYPE lvc_t_fidx.                "#EC NEEDED
  DATA: lt_filter TYPE lvc_t_filt.                          "#EC NEEDED

  g_grid->get_filtered_entries(
    IMPORTING et_filtered_entries = lt_filtered_entries ).

  g_grid->get_filter_criteria(
    IMPORTING et_filter = lt_filter ).

  IF lt_filter[] IS INITIAL.
    " Jika tidak ada filter aktif, centang semua baris
    LOOP AT gt_clno ASSIGNING FIELD-SYMBOL(<fs_clno>).
      <fs_clno>-chkbx = fu_chkbx.
    ENDLOOP.
  ELSE.
    " Jika ada filter, HANYA centang baris yang lolos filter
    LOOP AT gt_clno ASSIGNING <fs_clno>.
      READ TABLE lt_filtered_entries WITH KEY table_line = sy-tabix TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0 AND <fs_clno>-chkbx NE fu_chkbx.
        <fs_clno>-chkbx = fu_chkbx.
      ENDIF.
    ENDLOOP.
  ENDIF.

  PERFORM f_refresh_alv.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_TOOLBAR_EXCLUDING
*&---------------------------------------------------------------------*
FORM f_toolbar_excluding .
  DATA ls_exclude TYPE ui_func.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_print .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy .
  APPEND ls_exclude TO gt_exclude.

  CLEAR ls_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row .
  APPEND ls_exclude TO gt_exclude.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_REFRESH_ALV
*&---------------------------------------------------------------------*
FORM f_refresh_alv .
  DATA: ls_stable  TYPE lvc_s_stbl.

  ls_stable-row = 'X'.
  ls_stable-col = 'X'.

  IF g_grid IS BOUND.
    CALL METHOD g_grid->refresh_table_display
      EXPORTING
        is_stable = ls_stable.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_HEADER
*&---------------------------------------------------------------------*
FORM f_write_header .
  DATA: lv_title    TYPE text255,
        lv_prd1(10), lv_prd2(10).

  WRITE: pa_prd1 TO lv_prd1,
         pa_prd2 TO lv_prd2.

  SELECT SINGLE zdesc INTO @DATA(lv_desc)
  FROM zfgstmmt_cust  WHERE bukrs = @pa_bukrs
                        AND vkbur = @pa_gsber
                        AND kunnr = @pa_kunnr.


  lv_title = |Customer : { pa_kunnr }-{ lv_desc } / Period: { lv_prd1 } - { lv_prd2 }|.

  CREATE OBJECT g_dyndoc_id.

  " Tambahkan teks judul
  CALL METHOD g_dyndoc_id->add_text
    EXPORTING
      text          = lv_title
*     sap_style     = 'HEADING'.
      sap_style     = 'NORMAL'
      sap_fontstyle = 'BOLD'.
*      sap_color     = cl_dd_document=>col_heading.

*  CALL METHOD g_dyndoc_id->add_gap( ). " Spasi

*  " Tambahkan info lain
*  CALL METHOD g_dyndoc_id->add_text
*    EXPORTING
*      text = |Tanggal: { sy-datum DATE = USER }|.

  " Tampilkan di container atas
  CALL METHOD g_dyndoc_id->display_document
    EXPORTING
      parent = g_cont_top.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

ENDMODULE.
