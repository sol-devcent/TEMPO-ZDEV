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

* Get month
  DO 9 TIMES.
    ADD 1 TO va_count.
    IF va_count EQ 1.
      va_count1 = va_count.
    ELSEIF va_count LT 6.
      va_count1 = va_count1 + 3.
    ELSE.
      va_count1 = va_count1 + 12.
    ENDIF.

    va_month00 = pa_perio.
    CALL FUNCTION 'HR_CALC_MONTH'
         EXPORTING
              delta   = va_count1
         CHANGING
              periode = va_month00.
    CASE va_count1.
      WHEN 1.
        va_month01 = va_month00.
        va_count1  = 0.
      WHEN 3.
        va_month03 = va_month00.
      WHEN 6.
        va_month06 = va_month00.
      WHEN 9.
        va_month09 = va_month00.
      WHEN 12.
        va_month12 = va_month00.
      WHEN 24.
        va_month24 = va_month00.
      WHEN 36.
        va_month36 = va_month00.
      WHEN 48.
        va_month48 = va_month00.
      WHEN 60.
        va_month60 = va_month00.
    ENDCASE.
  ENDDO.
  va_month00 = pa_perio.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA: l_toleranzun(22),
        l_toleranzob(22),
        l_prueflos  LIKE qals-prueflos,
        l_annahmez  LIKE qasv-annahmez,
        l_enstehdat LIKE qals-enstehdat,
        l_schdat    LIKE qals-enstehdat,
        l_schmth    LIKE pc260-fpper,
        l_count     TYPE i.

  SELECT SINGLE mtart
    FROM mara
    INTO va_mtart
    WHERE matnr EQ pa_matnr.

*{   REPLACE        P01K910383                                        1
*\  SELECT prueflos werk art matnr charg enstehdat pastrterm plnty plnnr
*\         plnal aufnr
*\    FROM qals
*\    INTO CORRESPONDING FIELDS OF TABLE i_hd
*\    WHERE werk         EQ pa_werk  AND
*\          art          IN ('41','03')  AND
*\          matnr        EQ pa_matnr AND
*\          charg        EQ pa_charg.
  "Start SOH: Shell SCI Adjustment 20240222 KRS
  SELECT prueflos werk art matnr charg enstehdat pastrterm plnty plnnr
         plnal aufnr
    FROM qals
    INTO CORRESPONDING FIELDS OF TABLE i_hd
    WHERE werk         EQ pa_werk  AND
          art          IN ('41','03')  AND
          matnr        EQ pa_matnr AND
          charg        EQ pa_charg
    ORDER BY prueflos.
    "End SOH: Shell SCI Adjustment 20240222 KRS
*}   REPLACE

  DELETE i_hd WHERE charg EQ space.
***changed by Rahmadi
*  APPEND LINES OF i_hd TO i_link.
  i_link[] = i_hd[].
***end of change
  DELETE ADJACENT DUPLICATES FROM i_link COMPARING plnty plnnr plnal.

  IF NOT i_link[] IS INITIAL.
    SELECT plnty plnnr plnal plnkn
      FROM plas
      INTO CORRESPONDING FIELDS OF TABLE i_hd1
      FOR ALL ENTRIES IN i_link
      WHERE plnty EQ i_link-plnty AND
            plnnr EQ i_link-plnnr AND
            plnal EQ i_link-plnal.

    IF NOT i_hd1[] IS INITIAL.
      SELECT a~kurztext a~masseinhsw a~merknr a~dummy40 a~toleranzun
             a~toleranzob a~stellen a~plnty a~plnnr a~plnkn a~sollwni
             a~verwmerkm
             b~vornr
        FROM plmk AS a JOIN plpo AS b ON a~plnty EQ b~plnty AND
                                         a~plnnr EQ b~plnnr AND
                                         a~plnkn EQ b~plnkn
        INTO CORRESPONDING FIELDS OF TABLE i_dt
        FOR ALL ENTRIES IN i_hd1
        WHERE a~plnty   EQ i_hd1-plnty AND
              a~plnnr   EQ i_hd1-plnnr AND
              a~plnkn   EQ i_hd1-plnkn AND
              a~loekz   NE 'X'.
    ENDIF.
  ENDIF.

  CLEAR: wa_hd.
  LOOP AT i_hd INTO wa_hd.
    va_charg = wa_hd-charg.
    wa_gab-period    = wa_hd-pastrterm(6).
    wa_gab-enstehdat = wa_hd-enstehdat.
    wa_gab-pastrterm = wa_hd-pastrterm.
    wa_gab-prueflos  = wa_hd-prueflos.
    CLEAR: wa_dt.
    LOOP AT i_dt INTO wa_dt
      WHERE plnty EQ wa_hd-plnty AND
            plnnr EQ wa_hd-plnnr.
      wa_gab-vornr     = wa_dt-vornr.
      wa_gab-merknr    = wa_dt-merknr.
      wa_gab-plnty     = wa_dt-plnty.
      wa_gab-plnnr     = wa_dt-plnnr.
      wa_gab-verwmerkm = wa_dt-verwmerkm.
      wa_gab-kurztext  = wa_dt-kurztext.
