*----------------------------------------------------------------------*
*   INCLUDE ZF_GSPOSTF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  DATA : month_names LIKE t247 OCCURS 0 WITH HEADER LINE.
  DATA : lr_subty    TYPE RANGE OF zfgstype-zsubtype,
         ls_subty    LIKE LINE OF lr_subty,
         lt_zfgstype TYPE STANDARD TABLE OF zfgstype,
         ls_zfgstype LIKE LINE OF lt_zfgstype.

  IF pa_bukrs EQ '8020'.
    gv_gsber     = '0200'.
  ELSEIF pa_bukrs EQ '8070'.
    gv_gsber     = '0700'.
  ENDIF.

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

  READ TABLE month_names WITH KEY mnr = pa_spmon+4(2).
  IF sy-subrc EQ 0.
    CONCATENATE 'G/S Periode' month_names-ktx pa_spmon(4) INTO gv_bktxt
    SEPARATED BY space.
  ENDIF.

  SELECT zsubtype zstext loekz
    FROM zfgssubtyt
    INTO TABLE gt_subtype.

  SELECT gsber hkont
    FROM zfgsgsber
    INTO TABLE gt_zfgsgsber
    WHERE ztype EQ pa_ztype.

  SELECT SINGLE bukrs name1 street post_code1 city1 tel_number fax_number
    FROM t001 AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
    INTO gv_t001
    WHERE bukrs EQ pa_bukrs.

  SELECT gsber ztype zform fname petugas1 jabat1 petugas2 jabat2 graph
    FROM zfgstt
    INTO CORRESPONDING FIELDS OF TABLE gt_zfgstt
    WHERE gsber   EQ pa_gsber AND
          ztype   EQ pa_ztype.

  SELECT SINGLE tmmt
    FROM zfgstype
    INTO gv_tmmt
    WHERE ztype    EQ pa_ztype AND
          zsubtype IN so_subty.

  SELECT SINGLE stm
    FROM zfgstype
    INTO gv_stm
    WHERE ztype    EQ pa_ztype AND
          zsubtype IN so_subty.

  SELECT *
    FROM zfgsflagtype
    INTO CORRESPONDING FIELDS OF TABLE gt_flag
    WHERE bukrs     = pa_bukrs
      AND ztype     = pa_ztype
      AND zsubtype  IN so_subty.

*  SELECT SINGLE gtext
*    FROM tgsbt
*    INTO gv_gtext
*    WHERE spras = sy-langu
*      AND gsber = pa_gsber.

  SELECT SINGLE bezei
    FROM tvkbt
    INTO gv_gtext
    WHERE spras = sy-langu
      AND vkbur = pa_gsber.

  SELECT *
    FROM zfgstmmt_cust
    INTO CORRESPONDING FIELDS OF TABLE gt_cust
    WHERE bukrs = pa_bukrs
      AND vkbur = pa_gsber.

  CLEAR gv_subrc.

  IF radio7 IS NOT INITIAL.
    SELECT *
      FROM zfgstype
      INTO CORRESPONDING FIELDS OF TABLE lt_zfgstype
      WHERE ztype    EQ pa_ztype AND
            zsubtype IN so_subty.

    IF sy-subrc = 0.
      ls_subty-low    = '15'.
      ls_subty-sign   = 'E'.
      ls_subty-option = 'EQ'.
      APPEND ls_subty TO lr_subty.
      ls_subty-low    = '57'.
      ls_subty-sign   = 'E'.
      ls_subty-option = 'EQ'.
      APPEND ls_subty TO lr_subty.
      LOOP AT lt_zfgstype INTO ls_zfgstype.
        IF ls_zfgstype-zsubtype IN lr_subty.
          MESSAGE s000(zab) WITH 'Hanya untuk subtype 15/57' DISPLAY LIKE 'E'.
          gv_subrc = 4.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
      MESSAGE s000(zab) WITH 'Subtype belum dimaintain' DISPLAY LIKE 'E'.
      gv_subrc = 4.
    ENDIF.
  ENDIF.

  SELECT *
    FROM zfgskunnr
    INTO CORRESPONDING FIELDS OF TABLE gt_customer
    WHERE kunnr <> space.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: lr_budat TYPE RANGE OF budat,
        lr_line  LIKE LINE OF lr_budat.

  CASE 'X'.
    WHEN radio3 OR radio7 OR radio8.
      IF so_spmon-high IS INITIAL.
        CONCATENATE so_spmon-low '01' INTO lr_line-low.
        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
          EXPORTING
            day_in            = lr_line-low
          IMPORTING
            last_day_of_month = lr_line-high.
        lr_line-sign    = 'I'.
        lr_line-option  = 'BT'.
        APPEND lr_line TO lr_budat.
      ELSE.
        CONCATENATE so_spmon-low '01' INTO lr_line-low.
        CONCATENATE so_spmon-high '01' INTO lr_line-high.
        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
          EXPORTING
            day_in            = lr_line-high
          IMPORTING
            last_day_of_month = lr_line-high.
        lr_line-sign    = 'I'.
        lr_line-option  = 'BT'.
        APPEND lr_line TO lr_budat.
      ENDIF.

    WHEN OTHERS.
      IF pa_spmon IS NOT INITIAL.
        CONCATENATE pa_spmon '01' INTO lr_line-low.
        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
          EXPORTING
            day_in            = lr_line-low
          IMPORTING
            last_day_of_month = lr_line-high.
        lr_line-sign    = 'I'.
        lr_line-option  = 'BT'.
        APPEND lr_line TO lr_budat.
      ENDIF.
  ENDCASE.

  CASE 'X'.
    WHEN radio1.
      SELECT bukrs gsber belnr gjahr buzei budat bldat xblnr xref2 xref3 zuonr
             sgtxt zgsno ztype zsubtype vbund kunnr waers shkzg wrbtr
             hkont txt1 txt2 txt3 txt4 belnrgs usergs tglgs belnrrevgs
             userrevgs tglrevgs belnrpost belnrdn gjahrpost userpost
             postdt tglpost jampost belnrrev belnrrevdn userrev tglrev kuntm
             perfr perto vbundx kunnrx
        FROM zfgscab
        INTO TABLE gt_zfgscab
        WHERE bukrs      EQ pa_bukrs AND
              gsber      EQ pa_gsber AND
*              budat      IN lr_budat AND
              gjahr      EQ pa_gjahr AND
              zgsno      IN so_zgsno AND
              ztype      EQ pa_ztype AND
              zsubtype   IN so_subty AND
              kunnr      IN so_kunnr AND
              belnrgs    NE space    AND
              belnrpost  EQ space    AND
              belnrdn    EQ space.

    WHEN radio4.
      SELECT bukrs gsber belnr gjahr buzei budat bldat xblnr xref2 xref3 zuonr
             sgtxt zgsno ztype zsubtype vbund kunnr waers shkzg wrbtr
             hkont txt1 txt2 txt3 txt4 belnrgs usergs tglgs belnrrevgs
             userrevgs tglrevgs belnrpost belnrdn gjahrpost userpost
             postdt tglpost jampost belnrrev belnrrevdn userrev tglrev kuntm
             perfr perto vbundx kunnrx
        FROM zfgscab
        INTO TABLE gt_zfgscab
        WHERE bukrs      EQ pa_bukrs AND
              gsber      EQ pa_gsber AND
              postdt     IN lr_budat AND
              zgsno      IN so_zgsno AND
              ztype      EQ pa_ztype AND
              zsubtype   IN so_subty AND
              kunnr      IN so_kunnr AND
              ( belnrpost  NE space  OR
                belnrdn    NE space ).
    WHEN radio2.
      SELECT bukrs gsber belnr gjahr buzei budat bldat xblnr xref2 xref3 zuonr
             sgtxt zgsno ztype zsubtype vbund kunnr waers shkzg wrbtr
             hkont txt1 txt2 txt3 txt4 belnrgs usergs tglgs belnrrevgs
             userrevgs tglrevgs belnrpost belnrdn gjahrpost userpost
             postdt tglpost jampost belnrrev belnrrevdn userrev tglrev kuntm
             perfr perto vbundx kunnrx
        FROM zfgscab
        INTO TABLE gt_zfgscab
        WHERE bukrs      EQ pa_bukrs AND
              gsber      EQ pa_gsber AND
              postdt     IN lr_budat AND
              zgsno      IN so_zgsno AND
              ztype      EQ pa_ztype AND
              zsubtype   IN so_subty AND
              kunnr      IN so_kunnr AND
              ( belnrpost  NE space  OR
                belnrdn    NE space ).
    WHEN radio3.
      SELECT bukrs gsber belnr gjahr buzei budat bldat xblnr xref2 xref3 zuonr
             sgtxt zgsno ztype zsubtype vbund kunnr waers shkzg wrbtr
             hkont txt1 txt2 txt3 txt4 belnrgs usergs tglgs belnrrevgs
             userrevgs tglrevgs belnrpost belnrdn gjahrpost userpost
             postdt tglpost jampost belnrrev belnrrevdn userrev tglrev kuntm
             perfr perto vbundx kunnrx
      FROM zfgscab
      INTO TABLE gt_zfgscab
      WHERE bukrs      EQ pa_bukrs AND
            gsber      IN so_gsber AND
            postdt     IN lr_budat AND
            zgsno      IN so_zgsno AND
            ztype      EQ pa_ztype AND
            kunnr      IN so_kunnr AND
            zsubtype   IN so_subty.
    WHEN radio5 OR radio6.
      SELECT bukrs gsber belnr gjahr buzei budat bldat xblnr xref2 xref3 zuonr
             sgtxt zgsno ztype zsubtype vbund kunnr waers shkzg wrbtr
             hkont txt1 txt2 txt3 txt4 belnrgs usergs tglgs belnrrevgs
             userrevgs tglrevgs belnrpost belnrdn gjahrpost userpost
             postdt tglpost jampost belnrrev belnrrevdn userrev tglrev kuntm
             perfr perto vbundx kunnrx
      FROM zfgscab
      INTO TABLE gt_zfgscab
      WHERE bukrs      EQ pa_bukrs AND
            gsber      IN so_gsber AND
            budat      IN lr_budat AND
            zgsno      IN so_zgsno AND
            ztype      EQ pa_ztype AND
            kunnr      IN so_kunnr AND
            zsubtype   IN so_subty.
    WHEN radio7.
      SELECT bukrs gsber belnr gjahr buzei budat bldat xblnr xref2 xref3 zuonr
             sgtxt zgsno ztype zsubtype vbund kunnr waers shkzg wrbtr
             hkont txt1 txt2 txt3 txt4 belnrgs usergs tglgs belnrrevgs
             userrevgs tglrevgs belnrpost belnrdn gjahrpost userpost
             postdt tglpost jampost belnrrev belnrrevdn userrev tglrev kuntm
             perfr perto vbundx kunnrx
      FROM zfgscab
      INTO TABLE gt_zfgscab
      WHERE bukrs      EQ pa_bukrs AND
            gsber      IN so_gsber AND
            postdt     IN lr_budat AND
            zgsno      IN so_zgsno AND
            ztype      EQ pa_ztype AND
            kunnr      IN so_kunnr AND
            zsubtype   IN so_subty.

    WHEN radio8.
      SELECT DISTINCT a~bukrs, a~gsber, a~zgsno, a~budat, a~xref2,
                      b~clnr, c~budat AS budat_dn
        FROM zfgscab AS a INNER JOIN zfgscab_cl AS b ON b~belnr = a~belnrgs AND
                                                        b~gjahr = a~gjahr   AND
                                                        b~zgsno = a~zgsno
                          LEFT OUTER JOIN bkpf AS c ON c~bukrs = a~bukrs AND
                                                       c~belnr = a~belnrdn AND
                                                       c~gjahr = a~gjahrpost
        INTO CORRESPONDING FIELDS OF TABLE @gt_out8
        WHERE a~bukrs    = @pa_bukrs
          AND a~gsber    IN @so_gsber
          AND a~postdt     IN @lr_budat
          AND a~zgsno      IN @so_zgsno
          AND a~ztype      EQ @pa_ztype
          AND a~kunnr      IN @so_kunnr
          AND a~zsubtype   IN @so_subty
        ORDER BY a~bukrs, a~gsber, a~zgsno.

  ENDCASE.

  IF radio5 = 'X' OR radio6 = 'X'.
    DELETE gt_zfgscab WHERE zsubtype NE '21' AND zsubtype NE '61'.
  ENDIF.

  IF gt_zfgscab[] IS NOT INITIAL.
    SELECT * INTO TABLE gt_zfgscab_add
      FROM zfgscab_add FOR ALL ENTRIES IN gt_zfgscab
      WHERE bukrs = gt_zfgscab-bukrs
        AND gsber = gt_zfgscab-gsber
        AND belnr = gt_zfgscab-belnr
        AND gjahr = gt_zfgscab-gjahr
        AND zgsno = gt_zfgscab-zgsno.
  ELSE.
    IF radio8 IS INITIAL.
      MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  gv_status = 0.

  IF radio7 IS NOT INITIAL.
    SET TITLEBAR 'TITLE'.
  ELSEIF radio8 IS NOT INITIAL.
    SET TITLEBAR 'TITLE8'.
  ENDIF.

  CASE 'X'.
    WHEN radio5 OR radio6.
      PERFORM f_alv TABLES gt_excela
                    USING ''.
    WHEN radio8.
      PERFORM f_alv TABLES gt_out8
                    USING ''.
    WHEN OTHERS.
      PERFORM f_alv TABLES gt_out
                    USING ''.
  ENDCASE.
