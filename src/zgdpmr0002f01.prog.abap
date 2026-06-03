*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPF01                                        *
*----------------------------------------------------------------------*

FORM f_init_data.

  p_year = s_period-low(4).
  p_month = s_period-low+4(2).

  CASE p_type.
    WHEN 'SPI001'.
      va_text = 'SOLAR'.
      r_eqart-sign = 'I'.
      r_eqart-option = 'EQ'.
      r_eqart-low = 'GENSET'.
      APPEND r_eqart.
      r_eqart-sign = 'I'.
      r_eqart-option = 'EQ'.
      r_eqart-low = 'BOILER'.
      APPEND r_eqart.
      r_eqart-sign = 'I'.
      r_eqart-option = 'EQ'.
      r_eqart-low = 'FORKLIFT'.
      APPEND r_eqart.
      r_eqart-sign = 'I'.
      r_eqart-option = 'EQ'.
      r_eqart-low = 'PEMINJAMAN'.
      APPEND r_eqart.
    WHEN 'SPJ001'.
      va_text = 'LISTRIK'.
      r_eqart-sign = 'I'.
      r_eqart-option = 'EQ'.
      r_eqart-low = 'ELECTRIC'.
      APPEND r_eqart.
    WHEN 'SPJ002'.
      va_text = 'AIR'.
      r_eqart-sign = 'I'.
      r_eqart-option = 'EQ'.
      r_eqart-low = 'WATER'.
      APPEND r_eqart.
  ENDCASE.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.

  DATA: l_lfgja  LIKE mardh-lfgja,
        l_lfmon  LIKE mardh-lfmon,
        l_date1  LIKE sy-datum.

  SELECT *
    INTO TABLE t_mondesc
    FROM t247
    WHERE spras = sy-langu.

  CONCATENATE p_year p_month '01' INTO l_date1.
  SUBTRACT 1 FROM l_date1.
  l_lfgja = l_date1(4).
  l_lfmon = l_date1+4(2).

** Material Solar
  SELECT matnr
    INTO TABLE t_mara
    FROM mara
    WHERE extwg = p_type.

  SELECT tplnr pltxt objnr swerk eqart
    INTO CORRESPONDING FIELDS OF TABLE t_iflo
    FROM iflo
*    WHERE tplnr  IN s_tplnr AND
    WHERE swerk =  p_swerk AND
          eqart IN r_eqart.

  IF NOT t_mara[] IS INITIAL.
** Stock Awal
    SELECT lfgja lfmon labst
      INTO TABLE t_mardh
      FROM mardh
      FOR ALL ENTRIES IN t_mara
      WHERE matnr = t_mara-matnr  AND
            werks = p_swerk       AND
            lfgja = p_year        AND
            lfmon LE 11.
    SELECT lfgja lfmon labst
      APPENDING TABLE t_mardh
      FROM mardh
      FOR ALL ENTRIES IN t_mara
      WHERE matnr = t_mara-matnr  AND
            werks = p_swerk       AND
            lfgja = l_lfgja       AND
            lfmon = l_lfmon.

** Pembelian
    SELECT mblnr mjahr bwart menge
      INTO TABLE t_mseg
      FROM mseg
      FOR ALL ENTRIES IN t_mara
      WHERE werks = p_swerk        AND
            bwart IN ('101','102') AND
            matnr = t_mara-matnr   AND
            mjahr = p_year.
    IF NOT t_mseg[] IS INITIAL.
      SELECT mblnr mjahr bldat budat
        INTO TABLE t_mkpf
        FROM mkpf
        FOR ALL ENTRIES IN t_mseg
        WHERE mblnr = t_mseg-mblnr AND
              mjahr = p_year.
    ENDIF.
  ENDIF.

  IF NOT t_iflo[] IS INITIAL.
** Pemakaian Solar
    SELECT mpobj psort point pttxt
      INTO CORRESPONDING FIELDS OF TABLE t_imptt
      FROM imptt
      FOR ALL ENTRIES IN t_iflo
      WHERE mpobj = t_iflo-objnr.
    IF NOT t_imptt[] IS INITIAL.
      SELECT point idate mdocm readg recdv recdu
        INTO CORRESPONDING FIELDS OF TABLE t_imrg
        FROM imrg
        FOR ALL ENTRIES IN t_imptt
        WHERE point = t_imptt-point AND
              idate IN s_period.
*              idate IN r_date.
    ENDIF.
  ENDIF.

  IF t_mseg[] IS INITIAL AND
     t_imrg[] IS INITIAL.
    EXIT.
  ENDIF.

  PERFORM f_stock_awal.
  PERFORM f_pembelian.
  PERFORM f_pemakaian.
  PERFORM f_stock_akhir.
  PERFORM f_next_stock_awal.
  SORT t_main BY index pltxt.

ENDFORM.


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

  DATA: ld_jdl(20),
        ld_month1 TYPE i,
        ld_month TYPE i,
        ld_year1(4) TYPE n,
        ld_year TYPE i.

  REFRESH: t_alv_fieldcat.

  DEFINE mac_header.
    read table t_mondesc index &1.
    if sy-subrc eq 0.
      concatenate t_mondesc-ktx ld_year1 into ld_jdl separated by space.
      perform f_fieldcatg using ft_report:
        'USE&1' '' '' '' '20' ld_jdl '' '' '' '' '' '' '' '' '3' ''.
*        'DOC&1' '' '' '' '' 'DOC01' '' '' '' '' '' '' '' '',
    endif.
  END-OF-DEFINITION.

  PERFORM f_fieldcatg USING ft_report:
    'INDEX' '' '' 'X' '' 'Index' '' '' '' '' '' '' '' '' '' '',
    'TPLNR' '' '' '' '40' '' '' '' '' '' '' '' '' '' '' 'X',
    'PLTXT' '' '' '' '20' '' '' '' '' '' '' '' '' '' '' 'X',
*    'OBJNR' 'IFLO' 'OBJNR' '' '' '' '' '' '' '' '' '' '' '' '',
    'RECDU' '' '' '' '4' 'UNIT' '' '' '' '' '' '' '' '' '' 'X'.

