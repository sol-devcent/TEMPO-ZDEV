*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.

  DATA: ld_mth   TYPE i,
        ld_start LIKE sy-datum,
        ld_low   LIKE sy-datum,
        ld_high  LIKE sy-datum,
        ld_month(2),
        ld_len   TYPE i.

  SELECT SINGLE b~name2 b~street
    FROM t001w AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
    INTO (va_name2, va_street)
    WHERE a~werks EQ pa_werks.

**Get user defaults
  CLEAR: t_user, t_user[].
  t_user-bname = sy-uname.
  APPEND t_user.
  CALL FUNCTION 'SUSR_GET_USER_DEFAULTS'
    EXPORTING
      langu = sy-langu
    TABLES
      users = t_user.
  IF sy-subrc <> 0.
  ENDIF.

**Check period
  ld_mth = so_spmon-high - so_spmon-low.
  IF ld_mth > 5.
    MESSAGE i000(zab)
            WITH 'Please select maximum 6 months in one process'.
    STOP.
  ENDIF.

**Fill period
  REFRESH ra_period.
  CLEAR ra_period.
  ra_period-sign = 'I'.
  ra_period-option = 'BT'.
  CONCATENATE so_spmon-low '01' INTO ra_period-low.
  IF so_spmon-high IS INITIAL.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = ra_period-low
      IMPORTING
        last_day_of_month = ra_period-high.
  ELSE.
    CONCATENATE so_spmon-high '01' INTO ld_start.
    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = ld_start
      IMPORTING
        last_day_of_month = ra_period-high.
  ENDIF.
  APPEND ra_period.

  CONCATENATE so_spmon-low '01' INTO ld_low.
  IF so_spmon-high+4(2) EQ '06'.
    CONCATENATE so_spmon-high '30' INTO ld_high.
  ELSEIF so_spmon-high+4(2) EQ '12'.
    CONCATENATE so_spmon-high '31' INTO ld_high.
  ENDIF.

  ra_datum-low    = ld_low.
  ra_datum-high   = ld_high.
  ra_datum-option = 'BT'.
  ra_datum-sign   = 'I'.
  APPEND ra_datum.

  CASE so_spmon-low+4(2).
    WHEN '01'.
      CLEAR: ld_month.
      DO 6 TIMES.
        ADD 1 TO ld_month.
        CONCATENATE so_spmon-low(4) '0' ld_month INTO t_period.
        APPEND t_period.
      ENDDO.
    WHEN '07'.
      ld_month = 6.
      DO 6 TIMES.
        ADD 1 TO ld_month.
        ld_len = STRLEN( ld_month ).
        IF ld_len EQ 1.
          CONCATENATE so_spmon-low(4) '0' ld_month INTO t_period.
          APPEND t_period.
        ELSE.
          CONCATENATE so_spmon-low(4) ld_month INTO t_period.
          APPEND t_period.
        ENDIF.
      ENDDO.
  ENDCASE.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
*-select material ==> only material type = 'ZPHA'
  SELECT mara~matnr meins mtart
    FROM mara JOIN marc ON mara~matnr EQ marc~matnr
    INTO CORRESPONDING FIELDS OF TABLE t_mara
    WHERE mara~matnr IN so_matnr AND
          mtart      EQ pa_mtart AND
          werks      EQ pa_werks.
  SORT t_mara BY matnr.

  IF NOT t_mara[] IS  INITIAL.
    SELECT matnr maktx
      FROM makt
      INTO TABLE t_makt
      FOR ALL ENTRIES IN t_mara
      WHERE matnr EQ t_mara-matnr AND
            spras EQ sy-langu.
    SORT t_makt BY matnr.
  ENDIF.

  LOOP AT t_mara.
    ra_matnr-low    = t_mara-matnr.
    ra_matnr-option = 'EQ'.
    ra_matnr-sign   = 'I'.
    APPEND ra_matnr.
  ENDLOOP.

