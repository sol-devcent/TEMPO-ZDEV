*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.

**Get user defaults
  CLEAR: t_user, t_user[].
  t_user-bname = sy-uname.
  APPEND t_user.
  CALL FUNCTION 'SUSR_GET_USER_DEFAULTS'
    EXPORTING
      langu = sy-langu
    TABLES
      users = t_user.

  SELECT istat
    FROM tj02t
    INTO CORRESPONDING FIELDS OF TABLE i_tj02t
    WHERE spras EQ sy-langu AND
          txt04 IN ('CNF', 'PCNF').

  CLEAR: wa_tj02t.
  LOOP AT i_tj02t INTO wa_tj02t.
    r_istat-low    = wa_tj02t-istat.
    r_istat-option = 'EQ'.
    r_istat-sign   = 'I'.
    APPEND r_istat.
    CLEAR: wa_tj02t.
  ENDLOOP.

  SELECT *
    FROM zgdppdt0015
    INTO CORRESPONDING FIELDS OF TABLE gt_0015.
ENDFORM.                    "f_init_data

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
*{   REPLACE        P01K900131                                        1
*\      CONCATENATE fu_budat+6(2) fu_budat+4(2) fu_budat+(4)
      CONCATENATE fu_budat+6(2) fu_budat+4(2) fu_budat(4)
*}   REPLACE
                  INTO fc_budat.
    WHEN 'MM/DD/YYYY' OR 'MM-DD-YYYY'.
*{   REPLACE        P01K900131                                        2
*\      CONCATENATE fu_budat+4(2) fu_budat+6(2) fu_budat+(4)
      CONCATENATE fu_budat+4(2) fu_budat+6(2) fu_budat(4)
*}   REPLACE
                  INTO fc_budat.
    WHEN 'YYYY.MM.DD' OR 'YYYY/MM/DD' OR 'YYYY-MM-DD'.
      CONCATENATE fu_budat+(4) fu_budat+4(2) fu_budat+6(2)
                  INTO fc_budat.
  ENDCASE.

ENDFORM.                    " f_format_date

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  SELECT auart werks objnr plnbez aufnr rueck rmzhl
    FROM caufv
    INTO CORRESPONDING FIELDS OF TABLE i_itab
    WHERE aufnr  IN s_aufnr  AND
          auart  IN s_auart  AND
          autyp  EQ '40'     AND
          werks  EQ p_werks  AND
          plnbez IN s_plnbez AND
          ftrmi  IN s_ftrmi.

***removed by Rahmadi -- rueck & rmzhl in CAUFV is blank
*          rueck  NE SPACE    AND
*          rmzhl  NE SPACE.
***end of removal

  IF sy-subrc EQ 0.
*   Get Confirmed date for execution finish
    SELECT rueck rmzhl iedd aufnr budat
      FROM afru
      INTO CORRESPONDING FIELDS OF TABLE i_iedd
      FOR ALL ENTRIES IN i_itab
***changed by Rahmadi
*--selection must be based on AUFNR since RUECK & RMZHL are empty
*--in CAUFV/AFKO
*      WHERE rueck EQ i_itab-rueck AND
*            rmzhl EQ i_itab-rmzhl.
      WHERE aufnr EQ i_itab-aufnr AND
            budat IN s_budat AND
            stokz = '' AND
            stzhl = ''.
***end of changes

*   Get Batch number
    SELECT aufnr charg
      FROM afpo
      INTO CORRESPONDING FIELDS OF TABLE i_charg
      FOR ALL ENTRIES IN i_itab
      WHERE aufnr EQ i_itab-aufnr.

*   Filter batch number
    IF NOT i_charg[] IS INITIAL.
      SELECT matnr charg
             INTO TABLE t_mcha
             FROM mch1
             FOR ALL ENTRIES IN i_charg
             WHERE matnr IN s_plnbez AND
*                   werks = p_werks AND
                   charg = i_charg-charg. " AND
* Update production date MSC2N 23/06/2015
*                   hsdat = '00000000'.
      SORT t_mcha BY matnr charg.
    ENDIF.


