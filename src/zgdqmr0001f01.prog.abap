*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.
  CLEAR : t_main, t_matnr, t_mcha.
  REFRESH : t_main, t_matnr, t_mcha.

  CASE 'X'.
    WHEN rad01.
      gr_date[] = s_date[].
    WHEN rad02.
      gr_date[] = s_date1[].
  ENDCASE.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.

  DATA : l_mtart LIKE koth700-mtart.
  DATA : lv_qndat TYPE int4.

* Get Material Type
***  IF s_date-high IS INITIAL.
***    IF s_date-low IS INITIAL.
  SELECT SINGLE mtart INTO l_mtart
    FROM koth700
    WHERE kappl = 'V'         AND
          kschl = p_mtart     AND
          mtart = p_mtart     AND
          werks = p_werks.
***    ELSE.
***      SELECT SINGLE mtart INTO l_mtart
***        FROM koth700
***        WHERE kappl = 'V'         AND
***              kschl = p_mtart     AND
***              mtart = p_mtart     AND
***              werks = p_werks     AND
***              datbi GE s_date-low AND
***              datab LE s_date-low.
***    ENDIF.
***  ELSE.
***    SELECT SINGLE mtart INTO l_mtart
***      FROM koth700
***      WHERE kappl = 'V'         AND
***            kschl = p_mtart     AND
***            mtart = p_mtart     AND
***            werks = p_werks     AND
***            datbi GE s_date-high AND
***            datab LE s_date-high.
***  ENDIF.

  CHECK NOT l_mtart IS INITIAL.

* Get Material Number
  SELECT a~matnr meins INTO TABLE t_matnr
    FROM mara AS a JOIN marc AS b ON b~matnr = a~matnr
    WHERE a~matnr IN s_matnr
      AND a~mtart EQ l_mtart
      AND b~werks EQ p_werks.

  CHECK NOT t_matnr[] IS INITIAL.

* Get Main Data
  CASE 'X'.
    WHEN rad01.
      SELECT a~matnr werks lgort charg clabs ceinm cspem cinsm ersda
             b~maktx
        INTO CORRESPONDING FIELDS OF TABLE t_main
        FROM mchb AS a JOIN makt AS b ON a~matnr = b~matnr
        FOR ALL ENTRIES IN t_matnr
        WHERE a~matnr = t_matnr-matnr
          AND werks = p_werks.
*          AND clabs NE 0.

      SELECT a~matnr werks lgort charg slabs seinm sspem sinsm ersda
             b~maktx
        APPENDING CORRESPONDING FIELDS OF TABLE t_main
        FROM mkol AS a JOIN makt AS b ON a~matnr = b~matnr
        FOR ALL ENTRIES IN t_matnr
        WHERE a~matnr = t_matnr-matnr
          AND werks   = p_werks.
*          AND slabs   NE 0.

      SELECT a~matnr werks charg lblab lbein lbins
             b~maktx
        APPENDING CORRESPONDING FIELDS OF TABLE t_main
        FROM mslb AS a JOIN makt AS b ON a~matnr = b~matnr
        FOR ALL ENTRIES IN t_matnr
        WHERE a~matnr = t_matnr-matnr
          AND werks   = p_werks.
*          AND lblab   NE 0.

    WHEN rad02.
      SELECT a~matnr werks lgort charg clabs ceinm cspem ersda
             b~maktx
        INTO CORRESPONDING FIELDS OF TABLE t_main
        FROM mchb AS a JOIN makt AS b ON a~matnr = b~matnr
        FOR ALL ENTRIES IN t_matnr
        WHERE a~matnr = t_matnr-matnr
          AND werks = p_werks.

      SELECT a~matnr werks lgort charg slabs seinm sspem ersda
             b~maktx
        APPENDING CORRESPONDING FIELDS OF TABLE t_main
        FROM mkol AS a JOIN makt AS b ON a~matnr = b~matnr
        FOR ALL ENTRIES IN t_matnr
        WHERE a~matnr = t_matnr-matnr
          AND werks   = p_werks.

      SELECT a~matnr werks charg lblab lbein
             b~maktx
        APPENDING CORRESPONDING FIELDS OF TABLE t_main
        FROM mslb AS a JOIN makt AS b ON a~matnr = b~matnr
        FOR ALL ENTRIES IN t_matnr
        WHERE a~matnr = t_matnr-matnr
          AND werks   = p_werks.
  ENDCASE.

  CHECK NOT t_main[] IS INITIAL.