*  mac_header : 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12.

  IF s_period-high IS INITIAL.
    ld_month = 1.
  ELSE.
    ld_year = s_period-high(4) - s_period-low(4).
    ld_month = ( s_period-high+4(2) - s_period-low+4(2) + 1 ) +
               ( ld_year * 12 ).
  ENDIF.
  IF ld_month GT 12.
    ld_month = 12.
  ENDIF.
  ld_month1 = s_period-low+4(2).
  ld_year1 = s_period-low(4).
  DO ld_month TIMES.
    CASE ld_month1.
      WHEN 1.
        mac_header : 1.
      WHEN 2.
        mac_header : 2.
      WHEN 3.
        mac_header : 3.
      WHEN 4.
        mac_header : 4.
      WHEN 5.
        mac_header : 5.
      WHEN 6.
        mac_header : 6.
      WHEN 7.
        mac_header : 7.
      WHEN 8.
        mac_header : 8.
      WHEN 9.
        mac_header : 9.
      WHEN 10.
        mac_header : 10.
      WHEN 11.
        mac_header : 11.
      WHEN 12.
        mac_header : 12.
    ENDCASE.
    ADD 1 TO ld_month1.
    IF ld_month1 GT 12.
      ld_month1 = ld_month1 - 12.
      ADD 1 TO ld_year1.
    ENDIF.
  ENDDO.

  PERFORM f_fieldcatg USING ft_report:
    'TOTAL' '' '' '' '20' 'Total' '' '' '' '' '' '' '' '' '3' ''.

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
                          value(fu_decimals_out)
                          value(fu_key).

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
  ld_fieldcat-decimals_out  = fu_decimals_out.
  ld_fieldcat-key           = fu_key.
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
*  ld_sort-fieldname = 'INDEX'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
*  APPEND ld_sort TO fu_sort.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'TPLNR'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  APPEND ld_sort TO fu_sort.

*  CLEAR ld_sort.
*  ld_sort-fieldname = 'PLTXT'.
*  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  APPEND ld_sort TO fu_sort.

ENDFORM.



*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  DATA : l_header2(35),
         l_header3(30),
         l_judul(100),
         l_from(10),
         l_to(10).

  CONCATENATE 'Laporan Pemakaian' va_text INTO l_judul
          SEPARATED BY space.
  CONCATENATE s_period-low+6(2) s_period-low+4(2) s_period-low(4)
        INTO l_from SEPARATED BY '/'.
  CONCATENATE s_period-high+6(2) s_period-high+4(2) s_period-high(4)
        INTO l_to SEPARATED BY '/'.
  CONCATENATE 'Period :' l_from '-' l_to
        INTO l_header2 SEPARATED BY space.
  CONCATENATE 'Plant :' p_swerk INTO l_header3 SEPARATED BY space.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING l_judul.
  PERFORM f_hdr_line2 USING l_header2.
  PERFORM f_hdr_line3 USING l_header3.
  PERFORM f_hdr_uline.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM F_END_OF_LIST                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_end_of_list.
  SKIP.
  WRITE: /5(20) 'Plant Manager' CENTERED,
        100(20) 'Enginering Manager' CENTERED.
  SKIP 3.
  WRITE: /5(20) p_text1 CENTERED,
        100(20) p_text2 CENTERED.
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
  IF t_mseg[] IS INITIAL AND t_imrg[] IS INITIAL.
    MESSAGE i000(zgdpm) WITH 'No Data'.
    EXIT.
  ENDIF.
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
*&      Form  f_hitung_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hitung_detail.

  DATA : va_flstr(22),
         va_use99 TYPE wisp_promo_amount.

  CLEAR : va_flstr, va_use99.
  CALL FUNCTION 'FLTP_CHAR_CONVERSION'
       EXPORTING
            decim = 3
*            input = t_imrg-readg
            input = t_imrg-recdv
            ivalu = 'X'
       IMPORTING
            flstr = va_flstr.

  REPLACE ',' WITH '.' INTO va_flstr.
  va_use99 = va_flstr.
*{   REPLACE        P01K900131                                        1
*\  MULTIPLY va_use99 BY 1000.

*}   REPLACE
  CASE t_imrg-idate+4(2).
    WHEN '01'.
      t_main-use1 = t_main-use1 + va_use99.
    WHEN '02'.
      t_main-use2 = t_main-use2 + va_use99.
    WHEN '03'.
      t_main-use3 = t_main-use3 + va_use99.
    WHEN '04'.
      t_main-use4 = t_main-use4 + va_use99.
    WHEN '05'.
      t_main-use5 = t_main-use5 + va_use99.
    WHEN '06'.
      t_main-use6 = t_main-use6 + va_use99.
    WHEN '07'.
      t_main-use7 = t_main-use7 + va_use99.
    WHEN '08'.
      t_main-use8 = t_main-use8 + va_use99.
    WHEN '09'.
      t_main-use9 = t_main-use9 + va_use99.
    WHEN '10'.
      t_main-use10 = t_main-use10 + va_use99.
    WHEN '11'.
      t_main-use11 = t_main-use11 + va_use99.
    WHEN '12'.
      t_main-use12 = t_main-use12 + va_use99.
  ENDCASE.
  t_main-recdu = t_imrg-recdu.
  t_main-total = t_main-use1 + t_main-use2 + t_main-use3 +
                 t_main-use4 + t_main-use5 + t_main-use6 +
                 t_main-use7 + t_main-use8 + t_main-use9 +
                 t_main-use10 + t_main-use11 + t_main-use12.

ENDFORM.                    " f_hitung

