*----------------------------------------------------------------------*
*   INCLUDE ZF_GSPOST_TMMTF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA: month_names LIKE t247 OCCURS 0 WITH HEADER LINE.

  SELECT bschl shkzg koart
    FROM tbsl
    INTO TABLE gt_tbsl.

  CALL FUNCTION 'MONTH_NAMES_GET'
    EXPORTING
      language              = sy-langu
    TABLES
      month_names           = month_names
    EXCEPTIONS
      month_names_not_found = 1
      OTHERS                = 2.

  READ TABLE month_names WITH KEY mnr = pa_datum+4(2).
  IF sy-subrc EQ 0.
    CONCATENATE 'G/S Periode' month_names-ktx pa_datum(4) INTO gv_bktxt
    SEPARATED BY space.
  ENDIF.

  SELECT zsubtype zstext loekz
    FROM zfgssubtyt
    INTO TABLE gt_subtype.

  SELECT gsber hkont
    FROM zfgsgsber
    INTO TABLE gt_zfgsgsber
    WHERE ztype EQ pa_ztype.

  SELECT SINGLE bukrs name1 street post_code1 city1 tel_number fax_number waers
    FROM t001 AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
    INTO gv_t001
    WHERE bukrs EQ pa_bukrs.

  SELECT SINGLE fname petugas1 jabat1 petugas2 jabat2 graph
    FROM zfgstt
    INTO (gv_fname, gv_petugas1, gv_jabat1, gv_petugas2, gv_jabat2, gv_graph)
    WHERE gsber   EQ '0200'
      AND zform   EQ 'TM'.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: lr_budat TYPE RANGE OF budat,
        lr_line  LIKE LINE OF lr_budat.

  DATA: lt_zfgscab    LIKE gt_zfgscab OCCURS 0 WITH HEADER LINE,
        lt_bseg       LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
        lt_kna1       LIKE gt_zfgscab OCCURS 0 WITH HEADER LINE,
        lt_kna11      LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
        lt_zfgsdntmmt LIKE gt_zfgsdntmmt OCCURS 0 WITH HEADER LINE.

  CONCATENATE pa_datum(6) '01' INTO lr_line-low.
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
      SELECT bukrs gsber belnr gjahr buzei budat bldat xblnr xref2 xref3 zuonr
             sgtxt zgsno ztype zsubtype vbund kunnr waers shkzg wrbtr
             hkont txt1 txt2 txt3 txt4 belnrgs belnrpost belnrdn gjahrpost
             userpost tglpost jampost belnrrev belnrrevdn userrev tglrev
        FROM zfgscab
        INTO TABLE gt_zfgscab
        WHERE bukrs      EQ pa_bukrs AND
              zgsno      IN so_zgsno AND
              ztype      EQ pa_ztype AND
              zsubtype   EQ pa_subty AND
              belnrpost  NE space    AND
              belnrdn    EQ space.

      CHECK gt_zfgscab[] IS NOT INITIAL.

      lt_zfgscab[] = gt_zfgscab[].
      SORT lt_zfgscab BY belnrpost gjahrpost.
      DELETE ADJACENT DUPLICATES FROM lt_zfgscab COMPARING belnrpost gjahrpost.

      IF lt_zfgscab[] IS NOT INITIAL.
        SELECT bukrs belnr gjahr budat xblnr bktxt
          FROM bkpf
          INTO TABLE gt_bkpf
          FOR ALL ENTRIES IN lt_zfgscab
          WHERE bukrs EQ pa_bukrs
            AND belnr EQ lt_zfgscab-belnrpost
            AND gjahr EQ lt_zfgscab-gjahrpost.

        SELECT bukrs belnr gjahr buzei bschl koart shkzg dmbtr zuonr hkont
          FROM bseg
          INTO TABLE gt_bseg
          FOR ALL ENTRIES IN lt_zfgscab
          WHERE bukrs EQ pa_bukrs
            AND belnr EQ lt_zfgscab-belnrpost
            AND gjahr EQ lt_zfgscab-gjahrpost.

        lt_bseg[] = gt_bseg[].
        SORT lt_bseg BY hkont.
        DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING hkont.
        IF lt_bseg[] IS NOT INITIAL.
          SELECT saknr txt20
            FROM skat
            INTO TABLE gt_skat
            FOR ALL ENTRIES IN lt_bseg
            WHERE spras EQ sy-langu AND
                  ktopl EQ 'TSPC'   AND
                  saknr EQ lt_bseg-hkont.
        ENDIF.
      ENDIF.

      lt_kna1[] = gt_zfgscab[].
      SORT lt_kna1 BY vbund.
      DELETE ADJACENT DUPLICATES FROM lt_kna1 COMPARING vbund.
      IF lt_kna1[] IS NOT INITIAL.
        SELECT rcomp name2
          FROM t880
          INTO TABLE gt_t880
          FOR ALL ENTRIES IN lt_kna1
          WHERE rcomp EQ lt_kna1-vbund
            AND langu EQ sy-langu.

        SELECT vbund kunnr zterm
          FROM zfgskunnr
          INTO TABLE gt_zfgskunnr
          FOR ALL ENTRIES IN lt_kna1
          WHERE vbund EQ lt_kna1-vbund.

        IF gt_zfgskunnr[] IS NOT INITIAL.
          SELECT a~kunnr b~name1 street post_code1 city1
            FROM kna1 AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
            INTO TABLE gt_kna1
            FOR ALL ENTRIES IN gt_zfgskunnr
            WHERE a~kunnr EQ gt_zfgskunnr-kunnr.
        ENDIF.
      ENDIF.

      IF ( pa_ztype = 'R' AND
        pa_subty = '15' ) OR
        ( pa_ztype = 'D' AND
        pa_subty = '57' ).
        PERFORM f_get_tmmt_additional.
      ENDIF.

    WHEN radio2.
      SELECT bukrs gsber belnr gjahr nomordn belnrdn belnrdnrev bktxt
        xblnr nopaaf maktx xref2 xref3 waers wrbtr kunnr budat
        FROM zfgsdntmmt
        INTO CORRESPONDING FIELDS OF TABLE gt_zfgsdntmmt
        WHERE bukrs   EQ pa_bukrs
          AND nomordn IN so_nodn
          AND flag    EQ space.

      lt_zfgsdntmmt[] = gt_zfgsdntmmt[].
      SORT lt_zfgsdntmmt BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_zfgsdntmmt COMPARING kunnr.

      IF lt_zfgsdntmmt[] IS NOT INITIAL.
        SELECT a~kunnr b~name1 street post_code1 city1
          FROM kna1 AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
          INTO TABLE gt_kna1
          FOR ALL ENTRIES IN lt_zfgsdntmmt
          WHERE a~kunnr EQ lt_zfgsdntmmt-kunnr.
      ENDIF.

    WHEN radio3.
      SELECT bukrs gsber belnr gjahr buzei budat bldat xblnr xref2 xref3 zuonr
             sgtxt zgsno ztype zsubtype vbund kunnr waers shkzg wrbtr
             hkont txt1 txt2 txt3 txt4 belnrgs belnrpost belnrdn gjahrpost
             userpost tglpost jampost belnrrev belnrrevdn userrev tglrev
        FROM zfgscab
        INTO TABLE gt_zfgscab
        WHERE bukrs      EQ pa_bukrs AND
              zgsno      IN so_zgsno AND
              ztype      EQ pa_ztype AND
              zsubtype   EQ pa_subty AND
              belnrpost  NE space    AND
              belnrdn    IN so_nodn.

      CHECK gt_zfgscab[] IS NOT INITIAL.

      SELECT bukrs gsber belnr gjahr nomordn belnrdn belnrdnrev bktxt
        xblnr nopaaf maktx xref2 xref3 waers wrbtr kunnr budat
        FROM zfgsdntmmt
        INTO CORRESPONDING FIELDS OF TABLE gt_zfgsdntmmt
        FOR ALL ENTRIES IN gt_zfgscab
        WHERE bukrs   EQ gt_zfgscab-bukrs
          AND gsber   EQ gt_zfgscab-gsber
          AND belnr   EQ gt_zfgscab-belnr
          AND gjahr   EQ gt_zfgscab-gjahr
          AND nomordn IN so_nodn
          AND flag    EQ space.

    WHEN radio4.
      SELECT bukrs belnr gjahr budat xblnr bktxt
      FROM bkpf
      INTO TABLE gt_bkpf
      WHERE bukrs EQ pa_bukrs
        AND belnr IN so_belnr
        AND gjahr EQ pa_gjahr.

      IF gt_bkpf[] IS NOT INITIAL.
        SELECT bukrs belnr gjahr buzei bschl koart shkzg dmbtr zuonr hkont
          wrbtr vbund xref1 xref2 xref3
          FROM bseg
          INTO TABLE gt_bseg
          FOR ALL ENTRIES IN gt_bkpf
          WHERE bukrs EQ pa_bukrs
            AND belnr EQ gt_bkpf-belnr
            AND gjahr EQ gt_bkpf-gjahr.

        SELECT bukrs gsber belnr gjahr nomordn belnrdn belnrdnrev bktxt
          xblnr nopaaf maktx xref2 xref3 waers wrbtr kunnr budat
          FROM zfgsdntmmt
          INTO CORRESPONDING FIELDS OF TABLE gt_zfgsdntmmt
          FOR ALL ENTRIES IN gt_bkpf
          WHERE bukrs   EQ pa_bukrs
            AND belnr   EQ gt_bkpf-belnr
            AND gjahr   EQ gt_bkpf-gjahr.
      ENDIF.

      lt_bseg[] = gt_bseg[].
      SORT lt_bseg BY hkont.
      DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING hkont.
      IF lt_bseg[] IS NOT INITIAL.
        SELECT saknr txt20
          FROM skat
          INTO TABLE gt_skat
          FOR ALL ENTRIES IN lt_bseg
          WHERE spras EQ sy-langu AND
                ktopl EQ 'TSPC'   AND
                saknr EQ lt_bseg-hkont.
      ENDIF.

      lt_kna11[] = gt_bseg[].
      SORT lt_kna11 BY vbund.
      DELETE ADJACENT DUPLICATES FROM lt_kna11 COMPARING vbund.
      IF lt_kna11[] IS NOT INITIAL.
        SELECT rcomp name2
          FROM t880
          INTO TABLE gt_t880
          FOR ALL ENTRIES IN lt_kna11
          WHERE rcomp EQ lt_kna11-vbund
            AND langu EQ sy-langu.

        SELECT vbund kunnr zterm
          FROM zfgskunnr
          INTO TABLE gt_zfgskunnr
          FOR ALL ENTRIES IN lt_kna11
          WHERE vbund EQ lt_kna11-vbund.

        IF gt_zfgskunnr[] IS NOT INITIAL.
          SELECT a~kunnr b~name1 street post_code1 city1
            FROM kna1 AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
            INTO TABLE gt_kna1
            FOR ALL ENTRIES IN gt_zfgskunnr
            WHERE a~kunnr EQ gt_zfgskunnr-kunnr.
        ENDIF.
      ENDIF.

    WHEN radio5.
      SELECT bukrs gsber belnr gjahr buzei budat bldat xblnr xref2 xref3 zuonr
             sgtxt zgsno ztype zsubtype vbund kunnr waers shkzg wrbtr
             hkont txt1 txt2 txt3 txt4 belnrgs belnrpost belnrdn gjahrpost
             userpost tglpost jampost belnrrev belnrrevdn userrev tglrev
        FROM zfgscab
        INTO TABLE gt_zfgscab
        WHERE bukrs      EQ pa_bukrs AND
              ztype      EQ pa_ztype AND
              zsubtype   EQ pa_subty.

      CHECK gt_zfgscab[] IS NOT INITIAL.

      lt_zfgscab[] = gt_zfgscab[].
      SORT lt_zfgscab BY belnrdn.
      DELETE ADJACENT DUPLICATES FROM lt_zfgscab COMPARING belnrdn.
      DELETE lt_zfgscab WHERE belnrdn IS INITIAL.

      IF lt_zfgscab[] IS NOT INITIAL.
        SELECT bukrs gsber belnr gjahr nomordn belnrdn belnrdnrev bktxt
               xblnr nopaaf maktx xref2 xref3 waers wrbtr kunnr budat
          FROM zfgsdntmmt
          INTO CORRESPONDING FIELDS OF TABLE gt_zfgsdntmmt
          FOR ALL ENTRIES IN lt_zfgscab
          WHERE belnrdn EQ lt_zfgscab-belnrdn
            AND budat   IN so_buda1.
      ENDIF.

      CLEAR : lt_zfgscab[], lt_zfgscab.
      lt_zfgscab[] = gt_zfgscab[].
      SORT lt_zfgscab BY bukrs belnrpost gjahrpost.
      DELETE ADJACENT DUPLICATES FROM lt_zfgscab COMPARING bukrs belnrpost gjahrpost.

      IF lt_zfgscab[] IS NOT INITIAL.
        SELECT bukrs belnr gjahr budat xblnr bktxt
          FROM bkpf
          INTO TABLE gt_bkpf
          FOR ALL ENTRIES IN lt_zfgscab
          WHERE bukrs EQ lt_zfgscab-bukrs
            AND belnr EQ lt_zfgscab-belnrpost
            AND gjahr EQ lt_zfgscab-gjahrpost
            AND budat IN so_buda2.

        SELECT bukrs belnr gjahr buzei bschl koart shkzg dmbtr zuonr hkont
          FROM bseg
          INTO TABLE gt_bseg
          FOR ALL ENTRIES IN lt_zfgscab
          WHERE bukrs EQ lt_zfgscab-bukrs
            AND belnr EQ lt_zfgscab-belnrpost
            AND gjahr EQ lt_zfgscab-gjahrpost
            AND hkont EQ gc_hkont
            AND bschl EQ gc_bschl.
      ENDIF.

      CHECK gt_zfgsdntmmt[] IS NOT INITIAL.

      SELECT bukrs belnr gjahr buzei bschl koart shkzg dmbtr zuonr hkont
        FROM bseg
        APPENDING TABLE gt_bseg
        FOR ALL ENTRIES IN gt_zfgsdntmmt
        WHERE bukrs EQ gt_zfgsdntmmt-bukrs
          AND gjahr EQ gt_zfgsdntmmt-gjahr
          AND belnr EQ gt_zfgsdntmmt-belnrdn
          AND koart EQ gc_koart.

      lt_bseg[] = gt_bseg[].
      SORT lt_bseg BY hkont.
      DELETE ADJACENT DUPLICATES FROM lt_bseg COMPARING hkont.
      IF lt_bseg[] IS NOT INITIAL.
        SELECT saknr txt20 txt50
          FROM skat
          INTO TABLE gt_skat
          FOR ALL ENTRIES IN lt_bseg
          WHERE spras EQ sy-langu AND
                ktopl EQ 'TSPC'   AND
                saknr EQ lt_bseg-hkont.
      ENDIF.
  ENDCASE.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  gv_status = 0.
  CASE 'X'.
    WHEN radio5.
      PERFORM f_alv TABLES gt_out
                    USING 'X'.
    WHEN OTHERS.
      PERFORM f_alv TABLES gt_out
                    USING ''.
  ENDCASE.