* Get Next Inspection Date
  CASE 'X'.
    WHEN rad01.
      SELECT a~matnr a~werks a~charg b~qndat b~vfdat
        INTO TABLE t_mcha
        FROM mcha AS a JOIN mch1 AS b ON a~matnr = b~matnr AND
                                         a~charg = b~charg
        FOR ALL ENTRIES IN t_main
        WHERE a~matnr = t_main-matnr
          AND a~werks = p_werks
          AND a~charg = t_main-charg
          AND b~qndat IN gr_date.
    WHEN rad02.
      SELECT a~matnr a~werks a~charg b~qndat b~vfdat
        INTO TABLE t_mcha
        FROM mcha AS a JOIN mch1 AS b ON a~matnr = b~matnr AND
                                         a~charg = b~charg
        FOR ALL ENTRIES IN t_main
        WHERE a~matnr = t_main-matnr
          AND a~werks = p_werks
          AND a~charg = t_main-charg
          AND b~vfdat IN gr_date.
  ENDCASE.

* Completed Itab
  CASE 'X'.
    WHEN rad01.
      SORT t_matnr BY matnr.
      SORT t_mcha BY matnr werks charg.
      SORT t_main BY matnr werks charg.
      LOOP AT t_main.
        IF t_main-slabs IS NOT INITIAL.
          t_main-clabs = t_main-slabs.
          MODIFY t_main TRANSPORTING clabs.
        ENDIF.

        IF t_main-lblab IS NOT INITIAL.
          t_main-clabs = t_main-lblab.
          MODIFY t_main TRANSPORTING clabs.
        ENDIF.

        PERFORM f_modify_xclab USING : t_main-clabs,
                                       t_main-slabs,
                                       t_main-lblab,
                                       t_main-cinsm,
                                       t_main-sinsm,
                                       t_main-lbins.

        CLEAR: t_matnr, t_mcha.
        READ TABLE t_mcha WITH KEY matnr = t_main-matnr
                                   werks = t_main-werks
                                   charg = t_main-charg.
        IF sy-subrc = 0.
          READ TABLE t_matnr WITH KEY matnr = t_main-matnr.
          t_main-meins = t_matnr-meins.
          t_main-qndat = t_mcha-qndat.
          t_main-vfdat = t_mcha-vfdat.
          MODIFY t_main.
        ELSE.
          DELETE t_main.
          CONTINUE.
        ENDIF.

        t_main-qnday = t_main-qndat - sy-datum.
        IF t_main-qnday LE 3.
          t_main-icon = icon_red_light.
        ELSEIF t_main-qnday LE 7.
          t_main-icon = icon_yellow_light.
        ELSE.
          t_main-icon = icon_green_light.
        ENDIF.
        MODIFY t_main TRANSPORTING qnday icon.
        CLEAR t_main.
      ENDLOOP.

    WHEN rad02.
      PERFORM f_process_rad02.
  ENDCASE.
ENDFORM.                    "f_get_data


*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.

*  t_main_tmp[] = t_main[].
*  ASSIGN t_main_tmp TO <fs_table>.
*  PERFORM f_alv TABLES <fs_table>.
  PERFORM f_alv TABLES t_main.

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
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event       TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
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
    'ICON' '' '' '' '4' '' '' '' '' '' '' '' '' '' '',
    'MATNR' 'MARA' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '',
    'CHARG' 'MCHA' 'CHARG' '' '' '' '' '' '' '' '' '' '' '' '',
    'LGORT' 'MCHB' 'LGORT' '' '' '' '' '' '' '' '' '' '' '' '',
    'CLABS' 'MCHB' 'CLABS' '' '' '' 'X' '' '' '' '' '' 'MEINS' '' ''.

  IF rad02 IS NOT INITIAL.
    PERFORM f_fieldcatg USING ft_report:
      'CEINM' 'MCHB' 'CEINM' '' '' '' 'X' '' '' '' '' '' 'MEINS' '' ''.
    IF p_werks = '2300'.
      PERFORM f_fieldcatg USING ft_report:
        'CSPEM' 'MCHB' 'CSPEM' '' '' '' 'X' '' '' '' '' '' 'MEINS' '' ''.
    ENDIF.
  ENDIF.

  PERFORM f_fieldcatg USING ft_report:
    'MEINS' 'MARA' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '',
    'QNDAT' 'MCHA' 'QNDAT' '' '' '' '' '' '' '' '' '' '' '' '',
    'VFDAT' 'MCH1' 'VFDAT' '' '' '' '' '' '' '' '' '' '' '' '',
    'TEXT'  '' '' '' '20' 'Comments' '' '' '' '' '' '' '' '' 'X',
    'QNDAY' '' '' 'X' '10' 'Days' '' '' '' '' '' '' '' '' '',
    'NOTE' 'DFBATCH' 'KZTXT' '' '' 'Note' '' '' '' '' '' '' '' '' ''.

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
                          value(fu_checkbox)
                          value(fu_input).

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
  ld_fieldcat-currency      = fu_waers.
  ld_fieldcat-quantity      = fu_meins.
  ld_fieldcat-qfieldname    = fu_meins_f.
  ld_fieldcat-cfieldname    = fu_waers_f.
  ld_fieldcat-checkbox      = fu_checkbox.
  ld_fieldcat-input         = fu_input.
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
  fu_layout-zebra              = 'X'.
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

  CLEAR ld_sort.
  ld_sort-fieldname = 'QNDAY'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'MATNR'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'CHARG'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'LGORT'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