*-- Begin Select PO Qty for PO Coloumn
  SELECT ebeln
    FROM ekko
    INTO CORRESPONDING FIELDS OF TABLE t_ekko
    WHERE bukrs EQ '8020' AND
          bsart EQ 'ZB'   AND
          reswk EQ pa_werks.

  IF NOT t_ekko[] IS INITIAL.
    SELECT ebeln ebelp matnr umrez
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE t_ekpo
      FOR ALL ENTRIES IN t_ekko
      WHERE ebeln EQ t_ekko-ebeln AND
            matnr IN ra_matnr     AND
            loekz EQ space.

    IF NOT t_ekpo[] IS INITIAL.
      SELECT ebeln ebelp eindt menge wamng
        FROM eket
        INTO CORRESPONDING FIELDS OF TABLE t_eket
        FOR ALL ENTRIES IN t_ekpo
        WHERE ebeln EQ t_ekpo-ebeln AND
              ebelp EQ t_ekpo-ebelp AND
              eindt IN ra_datum.

      SORT t_ekpo BY ebeln ebelp.
      SORT t_eket BY ebeln ebelp.
      IF NOT t_eket[] IS INITIAL.

        SELECT ebeln ebelp belnr buzei budat shkzg menge
          FROM ekbe
          INTO CORRESPONDING FIELDS OF TABLE t_ekbe
          FOR ALL ENTRIES IN t_eket
          WHERE ebeln EQ t_eket-ebeln AND
                ebelp EQ t_eket-ebelp AND
                bwart NE space        AND
                bewtp EQ 'U'.

        SORT t_ekbe BY ebeln ebelp.
        LOOP AT t_ekbe.
          IF t_ekbe-shkzg EQ 'H'.
            t_ekbe-menge = t_ekbe-menge * -1.
          ENDIF.
          READ TABLE t_eket WITH KEY ebeln = t_ekbe-ebeln
                                     ebelp = t_ekbe-ebelp.
          IF sy-subrc EQ 0.
            IF t_ekbe-budat(6) NE t_eket-eindt(6).
              DELETE t_ekbe.
            ELSE.
              t_ekbesum-ebeln = t_ekbe-ebeln.
              t_ekbesum-ebelp = t_ekbe-ebelp.
              t_ekbesum-perio = t_ekbe-budat(6).
              t_ekbesum-menge = t_ekbe-menge.
              COLLECT t_ekbesum.
            ENDIF.
          ENDIF.
        ENDLOOP.

        SORT t_ekbesum BY ebeln ebelp.
        LOOP AT t_eket.
          READ TABLE t_ekpo WITH KEY ebeln = t_eket-ebeln
                                     ebelp = t_eket-ebelp
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            t_po-ebeln = t_ekpo-ebeln.
            t_po-ebelp = t_ekpo-ebelp.
            t_po-eindt = t_eket-eindt.
            t_po-perio = t_eket-eindt(6).
            t_po-matnr = t_ekpo-matnr.
            t_po-menge = t_eket-menge * t_ekpo-umrez.
          ENDIF.

          READ TABLE t_ekbesum WITH KEY ebeln = t_eket-ebeln
                                        ebelp = t_eket-ebelp
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            t_po-menge1 = t_ekbesum-menge.
          ENDIF.
          APPEND t_po.
          CLEAR: t_po.
        ENDLOOP.
      ENDIF.

      IF NOT t_po[] IS INITIAL.
        SORT t_po BY matnr eindt.
        LOOP AT t_po.
          t_posum-matnr = t_po-matnr.
          CASE t_po-perio+4(2).
            WHEN '01' OR '07'.
              t_posum-menge01 = t_po-menge.
              t_posum-menge11 = t_po-menge1.
            WHEN '02' OR '08'.
              t_posum-menge02 = t_po-menge.
              t_posum-menge12 = t_po-menge1.
            WHEN '03' OR '09'.
              t_posum-menge03 = t_po-menge.
              t_posum-menge13 = t_po-menge1.
            WHEN '04' OR '10'.
              t_posum-menge04 = t_po-menge.
              t_posum-menge14 = t_po-menge1.
            WHEN '05' OR '11'.
              t_posum-menge05 = t_po-menge.
              t_posum-menge15 = t_po-menge1.
            WHEN '06' OR '12'.
              t_posum-menge06 = t_po-menge.
              t_posum-menge16 = t_po-menge1.
          ENDCASE.
          COLLECT t_posum.
          CLEAR: t_posum.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