ENDFORM.                    "F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report
           USING fu_proc.
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
  PERFORM f_build_excluding.
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
      it_excluding             = t_alv_excluding[]
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
    WHEN radio1 OR radio4.
      IF fu_proc IS INITIAL.
        PERFORM f_fieldcatg USING ft_report:
          'ZTYPE' 'ZFGSCAB' 'ZTYPE' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'ZSUBTYPE' 'ZFGSCAB' 'ZSUBTYPE' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
          'ZGSNO' 'ZFGSCAB' 'ZGSNO' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'BUDAT' 'ZFGSCAB' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'ZUONR' 'ZFGSCAB' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' ''.
        PERFORM f_fieldcatg USING ft_report:
          'ACTDES' '' '' '' '50' 'Activity Description' '' '' '' '' '' '' '' '' '' ''.
        PERFORM f_fieldcatg USING ft_report:
          'KUNNR' 'ZFGSCAB' 'KUNNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'KUNTM' 'ZFGSCAB' 'KUNTM' '' '' 'Cust.TMMT' '' '' '' '' '' '' '' '' '' '',
          'WAERS' 'ZFGSCAB' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'SHKZG' 'ZFGSCAB' 'SHKZG' '' '' '' '' '' '' '' '' '' '' '' '' '',
          'WRBTR' 'ZFGSCAB' 'WRBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' '',
          'SGTXT' 'ZFGSCAB' 'SGTXT' '' '' '' '' '' '' '' '' '' '' '' '' ''.
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
    WHEN radio2.
      PERFORM f_fieldcatg USING ft_report:
        'BUKRS' 'ZFGSCAB' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'ZFGSCAB' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR' 'ZFGSCAB' 'BELNR' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
        'ZGSNO' 'ZFGSCAB' 'ZGSNO' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNRPOST' 'ZFGSCAB' 'BELNRPOST' '' '12' 'Doc.Post G/S' '' 'X' '' '' '' '' '' '' '' '',
        'BELNRDN' 'ZFGSCAB' 'BELNRDN' '' '15' 'Doc.Post DN' '' 'X' '' '' '' '' '' '' '' ''.
    WHEN radio3.
      PERFORM f_fieldcatg USING ft_report:
        'ZTYPE' 'ZFGSCAB' 'ZTYPE' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZSUBTYPE' 'ZFGSCAB' 'ZSUBTYPE' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GSBER' 'BSIS' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZGSNO' 'ZFGSCAB' 'ZGSNO' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUDAT' 'BSIS' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR' 'BSIS' 'BELNR' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
        'ZUONR' 'BSIS' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' ''.

      PERFORM f_fieldcatg USING ft_report:
        'XREF2' 'BSIS' 'XREF2' '' '20' 'No.DN Principal' '' '' '' '' '' '' '' '' '' ''.

      PERFORM f_fieldcatg USING ft_report:
        'VBUND' 'BSIS' 'VBUND' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'SGTXT' 'BSIS' 'SGTXT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'WRBTR' 'BSIS' 'WRBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' '',

        'BUKRS' 'BSIS' 'BUKRS' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'BSIS' 'GJAHR' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUZEI' 'BSIS' 'BUZEI' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'BLDAT' 'BSIS' 'BLDAT' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' 'ZFGSCAB' 'KUNNR' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'WAERS' 'BSIS' 'WAERS' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'SHKZG' 'BSIS' 'SHKZG' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'HKONT' 'BSIS' 'HKONT' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'TXT1' 'ZFGSCAB' 'TXT1' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'TXT2' 'ZFGSCAB' 'TXT2' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'TXT3' 'ZFGSCAB' 'TXT3' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'TXT4' 'ZFGSCAB' 'TXT4' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNRGS' 'ZFGSCAB' 'BELNRGS' 'X' '12' 'Doc. G/S' '' 'X' '' '' '' '' '' '' '' '',
        'TGLGS' 'ZFGSCAB' 'TGLGS' 'X' '' 'Tgl. G/S' '' '' '' '' '' '' '' '' '' '',
        'USERGS' 'ZFGSCAB' 'USERGS' 'X' '' 'UserName G/S' '' '' '' '' '' '' '' '' '' '',
        'BELNRREVGS' 'ZFGSCAB' 'BELNRREVGS' 'X' '12' 'Reverse Doc. G/S' '' 'X' '' '' '' '' '' '' '' '',
        'TGLREVGS' 'ZFGSCAB' 'TGLREVGS' 'X' '' 'Tgl. Reverse G/S' '' '' '' '' '' '' '' '' '' '',
        'USERREVGS' 'ZFGSCAB' 'USERREVGS' 'X' '' 'UserName Reverse G/S' '' '' '' '' '' '' '' '' '' '',
        'BELNRPOST' 'ZFGSCAB' 'BELNRPOST' '' '12' 'Doc.Post G/S' '' 'X' '' '' '' '' '' '' '' '',
        'BELNRDN' 'ZFGSCAB' 'BELNRDN' '' '15' 'Doc.Post DN' '' 'X' '' '' '' '' '' '' '' '',
        'GJAHRPOST' 'ZFGSCAB' 'GJAHRPOST' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'USERPOST' 'ZFGSCAB' 'USERPOST' 'X' '' 'UserName Post G/S' '' '' '' '' '' '' '' '' '' '',
        'TGLPOST' 'ZFGSCAB' 'TGLPOST' 'X' '' 'Tgl.Post G/S' '' '' '' '' '' '' '' '' '' '',
        'JAMPOST' 'ZFGSCAB' 'JAMPOST' 'X' '' 'Jam Post G/S' '' '' '' '' '' '' '' '' '' '',
        'BELNRREV' 'ZFGSCAB' 'BELNRREV' '' '12' 'Doc.Rev G/S' '' 'X' '' '' '' '' '' '' '' '',
        'BELNRREVDN' 'ZFGSCAB' 'BELNRREVDN' '' '15' 'Doc.Rev DN' '' 'X' '' '' '' '' '' '' '' '',
        'USERREV' 'ZFGSCAB' 'USERREV' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'TGLREV' 'ZFGSCAB' 'TGLREV' 'X' '' '' '' '' '' '' '' '' '' '' '' ''.

    WHEN radio7.
      PERFORM f_fieldcatg USING ft_report:
        'GSBER' 'BSIS' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZGSNO' 'ZFGSCAB' 'ZGSNO' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUDAT' 'BSIS' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR' 'BSIS' 'BELNR' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
        'ZUONR' 'BSIS' 'ZUONR' '' '' 'No.DN. TMMT' '' '' '' '' '' '' '' '' '' '',
        'KUNTM' 'ZFGSCAB' 'KUNNR' '' '' 'Cust.No. TMMT' '' '' '' '' '' '' '' '' '' '',
        'ZDESC' 'ZFGSTMMT_CUST' 'ZDESC' '' '' 'Description' '' '' '' '' '' '' '' '' '' '',
        'VBUND' 'BSIS' 'VBUND' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'SGTXT' 'BSIS' 'SGTXT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'WRBTR' 'BSIS' 'WRBTR' '' '' '' '' '' '' '' '' 'WAERS' '' '' '' '',

        'BUKRS' 'BSIS' 'BUKRS' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
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
        'BELNRGS' 'ZFGSCAB' 'BELNRGS' 'X' '12' 'Doc. G/S' '' 'X' '' '' '' '' '' '' '' '',
        'TGLGS' 'ZFGSCAB' 'TGLGS' 'X' '' 'Tgl. G/S' '' '' '' '' '' '' '' '' '' '',
        'USERGS' 'ZFGSCAB' 'USERGS' 'X' '' 'UserName G/S' '' '' '' '' '' '' '' '' '' '',
        'BELNRREVGS' 'ZFGSCAB' 'BELNRREVGS' 'X' '12' 'Reverse Doc. G/S' '' 'X' '' '' '' '' '' '' '' '',
        'TGLREVGS' 'ZFGSCAB' 'TGLREVGS' 'X' '' 'Tgl. Reverse G/S' '' '' '' '' '' '' '' '' '' '',
        'USERREVGS' 'ZFGSCAB' 'USERREVGS' 'X' '' 'UserName Reverse G/S' '' '' '' '' '' '' '' '' '' '',
        'BELNRPOST' 'ZFGSCAB' 'BELNRPOST' '' '12' 'Doc.Post G/S' '' 'X' '' '' '' '' '' '' '' '',
        'BELNRDN' 'ZFGSCAB' 'BELNRDN' '' '15' 'Doc.Post DN' '' 'X' '' '' '' '' '' '' '' '',
        'GJAHRPOST' 'ZFGSCAB' 'GJAHRPOST' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'USERPOST' 'ZFGSCAB' 'USERPOST' 'X' '' 'UserName Post G/S' '' '' '' '' '' '' '' '' '' '',
        'TGLPOST' 'ZFGSCAB' 'TGLPOST' 'X' '' 'Tgl.Post G/S' '' '' '' '' '' '' '' '' '' '',
        'JAMPOST' 'ZFGSCAB' 'JAMPOST' 'X' '' 'Jam Post G/S' '' '' '' '' '' '' '' '' '' '',
        'BELNRREV' 'ZFGSCAB' 'BELNRREV' '' '12' 'Doc.Rev G/S' '' 'X' '' '' '' '' '' '' '' '',
        'BELNRREVDN' 'ZFGSCAB' 'BELNRREVDN' '' '15' 'Doc.Rev DN' '' 'X' '' '' '' '' '' '' '' '',
        'USERREV' 'ZFGSCAB' 'USERREV' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'TGLREV' 'ZFGSCAB' 'TGLREV' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
        'PERFR' 'ZFGSCAB' 'PERFR' 'X' '' 'Period Promo Fr' '' '' '' '' '' '' '' '' '' '',
        'PERTO' 'ZFGSCAB' 'PERTO' 'X' '' 'Period Promo To' '' '' '' '' '' '' '' '' '' ''.

    WHEN radio5 OR radio6.
      PERFORM f_fieldcatg USING ft_report:
        'BUKRS' 'ZFGSST_DOWNLOAD' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GSBER' 'ZFGSST_DOWNLOAD' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR' 'ZFGSST_DOWNLOAD' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'ZFGSST_DOWNLOAD' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZGSNO' 'ZFGSST_DOWNLOAD' 'ZGSNO' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
        'PERIOD' '' '' '' '4' 'Period' '' '' '' '' '' '' '' '' '' '',
        'ENTITY' '' '' '' '50' 'Entity' '' '' '' '' '' '' '' '' '' '',
        'DISTRB' '' '' '' '6' 'Distributor' '' '' '' '' '' '' '' '' '' '',
        'SUBACC' '' '' '' '50' 'Sub Account' '' '' '' '' '' '' '' '' '' '',
        'KUNNR' '' '' '' '10' 'Customer' '' '' '' '' '' '' '' '' '' '',
        'ACTDES' '' '' '' '100' 'Activity Description' '' '' '' '' '' '' '' '' '' '',
        'PROMO' '' '' '' '22' 'Promo Number' '' '' '' '' '' '' '' '' '' '',
        'INCODN' '' '' '' '12' 'Internal Doc.' '' '' '' '' '' '' '' '' '' '',
        'CLAIM' '' '' '' '15' 'Claim Amount' '' '' '' '' '' '' '' '' '' '',
        'DUEDAT' '' '' '' '10' 'Due Date' '' '' '' '' '' '' '' '' '' '',
        'FEEDES' '' '' '' '100' 'Fee Description' '' '' '' '' '' '' '' '' '' '',
        'FEEAMT' '' '' '' '15' 'Fee Amount' '' '' '' '' '' '' '' '' '' '',
        'DNTYPE' '' '' '' '10' 'DN Type' '' '' '' '' '' '' '' '' '' '',
        'STSPPN' '' '' '' '7' 'Sts PPN' '' '' '' '' '' '' '' '' '' '',
        'VAT%' '' '' '' '11' 'VAT %' '' '' '' '' '' '' '' '' '' '',
        'STSPPH' '' '' '' '7' 'Sts PPH' '' '' '' '' '' '' '' '' '' '',
        'PPH%' '' '' '' '11' 'PPH %' '' '' '' '' '' '' '' '' '' '',
        'FPNUM' '' '' '' '19' 'FP Number' '' '' '' '' '' '' '' '' '' '',
        'FPDAT' '' '' '' '10' 'FP Data' '' '' '' '' '' '' '' '' '' '',
        'TAXLVL' '' '' '' '8' 'Tax Level' '' '' '' '' '' '' '' '' '' '',
        'FILEC' '' '' '' '128' 'File Cabang' '' 'X' '' '' '' '' '' '' '' '',
        'FILEP' '' '' '' '128' 'File Pusat' '' 'X' '' '' '' '' '' '' '' '',
        'FILED' '' '' '' '25' 'File Download' '' 'X' '' '' '' '' '' '' '' '',
        'FILED2' '' '' '' '25' 'File Download' '' 'X' '' '' '' '' '' '' '' ''.

    WHEN radio8.
      PERFORM f_fieldcatg USING ft_report:
        'BUKRS' 'ZFGSCAB' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GSBER' 'ZFGSCAB' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZGSNO' 'ZFGSCAB' 'ZGSNO' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'XREF2' 'ZFGSCAB' 'XREF2' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUDAT' 'ZFGSCAB' 'BUDAT' '' '' 'GS Date' '' '' '' '' '' '' '' '' '' '',
        'BUDAT_DN' 'BKPF' 'BUDAT' '' '' 'DN Date' '' '' '' '' '' '' '' '' '' '',
        'CLNR' 'ZFGSCAB_CL' 'CLNR' '' '' '' '' '' '' '' '' '' '' '' '' ''.
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

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&NTE'.
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
  CASE 'X'.
    WHEN radio1 OR radio4.
      IF fu_proc IS INITIAL.
        fu_layout-box_fieldname      = 'CHECK'.
      ENDIF.
    WHEN radio2 OR radio5 OR radio6.
      fu_layout-box_fieldname      = 'CHECK'.
      fu_layout-colwidth_optimize  = 'X'.
  ENDCASE.
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
    WHEN radio1.
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
    WHEN radio2.
      CLEAR ld_sort.
      ld_sort-fieldname = 'ZGSNO'.
      ld_sort-up        = 'X'.
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
  CLEAR: glacc[], aracc[], apacc[], curracc[], extacc[].
  CLEAR: gldn[], ardn[], apdn[], currdn[], extdn[].
  CLEAR: gt_postacc, gt_postacc[], gt_postdn, gt_postdn[].
  CLEAR: gt_header[], gt_error[], gt_kna1[], gt_skat[].
  CLEAR: gt_mantax, gt_mantax[].
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
  DATA: lt_exclude TYPE TABLE OF sy-ucomm.

  sy-lsind = 0.
  CASE 'X'.
    WHEN radio1.
      IF gv_status IS INITIAL.
        SET PF-STATUS 'TOSIMULATE'.
      ELSE.
        SET PF-STATUS 'TOEXECUTE'.
      ENDIF.
    WHEN radio2.
      SET PF-STATUS 'TOREVERSE'.
    WHEN radio3.
      APPEND '&DOWN' TO lt_exclude.
      APPEND '&ENT' TO lt_exclude.
      APPEND '&REFSH' TO lt_exclude.
      SET PF-STATUS 'STANDARD' EXCLUDING lt_exclude.
    WHEN radio4.
      SET PF-STATUS 'TOEXECUTE'.
    WHEN radio5.
      SET PF-STATUS 'STANDARD'.
    WHEN radio6.
      APPEND '&ENT' TO lt_exclude.
      APPEND '&REFSH' TO lt_exclude.
      SET PF-STATUS 'STANDARD'.
      SET PF-STATUS 'STANDARD' EXCLUDING lt_exclude.
    WHEN radio7 OR radio8.
      APPEND '&DOWN' TO lt_exclude.
      APPEND '&ENT' TO lt_exclude.
      APPEND '&REFSH' TO lt_exclude.
      SET PF-STATUS 'STANDARD' EXCLUDING lt_exclude.
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
  DATA: lv_duedat TYPE datum.
  DATA: lv_budat TYPE datum.

  DATA : lv_str1 TYPE string,
         lv_str2 TYPE string,
         ls_cust LIKE LINE OF gt_cust.

  DATA : lt_zfgscab LIKE gt_zfgscab OCCURS 0,
         lt_kna1    LIKE gt_kna1 OCCURS 0,
         ls_kna1    LIKE LINE OF lt_kna1.

  CASE 'X'.
    WHEN radio1 OR radio4.
      LOOP AT gt_zfgscab.
        gt_out     = gt_zfgscab.
        READ TABLE gt_zfgscab_add WITH KEY bukrs = gt_zfgscab-bukrs
                                           gsber = gt_zfgscab-gsber
                                           belnr = gt_zfgscab-belnr
                                           gjahr = gt_zfgscab-gjahr
                                           zgsno = gt_zfgscab-zgsno.
        IF sy-subrc = 0.
          gt_out-actdes = gt_zfgscab_add-actdesc.
        ENDIF.
        APPEND gt_out.
      ENDLOOP.
    WHEN radio2.
      SORT gt_zfgscab BY belnr.
      LOOP AT gt_zfgscab.
        gt_out-bukrs     = gt_zfgscab-bukrs.
        gt_out-belnr     = gt_zfgscab-belnr.
        gt_out-gjahr     = gt_zfgscab-gjahr.
        gt_out-zgsno     = gt_zfgscab-zgsno.
        gt_out-belnrpost = gt_zfgscab-belnrpost.
        gt_out-belnrdn   = gt_zfgscab-belnrdn.
        COLLECT gt_out.
      ENDLOOP.

    WHEN radio3.
      LOOP AT gt_zfgscab.
        gt_out = gt_zfgscab.
        IF gt_out-zsubtype <> '15' AND
          gt_out-zsubtype <> '57'.
          APPEND gt_out.
        ENDIF.
      ENDLOOP.

    WHEN radio5 OR radio6.
      lt_zfgscab[] = gt_zfgscab[].
      SORT lt_zfgscab BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_zfgscab COMPARING kunnr.
      IF lt_zfgscab[] IS NOT INITIAL.
        SELECT kunnr name1
          FROM kna1
          INTO TABLE lt_kna1
          FOR ALL ENTRIES IN lt_zfgscab
          WHERE kunnr = lt_zfgscab-kunnr.
      ENDIF.

      LOOP AT gt_zfgscab.
        CLEAR: gt_zfgscab_add, lv_duedat, ls_kna1.
        READ TABLE gt_zfgscab_add WITH KEY bukrs = gt_zfgscab-bukrs
                                           gsber = gt_zfgscab-gsber
                                           belnr = gt_zfgscab-belnr
                                           gjahr = gt_zfgscab-gjahr
                                           zgsno = gt_zfgscab-zgsno.

        gt_excela-bukrs = gt_zfgscab_add-bukrs.
        gt_excela-gsber = gt_zfgscab_add-gsber.
        gt_excela-belnr = gt_zfgscab_add-belnr.
        gt_excela-gjahr = gt_zfgscab_add-gjahr.
        gt_excela-zgsno = gt_zfgscab_add-zgsno.
        gt_excela-period = gt_zfgscab_add-period.

        READ TABLE lt_kna1 INTO ls_kna1
                           WITH KEY kunnr = gt_zfgscab-kunnr.
        IF sy-subrc = 0.
          gt_excela-entity = ls_kna1-name1.
        ELSE.
          gt_excela-entity = 'Nutricia Indonesia Sejahtera'.
        ENDIF.
        gt_excela-distrb = 'Tempo'.
        gt_excela-subacc = gt_zfgscab_add-subacct.
        gt_excela-actdes = gt_zfgscab_add-actdesc.
        gt_excela-promo  = gt_zfgscab_add-promonr.
        gt_excela-incodn = gt_zfgscab-xref2.
        WRITE gt_zfgscab_add-claimamt TO gt_excela-claim  CURRENCY gt_zfgscab-waers.

        SELECT SINGLE budat
          FROM bkpf
          INTO lv_budat
          WHERE bukrs = '8020'
            AND belnr = gt_zfgscab-belnrdn
            AND gjahr = gt_zfgscab-gjahr.
        IF sy-subrc = 0.
          lv_duedat = lv_budat + 30.
        ENDIF.

        WRITE lv_duedat TO gt_excela-duedat USING EDIT MASK '__-__-____'.
*        REPLACE ALL OCCURRENCES OF '.' IN gt_excela-duedat WITH '-'.
*        gt_excela-feedes.
        gt_excela-feeamt = '0'.
        gt_excela-dntype = 'Promo'.
        IF gt_zfgscab_add-vat IS INITIAL OR gt_zfgscab_add-vat = '0'.
          gt_excela-vat%   = '0'.
          CLEAR gt_excela-stsppn.
        ELSE.
          gt_excela-vat%   = gt_zfgscab_add-vat.
          gt_excela-stsppn = 'PPN - DPP'.
        ENDIF.
        IF gt_zfgscab_add-pph IS INITIAL OR gt_zfgscab_add-pph = '0'.
          gt_excela-pph%   = '0'.
          CLEAR gt_excela-stspph.
        ELSE.
          gt_excela-pph%   = gt_zfgscab_add-pph.
          gt_excela-stspph = 'PPH - DPP'.
        ENDIF.
        gt_excela-fpnum  = gt_zfgscab_add-fpnr.
        WRITE gt_zfgscab_add-fpdat TO gt_excela-fpdat USING EDIT MASK '__-__-____'.