* Get result
      CALL FUNCTION 'BAPI_INSPCHAR_GETRESULT'
           EXPORTING
                insplot       = wa_gab-prueflos
                inspoper      = wa_gab-vornr
                inspchar      = wa_gab-merknr
           IMPORTING
                char_result   = char_result
                sample_result = sample_result.
      IF sy-subrc EQ 0.
        IF wa_dt-verwmerkm(1) EQ 'R'.
          IF NOT sample_result-minimum IS INITIAL AND
            NOT sample_result-maximum IS INITIAL.
            CONCATENATE sample_result-minimum '-' sample_result-maximum
              INTO wa_gab-result
              SEPARATED BY space.
          ENDIF.
        ELSE.
          IF wa_hd-art EQ '41'.
            IF char_result-mean_value EQ space.
              SELECT SINGLE kurztext
                FROM qpct
                INTO wa_gab-result
                WHERE katalogart EQ '1'                   AND
                      codegruppe EQ char_result-code_grp1 AND
                      code       EQ char_result-code1.
            ELSE.
              wa_gab-result = char_result-mean_value.
            ENDIF.
          ELSEIF wa_hd-art EQ '03'.
            IF sample_result-mean_value EQ space.
              SELECT SINGLE kurztext
                FROM qpct
                INTO wa_gab-result
                WHERE katalogart EQ '1'                   AND
                      codegruppe EQ sample_result-code_grp1 AND
                      code       EQ sample_result-code1.
            ELSE.
              wa_gab-result = sample_result-mean_value.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF wa_hd-art EQ '41'.
        APPEND wa_gab TO i_gab.
        CLEAR: wa_gab-result.
      ENDIF.

      IF wa_hd-art EQ '03'.
        READ TABLE i_gab1 INTO wa_gab1 WITH KEY vornr  = wa_dt-vornr
                                                merknr = wa_dt-merknr.
        IF sy-subrc NE 0.
          APPEND wa_gab TO i_gab1.
        ENDIF.
        CLEAR: wa_gab-result.
      ENDIF.
    ENDLOOP.
    CLEAR: wa_hd.
  ENDLOOP.

* Analysis date process
  CLEAR: wa_gab, l_count.
  LOOP AT i_gab INTO wa_gab.
    IF l_count EQ 0.
      l_count = 1.
      READ TABLE i_gab1 INTO wa_gab1 INDEX 1.
      l_enstehdat = wa_gab1-pastrterm.
      CONCATENATE l_enstehdat+6(2) l_enstehdat+4(2) l_enstehdat(4)
          INTO wa_out-month00
          SEPARATED BY '.'.
      l_schdat = l_enstehdat.
      l_schmth = l_enstehdat.
    ENDIF.
    l_enstehdat = wa_gab-pastrterm.
    AT NEW period.
      CASE wa_gab-period.
        WHEN va_month00.
*          CONCATENATE l_enstehdat+6(2) l_enstehdat+4(2) l_enstehdat(4)
*              INTO wa_out-month00
*              SEPARATED BY '.'.
*          l_schdat = l_enstehdat.
*          l_schmth = l_enstehdat.
        WHEN va_month01.
          CONCATENATE l_enstehdat+6(2) l_enstehdat+4(2) l_enstehdat(4)
                INTO wa_out-month01
                SEPARATED BY '.'.
        WHEN va_month03.
          CONCATENATE l_enstehdat+6(2) l_enstehdat+4(2) l_enstehdat(4)
                INTO wa_out-month03
                SEPARATED BY '.'.
        WHEN va_month06.
          CONCATENATE l_enstehdat+6(2) l_enstehdat+4(2) l_enstehdat(4)
                INTO wa_out-month06
                SEPARATED BY '.'.
        WHEN va_month09.
          CONCATENATE l_enstehdat+6(2) l_enstehdat+4(2) l_enstehdat(4)
                INTO wa_out-month09
                SEPARATED BY '.'.
        WHEN va_month12.
          CONCATENATE l_enstehdat+6(2) l_enstehdat+4(2) l_enstehdat(4)
                INTO wa_out-month12
                SEPARATED BY '.'.
        WHEN va_month24.
          CONCATENATE l_enstehdat+6(2) l_enstehdat+4(2) l_enstehdat(4)
                INTO wa_out-month24
                SEPARATED BY '.'.
        WHEN va_month48.
          CONCATENATE l_enstehdat+6(2) l_enstehdat+4(2) l_enstehdat(4)
                INTO wa_out-month48
                SEPARATED BY '.'.
        WHEN va_month60.
          CONCATENATE l_enstehdat+6(2) l_enstehdat+4(2) l_enstehdat(4)
                INTO wa_out-month60
                SEPARATED BY '.'.
      ENDCASE.
    ENDAT.

    AT LAST.
      wa_out-kurztext = 'Inspection Date'.
      APPEND wa_out TO i_out.
    ENDAT.
    CLEAR: wa_gab.
  ENDLOOP.


  wa_out-kurztext = 'Schedule Date'.