*-- End select PO Qty for PO Coloumn

*-- Begin Select SO Qty for PO Coloumn
  SELECT vbeln
    FROM vbak
    INTO CORRESPONDING FIELDS OF TABLE t_vbak
    WHERE vbtyp EQ 'C' AND
          vkbur EQ pa_werks.

  IF NOT t_vbak[] IS INITIAL.
    SELECT vbeln posnr matnr umziz
      FROM vbap
      INTO CORRESPONDING FIELDS OF TABLE t_vbap
      FOR ALL ENTRIES IN t_vbak
      WHERE vbeln EQ t_vbak-vbeln AND
            matnr IN ra_matnr     AND
            abgru EQ space.

    IF NOT t_vbak[] IS INITIAL.
      SELECT vbeln posnr edatu bmeng
        FROM vbep
        INTO CORRESPONDING FIELDS OF TABLE t_vbep
        FOR ALL ENTRIES IN t_vbap
        WHERE vbeln EQ t_vbap-vbeln AND
              posnr EQ t_vbap-posnr AND
              edatu IN ra_datum.

      SORT t_vbap BY vbeln posnr.
      SORT t_vbep BY vbeln posnr.
      IF NOT t_vbep[] IS INITIAL.

        SELECT vbelv posnv vbeln posnn erdat vbtyp_n rfmng
          FROM vbfa
          INTO CORRESPONDING FIELDS OF TABLE t_vbfa
          FOR ALL ENTRIES IN t_vbep
          WHERE vbelv EQ t_vbep-vbeln AND
                posnv EQ t_vbep-posnr AND
                vbtyp_n IN ('R','h')  AND
                bwart NE space.

        SORT t_vbfa BY vbelv posnv.
        LOOP AT t_vbfa.
          READ TABLE t_vbep WITH KEY vbeln = t_vbfa-vbelv
                                     posnr = t_vbfa-posnv.
          IF t_vbfa-vbtyp_n EQ 'h'.
            t_vbfa-rfmng = t_vbfa-rfmng * -1.
          ENDIF.

          IF sy-subrc EQ 0.
            IF t_vbfa-erdat(6) NE t_vbep-edatu(6).
              DELETE t_vbfa.
            ELSE.
              t_vbfasum-vbelv = t_vbfa-vbelv.
              t_vbfasum-posnv = t_vbfa-posnv.
              t_vbfasum-perio = t_vbfa-erdat(6).
              t_vbfasum-rfmng = t_vbfa-rfmng.
              COLLECT t_vbfasum.
            ENDIF.
          ENDIF.
        ENDLOOP.

        SORT t_vbfasum BY vbelv posnv.
        LOOP AT t_vbep.
          READ TABLE t_vbap WITH KEY vbeln = t_vbep-vbeln
                                     posnr = t_vbep-posnr
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            t_so-vbeln = t_vbap-vbeln.
            t_so-posnr = t_vbap-posnr.
            t_so-edatu = t_vbep-edatu.
            t_so-perio = t_vbep-edatu(6).
            t_so-matnr = t_vbap-matnr.
            t_so-bmeng = t_vbep-bmeng * t_vbap-umziz.
          ENDIF.

          READ TABLE t_vbfasum WITH KEY vbelv = t_vbep-vbeln
                                        posnv = t_vbep-posnr
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            t_so-rfmng = t_vbfasum-rfmng.
          ENDIF.

          APPEND t_so.
          CLEAR: t_so.
        ENDLOOP.
      ENDIF.
      IF NOT t_so[] IS INITIAL.
        SORT t_so BY matnr edatu.
        LOOP AT t_so.
          t_sosum-matnr = t_so-matnr.
          CASE t_so-perio+4(2).
            WHEN '01' OR '07'.
              t_sosum-bmeng01 = t_so-bmeng.
              t_sosum-rfmng01 = t_so-rfmng.
            WHEN '02' OR '08'.
              t_sosum-bmeng02 = t_so-bmeng.
              t_sosum-rfmng02 = t_so-rfmng.
            WHEN '03' OR '09'.
              t_sosum-bmeng03 = t_so-bmeng.
              t_sosum-rfmng03 = t_so-rfmng.
            WHEN '04' OR '10'.
              t_sosum-bmeng04 = t_so-bmeng.
              t_sosum-rfmng04 = t_so-rfmng.
            WHEN '05' OR '11'.
              t_sosum-bmeng05 = t_so-bmeng.
              t_sosum-rfmng05 = t_so-rfmng.
            WHEN '06' OR '12'.
              t_sosum-bmeng06 = t_so-bmeng.
              t_sosum-rfmng06 = t_so-rfmng.
          ENDCASE.
          COLLECT t_sosum.
          CLEAR: t_sosum.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