*        REPLACE ALL OCCURRENCES OF '.' IN gt_excela-fpdat WITH '-'.
        gt_excela-taxlvl = gt_zfgscab_add-taxlvl.
        gt_excela-filec  = gt_zfgscab_add-filecabang.
        gt_excela-filep  = gt_zfgscab_add-filepusat.
        gt_excela-filed  = gt_zfgscab_add-filedown.
        gt_excela-filed2 = gt_zfgscab_add-filedown2.
        gt_excela-kunnr  = gt_zfgscab_add-kunnr.
        APPEND gt_excela. CLEAR gt_excela.
      ENDLOOP.

    WHEN radio7.
      LOOP AT gt_zfgscab.
        MOVE-CORRESPONDING gt_zfgscab TO gt_out.
        SPLIT gt_zfgscab-xref2 AT '/' INTO lv_str1 lv_str2.
        CONCATENATE lv_str1 '/MT/' lv_str2 INTO gt_out-zuonr.
        IF gt_zfgscab-belnrdn IS INITIAL.
          CLEAR gt_out-zuonr.
        ENDIF.

        CLEAR ls_cust.
        READ TABLE gt_cust INTO ls_cust
                           WITH KEY kunnr = gt_zfgscab-kuntm.
        IF sy-subrc = 0.
          gt_out-zdesc   = ls_cust-zdesc.
        ENDIF.

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
        ls_add        LIKE LINE OF gt_zfgscab_add,
        ffield(20),
        ffield2(20),
        fvalue(20),
        fvalue2(128),
        lv_error(100),
        lv_subrc      TYPE sy-subrc,
        lv_blartacc   TYPE blart,
        lv_blartdn    TYPE blart,
        lv_nomor      TYPE znomor2.

  DATA: ls_excela   LIKE LINE OF gt_excela,
        ls_customer LIKE LINE OF gt_customer.

  GET CURSOR FIELD ffield VALUE fvalue.
  GET CURSOR FIELD ffield2 VALUE fvalue2.
  READ TABLE gt_excela INTO ls_excela INDEX fu_selfield-tabindex.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&NTE' OR '&REFSH'.
      fu_selfield-refresh = 'X'.

    WHEN '&IC1'.
      CASE 'X'.
        WHEN radio1.
          IF ffield EQ 'GT_OUT-ZSUBTYPE'.
            CLEAR : wa_out, ls_add.
            READ TABLE gt_out INDEX fu_selfield-tabindex INTO wa_out.

            SELECT SINGLE * INTO ls_add
              FROM zfgscab_add
              WHERE bukrs = wa_out-bukrs
                AND gsber = wa_out-gsber
                AND belnr = wa_out-belnr
                AND gjahr = wa_out-gjahr
                AND zgsno = wa_out-zgsno.

            pa_ztyp1  = pa_ztype.
            pa_subt1  = wa_out-zsubtype.
            pa_actde  = ls_add-actdesc.
            pa_kunnr  = wa_out-kunnr.
            CALL SELECTION-SCREEN 9000 STARTING AT 10 10.

            IF gt_out-zsubtype = '21' OR
              gt_out-zsubtype = '61'.
              ls_add-actdesc = pa_actde.
              IF pa_prev IS INITIAL.
                MODIFY zfgscab_add FROM ls_add.
              ENDIF.
            ENDIF.

            gt_out-zsubtype = pa_subt1.
            gt_out-kunnrx   = wa_out-kunnr.
            gt_out-vbundx   = wa_out-vbund.
            gt_out-kunnr    = pa_kunnr.
            READ TABLE gt_customer INTO ls_customer
                                   WITH KEY kunnr = pa_kunnr.
            IF sy-subrc = 0.
              gt_out-vbund = ls_customer-vbund.
            ENDIF.
            READ TABLE gt_subtype WITH KEY zsubtype = gt_out-zsubtype.
            IF sy-subrc EQ 0.
              IF gt_subtype-loekz IS INITIAL.
                IF pa_prev IS INITIAL.
                  UPDATE zfgscab SET vbundx = gt_out-vbundx
                                     kunnrx = gt_out-kunnrx
                                     vbund = gt_out-vbund
                                     kunnr = gt_out-kunnr
                                 WHERE bukrs = wa_out-bukrs
                                   AND gsber = wa_out-gsber
                                   AND belnr = wa_out-belnr
                                   AND gjahr = wa_out-gjahr
                                   AND buzei = wa_out-buzei.
                ENDIF.

                MODIFY gt_out TRANSPORTING zsubtype vbund kunnr kunnrx vbundx
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
          ENDIF.

        WHEN radio2.
          IF ffield EQ 'GT_OUT-BELNRPOST' OR
            ffield EQ 'GT_OUT-BELNRDN'.
            IF fvalue IS NOT INITIAL.
              SET PARAMETER ID 'BLN' FIELD fvalue.
              SET PARAMETER ID 'BUK' FIELD pa_bukrs.
              SET PARAMETER ID 'GJR' FIELD pa_spmon(4).
              CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.

        WHEN radio3.
          IF ffield EQ 'GT_OUT-BELNR' OR
            ffield EQ 'GT_OUT-BELNRPOST' OR
            ffield EQ 'GT_OUT-BELNRDN' OR
            ffield EQ 'GT_OUT-BELNRREV'.
            IF fvalue IS NOT INITIAL.
              SET PARAMETER ID 'BLN' FIELD fvalue.
              SET PARAMETER ID 'BUK' FIELD pa_bukrs.
              SET PARAMETER ID 'GJR' FIELD pa_spmon(4).
              CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.

        WHEN radio5 OR radio6.
          IF ffield2 EQ 'GT_EXCELA-FILEP' OR
             ffield2 EQ 'GT_EXCELA-FILEC'.
            IF fvalue2 IS NOT INITIAL.
              PERFORM f_display_pdf USING ffield2 fvalue2.
            ENDIF.
          ENDIF.

          IF radio5 = 'X'.
            IF ffield2 EQ 'GT_EXCELA-ZGSNO'.
              CLEAR: gt_excela,pa_filps.
              READ TABLE gt_excela WITH KEY zgsno = fvalue.
              pa_filps = gv_filepusat = gt_excela-filep.
              CALL SELECTION-SCREEN 9007 STARTING AT 10 10.

              IF sy-subrc = 0.
                "Move file to server
                CALL FUNCTION 'ZAB_MOVE_FILE_TO_SERVER'
                  EXPORTING
                    local_file  = pa_filps
                    server_path = gc_path
                  IMPORTING
                    server_file = gt_excela-filep.

                "Modify itab
                MODIFY gt_excela TRANSPORTING filep
                                 WHERE bukrs = ls_excela-bukrs
                                   AND gsber = ls_excela-gsber
                                   AND belnr = ls_excela-belnr
                                   AND gjahr = ls_excela-gjahr
                                   AND zgsno = ls_excela-zgsno.

                "Update Table
                UPDATE zfgscab_add SET filepusat = gt_excela-filep
                                   WHERE bukrs = ls_excela-bukrs
                                     AND gsber = ls_excela-gsber
                                     AND belnr = ls_excela-belnr
                                     AND gjahr = ls_excela-gjahr
                                     AND zgsno = ls_excela-zgsno.
              ENDIF.
            ENDIF.
          ENDIF.
      ENDCASE.

    WHEN '&LOG'.
      CALL SCREEN 500 STARTING AT 10 10 ENDING AT 132 22.

    WHEN '&SIM'.
      PERFORM f_free_memory.
      CLEAR: lv_subrc.
      PERFORM f_posting_data CHANGING lv_subrc lv_blartacc lv_blartdn.
      CHECK lv_subrc IS INITIAL.
      gv_status = 1.
      PERFORM f_simulate.
      PERFORM f_alv TABLES gt_post
                    USING 'SIMULATE'.
      gv_status = 0.
      LEAVE TO SCREEN 0.

    WHEN '&POS'.
      CLEAR: glacc[], aracc[], apacc[], curracc[], extacc[],
             gldn[], ardn[], apdn[], currdn[], extdn[], lv_subrc.
      IF gt_error[] IS INITIAL.
        CASE 'X'.
          WHEN radio1.
            IF headdn IS NOT INITIAL.
              PERFORM f_get_dn_no CHANGING lv_subrc lv_nomor.
            ENDIF.
          WHEN radio4.
            PERFORM f_posting_data CHANGING lv_subrc lv_blartacc lv_blartdn.
        ENDCASE.
        IF lv_subrc EQ 0.
          PERFORM f_post_entries USING lv_nomor.
        ELSE.
          MESSAGE e000(zab) WITH 'DN Number has not been maintained'.
        ENDIF.
      ELSE.
        MESSAGE e000(zab) WITH 'There is still incorrect data'.
      ENDIF.
      CLEAR: gt_error[].

    WHEN '&REV'.
      LOOP AT gt_out WHERE check EQ 'X'.
        PERFORM f_reverse USING gt_out-belnr gt_out-belnrpost '0'.
        PERFORM f_reverse USING gt_out-belnr gt_out-belnrdn '1'.
      ENDLOOP.
      LEAVE TO SCREEN 0.

    WHEN '&DOWN'.
      IF radio5 = 'X' OR radio6 = 'X'.
        PERFORM f_download_excel.
      ENDIF.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries USING fu_nomor.
  DATA: lv_subrc  TYPE sy-subrc,
        lv_zform  TYPE zfgstt-zform,
        lv_graph,
        ls_zfgstt LIKE LINE OF gt_zfgstt.

  obj_type = 'BKPF'.

  IF headdn IS NOT INITIAL.
    CASE gv_zsubtype.
      WHEN '15' OR '57'.
        lv_zform = 'DN'.
        lv_graph = 'X'.
      WHEN OTHERS.
        lv_zform = 'DN'.
*        lv_graph = space.
        lv_graph = 'X'.
    ENDCASE.
    READ TABLE gt_zfgstt INTO ls_zfgstt
                         WITH KEY zform = lv_zform.
    IF sy-subrc = 0.
      gv_fname      = ls_zfgstt-fname.
      gv_petugas1   = ls_zfgstt-petugas1.
      gv_jabat1     = ls_zfgstt-jabat1.
      gv_petugas2   = ls_zfgstt-petugas2.
      gv_jabat2     = ls_zfgstt-jabat2.
      IF lv_graph IS NOT INITIAL.
        gv_graph      = ls_zfgstt-graph.
      ENDIF.
    ENDIF.
    PERFORM f_print_dn USING gv_fname lv_zform
                       CHANGING lv_subrc fu_nomor.
  ENDIF.

  CHECK lv_subrc EQ 0.

  IF radio1 EQ 'X'.
    IF headacc IS NOT INITIAL.
      PERFORM f_detail_data TABLES glacc apacc aracc curracc extacc criteria retacc
                                   gt_postacc.

      IF pa_prev IS INITIAL.
        PERFORM f_bapi_document_post TABLES glacc apacc aracc curracc extacc criteria
                                            retacc gt_postacc
                                     USING headacc obj_type '0'
                                     CHANGING lv_subrc.
      ENDIF.
    ENDIF.

    IF headdn IS NOT INITIAL.
*      PERFORM f_lock_table2 USING gv_gsber pa_spmon pa_ztype 'GS'.

      PERFORM f_detail_data TABLES gldn apdn ardn currdn extdn criteria retdn
                                   gt_postdn.

      IF pa_prev IS INITIAL.
        PERFORM f_bapi_document_post TABLES gldn apdn ardn currdn extdn criteria retdn
                                            gt_postdn
                                     USING headdn obj_type '1'
                                     CHANGING lv_subrc.
        CHECK lv_subrc EQ 0.

*        PERFORM f_modify_table_gsnomor USING gv_gsber pa_spmon pa_ztype 'GS' gv_gsnomor gt_out-vbund.
*        PERFORM f_unlock_table2 USING gv_gsber pa_spmon pa_ztype 'GS' gt_out-vbund.
        PERFORM f_modify_table_gsnomor USING gv_gsber pa_budat(6) pa_ztype 'GS' gv_gsnomor gt_out-vbund.
        PERFORM f_unlock_table2 USING gv_gsber pa_budat(6) pa_ztype 'GS' gt_out-vbund.
      ENDIF.

      PERFORM f_unlock_table USING fu_nomor.
    ENDIF.
  ENDIF.

*  PERFORM f_unlock_table2 USING gv_gsber pa_spmon pa_ztype 'GS' gt_out-vbund.
  PERFORM f_unlock_table2 USING gv_gsber pa_budat(6) pa_ztype 'GS' gt_out-vbund.

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
    WHEN radio9.
      LOOP AT SCREEN.
        IF screen-group1 = 'BUK'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GS1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GS2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'ZTY'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GRY'.
          screen-input  = 0.
        ENDIF.
        IF screen-group1 = 'SSP'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJA'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'SPM'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'PRE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'SU2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DAT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'ZGS'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'SSP'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'PRE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'SU1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'KUN'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DAT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJA'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'SPM'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'SSP'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio1 OR radio4.
      LOOP AT SCREEN.
        IF screen-group1 = 'GS2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GRY'.
          screen-input  = 0.
        ENDIF.
        IF screen-group1 = 'SSP'.
          screen-active  = 0.
        ENDIF.
        IF radio4 IS NOT INITIAL.
          IF screen-group1 = 'GJA'.
            screen-active  = 0.
          ENDIF.
        ELSE.
          IF screen-group1 = 'SPM'.
            screen-active  = 0.
          ENDIF.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio2.
      LOOP AT SCREEN.
        IF screen-group1 = 'PRE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GS2'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DAT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJA'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'SSP'.
          screen-active  = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN radio3 OR radio5 OR radio6 OR radio7 OR radio8.
      LOOP AT SCREEN.
        IF screen-group1 = 'PRE'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'SU1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GS1'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'DAT'.
          screen-active  = 0.
        ENDIF.
        IF screen-group1 = 'GJA'.
          screen-active  = 0.
        ENDIF.
        IF radio3 IS NOT INITIAL OR
           radio7 IS NOT INITIAL OR
           radio8 IS NOT INITIAL.
          IF screen-group1 = 'SPM'.
            screen-active  = 0.
          ENDIF.
        ELSE.
          IF screen-group1 = 'SSP'.
            screen-active  = 0.
          ENDIF.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.

  CASE sy-dynnr.
    WHEN '9000'.
      LOOP AT SCREEN.
        IF gt_out-zsubtype = '21' OR
          gt_out-zsubtype = '61'.
          IF screen-group1 = 'PSU'.
            screen-input  = 0.
            MODIFY SCREEN.
          ENDIF.
        ELSE.
          IF screen-group1 = 'PAC'.
            screen-active  = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDLOOP.

    WHEN '9001'.
      LOOP AT SCREEN.
        IF screen-group1 = 'FLP'.
          screen-active  = 0.
          MODIFY SCREEN.
        ENDIF.
        IF gt_out-zsubtype EQ '21' OR gt_out-zsubtype EQ '61'.
          IF screen-group1 = 'XR3'.
            screen-active  = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDLOOP.

    WHEN '9007'.
      IF pa_filps IS INITIAL.
        PERFORM f_screen_modify2  USING 'FPS' '1' '1' '0'.
      ELSE.
        PERFORM f_screen_modify2  USING 'FPS' '0' '1' '0'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA: lv_mess(100)  VALUE 'Fill in all required entry fields',
        lv_error(100).

  CASE 'X'.
    WHEN radio9.

    WHEN OTHERS.
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
        WHEN radio3 OR radio5 OR radio6 OR radio7 OR radio8.
          IF radio7 IS NOT INITIAL OR radio8 IS NOT INITIAL.
            IF so_subty[] IS INITIAL.
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
          ENDIF.

        WHEN OTHERS.
          IF pa_gsber IS INITIAL.
            LOOP AT SCREEN.
              IF screen-group1 = 'GS1'.
                screen-input  = 1.
              ELSE.
                screen-input  = 0.
              ENDIF.
              MODIFY SCREEN.
            ENDLOOP.
            MESSAGE e000(zab) WITH lv_mess.
          ENDIF.
      ENDCASE.

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