ENDFORM.                    "F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report
           USING  fu_proc.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report
                              USING   fu_proc.
  PERFORM f_build_layout      USING   d_layout fu_proc.
  PERFORM f_build_sortfield   USING   t_alv_isort[] fu_proc.
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
                      USING  fu_proc.
  REFRESH: t_alv_fieldcat.

  CASE 'X'.
    WHEN radio1 OR radio4.
      IF fu_proc IS INITIAL.
        PERFORM f_fieldcatg USING ft_report:
          'ZGSNO' 'ZFGSCAB' 'ZGSNO' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
          'ZTYPE' 'ZFGSCAB' 'ZTYPE' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'ZSUBTYPE' 'ZFGSCAB' 'ZSUBTYPE' '' '' '' '' '' '' '' '' '' '' ''
          '' '',
          'KUNNR' 'ZFGSCAB' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'BELNRPOST' 'ZFGSCAB' 'BELNRPOST' '' '12' 'Doc.Jurnal KP' '' ''
          '' '' '' '' '' '' '' '',
          'BELNRGS' 'ZFGSCAB' 'BELNRGS' '' '12' 'Doc.Jurnal G/S' '' '' ''
          '' '' '' '' '' '' '',
          'BUDAT' 'BKPF' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'BLDAT' 'BKPF' 'BLDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'BKTXT' 'BKPF' 'BKTXT' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'XBLNR' 'BKPF' 'XBLNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'XREF2' '' '' '' '12' 'Reference 2' '' '' '' '' '' '' '' '' '' '',
          'XREF3' '' '' '' '20' 'Reference 3' '' '' '' '' '' '' '' '' '' '',
          'NOPAAF' '' '' '' '50' 'No. PAAF/CLP' '' '' '' '' '' '' '' '' '' '',
          'MAKTX' '' '' '' '50' 'Nama Produk' '' '' '' '' '' '' '' '' '' ''.
      ELSE.
        PERFORM f_fieldcatg USING ft_report:
          'ICON' '' '' '' '4' 'Sts' '' '' '' '' '' '' '' '' '' '',
          'BLART' 'BKPF' 'BLART' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'XBLNR' 'BKPF' 'XBLNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'BSCHL' 'BSEG' 'BSCHL' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'GSBER' 'BSEG' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'ACCOUNT' 'BSEG' 'HKONT' '' '' 'Account' '' '' '' '' '' '' '' '' '' '',
          'DESCRIPTION' '' '' '' '30' 'Description' '' '' '' '' '' '' '' '' '' '',
          'WRBTR' 'BSEG' 'WRBTR' '' '' '' 'X' '' '' 'IDR' '' '' '' '' '' ''.
      ENDIF.

    WHEN radio2 OR radio3.
      PERFORM f_fieldcatg USING ft_report:
        'BUKRS' 'ZFGSDNTMMT' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'ZFGSDNTMMT' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR' 'ZFGSDNTMMT' 'BELNR' '' '15' 'Doc.Post KP' '' '' '' '' '' '' '' '' '' '',
        'NOMORDN' 'ZFGSDNTMMT' 'NOMORDN' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNRDN' 'ZFGSDNTMMT' 'BELNRDN' '' '15' 'Doc.Post DN' '' 'X' '' '' ''
        '' '' '' '' ''.

    WHEN radio5.
      PERFORM f_fieldcatg USING ft_report:
        'BUDAT' 'BKPF' 'BUDAT' '' '17' 'Pstng Date Target' '' '' '' '' '' '' '' '' '' '',
        'ZTYPE' 'ZFGSCAB' 'ZTYPE' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZSUBTYPE' 'ZFGSCAB' 'ZSUBTYPE' '' '' '' '' '' '' '' '' '' '' ''
        '' '',
        'ZGSNO' 'ZFGSCAB' 'ZGSNO' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'CABANG' '' '' '' '50' 'Cabang' '' '' '' '' '' '' '' '' '' '',
        'ZUONR' '' '' '' '20' 'Status Supp.Doc.' '' '' '' '' '' '' '' '' '' '',
        'PRINCIPAL' '' '' '' '20' 'Principal' '' '' '' '' '' '' '' '' '' '',
        'WRBTR' 'ZFGSCAB' 'WRBTR' '' '' 'Amount Target' '' '' '' '' '' 'WAERS' '' '' '' '',
        'BUDATDN' 'BKPF' 'BUDAT' '' '17' 'Pstng Date DN' '' '' '' '' '' '' '' '' '' '',
        'NOMORDN' 'ZFGSDNTMMT' 'NOMORDN' '' '' 'No.DN/kuitansi' '' '' '' '' '' '' '' '' '' '',
        'XBLNR' 'BKPF' 'XBLNR' '' '' 'Nama Customer' '' '' '' '' '' '' '' '' '' '',
        'BKTXT' 'BKPF' 'BKTXT' '' '' 'Jenis Biaya' '' '' '' '' '' '' '' '' '' '',
        'XREF2' '' '' '' '12' 'Reference 2' '' '' 'Periode Promo' '' '' '' '' '' '' '',
        'MAKTX' '' '' '' '50' 'Nama Produk' '' '' '' '' '' '' '' '' '' '',
        'WRBTRDN' 'ZFGSCAB' 'WRBTR' '' '' 'Amount DN' '' '' '' '' '' 'WAERS' '' '' '' '',
        'NOPAAF' '' '' '' '50' 'No. PAAF/CLP' '' '' '' '' '' '' '' '' '' '',
        'BELNRREV' 'ZFGSCAB' 'BELNRREV' '' '12' 'No.Rev.Doc.GS' '' ''
        '' '' '' '' '' '' '' '',
        'BELNRDNREV' 'ZFGSDNTMMT' 'BELNRDNREV' '' '12' 'No.Rev.Doc.DN' '' ''
        '' '' '' '' '' '' '' ''.
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
FORM f_build_layout USING fu_layout TYPE slis_layout_alv
                          fu_proc.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
  IF fu_proc IS INITIAL.
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
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv
                             fu_proc.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CASE 'X'.
    WHEN radio1 OR radio4.
      IF fu_proc IS INITIAL.
        CLEAR ld_sort.
        ld_sort-fieldname = 'ZGSNO'.
        ld_sort-up        = 'X'.
        APPEND ld_sort TO fu_sort.
      ELSE.
        CLEAR ld_sort.
        ld_sort-fieldname = 'BLART'.
        ld_sort-up        = 'X'.
        ld_sort-group     = 'UL'.
        APPEND ld_sort TO fu_sort.
        CLEAR ld_sort.
        ld_sort-fieldname = 'XBLNR'.
        ld_sort-up        = 'X'.
        ld_sort-subtot    = 'X'.
        ld_sort-group     = 'UL'.
        APPEND ld_sort TO fu_sort.
        CLEAR ld_sort.
        ld_sort-fieldname = 'BSCHL'.
        ld_sort-up        = 'X'.
        APPEND ld_sort TO fu_sort.
      ENDIF.
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
  CLEAR: gl[], ar[], ap[], curr[], ext[].
  CLEAR: gt_header[], gt_error[].
  PERFORM f_unlock_table2 USING '0200' pa_budat(6) pa_ztype 'GS'.
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
    WHEN radio1 OR radio4.
      IF gv_status IS INITIAL.
        SET PF-STATUS 'TOSIMULATE'.
      ELSE.
        SET PF-STATUS 'TOEXECUTE'.
      ENDIF.

    WHEN radio2.
      SET PF-STATUS 'TOEXECUTE'.

    WHEN radio3.
      SET PF-STATUS 'TOREVERSE'.

    WHEN radio5.
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
  DATA : lt_bseg     LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
         lv_input(4),
         lv_length   TYPE i.

  CASE 'X'.
    WHEN radio1.
      LOOP AT gt_zfgscab.
        gt_out     = gt_zfgscab.
        gt_out-budat  = pa_datum.
        gt_out-bldat  = pa_datum.
        READ TABLE gt_zfgskunnr WITH KEY vbund  = gt_zfgscab-vbund.
        IF sy-subrc EQ 0.
          gt_out-kunnr  = gt_zfgskunnr-kunnr.
          gt_out-zterm  = gt_zfgskunnr-zterm.
        ENDIF.
        READ TABLE gt_bkpf WITH KEY bukrs = pa_bukrs
                                    belnr = gt_zfgscab-belnrpost
                                    gjahr = gt_zfgscab-gjahrpost.
        IF sy-subrc EQ 0.
          gt_out-xblnr  = gt_bkpf-xblnr.
          gt_out-bktxt  = gt_bkpf-bktxt.
        ENDIF.
        APPEND gt_out.
        CLEAR gt_out.
      ENDLOOP.

    WHEN radio2 OR radio3.
      LOOP AT gt_zfgsdntmmt.
        MOVE-CORRESPONDING gt_zfgsdntmmt TO gt_out.
        IF gt_out-vbund IS INITIAL.
          lv_length = strlen( gt_out-kunnr ).
          lv_length = lv_length - 4.
          lv_input  = gt_out-kunnr+lv_length(4).
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_input
            IMPORTING
              output = gt_out-vbund.
        ENDIF.
        APPEND gt_out.
      ENDLOOP.

    WHEN radio4.
      lt_bseg[]  = gt_bseg[].
      LOOP AT gt_bseg WHERE shkzg EQ 'S'.
        READ TABLE gt_zfgsdntmmt WITH KEY belnr = gt_bseg-belnr
                                          gjahr = gt_bseg-gjahr.
        IF sy-subrc EQ 0.
          CONTINUE.
        ELSE.
          MOVE-CORRESPONDING gt_bseg TO gt_out.
          gt_out-budat  = pa_datum.
          gt_out-bldat  = pa_datum.
          gt_out-belnrpost  = gt_bseg-belnr.
          gt_out-gjahrpost  = pa_gjahr.
          READ TABLE gt_zfgskunnr WITH KEY vbund  = gt_bseg-vbund.
          IF sy-subrc EQ 0.
            gt_out-kunnr  = gt_zfgskunnr-kunnr.
            gt_out-zterm  = gt_zfgskunnr-zterm.
          ENDIF.
          READ TABLE lt_bseg WITH KEY bukrs = pa_bukrs
                                      belnr = gt_bseg-belnr
                                      gjahr = gt_bseg-gjahr
                                      shkzg = 'H'.
          IF sy-subrc EQ 0.
            SHIFT lt_bseg-xref1 LEFT DELETING LEADING space.
            gt_out-gsber  = lt_bseg-xref1(4).
            gt_out-xref2  = lt_bseg-xref2.
            gt_out-xref3  = lt_bseg-xref3.
          ENDIF.
          READ TABLE gt_bkpf WITH KEY bukrs = pa_bukrs
                                      belnr = gt_bseg-belnr
                                      gjahr = gt_bseg-gjahr.
          IF sy-subrc EQ 0.
            gt_out-xblnr  = gt_bkpf-xblnr.
            gt_out-bktxt  = gt_bkpf-bktxt.
          ENDIF.
          APPEND gt_out.
        ENDIF.
      ENDLOOP.

    WHEN radio5.
      LOOP AT gt_zfgscab.
        MOVE-CORRESPONDING gt_zfgscab TO gt_out.
        READ TABLE gt_bkpf WITH KEY bukrs = gt_zfgscab-bukrs
                                    belnr = gt_zfgscab-belnrpost
                                    gjahr = gt_zfgscab-gjahrpost.
        IF sy-subrc EQ 0.
          gt_out-budat  = gt_bkpf-budat.
        ELSE.
          CONTINUE.
        ENDIF.

        READ TABLE gt_zfgsdntmmt WITH KEY belnrdn = gt_zfgscab-belnrdn.
        IF sy-subrc EQ 0.
          READ TABLE gt_bseg WITH KEY belnr = gt_zfgsdntmmt-belnrdn
                                      gjahr = gt_zfgsdntmmt-gjahr.
          IF sy-subrc EQ 0.
            READ TABLE gt_skat WITH KEY saknr = gt_bseg-hkont.
            IF sy-subrc EQ 0.
              CONCATENATE gt_bseg-hkont '-' gt_skat-txt50
              INTO gt_out-cabang
              SEPARATED BY space.
            ENDIF.
          ENDIF.
          gt_out-budatdn      = gt_zfgsdntmmt-budat.
          gt_out-nomordn      = gt_zfgsdntmmt-nomordn.
          gt_out-xblnr        = gt_zfgsdntmmt-xblnr.
          gt_out-bktxt        = gt_zfgsdntmmt-bktxt.
          gt_out-xref2        = gt_zfgsdntmmt-xref2.
          gt_out-maktx        = gt_zfgsdntmmt-maktx.
          gt_out-wrbtrdn      = gt_zfgsdntmmt-wrbtr.
          gt_out-nopaaf       = gt_zfgsdntmmt-nopaaf.
          gt_out-belnrdnrev   = gt_zfgsdntmmt-belnrdnrev.
        ENDIF.

        READ TABLE gt_bseg WITH KEY bukrs = gt_zfgscab-bukrs
                                    belnr = gt_zfgscab-belnrpost
                                    gjahr = gt_zfgscab-gjahrpost
                                    hkont = gc_hkont
                                    bschl = gc_bschl.
        IF sy-subrc EQ 0.
          gt_out-zuonr  = gt_bseg-zuonr.
        ENDIF.

        CONCATENATE gt_zfgscab-vbund '-' gt_zfgscab-kunnr
        INTO gt_out-principal
        SEPARATED BY space.

        gt_out-belnrrev   = gt_zfgscab-belnrrev.

        APPEND gt_out.
        CLEAR gt_out.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread   LIKE dynpread OCCURS 0 WITH HEADER LINE,
        wa_out        LIKE gt_out,
        ffield(20),
        fvalue(20),
        lv_error(100),
        lv_subrc      TYPE sy-subrc.

  GET CURSOR FIELD ffield VALUE fvalue.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&IC1'.
      CASE 'X'.
        WHEN radio1 OR radio4.
          CASE ffield.
            WHEN 'GT_OUT-ZSUBTYPE'.
              READ TABLE gt_out INDEX fu_selfield-tabindex INTO wa_out.
              pa_ztyp1  = pa_ztype.
              pa_subt1  = wa_out-zsubtype.
              CALL SELECTION-SCREEN 9000 STARTING AT 10 10.
              gt_out-zsubtype = pa_subt1.
              READ TABLE gt_subtype WITH KEY zsubtype = gt_out-zsubtype.
              IF sy-subrc EQ 0.
                IF gt_subtype-loekz IS INITIAL.
                  MODIFY gt_out TRANSPORTING zsubtype
                                WHERE belnr EQ wa_out-belnr.
                ELSE.
                  CONCATENATE 'Sub Type' gt_out-zsubtype 'not active' INTO lv_error
                  SEPARATED BY space.
                  MESSAGE e000(zab) WITH lv_error.
                ENDIF.
              ELSE.
                CONCATENATE 'Sub Type' gt_out-zsubtype 'not found' INTO lv_error
                SEPARATED BY space.
                MESSAGE e000(zab) WITH lv_error.
              ENDIF.
              PERFORM f_alv TABLES gt_out
                            USING ''.
              LEAVE TO SCREEN 0.

            WHEN 'GT_OUT-ZGSNO'.
              READ TABLE gt_out INDEX fu_selfield-tabindex INTO wa_out.
              pa_budat  = wa_out-budat.
              pa_bktxt  = wa_out-bktxt.
              pa_xblnr  = wa_out-xblnr.
              pa_xref2  = wa_out-xref2.
              pa_xref3  = wa_out-xref3.
              pa_nopaf  = wa_out-nopaaf.
              pa_maktx  = wa_out-maktx.

              IF radio1 EQ 'X'.
                PERFORM f_modify_xref2 USING wa_out-vbund pa_budat
                                       CHANGING pa_xref2.
              ENDIF.

              CALL SELECTION-SCREEN 9001 STARTING AT 10 10.

              IF sy-subrc EQ 0.
                PERFORM f_lock_table2 USING '0200' pa_budat(6) pa_ztype 'GS'.
                wa_out-budat  = pa_budat.
                wa_out-bldat  = pa_budat.
                wa_out-bktxt  = pa_bktxt.
                wa_out-xblnr  = pa_xblnr.
                wa_out-xref2  = pa_xref2.
                wa_out-xref3  = pa_xref3.
                wa_out-nopaaf = pa_nopaf.
                wa_out-maktx  = pa_maktx.
                MODIFY gt_out FROM wa_out INDEX fu_selfield-tabindex.
              ENDIF.
              PERFORM f_alv TABLES gt_out
                            USING ''.
              LEAVE TO SCREEN 0.
          ENDCASE.
        WHEN radio2 OR radio3.
          CASE ffield.
            WHEN 'GT_OUT-BELNRDN'.
              IF fvalue IS NOT INITIAL.
                READ TABLE gt_out INDEX fu_selfield-tabindex INTO wa_out.
                SET PARAMETER ID 'BLN' FIELD fvalue.
                SET PARAMETER ID 'BUK' FIELD pa_bukrs.
                SET PARAMETER ID 'GJR' FIELD wa_out-gjahr.
                CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
              ENDIF.
          ENDCASE.
      ENDCASE.

    WHEN '&LOG'.
      CALL SCREEN 500 STARTING AT 10 10 ENDING AT 132 22.

    WHEN '&SIM'.
      PERFORM f_free_memory.
      CLEAR: lv_subrc.
      PERFORM f_posting_data CHANGING lv_subrc.
      gv_status = 1.
      PERFORM f_alv TABLES gt_post
                    USING 'SIMULATE'.
      gv_status = 0.
      LEAVE TO SCREEN 0.

    WHEN '&POS'.
      CASE 'X'.
        WHEN radio1 OR radio4.
          CLEAR: gl[], ar[], ap[], curr[], ext[], lv_subrc.
          IF gt_error[] IS INITIAL.
            CASE 'X'.
              WHEN radio1 OR radio4.
                PERFORM f_get_dn_no CHANGING lv_subrc.
            ENDCASE.
            IF lv_subrc EQ 0.
              PERFORM f_post_entries.
            ELSE.
              MESSAGE e000(zab) WITH 'DN Number has not been maintained'.
            ENDIF.
          ELSE.
            MESSAGE e000(zab) WITH 'There is still incorrect data'.
          ENDIF.
          CLEAR: gt_error[].

        WHEN radio2.
          CLEAR : gt_post, gt_post[].
          LOOP AT gt_out WHERE check EQ 'X'.
            MOVE-CORRESPONDING gt_out TO gt_post.
            gt_post-bschl   = '01'.
            gt_post-account = gt_out-kunnr.
            APPEND gt_post.
          ENDLOOP.

          PERFORM f_print_dn USING gv_fname 'X'
                             CHANGING lv_subrc.
      ENDCASE.

    WHEN '&REV'.
      LOOP AT gt_out WHERE check EQ 'X'.
        PERFORM f_reverse USING gt_out-belnr gt_out-belnrdn.
      ENDLOOP.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.
  DATA: lv_subrc   TYPE sy-subrc,
        lwa_out    LIKE gt_out,
        lv_nomordn TYPE zdnno.

  obj_type = 'BKPF'.

  PERFORM f_print_dn USING gv_fname ''
                     CHANGING lv_subrc.

  IF lv_subrc IS NOT INITIAL.
    MESSAGE e000(zab) WITH 'DN Number has not been maintained'.
  ENDIF.

  CHECK lv_subrc EQ 0.

  IF radio1 EQ 'X' OR radio4 EQ 'X'.
    LOOP AT gt_out1 INTO lwa_out.
      CLEAR head.
      PERFORM f_get_header USING lwa_out
                           CHANGING head.

      CLEAR: gl[], ar[], ap[], curr[], ext[], criteria[], ret[].

      PERFORM f_detail_data TABLES gl ap ar curr ext criteria ret
                                   gt_post
                            USING  lwa_out
                            CHANGING lv_nomordn.

      IF pa_prev IS INITIAL.
        PERFORM f_bapi_document_post TABLES gl ap ar curr ext criteria ret
                                     USING lwa_out head obj_type lv_nomordn
                                     CHANGING lv_subrc.
        CHECK lv_subrc EQ 0.
      ENDIF.
    ENDLOOP.
  ENDIF.

  PERFORM f_unlock_table.
  PERFORM f_unlock_table2 USING '0200' pa_budat(6) pa_ztype 'GS'.

  MESSAGE s000(zab) WITH 'Data already processed'.
  LEAVE TO SCREEN 0.
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
        IF screen-group1 = 'NDN'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'BEL'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJA'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'BU1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'BU2'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio2.
      LOOP AT SCREEN.
        IF screen-group1 = 'GJA'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'ZTY'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'SU2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'ZGS'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DAT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'BEL'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'BU1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'BU2'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio3.
      LOOP AT SCREEN.
        IF screen-group1 = 'GJA'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DAT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'PRE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'BEL'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'BU1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'BU2'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio4.
      LOOP AT SCREEN.
        IF screen-group1 = 'NDN'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'ZGS'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'BU1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'BU2'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio5.
      LOOP AT SCREEN.
        IF screen-group1 = 'ZGS'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'NDN'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'BEL'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJA'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DAT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'PRE'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA: lv_mess(100)  VALUE 'Fill in all required entry fields',
        lv_error(100),
        lv_tmmt(1).

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

  CASE 'X'.
    WHEN radio1 OR radio3 OR radio4 OR radio5.
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

      IF pa_subty IS INITIAL.
        LOOP AT SCREEN.
          IF screen-group1 = 'SU2'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH lv_mess.
      ENDIF.

      IF pa_ztype IS NOT INITIAL AND
        pa_subty IS NOT INITIAL.
        SELECT SINGLE tmmt
          FROM zfgstype
          INTO lv_tmmt
          WHERE ztype EQ pa_ztype
            AND zsubtype EQ pa_subty.
        IF lv_tmmt IS INITIAL.
          LOOP AT SCREEN.
            IF screen-group1 = 'ZTY' OR
              screen-group1 = 'SU2'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH 'Error in Type and SubType'.
        ENDIF.
      ENDIF.

      IF radio1 EQ 'X' OR
        radio4 EQ 'X'.
        IF pa_datum IS INITIAL.
          LOOP AT SCREEN.
            IF screen-group1 = 'DAT'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH lv_mess.
        ENDIF.
      ENDIF.

      IF radio4 EQ 'X'.
        IF so_belnr[] IS INITIAL.
          LOOP AT SCREEN.
            IF screen-group1 = 'BEL'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH lv_mess.
        ENDIF.

        IF pa_gjahr IS INITIAL.
          LOOP AT SCREEN.
            IF screen-group1 = 'GJA'.
              screen-input  = 1.
            ELSE.
              screen-input  = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDLOOP.
          MESSAGE e000(zab) WITH lv_mess.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_SIMULATE