*&---------------------------------------------------------------------*
*&      Form  f_total_boiler
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_total_boiler.
  wa_boiler-use1 = wa_boiler-use1 + t_main-use1.
  wa_boiler-use2 = wa_boiler-use2 + t_main-use2.
  wa_boiler-use3 = wa_boiler-use3 + t_main-use3.
  wa_boiler-use4 = wa_boiler-use4 + t_main-use4.
  wa_boiler-use5 = wa_boiler-use5 + t_main-use5.
  wa_boiler-use6 = wa_boiler-use6 + t_main-use6.
  wa_boiler-use7 = wa_boiler-use7 + t_main-use7.
  wa_boiler-use8 = wa_boiler-use8 + t_main-use8.
  wa_boiler-use9 = wa_boiler-use9 + t_main-use9.
  wa_boiler-use10 = wa_boiler-use10 + t_main-use10.
  wa_boiler-use11 = wa_boiler-use11 + t_main-use11.
  wa_boiler-use12 = wa_boiler-use12 + t_main-use12.
  wa_boiler-total = wa_boiler-total + t_main-total.
  wa_solar-use1 = wa_solar-use1 + t_main-use1.
  wa_solar-use2 = wa_solar-use2 + t_main-use2.
  wa_solar-use3 = wa_solar-use3 + t_main-use3.
  wa_solar-use4 = wa_solar-use4 + t_main-use4.
  wa_solar-use5 = wa_solar-use5 + t_main-use5.
  wa_solar-use6 = wa_solar-use6 + t_main-use6.
  wa_solar-use7 = wa_solar-use7 + t_main-use7.
  wa_solar-use8 = wa_solar-use8 + t_main-use8.
  wa_solar-use9 = wa_solar-use9 + t_main-use9.
  wa_solar-use10 = wa_solar-use10 + t_main-use10.
  wa_solar-use11 = wa_solar-use11 + t_main-use11.
  wa_solar-use12 = wa_solar-use12 + t_main-use12.
  wa_solar-total = wa_solar-total + t_main-total.
ENDFORM.                    " f_total_boiler

*&---------------------------------------------------------------------*
*&      Form  f_total_genset
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_total_genset.
  wa_genset-use1 = wa_genset-use1 + t_main-use1.
  wa_genset-use2 = wa_genset-use2 + t_main-use2.
  wa_genset-use3 = wa_genset-use3 + t_main-use3.
  wa_genset-use4 = wa_genset-use4 + t_main-use4.
  wa_genset-use5 = wa_genset-use5 + t_main-use5.
  wa_genset-use6 = wa_genset-use6 + t_main-use6.
  wa_genset-use7 = wa_genset-use7 + t_main-use7.
  wa_genset-use8 = wa_genset-use8 + t_main-use8.
  wa_genset-use9 = wa_genset-use9 + t_main-use9.
  wa_genset-use10 = wa_genset-use10 + t_main-use10.
  wa_genset-use11 = wa_genset-use11 + t_main-use11.
  wa_genset-use12 = wa_genset-use12 + t_main-use12.
  wa_genset-total = wa_genset-total + t_main-total.
  wa_solar-use1 = wa_solar-use1 + t_main-use1.
  wa_solar-use2 = wa_solar-use2 + t_main-use2.
  wa_solar-use3 = wa_solar-use3 + t_main-use3.
  wa_solar-use4 = wa_solar-use4 + t_main-use4.
  wa_solar-use5 = wa_solar-use5 + t_main-use5.
  wa_solar-use6 = wa_solar-use6 + t_main-use6.
  wa_solar-use7 = wa_solar-use7 + t_main-use7.
  wa_solar-use8 = wa_solar-use8 + t_main-use8.
  wa_solar-use9 = wa_solar-use9 + t_main-use9.
  wa_solar-use10 = wa_solar-use10 + t_main-use10.
  wa_solar-use11 = wa_solar-use11 + t_main-use11.
  wa_solar-use12 = wa_solar-use12 + t_main-use12.
  wa_solar-total = wa_solar-total + t_main-total.
ENDFORM.                    " f_total_genset

*&---------------------------------------------------------------------*
*&      Form  f_stock_awal
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_stock_awal.

  CLEAR t_main.
  SORT t_mardh BY lfgja lfmon.

  LOOP AT t_mardh.
    AT END OF lfmon.
      SUM.
      CASE t_mardh-lfmon.
        WHEN 12.
          t_main-use1 = t_mardh-labst.
        WHEN 01.
          t_main-use2 = t_mardh-labst.
        WHEN 02.
          t_main-use3 = t_mardh-labst.
        WHEN 03.
          t_main-use4 = t_mardh-labst.
        WHEN 04.
          t_main-use5 = t_mardh-labst.
        WHEN 05.
          t_main-use6 = t_mardh-labst.
        WHEN 06.
          t_main-use7 = t_mardh-labst.
        WHEN 07.
          t_main-use8 = t_mardh-labst.
        WHEN 08.
          t_main-use9 = t_mardh-labst.
        WHEN 09.
          t_main-use10 = t_mardh-labst.
        WHEN 10.
          t_main-use11 = t_mardh-labst.
        WHEN 11.
          t_main-use12 = t_mardh-labst.
      ENDCASE.
    ENDAT.
  ENDLOOP.
*  t_main-total = t_main-USE1 + t_main-USE2 + t_main-USE3 +
*                 t_main-USE4 + t_main-USE5 + t_main-USE6 +
*                 t_main-USE7 + t_main-USE8 + t_main-USE9 +
*                 t_main-use10 + t_main-use11 + t_main-use12.
  PERFORM f_hitung_stock_akhir.
  CLEAR wa_akhir-total.

  t_main-index = 1.
  t_main-tplnr = 'STOCK AWAL'.
  t_main-info = 'C70'.
  APPEND t_main. CLEAR: t_main.

ENDFORM.                    " f_stock_awal

*&---------------------------------------------------------------------*
*&      Form  f_pembelian
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pembelian.

  CLEAR t_main.
  SORT t_mseg BY mblnr mjahr.
  SORT t_mkpf BY mblnr mjahr.

  LOOP AT t_mseg.
    IF t_mseg-bwart = '102'.
      MULTIPLY t_mseg-bwart BY -1.
    ENDIF.
    READ TABLE t_mkpf WITH KEY mblnr = t_mseg-mblnr
                               mjahr = t_mseg-mjahr.
    IF sy-subrc NE 0.
      CONCATENATE p_year '12' '01' INTO t_mkpf-budat.
    ENDIF.

    CASE t_mkpf-budat+4(2).
      WHEN 01.
        t_main-use1 = t_main-use1 + t_mseg-menge.
      WHEN 02.
        t_main-use2 = t_main-use2 + t_mseg-menge.
      WHEN 03.
        t_main-use3 = t_main-use3 + t_mseg-menge.
      WHEN 04.
        t_main-use4 = t_main-use4 + t_mseg-menge.
      WHEN 05.
        t_main-use5 = t_main-use5 + t_mseg-menge.
      WHEN 06.
        t_main-use6 = t_main-use6 + t_mseg-menge.
      WHEN 07.
        t_main-use7 = t_main-use7 + t_mseg-menge.
      WHEN 08.
        t_main-use8 = t_main-use8 + t_mseg-menge.
      WHEN 09.
        t_main-use9 = t_main-use9 + t_mseg-menge.
      WHEN 10.
        t_main-use10 = t_main-use10 + t_mseg-menge.
      WHEN 11.
        t_main-use11 = t_main-use11 + t_mseg-menge.
      WHEN 12.
        t_main-use12 = t_main-use12 + t_mseg-menge.
    ENDCASE.
  ENDLOOP.
  t_main-total = t_main-use1 + t_main-use2 + t_main-use3 +
                 t_main-use4 + t_main-use5 + t_main-use6 +
                 t_main-use7 + t_main-use8 + t_main-use9 +
                 t_main-use10 + t_main-use11 + t_main-use12.
  PERFORM f_hitung_stock_akhir.

  t_main-index = 2.
  CONCATENATE 'PEMBELIAN' va_text INTO t_main-tplnr SEPARATED BY space.
  t_main-info = 'C40'.
  APPEND t_main. CLEAR: t_main.