* wa_out-month00 = l_schdat.
  CONCATENATE l_schdat+6(2) l_schdat+4(2) l_schdat(4)
              INTO wa_out-month00
              SEPARATED BY '.'.
  CALL FUNCTION 'HR_CALC_MONTH'
       EXPORTING
            delta   = 1
       CHANGING
            periode = l_schmth.
  CONCATENATE l_schdat+6(2) l_schmth+4(2) l_schmth(4)
              INTO wa_out-month01
              SEPARATED BY '.'.
  CALL FUNCTION 'HR_CALC_MONTH'
       EXPORTING
            delta   = 2
       CHANGING
            periode = l_schmth.
  CONCATENATE l_schdat+6(2) l_schmth+4(2) l_schmth(4)
              INTO wa_out-month03
              SEPARATED BY '.'.
  CALL FUNCTION 'HR_CALC_MONTH'
       EXPORTING
            delta   = 3
       CHANGING
            periode = l_schmth.
  CONCATENATE l_schdat+6(2) l_schmth+4(2) l_schmth(4)
              INTO wa_out-month06
              SEPARATED BY '.'.
  CALL FUNCTION 'HR_CALC_MONTH'
       EXPORTING
            delta   = 3
       CHANGING
            periode = l_schmth.
  CONCATENATE l_schdat+6(2) l_schmth+4(2) l_schmth(4)
              INTO wa_out-month09
              SEPARATED BY '.'.
  CALL FUNCTION 'HR_CALC_MONTH'
       EXPORTING
            delta   = 3
       CHANGING
            periode = l_schmth.
  CONCATENATE l_schdat+6(2) l_schmth+4(2) l_schmth(4)
              INTO wa_out-month12
              SEPARATED BY '.'.
  CALL FUNCTION 'HR_CALC_MONTH'
       EXPORTING
            delta   = 12
       CHANGING
            periode = l_schmth.
  CONCATENATE l_schdat+6(2) l_schmth+4(2) l_schmth(4)
              INTO wa_out-month24
              SEPARATED BY '.'.
  CALL FUNCTION 'HR_CALC_MONTH'
       EXPORTING
            delta   = 24
       CHANGING
            periode = l_schmth.
  CONCATENATE l_schdat+6(2) l_schmth+4(2) l_schmth(4)
              INTO wa_out-month48
              SEPARATED BY '.'.
  CALL FUNCTION 'HR_CALC_MONTH'
       EXPORTING
            delta   = 12
       CHANGING
            periode = l_schmth.
  CONCATENATE l_schdat+6(2) l_schmth+4(2) l_schmth(4)
              INTO wa_out-month60
              SEPARATED BY '.'.
  APPEND wa_out TO i_out.
  CLEAR: wa_out.

  CLEAR: wa_dt.
  LOOP AT i_dt INTO wa_dt.
    CLEAR: wa_gab.
    SORT i_gab BY period vornr merknr.
    LOOP AT i_gab INTO wa_gab
      WHERE plnty  EQ wa_dt-plnty AND
            plnnr  EQ wa_dt-plnnr AND
            vornr  EQ wa_dt-vornr AND
            merknr EQ wa_dt-merknr.

      CASE wa_gab-period.
        WHEN va_month01.
          wa_out-month01 = wa_gab-result.
        WHEN va_month03.
          wa_out-month03 = wa_gab-result.
        WHEN va_month06.
          wa_out-month06 = wa_gab-result.
        WHEN va_month09.
          wa_out-month09 = wa_gab-result.
        WHEN va_month12.
          wa_out-month12 = wa_gab-result.
        WHEN va_month24.
          wa_out-month24 = wa_gab-result.
        WHEN va_month48.
          wa_out-month48 = wa_gab-result.
        WHEN va_month60.
          wa_out-month60 = wa_gab-result.
      ENDCASE.

      IF NOT i_gab IS INITIAL.
        READ TABLE i_gab1 INTO wa_gab1
        WITH KEY kurztext  = wa_dt-kurztext
                 verwmerkm = wa_dt-verwmerkm.
        IF sy-subrc EQ 0.
          wa_out-month00 = wa_gab1-result.
        ELSE.
          CLEAR wa_out-month00.
        ENDIF.
      ENDIF.

      CLEAR: wa_gab.
    ENDLOOP.

    IF sy-subrc EQ 0.
      wa_out-kurztext = wa_dt-kurztext.