*&---------------------------------------------------------------------*
FORM f_simulate  USING    fwa_out      STRUCTURE gt_out.

  DATA : lv_nomordn   TYPE zdnno.

  CLEAR: gl, gl[], ap, ap[], ar, ar[], curr, curr[],
         ext, ext[], criteria, criteria[], ret, ret[].

  obj_type = 'BKPF'.

  IF head IS NOT INITIAL.
    PERFORM f_detail_data TABLES gl ap ar curr ext criteria ret
                                 gt_post
                          USING  fwa_out
                          CHANGING lv_nomordn.

    PERFORM f_bapi_document_check TABLES gl ap ar curr ext criteria ret
                                         gt_post
                                  USING  fwa_out head obj_type ''.
  ENDIF.
ENDFORM.                    " F_SIMULATE

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
    WRITE: / sy-vline, (20) gt_error-bktxt,
             sy-vline, (94) gt_error-message,
             sy-vline.
  ENDLOOP.
  WRITE: / sy-uline(121).
ENDFORM.                    " F_ERROR_LOG

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_DATA
*&---------------------------------------------------------------------*
FORM f_detail_data TABLES   accountgl         STRUCTURE bapiacgl09
                            accountpayable    STRUCTURE bapiacap09
                            accountreceivable STRUCTURE bapiacar09
                            currencyamount    STRUCTURE bapiaccr09
                            extension1        STRUCTURE bapiacextc
                            criteria          STRUCTURE bapiackec9
                            return            STRUCTURE bapiret2
                            ft_post           STRUCTURE gt_post
                    USING   fwa_out           STRUCTURE gt_out
                    CHANGING  fc_nomordn.

  DATA: lv_wrbtr  TYPE wrbtr.

  LOOP AT ft_post WHERE icon  EQ icon_led_green
                    AND bukrs EQ fwa_out-bukrs
                    AND belnr EQ fwa_out-belnr
                    AND gjahr EQ fwa_out-gjahr.
    IF ft_post-nomordn IS NOT INITIAL.
      fc_nomordn  = ft_post-nomordn.
    ENDIF.
    CASE ft_post-koart.
      WHEN 'D'.
        accountreceivable-itemno_acc    = ft_post-buzeipost.
        accountreceivable-customer      = ft_post-account.