ENDFORM.                    " f_pembelian

*&---------------------------------------------------------------------*
*&      Form  f_pemakaian
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pemakaian.

  DATA: l_index1(6) TYPE n,
        l_index2(6) TYPE n,
        l_index3(6) TYPE n,
        l_index4(6) TYPE n,
        l_tabix1 LIKE sy-tabix,
        l_tabix2 LIKE sy-tabix,
        sw1(1),sw2(1),sw3(1),sw4(1),sw5(1),sw6(1),sw7(1).

  SORT t_iflo BY tplnr objnr.
  SORT t_imptt BY mpobj psort point.
  SORT t_imrg BY point idate.

  LOOP AT t_iflo.

    READ TABLE t_imptt WITH KEY mpobj = t_iflo-objnr.
    CHECK sy-subrc = 0.
    l_tabix1 = sy-tabix.

    ADD 10 TO l_index1.
    l_index2 = l_index1 + 1.
    l_index3 = l_index2 + 3.
    l_index4 = l_index3 + 3.

    LOOP AT t_imptt FROM l_tabix1.

      READ TABLE t_imrg WITH KEY point = t_imptt-point.
      CHECK sy-subrc = 0.
      l_tabix2 = sy-tabix.

      IF t_imptt-mpobj NE t_iflo-objnr.
        CLEAR : sw1,sw2,sw3,sw4,sw5,sw6,sw7.
        EXIT.
      ENDIF.

      LOOP AT t_imrg FROM l_tabix2.
        IF t_imrg-point NE t_imptt-point.
          EXIT.
        ENDIF.
        PERFORM f_hitung_detail.
      ENDLOOP.

      IF t_iflo-tplnr IN s_tplnr.
*        IF t_imptt-psort CP '*BOILER*'.
        IF t_iflo-eqart = 'BOILER'.
          PERFORM f_total_boiler.
          IF sw1 IS INITIAL.
*          t_main-index = l_index1.
            t_main-index = 10.
            CONCATENATE t_iflo-tplnr t_iflo-pltxt
                INTO t_main-tplnr SEPARATED BY space.
            t_main-pltxt = t_imptt-psort.
            t_main-objnr = t_imptt-mpobj.
            APPEND t_main. CLEAR t_main.
          ELSE.
*          t_main-index = l_index2.
            t_main-index = 10.
            t_main-pltxt = t_imptt-psort.
            t_main-objnr = t_imptt-mpobj.
            APPEND t_main. CLEAR t_main.
          ENDIF.
          sw1 = '1'.
*        ELSEIF t_imptt-psort CP '*GENSET*'.
        ELSEIF t_iflo-eqart = 'GENSET'.
          PERFORM f_total_genset.
          IF sw2 IS INITIAL.
*          t_main-index = l_index1.
            t_main-index = 20.
            CONCATENATE t_iflo-tplnr t_iflo-pltxt
                INTO t_main-tplnr SEPARATED BY space.
            t_main-pltxt = t_imptt-psort.
            t_main-objnr = t_imptt-mpobj.
            APPEND t_main. CLEAR t_main.
          ELSE.
*          t_main-index = l_index3.
            t_main-index = 20.
            t_main-pltxt = t_imptt-psort.
            t_main-objnr = t_imptt-mpobj.
            APPEND t_main. CLEAR t_main.
          ENDIF.
          sw2 = '1'.
*        ELSEIF t_imptt-psort CP '*FORKLIF*'.
        ELSEIF t_iflo-eqart = 'FORKLIFT'.
          PERFORM f_total_forklift.
          IF sw3 IS INITIAL.
*          t_main-index = l_index1.
            t_main-index = 30.
            CONCATENATE t_iflo-tplnr t_iflo-pltxt
                INTO t_main-tplnr SEPARATED BY space.
            t_main-pltxt = t_imptt-psort.
            t_main-objnr = t_imptt-mpobj.
            APPEND t_main. CLEAR t_main.
          ELSE.
*          t_main-index = l_index4.
            t_main-index = 30.
            t_main-pltxt = t_imptt-psort.
            t_main-objnr = t_imptt-mpobj.
            APPEND t_main. CLEAR t_main.
          ENDIF.
          sw3 = '1'.
        ELSEIF t_iflo-eqart = 'PEMINJAMAN'.
          PERFORM f_total_peminjaman.
          IF sw7 IS INITIAL.
*          t_main-index = l_index1.
            t_main-index = 40.
            CONCATENATE t_iflo-tplnr t_iflo-pltxt
                INTO t_main-tplnr SEPARATED BY space.
            t_main-pltxt = t_imptt-psort.
            t_main-objnr = t_imptt-mpobj.
            APPEND t_main. CLEAR t_main.
          ELSE.
