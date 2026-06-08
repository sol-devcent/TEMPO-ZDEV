*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.

  SELECT SINGLE b~name2 b~street
    FROM t001w AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
    INTO (va_name2, va_street)
    WHERE a~werks EQ p_werks.

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

  ra_lgort-low    = '3000'.
  ra_lgort-high   = '3002'.
  ra_lgort-sign   = 'I'.
  ra_lgort-option = 'BT'.
  APPEND ra_lgort.
  ra_lgort-low    = '3099'.
  ra_lgort-sign   = 'I'.
  ra_lgort-option = 'EQ'.
  APPEND ra_lgort.
  ra_lgort-low    = '30U0'.
  ra_lgort-sign   = 'I'.
  ra_lgort-option = 'EQ'.
  APPEND ra_lgort.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.

  DATA: BEGIN OF lt_s933 OCCURS 0,
          spmon LIKE s933-spmon,
          werks LIKE s933-werks,
          matnr LIKE s933-matnr,
          bwart LIKE s933-bwart,
          charg LIKE s933-charg,
          mblnr LIKE s933-mblnr,
          budat LIKE s933-budat,
          lgort LIKE s933-lgort,
          menge LIKE s933-menge,
        END OF lt_s933.

  DATA: BEGIN OF lt_s933_30u0 OCCURS 0.
          INCLUDE STRUCTURE lt_s933.
  DATA: END OF lt_s933_30u0.

* select material ==> only material type = 'ZPHA'
  SELECT mara~matnr meins mtart
         INTO CORRESPONDING FIELDS OF TABLE t_mara
         FROM mara JOIN marc ON mara~matnr = marc~matnr
         WHERE mara~matnr IN s_matnr AND
               mtart = p_mtart AND
               werks = p_werks.
  SORT t_mara BY matnr.

  IF NOT t_mara[] IS  INITIAL.
    SELECT matnr maktx
           INTO TABLE t_makt
           FROM makt
           FOR ALL ENTRIES IN t_mara
           WHERE matnr = t_mara-matnr AND
                 spras = sy-langu.
    SORT t_makt BY matnr.

    SELECT spmon werks matnr bwart charg mblnr budat lgort menge
           INTO CORRESPONDING FIELDS OF TABLE lt_s933
           FROM s933
           FOR ALL ENTRIES IN t_mara
           WHERE spmon IN s_spmon AND
                 werks = p_werks AND
                 matnr = t_mara-matnr AND
                 bwart IN s_bwart AND
                 lgort IN ra_lgort.
    IF sy-subrc = 0.
      LOOP AT lt_s933.
        IF lt_s933-lgort EQ '30U0' AND
          lt_s933-bwart NE '343' AND
          lt_s933-bwart NE '344'.
          lt_s933_30u0 = lt_s933.
          APPEND lt_s933_30u0.
        ENDIF.
      ENDLOOP.

      SORT lt_s933 BY spmon matnr charg mblnr.
      SORT lt_s933_30u0 BY spmon matnr charg mblnr.
      LOOP AT lt_s933.
        READ TABLE lt_s933_30u0 WITH KEY spmon = lt_s933-spmon
                                      matnr = lt_s933-matnr
                                      charg = lt_s933-charg
                                      mblnr = lt_s933-mblnr
        BINARY SEARCH.
        IF sy-subrc EQ 0.
          DELETE lt_s933 WHERE spmon EQ lt_s933_30u0-spmon AND
                               matnr EQ lt_s933_30u0-matnr AND
                               charg EQ lt_s933_30u0-charg AND
                               mblnr EQ lt_s933_30u0-mblnr.
        ENDIF.
      ENDLOOP.

      SORT lt_s933 BY matnr spmon bwart.
      LOOP AT lt_s933.
        MOVE-CORRESPONDING lt_s933 TO t_s933_sum.
        IF lt_s933-bwart EQ '343' OR
          lt_s933-bwart EQ '344'.
          t_s933_sum-menge = lt_s933-menge * -1.
        ENDIF.
        COLLECT t_s933_sum.
      ENDLOOP.
      DELETE t_s933_sum WHERE menge < 0.
    ENDIF.
  ENDIF.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.

  PERFORM f_alv TABLES t_result.