*  CASE 'X'.
*    WHEN radio3.
*    WHEN OTHERS.
*      IF pa_subty IS INITIAL.
*        LOOP AT SCREEN.
*          IF screen-group1 = 'SU1'.
*            screen-input  = 1.
*          ELSE.
*            screen-input  = 0.
*          ENDIF.
*          MODIFY SCREEN.
*        ENDLOOP.
*        MESSAGE e000(zab) WITH lv_mess.
*      ELSE.
*        CLEAR: gt_subtype, gt_subtype[].
*        SELECT zsubtype zstext
*          FROM zfgssubtyt
*          INTO TABLE gt_subtype.
*        READ TABLE gt_subtype WITH KEY zsubtype = pa_subty.
*        IF sy-subrc NE 0.
*          LOOP AT SCREEN.
*            IF screen-group1 = 'SU1'.
*              screen-input  = 1.
*            ELSE.
*              screen-input  = 0.
*            ENDIF.
*            MODIFY SCREEN.
*          ENDLOOP.
*          CONCATENATE 'Sub Type' pa_subty 'not found' INTO lv_error
*          SEPARATED BY space.
*          MESSAGE e000(zab) WITH lv_error.
*        ENDIF.
*      ENDIF.
*  ENDCASE.

      CASE 'X'.
        WHEN radio1.
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
        WHEN radio3 OR radio7 OR radio8.
          IF so_spmon[] IS INITIAL.
            LOOP AT SCREEN.
              IF screen-group1 = 'SSP'.
                screen-input  = 1.
              ELSE.
                screen-input  = 0.
              ENDIF.
              MODIFY SCREEN.
            ENDLOOP.
            MESSAGE e000(zab) WITH lv_mess.
          ENDIF.

        WHEN OTHERS.
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
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_SIMULATE
*&---------------------------------------------------------------------*
FORM f_simulate.

  CLEAR: gt_error, gt_error[].

  obj_type = 'BKPF'.

  IF headacc IS NOT INITIAL.
    PERFORM f_detail_data TABLES glacc apacc aracc curracc extacc criteria retacc
                                 gt_postacc.

    PERFORM f_bapi_document_check TABLES glacc apacc aracc curracc extacc criteria
                                         retacc gt_postacc
                                  USING headacc obj_type.
  ENDIF.

  IF headdn IS NOT INITIAL.
    PERFORM f_detail_data TABLES gldn apdn ardn currdn extdn criteria retdn
                                 gt_postdn.

    PERFORM f_bapi_document_check TABLES gldn apdn ardn currdn extdn criteria retdn
                                         gt_postdn
                                  USING headdn obj_type.
  ENDIF.

  LOOP AT gt_postacc.
    gt_post = gt_postacc.
    APPEND gt_post.
  ENDLOOP.
  LOOP AT gt_postdn.
    gt_post = gt_postdn.
    APPEND gt_post.
  ENDLOOP.
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
                            ft_post           STRUCTURE gt_post.

  DATA: lv_wrbtr     TYPE wrbtr,
        ls_flag      LIKE LINE OF gt_flag,
        lv_zuonr(50).

  LOOP AT ft_post WHERE icon  EQ icon_led_green.
    CASE ft_post-koart.
      WHEN 'D'.
        accountreceivable-itemno_acc    = ft_post-buzeipost.
        accountreceivable-customer      = ft_post-account.
        IF ft_post-ogtxt IS INITIAL.
          accountreceivable-item_text     = ft_post-sgtxt.
        ELSE.
          accountreceivable-item_text     = ft_post-ogtxt.
        ENDIF.
        accountreceivable-bus_area      = ft_post-gsber.
        accountreceivable-tax_code      = ft_post-mwskz.
        accountreceivable-alloc_nmbr    = ft_post-zuonr.
        accountreceivable-bline_date    = pa_bldat.
        accountreceivable-ref_key_2     = pa_xref2.

        IF pa_xref3 IS INITIAL.
          accountreceivable-ref_key_3     = 'X'.
        ELSE.
          accountreceivable-ref_key_3     = pa_xref3.
        ENDIF.
        APPEND accountreceivable.
      WHEN 'K'.
        accountpayable-itemno_acc       = ft_post-buzeipost.
        accountpayable-vendor_no        = ft_post-account.
        IF ft_post-ogtxt IS INITIAL.
          accountpayable-item_text        = ft_post-sgtxt.
        ELSE.
          accountpayable-item_text        = ft_post-ogtxt.
        ENDIF.
        accountpayable-bus_area         = ft_post-gsber.
        accountpayable-tax_code         = ft_post-mwskz.
        accountpayable-alloc_nmbr       = ft_post-zuonr.
        accountpayable-bline_date       = ft_post-zfbdt.
        accountpayable-ref_key_2        = pa_xref2.
        IF pa_xref3 IS INITIAL.
          accountpayable-ref_key_3        = 'X'.
        ELSE.
          accountpayable-ref_key_3        = pa_xref3.
        ENDIF.
        APPEND accountpayable.
      WHEN 'S'.
        IF ft_post-ogtxt IS INITIAL.
          accountgl-item_text             = ft_post-sgtxt.
        ELSE.
          accountgl-item_text             = ft_post-ogtxt.
        ENDIF.
        accountgl-alloc_nmbr            = ft_post-zuonr.

        IF ft_post-account = '0142200200'.
          READ TABLE gt_out WITH KEY belnr = ft_post-belnr
                                     gjahr = ft_post-gjahr.
          IF sy-subrc = 0.
            CLEAR ls_flag.
            READ TABLE gt_flag INTO ls_flag WITH KEY bukrs    = gt_out-bukrs
                                                     ztype    = gt_out-ztype
                                                     zsubtype = gt_out-zsubtype.
            IF sy-subrc = 0.
              IF ls_flag IS NOT INITIAL.
                accountgl-item_text             = gt_out-txt1.
                lv_zuonr = gt_out-txt3+3(19).
                TRANSLATE lv_zuonr USING '. '.
                TRANSLATE lv_zuonr USING '- '.
                CONDENSE lv_zuonr NO-GAPS.
                accountgl-alloc_nmbr            = lv_zuonr.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        accountgl-itemno_acc            = ft_post-buzeipost.
        accountgl-gl_account            = ft_post-account.
        accountgl-bus_area              = ft_post-gsber.
        accountgl-tax_code              = ft_post-mwskz.
        accountgl-trade_id              = ft_post-vbund.
        accountgl-ref_key_2             = pa_xref2.
        IF pa_xref3 IS INITIAL.
          accountgl-ref_key_3             = 'X'.
        ELSE.
          accountgl-ref_key_3             = pa_xref3.
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
FORM f_reverse USING fu_belnr fu_belnr1 fu_flag.
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

        SELECT SINGLE zgsno, belnrgs
          FROM zfgscab
          WHERE belnr  EQ @fu_belnr AND
                bukrs  EQ @gt_out-bukrs AND
                gjahr  EQ @gt_out-gjahr
          INTO (@DATA(lv_zgsno), @DATA(lv_belnrgs)).
        IF sy-subrc = 0.
          UPDATE zfgscab_cl SET xref2 = space
                            WHERE belnr = lv_belnrgs
                              AND gjahr = gt_out-gjahr
                              AND zgsno = lv_zgsno.
        ENDIF.

        IF fu_flag EQ '0'.
          UPDATE zfgscab SET belnrpost  = space
                             belnrrev   = t_bdcmsg-msgv1
                             userrev    = sy-uname
                             tglrev     = sy-datum
                         WHERE belnr  EQ fu_belnr AND
                               bukrs  EQ gt_out-bukrs AND
                               gjahr  EQ gt_out-gjahr.
        ELSE.
          UPDATE zfgscab SET belnrdn    = space
                             belnrrevdn = t_bdcmsg-msgv1
                             userrev    = sy-uname
                             tglrev     = sy-datum
                         WHERE belnr  EQ fu_belnr AND
                               bukrs  EQ gt_out-bukrs AND
                               gjahr  EQ gt_out-gjahr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_REVERSE

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data CHANGING fc_subrc fc_blartacc fc_blartdn.

  PERFORM f_collect_data CHANGING fc_subrc fc_blartacc fc_blartdn.
  IF fc_subrc IS INITIAL.
    IF fc_blartacc IS NOT INITIAL.
      PERFORM f_get_header USING fc_blartacc
                           CHANGING headacc.
    ENDIF.

    IF fc_blartdn IS NOT INITIAL.
      PERFORM f_get_header USING fc_blartdn
                           CHANGING headdn.
    ENDIF.

    IF headacc IS INITIAL AND
      headdn IS INITIAL.
      MESSAGE e000(zab) WITH 'No data to be processed'.
    ENDIF.
  ELSE.
    CASE fc_subrc.
      WHEN 1.
        MESSAGE e000(zab) WITH 'No data to be processed'.
      WHEN 2.
        MESSAGE e000(zab) WITH 'There are different Subtype/Reference'.
      WHEN 3.
        MESSAGE e000(zab) WITH 'Cancel process'.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_POSTING_DATA

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
*&      Form  F_COLLECT_DATA
*&---------------------------------------------------------------------*
FORM f_collect_data CHANGING fc_subrc fc_blartacc fc_blartdn.
  DATA: lt_header        LIKE gt_out OCCURS 0 WITH HEADER LINE,
        lt_out           LIKE gt_out OCCURS 0 WITH HEADER LINE,
        lv_lines         TYPE i,
        lv_countacc      TYPE i,
        lv_countdn       TYPE i,
        lv_wrbtr         TYPE wrbtr,
        lv_bschl         TYPE bschl,
        lv_inputppn(1),
        lv_inputgsber(1),
        lv_inputhkont(1).

  DATA : ls_flag     LIKE LINE OF gt_flag.

  IF pa_ztype EQ 'R'.
    lv_bschl  = '40'.
  ELSE.
    lv_bschl = '50'.
  ENDIF.

  CLEAR : pa_bktxt, gv_zsubtype.
  LOOP AT gt_out WHERE check EQ 'X'.
    gt_out-check  = 'X'.
    MODIFY gt_out TRANSPORTING check
                  WHERE gsber EQ gt_out-gsber AND
                        belnr EQ gt_out-belnr AND
                        gjahr EQ gt_out-gjahr.

    IF pa_bktxt IS INITIAL.
      pa_bktxt = gt_out-sgtxt.
    ENDIF.
  ENDLOOP.

  SORT gt_out BY zsubtype.
  LOOP AT gt_out WHERE check EQ 'X'.
    lt_out  = gt_out.
    CLEAR: lt_out-buzei, lt_out-zuonr.

    CLEAR: lt_out-txt1, lt_out-txt2,
           lt_out-txt3, lt_out-txt4.
    COLLECT lt_out.

    CLEAR ls_flag.
    READ TABLE gt_flag INTO ls_flag WITH KEY bukrs    = gt_out-bukrs
                                             ztype    = gt_out-ztype
                                             zsubtype = gt_out-zsubtype.
    IF sy-subrc = 0.
      IF ls_flag-flag IS INITIAL.
        lt_header-xref3     = gt_out-zgsno.
      ELSE.
        CASE ls_flag-zsubtype.
          WHEN '21' OR '61'.
            lt_header-xref3     = gt_out-zgsno.
          WHEN OTHERS.
            lt_header-xref3     = gt_out-txt2.
        ENDCASE.
      ENDIF.
    ELSE.
      lt_header-xref3     = gt_out-zgsno.
    ENDIF.

    gt_manba-bschl  = lv_bschl.
    gt_manba-sgtxt  = gt_out-sgtxt.
    gt_manba-wrbtr  = gt_out-wrbtr.
    APPEND gt_manba.

    lt_header-ztype     = gt_out-ztype.
    lt_header-zsubtype  = gt_out-zsubtype.
    lt_header-gsber     = gt_out-gsber.
    lt_header-xref2     = gt_out-xref2.

    IF radio1 EQ 'X'.
      PERFORM f_modify_xref2 USING gt_out-vbund gt_out-vbundx pa_budat
                             CHANGING lt_header-xref2.
    ENDIF.

    ADD gt_out-wrbtr  TO lv_wrbtr.
    COLLECT lt_header.
  ENDLOOP.

  WRITE lv_wrbtr TO gv_wrbtr CURRENCY 'IDR'.

  IF sy-subrc EQ 0.
    DESCRIBE TABLE lt_header LINES lv_lines.
    IF lv_lines EQ 1.
      READ TABLE lt_header INDEX 1.
      pa_xblnr  = pa_xref3  = lt_header-xref3.
      pa_xref2  = lt_header-xref2.
      CLEAR: gt_zfgsacc, gt_zfgsacc[], gt_zfgsaccdn, gt_zfgsaccdn[].
* Acc
      PERFORM f_get_zfgsacc TABLES gt_zfgsacc
                            USING lt_header-ztype lt_header-zsubtype
                                  lt_header-gsber '0'
                            CHANGING fc_blartacc lv_countacc
                                     lv_inputppn lv_inputgsber
                                     lv_inputhkont.
* DN
      PERFORM f_get_zfgsacc TABLES gt_zfgsaccdn
                            USING lt_header-ztype lt_header-zsubtype
                                  lt_header-gsber '1'
                            CHANGING fc_blartdn lv_countdn
                                     lv_inputppn lv_inputgsber
                                     lv_inputhkont.

      IF radio1 EQ 'X'.
        IF lv_inputppn IS NOT INITIAL.
          PERFORM f_get_tax_manual_entry TABLES gt_zfgsacc.
          CALL SCREEN 9002 STARTING AT 10 10.
        ELSEIF lv_inputgsber IS NOT INITIAL.
          PERFORM f_get_gsber_manual_entry TABLES gt_zfgsacc.
          CALL SCREEN 9003 STARTING AT 10 10.
        ELSEIF lv_inputhkont IS NOT INITIAL.
          PERFORM f_get_hkont_manual_entry TABLES gt_zfgsacc
                                           USING lv_wrbtr
                                           CHANGING gv_wrbtr.
          IF gv_tmmt IS INITIAL.
            IF gv_stm IS INITIAL.
              CALL SCREEN 9004 STARTING AT 10 10.
            ELSE.
              CALL SCREEN 9008 STARTING AT 10 10.
            ENDIF.
          ELSE.
            CALL SCREEN 9006 STARTING AT 10 10.
          ENDIF.
        ELSE.
          CALL SELECTION-SCREEN 9001 STARTING AT 10 10.
          IF sy-subrc = 0.
*            PERFORM f_lock_table2 USING gv_gsber pa_spmon pa_ztype 'GS' gt_out-vbund.
            PERFORM f_lock_table2 USING gv_gsber pa_budat(6) pa_ztype 'GS' gt_out-vbund.
          ENDIF.
        ENDIF.
      ENDIF.

      IF sy-subrc EQ 0.
* Get detail Acc
        PERFORM f_get_detail TABLES gt_zfgsacc gt_postacc lt_out
                             USING lv_inputppn lv_inputgsber lv_inputhkont
                                   lt_header-zsubtype fc_blartacc lv_countacc '0'.
* Get detail DN
        PERFORM f_get_detail TABLES gt_zfgsaccdn gt_postdn lt_out
                             USING lv_inputppn lv_inputgsber lv_inputhkont
                                   lt_header-zsubtype fc_blartdn lv_countdn '1'.
      ELSE.
        fc_subrc  = 3.
      ENDIF.
    ELSE.
      fc_subrc  = 2.
    ENDIF.
  ELSE.
    fc_subrc  = 1.
  ENDIF.
ENDFORM.                    " F_COLLECT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DETAIL
*&---------------------------------------------------------------------*
FORM f_get_detail  TABLES   ft_zfgs      STRUCTURE gt_zfgsacc
                            ft_post      STRUCTURE gt_postacc
                            ft_out       STRUCTURE gt_out
                   USING    fu_inputppn fu_inputgsber fu_inputhkont
                            fu_zsubtype fu_blart fu_count fu_flag.
  DATA: lt_kna1   LIKE gt_out OCCURS 0 WITH HEADER LINE,
        lwa_out   LIKE gt_out,
        lwa_zfgs  LIKE gt_zfgsacc,
        lv_wrbtr  TYPE wrbtr,
        lv_count  TYPE i,
        lv_bschl  TYPE bschl,
        lv_hkont  TYPE hkont,
        lv_mwskz  TYPE mwskz,
        lv_ztax   TYPE ztax1,
        lv_wrbtr1 TYPE wrbtr,
        lv_wrbtr2 TYPE wrbtr,
        lv_wrbtr3 TYPE wrbtr,
        lv_wrbtr4 TYPE wrbtr,
        lv_wrbtr5 TYPE wrbtr,
        lv_wrbtr6 TYPE wrbtr,
        lv_wrbtr7 TYPE wrbtr,
        lv_wrbtr8 TYPE wrbtr.

  lt_kna1[] = ft_out[].
  SORT lt_kna1 BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_kna1 COMPARING kunnr.

  IF lt_kna1[] IS NOT INITIAL.
    SELECT a~kunnr b~name1 street post_code1 city1
      FROM kna1 AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
      INTO TABLE gt_kna1
      FOR ALL ENTRIES IN lt_kna1
      WHERE a~kunnr EQ lt_kna1-kunnr.
  ENDIF.

  CLEAR lwa_zfgs.
  READ TABLE ft_zfgs INTO lwa_zfgs INDEX 1.

  LOOP AT ft_out INTO lwa_out.
    ft_post-ztype     = lwa_out-ztype.
    ft_post-zsubtype  = lwa_out-zsubtype.
    ft_post-blart     = fu_blart.
    ft_post-bukrs     = lwa_out-bukrs.
    ft_post-belnr     = lwa_out-belnr.
    ft_post-buzei     = lwa_out-buzei.
    ft_post-gjahr     = lwa_out-gjahr.
    ft_post-xblnr     = lwa_out-xblnr.
    ft_post-kuntm     = lwa_out-kuntm.

    ft_post-gsber     = gv_gsber.

    ft_post-vbund     = lwa_out-vbund.

    ft_post-kostl     = lwa_zfgs-kostl.
    ft_post-vkorg     = lwa_zfgs-vkorg.
    ft_post-werks     = lwa_zfgs-werks.
    ft_post-kmvkbu    = lwa_zfgs-kmvkbu.
    ft_post-wwsfr     = lwa_zfgs-wwsfr.
    ft_post-wwpfn     = lwa_zfgs-wwpfn.
    ft_post-wwpos     = lwa_zfgs-wwpos.

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

      PERFORM f_modify_wrbtr USING lv_count fu_count lv_ztax
                                   fu_zsubtype lwa_out-wrbtr lv_bschl lv_hkont
                                   fu_flag fu_inputppn fu_inputgsber fu_inputhkont
                                   lv_wrbtr1 lv_wrbtr2 lv_wrbtr3 lv_wrbtr4
                                   lv_wrbtr5 lv_wrbtr6 lv_wrbtr7 lv_wrbtr8
                             CHANGING lv_wrbtr.
      CASE lv_count.
        WHEN 1.
          lv_wrbtr1 = lv_wrbtr.
        WHEN 2.
          lv_wrbtr2 = lv_wrbtr.
        WHEN 3.
          lv_wrbtr3 = lv_wrbtr.
        WHEN 4.
          lv_wrbtr4 = lv_wrbtr.
        WHEN 5.
          lv_wrbtr5 = lv_wrbtr.
        WHEN 6.
          lv_wrbtr6 = lv_wrbtr.
        WHEN 7.
          lv_wrbtr7 = lv_wrbtr.
        WHEN 8.
          lv_wrbtr8 = lv_wrbtr.
      ENDCASE.

      PERFORM f_post_detail TABLES ft_post
                            USING lwa_out lv_bschl lv_hkont lv_mwskz
                                  lv_ztax lv_wrbtr
                            CHANGING ft_post-buzeipost.
    ENDDO.
    CLEAR: lwa_out, lv_count,
           lv_wrbtr1, lv_wrbtr2, lv_wrbtr3, lv_wrbtr4,
           lv_wrbtr5, lv_wrbtr6, lv_wrbtr7, lv_wrbtr8.
  ENDLOOP.

  IF pa_ztype EQ 'R'.
    lv_bschl  = '40'.
  ELSE.
    lv_bschl  = '50'.
  ENDIF.

  IF fu_flag EQ '0'.
    IF fu_inputgsber IS NOT INITIAL.
      DESCRIBE TABLE ft_post LINES lv_count.
      LOOP AT gt_manba.
        ADD 1 TO lv_count.

        READ TABLE gt_tbsl WITH KEY bschl = lv_bschl.
        IF gt_tbsl-shkzg EQ 'H'.
          ft_post-wrbtr     = gt_manba-wrbtr * -1.
        ELSE.
          ft_post-wrbtr = gt_manba-wrbtr.
        ENDIF.
        ft_post-icon  = icon_led_green.
        ft_post-wrbtr = gt_manba-wrbtr.
        READ TABLE gt_zfgsgsber WITH KEY gsber = gt_manba-gsber.
        IF sy-subrc EQ 0.
          ft_post-buzeipost = lv_count.
          ft_post-bschl     = lv_bschl.
          ft_post-account   = gt_zfgsgsber-hkont.
          READ TABLE gt_skat WITH KEY saknr = gt_zfgsgsber-hkont.
          IF sy-subrc EQ 0.
            ft_post-description = gt_skat-txt20.
          ENDIF.
          APPEND ft_post.
        ENDIF.
      ENDLOOP.
    ELSEIF fu_inputhkont IS NOT INITIAL.
      DELETE gt_manhk WHERE bschl EQ space.
      DESCRIBE TABLE ft_post LINES lv_count.
      LOOP AT gt_manhk WHERE blart EQ 'SA'.
        ADD 1 TO lv_count.
        READ TABLE gt_tbsl WITH KEY bschl = gt_manhk-bschl.
        IF gt_tbsl-shkzg EQ 'H'.
          ft_post-wrbtr     = gt_manhk-wrbtr * -1.
        ELSE.
          ft_post-wrbtr     = gt_manhk-wrbtr.
        ENDIF.
        ft_post-icon      = icon_led_green.
        ft_post-buzeipost = lv_count.
        ft_post-bschl     = gt_manhk-bschl.
        ft_post-account   = gt_manhk-hkont.
        ft_post-zfbdt     = gt_manhk-zfbdt.
        ft_post-zuonr     = gt_manhk-zuonr.
        ft_post-vbund     = gt_manhk-vbund.
        ft_post-kostl     = gt_manhk-kostl.
        IF gv_tmmt IS NOT INITIAL.
          ft_post-sgtxt   = gt_manhk-sgtxt.
        ENDIF.
        IF gv_stm IS NOT INITIAL.
          ft_post-sgtxt   = gt_manhk-sgtxt.
        ENDIF.
        SELECT SINGLE txt20
          FROM skat
          INTO ft_post-description
          WHERE saknr EQ gt_manhk-hkont.
        APPEND ft_post.
      ENDLOOP.
    ENDIF.
  ELSE.
    IF fu_inputhkont IS NOT INITIAL.
      DELETE gt_manhk WHERE bschl EQ space.
      DESCRIBE TABLE ft_post LINES lv_count.
      LOOP AT gt_manhk WHERE blart EQ 'DR'.
        ADD 1 TO lv_count.
        READ TABLE gt_tbsl WITH KEY bschl = gt_manhk-bschl.
        ft_post-koart   = gt_tbsl-koart.
        IF gt_tbsl-shkzg EQ 'H'.
          ft_post-wrbtr     = gt_manhk-wrbtr * -1.
        ELSE.
          ft_post-wrbtr     = gt_manhk-wrbtr.
        ENDIF.
        ft_post-icon      = icon_led_green.
        ft_post-buzeipost = lv_count.
        ft_post-bschl     = gt_manhk-bschl.
        ft_post-account   = gt_manhk-hkont.
        ft_post-zfbdt     = gt_manhk-zfbdt.
        ft_post-zuonr     = gt_manhk-zuonr.
        ft_post-vbund     = gt_manhk-vbund.
        ft_post-kostl     = gt_manhk-kostl.
        SELECT SINGLE txt20
          FROM skat
          INTO ft_post-description
          WHERE saknr EQ gt_manhk-hkont.
        APPEND ft_post.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_POST_DETAIL