*   Filter i_itab with 'CNF' & 'PCNF'
    SELECT objnr
      FROM jest
      INTO CORRESPONDING FIELDS OF TABLE i_objnr
      FOR ALL ENTRIES IN i_itab
      WHERE objnr EQ i_itab-objnr AND
            stat  IN r_istat AND
            inact EQ ''.
  ENDIF.

  break bcrmd.
***changed by Rahmadi
*--selection must be based on AUFNR since RUECK & RMZHL are empty
*--in CAUFV/AFKO
*  SORT i_iedd BY rueck rmzhl.
  SORT i_iedd BY aufnr rueck rmzhl.
***end of changes
  CLEAR: wa_itab.
  SORT i_itab BY aufnr rueck rmzhl.

  LOOP AT i_itab INTO wa_itab.
    CLEAR: i_itab.
    READ TABLE i_objnr INTO wa_objnr WITH KEY objnr = wa_itab-objnr.
    IF sy-subrc EQ 0.
      READ TABLE i_charg INTO wa_charg WITH KEY aufnr = wa_itab-aufnr.
      IF sy-subrc EQ 0.
        MODIFY i_itab FROM wa_charg TRANSPORTING charg.
        IF wa_charg-charg IS INITIAL.
          i_itab-msg = 'Batch number is not assigned'.
          i_itab-icon = icon_led_red.
          MODIFY i_itab TRANSPORTING msg icon.
        ELSE.
          READ TABLE t_mcha WITH KEY matnr = wa_itab-plnbez
                                     charg = wa_charg-charg
                                     BINARY SEARCH.
          IF sy-subrc = 0.
            READ TABLE i_iedd INTO wa_iedd WITH KEY
***modified by Rahmadi
*--selection must be based on AUFNR since RUECK & RMZHL are empty
*--in CAUFV/AFKO
                                           aufnr = wa_itab-aufnr
*                                     rueck = wa_itab-rueck
*                                     rmzhl = wa_itab-rmzhl
***end of modification
                                           BINARY SEARCH.
            IF sy-subrc EQ 0.
              PERFORM f_modify_nigeria USING wa_itab-plnbez wa_charg-charg
                                       CHANGING wa_iedd-budat.

              MODIFY i_itab FROM wa_iedd TRANSPORTING iedd budat.
              i_itab-icon = icon_led_green.
              MODIFY i_itab TRANSPORTING icon.
            ELSE.
              DELETE i_itab WHERE aufnr EQ wa_itab-aufnr.
            ENDIF.
          ELSE.
            DELETE i_itab WHERE aufnr EQ wa_itab-aufnr.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      DELETE i_itab WHERE aufnr EQ wa_itab-aufnr.
    ENDIF.
    CLEAR: wa_itab, wa_objnr, wa_iedd, wa_charg.
  ENDLOOP.
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.

  PERFORM f_alv TABLES i_itab.

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
  PERFORM f_build_fieldcat   TABLES  ft_report.
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

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
    'ICON' '' '' '' '9' 'Status' '' '' '' '' '' '' '' '',
    'PLNBEZ' 'CAUFV' 'PLNBEZ' '' '' '' '' '' '' '' '' '' '' '',
    'AUFNR' 'CAUFV' 'AUFNR' '' '' '' '' '' '' '' '' '' '' '',
    'CHARG' 'AFPO' 'CHARG' '' '' '' '' '' '' '' '' '' '' '',
    'WERKS' 'CAUFV' 'WERKS' '' '' '' '' '' '' '' '' '' '' '',
    'BUDAT' 'AFRU' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '',
    'IEDD' 'AFRU' 'IEDD' '' '' '' '' '' '' '' '' '' '' '',
    'MSG' '' '' '' '75' 'Message' '' '' '' '' '' '' '' ''.
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
ENDFORM.                    "f_build_sortfield