ENDFORM.


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
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*   I_INTERFACE_CHECK              = ' '
*   I_BYPASSING_BUFFER             =
*   I_BUFFER_ACTIVE                = ' '
    i_callback_program             = d_repid
    i_callback_pf_status_set       = 'F_SET_PF_STATUS'
    i_callback_user_command        = 'F_USER_COMMAND'
*   I_STRUCTURE_NAME               =
*    i_background_id                = 'ALV_BACKGROUND'
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
ENDFORM.


*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.
*HEADALV
  DATA: ld_jdl(30).
  REFRESH: t_alv_fieldcat.
  PERFORM f_fieldcatg USING ft_report:
    'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '',
    'MEINS' 'MARA' 'MEINS'  '' '' 'UoM' '' '' '' '' '' '' '' ''.

  DEFINE mac_header.
    read table t_period index &1.
    if sy-subrc eq 0 and not t_period is initial.
      select single * from t247
       where mnr = t_period+4(2)
       and   spras = sy-langu.
      concatenate t247-ktx t_period(4) into ld_jdl
         separated by space.
      perform f_fieldcatg using ft_report:
     'PER&1' 'S933' 'MENGE' '' '' ld_jdl '' '' '' '' '' '' 'MEINS' ''.
    endif.
  END-OF-DEFINITION.
  mac_header : 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12.
  PERFORM f_fieldcatg USING ft_report:
   'TOTAL' 'S933' 'MENGE' '' '' 'Total' '' '' '' '' '' '' 'MEINS' ''.

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
  ld_fieldcat-tabname       = fu_types.
  ld_fieldcat-fieldname     = fu_fname.
  ld_fieldcat-ref_tabname   = fu_reftb.
  ld_fieldcat-ref_fieldname = fu_refld.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-outputlen     = fu_outln.
  ld_fieldcat-seltext_l     = fu_fltxt.
  ld_fieldcat-seltext_m     = fu_fltxt.
  ld_fieldcat-seltext_s     = fu_fltxt.
  ld_fieldcat-reptext_ddic  = fu_fltxt.
  ld_fieldcat-no_out        = fu_noout.
  ld_fieldcat-do_sum        = fu_dosum.
  ld_fieldcat-hotspot       = fu_hotsp.
  ld_fieldcat-decimals_out  = fu_dec.
  ld_fieldcat-currency    = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
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





ENDFORM.

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

ENDFORM.


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

ENDFORM.


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
ENDFORM.


*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
*  DATA: ld_sort TYPE slis_sortinfo_alv.
*
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

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE1X
*&---------------------------------------------------------------------*
*       Header line with report, title and page
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
*  IF sy-cprog EQ sy-repid.
*    REPLACE 'xx' WITH sy-repid INTO progname.
*  ELSE.
*    CONCATENATE sy-repid '(' sy-cprog ')' INTO ld_progname.
*    REPLACE 'xx' WITH ld_progname INTO progname.
*  ENDIF.

*--- Output line
  PERFORM f_hdr_pad_title USING va_name2 fu_company page_number.
ENDFORM.                    " F_HDR_LINE1X

*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE2X
*&---------------------------------------------------------------------*
*       Header line with report, title and page
*----------------------------------------------------------------------*
FORM f_hdr_line2x USING fu_company.
  DATA:
  ld_datum(10).

*--- date
  WRITE sy-datum TO ld_datum.

*--- Output line
  PERFORM f_hdr_pad_title USING va_street fu_company ld_datum.
ENDFORM.                    " F_HDR_LINE2X

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

*** For ALV LIST
  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1x USING sy-title.
  PERFORM f_hdr_line2x USING s_spmon-low(4).
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.
ENDFORM.



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
  FREE: t_s933_sum, t_mara, t_makt, t_result.

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
ENDFORM.


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
FORM f_reformat_data.
  DATA: ld_period(6) TYPE c,
        ld_date TYPE sy-datum,
        ld_row LIKE sy-tabix.
  DATA: BEGIN OF lt_mmyy OCCURS 0,
        t_period(6),
        END OF lt_mmyy.