*&---------------------------------------------------------------------*
FORM f_post_detail  TABLES   ft_post  STRUCTURE gt_postacc
                    USING    fwa_out  STRUCTURE gt_out
                             fu_bschl fu_hkont fu_mwskz fu_ztax fu_wrbtr
                    CHANGING fc_buzei.

  IF fu_bschl IS NOT INITIAL.
    ft_post-icon  = icon_led_green.
    ADD 1 TO fc_buzei.
    ft_post-buzeipost = fc_buzei.
    ft_post-bschl     = fu_bschl.
    ft_post-sgtxt     = fwa_out-sgtxt.
    ft_post-mwskz     = fu_mwskz.
    READ TABLE gt_tbsl WITH KEY bschl = fu_bschl.
    IF sy-subrc EQ 0.
      ft_post-koart = gt_tbsl-koart.
      IF fu_bschl EQ '01'.
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
*&      Form  F_GET_ZFGSACC
*&---------------------------------------------------------------------*
FORM f_get_zfgsacc  TABLES   ft_zfgs STRUCTURE gt_zfgsacc
                    USING    fu_ztype fu_zsubtype fu_gsber fu_flag
                    CHANGING fc_blart fc_count
                             fc_inputppn fc_inputgsber fc_inputhkont.

  DATA: lt_skat  LIKE gt_skat OCCURS 0 WITH HEADER LINE,
        lwa_zfgs LIKE gt_zfgsacc,
        lv_count TYPE i,
        lv_hkont TYPE hkont.

  CASE fu_flag.
    WHEN '0'.
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
             zinputgsber zinputhkont
             kostl vbund vkorg werks kmvkbu
             wwsfr wwpfn wwpos
        FROM zfgsacc
        INTO CORRESPONDING FIELDS OF TABLE ft_zfgs
        WHERE ztype    EQ fu_ztype     AND
              zsubtype EQ fu_zsubtype  AND
              gsber    EQ fu_gsber.
    WHEN '1'.
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
             zinputgsber zinputhkont
             kostl vbund vkorg werks kmvkbu
             wwsfr wwpfn wwpos
        FROM zfgsaccdn
        INTO CORRESPONDING FIELDS OF TABLE ft_zfgs
        WHERE ztype    EQ fu_ztype     AND
              zsubtype EQ fu_zsubtype  AND
              gsber    EQ fu_gsber.
  ENDCASE.

  READ TABLE ft_zfgs INTO lwa_zfgs INDEX 1.
  IF sy-subrc EQ 0.
    fc_blart      = lwa_zfgs-blart.
    gv_zsubtype   = lwa_zfgs-zsubtype.
    IF fc_inputppn IS INITIAL.
      fc_inputppn  = lwa_zfgs-zinputppn.
    ENDIF.
    IF fc_inputgsber IS INITIAL.
      fc_inputgsber = lwa_zfgs-zinputgsber.
    ENDIF.
    IF fc_inputhkont IS INITIAL.
      fc_inputhkont = lwa_zfgs-zinputhkont.
    ENDIF.
    CLEAR fc_count.
    DO 8 TIMES.
      CLEAR lv_hkont.
      CASE fc_count.
        WHEN 0.
          lv_hkont  = lwa_zfgs-hkont1.
        WHEN 1.
          lv_hkont  = lwa_zfgs-hkont2.
        WHEN 2.
          lv_hkont  = lwa_zfgs-hkont3.
        WHEN 3.
          lv_hkont  = lwa_zfgs-hkont4.
        WHEN 4.
          lv_hkont  = lwa_zfgs-hkont5.
        WHEN 5.
          lv_hkont  = lwa_zfgs-hkont6.
        WHEN 6.
          lv_hkont  = lwa_zfgs-hkont7.
        WHEN 7.
          lv_hkont  = lwa_zfgs-hkont8.
      ENDCASE.
      PERFORM f_count TABLES lt_skat
                      USING lv_hkont
                      CHANGING fc_count.
    ENDDO.
    IF fu_zsubtype EQ '31'.
      ADD 2 TO fc_count.
    ENDIF.
  ENDIF.

  SORT lt_skat BY saknr.
  DELETE ADJACENT DUPLICATES FROM lt_skat COMPARING saknr.
  IF lt_skat[] IS NOT INITIAL.
    SELECT saknr txt20
      FROM skat
      APPENDING TABLE gt_skat
      FOR ALL ENTRIES IN lt_skat
      WHERE spras EQ sy-langu AND
            ktopl EQ 'TSPC'   AND
            saknr EQ lt_skat-saknr.
    IF gt_zfgsgsber[] IS NOT INITIAL.
      SELECT saknr txt20
        FROM skat
        APPENDING TABLE gt_skat
        FOR ALL ENTRIES IN gt_zfgsgsber
        WHERE spras EQ sy-langu AND
              ktopl EQ 'TSPC'   AND
              saknr EQ gt_zfgsgsber-hkont.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_ZFGSACC

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
      criteria          = criteria
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
*&      Form  F_BAPI_DOCUMENT_POST
*&---------------------------------------------------------------------*
FORM f_bapi_document_post  TABLES   accountgl         STRUCTURE bapiacgl09
                                    accountpayable    STRUCTURE bapiacap09
                                    accountreceivable STRUCTURE bapiacar09
                                    currencyamount    STRUCTURE bapiaccr09
                                    extension1        STRUCTURE bapiacextc
                                    criteria          STRUCTURE bapiackec9
                                    return            STRUCTURE bapiret2
                                    ft_post           STRUCTURE gt_post
                            USING   documentheader    STRUCTURE bapiache09
                                    obj_type fu_flag
                            CHANGING fc_subrc.

  DATA: lv_zgsno TYPE zgsno,
        lv_belnr TYPE belnr_d,
        lv_gjahr TYPE gjahr,
        lt_post  LIKE gt_postacc OCCURS 0 WITH HEADER LINE.

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

  PERFORM f_change_bline_date TABLES accountgl ft_post
                              USING documentheader-doc_type lv_belnr pa_bukrs lv_gjahr pa_bldat.

  lt_post[] = ft_post[].
  SORT lt_post BY bukrs belnr gjahr.
  DELETE ADJACENT DUPLICATES FROM lt_post COMPARING bukrs belnr gjahr.

  SELECT DISTINCT bukrs, gsber, belnr, gjahr, zgsno, belnrgs
    INTO TABLE @DATA(lt_zfgscab)
    FROM zfgscab FOR ALL ENTRIES IN @lt_post
    WHERE bukrs EQ @lt_post-bukrs AND
          belnr EQ @lt_post-belnr AND
          gjahr EQ @lt_post-gjahr.

  LOOP AT lt_post.
    DATA(lv_belnrgs) = VALUE #( lt_zfgscab[ bukrs = lt_post-bukrs
                                            belnr = lt_post-belnr
                                            gjahr = lt_post-gjahr ]-belnrgs OPTIONAL ).
    lv_zgsno = VALUE #( lt_zfgscab[ bukrs = lt_post-bukrs
                                    belnr = lt_post-belnr
                                    gjahr = lt_post-gjahr ]-zgsno OPTIONAL ).
    IF lv_belnrgs IS NOT INITIAL.
      UPDATE zfgscab_cl SET xref2 = pa_xref2
                        WHERE belnr = lv_belnrgs
                          AND gjahr = lt_post-gjahr
                          AND zgsno = lv_zgsno.
    ENDIF.

    IF fu_flag EQ '0'.
      PERFORM f_update_zfgscab_add USING gt_out-bukrs
                                         gt_out-gsber
                                         gt_out-belnr
                                         gt_out-gjahr
                                         gt_out-buzei
                                         gt_out-zgsno.

      UPDATE zfgscab SET zsubtype   = lt_post-zsubtype
                         xref2      = pa_xref2
                         xref3      = pa_xref3
                         belnrpost  = lv_belnr
                         gjahrpost  = lv_gjahr
                         userpost   = sy-uname
                         tglpost    = sy-datum
                         jampost    = sy-uzeit
                         gsberk     = gv_gsber1
                         gsbert     = gv_gsber2
                     WHERE bukrs EQ lt_post-bukrs AND
                           belnr EQ lt_post-belnr AND
                           gjahr EQ lt_post-gjahr.
      fc_subrc  = sy-subrc.
    ELSE.
      PERFORM f_update_zfgscab_add USING gt_out-bukrs
                                         gt_out-gsber
                                         gt_out-belnr
                                         gt_out-gjahr
                                         gt_out-buzei
                                         gt_out-zgsno.

      UPDATE zfgscab SET zsubtype   = lt_post-zsubtype
                         xref2      = pa_xref2
                         xref3      = pa_xref3
                         belnrdn    = lv_belnr
                         gjahrpost  = lv_gjahr
                         userpost   = sy-uname
                         tglpost    = sy-datum
                         jampost    = sy-uzeit
                         gsberk     = gv_gsber1
                         gsbert     = gv_gsber2
                     WHERE bukrs EQ lt_post-bukrs AND
                           belnr EQ lt_post-belnr AND
                           gjahr EQ lt_post-gjahr.
      fc_subrc  = sy-subrc.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_BAPI_DOCUMENT_POST

*&---------------------------------------------------------------------*
*&      Form  F_COUNT
*&---------------------------------------------------------------------*
FORM f_count  TABLES   ft_skat STRUCTURE gt_skat
              USING    fu_hkont
              CHANGING fc_count.

  IF fu_hkont IS NOT INITIAL.
    ft_skat-saknr = fu_hkont.
    APPEND ft_skat.
    ADD 1 TO fc_count.
  ENDIF.
ENDFORM.                    " F_COUNT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_WRBTR
*&---------------------------------------------------------------------*
FORM f_modify_wrbtr  USING    fu_count1 fu_count2 fu_ztax
                              fu_zsubtype fu_wrbtr fu_bschl fu_hkont
                              fu_flag fu_inputppn fu_inputgsber fu_inputhkont
                              fu_wrbtr1 fu_wrbtr2 fu_wrbtr3 fu_wrbtr4
                              fu_wrbtr5 fu_wrbtr6 fu_wrbtr7 fu_wrbtr8
                     CHANGING fc_wrbtr.

  DATA: lv_wrbtr  TYPE wrbtr.

  IF fu_flag EQ '0'.
    lv_wrbtr  = fu_wrbtr.
  ELSE.
    READ TABLE gt_postacc WITH KEY account = fu_hkont.
    IF sy-subrc EQ 0.
      lv_wrbtr  = gt_postacc-wrbtr.
    ELSE.
      lv_wrbtr  = fu_wrbtr.
    ENDIF.
  ENDIF.

  lv_wrbtr  = abs( lv_wrbtr ).
  READ TABLE gt_tbsl WITH KEY bschl = fu_bschl.
  IF gt_tbsl-shkzg EQ 'H'.
    lv_wrbtr  = lv_wrbtr * -1.
  ELSE.
    lv_wrbtr  = lv_wrbtr.
  ENDIF.

  IF fu_inputppn IS NOT INITIAL.
    PERFORM f_special16 USING fu_hkont fu_bschl fu_flag gt_tbsl-shkzg fu_ztax
                              fu_count1 fu_count2
                              fu_wrbtr1 fu_wrbtr2 fu_wrbtr3 fu_wrbtr4
                              fu_wrbtr5 fu_wrbtr6 fu_wrbtr7 fu_wrbtr8
                        CHANGING fc_wrbtr.
  ELSE.
    IF fu_count2 EQ 2.
      fc_wrbtr  = lv_wrbtr * ( fu_ztax / 100 ).
    ELSE.
      IF fu_count1 EQ fu_count2.
        IF fu_inputhkont IS NOT INITIAL.
          fc_wrbtr  = lv_wrbtr * ( fu_ztax / 100 ).
        ELSE.
          fc_wrbtr  = fu_wrbtr1 + fu_wrbtr2 + fu_wrbtr3 + fu_wrbtr4 +
                      fu_wrbtr5 + fu_wrbtr6 + fu_wrbtr7 + fu_wrbtr8.
          PERFORM f_shkzg USING gt_tbsl-shkzg
                          CHANGING fc_wrbtr.
        ENDIF.
      ELSE.
        CASE fu_zsubtype.
          WHEN '15'.
            PERFORM f_special15 USING fu_hkont fu_flag lv_wrbtr fu_wrbtr1 fu_wrbtr2 fu_ztax
                                      gt_tbsl-shkzg
                                CHANGING fc_wrbtr.
          WHEN OTHERS.
            fc_wrbtr  = lv_wrbtr * ( fu_ztax / 100 ).
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_WRBTR

*&---------------------------------------------------------------------*
*&      Form  F_SHKZG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_TBSL_SHKZG  text
*      <--P_FC_WRBTR  text
*----------------------------------------------------------------------*
FORM f_shkzg  USING    fu_shkzg
              CHANGING fc_wrbtr.
  IF fu_shkzg EQ 'H'.
    IF fc_wrbtr GT 0.
      fc_wrbtr  = fc_wrbtr * -1.
    ENDIF.
  ELSE.
    IF fc_wrbtr LT 0.
      fc_wrbtr  = fc_wrbtr * -1.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_SHKZG

*&---------------------------------------------------------------------*
*&      Form  F_SPECIAL15
*&---------------------------------------------------------------------*
FORM f_special15  USING    fu_hkont fu_flag fu_wrbtr fu_wrbtr1 fu_wrbtr2
                           fu_ztax fu_shkzg
                  CHANGING fc_wrbtr.

  IF fu_hkont EQ '0315300100'.
    fc_wrbtr  = ( fu_wrbtr1 + fu_wrbtr2 ) * ( fu_ztax / 100 ).
  ELSEIF fu_hkont EQ '0142100020'.
    IF fu_flag EQ 0.
      fc_wrbtr  = fu_wrbtr * ( fu_ztax / 100 ).
    ELSE.
      fc_wrbtr  = fu_wrbtr2 * ( fu_ztax / 100 ).
      PERFORM f_shkzg USING fu_shkzg
                      CHANGING fc_wrbtr.
    ENDIF.
  ELSE.
    fc_wrbtr  = fu_wrbtr * ( fu_ztax / 100 ).
  ENDIF.
ENDFORM.                    " F_SPECIAL15

*&---------------------------------------------------------------------*
*&      Form  F_SPECIAL16
*&---------------------------------------------------------------------*
FORM f_special16  USING    fu_hkont fu_bschl fu_flag fu_shkzg fu_ztax
                           fu_count1 fu_count2
                           fu_wrbtr1 fu_wrbtr2 fu_wrbtr3 fu_wrbtr4
                           fu_wrbtr5 fu_wrbtr6 fu_wrbtr7 fu_wrbtr8
                  CHANGING fc_wrbtr.
  DATA: lv_index     TYPE sy-tabix,
        lv_wrbtr(15),
        lv_subrc     TYPE sy-subrc.

  IF fu_flag EQ '0'.
    IF fu_bschl EQ '50'.
      lv_wrbtr  = gv_wrbtr.
      CLEAR lv_subrc.
      WHILE lv_subrc IS INITIAL.
        REPLACE '.' WITH space INTO lv_wrbtr.
        lv_subrc  = sy-subrc.
      ENDWHILE.
      CONDENSE lv_wrbtr NO-GAPS.
      fc_wrbtr  = lv_wrbtr / 100.
      IF fu_shkzg EQ 'H'.
        fc_wrbtr  = fc_wrbtr * -1.
      ENDIF.
    ELSE.
      READ TABLE gt_mantax WITH KEY hkont = fu_hkont
                                    flag  = space.
      IF sy-subrc EQ 0.
        lv_index        = sy-tabix.
        fc_wrbtr        = gt_mantax-wrbtr.
        gt_mantax-flag  = 'X'.
        MODIFY gt_mantax INDEX lv_index TRANSPORTING flag .
      ENDIF.
    ENDIF.
  ELSE.
    READ TABLE gt_mantax WITH KEY hkont = fu_hkont.
    IF sy-subrc EQ 0.
      fc_wrbtr        = gt_mantax-wrbtr.
    ELSE.
      IF fu_count1 EQ fu_count2.
        fc_wrbtr  = fu_wrbtr1 + fu_wrbtr2 + fu_wrbtr3 + fu_wrbtr4 +
                    fu_wrbtr5 + fu_wrbtr6 + fu_wrbtr7 + fu_wrbtr8.
      ELSE.
        fc_wrbtr        = fc_wrbtr * ( fu_ztax / 100 ).
      ENDIF.
    ENDIF.
    PERFORM f_shkzg USING fu_shkzg
                    CHANGING fc_wrbtr.
  ENDIF.
ENDFORM.                    " F_SPECIAL16

*&---------------------------------------------------------------------*
*&      Form  F_GET_TAX_MANUAL_ENTRY
*&---------------------------------------------------------------------*
FORM f_get_tax_manual_entry TABLES ft_zfgs STRUCTURE gt_zfgsacc.
  READ TABLE ft_zfgs INDEX 1.
  IF sy-subrc EQ 0.
    IF ft_zfgs-hkont1 IS NOT INITIAL AND
      ft_zfgs-ztax1 IS INITIAL.
      gt_mantax-bschl = ft_zfgs-bschl1.
      gt_mantax-hkont = ft_zfgs-hkont1.
      APPEND gt_mantax.
    ELSEIF ft_zfgs-bschl1 EQ '50'.
      gv_bschl    = ft_zfgs-bschl1.
      gv_hkont    = ft_zfgs-hkont1.
    ENDIF.
    IF ft_zfgs-hkont2 IS NOT INITIAL AND
      ft_zfgs-ztax2 IS INITIAL.
      gt_mantax-bschl = ft_zfgs-bschl2.
      gt_mantax-hkont = ft_zfgs-hkont2.
      APPEND gt_mantax.
    ELSEIF ft_zfgs-bschl2 EQ '50'.
      gv_bschl    = ft_zfgs-bschl2.
      gv_hkont    = ft_zfgs-hkont2.
    ENDIF.
    IF ft_zfgs-hkont3 IS NOT INITIAL AND
      ft_zfgs-ztax3 IS INITIAL.
      gt_mantax-bschl = ft_zfgs-bschl3.
      gt_mantax-hkont = ft_zfgs-hkont3.
      APPEND gt_mantax.
    ELSEIF ft_zfgs-bschl3 EQ '50'.
      gv_bschl    = ft_zfgs-bschl3.
      gv_hkont    = ft_zfgs-hkont3.
    ENDIF.
    IF ft_zfgs-hkont4 IS NOT INITIAL AND
      ft_zfgs-ztax4 IS INITIAL.
      gt_mantax-bschl = ft_zfgs-bschl4.
      gt_mantax-hkont = ft_zfgs-hkont4.
      APPEND gt_mantax.
    ELSEIF ft_zfgs-bschl4 EQ '50'.
      gv_bschl    = ft_zfgs-bschl4.
      gv_hkont    = ft_zfgs-hkont4.
    ENDIF.
    IF ft_zfgs-hkont5 IS NOT INITIAL AND
      ft_zfgs-ztax5 IS INITIAL.
      gt_mantax-bschl = ft_zfgs-bschl5.
      gt_mantax-hkont = ft_zfgs-hkont5.
      APPEND gt_mantax.
    ELSEIF ft_zfgs-bschl5 EQ '50'.
      gv_bschl    = ft_zfgs-bschl5.
      gv_hkont    = ft_zfgs-hkont5.
    ENDIF.
    IF ft_zfgs-hkont6 IS NOT INITIAL AND
      ft_zfgs-ztax6 IS INITIAL.
      gt_mantax-bschl = ft_zfgs-bschl6.
      gt_mantax-hkont = ft_zfgs-hkont6.
      APPEND gt_mantax.
    ELSEIF ft_zfgs-bschl6 EQ '50'.
      gv_bschl    = ft_zfgs-bschl6.
      gv_hkont    = ft_zfgs-hkont6.
    ENDIF.
    IF ft_zfgs-hkont7 IS NOT INITIAL AND
      ft_zfgs-ztax7 IS INITIAL.
      gt_mantax-bschl = ft_zfgs-bschl7.
      gt_mantax-hkont = ft_zfgs-hkont7.
      APPEND gt_mantax.
    ELSEIF ft_zfgs-bschl7 EQ '50'.
      gv_bschl    = ft_zfgs-bschl7.
      gv_hkont    = ft_zfgs-hkont7.
    ENDIF.
    IF ft_zfgs-hkont8 IS NOT INITIAL AND
      ft_zfgs-ztax8 IS INITIAL.
      gt_mantax-bschl = ft_zfgs-bschl8.
      gt_mantax-hkont = ft_zfgs-hkont8.
      APPEND gt_mantax.
    ELSEIF ft_zfgs-bschl8 EQ '50'.
      gv_bschl    = ft_zfgs-bschl8.
      gv_hkont    = ft_zfgs-hkont8.
    ENDIF.
  ENDIF.

  READ TABLE gt_skat WITH KEY saknr = gv_hkont.
  IF sy-subrc EQ 0.
    gv_txt20  = gt_skat-txt20.
  ENDIF.

  LOOP AT gt_mantax.
    READ TABLE gt_skat WITH KEY saknr = gt_mantax-hkont.
    IF sy-subrc EQ 0.
      gt_mantax-txt20 = gt_skat-txt20.
      MODIFY gt_mantax TRANSPORTING txt20.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_TAX_MANUAL_ENTRY