ENDFORM.                    "f_build_sortfield

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
FORM f_validate_data.
  SORT t_mseg BY matnr charg mblnr DESCENDING.
  LOOP AT t_main.
    IF t_main-cspem IS NOT INITIAL.
      CLEAR t_mseg.
      READ TABLE t_mseg WITH KEY matnr = t_main-matnr
                                 charg = t_main-charg.
      IF sy-subrc = 0.
        IF t_mseg-tcode2 <> 'QA07'.
          CLEAR t_main-cspem.
          MODIFY t_main TRANSPORTING cspem.
        ENDIF.
      ELSE.
        CLEAR t_main-cspem.
        MODIFY t_main TRANSPORTING cspem.
      ENDIF.
    ENDIF.
    IF t_main-clabs IS NOT INITIAL.
      t_main-xlabs = t_main-clabs.
    ELSEIF t_main-cinsm IS NOT INITIAL.
    ENDIF.
  ENDLOOP.

  CASE p_werks.
    WHEN '3600'.
      DELETE t_main WHERE clabs IS INITIAL
                      AND ceinm IS INITIAL.
    WHEN '2300'.
*      DELETE t_main WHERE clabs IS INITIAL
*                      AND ceinm IS INITIAL
*                      AND cspem IS INITIAL.
      CASE 'X'.
        WHEN rad01.
          DELETE t_main WHERE clabs IS INITIAL.
        WHEN rad02.
          DELETE t_main WHERE clabs IS INITIAL
                          AND ceinm IS INITIAL
                          AND cspem IS INITIAL.
      ENDCASE.

    WHEN '0101' OR '0102'.
      CASE 'X'.
        WHEN rad01.
          DELETE t_main WHERE xlabs IS INITIAL.
        WHEN rad02.
          DELETE t_main WHERE clabs IS INITIAL.
      ENDCASE.

    WHEN OTHERS.
      DELETE t_main WHERE clabs IS INITIAL.
  ENDCASE.

  LOOP AT t_main.
    PERFORM f_get_note USING t_main-matnr t_main-charg.
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
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF p_werks IS INITIAL.
    PERFORM f_error_message USING 'PWE' 'Please input Plant'.
  ENDIF.

  IF p_mtart IS INITIAL.
    PERFORM f_error_message USING 'PMT' 'Please input Material Type'.
  ENDIF.

  CASE 'X'.
    WHEN rad01.
      IF s_date[] IS INITIAL.
        PERFORM f_error_message USING 'SD0' 'Please input Next Inspection Date'.
      ENDIF.
    WHEN rad02.
      IF s_date1[] IS INITIAL.
        PERFORM f_error_message USING 'SD1' 'Please input Expiration Date'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

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

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  DATA : l_title(70),
         l_period(70),
         l_datel(10),
         l_dateh(10),
         ld_werks(40).

  CONCATENATE sy-title p_mtart INTO l_title
              SEPARATED BY space.
  CASE 'X'.
    WHEN rad01.
      WRITE s_date-low TO l_datel DD/MM/YYYY.
      WRITE s_date-high TO l_dateh DD/MM/YYYY.
      CONCATENATE text-002 l_datel 'to' l_dateh INTO l_period
                  SEPARATED BY space.
    WHEN rad02.
      WRITE s_date1-low TO l_datel DD/MM/YYYY.
      WRITE s_date1-high TO l_dateh DD/MM/YYYY.
      CONCATENATE text-003 l_datel 'to' l_dateh INTO l_period
                  SEPARATED BY space.
  ENDCASE.
  CONCATENATE 'Plant' p_werks '-' t001w-name1 INTO ld_werks
              SEPARATED BY space.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING l_title.
  PERFORM f_hdr_line2 USING ld_werks.
  PERFORM f_hdr_line3 USING l_period.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page


*data: gs_lineinfo type kkblo_lineinfo.
FORM f_after_line_output USING lineinfo TYPE slis_lineinfo.
  BREAK-POINT.