*          t_main-index = l_index4.
            t_main-index = 40.
            t_main-pltxt = t_imptt-psort.
            t_main-objnr = t_imptt-mpobj.
            APPEND t_main. CLEAR t_main.
          ENDIF.
          sw7 = '1'.
        ELSEIF t_iflo-eqart = 'WATER'.
          PERFORM f_total_water.
          IF sw4 IS INITIAL.
            t_main-index = 10.
            CONCATENATE t_iflo-tplnr t_iflo-pltxt
                INTO t_main-tplnr SEPARATED BY space.
            t_main-pltxt = t_imptt-psort.
            t_main-objnr = t_imptt-mpobj.
            APPEND t_main. CLEAR t_main.
          ELSE.
            t_main-index = 10.
            t_main-pltxt = t_imptt-psort.
            t_main-objnr = t_imptt-mpobj.
            APPEND t_main. CLEAR t_main.
          ENDIF.
          sw4 = '1'.
        ELSEIF t_iflo-eqart = 'ELECTRIC'.
          PERFORM f_total_electric.
          IF sw5 IS INITIAL.
            t_main-index = 10.
            CONCATENATE t_iflo-tplnr t_iflo-pltxt
                INTO t_main-tplnr SEPARATED BY space.
            t_main-pltxt = t_imptt-psort.
            t_main-objnr = t_imptt-mpobj.
            APPEND t_main. CLEAR t_main.
          ELSE.
            t_main-index = 10.
            t_main-pltxt = t_imptt-psort.
            t_main-objnr = t_imptt-mpobj.
            APPEND t_main. CLEAR t_main.
          ENDIF.
          sw5 = '1'.
        ELSE.
          PERFORM f_total_other1.
          IF sw6 IS INITIAL.
            t_main-index = 60.
            CONCATENATE t_iflo-tplnr t_iflo-pltxt
                INTO t_main-tplnr SEPARATED BY space.
            t_main-pltxt = t_imptt-psort.
            t_main-objnr = t_imptt-mpobj.
            APPEND t_main. CLEAR t_main.
          ELSE.
            t_main-index = 60.
            t_main-pltxt = t_imptt-psort.
            t_main-objnr = t_imptt-mpobj.
            APPEND t_main. CLEAR t_main.
          ENDIF.
          sw6 = '1'.
        ENDIF.
      ELSE.
        PERFORM f_total_other.
        CLEAR t_main.
      ENDIF.

    ENDLOOP.

  ENDLOOP.

  IF NOT wa_boiler-total IS INITIAL.
    MOVE-CORRESPONDING wa_boiler TO t_main.
    l_index2 = l_index2 + 1.
    t_main-index = 19.
    t_main-tplnr = ' ====> TOTAL BOILER'.
    t_main-info = 'C30'.
    APPEND t_main. CLEAR: t_main, wa_boiler.
  ENDIF.

  IF NOT wa_genset-total IS INITIAL.
    MOVE-CORRESPONDING wa_genset TO t_main.
    l_index3 = l_index3 + 1.
    t_main-index = 29.
    t_main-tplnr = ' ====> TOTAL GENSET'.
    t_main-info = 'C30'.
    APPEND t_main. CLEAR: t_main, wa_genset.
  ENDIF.

  IF NOT wa_forklift-total IS INITIAL.
    MOVE-CORRESPONDING wa_forklift TO t_main.
    l_index4 = l_index4 + 1.
    t_main-index = 39.
    t_main-tplnr = ' ====> TOTAL FORKLIFT'.
    t_main-info = 'C30'.
    APPEND t_main. CLEAR: t_main, wa_forklift.
  ENDIF.

  IF NOT wa_peminjaman-total IS INITIAL.
    MOVE-CORRESPONDING wa_peminjaman TO t_main.
    l_index4 = l_index4 + 1.
    t_main-index = 49.
    t_main-tplnr = ' ====> TOTAL PEMINJAMAN'.
    t_main-info = 'C30'.
    APPEND t_main. CLEAR: t_main, wa_peminjaman.
  ENDIF.

  IF NOT wa_water-total IS INITIAL.
    MOVE-CORRESPONDING wa_water TO t_main.
    l_index4 = l_index4 + 1.
    t_main-index = 19.
    t_main-tplnr = ' ====> TOTAL AIR'.
    t_main-info = 'C30'.
    APPEND t_main. CLEAR: t_main, wa_water.
  ENDIF.

  IF NOT wa_electric-total IS INITIAL.
    MOVE-CORRESPONDING wa_electric TO t_main.
    l_index4 = l_index4 + 1.
    t_main-index = 19.
    t_main-tplnr = ' ====> TOTAL LISTRIK'.
    t_main-info = 'C30'.
    APPEND t_main. CLEAR: t_main, wa_electric.
  ENDIF.

  IF NOT wa_other1-total IS INITIAL.
    MOVE-CORRESPONDING wa_other1 TO t_main.
    l_index4 = l_index4 + 1.
    t_main-index = 69.
    t_main-tplnr = ' ====> TOTAL OTHER'.
    t_main-info = 'C30'.
    APPEND t_main. CLEAR: t_main, wa_other1.
  ENDIF.

  IF NOT wa_other-total IS INITIAL.
    MOVE-CORRESPONDING wa_other TO t_main.
    t_main-index = 79.
    t_main-tplnr = ' ====> Pemakaian Lain-lain'.
    t_main-info = 'C30'.
    APPEND t_main. CLEAR: t_main, wa_forklift.
  ENDIF.

  MOVE-CORRESPONDING wa_solar TO t_main.
  PERFORM f_hitung_stock_akhir1.
  CLEAR wa_akhir-total.

  l_index4 = l_index4 + 1.
*  t_main-index = l_index4.
  t_main-index = 99.
  CONCATENATE ' ==> TOTAL PEMAKAIAN' va_text INTO t_main-tplnr
        SEPARATED BY space .
  t_main-info = 'C50'.
  APPEND t_main. CLEAR: t_main, wa_solar.
*      l_index3 = l_index3 + 1.
*      t_main-index = l_index3.
*      APPEND t_main.
*  ENDIF.
  CLEAR : t_main, l_index2, l_index3.

ENDFORM.                    " f_pemakaian

*&---------------------------------------------------------------------*
*&      Form  f_stock_akhir
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_stock_akhir.

  wa_akhir-index = 999999.
  wa_akhir-tplnr = 'STOCK AKHIR'.
  wa_akhir-info = 'C71'.
  APPEND wa_akhir TO t_main. CLEAR: t_main.

ENDFORM.                    " f_stock_akhir