*-- End Select SO Qty for PO Coloumn

*-- Begin ROFO
  SELECT period matnr werks kunnr podist
    FROM zgdppdt0004
    INTO TABLE gt_zgdppdt0004
    WHERE period IN so_spmon AND
          matnr  IN so_matnr AND
          werks  EQ pa_werks.

ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.

  PERFORM f_alv TABLES t_result.

ENDFORM.                    "f_print_data

*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout     USING   d_layout.
  PERFORM f_build_sortfield  USING   t_alv_isort[].
  PERFORM f_build_event      TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print      USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
*   I_INTERFACE_CHECK              = ' '
*   I_BYPASSING_BUFFER             =
*   I_BUFFER_ACTIVE                = ' '
    i_callback_program             = d_repid
    i_callback_pf_status_set       = 'F_SET_PF_STATUS'
    i_callback_user_command        = 'F_USER_COMMAND'
*   I_STRUCTURE_NAME               =
    is_layout                      = d_layout
    it_fieldcat                    = t_alv_fieldcat[]
*   IT_EXCLUDING                   =
*   IT_SPECIAL_GROUPS              =
    it_sort                        = t_alv_isort[]
*   IT_FILTER                      =
*   IS_SEL_HIDE                    =
    i_default                      = 'X'
    i_save                         = 'A'
    is_variant                     = d_alv_variant
    it_events                      = t_alv_event[]
    it_event_exit                  = t_event_exit[]
    is_print                       = d_print
*   IS_REPREP_ID                   =
*   I_SCREEN_START_COLUMN          = 0
*   I_SCREEN_START_LINE            = 0
*   I_SCREEN_END_COLUMN            = 0
*   I_SCREEN_END_LINE              = 0
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER        =
*   ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab                       = ft_report
   EXCEPTIONS
     program_error                  = 1
     OTHERS                         = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    "f_alv

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
  DATA: ld_jdl1(30),
        ld_jdl2(30),
        ld_jdl3(30),
        ld_jdl4(30),
        ld_ktx LIKE t247-ktx.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
    'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '',
    'MEINS' 'MSEG' 'MEINS' '' '' '' '' '' '' '' '' '' '' ''.
  DEFINE mac_header.
    read table t_period index &1.
    if sy-subrc eq 0 and not t_period is initial.
      select single ktx
        from t247
        into ld_ktx
        where mnr   eq t_period+4(2) and
              spras eq sy-langu.
      concatenate 'ROFO' ld_ktx t_period(4) into ld_jdl4
         separated by space.
      concatenate 'PO' ld_ktx t_period(4) into ld_jdl1
         separated by space.
      concatenate 'Sup/Ex-Fact' ld_ktx t_period(4) into ld_jdl2
         separated by space.
      concatenate '%' ld_ktx t_period(4) into ld_jdl3
         separated by space.
      perform f_fieldcatg using ft_report:
     'ROFO0&1' 'ZGDPPDT0004' 'PODIST' '' '' ld_jdl4 '' '' '' '' '' '' 'MEINS' '',
     'PO0&1' 'EKET' 'MENGE' '' '' ld_jdl1 '' '' '' '' '' '' 'MEINS' '',
     'SUPPLY0&1' '' '' '' '20' ld_jdl2 '' '' '' '' '' '' 'MEINS' '',
     'PERSEN0&1' 'AFRV' 'HRAZL' '' '' ld_jdl3 '' '' '' '' '' '' '' ''.
    endif.
  END-OF-DEFINITION.
  mac_header : 1, 2, 3, 4, 5, 6.

  PERFORM f_fieldcatg USING ft_report:
     'TOT_PO' 'EKET' 'MENGE' '' '' 'YTD PO' '' '' '' '' '' ''
     'MEINS' '',
     'TOT_SUPPLY' '' '' '' '20' 'YTD Supply/Ex-Fact' '' '' '' '' '' ''
     'MEINS' '',
     'TOT_PERSEN' 'AFRV' 'HRAZL' '' '' 'YTD %' '' '' '' '' '' '' '' ''.