*        accountreceivable-item_text     = ft_post-maktx.
        accountreceivable-item_text     = ft_post-sgtxt.
        accountreceivable-bus_area      = ft_post-gsber.
        accountreceivable-tax_code      = ft_post-mwskz.
        accountreceivable-alloc_nmbr    = ft_post-nomordn.
        accountreceivable-bline_date    = ft_post-budat.
        accountreceivable-ref_key_1     = ft_post-nopaaf.
        accountreceivable-ref_key_2     = ft_post-xref2.
        accountreceivable-pmnttrms      = ft_post-zterm.
        IF pa_xref3 IS INITIAL.
          accountreceivable-ref_key_3     = 'X'.
        ELSE.
          accountreceivable-ref_key_3     = ft_post-xref3.
        ENDIF.
        APPEND accountreceivable.
      WHEN 'K'.
        accountpayable-itemno_acc       = ft_post-buzeipost.
        accountpayable-vendor_no        = ft_post-account.
        accountpayable-item_text        = ft_post-maktx.
        accountpayable-bus_area         = ft_post-gsber.
        accountpayable-tax_code         = ft_post-mwskz.
        accountpayable-alloc_nmbr       = ft_post-nomordn.
        accountpayable-bline_date       = ft_post-zfbdt.
        accountpayable-ref_key_1        = ft_post-nopaaf.
        accountpayable-ref_key_2        = ft_post-xref2.
        accountpayable-pmnttrms         = ft_post-zterm.
        IF pa_xref3 IS INITIAL.
          accountpayable-ref_key_3        = 'X'.
        ELSE.
          accountpayable-ref_key_3        = ft_post-xref3.
        ENDIF.
        APPEND accountpayable.
      WHEN 'S'.
        accountgl-itemno_acc            = ft_post-buzeipost.
        accountgl-gl_account            = ft_post-account.
        accountgl-item_text             = ft_post-maktx.
        accountgl-bus_area              = ft_post-gsber.
        accountgl-tax_code              = ft_post-mwskz.
        accountgl-trade_id              = ft_post-vbund.
        accountgl-alloc_nmbr            = ft_post-nomordn.
        accountgl-ref_key_1             = ft_post-nopaaf.
        accountgl-ref_key_2             = ft_post-xref2.
        IF pa_xref3 IS INITIAL.
          accountgl-ref_key_3             = 'X'.
        ELSE.
          accountgl-ref_key_3             = ft_post-xref3.
        ENDIF.
        accountgl-costcenter            = ft_post-kostl.
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
         ' '  'BKPF-BUKRS'    gt_out-bukrs,
         ' '  'RF05A-GJAHS'   gt_out-gjahr,
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
        UPDATE zfgscab SET   belnrdn    = space
                             belnrrevdn = t_bdcmsg-msgv1
                             userrev    = sy-uname
                             tglrev     = sy-datum
                       WHERE belnr  EQ fu_belnr
                         AND bukrs  EQ gt_out-bukrs
                         AND gjahr  EQ gt_out-gjahr.

        UPDATE zfgsdntmmt SET   belnrdnrev = t_bdcmsg-msgv1
                                flag       = 'X'
                                zuserrev   = sy-uname
                                zdatumrev  = sy-datum
                          WHERE belnr  EQ fu_belnr
                            AND bukrs  EQ gt_out-bukrs
                            AND gjahr  EQ gt_out-gjahr.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_REVERSE

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data CHANGING fc_subrc.
  DATA: lwa_out  LIKE gt_out.

  LOOP AT gt_out WHERE check EQ 'X'.
    gt_out1  = gt_out.
    APPEND gt_out1.
  ENDLOOP.

  IF radio1 EQ 'X' OR radio4 EQ 'X'.
    IF gt_out1[] IS INITIAL.
      MESSAGE e000(zab) WITH 'No data to be processed'.
    ELSE.
      LOOP AT gt_out1 INTO lwa_out.
        CLEAR head.
        PERFORM f_get_header USING lwa_out
                             CHANGING head.

        PERFORM f_get_detail TABLES gt_post
                             USING lwa_out 'DR'.

        PERFORM f_simulate USING lwa_out.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_HEADER