*&---------------------------------------------------------------------*
*&      Module  STATUS_9002  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_9002 OUTPUT.
  SET PF-STATUS 'STATUS_9002'.
  DESCRIBE TABLE gt_mantax LINES fill.
  mantax-lines = fill.
ENDMODULE.                 " STATUS_9002  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_9003  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_9003 OUTPUT.
  SET PF-STATUS 'STATUS_9002'.
  DESCRIBE TABLE gt_manba LINES fill.
  manba-lines = fill.
ENDMODULE.                 " STATUS_9003  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL_MANTAX  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_table_control_mantax OUTPUT.
  READ TABLE gt_mantax INTO wa_mantax INDEX mantax-current_line.
ENDMODULE.                 " FILL_TABLE_CONTROL_MANTAX  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL_MANTAX  INPUT
*&---------------------------------------------------------------------*
MODULE read_table_control_mantax INPUT.
  lines = sy-loopc.
  MODIFY gt_mantax FROM wa_mantax INDEX mantax-current_line.
ENDMODULE.                 " READ_TABLE_CONTROL_MANTAX  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9002 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'CANCEL'.
      LOOP AT gt_mantax.
        CLEAR gt_mantax-wrbtr.
        MODIFY gt_mantax TRANSPORTING wrbtr.
      ENDLOOP.
      sy-subrc = 4.
      LEAVE TO SCREEN 0.
    WHEN '&POS'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_9002  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9003  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9003 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'CANCEL'.
      LOOP AT gt_manba.
        CLEAR gt_manba-gsber.
        MODIFY gt_manba TRANSPORTING gsber.
      ENDLOOP.
      sy-subrc = 4.
      LEAVE TO SCREEN 0.
    WHEN '&POS'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_9003  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DN
*&---------------------------------------------------------------------*
FORM f_print_dn USING p_formname TYPE tdsfname fu_zform
                CHANGING fc_subrc fc_nomor.
  DATA:
    l_funcname         TYPE tdsfname,
    l_total_pages      TYPE tdsffpage,
    lwa_control_option TYPE ssfctrlop,
    lwa_output_option  TYPE ssfcompop,
    lwa_doc_info       TYPE ssfcrespd,
    lwa_output_info    TYPE ssfcrescl.

  DATA: lv_wrbtr     TYPE wrbtr,
        lv_month(40),
        in_words     LIKE spell OCCURS 0 WITH HEADER LINE,
        lt_kna1      LIKE gt_postdn OCCURS 0 WITH HEADER LINE,
        ls_zfgstt    LIKE LINE OF gt_zfgstt.

  DATA : lt_postdn LIKE gt_post OCCURS 0 WITH HEADER LINE,
         lv_lines  TYPE i,
         lt_detail LIKE zfstgsdn OCCURS 0 WITH HEADER LINE.

  DATA: job_output_info TYPE ssfcrescl,
        ls_spoolid      LIKE LINE OF job_output_info-spoolids,
        lv_spoolno      LIKE tsp01-rqident,
        lv_filepusat    TYPE zfilepusat.

  DATA : lv_name2     TYPE zfgsnomor2-name2,
         lv_txt1(100),
         lv_length    TYPE i.

  DATA : ls_cust  LIKE LINE OF gt_cust,
         lv_str1  TYPE string,
         lv_str2  TYPE string,
         lv_subrc TYPE sy-subrc.

  lt_postdn[] = gt_postdn[].
  SORT lt_postdn BY zsubtype.
  DELETE ADJACENT DUPLICATES FROM lt_postdn COMPARING zsubtype.
  DESCRIBE TABLE lt_postdn LINES lv_lines.
  IF lv_lines = 1.
    READ TABLE lt_postdn INDEX 1.
    IF lt_postdn-ztype = 'D' AND
      lt_postdn-zsubtype = '60'.
      gv_flag = 'X'.
    ENDIF.
  ENDIF.

  IF lt_postdn[] IS NOT INITIAL.
    SELECT a~bukrs, a~gsber, a~belnr, a~gjahr, a~zgsno, a~belnrgs, b~clnr, b~kdgrp
      INTO TABLE @DATA(lt_clnr)
      FROM zfgscab AS a JOIN zfgscab_cl AS b ON a~belnrgs = b~belnr AND
                                                a~gjahr = b~gjahr   AND
                                                a~zgsno = b~zgsno
      FOR ALL ENTRIES IN @lt_postdn
      WHERE a~bukrs = @lt_postdn-bukrs
        AND a~belnr = @lt_postdn-belnr
        AND a~gjahr = @lt_postdn-gjahr
        AND a~zsubtype IN ('15','57').
    SORT lt_clnr BY bukrs belnr gjahr clnr.
    DELETE ADJACENT DUPLICATES FROM lt_clnr COMPARING bukrs belnr gjahr clnr.
  ENDIF.

  SORT gt_postdn BY account DESCENDING.
  LOOP AT gt_postdn.
    IF gv_flag IS NOT INITIAL.
      IF gt_postdn-ogtxt IS INITIAL.
        gt_postdn-ogtxt = gt_postdn-sgtxt.
        MODIFY gt_postdn TRANSPORTING ogtxt.
      ENDIF.
    ENDIF.
    IF gt_postdn-bschl EQ '01'.
      gt_head       = gv_t001.
      gt_head-vbund = gt_postdn-vbund.
      gt_head-kunnr = gt_postdn-account.
      gt_head-waers = 'IDR'.
      gt_head-wrbtr = gt_postdn-wrbtr.
      gt_head-xref3 = pa_xblnr.
      gt_head-kuntm = gt_postdn-kuntm.

      CLEAR ls_cust.
      READ TABLE gt_cust INTO ls_cust
                         WITH KEY kunnr = gt_postdn-kuntm.
      IF sy-subrc = 0.
        gt_head-zdesc   = ls_cust-zdesc.
      ENDIF.

      READ TABLE gt_kna1 WITH KEY kunnr = gt_postdn-account.
      IF sy-subrc EQ 0.
        gt_head-name1_to       = gt_kna1-name1.
        gt_head-street_to      = gt_kna1-street.
        gt_head-post_code1_to  = gt_kna1-post_code1.
        gt_head-city1_to       = gt_kna1-city1.
      ENDIF.
      IF pa_xref2 IS INITIAL.
        READ TABLE gt_out WITH KEY bukrs = gt_postdn-bukrs
                                   belnr = gt_postdn-belnr.
        IF sy-subrc EQ 0.
          gt_head-xref2  = gt_out-xref2.
        ENDIF.
      ELSE.
        gt_head-xref2  = pa_xref2.
      ENDIF.

      CLEAR: gt_head-kdgrp,gt_head-clnr.
      IF gt_postdn-zsubtype = '15' OR gt_postdn-zsubtype = '57'.
        gt_head-kdgrp = VALUE #( lt_clnr[ bukrs = lt_postdn-bukrs
                                          belnr = lt_postdn-belnr
                                          gjahr = lt_postdn-gjahr ]-kdgrp OPTIONAL ).
        LOOP AT lt_clnr INTO DATA(ls_clnr) WHERE bukrs = lt_postdn-bukrs
                                             AND belnr = lt_postdn-belnr
                                             AND gjahr = lt_postdn-gjahr.
          IF gt_head-clnr IS INITIAL.
            gt_head-clnr = ls_clnr-clnr.
          ELSE.
            gt_head-clnr = | { gt_head-clnr }; { ls_clnr-clnr } |.
          ENDIF.
        ENDLOOP.
      ENDIF.

      COLLECT gt_head.
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
    lwa_output_option-tdnewid  = 'X'.
    lwa_output_option-tdimmed  = 'X'.
  ELSE.
    lwa_output_option-tdnoprint = 'X'.
  ENDIF.

  LOOP AT gt_head.
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

      lv_month  = pa_datum+4(2).
      CALL FUNCTION 'ZMONTH_NAME'
        EXPORTING
          month = lv_month
        IMPORTING
          name  = lv_month.
      CONCATENATE gt_head-city1_ho ',' pa_datum+6(2) lv_month pa_datum(4)
      INTO gt_head-datum
      SEPARATED BY space.

      gt_head-petugas = gv_petugas1.
      gt_head-jabatan = gv_jabat1.
      gt_head-graph   = gv_graph.
      IF gt_postdn-zsubtype = '61' OR gt_postdn-zsubtype = '21'.
        gt_head-graph = 'KEH'.
      ENDIF.

      CASE gv_zsubtype.
        WHEN '15' OR '57'.
          SELECT SINGLE name2
            FROM zfgsnomor2
            INTO lv_name2
            WHERE gsber = gv_gsber
              AND vbund = gt_head-vbund
              AND spmon = pa_budat(6). "pa_spmon.

          CASE 'X'.
            WHEN radio1.
              CONCATENATE lv_name2 pa_budat+4(2) pa_budat+2(2) '/' INTO gt_head-nomordn.
              CONCATENATE gt_head-nomordn 'MT' '/' fc_nomor  INTO gt_head-nomordn.
            WHEN radio4.
              gt_head-nomordn = gt_head-xref2.
              lv_length = strlen( gt_head-nomordn ).
              lv_length = lv_length - 1.
              IF gt_head-nomordn+lv_length(1) = '/'.
                gt_head-nomordn+lv_length = 'MT'.
              ELSE.
                SPLIT gt_head-nomordn AT '/' INTO lv_str1 lv_str2.
                CONCATENATE lv_str1 'MT' lv_str2 INTO gt_head-nomordn
                SEPARATED BY '/'.
              ENDIF.
          ENDCASE.
        WHEN OTHERS.
          CONCATENATE fc_nomor '/' pa_spmon+4(2) '/' pa_spmon(4) INTO gt_head-nomordn.
      ENDCASE.

      CONCATENATE pa_gsber '-' gv_gtext INTO gt_head-cabang
      SEPARATED BY space.

      gt_head-subtype = gv_zsubtype.
      MODIFY gt_head TRANSPORTING totaltxt terbilang datum petugas jabatan nomordn graph
                                  cabang subtype.
      ADD 1 TO fc_nomor.
    ENDIF.

    CLEAR: gt_detail, gt_detail[].
    LOOP AT gt_postdn WHERE vbund EQ gt_head-vbund AND
                            bschl NE '01'.
      gt_detail-hkont = gt_postdn-account.
      READ TABLE gt_out WITH KEY bukrs = gt_postdn-bukrs
                                 belnr = gt_postdn-belnr.
      IF sy-subrc EQ 0.
        CONCATENATE gt_out-txt1 gt_out-txt2 gt_out-txt3 gt_out-txt4
        INTO gt_detail-text
        SEPARATED BY space.

        PERFORM f_get_period USING gt_out-perfr
                                   gt_out-perto
                             CHANGING gt_detail-perfr
                                      gt_detail-perto
                                      gt_detail-period.
      ENDIF.
*      READ TABLE gt_skat WITH KEY saknr = gt_postdn-account.
*      IF sy-subrc EQ 0.
*        gt_detail-text  = gt_skat-txt20.
*      ENDIF.
      gt_detail-wrbtr = gt_postdn-wrbtr.

      IF gt_postdn-account(6) = '012222' AND
        gt_postdn-ztype = 'D' AND
        gt_postdn-zsubtype = '60'.
        APPEND gt_detail.
      ELSE.
        COLLECT gt_detail.
      ENDIF.

      PERFORM f_modify_text USING gt_out-txt1
                            CHANGING lv_txt1.
    ENDLOOP.

    IF lv_txt1 IS NOT INITIAL.
      gv_sgtxt  = lv_txt1.
    ELSE.
      READ TABLE gt_post INDEX 1.
      gv_sgtxt  = gt_post-sgtxt.
    ENDIF.
    gv_waers  = 'IDR'.
    CALL SCREEN 9005 STARTING AT 10 10.

    IF sy-subrc EQ 0.
      SORT gt_detail BY hkont.
      SORT gt_mantext BY hkont.
      LOOP AT gt_detail.
        READ TABLE gt_mantext WITH KEY hkont = gt_detail-hkont
                                       flag  = space.
        IF sy-subrc EQ 0.
          gt_detail-ltext  = gt_mantext-ltext.
          gt_mantext-flag  = 'X'.
          MODIFY gt_mantext INDEX sy-tabix TRANSPORTING flag.
        ENDIF.
        WRITE gt_detail-wrbtr TO gt_detail-wrbtrtxt CURRENCY 'IDR' NO-SIGN.

        PERFORM f_change_ltext CHANGING gt_detail-ltext gt_head-kuntm.

        MODIFY gt_detail TRANSPORTING wrbtrtxt ltext.
* Modify SGTXT & ZUONR
        READ TABLE gt_postdn WITH KEY vbund   = gt_head-vbund
                                      account = gt_detail-hkont
                             TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          READ TABLE gt_postdn ASSIGNING <fs_postdn>
                               WITH KEY bschl = '01'.
          IF sy-subrc = 0.
            <fs_postdn>-sgtxt = gt_detail-ltext.
*            <fs_postdn>-zuonr = pa_xref2.

            CASE gv_zsubtype.
              WHEN '15' OR '57'.
                gt_postdn-zuonr = gt_head-nomordn.
                MODIFY gt_postdn TRANSPORTING zuonr
                                 WHERE zuonr NE gt_head-nomordn.
              WHEN OTHERS.
                gt_postdn-zuonr = pa_xref2.
                MODIFY gt_postdn TRANSPORTING zuonr
                                 WHERE zuonr NE pa_xref2.
            ENDCASE.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF gv_flag IS INITIAL.
        SORT gt_detail BY hkont DESCENDING.
      ELSE.
        lt_detail[] = gt_detail[].
        CLEAR gt_detail[].

        LOOP AT lt_detail WHERE hkont(5) = '01222'.
          APPEND lt_detail TO gt_detail.
          DELETE lt_detail.
        ENDLOOP.
        LOOP AT lt_detail WHERE hkont(5) = '03153'.
          APPEND lt_detail TO gt_detail.
          DELETE lt_detail.
        ENDLOOP.
        LOOP AT lt_detail WHERE hkont(5) = '01421'.
          CONDENSE lt_detail-wrbtrtxt.
          CONCATENATE '-' lt_detail-wrbtrtxt INTO lt_detail-wrbtrtxt.
          APPEND lt_detail TO gt_detail.
          DELETE lt_detail.
        ENDLOOP.
        LOOP AT lt_detail.
          APPEND lt_detail TO gt_detail.
          DELETE lt_detail.
        ENDLOOP.
      ENDIF.

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
        IMPORTING
          job_output_info    = job_output_info
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
        fc_subrc  = sy-subrc.

      ELSE.
        READ TABLE gt_postdn INDEX 1.
        IF gt_postdn-zsubtype = '61' OR gt_postdn-zsubtype = '21'.
          IF job_output_info-spoolids IS NOT INITIAL.
            LOOP AT job_output_info-spoolids INTO ls_spoolid.
              IF ls_spoolid NE space.
                lv_spoolno = ls_spoolid.
              ENDIF.
            ENDLOOP.
            PERFORM f_convert_spool_to_pdf USING lv_spoolno
                                           CHANGING lv_filepusat.
            PERFORM f_update_filepusat USING lv_filepusat.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      fc_subrc  = sy-subrc.
      CLEAR: gt_mantext, gt_mantext[], gt_head, gt_head[], gt_detail, gt_detail[].
    ENDIF.
    lwa_control_option-no_open = 'X'.
  ENDLOOP.
ENDFORM.                    " F_PRINT_DN