ENDFORM.                    " F_FIELDCAT


*---------------------------------------------------------------------*
*       FORM f_fieldcats                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_FNAME                                                      *
*  -->  FU_OUTLEN                                                     *
*  -->  FU_NOSIGN                                                     *
*  -->  FU_NOOUT                                                      *
*  -->  FU_TEXT                                                       *
*  -->  FU_REFTB                                                      *
*  -->  FU_REFFNAME                                                   *
*  -->  FU_DECIMALS                                                   *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
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
                          value(fu_checkbox).

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
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.

ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_event                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.

  CLEAR ft_events.
  ft_events-name = slis_ev_end_of_list.
  ft_events-form = 'F_END_OF_LIST'.
  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_page.
*  ft_events-form = 'F_END_OF_PAGE'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_before_line_output.
*  ft_events-form = 'F_BEFORE_LINE_OUTPUT'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_after_line_output.
*  ft_events-form = 'F_AFTER_LINE_OUTPUT'.
*  APPEND ft_events.
*
*  CLEAR ft_events.
*  ft_events-name = slis_ev_subtotal_text.
*  ft_events-form = 'F_SUBTOTAL'.
*  APPEND ft_events.
ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
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

ENDFORM.                    "f_build_event_exit

*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
* fu_layout-f2code             = '&ETA'.
* fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos = 'X'.
  fu_print-no_print_selinfos  = 'X'.
  fu_print-no_coverpage       = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'WERKS'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.
*  CLEAR ld_sort.
*  ld_sort-fieldname = 'VERSB'.
*  ld_sort-up        = 'X'.
*  APPEND ld_sort TO fu_sort.
ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.
  DATA ld_per   LIKE sy-title.
  DATA ld_from  LIKE sy-title.
  DATA ld_to    LIKE sy-title.
  DATA ld_ktx   LIKE t247-ktx.
  DATA ld_werks LIKE sy-title.

* Title
  CONCATENATE sy-title so_spmon-low(4) INTO ld_werks
  SEPARATED BY space.

* Plant


* Semester
  IF so_spmon-low+4(2) EQ '01'.
    ld_per = '(SMT - I)'.
  ELSEIF so_spmon-low+4(2) EQ '07'.
    ld_per = '(SMT - II)'.
  ENDIF.


*** For ALV LIST
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1x USING ld_werks.
  PERFORM f_hdr_line2x USING ld_per.
  PERFORM f_hdr_line3x USING ''.
  PERFORM f_hdr_uline.
ENDFORM.                    "f_top_of_page

*---------------------------------------------------------------------*
*       FORM F_END_OF_LIST                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_end_of_list.
  LOOP AT t_text.
    WRITE: / t_text-line.
  ENDLOOP.
ENDFORM.                    "f_end_of_list

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.

* here free all the internal table used in the program.

ENDFORM.                    " F_FREE_MEMORY
*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
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
ENDFORM.                    " f_clear_alv_data



*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.

  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.

ENDFORM.                    " F_SET_PF_STATUS


*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "f_gui_message