*&---------------------------------------------------------------------*
FORM f_get_header  USING    fwa_out        STRUCTURE gt_out
                   CHANGING documentheader STRUCTURE bapiache09.

  documentheader-bus_act    = 'RFBU'.
  documentheader-username   = sy-uname.
  documentheader-comp_code  = pa_bukrs.
  documentheader-doc_date   = fwa_out-budat.
  documentheader-pstng_date = fwa_out-bldat.
  documentheader-doc_type   = 'DR'.
  documentheader-ref_doc_no = fwa_out-xblnr.
  documentheader-header_txt = fwa_out-bktxt.
ENDFORM.                    " F_GET_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_GET_DETAIL
*&---------------------------------------------------------------------*
FORM f_get_detail  TABLES   ft_post      STRUCTURE gt_post
                   USING    fwa_out      STRUCTURE gt_out
                            fu_blart.
  DATA: lt_kna1   LIKE gt_out OCCURS 0 WITH HEADER LINE,
        lv_wrbtr  TYPE wrbtr,
        lv_count  TYPE i,
        lv_bschl  TYPE bschl,
        lv_hkont  TYPE hkont,
        lv_hkont1 TYPE hkont.

  SORT gt_bseg BY bukrs belnr gjahr buzei DESCENDING.

  ft_post-zsubtype  = fwa_out-zsubtype.
  ft_post-blart     = fu_blart.
  ft_post-bukrs     = fwa_out-bukrs.
  ft_post-belnr     = fwa_out-belnr.
  ft_post-buzei     = fwa_out-buzei.
  ft_post-gjahr     = fwa_out-gjahr.
  ft_post-xblnr     = fwa_out-xblnr.
  ft_post-bktxt     = fwa_out-bktxt.
  ft_post-xref2     = fwa_out-xref2.
  ft_post-xref3     = fwa_out-xref3.
  ft_post-nopaaf    = fwa_out-nopaaf.
  ft_post-maktx     = fwa_out-maktx.
  ft_post-zterm     = fwa_out-zterm.

  IF pa_bukrs EQ '8020'.
    ft_post-gsber     = '0200'.
  ELSEIF pa_bukrs EQ '8070'.
    ft_post-gsber     = '0700'.
  ENDIF.

  ft_post-vbund     = fwa_out-vbund.

  IF radio1 EQ 'X'.
    READ TABLE gt_bseg WITH KEY bukrs = pa_bukrs
                                belnr = fwa_out-belnrpost
                                gjahr = fwa_out-gjahrpost.
    IF sy-subrc EQ 0.
      lv_hkont1 = gt_bseg-hkont.
      lv_wrbtr  = gt_bseg-dmbtr.
    ENDIF.
  ELSEIF radio4 EQ 'X'.
    lv_hkont1 = fwa_out-hkont.
    lv_wrbtr  = fwa_out-wrbtr.
  ENDIF.

  DO 2 TIMES.
    CLEAR: lv_bschl, lv_hkont.
    ADD 1 TO lv_count.
    CASE lv_count.
      WHEN 1.
        lv_bschl  = '01'.
        lv_hkont  = fwa_out-kunnr.
      WHEN 2.
        lv_bschl  = '50'.
        lv_hkont  = lv_hkont1.
        lv_wrbtr  = lv_wrbtr * -1.
    ENDCASE.

    PERFORM f_post_detail TABLES ft_post
                          USING fwa_out lv_bschl lv_hkont lv_wrbtr
                          CHANGING ft_post-buzeipost.
  ENDDO.