*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING ''.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page



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
* refresh:

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

  d_execute = p_test.
  sy-lsind = 0.
  IF d_execute IS INITIAL.
    SET PF-STATUS 'TOEXECUTE'.
  ELSE.
    SET PF-STATUS 'STATUS'.
  ENDIF.

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
      IF d_update IS INITIAL.
        d_update = 'X'.
        PERFORM f_post_entries.
        IF d_update = 'X'.
          CLEAR d_update.
          LEAVE TO SCREEN 0.
        ENDIF.

      ELSE.
        MESSAGE e000(zab) WITH 'Data cannot be executed anymore'.
      ENDIF.
    WHEN 'BACK'.
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
  DATA: l_date(10).

  IF i_itab IS INITIAL.
    MESSAGE e000(zab) WITH 'No data to execute'.
  ELSE.
    SORT i_itab BY plnbez.

    d_bdc_tctxt = 'Executing Transaction MSC2N'.
    d_bdc_batch = 'N'.

    CLEAR: t_bdcdata, t_bdcmsg.
    REFRESH: t_bdcdata, t_bdcmsg.
    CLEAR: wa_itab.
    LOOP AT i_itab INTO wa_itab
         WHERE NOT charg IS INITIAL.   "update only the one with batch

      PERFORM f_format_date USING    wa_itab-budat
                            CHANGING l_date.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
        'X' 'SAPLCHRG'     '1000',
        ' ' 'BDC_OKCODE'   '=ENTR',
        ' ' 'DFBATCH-MATNR' wa_itab-plnbez,
        ' ' 'DFBATCH-CHARG' wa_itab-charg,
        ' ' 'DFBATCH-WERKS' wa_itab-werks.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X' 'SAPLCHRG'     '1000',
      ' ' 'BDC_OKCODE'   '=ENTR',
      ' ' 'MCHA-HSDAT'    l_date.

      PERFORM f_bdc_data TABLES t_bdcdata USING:
      'X' 'SAPLCHRG'     '1000',
      ' ' 'BDC_OKCODE'   '=SAVE',
      ' ' 'MCHA-HSDAT'    l_date.

      PERFORM f_bdc_call_tcode_session TABLES t_bdcdata
                                              t_bdcmsg
                                       USING 'MSC2N' d_bdc_tctxt.

      PERFORM f_get_message USING t_bdcmsg
                            CHANGING wa_itab-msg.

*-----Update message for the status report
      IF d_bdc_error = 0.
        wa_itab-icon = icon_led_green.
        wa_itab-msg = 'Data has been saved'.
      ELSE.
        wa_itab-icon = icon_led_red.
      ENDIF.
      MODIFY i_itab FROM wa_itab TRANSPORTING msg icon
        WHERE plnbez = wa_itab-plnbez AND
              charg = wa_itab-charg   AND
              werks = wa_itab-werks.
      CLEAR: wa_itab, l_date.
      CLEAR: t_bdcdata, t_bdcmsg.
      REFRESH: t_bdcdata, t_bdcmsg.
    ENDLOOP.
    PERFORM f_print_data.
    MESSAGE s000(zab) WITH 'Data has been updated'.
  ENDIF.
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
*&      Form  F_MODIFY_NIGERIA
*&---------------------------------------------------------------------*
FORM f_modify_nigeria  USING    fu_matnr fu_charg
                       CHANGING fc_budat.

  DATA : ls_0015    LIKE LINE OF gt_0015,
         lv_charg   TYPE mcha-charg,
         lv_char1   TYPE mcha-charg,
         lv_char2   TYPE mcha-charg.

  READ TABLE gt_0015 INTO ls_0015
                     WITH KEY matnr = fu_matnr.
  IF sy-subrc = 0.
    IF ls_0015-charg IS NOT INITIAL.
      lv_charg = fu_charg.
      SPLIT lv_charg AT space INTO lv_char1 lv_char2.
      IF lv_char2 <> ls_0015-charg.
        CONCATENATE lv_char1 ls_0015-charg INTO lv_charg
        SEPARATED BY space.
        SELECT SINGLE hsdat
           FROM mch1
           INTO fc_budat
           WHERE matnr = fu_matnr
             AND charg = lv_charg.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_NIGERIA