*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.
  DATA: lv_count        TYPE i,
        lt_zgdppdt0004  LIKE gt_zgdppdt0004 OCCURS 0 WITH HEADER LINE,
        lv_period       TYPE spmon,
        lv_datum        TYPE sy-datum.

  SORT t_mara BY matnr.
  SORT t_makt BY matnr.
  SORT t_posum BY matnr.
  SORT t_sosum BY matnr.
  SORT gt_zgdppdt0004 BY period matnr werks.

  LOOP AT gt_zgdppdt0004.
    lt_zgdppdt0004-period  = gt_zgdppdt0004-period.
    lt_zgdppdt0004-matnr   = gt_zgdppdt0004-matnr.
    lt_zgdppdt0004-werks   = gt_zgdppdt0004-werks.
    lt_zgdppdt0004-podist  = gt_zgdppdt0004-podist.
    COLLECT lt_zgdppdt0004.
  ENDLOOP.

  LOOP AT t_mara.
    READ TABLE t_makt WITH KEY matnr = t_mara-matnr
      BINARY SEARCH.
    IF sy-subrc EQ 0.
      t_result-matnr = t_makt-matnr.
      t_result-maktx = t_makt-maktx.
      t_result-meins = t_mara-meins.
    ENDIF.

    CLEAR: lv_count.
    DO 6 TIMES.
      ADD 1 TO lv_count.
      IF lv_count EQ 1.
        lv_period = so_spmon-low.
      ELSE.
        CONCATENATE lv_period '01' INTO lv_datum.
        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
          EXPORTING
            day_in            = lv_datum
          IMPORTING
            last_day_of_month = lv_datum.
        lv_datum = lv_datum + 1.
        lv_period = lv_datum(6).
      ENDIF.
      LOOP AT lt_zgdppdt0004 WHERE matnr  EQ t_mara-matnr AND
                                   period EQ lv_period.
        CASE lv_count.
          WHEN 1.
            t_result-rofo01 = lt_zgdppdt0004-podist.
          WHEN 2.
            t_result-rofo02 = lt_zgdppdt0004-podist.
          WHEN 3.
            t_result-rofo03 = lt_zgdppdt0004-podist.
          WHEN 4.
            t_result-rofo04 = lt_zgdppdt0004-podist.
          WHEN 5.
            t_result-rofo05 = lt_zgdppdt0004-podist.
          WHEN 6.
            t_result-rofo06 = lt_zgdppdt0004-podist.
        ENDCASE.
      ENDLOOP.
    ENDDO.

    READ TABLE t_posum WITH KEY matnr = t_mara-matnr
      BINARY SEARCH.
    IF sy-subrc EQ 0.
      t_result-po01 = t_result-po01 + t_posum-menge01.
      t_result-po02 = t_result-po02 + t_posum-menge02.
      t_result-po03 = t_result-po03 + t_posum-menge03.
      t_result-po04 = t_result-po04 + t_posum-menge04.
      t_result-po05 = t_result-po05 + t_posum-menge05.
      t_result-po06 = t_result-po06 + t_posum-menge06.

      t_result-supply01 = t_result-supply01 + ABS( t_posum-menge11 ).
      t_result-supply02 = t_result-supply02 + ABS( t_posum-menge12 ).
      t_result-supply03 = t_result-supply03 + ABS( t_posum-menge13 ).
      t_result-supply04 = t_result-supply04 + ABS( t_posum-menge14 ).
      t_result-supply05 = t_result-supply05 + ABS( t_posum-menge15 ).
      t_result-supply06 = t_result-supply06 + ABS( t_posum-menge16 ).
    ENDIF.

    READ TABLE t_sosum WITH KEY matnr = t_mara-matnr
      BINARY SEARCH.
    IF sy-subrc EQ 0.
      t_result-po01 = t_result-po01 + t_sosum-bmeng01.
      t_result-po02 = t_result-po02 + t_sosum-bmeng02.
      t_result-po03 = t_result-po03 + t_sosum-bmeng03.
      t_result-po04 = t_result-po04 + t_sosum-bmeng04.
      t_result-po05 = t_result-po05 + t_sosum-bmeng05.
      t_result-po06 = t_result-po06 + t_sosum-bmeng06.

      t_result-supply01 = t_result-supply01 + t_sosum-rfmng01.
      t_result-supply02 = t_result-supply02 + t_sosum-rfmng02.
      t_result-supply03 = t_result-supply03 + t_sosum-rfmng03.
      t_result-supply04 = t_result-supply04 + t_sosum-rfmng04.
      t_result-supply05 = t_result-supply05 + t_sosum-rfmng05.
      t_result-supply06 = t_result-supply06 + t_sosum-rfmng06.
    ENDIF.

    t_result-persen01 = t_result-supply01 / t_result-po01 * 100.
    t_result-persen02 = t_result-supply02 / t_result-po02 * 100.
    t_result-persen03 = t_result-supply03 / t_result-po03 * 100.
    t_result-persen04 = t_result-supply04 / t_result-po04 * 100.
    t_result-persen05 = t_result-supply05 / t_result-po05 * 100.
    t_result-persen06 = t_result-supply06 / t_result-po06 * 100.

    t_result-tot_po = t_result-po01 + t_result-po02 + t_result-po03 +
                      t_result-po04 + t_result-po05 + t_result-po06.

    t_result-tot_supply = t_result-supply01 + t_result-supply02 +
                          t_result-supply03 + t_result-supply04 +
                          t_result-supply05 + t_result-supply06.

    t_result-tot_persen = t_result-tot_supply / t_result-tot_po * 100.
    COLLECT t_result.
    CLEAR: t_result.
  ENDLOOP.

  DELETE t_result WHERE tot_po EQ 0 AND
                        tot_supply EQ 0.