ENDFORM.                    " F_GET_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_POST_DETAIL
*&---------------------------------------------------------------------*
FORM f_post_detail  TABLES   ft_post  STRUCTURE gt_post
                    USING    fwa_out  STRUCTURE gt_out
                             fu_bschl fu_hkont fu_wrbtr
                    CHANGING fc_buzei.

  IF fu_bschl IS NOT INITIAL.
    ft_post-icon  = icon_led_green.
    ADD 1 TO fc_buzei.
    ft_post-buzeipost = fc_buzei.
    ft_post-bschl     = fu_bschl.
    ft_post-budat     = fwa_out-budat.
    ft_post-bldat     = fwa_out-bldat.
    ft_post-sgtxt     = fwa_out-sgtxt.
    READ TABLE gt_tbsl WITH KEY bschl = fu_bschl.
    IF sy-subrc EQ 0.
      ft_post-koart = gt_tbsl-koart.
      IF fu_bschl EQ '01'.
        CONCATENATE 'REIMBURSEMENT' fwa_out-bktxt fwa_out-xblnr
          INTO ft_post-sgtxt SEPARATED BY space.
        ft_post-account = fwa_out-kunnr.
        READ TABLE gt_kna1 WITH KEY kunnr = fwa_out-kunnr.
        IF sy-subrc EQ 0.
          ft_post-description = gt_kna1-name1.
        ENDIF.
      ELSE.
        ft_post-account = fu_hkont.
        READ TABLE gt_skat WITH KEY saknr = fu_hkont.
        IF sy-subrc EQ 0.
          ft_post-description = gt_skat-txt20.
        ENDIF.
      ENDIF.
      ft_post-wrbtr  = fu_wrbtr.
    ENDIF.
    APPEND ft_post.
  ELSE.
    ft_post-icon  = icon_led_red.
  ENDIF.
ENDFORM.                    " F_POST_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_DOCUMENT_CHECK
*&---------------------------------------------------------------------*
FORM f_bapi_document_check  TABLES   accountgl         STRUCTURE bapiacgl09
                                     accountpayable    STRUCTURE bapiacap09
                                     accountreceivable STRUCTURE bapiacar09
                                     currencyamount    STRUCTURE bapiaccr09
                                     extension1        STRUCTURE bapiacextc
                                     criteria          STRUCTURE bapiackec9
                                     return            STRUCTURE bapiret2
                                     ft_post           STRUCTURE gt_post
                            USING    fwa_out           STRUCTURE gt_out
                                     documentheader    STRUCTURE bapiache09
                                     obj_type fu_nomordn.

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
      criteria          = criteria
      return            = return.

  LOOP AT return.
    IF return-type = 'A' OR return-type = 'E'.
      gt_error-bktxt    = fwa_out-zgsno.
      gt_error-message  = return-message.
      lv_error          = 1.
      IF return-id NE 'RW' OR
        return-number NE '609'.
        APPEND gt_error.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lv_error IS NOT INITIAL.
    LOOP AT ft_post WHERE bukrs EQ pa_bukrs
                      AND belnr EQ fwa_out-belnr
                      AND gjahr EQ fwa_out-gjahr.
      ft_post-icon  = icon_led_red.
      MODIFY ft_post TRANSPORTING icon.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_BAPI_DOCUMENT_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_DOCUMENT_POST
*&---------------------------------------------------------------------*
FORM f_bapi_document_post  TABLES   accountgl         STRUCTURE bapiacgl09
                                    accountpayable    STRUCTURE bapiacap09
                                    accountreceivable STRUCTURE bapiacar09
                                    currencyamount    STRUCTURE bapiaccr09
                                    extension1        STRUCTURE bapiacextc
                                    criteria          STRUCTURE bapiackec9
                                    return            STRUCTURE bapiret2
                            USING   fwa_out           STRUCTURE gt_out
                                    documentheader    STRUCTURE bapiache09
                                    obj_type fu_nomordn
                            CHANGING fc_subrc.

  DATA: lv_zgsno TYPE zgsno,
        lv_belnr TYPE belnr_d,
        lv_gjahr TYPE gjahr.

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
      criteria          = criteria
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

*  PERFORM f_change_bline_date TABLES accountgl ft_post
*                              USING documentheader-doc_type lv_belnr pa_bukrs
*                                    lv_gjahr pa_budat.

  IF radio4 NE 'X'.
    UPDATE zfgscab SET belnrdn    = lv_belnr
                   WHERE bukrs EQ fwa_out-bukrs
                     AND gsber EQ fwa_out-gsber
                     AND belnr EQ fwa_out-belnr
                     AND gjahr EQ fwa_out-gjahr.
  ENDIF.

  PERFORM f_save_zfgsdntmmt USING    fwa_out lv_belnr '0'
                            CHANGING fc_subrc.

  IF radio4 EQ 'X'.
    PERFORM f_bdc_update_fb02 USING pa_bukrs fwa_out-belnr fwa_out-gjahr
                                    fu_nomordn.
  ELSEIF radio1 EQ 'X'.
    PERFORM f_bdc_update_fb02 USING pa_bukrs fwa_out-belnrpost
                                    fwa_out-gjahrpost
                                    fu_nomordn.
  ENDIF.

  fc_subrc  = sy-subrc.
ENDFORM.                    " F_BAPI_DOCUMENT_POST

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DN
*&---------------------------------------------------------------------*
FORM f_print_dn USING p_formname TYPE tdsfname fu_reprint
                CHANGING fc_subrc.

  DATA: l_funcname         TYPE tdsfname,
        l_total_pages      TYPE tdsffpage,
        lwa_control_option TYPE ssfctrlop,
        lwa_output_option  TYPE ssfcompop,
        lwa_doc_info       TYPE ssfcrespd,
        lwa_output_info    TYPE ssfcrescl.

  DATA: lv_wrbtr     TYPE wrbtr,
        lv_period(4),
        lv_nomor     TYPE znomor2,
        lv_spmon     TYPE spmon,
        lv_kunnr     TYPE kunnr,
        in_words     LIKE spell OCCURS 0 WITH HEADER LINE.

  DATA : ls_out       LIKE LINE OF gt_out.

  CLEAR : gt_head, gt_head[].

  gt_nomor_temp[] = gt_zfgsnomor[].

  SORT gt_post BY account DESCENDING.
  LOOP AT gt_post.
    IF gt_post-bschl EQ '01'.
      gt_head        = gv_t001.
      gt_head-belnr  = gt_post-belnr.
      gt_head-vbund  = gt_post-vbund.
      gt_head-kunnr  = gt_post-account.
      CASE 'X'.
        WHEN radio2.
          gt_head-nomordn  = gt_post-nomordn.
      ENDCASE.
      gt_head-waers  = 'IDR'.
      gt_head-wrbtr  = gt_post-wrbtr.
      gt_head-nopaaf = gt_post-nopaaf.
      gt_head-bktxt  = gt_post-bktxt.
      gt_head-xblnr  = gt_post-xblnr.
      gt_head-xref2  = gt_post-xref2.
      gt_head-maktx  = gt_post-maktx.
      WRITE gt_post-budat TO gt_head-datum DD/MM/YYYY.
      READ TABLE gt_kna1 WITH KEY kunnr = gt_post-account.
      IF sy-subrc EQ 0.
        gt_head-name1_to       = gt_kna1-name1.
        gt_head-street_to      = gt_kna1-street.
        gt_head-post_code1_to  = gt_kna1-post_code1.
        gt_head-city1_to       = gt_kna1-city1.
      ENDIF.
      gt_head-reprint = fu_reprint.
      gt_head-bschl   = gt_post-bschl.
      CLEAR ls_out.
      READ TABLE gt_out INTO ls_out
                        WITH KEY belnr = gt_post-belnr.
      IF sy-subrc = 0.
        gt_head-vkbur   = ls_out-gsber.
      ENDIF.
      COLLECT gt_head.
      CLEAR lv_kunnr.
    ENDIF.
  ENDLOOP.

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

  IF pa_prev IS INITIAL.
    lwa_output_option-tdnoprev = 'X'.
  ELSE.
    lwa_output_option-tdnoprint = 'X'.
  ENDIF.

  LOOP AT gt_head.
    SELECT SINGLE bezei INTO gt_head-bezei
      FROM tvkbt WHERE spras = sy-langu
                   AND vkbur = gt_head-vkbur.
    IF sy-subrc = 0.
      CONCATENATE gt_head-vkbur gt_head-bezei INTO gt_head-bezei
        SEPARATED BY '-'.
      MODIFY gt_head TRANSPORTING bezei.
    ENDIF.

    CALL FUNCTION 'SPELL_AMOUNT'
      EXPORTING
        amount   = gt_head-wrbtr
        currency = 'IDR'
        language = 'i'
      IMPORTING
        in_words = in_words.

    IF sy-subrc EQ 0.
      WRITE gt_head-wrbtr TO gt_head-totaltxt CURRENCY 'IDR' NO-SIGN.
      CONCATENATE in_words-word 'RUPIAH' INTO gt_head-terbilang SEPARATED BY space.
      TRANSLATE gt_head-terbilang TO UPPER CASE.

      CONCATENATE gt_head-datum+6(4) gt_head-datum+3(2) INTO lv_spmon.

      CASE 'X'.
        WHEN radio1 OR radio4.
          READ TABLE gt_t880 WITH KEY rcomp = gt_head-vbund.
          IF sy-subrc EQ 0.
            gt_head-nomordn = gt_t880-name2.
          ENDIF.
          CONCATENATE gt_head-datum+3(2) gt_head-datum+8(2) INTO lv_period.
          READ TABLE gt_nomor_temp WITH KEY spmon = lv_spmon.
          IF sy-subrc EQ 0.
            lv_nomor  = gt_nomor_temp-nomor.
          ELSE.
            fc_subrc = 1.
            EXIT.
          ENDIF.

          CONCATENATE gt_head-nomordn '/TMMT/' lv_period '/' lv_nomor
          INTO gt_head-nomordn.
      ENDCASE.

      CONCATENATE gt_head-city1_ho ',' gt_head-datum
      INTO gt_head-datum
      SEPARATED BY space.

      gt_head-petugas = gv_petugas1.
      gt_head-jabatan = gv_jabat1.
      gt_head-graph = gv_graph.

      ADD 1 TO gt_nomor_temp-nomor.
      MODIFY gt_nomor_temp TRANSPORTING nomor
                           WHERE spmon = lv_spmon.

      CASE 'X'.
        WHEN radio1 OR radio4.
          MODIFY gt_head TRANSPORTING totaltxt terbilang datum petugas jabatan nomordn graph.
        WHEN radio2.
          MODIFY gt_head TRANSPORTING totaltxt terbilang datum petugas jabatan graph.
      ENDCASE.

      gt_post-nomordn = gt_head-nomordn.
      MODIFY gt_post TRANSPORTING nomordn
                     WHERE belnr EQ gt_head-belnr.
    ENDIF.

    CLEAR: gt_detail, gt_detail[].

    IF pa_ztype = 'R' AND
      pa_subty = '15'.
      PERFORM f_detail_tmmt CHANGING gt_detail-ltext gt_detail-xref2 gt_detail-maktx
                                     gt_detail-wrbtrtxt gt_detail-jbreak.
    ELSEIF pa_ztype = 'D' AND
      pa_subty = '57'.
      PERFORM f_detail_tmmt CHANGING gt_detail-ltext gt_detail-xref2 gt_detail-maktx
                                     gt_detail-wrbtrtxt gt_detail-jbreak.
    ELSE.
      gt_detail-xref2   = gt_head-xref2.
      WRITE gt_head-wrbtr TO gt_detail-wrbtrtxt CURRENCY 'IDR' NO-SIGN.