* Specification process
      IF wa_dt-masseinhsw EQ space.
        IF va_mtart EQ 'ZPM'.
          SELECT SINGLE annahmez
            FROM qasv
            INTO l_annahmez
            WHERE prueflos EQ l_prueflos AND
                  merknr   EQ wa_dt-merknr.
          wa_out-specific = l_annahmez.
        ELSE.
          wa_out-specific = wa_dt-dummy40.
        ENDIF.
      ELSE.
        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
             EXPORTING
                  input = wa_dt-toleranzun
                  ivalu = 'X'
                  decim = wa_dt-stellen
             IMPORTING
                  flstr = l_toleranzun.

        CALL FUNCTION 'FLTP_CHAR_CONVERSION'
             EXPORTING
                  input = wa_dt-toleranzob
                  ivalu = 'X'
                  decim = wa_dt-stellen
             IMPORTING
                  flstr = l_toleranzob.

        SHIFT l_toleranzun LEFT DELETING LEADING space.
        SHIFT l_toleranzob LEFT DELETING LEADING space.
        CONCATENATE l_toleranzun '-' l_toleranzob wa_dt-masseinhsw
          INTO wa_out-specific
          SEPARATED BY space.
      ENDIF.
      APPEND wa_out TO i_out.
      CLEAR: wa_out.
    ENDIF.
    CLEAR: wa_dt.
  ENDLOOP.

  CLEAR: wa_out.
  wa_out-kurztext = 'Diperiksa oleh'.
  wa_out-info     = 'C30'.
  APPEND wa_out TO i_out.

  wa_out-kurztext = 'QC/QA Mgr'.
  wa_out-info     = 'C30'.
  APPEND wa_out TO i_out.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.
  PERFORM f_alv TABLES i_out.
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
ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
    'KURZTEXT' '' '' '' '40' 'TESTS' '' '' '' '' '' '' '' '',
    'SPECIFIC' '' '' '' '22' 'SPECIFICATION' '' '' '' '' '' '' '' '',
    'MONTH00' '' '' '' '22' 'MONTH' '' '' '' '' '' '' '' '',
    'MONTH01' '' '' '' '22' 'MONTH + 1' '' '' '' '' '' '' '' '',
    'MONTH03' '' '' '' '22' 'MONTH + 3' '' '' '' '' '' '' '' '',
    'MONTH06' '' '' '' '22' 'MONTH + 6' '' '' '' '' '' '' '' '',
    'MONTH09' '' '' '' '22' 'MONTH + 9' '' '' '' '' '' '' '' '',
    'MONTH12' '' '' '' '22' 'MONTH + 12' '' '' '' '' '' '' '' '',
    'MONTH24' '' '' '' '22' 'MONTH + 24' '' '' '' '' '' '' '' '',
    'MONTH48' '' '' '' '22' 'MONTH + 48' '' '' '' '' '' '' '' '',
    'MONTH60' '' '' '' '22' 'MONTH + 60' '' '' '' '' '' '' '' ''.
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
  fu_layout-info_fieldname     = 'INFO'.

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

ENDFORM.

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
  SKIP 1.

  PERFORM f_hdr_line4 USING ''.

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

  sy-lsind = 0.
*  SET PF-STATUS 'STANDARD'.

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
  BREAK-POINT.
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
*&      Form  f_hdr_line4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0465   text
*----------------------------------------------------------------------*
FORM f_hdr_line4 USING fu_title.
  DATA: l_matnr(60) VALUE 'NAMA PRODUK : ',
        l_maktx LIKE makt-maktx,
        l_charg(60) VALUE 'NO. BATCH   : '.

  SELECT SINGLE maktx
    FROM makt
    INTO l_maktx
    WHERE matnr EQ pa_matnr.

  CONCATENATE l_matnr l_maktx INTO l_matnr
    SEPARATED BY space.
*--- output line
  WRITE: /2 l_matnr.

  CONCATENATE l_charg va_charg INTO l_charg
    SEPARATED BY space.
*--- output line
  WRITE: /2 l_charg.

ENDFORM.                    " f_hdr_line4