ENDFORM.                    "f_after_line_output

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN rad01.
      PERFORM f_modify_screen USING : 'SD1' '' '0' '' ''.
      CLEAR : s_date1[], s_date1.
    WHEN rad02.
      PERFORM f_modify_screen USING : 'SD0' '' '0' '' ''.
      s_date1-low     = sy-datum - 3.
      s_date1-high    = sy-datum + 3.
      s_date1-sign    = 'I'.
      s_date1-option  = 'BT'.
      APPEND s_date1.
      CLEAR : s_date[], s_date.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_required.
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

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_RAD02
*&---------------------------------------------------------------------*
FORM f_process_rad02 .
  DATA : lt_main    LIKE t_main OCCURS 0.

  SORT t_matnr BY matnr.
  SORT t_mcha BY matnr werks charg.
  SORT t_main BY matnr werks charg.
  LOOP AT t_main.
    IF t_main-slabs IS NOT INITIAL.
      t_main-clabs = t_main-slabs.
    ENDIF.

    IF t_main-lblab IS NOT INITIAL.
      t_main-clabs = t_main-lblab.
    ENDIF.

    IF t_main-seinm IS NOT INITIAL.
      t_main-ceinm = t_main-seinm.
    ENDIF.

    IF t_main-lbein IS NOT INITIAL.
      t_main-ceinm = t_main-lbein.
    ENDIF.

    IF t_main-sspem IS NOT INITIAL.
      t_main-cspem = t_main-sspem.
    ENDIF.

    CLEAR: t_matnr, t_mcha.
    READ TABLE t_mcha WITH KEY matnr = t_main-matnr
                               werks = t_main-werks
                               charg = t_main-charg.
    IF sy-subrc = 0.
      READ TABLE t_matnr WITH KEY matnr = t_main-matnr.
      t_main-meins = t_matnr-meins.
      t_main-qndat = t_mcha-qndat.
      t_main-vfdat = t_mcha-vfdat.
    ELSE.
      DELETE t_main.
      CONTINUE.
    ENDIF.

    t_main-qnday = t_main-vfdat - sy-datum.
    IF t_main-qnday LE 0.
      t_main-icon = icon_red_light.
    ELSEIF t_main-qnday LE 3.
      t_main-icon = icon_yellow_light.
    ELSE.
      t_main-icon = icon_green_light.
    ENDIF.

    MODIFY t_main TRANSPORTING clabs ceinm cspem meins qndat vfdat qnday icon.
    CLEAR t_main.
  ENDLOOP.

  lt_main[] = t_main[].
  DELETE lt_main WHERE cspem IS INITIAL.
  SORT lt_main BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM lt_main COMPARING matnr charg.
  IF lt_main[] IS NOT INITIAL.
    SELECT mseg~mblnr mseg~mjahr zeile matnr lgort charg tcode2 cpudt
    FROM mseg JOIN mkpf ON mseg~mblnr = mkpf~mblnr
                       AND mseg~mjahr = mkpf~mjahr
    INTO TABLE t_mseg
    FOR ALL ENTRIES IN lt_main
    WHERE matnr = lt_main-matnr
      AND lgort = lt_main-lgort
      AND charg = lt_main-charg
      AND werks = p_werks
      AND bwart = '344'
      AND xauto = space.
  ENDIF.
ENDFORM.                    " F_PROCESS_RAD02

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_XCLAB
*&---------------------------------------------------------------------*
FORM f_modify_xclab  USING    fu_clabs.
  IF fu_clabs IS NOT INITIAL.
    t_main-xlabs = fu_clabs.
    MODIFY t_main TRANSPORTING xlabs.
  ENDIF.
ENDFORM.                    " F_MODIFY_XCLAB

*&---------------------------------------------------------------------*
*&      Form  F_GET_NOTE
*&---------------------------------------------------------------------*
FORM f_get_note  USING    fu_matnr fu_charg.
  DATA : lv_name    TYPE thead-tdname,
         lt_lines   TYPE STANDARD TABLE OF tline,
         ls_lines   LIKE LINE OF lt_lines.

  lv_name(18)    = fu_matnr.
  lv_name+22(10) = fu_charg.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'VERM'
      language                = sy-langu
      name                    = lv_name
      object                  = 'CHARGE'
    TABLES
      lines                   = lt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  IF sy-subrc = 0.
    READ TABLE lt_lines INTO ls_lines INDEX 1.
    IF sy-subrc = 0.
      t_main-note = ls_lines-tdline.
      MODIFY t_main TRANSPORTING note.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_NOTE