*&---------------------------------------------------------------------*
*&      Form  f_hitung_stock_akhir
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hitung_stock_akhir.

  wa_akhir-use1 = wa_akhir-use1 + t_main-use1.
  wa_akhir-use2 = wa_akhir-use2 + t_main-use2.
  wa_akhir-use3 = wa_akhir-use3 + t_main-use3.
  wa_akhir-use4 = wa_akhir-use4 + t_main-use4.
  wa_akhir-use5 = wa_akhir-use5 + t_main-use5.
  wa_akhir-use6 = wa_akhir-use6 + t_main-use6.
  wa_akhir-use7 = wa_akhir-use7 + t_main-use7.
  wa_akhir-use8 = wa_akhir-use8 + t_main-use8.
  wa_akhir-use9 = wa_akhir-use9 + t_main-use9.
  wa_akhir-use10 = wa_akhir-use10 + t_main-use10.
  wa_akhir-use11 = wa_akhir-use11 + t_main-use11.
  wa_akhir-use12 = wa_akhir-use12 + t_main-use12.
  wa_akhir-total = wa_akhir-total + t_main-total.

ENDFORM.                    " f_hitung_stock_akhir

*&---------------------------------------------------------------------*
*&      Form  f_hitung_stock_akhir1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_hitung_stock_akhir1.

  wa_akhir-use1 = wa_akhir-use1 - t_main-use1.
  wa_akhir-use2 = wa_akhir-use2 - t_main-use2.
  wa_akhir-use3 = wa_akhir-use3 - t_main-use3.
  wa_akhir-use4 = wa_akhir-use4 - t_main-use4.
  wa_akhir-use5 = wa_akhir-use5 - t_main-use5.
  wa_akhir-use6 = wa_akhir-use6 - t_main-use6.
  wa_akhir-use7 = wa_akhir-use7 - t_main-use7.
  wa_akhir-use8 = wa_akhir-use8 - t_main-use8.
  wa_akhir-use9 = wa_akhir-use9 - t_main-use9.
  wa_akhir-use10 = wa_akhir-use10 - t_main-use10.
  wa_akhir-use11 = wa_akhir-use11 - t_main-use11.
  wa_akhir-use12 = wa_akhir-use12 - t_main-use12.
  wa_akhir-total = wa_akhir-total - t_main-total.

ENDFORM.                    " f_hitung_stock_akhir1

*&---------------------------------------------------------------------*
*&      Form  f_next_stock_awal
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_next_stock_awal.

  DATA: lwa_awal   LIKE t_main,
        lwa_akhir  LIKE t_main,
        l_month(2) TYPE n,
        l_loop     TYPE i,
        ld_year TYPE i.

  READ TABLE t_main WITH KEY INDEX = 1
                    INTO lwa_awal.
  READ TABLE t_main WITH KEY INDEX = 999999
                    INTO lwa_akhir.

  IF s_period-high IS INITIAL.
    l_loop = 1.
  ELSE.
    ld_year = s_period-high(4) - s_period-low(4).
    l_loop = ( s_period-high+4(2) - s_period-low+4(2) ) +
             ( ld_year * 12 ).
  ENDIF.
  IF l_loop GT 12.
    l_loop = 12.
  ENDIF.
  l_month = s_period-low+4(2).
  DO l_loop TIMES.
    ADD 1 TO l_month.
    IF l_month GT 12.
      l_month = l_month - 12.
    ENDIF.
    CASE l_month.
      WHEN '01'.
        ADD lwa_akhir-use12 TO lwa_awal-use1.
        ADD lwa_awal-use1 TO lwa_akhir-use1.
      WHEN '02'.
        ADD lwa_akhir-use1 TO lwa_awal-use2.
        ADD lwa_awal-use2 TO lwa_akhir-use2.
      WHEN '03'.
        ADD lwa_akhir-use2 TO lwa_awal-use3.
        ADD lwa_awal-use3 TO lwa_akhir-use3.
      WHEN '04'.
        ADD lwa_akhir-use3 TO lwa_awal-use4.
        ADD lwa_awal-use4 TO lwa_akhir-use4.
      WHEN '05'.
        ADD lwa_akhir-use4 TO lwa_awal-use5.
        ADD lwa_awal-use5 TO lwa_akhir-use5.
      WHEN '06'.
        ADD lwa_akhir-use5 TO lwa_awal-use6.
        ADD lwa_awal-use6 TO lwa_akhir-use6.
      WHEN '07'.
        ADD lwa_akhir-use6 TO lwa_awal-use7.
        ADD lwa_awal-use7 TO lwa_akhir-use7.
      WHEN '08'.
        ADD lwa_akhir-use7 TO lwa_awal-use8.
        ADD lwa_awal-use8 TO lwa_akhir-use8.
      WHEN '09'.
        ADD lwa_akhir-use8 TO lwa_awal-use9.
        ADD lwa_awal-use9 TO lwa_akhir-use9.
      WHEN '10'.
        ADD lwa_akhir-use9 TO lwa_awal-use10.
        ADD lwa_awal-use10 TO lwa_akhir-use10.
      WHEN '11'.
        ADD lwa_akhir-use10 TO lwa_awal-use11.
        ADD lwa_awal-use11 TO lwa_akhir-use11.
      WHEN '12'.
        ADD lwa_akhir-use11 TO lwa_awal-use12.
        ADD lwa_awal-use12 TO lwa_akhir-use12.
    ENDCASE.
  ENDDO.

*  ADD 1 TO l_month.
*  CASE l_month.
*    WHEN '01'.
*      ADD lwa_akhir-use12 TO lwa_awal-use1.
*    WHEN '02'.
*      ADD lwa_akhir-use1 TO lwa_awal-use2.
*    WHEN '03'.
*      ADD lwa_akhir-use2 TO lwa_awal-use3.
*    WHEN '04'.
*      ADD lwa_akhir-use3 TO lwa_awal-use4.
*    WHEN '05'.
*      ADD lwa_akhir-use4 TO lwa_awal-use5.
*    WHEN '06'.
*      ADD lwa_akhir-use5 TO lwa_awal-use6.
*    WHEN '07'.
*      ADD lwa_akhir-use6 TO lwa_awal-use7.
*    WHEN '08'.
*      ADD lwa_akhir-use7 TO lwa_awal-use8.
*    WHEN '09'.
*      ADD lwa_akhir-use8 TO lwa_awal-use9.
*    WHEN '10'.
*      ADD lwa_akhir-use9 TO lwa_awal-use10.
*    WHEN '11'.
*      ADD lwa_akhir-use10 TO lwa_awal-use11.
*    WHEN '12'.
*      ADD lwa_akhir-use11 TO lwa_awal-use12.
*  ENDCASE.

  LOOP AT t_main.
    IF t_main-index = 1.
      MODIFY t_main FROM lwa_awal
                    TRANSPORTING use1 use2 use3 use4 use5 use6
                                 use7 use8 use9 use10 use11 use12.
    ELSEIF t_main-index = 999999.
      MODIFY t_main FROM lwa_akhir
                    TRANSPORTING use1 use2 use3 use4 use5 use6
                                 use7 use8 use9 use10 use11 use12.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " f_next_stock_awal