*&---------------------------------------------------------------------*
*&      Form  F_GET_DN_NO
*&---------------------------------------------------------------------*
FORM f_get_dn_no  CHANGING fc_subrc fc_nomor.
  DATA : lv_zform      TYPE zfgsnomor-zform,
         ls_out        LIKE LINE OF gt_out,
         ls_zfgsnomor2 TYPE zfgsnomor2.

  CASE gv_zsubtype.
    WHEN '15' OR '57'.
      READ TABLE gt_out INTO ls_out
                        WITH KEY check = 'X'.
      IF sy-subrc = 0.
        fc_nomor  = gv_gsnomor.
        PERFORM f_lock_table USING '2' ls_out-vbund.
      ENDIF.

    WHEN OTHERS.
      lv_zform  = 'DN'.
      SELECT gsber spmon ztype prefix1 prefix2 nomor
        FROM zfgsnomor
        INTO TABLE gt_zfgsnomor
        WHERE gsber EQ pa_gsber
          AND spmon EQ pa_budat(6)
          AND ztype EQ pa_ztype
          AND zform EQ lv_zform.

      fc_subrc  = sy-subrc.

      READ TABLE gt_zfgsnomor INDEX 1.
      IF sy-subrc EQ 0.
        fc_nomor  = gt_zfgsnomor-nomor.
        PERFORM f_lock_table USING '1' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_DN_NO

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE
*&---------------------------------------------------------------------*
FORM f_lock_table USING fu_lock fu_vbund.
  DATA: ld_mess(100).

  CASE fu_lock.
    WHEN '1'.
      CALL FUNCTION 'ENQUEUE_EZFGSNOMOR'
        EXPORTING
          mode_zfgsnomor = 'E'
          mandt          = sy-mandt
          gsber          = pa_gsber
          spmon          = pa_budat(6)   "pa_spmon
          ztype          = pa_ztype
          zform          = 'DN'
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
    WHEN '2'.
      CALL FUNCTION 'ENQUEUE_EZFGSNOMOR2'
        EXPORTING
          gsber          = gv_gsber
          vbund          = fu_vbund
          spmon          = pa_budat(6)   "pa_spmon
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
  ENDCASE.

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
FORM f_unlock_table USING fu_nomor.
  IF pa_prev IS INITIAL.
    UPDATE zfgsnomor SET nomor  = fu_nomor
    WHERE gsber EQ pa_gsber AND
          spmon EQ pa_spmon AND
          ztype EQ pa_ztype AND
          zform EQ 'DN'.
  ENDIF.

  CALL FUNCTION 'DEQUEUE_EZFGSNOMOR'
    EXPORTING
      mode_zfgsnomor = 'X'
      mandt          = sy-mandt
      gsber          = pa_gsber
      spmon          = pa_spmon
      ztype          = pa_ztype
      zform          = 'DN'.
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

  DATA : ls_flag    LIKE LINE OF gt_flag.

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
    READ TABLE gt_out WITH KEY belnr = ft_post-belnr
                               gjahr = ft_post-gjahr.
    IF sy-subrc = 0.
      CLEAR ls_flag.
      READ TABLE gt_flag INTO ls_flag WITH KEY bukrs    = gt_out-bukrs
                                               ztype    = gt_out-ztype
                                               zsubtype = gt_out-zsubtype.
      IF sy-subrc = 0.
        IF ls_flag IS NOT INITIAL.
          CONCATENATE gt_out-txt3+29(4)
                      gt_out-txt3+26(2)
                      gt_out-txt3+23(2) INTO fu_bldat.
        ENDIF.
      ENDIF.
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
*&      Form  F_GET_GSBER_MANUAL_ENTRY
*&---------------------------------------------------------------------*
FORM f_get_gsber_manual_entry  TABLES ft_zfgs STRUCTURE gt_zfgsacc.
  READ TABLE ft_zfgs INDEX 1.
  IF sy-subrc EQ 0.
    gv_bschl    = ft_zfgs-bschl1.
    gv_hkont    = ft_zfgs-hkont1.
    READ TABLE gt_skat WITH KEY saknr = ft_zfgs-hkont1.
    IF sy-subrc EQ 0.
      gv_txt20  = gt_skat-txt20.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_GSBER_MANUAL_ENTRY

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL_MANBA  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_table_control_manba OUTPUT.
  READ TABLE gt_manba INTO wa_manba INDEX manba-current_line.
ENDMODULE.                 " FILL_TABLE_CONTROL_MANBA  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL_MANBA  INPUT
*&---------------------------------------------------------------------*
MODULE read_table_control_manba INPUT.
  lines = sy-loopc.
  MODIFY gt_manba FROM wa_manba INDEX manba-current_line.
ENDMODULE.                 " READ_TABLE_CONTROL_MANBA  INPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_9004  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_9004 OUTPUT.
  SET PF-STATUS 'STATUS_9002'.
  DO 1000 TIMES.
    APPEND gt_manhk.
  ENDDO.
  DESCRIBE TABLE gt_manhk LINES fill.
  manhk-lines = fill.
ENDMODULE.                 " STATUS_9004  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL_MANHK  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_table_control_manhk OUTPUT.
  READ TABLE gt_manhk INTO wa_manhk INDEX manhk-current_line.
ENDMODULE.                 " FILL_TABLE_CONTROL_MANHK  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL_MANHK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_table_control_manhk INPUT.
  lines = sy-loopc.
  MODIFY gt_manhk FROM wa_manhk INDEX manhk-current_line.
ENDMODULE.                 " READ_TABLE_CONTROL_MANHK  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9004  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9004 INPUT.
  DATA : lv_subrc   TYPE sy-subrc.

  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'CANCEL'.
      LOOP AT gt_manhk.
        CLEAR gt_manhk-hkont.
        MODIFY gt_manhk TRANSPORTING hkont.
      ENDLOOP.
      sy-subrc = 4.
      LEAVE TO SCREEN 0.
    WHEN '&POS'.
      IF lv_subrc IS INITIAL.
        LEAVE TO SCREEN 0.
      ELSE.
        CLEAR lv_subrc.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_9004  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_GET_HKONT_MANUAL_ENTRY
*&---------------------------------------------------------------------*
FORM f_get_hkont_manual_entry  TABLES   ft_zfgs STRUCTURE gt_zfgsacc
                               USING    fu_wrbtr
                               CHANGING fc_wrbtr.
  DATA: lv_wrbtr  TYPE wrbtr.
  READ TABLE ft_zfgs INDEX 1.
  IF sy-subrc EQ 0.
    gv_bschl    = ft_zfgs-bschl1.
    gv_hkont    = ft_zfgs-hkont1.
    READ TABLE gt_skat WITH KEY saknr = ft_zfgs-hkont1.
    IF sy-subrc EQ 0.
      gv_txt20  = gt_skat-txt20.
    ENDIF.
    lv_wrbtr    = fu_wrbtr * ( ft_zfgs-ztax1 / 100 ).

    lv_wrbtr = abs( lv_wrbtr ).
    READ TABLE gt_tbsl WITH KEY bschl = gv_bschl.
    IF gt_tbsl-shkzg EQ 'H'.
      lv_wrbtr  = lv_wrbtr * -1.
    ENDIF.

    WRITE lv_wrbtr TO fc_wrbtr CURRENCY 'IDR'.
  ENDIF.

  SELECT *
    FROM zfgstmmt
    INTO CORRESPONDING FIELDS OF TABLE gt_zfgstmmt.

  SELECT *
    FROM zfgsstm
    INTO CORRESPONDING FIELDS OF TABLE gt_zfgsstm.
ENDFORM.                    " F_GET_HKONT_MANUAL_ENTRY

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL_MANTEXT  OUTPUT
*&---------------------------------------------------------------------*
MODULE fill_table_control_mantext OUTPUT.
  READ TABLE gt_mantext INTO wa_mantext INDEX mantext-current_line.
  IF wa_mantext-wrbtr IS NOT INITIAL.
    IF wa_mantext-wrbtr < 0.
      wa_mantext-wrbtr = wa_mantext-wrbtr * -1.

      IF gv_flag IS INITIAL OR
        wa_mantext-hkont(5) <> '01222'.
        IF pa_bukrs = '8020' OR pa_bukrs = '8070'.
*        wa_mantext-ltext = pa_bktxt.             "Command on 27.11.2019
          wa_mantext-ltext = gv_sgtxt.              "Active on 27.11.2019
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " FILL_TABLE_CONTROL_MANTEXT  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TABLE_CONTROL_MANTEXT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_table_control_mantext INPUT.
  lines = sy-loopc.
  MODIFY gt_mantext FROM wa_mantext INDEX mantext-current_line.
ENDMODULE.                 " READ_TABLE_CONTROL_MANTEXT  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TEXT
*&---------------------------------------------------------------------*
FORM f_modify_text USING fu_txt1
                   CHANGING fc_txt1.
  gt_mantext-hkont  = gt_detail-hkont.
  gt_mantext-wrbtr  = gt_detail-wrbtr.

  IF gt_postdn-account(6) = '012222' AND
    gt_postdn-ztype = 'D' AND
    gt_postdn-zsubtype = '60'.
    gt_mantext-ltext  = gt_postdn-sgtxt.
    APPEND gt_mantext.
  ELSE.
    gt_mantext-ltext  = gt_detail-text.
    fc_txt1 = fu_txt1.
    COLLECT gt_mantext.
  ENDIF.
ENDFORM.                    " F_MODIFY_TEXT

*&---------------------------------------------------------------------*
*&      Module  STATUS_9005  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9005 OUTPUT.
  SET PF-STATUS 'STATUS_9002'.
  DESCRIBE TABLE gt_mantext LINES fill.
  mantext-lines = fill.
ENDMODULE.                 " STATUS_9005  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9005  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9005 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'CANCEL'.
      LOOP AT gt_mantext.
        CLEAR gt_mantext-ltext.
        MODIFY gt_mantext TRANSPORTING ltext.
      ENDLOOP.
      sy-subrc = 4.
      LEAVE TO SCREEN 0.
    WHEN '&POS'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_9005  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALIDASI_FIELD  INPUT
*&---------------------------------------------------------------------*
MODULE validasi_field INPUT.
  IF sy-ucomm NE 'CANCEL'.
    IF pa_xblnr IS NOT INITIAL.
      IF gv_tmmt IS NOT INITIAL.
        PERFORM f_validasi_field USING '1' pa_xblnr '' 'PA_XBLNR'
                              CHANGING lv_subrc.
      ELSEIF gv_stm IS NOT INITIAL.
        PERFORM f_validasi_field USING '3' pa_xblnr '' 'PA_XBLNR'
                              CHANGING lv_subrc.
      ENDIF.
    ENDIF.

    IF pa_bktxt IS NOT INITIAL.
      IF gv_tmmt IS NOT INITIAL.
        PERFORM f_validasi_field USING '2' '' pa_bktxt 'PA_BKTXT'
                               CHANGING lv_subrc.
      ELSEIF gv_stm IS NOT INITIAL.
        PERFORM f_validasi_field USING '4' '' pa_bktxt 'PA_BKTXT'
                               CHANGING lv_subrc.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALIDASI_FIELD  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_FIELD
*&---------------------------------------------------------------------*
FORM f_validasi_field  USING    fu_ztype fu_xblnr fu_bktxt fu_value
                       CHANGING fc_subrc.
  CASE fu_ztype.
    WHEN '1'.
      READ TABLE gt_zfgstmmt WITH KEY ztype = fu_ztype
                                      xblnr = pa_xblnr.
      IF sy-subrc NE 0.
        LOOP AT SCREEN.
          IF screen-name  = fu_value.
            screen-input  = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
        fc_subrc  = '1'.
        MESSAGE 'Reference error' TYPE 'I'.
      ENDIF.
    WHEN '2'.
      READ TABLE gt_zfgstmmt WITH KEY ztype = fu_ztype
                                      bktxt = fu_bktxt.
      IF sy-subrc NE 0.
        LOOP AT SCREEN.
          IF screen-name  = fu_value.
            screen-input  = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
        fc_subrc  = '1'.
        MESSAGE 'Document Header Text error' TYPE 'I'.
      ENDIF.
    WHEN '3'.
      READ TABLE gt_zfgsstm WITH KEY ztype = fu_ztype
                                     xblnr = pa_xblnr.
      IF sy-subrc NE 0.
        LOOP AT SCREEN.
          IF screen-name  = fu_value.
            screen-input  = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
        fc_subrc  = '1'.
        MESSAGE 'Reference error' TYPE 'I'.
      ENDIF.
    WHEN '4'.
      READ TABLE gt_zfgsstm WITH KEY ztype = fu_ztype
                                     bktxt = fu_bktxt.
      IF sy-subrc NE 0.
        LOOP AT SCREEN.
          IF screen-name  = fu_value.
            screen-input  = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
        fc_subrc  = '1'.
        MESSAGE 'Document Header Text error' TYPE 'I'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDASI_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_XREF2
*&---------------------------------------------------------------------*
FORM f_modify_xref2  USING    fu_vbund fu_vbundx fu_budat
                     CHANGING fc_xref2.
  DATA: ls_zfgsnomor2 LIKE zfgsnomor2.
  DATA: lv_vbund  TYPE zfgsnomor2-vbund.

*  IF fu_vbundx IS NOT INITIAL.
*    lv_vbund  = fu_vbundx.
*  ELSE.
  lv_vbund  = fu_vbund.
*  ENDIF.

  SELECT SINGLE * INTO ls_zfgsnomor2
    FROM zfgsnomor2 WHERE gsber = gv_gsber
                      AND vbund = lv_vbund
                      AND spmon = fu_budat(6).
  IF sy-subrc = 0.
    CASE gv_zsubtype.
      WHEN '15' OR '57'.
        CASE 'X'.
          WHEN radio1.
            gv_gsnomor = ls_zfgsnomor2-nomor5t + 1.
            CONCATENATE ls_zfgsnomor2-name2 fu_budat+4(2) fu_budat+2(2) INTO fc_xref2.
            CONCATENATE fc_xref2 gv_gsnomor INTO fc_xref2 SEPARATED BY '/'.
          WHEN OTHERS.
            gv_gsnomor = ls_zfgsnomor2-nomor5t + 1.
            CONCATENATE ls_zfgsnomor2-name2 fu_budat+4(2) fu_budat+2(2) INTO fc_xref2.
            CONCATENATE fc_xref2 gv_gsnomor 'MT' INTO fc_xref2 SEPARATED BY '/'.
        ENDCASE.
      WHEN OTHERS.
        gv_gsnomor = ls_zfgsnomor2-nomor1 + 1.
        CONCATENATE ls_zfgsnomor2-name2 fu_budat+4(2) fu_budat+2(2) INTO fc_xref2.
        CONCATENATE fc_xref2 gv_gsnomor INTO fc_xref2 SEPARATED BY '/'.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_MODIFY_XREF2

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE2
*&---------------------------------------------------------------------*
FORM f_lock_table2  USING    fu_gsber
                             fu_spmon
                             fu_ztype
                             fu_zform
                             fu_vbund.
  DATA: ld_mess(100).

  CALL FUNCTION 'ENQUEUE_EZFGSNOMOR2'
    EXPORTING
*Begin remark Unicode conversion - DEVK966003
*16.03.2020 - SOL_FELIX
*     mode_zfgsnomor  = 'E'
*End remark Unicode conversion - DEVK966003
*Begin insert Unicode conversion - DEVK966003
*16.03.2020 - SOL_FELIX
      mode_zfgsnomor2 = 'E'
*End insert Unicode conversion - DEVK966003
      mandt           = sy-mandt
      gsber           = fu_gsber
      vbund           = fu_vbund
      spmon           = fu_spmon
*     ztype           = fu_ztype
*     zform           = fu_zform
    EXCEPTIONS
      foreign_lock    = 1
      system_failure  = 2
      OTHERS          = 3.
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
                               fu_zform
                               fu_vbund.
  CALL FUNCTION 'DEQUEUE_EZFGSNOMOR2'
    EXPORTING
* Begin remark unicode coversion - DEVK966054
* 18.03.2020 - sol chirka
**     mode_zfgsnomor        = 'X'
* End remark unicode coversion - DEVK966054
* Begin insert unicode conversion - DEVK966054
* 18.03.2020 - sol chirka
      mode_zfgsnomor2 = 'E'
* End insert unicode conversion - DEVK966054
      mandt           = sy-mandt
      gsber           = fu_gsber
      vbund           = fu_vbund
      spmon           = fu_spmon.
*     ztype                 = fu_ztype
*     zform                 = fu_zform.
ENDFORM.                    " F_UNLOCK_TABLE2

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_TABLE_GSNOMOR
*&---------------------------------------------------------------------*
FORM f_modify_table_gsnomor  USING    fu_gsber
                                      fu_spmon
                                      fu_ztype
                                      fu_zform
                                      fu_gsnomor
                                      fu_vbund.
  CASE gv_zsubtype .
    WHEN '15' OR '57'.
      UPDATE zfgsnomor2 SET nomor5t  = fu_gsnomor
        WHERE gsber EQ fu_gsber AND
              spmon EQ fu_spmon AND
              vbund EQ fu_vbund.
*          ztype EQ fu_ztype AND
*          zform EQ fu_zform.
    WHEN OTHERS.
      UPDATE zfgsnomor2 SET nomor1  = fu_gsnomor
        WHERE gsber EQ fu_gsber AND
              spmon EQ fu_spmon AND
              vbund EQ fu_vbund.
*          ztype EQ fu_ztype AND
*          zform EQ fu_zform.
  ENDCASE.
ENDFORM.                    " F_MODIFY_TABLE_GSNOMOR

*&---------------------------------------------------------------------*
*&      Form  F_GET_FILENAME
*&---------------------------------------------------------------------*
FORM f_get_filename USING fu_filep fu_fieldname.
  DATA: lv_repid LIKE sy-repid.
  lv_repid = sy-repid.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = lv_repid
      dynpro_number = sy-dynnr
      field_name    = fu_fieldname
    IMPORTING
      file_name     = fu_filep
    EXCEPTIONS
      OTHERS        = 1.
  IF sy-subrc <> 0.
    CLEAR fu_filep.
  ENDIF.
ENDFORM.                    " F_GET_FILENAME

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_ZFGSCAB_ADD
*&---------------------------------------------------------------------*
FORM f_update_zfgscab_add  USING    fu_bukrs
                                    fu_gsber
                                    fu_belnr
                                    fu_gjahr
                                    fu_buzei
                                    fu_zgsno.
  DATA: lv_server_file  TYPE localfile.

*  CALL FUNCTION 'ZAB_MOVE_FILE_TO_SERVER'
*    EXPORTING
*      local_file  = pa_filep
*      server_path = gc_path
*    IMPORTING
*      server_file = lv_server_file.
*
*  UPDATE zfgscab_add SET filepusat = lv_server_file
*                     WHERE bukrs = fu_bukrs
*                       AND gsber = fu_gsber
*                       AND belnr = fu_belnr
*                       AND gjahr = fu_gjahr
*                       AND zgsno = fu_zgsno.
ENDFORM.                    " F_UPDATE_ZFGSCAB_ADD

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_PDF
*&---------------------------------------------------------------------*
FORM f_display_pdf  USING    fu_ffield fu_fvalue.
  DATA: lv_path TYPE char20.

  CASE sy-sysid.
    WHEN 'DEV'.
*      lv_path = '\\10.66.0.9'.
      lv_path = '\\10.66.0.64'.            "SOH adj 20240827
    WHEN 'QAS'.
      lv_path = '\\10.66.0.22'.
    WHEN 'P01'.
*      lv_path = '\\10.66.0.14'.
      lv_path = '\\10.66.0.39'.             "SOH Adj 20240820
  ENDCASE.
  CLEAR gt_url.
  REPLACE ALL OCCURRENCES OF '/' IN fu_fvalue WITH '\'.
  CONCATENATE lv_path fu_fvalue INTO gt_url.

**" SOH Adjustment REPLACE 20240820
*  CALL FUNCTION 'CALL_BROWSER'
*    EXPORTING
*      url                    = gt_url
**     BROWSER_TYPE           =
**     CONTEXTSTRING          =
*    EXCEPTIONS
*      frontend_not_supported = 1
*      frontend_error         = 2
*      prog_not_found         = 3
*      no_batch               = 4
*      unspecified_error      = 5
*      OTHERS                 = 6.