*    CONCATENATE gt_head-bktxt ',' gt_head-xblnr INTO gt_detail-ltext
      CONCATENATE 'REIMBURSEMENT' gt_head-bktxt ',' gt_head-xblnr INTO gt_detail-ltext
      SEPARATED BY space.
      gt_detail-maktx   = gt_head-maktx.
    ENDIF.

    APPEND gt_detail.

    gv_waers  = 'IDR'.

    AT FIRST.
      lwa_control_option-no_close = 'X'.
    ENDAT.

    AT LAST.
      lwa_control_option-no_close = space.
    ENDAT.

    CALL FUNCTION l_funcname
      EXPORTING
        output_options     = lwa_output_option
        control_parameters = lwa_control_option
        user_settings      = 'X'
        gt_head            = gt_head
      TABLES
        gt_detail          = gt_detail
        gt_add             = gt_add
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      fc_subrc  = sy-subrc.
    ENDIF.
    lwa_control_option-no_open = 'X'.
  ENDLOOP.
ENDFORM.                    " F_PRINT_DN

*&---------------------------------------------------------------------*
*&      Form  F_GET_DN_NO
*&---------------------------------------------------------------------*
FORM f_get_dn_no  CHANGING fc_subrc.

  SELECT gsber spmon ztype prefix1 prefix2 nomor
    FROM zfgsnomor
    INTO TABLE gt_zfgsnomor
    WHERE gsber EQ '0200'
      AND zform EQ 'TM'.

  fc_subrc  = sy-subrc.

  IF sy-subrc EQ 0.
    PERFORM f_lock_table.
  ENDIF.
ENDFORM.                    " F_GET_DN_NO

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_lock_table .
  DATA: ld_mess(100).

  CALL FUNCTION 'ENQUEUE_EZFGSNOMOR'
    EXPORTING
      mode_zfgsnomor = 'E'
      mandt          = sy-mandt
      gsber          = '0200'
      zform          = 'TM'
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
ENDFORM.                    " F_LOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_unlock_table.
  IF pa_prev IS INITIAL.
    LOOP AT gt_nomor_temp.
      UPDATE zfgsnomor SET nomor  = gt_nomor_temp-nomor
      WHERE gsber EQ '0200'
        AND spmon EQ gt_nomor_temp-spmon
        AND zform EQ 'TM'.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'DEQUEUE_EZFGSNOMOR'
    EXPORTING
      mode_zfgsnomor = 'X'
      mandt          = sy-mandt
      gsber          = '0200'
      zform          = 'TM'.
ENDFORM.                    " F_UNLOCK_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_BLINE_DATE
*&---------------------------------------------------------------------*
FORM f_change_bline_date  TABLES   accountgl STRUCTURE bapiacgl09
                                   ft_post   STRUCTURE gt_post
                          USING    fu_blart fu_belnr fu_bukrs fu_gjahr fu_bldat.

  DATA: lv_mode     VALUE 'N',
        lv_update   VALUE 'S',
        lv_bldat(8),
        lv_buzei    TYPE buzei,
        lr_hkont    TYPE RANGE OF hkont,
        lr_line     LIKE LINE OF lr_hkont.

  lr_line-low     = '0315300100'.
  lr_line-sign    = 'I'.
  lr_line-option  = 'EQ'.
  APPEND lr_line TO lr_hkont.
  lr_line-low     = '0142200200'.
  lr_line-sign    = 'I'.
  lr_line-option  = 'EQ'.
  APPEND lr_line TO lr_hkont.

  READ TABLE ft_post WITH KEY account = '0142200200'.
  IF sy-subrc EQ 0.
    IF ft_post-zfbdt IS NOT INITIAL.
      fu_bldat  = ft_post-zfbdt.
    ENDIF.
  ENDIF.

  CONCATENATE fu_bldat+6(2) fu_bldat+4(2) fu_bldat(4) INTO lv_bldat.

  LOOP AT accountgl.
    CLEAR: t_bdcdata,t_bdcmsg.
    REFRESH: t_bdcdata, t_bdcmsg.
    IF accountgl-gl_account IN lr_hkont.
      lv_buzei  = accountgl-itemno_acc.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPMF05L'      '0102',
           ' '  'BDC_OKCODE'    '/00',
           ' '  'RF05L-BELNR'   fu_belnr,
           ' '  'RF05L-BUKRS'   fu_bukrs,
           ' '  'RF05L-GJAHR'   fu_gjahr,
           ' '  'RF05L-BUZEI'   lv_buzei.
      CASE fu_blart.
        WHEN 'SA'.
          PERFORM f_bdc_data TABLES t_bdcdata USING:
               ' '  'RF05L-XKSAK'   'X'.
        WHEN 'DR'.
          PERFORM f_bdc_data TABLES t_bdcdata USING:
               ' '  'RF05L-XKDEB'   'X'.
      ENDCASE.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPMF05L'      '0300',
           ' '  'BDC_OKCODE'    '/00',
           ' '  'BSEG-ZFBDT'    lv_bldat.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPLKACB'      '0002',
           ' '  'BDC_OKCODE'    '=ENTE'.

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
*&      Form  F_SAVE_ZFGSDNTMMT
*&---------------------------------------------------------------------*
FORM f_save_zfgsdntmmt  USING    fwa_out STRUCTURE gt_out
                                 fu_belnr fu_proc
                        CHANGING fc_subrc.

  DATA: lt_tmmt   LIKE zfgsdntmmt OCCURS 0 WITH HEADER LINE.

  READ TABLE gt_post WITH KEY belnr = fwa_out-belnr.
  IF sy-subrc EQ 0.
    lt_tmmt-nomordn       = gt_post-nomordn.
  ENDIF.

  lt_tmmt-bukrs         = fwa_out-bukrs.
  lt_tmmt-gsber         = fwa_out-gsber.
  lt_tmmt-belnr         = fwa_out-belnr.
  lt_tmmt-gjahr         = fwa_out-gjahr.
  lt_tmmt-belnrdn       = fu_belnr.
  lt_tmmt-bktxt         = fwa_out-bktxt.
  lt_tmmt-xblnr         = fwa_out-xblnr.
  lt_tmmt-nopaaf        = fwa_out-nopaaf.
  lt_tmmt-maktx         = fwa_out-maktx.
  lt_tmmt-xref2         = fwa_out-xref2.
  lt_tmmt-xref3         = fwa_out-xref3.
  lt_tmmt-waers         = 'IDR'.
  lt_tmmt-wrbtr         = fwa_out-wrbtr.
  lt_tmmt-kunnr         = fwa_out-kunnr.
  lt_tmmt-budat         = fwa_out-budat.
  lt_tmmt-zuser         = sy-uname.
  lt_tmmt-zdatum        = sy-datum.
  lt_tmmt-zuzeit        = sy-uzeit.
  APPEND lt_tmmt.

  CASE fu_proc.
    WHEN '0'.
      INSERT zfgsdntmmt FROM TABLE lt_tmmt.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_SAVE_ZFGSDNTMMT