*&---------------------------------------------------------------------*
*&      Form  f_total_forklift
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_total_forklift.
  wa_forklift-use1 = wa_forklift-use1 + t_main-use1.
  wa_forklift-use2 = wa_forklift-use2 + t_main-use2.
  wa_forklift-use3 = wa_forklift-use3 + t_main-use3.
  wa_forklift-use4 = wa_forklift-use4 + t_main-use4.
  wa_forklift-use5 = wa_forklift-use5 + t_main-use5.
  wa_forklift-use6 = wa_forklift-use6 + t_main-use6.
  wa_forklift-use7 = wa_forklift-use7 + t_main-use7.
  wa_forklift-use8 = wa_forklift-use8 + t_main-use8.
  wa_forklift-use9 = wa_forklift-use9 + t_main-use9.
  wa_forklift-use10 = wa_forklift-use10 + t_main-use10.
  wa_forklift-use11 = wa_forklift-use11 + t_main-use11.
  wa_forklift-use12 = wa_forklift-use12 + t_main-use12.
  wa_forklift-total = wa_forklift-total + t_main-total.
  wa_solar-use1 = wa_solar-use1 + t_main-use1.
  wa_solar-use2 = wa_solar-use2 + t_main-use2.
  wa_solar-use3 = wa_solar-use3 + t_main-use3.
  wa_solar-use4 = wa_solar-use4 + t_main-use4.
  wa_solar-use5 = wa_solar-use5 + t_main-use5.
  wa_solar-use6 = wa_solar-use6 + t_main-use6.
  wa_solar-use7 = wa_solar-use7 + t_main-use7.
  wa_solar-use8 = wa_solar-use8 + t_main-use8.
  wa_solar-use9 = wa_solar-use9 + t_main-use9.
  wa_solar-use10 = wa_solar-use10 + t_main-use10.
  wa_solar-use11 = wa_solar-use11 + t_main-use11.
  wa_solar-use12 = wa_solar-use12 + t_main-use12.
  wa_solar-total = wa_solar-total + t_main-total.
ENDFORM.                    " f_total_forklift

*&---------------------------------------------------------------------*
*&      Form  f_total_other
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_total_other.
  wa_other-use1 = wa_other-use1 + t_main-use1.
  wa_other-use2 = wa_other-use2 + t_main-use2.
  wa_other-use3 = wa_other-use3 + t_main-use3.
  wa_other-use4 = wa_other-use4 + t_main-use4.
  wa_other-use5 = wa_other-use5 + t_main-use5.
  wa_other-use6 = wa_other-use6 + t_main-use6.
  wa_other-use7 = wa_other-use7 + t_main-use7.
  wa_other-use8 = wa_other-use8 + t_main-use8.
  wa_other-use9 = wa_other-use9 + t_main-use9.
  wa_other-use10 = wa_other-use10 + t_main-use10.
  wa_other-use11 = wa_other-use11 + t_main-use11.
  wa_other-use12 = wa_other-use12 + t_main-use12.
  wa_other-total = wa_other-total + t_main-total.
  wa_solar-use1 = wa_solar-use1 + t_main-use1.
  wa_solar-use2 = wa_solar-use2 + t_main-use2.
  wa_solar-use3 = wa_solar-use3 + t_main-use3.
  wa_solar-use4 = wa_solar-use4 + t_main-use4.
  wa_solar-use5 = wa_solar-use5 + t_main-use5.
  wa_solar-use6 = wa_solar-use6 + t_main-use6.
  wa_solar-use7 = wa_solar-use7 + t_main-use7.
  wa_solar-use8 = wa_solar-use8 + t_main-use8.
  wa_solar-use9 = wa_solar-use9 + t_main-use9.
  wa_solar-use10 = wa_solar-use10 + t_main-use10.
  wa_solar-use11 = wa_solar-use11 + t_main-use11.
  wa_solar-use12 = wa_solar-use12 + t_main-use12.
  wa_solar-total = wa_solar-total + t_main-total.
ENDFORM.                    " f_total_other

*&---------------------------------------------------------------------*
*&      Form  f_total_water
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_total_water.
  wa_water-use1 = wa_water-use1 + t_main-use1.
  wa_water-use2 = wa_water-use2 + t_main-use2.
  wa_water-use3 = wa_water-use3 + t_main-use3.
  wa_water-use4 = wa_water-use4 + t_main-use4.
  wa_water-use5 = wa_water-use5 + t_main-use5.
  wa_water-use6 = wa_water-use6 + t_main-use6.
  wa_water-use7 = wa_water-use7 + t_main-use7.
  wa_water-use8 = wa_water-use8 + t_main-use8.
  wa_water-use9 = wa_water-use9 + t_main-use9.
  wa_water-use10 = wa_water-use10 + t_main-use10.
  wa_water-use11 = wa_water-use11 + t_main-use11.
  wa_water-use12 = wa_water-use12 + t_main-use12.
  wa_water-total = wa_water-total + t_main-total.
  wa_solar-use1 = wa_solar-use1 + t_main-use1.
  wa_solar-use2 = wa_solar-use2 + t_main-use2.
  wa_solar-use3 = wa_solar-use3 + t_main-use3.
  wa_solar-use4 = wa_solar-use4 + t_main-use4.
  wa_solar-use5 = wa_solar-use5 + t_main-use5.
  wa_solar-use6 = wa_solar-use6 + t_main-use6.
  wa_solar-use7 = wa_solar-use7 + t_main-use7.
  wa_solar-use8 = wa_solar-use8 + t_main-use8.
  wa_solar-use9 = wa_solar-use9 + t_main-use9.
  wa_solar-use10 = wa_solar-use10 + t_main-use10.
  wa_solar-use11 = wa_solar-use11 + t_main-use11.
  wa_solar-use12 = wa_solar-use12 + t_main-use12.
  wa_solar-total = wa_solar-total + t_main-total.