ENDFORM.                    " f_validate_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.
  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.
  ENDCASE.

ENDFORM.                    "f_user_command

*&---------------------------------------------------------------------*
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_entries.

ENDFORM.                    " f_post_entries

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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

*data: gs_lineinfo type kkblo_lineinfo.
FORM f_after_line_output USING lineinfo TYPE slis_lineinfo.
  BREAK-POINT.
ENDFORM.                    "f_after_line_output

*&---------------------------------------------------------------------*
*&      Form  f_popup_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_popup_text.
  CALL FUNCTION 'ZTXW_TEXTNOTE_EDIT'
    EXPORTING
      edit_mode = 'X'
    TABLES
      t_txwnote = t_text.
ENDFORM.                    " f_popup_text

*&---------------------------------------------------------------------*
*&      Form  f_hdr_line1x
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_TITLE  text
*----------------------------------------------------------------------*
FORM f_hdr_line1x USING fu_company.
  DATA:
    page_number(10) VALUE 'Page: nnnn',
    progname(42),
    ld_progname(20),
    page(4).

*--- Page number
  page = sy-pagno.
  REPLACE 'nnnn' WITH page INTO page_number.

*--- Output line
  PERFORM f_hdr_pad_title USING va_name2 fu_company page_number.
ENDFORM.                    " f_hdr_line1x

*&---------------------------------------------------------------------*
*&      Form  f_hdr_line2x
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_PER  text
*----------------------------------------------------------------------*
FORM f_hdr_line2x USING fu_company.
  DATA:
    ld_datum(10).

*--- date
  WRITE sy-datum TO ld_datum.

*--- Output line
  PERFORM f_hdr_pad_title USING va_street fu_company ld_datum.
ENDFORM.                    " f_hdr_line2x

*&---------------------------------------------------------------------*
*&      Form  f_hdr_line3x
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_PER  text
*----------------------------------------------------------------------*
FORM f_hdr_line3x USING fu_company.
  DATA:
    progname(42),
    ld_uzeit(5) VALUE 'hh:mm',
    ld_uname(21) VALUE 'User:    xx'.

*--- time
  REPLACE 'hh' WITH sy-uzeit(2) INTO ld_uzeit.     " hour
  REPLACE 'mm' WITH sy-uzeit+2(2) INTO ld_uzeit.   " minute

  progname = 'FINISHED GOODS'.

*--- Output line
  PERFORM f_hdr_pad_title USING progname fu_company ld_uzeit.
ENDFORM.                    " f_hdr_line3x