*  SORT t_s933_sum BY spmon.
*  LOOP AT t_s933_sum.
*    t_period = t_s933_sum-spmon.
*    COLLECT t_period.
*  ENDLOOP.

  t_period = s_spmon-low.
  CONCATENATE t_period '01' INTO ld_date.
  COLLECT t_period.
  IF NOT s_spmon-high IS INITIAL.
    DO.
      CALL FUNCTION 'LAST_DAY_OF_MONTHS'
           EXPORTING
                day_in            = ld_date
           IMPORTING
                last_day_of_month = ld_date.

      IF ld_date(6) EQ s_spmon-high.
        t_period = ld_date(6).
        COLLECT t_period.
        EXIT.
      ELSE.
        t_period = ld_date(6).
        COLLECT t_period.
        ld_date = ld_date + 1.
      ENDIF.
    ENDDO.
  ENDIF.

  DESCRIBE TABLE t_period LINES d_nline.

  LOOP AT t_period.
    APPEND t_period TO lt_mmyy.
  ENDLOOP.

  DEFINE mac_trans.
  when '&1'.
    t_result-per&1 = t_s933_sum-menge.
  END-OF-DEFINITION.

  LOOP AT t_s933_sum.
    t_result = t_s933_sum.
    ld_period = t_s933_sum-spmon.
    CLEAR t_result-spmon.
    READ TABLE lt_mmyy  WITH KEY
      t_period = ld_period.
    ld_row = sy-tabix.
    CASE ld_row.
        mac_trans: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12.
    ENDCASE.
    t_result-total = t_result-per1 + t_result-per2 + t_result-per3 +
                     t_result-per4 + t_result-per5 + t_result-per6 +
                     t_result-per7 + t_result-per8 + t_result-per9 +
                     t_result-per10 + t_result-per11 + t_result-per12.
    CLEAR t_result-maktx.
    READ TABLE t_makt WITH KEY matnr = t_s933_sum-matnr
         BINARY SEARCH.
    IF sy-subrc = 0.
      t_result-maktx = t_makt-maktx.
    ENDIF.
    CLEAR t_result-meins.
    READ TABLE t_mara WITH KEY matnr = t_s933_sum-matnr
         BINARY SEARCH.
    IF sy-subrc = 0.
      t_result-meins = t_mara-meins.
    ENDIF.
    COLLECT t_result.
  ENDLOOP.
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

ENDFORM.
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

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  f_format_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_BUDAT  text
*      <--FC_BUDAT  text
*----------------------------------------------------------------------*
FORM f_format_date USING    fu_budat
                   CHANGING fc_budat.

  READ TABLE t_user INDEX 1.
  CASE t_user-datfm.
    WHEN 'DD.MM.YYYY'.
      CONCATENATE fu_budat+6(2) fu_budat+4(2) fu_budat+(4)
                  INTO fc_budat.
    WHEN 'MM/DD/YYYY' OR 'MM-DD-YYYY'.
      CONCATENATE fu_budat+4(2) fu_budat+6(2) fu_budat+(4)
                  INTO fc_budat.
    WHEN 'YYYY.MM.DD' OR 'YYYY/MM/DD' OR 'YYYY-MM-DD'.
      CONCATENATE fu_budat+(4) fu_budat+4(2) fu_budat+6(2)
                  INTO fc_budat.
  ENDCASE.

ENDFORM.                    " f_format_date

*&---------------------------------------------------------------------*
*&      Form  f_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init.

**Movement type
  REFRESH s_bwart.
  CLEAR s_bwart.
  s_bwart-sign = 'I'.
  s_bwart-option = 'BT'.
  s_bwart-low = '311'.
  s_bwart-high = '312'.
  APPEND s_bwart.
  s_bwart-sign = 'I'.
  s_bwart-option = 'BT'.
  s_bwart-low = '343'.
  s_bwart-high = '344'.
  APPEND s_bwart.

**Period
  REFRESH s_spmon.
  CLEAR s_spmon.
  s_spmon-sign = 'I'.
  s_spmon-option = 'BT'.
  CONCATENATE sy-datum(4) '01' INTO s_spmon-low.
  CONCATENATE sy-datum(4) '12' INTO s_spmon-high.
  APPEND s_spmon.

ENDFORM.                    " f_init