*&---------------------------------------------------------------------*
*&      Form  F_BDC_UPDATE_FB02
*&---------------------------------------------------------------------*
FORM f_bdc_update_fb02 USING  fu_bukrs fu_belnr fu_gjahr fu_nomordn.
  DATA : lv_mode, lv_update.

  lv_mode   = 'N'.
  lv_update = 'S'.

  CLEAR: t_bdcdata, t_bdcmsg.
  REFRESH: t_bdcdata, t_bdcmsg.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPMF05L'             '0100',
       ' '  'BDC_OKCODE'           '=AZ',
       ' '  'RF05L-BELNR'          fu_belnr,
       ' '  'RF05L-BUKRS'          fu_bukrs,
       ' '  'RF05L-GJAHR'          fu_gjahr.

  IF radio1 EQ 'X'.
    DO 3 TIMES.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPMF05L'      '0300',
           ' '  'BDC_OKCODE'    '=Z+'.
      PERFORM f_bdc_data TABLES t_bdcdata USING:
           'X'  'SAPLKACB'      '0002',
           ' '  'BDC_OKCODE'    '=ENTE'.
    ENDDO.
  ENDIF.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPMF05L'             '0300',
       ' '  'BDC_OKCODE'           '=AE',
       ' '  'BSEG-ZUONR'           fu_nomordn.

  PERFORM f_bdc_data TABLES t_bdcdata USING:
       'X'  'SAPLKACB'             '0002',
       ' '  'BDC_OKCODE'           '=ENTE'.

  CALL TRANSACTION 'FB02' USING t_bdcdata
                          MODE lv_mode
                          UPDATE lv_update
                          MESSAGES INTO t_bdcmsg.
ENDFORM.                    " F_BDC_UPDATE_FB02

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_XREF2
*&---------------------------------------------------------------------*
FORM f_modify_xref2  USING    fu_vbund fu_budat
                     CHANGING fc_xref2.
  DATA: lv_name2 LIKE t880-name2.

  SELECT SINGLE name2 INTO lv_name2
    FROM t880 WHERE rcomp = fu_vbund.

  CLEAR gv_gsnomor.
  SELECT SINGLE nomor INTO gv_gsnomor
    FROM zfgsnomor WHERE gsber EQ '0200'   AND
                         spmon EQ pa_budat(6) AND
                         ztype EQ pa_ztype AND
                         zform EQ 'GS'.

  IF sy-subrc = 0.
    PERFORM f_lock_table2 USING '0200' pa_budat(6) pa_ztype 'GS'.
    ADD 1 TO gv_gsnomor.
    CONCATENATE lv_name2(3) fu_budat+4(2) fu_budat+2(2) INTO fc_xref2.
    CONCATENATE fc_xref2 gv_gsnomor INTO fc_xref2 SEPARATED BY '/'.
  ENDIF.
ENDFORM.                    " F_MODIFY_XREF2

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE2
*&---------------------------------------------------------------------*
FORM f_lock_table2  USING    fu_gsber
                             fu_spmon
                             fu_ztype
                             fu_zform.
  DATA: ld_mess(100).

  CALL FUNCTION 'ENQUEUE_EZFGSNOMOR'
    EXPORTING
      mode_zfgsnomor = 'E'
      mandt          = sy-mandt
      gsber          = fu_gsber
      spmon          = fu_spmon
      ztype          = fu_ztype
      zform          = fu_zform
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
ENDFORM.                    " F_LOCK_TABLE2

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_TABLE2
*&---------------------------------------------------------------------*
FORM f_unlock_table2  USING    fu_gsber
                               fu_spmon
                               fu_ztype
                               fu_zform.
  CALL FUNCTION 'DEQUEUE_EZFGSNOMOR'
    EXPORTING
      mode_zfgsnomor = 'X'
      mandt          = sy-mandt
      gsber          = fu_gsber
      spmon          = fu_spmon
      ztype          = fu_ztype
      zform          = fu_zform.
ENDFORM.                    " F_UNLOCK_TABLE2

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TABLE_GSNOMOR
*&---------------------------------------------------------------------*
FORM f_modify_table_gsnomor  USING    fu_gsber
                                      fu_spmon
                                      fu_ztype
                                      fu_zform
                                      fu_gsnomor.
  UPDATE zfgsnomor SET nomor  = fu_gsnomor
    WHERE gsber EQ fu_gsber AND
          spmon EQ fu_spmon AND
          ztype EQ fu_ztype AND
          zform EQ fu_zform.
ENDFORM.                    " F_MODIFY_TABLE_GSNOMOR

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_TMMT
*&---------------------------------------------------------------------*
FORM f_detail_tmmt  CHANGING fc_ltext fc_xref2 fc_maktx fc_wrbtr
                             fc_jbreak.
  DATA : ls_xadd  LIKE LINE OF gt_xadd,
         ls_3     LIKE LINE OF gt_3,
         lv_name1 TYPE kna1-name1.

  CLEAR ls_xadd.
  READ TABLE gt_xadd INTO ls_xadd
                   WITH KEY zgsno = gt_head-xblnr.
  IF sy-subrc = 0.
    fc_ltext  = 'REIMBURSEMENT'.
    CLEAR ls_3.
    READ TABLE gt_3 INTO ls_3
                    WITH KEY subchnl = ls_xadd-schnl
                             kvgr4   = ls_xadd-kvgr4.
    CONCATENATE fc_ltext ls_xadd-jbiaya ls_3-ntoko
    INTO fc_ltext
    SEPARATED BY space.

    SELECT SINGLE name1
      FROM kna1
      INTO lv_name1
      WHERE kunnr = ls_xadd-kunnr.

    CONCATENATE lv_name1 ls_xadd-jbreak1 INTO fc_jbreak
    SEPARATED BY space.
    PERFORM f_break_concatenate USING ls_xadd-jbreak2
                                CHANGING fc_jbreak.
    PERFORM f_break_concatenate USING ls_xadd-jbreak3
                                CHANGING fc_jbreak.
    PERFORM f_break_concatenate USING ls_xadd-jbreak4
                                CHANGING fc_jbreak.
    PERFORM f_break_concatenate USING ls_xadd-jbreak5
                                CHANGING fc_jbreak.

*    PERFORM f_add_break USING : ls_xadd-kunnr ls_xadd-jbreak1 ls_xadd-wrbtr1,
*                                ls_xadd-kunnr ls_xadd-jbreak2 ls_xadd-wrbtr2,
*                                ls_xadd-kunnr ls_xadd-jbreak3 ls_xadd-wrbtr3,
*                                ls_xadd-kunnr ls_xadd-jbreak4 ls_xadd-wrbtr4,
*                                ls_xadd-kunnr ls_xadd-jbreak5 ls_xadd-wrbtr5.
  ENDIF.

  gt_detail-xref2   = gt_head-xref2.
  WRITE gt_head-wrbtr TO fc_wrbtr CURRENCY 'IDR' NO-SIGN.
  gt_detail-maktx   = gt_head-maktx.
ENDFORM.                    " F_DETAIL_TMMT

*&---------------------------------------------------------------------*
*&      Form  F_GET_TMMT_ADDITIONAL
*&---------------------------------------------------------------------*
FORM f_get_tmmt_additional .
  SELECT *
    FROM zfgsdntmmt_add
    INTO CORRESPONDING FIELDS OF TABLE gt_xadd
    WHERE bukrs = pa_bukrs
      AND zgsno IN so_zgsno.

  SELECT *
    FROM zfgstmmt3
    INTO CORRESPONDING FIELDS OF TABLE gt_3.
ENDFORM.                    " F_GET_TMMT_ADDITIONAL

*&---------------------------------------------------------------------*
*&      Form  F_ADD_BREAK
*&---------------------------------------------------------------------*
FORM f_add_break  USING    fu_kunnr fu_jbreak fu_wrbtr.
  DATA : ls_add   TYPE zfgsdntmmt_add.

  IF fu_jbreak IS NOT INITIAL.
    ls_add-jbreak1  = fu_jbreak.
    SELECT SINGLE name1
      FROM kna1
      INTO ls_add-name1
      WHERE kunnr = fu_kunnr.

    ls_add-wrbtr1   = fu_wrbtr.
    WRITE fu_wrbtr TO ls_add-jbiaya CURRENCY gv_t001-waers.
    APPEND ls_add TO gt_add.
    CLEAR ls_add.
  ENDIF.
ENDFORM.                    " F_ADD_BREAK

*&---------------------------------------------------------------------*
*&      Form  F_BREAK_CONCATENATE
*&---------------------------------------------------------------------*
FORM f_break_concatenate  USING    fu_jbreak
                          CHANGING fc_jbreak.
  IF fu_jbreak IS NOT INITIAL.
    CONCATENATE fc_jbreak '-' fu_jbreak INTO fc_jbreak
    SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_BREAK_CONCATENATE