ENDFORM.                    " f_total_water

*&---------------------------------------------------------------------*
*&      Form  f_total_electric
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_total_electric.
  wa_electric-use1 = wa_electric-use1 + t_main-use1.
  wa_electric-use2 = wa_electric-use2 + t_main-use2.
  wa_electric-use3 = wa_electric-use3 + t_main-use3.
  wa_electric-use4 = wa_electric-use4 + t_main-use4.
  wa_electric-use5 = wa_electric-use5 + t_main-use5.
  wa_electric-use6 = wa_electric-use6 + t_main-use6.
  wa_electric-use7 = wa_electric-use7 + t_main-use7.
  wa_electric-use8 = wa_electric-use8 + t_main-use8.
  wa_electric-use9 = wa_electric-use9 + t_main-use9.
  wa_electric-use10 = wa_electric-use10 + t_main-use10.
  wa_electric-use11 = wa_electric-use11 + t_main-use11.
  wa_electric-use12 = wa_electric-use12 + t_main-use12.
  wa_electric-total = wa_electric-total + t_main-total.
  wa_solar-use1 = wa_solar-use1 + t_main-use1.
  wa_solar-use2 = wa_solar-use2 + t_main-use2.
  wa_solar-use3 = wa_solar-use3 + t_main-use3.
  wa_solar-use4 = wa_solar-use4 + t_main-use4.
  wa_solar-use5 = wa_solar-use5 + t_main-use5.
  wa_solar-use6 = wa_solar-use6 + t_main-use6.
  wa_solar-use7 = wa_solar-use7 + t_main-use7.
  wa_solar-use8 = wa_solar-use8 + t_main-use8.
  wa_solar-use9 = wa_solar-use9 + t_main-use9.
  wa_solar-use10 = wa_solar-use10 + t_main-use10.
  wa_solar-use11 = wa_solar-use11 + t_main-use11.
  wa_solar-use12 = wa_solar-use12 + t_main-use12.
  wa_solar-total = wa_solar-total + t_main-total.
ENDFORM.                    " f_total_electric

*&---------------------------------------------------------------------*
*&      Form  f_total_other1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_total_other1.
  wa_other1-use1 = wa_other1-use1 + t_main-use1.
  wa_other1-use2 = wa_other1-use2 + t_main-use2.
  wa_other1-use3 = wa_other1-use3 + t_main-use3.
  wa_other1-use4 = wa_other1-use4 + t_main-use4.
  wa_other1-use5 = wa_other1-use5 + t_main-use5.
  wa_other1-use6 = wa_other1-use6 + t_main-use6.
  wa_other1-use7 = wa_other1-use7 + t_main-use7.
  wa_other1-use8 = wa_other1-use8 + t_main-use8.
  wa_other1-use9 = wa_other1-use9 + t_main-use9.
  wa_other1-use10 = wa_other1-use10 + t_main-use10.
  wa_other1-use11 = wa_other1-use11 + t_main-use11.
  wa_other1-use12 = wa_other1-use12 + t_main-use12.
  wa_other1-total = wa_other1-total + t_main-total.
  wa_solar-use1 = wa_solar-use1 + t_main-use1.
  wa_solar-use2 = wa_solar-use2 + t_main-use2.
  wa_solar-use3 = wa_solar-use3 + t_main-use3.
  wa_solar-use4 = wa_solar-use4 + t_main-use4.
  wa_solar-use5 = wa_solar-use5 + t_main-use5.
  wa_solar-use6 = wa_solar-use6 + t_main-use6.
  wa_solar-use7 = wa_solar-use7 + t_main-use7.
  wa_solar-use8 = wa_solar-use8 + t_main-use8.
  wa_solar-use9 = wa_solar-use9 + t_main-use9.
  wa_solar-use10 = wa_solar-use10 + t_main-use10.
  wa_solar-use11 = wa_solar-use11 + t_main-use11.
  wa_solar-use12 = wa_solar-use12 + t_main-use12.
  wa_solar-total = wa_solar-total + t_main-total.
ENDFORM.                    " f_total_other1

*&---------------------------------------------------------------------*
*&      Form  f_total_peminjaman
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_total_peminjaman.
  wa_peminjaman-use1 = wa_peminjaman-use1 + t_main-use1.
  wa_peminjaman-use2 = wa_peminjaman-use2 + t_main-use2.
  wa_peminjaman-use3 = wa_peminjaman-use3 + t_main-use3.
  wa_peminjaman-use4 = wa_peminjaman-use4 + t_main-use4.
  wa_peminjaman-use5 = wa_peminjaman-use5 + t_main-use5.
  wa_peminjaman-use6 = wa_peminjaman-use6 + t_main-use6.
  wa_peminjaman-use7 = wa_peminjaman-use7 + t_main-use7.
  wa_peminjaman-use8 = wa_peminjaman-use8 + t_main-use8.
  wa_peminjaman-use9 = wa_peminjaman-use9 + t_main-use9.
  wa_peminjaman-use10 = wa_peminjaman-use10 + t_main-use10.
  wa_peminjaman-use11 = wa_peminjaman-use11 + t_main-use11.
  wa_peminjaman-use12 = wa_peminjaman-use12 + t_main-use12.
  wa_peminjaman-total = wa_peminjaman-total + t_main-total.
  wa_solar-use1 = wa_solar-use1 + t_main-use1.
  wa_solar-use2 = wa_solar-use2 + t_main-use2.
  wa_solar-use3 = wa_solar-use3 + t_main-use3.
  wa_solar-use4 = wa_solar-use4 + t_main-use4.
  wa_solar-use5 = wa_solar-use5 + t_main-use5.
  wa_solar-use6 = wa_solar-use6 + t_main-use6.
  wa_solar-use7 = wa_solar-use7 + t_main-use7.
  wa_solar-use8 = wa_solar-use8 + t_main-use8.
  wa_solar-use9 = wa_solar-use9 + t_main-use9.
  wa_solar-use10 = wa_solar-use10 + t_main-use10.
  wa_solar-use11 = wa_solar-use11 + t_main-use11.
  wa_solar-use12 = wa_solar-use12 + t_main-use12.
  wa_solar-total = wa_solar-total + t_main-total.
endform.                    " f_total_peminjaman
