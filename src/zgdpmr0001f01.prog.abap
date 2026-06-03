*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.
  Refresh: i_material, i_viaufks, i_itab, i_matnr.
  Clear: i_material, i_viaufks, i_itab, i_matnr,
         wa_material, wa_viaufks, wa_itab, wa_matnr.
  Refresh: i_AFFHD, i_AFVGD, i_RESBD, i_RIPW0, i_RIPRT1,
           i_IHPAD, i_IHSG, i_IHGNS, i_KBEDP.

  Clear: i_AFFHD, i_AFVGD, i_RESBD, i_RIPW0, i_RIPRT1,
         i_IHPAD, i_IHSG, i_IHGNS, i_KBEDP,
         wa_AFFHD, wa_AFVGD, wa_RESBD, wa_RIPW0, wa_RIPRT1,
         wa_IHPAD, wa_IHSG, wa_IHGNS, wa_KBEDP,
         wa_CAUFVD, wa_ILOA, wa_RIWO1.
ENDFORM.                    "f_init_data


*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.

  Select * into table i_VIAUFKS from VIAUFKS
        where iwerk = p_werks and
              auart in s_auart and
              tplnr in s_tplnr and
              plnbez in s_plnbez and
              gstrp in s_gstrp.




ENDFORM.                    "f_get_data


*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.

*  t_main_tmp[] = t_main[].
*  ASSIGN t_main_tmp TO <fs_table>.
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
*perform F_TOP_OF_PAGE.

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
*    i_callback_pf_status_set       = 'F_SET_PF_STATUS'
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
*   wa_itab-aufnr = wa_VIAUFKS-aufnr.
*   wa_itab-tplnr = wa_VIAUFKS-tplnr.
*   wa_itab-plnbez = wa_VIAUFKS-plnbez.
*   wa_itab-GAMNG = wa_VIAUFKS-GAMNG.
*   wa_itab-Gmein = wa_VIAUFKS-gmein.
*    wa_itab-maktx = wa_material-maktx.
*    wa_itab-verpr = wa_material-verpr.
*    wa_itab-waers = 'IDR'.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
*    'WERKS' 'RESBD' 'WERKS' '' '' '' '' '' '' '' '' '' '' '',
*    'GSTRP' 'CAUFVD' 'GSTRP' '' '' '' '' '' '' '' '' '' '' '',
    'AUFNR' 'VIAUFKS' 'AUFNR' '' '' '' '' '' '' '' '' '' '' '',
    'TPLNR' 'VIAUFKS' 'TPLNR' '' '' '' '' '' '' '' '' '' '' '',
    'PLTXT' 'RIWO1' 'PLTXT' '' '' '' '' '' '' '' '' '' '' '',
    'MATNR' 'RESBD' 'MATNR' '' '' '' '' '' '' '' '' '' '' '',
    'CHARG' 'RESBD' 'CHARG' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '',
*    'KTEXT' 'VIAUFKS' 'KTEXT' '' '' '' '' '' '' '' '' '' '' '',
    'DENMNG'  'RESBD' 'DENMNG' '' '15' 'Quantity' ''
    '' '' '' '' '' 'ERFME' '',
    'ERFME'     'RESBD' 'ERFME' '' '' '' '' '' '' '' '' '' '' '',

    'VERPR'     'MBEW' 'VERPR' '' '' 'Amount'        ''
    '' '' '' '' 'WAERS' '' '',
   'TOT_VERPR' 'MBEW' 'VERPR' '' '' 'Total Amount' 'X'
    '' '' '' '' 'WAERS' '' '',