*  cl_gui_frontend_services=>execute(
*  EXPORTING
*        document           = 'X'
*        parameter = gt_url
*   EXCEPTIONS
*        cntl_error             = 1
*        error_no_gui           = 2
*        bad_parameter          = 3
*        file_not_found         = 4
*        path_not_found         = 5
*        file_extension_unknown = 6
*        error_execute_failed   = 7
*        synchronous_failed     = 8
*        not_supported_by_gui   = 9
*        OTHERS                 = 10
*  ).


  CALL FUNCTION 'WS_EXECUTE'
    EXPORTING
      document           = 'X'
*     cd                 = ' '
*     commandline        = ' '
*     inform             = ' '
      program            = gt_url
*     STAT               = ' '
*     WINID              = ' '
*     OSMAC_SCRIPT       = ' '
*     OSMAC_CREATOR      = ' '
*     WIN16_EXT          = ' '
*     EXEC_RC            = ' '
*   IMPORTING
*     RBUFF              =
    EXCEPTIONS
      frontend_error     = 1
      no_batch           = 2
      prog_not_found     = 3
      illegal_option     = 4
      gui_refuse_execute = 5
      OTHERS             = 6.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
**" SOH Adjustment REPLACE 20240820
ENDFORM.                    " F_DISPLAY_PDF

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_EXCLUDING
*&---------------------------------------------------------------------*
FORM f_build_excluding.
  IF radio3 = 'X'.
    s_alv_excluding-fcode = '&DOWN'.
    APPEND s_alv_excluding TO t_alv_excluding.
    CLEAR s_alv_excluding.
  ENDIF.
ENDFORM.                    " F_BUILD_EXCLUDING

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_EXCEL
*&---------------------------------------------------------------------*
FORM f_download_excel .
  TYPES lty_truxs_t_text_data(4096) TYPE c.

  DATA: BEGIN OF lt_dwn_field OCCURS 0,
          txt_field(255),
        END OF lt_dwn_field.

  DATA: lt_download01  TYPE TABLE OF zfgsst_download01 WITH HEADER LINE,
        lt_download02  TYPE TABLE OF zfgsst_download02 WITH HEADER LINE,
        lt_downloadcsv TYPE truxs_t_text_data,
        ls_headercsv   TYPE lty_truxs_t_text_data,
        dfies_tab      LIKE dfies OCCURS 0 WITH HEADER LINE,
        lt_excela      LIKE gt_excela OCCURS 0 WITH HEADER LINE,
        lv_file_name   LIKE rlgrap-filename.

  DATA: lv_filedown     TYPE zfiledown,
        ld_filename     TYPE string,
        ld_tabname      TYPE ddobjname,
        ld_filetype(10).

  FIELD-SYMBOLS: <fs_downloadcsv> TYPE lty_truxs_t_text_data.

  lt_excela[] = gt_excela[].
  DELETE lt_excela WHERE check IS INITIAL.
  IF lt_excela[] IS INITIAL.
    MESSAGE 'No data selected' TYPE 'S'.
  ELSE.

    CASE 'X'.
      WHEN radio5.
        ld_tabname = 'ZFGSST_DOWNLOAD01'.
      WHEN radio6.
        ld_tabname = 'ZFGSST_DOWNLOAD02'.
    ENDCASE.

    "Get struture file
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = ld_tabname
      TABLES
        dfies_tab      = dfies_tab
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    IF sy-subrc = 0.
      LOOP AT dfies_tab.
*        lt_dwn_field-txt_field = dfies_tab-fieldtext.
*        APPEND lt_dwn_field. CLEAR lt_dwn_field.

        IF ls_headercsv IS INITIAL.
          ls_headercsv = dfies_tab-fieldtext.
        ELSE.
          CONCATENATE ls_headercsv dfies_tab-fieldtext
            INTO ls_headercsv SEPARATED BY ';'.
        ENDIF.
      ENDLOOP.
    ENDIF.

    "Move data to itab download
    LOOP AT lt_excela.
      CASE 'X'.
        WHEN radio5.
          MOVE-CORRESPONDING lt_excela TO lt_download01.
          APPEND lt_download01.
        WHEN radio6.
          MOVE-CORRESPONDING lt_excela TO lt_download02.
          PERFORM f_split_filename USING lt_download02-filec.
          PERFORM f_split_filename USING lt_download02-filep.
          APPEND lt_download02.
      ENDCASE.
    ENDLOOP.

    "Generated itab CSV
    CASE 'X'.
      WHEN radio5.
        CALL FUNCTION 'SAP_CONVERT_TO_CSV_FORMAT'
          EXPORTING
            i_field_seperator    = ';'
          TABLES
            i_tab_sap_data       = lt_download01
          CHANGING
            i_tab_converted_data = lt_downloadcsv
          EXCEPTIONS
            conversion_failed    = 1
            OTHERS               = 2.
      WHEN radio6.
        CALL FUNCTION 'SAP_CONVERT_TO_CSV_FORMAT'
          EXPORTING
            i_field_seperator    = ';'
          TABLES
            i_tab_sap_data       = lt_download02
          CHANGING
            i_tab_converted_data = lt_downloadcsv
          EXCEPTIONS
            conversion_failed    = 1
            OTHERS               = 2.
    ENDCASE.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    "Insert Header to itab CSV
    INSERT INITIAL LINE INTO lt_downloadcsv INDEX 1 ASSIGNING <fs_downloadcsv>.
    <fs_downloadcsv> = ls_headercsv.

    "Get Filename
    ld_filetype = 'ASC'.
    CONCATENATE sy-datum sy-uzeit INTO ld_filename
      SEPARATED BY '_'.
    CONCATENATE ld_filename '.csv' INTO lv_filedown.
    CASE 'X'.
      WHEN radio5.
        CONCATENATE 'C:\NIS\DN\' ld_filename '.csv' INTO ld_filename.
      WHEN radio6.
        CONCATENATE 'C:\NIS\SUP\' ld_filename '.csv' INTO ld_filename.
    ENDCASE.

    "Download itab to local file
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename         = ld_filename
        filetype         = ld_filetype
*       write_field_separator = 'X'
      TABLES
        data_tab         = lt_downloadcsv
*       fieldnames       = lt_dwn_field
      EXCEPTIONS
        file_write_error = 01
        no_batch         = 04
        unknown_error    = 05
        OTHERS           = 99.

    IF sy-subrc = 0.
      "Update table
      PERFORM f_update_filedown USING lv_filedown.
      MESSAGE 'file downloaded successfully' TYPE 'S'.
      LEAVE TO SCREEN 0.
    ENDIF.

*    lv_file_name = 'C:\NIS\coba.xls'.
*    CALL FUNCTION 'MS_EXCEL_OLE_STANDARD_DAT'
*      EXPORTING
*        file_name                 = lv_file_name
*      TABLES
*        data_tab                  = lt_download01
*        fieldnames                = lt_dwn_field
*      EXCEPTIONS
*        file_not_exist            = 1
*        filename_expected         = 2
*        communication_error       = 3
*        ole_object_method_error   = 4
*        ole_object_property_error = 5
*        invalid_pivot_fields      = 7
*        download_problem          = 8
*        OTHERS                    = 9.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid
*            TYPE sy-msgty
*            NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ELSE.
*      MESSAGE 'file downloaded successfully' TYPE 'S'.
*    ENDIF.
  ENDIF.
ENDFORM.                    " F_DOWNLOAD_EXCEL

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_FILEDOWN
*&---------------------------------------------------------------------*
FORM f_update_filedown  USING    fu_filedown.
  DATA: lt_excela LIKE gt_excela OCCURS 0 WITH HEADER LINE.

  lt_excela[] = gt_excela[].
  DELETE lt_excela WHERE check IS INITIAL.

  SORT lt_excela BY bukrs gsber belnr gjahr zgsno.
  SORT gt_zfgscab_add BY bukrs gsber belnr gjahr zgsno.
  LOOP AT gt_zfgscab_add.
    READ TABLE lt_excela WITH KEY bukrs = gt_zfgscab_add-bukrs
                                  gsber = gt_zfgscab_add-gsber
                                  belnr = gt_zfgscab_add-belnr
                                  gjahr = gt_zfgscab_add-gjahr
                                  zgsno = gt_zfgscab_add-zgsno
                                  BINARY SEARCH.
    IF sy-subrc = 0.
      CASE 'X'.
        WHEN radio5.
          gt_zfgscab_add-filepusat = lt_excela-filep.
          gt_zfgscab_add-filedown = fu_filedown.
          MODIFY gt_zfgscab_add TRANSPORTING filepusat filedown.

        WHEN radio6.
          PERFORM f_move_file_to_final USING gt_zfgscab_add-filecabang.
          PERFORM f_move_file_to_final USING gt_zfgscab_add-filepusat.
          gt_zfgscab_add-filedown2 = fu_filedown.
          MODIFY gt_zfgscab_add TRANSPORTING filedown2.
      ENDCASE.
    ELSE.
      DELETE gt_zfgscab_add.
    ENDIF.
  ENDLOOP.

  MODIFY zfgscab_add FROM TABLE gt_zfgscab_add.
ENDFORM.                    " F_UPDATE_FILEDOWN

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_FILE_TO_FINAL
*&---------------------------------------------------------------------*
FORM f_move_file_to_final  USING fu_file.
  DATA: lv_sourcepath LIKE sapb-sappfad,
        lv_targetpath LIKE sapb-sappfad.

  DATA: lv_serverfname TYPE eseftappl,
        lv_localfname  TYPE string.

  IF fu_file IS NOT INITIAL.
    lv_serverfname = lv_localfname = fu_file.
    PERFORM f_split_filename USING lv_localfname.
    CONCATENATE 'C:\NIS\FINAL\' lv_localfname INTO lv_localfname.

    CALL FUNCTION 'ZSOH_C13Z_FILE_DOWNLOAD_BINARY'              "SOH Adj 20240827
      EXPORTING
        i_file_front_end     = lv_localfname
        i_file_appl          = lv_serverfname
        i_file_overwrite     = 'X'
      EXCEPTIONS
        fe_file_open_error   = 1
        fe_file_exists       = 2
        fe_file_write_error  = 3
        ap_no_authority      = 4
        ap_file_open_error   = 5
        ap_file_empty        = 6
        tcode_not_authorized = 7
        OTHERS               = 8.

    IF sy-subrc EQ 0.
      DELETE DATASET lv_serverfname.
    ENDIF.

*    CALL FUNCTION 'ARCHIVFILE_SERVER_TO_SERVER'
*      EXPORTING
*        sourcepath       = lv_sourcepath
*        targetpath       = lv_targetpath
*      EXCEPTIONS
*        error_file       = 1
*        no_authorization = 2
*        OTHERS           = 3.
*
*    IF sy-subrc EQ 0.
**      DELETE DATASET lv_sourcepath.
*    ENDIF.
  ENDIF.
ENDFORM.                    " F_MOVE_FILE_TO_FINAL

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_FILENAME
*&---------------------------------------------------------------------*
FORM f_split_filename  USING    fu_filec.
* Start adjustment SOH 20240819
*========= replace
**  DATA: lv_docid      TYPE dsvasdocid,
**        lv_directory  TYPE dsvasdocid,
**        lv_filename   TYPE dsvasdocid,
**        lv_extension  TYPE dsvasdocid.
  DATA: lv_docid     TYPE text255,
        lv_directory TYPE text255,
        lv_filename  TYPE text255,
        lv_extension TYPE text255.
* End adjustment SOH 20240819

  lv_docid = fu_filec.
*    CALL FUNCTION 'DSVAS_DOC_FILENAME_SPLIT'             "Rem SOH Adj 20240819
  CALL FUNCTION 'Z_DSVAS_DOC_FILENAME_SPLIT'
    EXPORTING
      pf_docid     = lv_docid
    IMPORTING
      pf_directory = lv_directory
      pf_filename  = lv_filename
      pf_extension = lv_extension.

  fu_filec = lv_filename.
ENDFORM.                    " F_SPLIT_FILENAME

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_LTEXT
*&---------------------------------------------------------------------*
FORM f_change_ltext  CHANGING fu_ltext fc_kuntm.
  DATA : lv_kuntm   TYPE zfgscab_add-kunnr.

  IF gt_post-zsubtype = '21' OR gt_post-zsubtype = '61'.
    CLEAR gt_zfgscab.
    READ TABLE gt_zfgscab WITH KEY bukrs = gt_post-bukrs
                                   belnr = gt_post-belnr
                                   gjahr = gt_post-gjahr.
    SELECT SINGLE actdesc kunnr INTO (fu_ltext, lv_kuntm)
      FROM zfgscab_add WHERE bukrs = gt_zfgscab-bukrs
                         AND gsber = gt_zfgscab-gsber
                         AND belnr = gt_zfgscab-belnr
                         AND gjahr = gt_zfgscab-gjahr
                         AND zgsno = gt_zfgscab-zgsno.

    IF fc_kuntm IS INITIAL.
      SELECT SINGLE name1
        FROM kna1
        INTO gt_head-zdesc
        WHERE kunnr = lv_kuntm.

      gt_head-kuntm = lv_kuntm.

      MODIFY gt_head TRANSPORTING kuntm zdesc.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHANGE_LTEXT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_9007
*&---------------------------------------------------------------------*
FORM f_validate_screen_9007 .
* Start adjustment SOH 20240819
*========= replace
**  DATA: lv_docid      TYPE dsvasdocid,
**        lv_directory  TYPE dsvasdocid,
**        lv_filename   TYPE dsvasdocid,
**        lv_extension  TYPE dsvasdocid.
  DATA: lv_docid     TYPE text255,
        lv_directory TYPE text255,
        lv_filename  TYPE text255,
        lv_extension TYPE text255.
* End adjustment SOH 20240819


  IF pa_filps IS INITIAL.
    PERFORM f_screen_modify USING 'FPS' ''
                                  'File PDF lampiran tidak boleh kosong'.
  ELSE.
    lv_docid = pa_filps.
*    CALL FUNCTION 'DSVAS_DOC_FILENAME_SPLIT'             "Rem SOH Adj 20240819
    CALL FUNCTION 'Z_DSVAS_DOC_FILENAME_SPLIT'
      EXPORTING
        pf_docid     = lv_docid
      IMPORTING
        pf_directory = lv_directory
        pf_filename  = lv_filename
        pf_extension = lv_extension.
    IF lv_extension = 'PDF' OR lv_extension = 'pdf'.
    ELSE.
      PERFORM f_screen_modify USING 'FPS' ''
                                    'File lampiran harus format PDF'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_9007

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_MODIFY
*&---------------------------------------------------------------------*
FORM f_screen_modify  USING    fu_group fu_input fu_mess.
  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
    ELSE.
      screen-input  = fu_input.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH fu_mess.
ENDFORM.                    " F_SCREEN_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_MODIFY
*&---------------------------------------------------------------------*
FORM f_screen_modify2  USING    fu_group fu_input fu_active fu_invisible.
  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input   = fu_input.
      screen-active  = fu_active.
      screen-invisible = fu_invisible.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_SCREEN_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_SPOOL_TO_PDF
*&---------------------------------------------------------------------*
FORM f_convert_spool_to_pdf  USING    fu_spoolids
                             CHANGING fc_filepusat.
  DATA: lv_xref2    TYPE xref2,
        lv_path     TYPE localfile,
        lv_filename TYPE char50.

  CASE sy-sysid.
    WHEN 'DEV'.
*      lv_path = '\\10.66.0.9'.
      lv_path = '\\10.66.0.9'.              "SOH Adj 20240827
    WHEN 'QAS'.
      lv_path = '\\10.66.0.22'.
    WHEN 'P01'.
*      lv_path = '\\10.66.0.14'.
      lv_path = '\\10.66.0.39'.             "SOH Adj 20240820
  ENDCASE.

  READ TABLE gt_head INDEX 1.
  lv_xref2 = gt_head-xref2.
  REPLACE '/' INTO lv_xref2 WITH '_'.
*  CONCATENATE sy-datum sy-uzeit INTO lv_filename
*      SEPARATED BY '_'.
*  CONCATENATE 'NIS' lv_filename '.pdf' INTO lv_filename.
  CONCATENATE lv_xref2 '.pdf' INTO lv_filename.
  CONCATENATE lv_path '\interface3\NIS\KP\' lv_filename INTO lv_path.
  CONCATENATE '/interface3/NIS/KP/' lv_filename INTO fc_filepusat.

  SUBMIT rstxpdft4 WITH spoolno = fu_spoolids
                   WITH p_file  = lv_path
                   AND RETURN.
ENDFORM.                    " F_CONVERT_SPOOL_TO_PDF

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_FILEPUSAT
*&---------------------------------------------------------------------*
FORM f_update_filepusat  USING    fu_filepusat.
  READ TABLE gt_zfgscab INDEX 1.
  UPDATE zfgscab_add SET filepusat = fu_filepusat
                     WHERE bukrs = gt_zfgscab-bukrs
                       AND gsber = gt_zfgscab-gsber
                       AND belnr = gt_zfgscab-belnr
                       AND gjahr = gt_zfgscab-gjahr
                       AND zgsno = gt_zfgscab-zgsno.
ENDFORM.                    " F_UPDATE_FILEPUSAT

*&---------------------------------------------------------------------*
*&      Form  F_GET_PERIOD
*&---------------------------------------------------------------------*
FORM f_get_period  USING    fu_perfr
                            fu_perto
                   CHANGING fc_perfr
                            fc_perto
                            fc_period.
  DATA: lv_perfr(10), lv_perto(10).

  IF fu_perfr IS NOT INITIAL AND fu_perto IS NOT INITIAL.
    fc_perfr = fu_perfr.
    fc_perto = fu_perto.

    WRITE: fu_perfr TO lv_perfr,
           fu_perto TO lv_perto.
    CONCATENATE lv_perfr lv_perto INTO fc_period SEPARATED BY ' - '.
  ENDIF.
ENDFORM.                    " F_GET_PERIOD

*&---------------------------------------------------------------------*
*&      Form  F_GET_F4
*&---------------------------------------------------------------------*
FORM f_get_f4  USING    fu_field.
  TYPES : BEGIN OF ty_cust,
            kunnr TYPE kna1-kunnr,
          END OF ty_cust.

  DATA : lt_cust     TYPE STANDARD TABLE OF ty_cust,
         ls_cust     LIKE LINE OF lt_cust,
         ls_customer LIKE LINE OF gt_customer,
         return_tab  TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return   LIKE LINE OF return_tab.

  LOOP AT gt_customer INTO ls_customer.
    ls_cust-kunnr = ls_customer-kunnr.
    APPEND ls_cust TO lt_cust.
    CLEAR ls_cust.
  ENDLOOP.

  SORT lt_cust BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_cust COMPARING kunnr.

  ASSIGN lt_cust[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'KUNNR' fu_field
                          CHANGING lv_subrc.
ENDFORM.

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
ENDFORM.

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