*    'VERPR'    'MBEW' 'VERPR' '' '' 'Amount'        ''
*    '' '' 'ft_report-waers' '' 'WAERS' '' '',
*    'TOT_VERPR' 'MBEW' 'VERPR' '' '' 'Total Amount' 'X'
*    '' '' 'ft_report-waers' '' 'WAERS' '' '',
    'WAERS' 'CAUFVD' 'WAERS' '' '' '' '' '' '' '' '' '' '' ''.


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
  ld_fieldcat-currency      = fu_waers.
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

  CLEAR ld_sort.
  ld_sort-fieldname = 'WERKS'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
  ld_sort-fieldname = 'GSTRP'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.
  ld_sort-fieldname = 'AUFNR'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  APPEND ld_sort TO fu_sort.
  ld_sort-fieldname = 'TPLNR'.
  ld_sort-up        = 'X'.
  ld_sort-group     = 'UL'.
  APPEND ld_sort TO fu_sort.
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
  Data: l_text(100), l_date1(10), l_date2(10).
  if s_gstrp is initial.
  Else.
    clear: l_text, l_date1, l_date2.
    if not s_gstrp-low is initial.
      write s_gstrp-low to l_date1.
      Concatenate 'Periode : ' l_date1
           into l_text separated by space.
    Endif.
    if not s_gstrp-high is initial.
      write s_gstrp-high to l_date2.
      Concatenate l_text 's/d' l_date2
           into l_text separated by space.
    endif.
  Endif.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING l_text.
  Concatenate 'Plant : ' p_werks
              into l_text separated by space.
  PERFORM f_hdr_line3 USING l_text.
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

  Refresh: i_material, i_viaufks, i_itab, i_matnr.
  Clear: i_material, i_viaufks, i_itab, i_matnr,
         wa_material, wa_viaufks, wa_itab, wa_matnr.
  Refresh: i_AFFHD, i_AFVGD, i_RESBD, i_RIPW0, i_RIPRT1,
           i_IHPAD, i_IHSG, i_IHGNS, i_KBEDP.

  Clear: i_AFFHD, i_AFVGD, i_RESBD, i_RIPW0, i_RIPRT1,
         i_IHPAD, i_IHSG, i_IHGNS, i_KBEDP,
         wa_AFFHD, wa_AFVGD, wa_RESBD, wa_RIPW0, wa_RIPRT1,
         wa_IHPAD, wa_IHSG, wa_IHGNS, wa_KBEDP,
         wa_CAUFVD, wa_ILOA, wa_RIWO1.

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
  break bcsuk.
  Clear: wa_itab, wa_VIAUFKS.
  Loop at i_VIAUFKS into wa_VIAUFKS.
    Perform f_call_pm_order_data_read.
    if sy-subrc eq 0.
      Perform f_isi_itab.
    endif.

    Clear: wa_VIAUFKS.
  Endloop.

  Refresh: i_VIAUFKS, i_material.
  Clear: i_VIAUFKS, i_material.
  Refresh: i_AFFHD, i_AFVGD, i_RESBD, i_RIPW0, i_RIPRT1,
           i_IHPAD, i_IHSG, i_IHGNS, i_KBEDP.

  Clear: i_AFFHD, i_AFVGD, i_RESBD, i_RIPW0, i_RIPRT1,
         i_IHPAD, i_IHSG, i_IHGNS, i_KBEDP,
         wa_AFFHD, wa_AFVGD, wa_RESBD, wa_RIPW0, wa_RIPRT1,
         wa_IHPAD, wa_IHSG, wa_IHGNS, wa_KBEDP,
         wa_CAUFVD, wa_ILOA, wa_RIWO1.

  DELETE ADJACENT DUPLICATES FROM i_matnr comparing matnr.

* begin of deletion sap_dev02/eka - 9 April 2007
*   Select b~werks a~matnr a~mtart d~maktx c~verpr
*         INTO CORRESPONDING FIELDS OF TABLE i_material
*         from mara as a join marc as b on b~matnr = a~matnr
*                        join mbew as c on c~matnr = a~matnr
*                        join makt as d on d~matnr = a~matnr
*         For All entries in i_matnr
*         where a~mtart in s_mtart and
*               a~matnr = i_matnr-matnr and
*               b~werks = p_werks and
*               c~bwkey = p_werks and
*               ( d~spras = 'EN' or d~spras = 'E' ).
* end of deletion sap_dev02/eka - 9 April 2007

* begin of insertion sap_dev02/eka - 9 April 2007
* add field PEINH
  Select b~werks a~matnr a~mtart d~maktx c~verpr c~peinh c~bwtar
      INTO CORRESPONDING FIELDS OF TABLE i_material
      from mara as a join marc as b on b~matnr = a~matnr
                     join mbew as c on c~matnr = a~matnr
                     join makt as d on d~matnr = a~matnr
      For All entries in i_matnr
      where a~mtart in s_mtart and
            a~matnr = i_matnr-matnr and
            b~werks = p_werks and
            c~bwkey = p_werks and
            ( d~spras = 'EN' or d~spras = 'E' ).

  sort i_material by werks matnr bwtar.
* end of insertion sap_dev02/eka - 9 April 2007

  Loop at i_itab into wa_itab.
    Clear: wa_material.
    Read table i_material into wa_material with
        key werks = wa_itab-werks
            matnr = wa_itab-matnr
            bwtar = wa_itab-charg
        Binary Search.
    if sy-subrc eq 0.
      wa_itab-maktx = wa_material-maktx.
*      wa_itab-verpr = wa_material-verpr.   "delete sap_dev02-eka
      wa_itab-verpr = wa_material-verpr / wa_material-peinh. "ins sap_dev02-eka
    Else.
      Delete i_itab.
      continue.
    endif.
    wa_itab-tot_verpr = wa_itab-erfmg * wa_itab-verpr.
    modify i_itab from wa_itab.
    Clear: wa_itab.
  Endloop.


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
*&      Form  f_format_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_BUDAT  text
*      <--FC_BUDAT  text
*----------------------------------------------------------------------*
FORM f_format_date USING    fu_budat
                   CHANGING fc_budat.

*  READ TABLE t_user INDEX 1.
*  CASE t_user-datfm.
*    WHEN 'DD.MM.YYYY'.
*      CONCATENATE fu_budat+6(2) fu_budat+4(2) fu_budat+(4)
*                  INTO fc_budat.
*    WHEN 'MM/DD/YYYY' OR 'MM-DD-YYYY'.
*      CONCATENATE fu_budat+4(2) fu_budat+6(2) fu_budat+(4)
*                  INTO fc_budat.
*    WHEN 'YYYY.MM.DD' OR 'YYYY/MM/DD' OR 'YYYY-MM-DD'.
*      CONCATENATE fu_budat+(4) fu_budat+4(2) fu_budat+6(2)
*                  INTO fc_budat.
*  ENDCASE.

ENDFORM.                    " f_format_date
*&---------------------------------------------------------------------*
*&      Form  f_call_pm_order_data_read
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_call_pm_order_data_read.
  Refresh: i_AFFHD, i_AFVGD, i_RESBD, i_RIPW0, i_RIPRT1,
           i_IHPAD, i_IHSG, i_IHGNS, i_KBEDP.

  Clear: i_AFFHD, i_AFVGD, i_RESBD, i_RIPW0, i_RIPRT1,
         i_IHPAD, i_IHSG, i_IHGNS, i_KBEDP,
         wa_AFFHD, wa_AFVGD, wa_RESBD, wa_RIPW0, wa_RIPRT1,
         wa_IHPAD, wa_IHSG, wa_IHGNS, wa_KBEDP,
         wa_CAUFVD, wa_ILOA, wa_RIWO1.
  CALL FUNCTION 'ZZPM_ORDER_DATA_READ'
    EXPORTING
        ORDER_NUMBER = wa_viaufks-aufnr
*         VALUE(CALL_FROM_NOTIF) LIKE  SY-DATAR OPTIONAL
    IMPORTING
        WCAUFVD = wa_CAUFVD
        WILOA   = wa_ILOA
        WRIWO1  = wa_RIWO1
    TABLES
        IAFFHD = i_AFFHD
        IAFVGD = i_AFVGD
        IRESBD = i_RESBD
        IRIPW0 = i_RIPW0
        OP_PRINT_TAB = i_RIPRT1
        IHPAD_TAB = i_IHPAD
        IHSG_TAB = i_IHSG
        IHGNS_TAB = i_IHGNS
        KBEDP_TAB = i_KBEDP
    EXCEPTIONS
        ORDER_NOT_FOUND = 1.

endform.                    " f_call_pm_order_data_read
*&---------------------------------------------------------------------*
*&      Form  f_isi_itab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_isi_itab.

*          maktx like makt-maktx,
*          verpr like mbew-verpr,
  Loop at i_resbd into wa_resbd.
    if wa_resbd-posnr = '0000'.
      continue.
    endif.
    if wa_resbd-denmng = 0.
      continue.
    endif.
    wa_itab-werks = wa_caufvd-werks.
    wa_itab-aufnr = wa_caufvd-aufnr.
    wa_itab-auart = wa_caufvd-auart.
    wa_itab-gstrp = wa_caufvd-gstrp.
    wa_itab-tplnr = wa_RIWO1-tplnr.
    wa_itab-pltxt = wa_RIWO1-pltxt.
    wa_itab-plnbez = wa_caufvd-plnbez.
    wa_itab-ktext = wa_caufvd-ktext.
    wa_itab-waers = wa_caufvd-waers.
    wa_itab-matnr = wa_resbd-matnr.
    wa_itab-erfmg = wa_resbd-erfmg.
    wa_itab-erfme = wa_resbd-erfme.
    wa_itab-denmng = wa_resbd-denmng.
    wa_itab-charg  = wa_resbd-charg.
    wa_matnr-matnr = wa_resbd-matnr.
    collect wa_matnr into i_matnr.
    append wa_itab to i_itab.
    Clear: wa_itab, wa_resbd, wa_matnr.
  Endloop.

endform.                    " f_isi_itab
