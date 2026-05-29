*----------------------------------------------------------------------*
*   INCLUDE ZGHMMALVF01                                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f_gui_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0319   text
*      -->P_0320   text
*----------------------------------------------------------------------*
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

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FT_REPORT  text
*----------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.

  REFRESH: t_alv_fieldcat.

  IF p_grid = 'X'.
    PERFORM f_fieldcatg USING ft_report:
     'MATNR' 'MARD' 'MATNR' '' '9' '' '' '' '' '' '' '' '' '' 'X' '' '' '' '' '',
     'MAKTX' 'MAKT' 'MAKTX' '' '15' '' '' '' '' '' '' '' '' '' 'X' '' '' '' '' ''.
  ENDIF.
  PERFORM f_fieldcatg USING ft_report:
   'MATKL' 'MARA' 'MATKL' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '' '' '' '',
   'WERKS' 'MARD' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '' '' '' '',
   'NAME1' 'T001W' 'NAME1' '' '' 'Plant Description' '' '' '' '' '' '' '' '' '' 'X' '' '' '' '',
   'LGORT' 'TVKOL' 'LGORT' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '' '' '' '',
   'VKBUR' 'S603' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '' '' '' '',
   'BEZEI' 'TVKBT' 'BEZEI' '' '' 'Sales Off Description' '' '' '' '' '' '' '' '' '' 'X' '' '' '' '',
   'MEINS' 'MARA' 'MEINS' '' '3' '' '' '' '' '' '' '' '' '' 'X''' '' '' '' '' '',
*   'ZEIAR' 'MARA' 'ZEIAR' '' '9' 'Must Have' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
   'MAABC' 'MARC' 'MAABC' '' '9' 'ABC analisis' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
   'FLG1' '' '' '' '12' 'Item Listing' '' '' '' '' '' '' '' '' 'X' '' '' '' '' '',
   'STKCR' '' '' '' '15' 'Curr UU Stock' '' 'X' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'STKCRPL' '' '' '' '15' 'Curr UU Stk in Pallette' '' 'X' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'BLSTKCR' '' '' '' '15' 'Curr Block Stock' '' 'X' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'INTRS' '' '' '' '15' 'Intransit' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'OPNSTO' '' '' '' '15' 'DN' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'OPNPO' '' '' '' '15' 'Open PO/STR' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'GRSTO' '' '' '' '15' 'GR PO/STR' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'TOTPO' '' '' '' '15' 'Total PO/STR' '' 'X' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
*   'AVRSL' '' '' '' '15' 'Average Sales' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'AVRSLUTD' '' '' '' '15' 'Average Sales United' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'AVRFC' '' '' '' '15' 'Average Include Forecast' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'STDRT' '' '' '' '15' 'Standart T' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'ACTRT' '' '' '' '15' 'Opening T' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'ACTRT1' '' '' '' '15' 'Current T' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'STKLS' '' '' '' '15' 'Opening Stock' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
*   'SALES' '' '' '' '15' 'Sales MTD' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'DNQTY' '' '' '' '13' 'Sales MTD' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
*   'TACM' '' '' '' '23' 'Tot. Allo. Curr. Month' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' 'C300',
*   'TANM' '' '' '' '21' 'Tot. Allo. Next Month' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' 'C300',
   'X6' '' '' '' '13' 'Sales M-6' '' '' '0' '' '' '' '' '' '' '' '' '' '' '',
   'X5' '' '' '' '13' 'Sales M-5' '' '' '0' '' '' '' '' '' '' '' '' '' '' '',
   'X4' '' '' '' '13' 'Sales M-4' '' '' '0' '' '' '' '' '' '' '' '' '' '' '',
   'X3' '' '' '' '13' 'Sales M-3' '' '' '0' '' '' '' '' '' '' '' '' '' '' '',
   'X2' '' '' '' '13' 'Sales M-2' '' '' '0' '' '' '' '' '' '' '' '' '' '' '',
   'X1' '' '' '' '13' 'Sales M-1' '' '' '0' '' '' '' '' '' '' '' '' '' '' '',
   'M0' '' '' '' '13' 'Forecast M' '' '' '0' '' '' '' '' '' '' '' '' '' '' '',
   'M1' '' '' '' '13' 'Forecast M+1' '' '' '0' '' '' '' '' '' '' '' '' '' '' '',
   'M2' '' '' '' '13' 'Forecast M+2' '' '' '0' '' '' '' '' '' '' '' '' '' '' '',
   'M3' '' '' '' '13' 'Forecast M+3' '' '' '0' '' '' '' '' '' '' '' '' '' '' '',
   'FTSM0W1' '' '' '' '13' 'Frc M W1' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM0W2' '' '' '' '13' 'Frc M W2' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM0W3' '' '' '' '13' 'Frc M W3' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM0W4' '' '' '' '13' 'Frc M W4' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM1W1' '' '' '' '13' 'Frc M+1 W1' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM1W2' '' '' '' '13' 'Frc M+1 W2' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM1W3' '' '' '' '13' 'Frc M+1 W3' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM1W4' '' '' '' '13' 'Frc M+1 W4' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM2W1' '' '' '' '13' 'Frc M+2 W1' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM2W2' '' '' '' '13' 'Frc M+2 W2' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM2W3' '' '' '' '13' 'Frc M+2 W3' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM2W4' '' '' '' '13' 'Frc M+2 W4' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM3W1' '' '' '' '13' 'Frc M+3 W1' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM3W2' '' '' '' '13' 'Frc M+3 W2' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM3W3' '' '' '' '13' 'Frc M+3 W3' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'FTSM3W4' '' '' '' '13' 'Frc M+3 W4' '' '' '0' '' '' '' '' '' '' '' '' '' 'X' '',
   'SLOBOP' '' '' '' '13' 'SLOB Last Month' '' '' '0' '' '' '' '' '' '' '' '' '' '' '',
   'SLOBCR' '' '' '' '13' 'SLOB Current Month' '' '' '0' '' '' '' '' '' '' '' '' '' '' '',
   'KARTON' '' '' '' '13' 'Carton' '' '' '0' '' '' '' '' '' '' '' '' '' '' '',
   'POQTY' '' '' '' '15' 'PO Qty' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'OOSQTY' '' '' '' '15' 'OOS Qty' '' '' '2' '' '' '' 'MEINS' '' '' '' '' '' '' '',
   'PEROOS' '' '' '' '5' '% OOS' '' '' '2' '' '' '' '' '' '' '' '' '' '' '',
   'KZAUS' 'MARC' 'KZAUS' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '' '' '' '',
   'NFMAT' 'MARC' 'NFMAT' '' '15' 'New Product' '' '' '' '' '' '' '' '' 'X' '' '' '' '' '',
   'OLMAT' 'MARC' 'NFMAT' '' '15' 'Old Product' '' '' '' '' '' '' '' '' 'X' '' '' '' '' '',
   'NSP' 'KONP' 'KBETR' '' '15' 'NSP' '' '' '' 'IDR' '' '' '' '' '' '' '' '' '' '',
   'WAERS' 'ZMM_PO_OOS' 'WAERS' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '',
   'OOSVAL' 'ZMM_PO_OOS' 'OOSVAL' '' '' 'OOS Amount' '' '' '' '' '' 'WAERS' '' '' '' '' '' '' '' ''.
*   'DNVAL' '' '' '' '13' 'B&NB Amount' '' '' '0' '' '' '' '' '' '' '' '' '' ''.

*  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.
*  CLEAR: ld_fieldcat.
*  ld_fieldcat-fieldname = 'NSP'.
*  ld_fieldcat-ref_fieldname = 'NSP'.
*  ld_fieldcat-seltext_s = 'NSP'.
*  ld_fieldcat-seltext_m = 'NSP'.
*  ld_fieldcat-seltext_l = 'NSP'.
*  ld_fieldcat-currency = 'IDR'.
*  APPEND ld_fieldcat TO t_alv_fieldcat.
*  CLEAR ld_fieldcat.

ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_build_fieldcat1.

*  REFRESH: t_alv_fieldcat.
*
*  PERFORM f_fieldcatg USING 'I_MAIN':
**   'MATNR' 'MARD' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' 'X' '' ''
*''
**,
**   'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' 'X' '' ''
*''
**,
*   'WERKS' 'MARD' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '' ''
*,
*   'NAME1' 'T001W' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' 'X' '' ''
*'',
*   'STKCR' '' '' '' '15' 'Curr Stock' '' '' '2' '' '' '' 'MEINS'
*'' '' '' '' '',
*   'INTRS' '' 'INTRS' '' '15' 'Intransit' '' '' '2' '' '' '' '' ''
*'' '' '' '',
*   'OPNSTO' '' 'OPNSTO' '' '15' 'Open STO/DN' '' '' '2' '' '' '' ''
*'' '' '' '' '',
*   'OPNPO' '' 'OPNPO' '' '15' 'Open PO' '' '' '2' '' '' '' '' '' ''
*'' '' '',
*   'GRSTO' '' 'GRSTO' '' '15' 'GR PO/STO' '' '' '2' '' '' '' '' ''
*'' '' '' '',
*   'TOTPO' '' 'TOTPO' '' '15' 'Total PO/STO' '' '' '2' '' '' '' ''
*'' '' '' '' '',
*   'AVRSL' '' 'AVRSL' '' '15' 'Average Sales' '' '' '2' '' '' '' ''
*'' '' '' '' '',
*   'STDRT' '' 'STDRT' '' '15' 'Standart T' '' '' '2' '' '' '' ''
*'' '' '' '' '',
*   'ACTRT' '' 'ACTRT' '' '15' 'Actual T' '' '' '2' '' '' '' ''
*'' '' '' '' '',
*   'STKLS' '' 'STKLS' '' '15' 'Stock Awal' '' '' '2' '' '' '' ''
*'' '' '' '' '',
*   'SALES' '' 'SALES' '' '15' 'Sales' '' '' '2' '' '' '' ''
*'' '' '' '' ''.

ENDFORM.                    " F_FIELDCAT1

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
                          VALUE(fu_key)
                          VALUE(fu_input)
                          VALUE(fu_no_zero)
                          VALUE(fu_no_sign)
                          VALUE(fu_no_out)
                          VALUE(fu_color).

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
  ld_fieldcat-key           = fu_key.
  ld_fieldcat-input         = fu_input.
  ld_fieldcat-no_zero       = fu_no_zero.
  ld_fieldcat-no_sign       = fu_no_sign.
  ld_fieldcat-no_out        = fu_no_out.
  ld_fieldcat-emphasize     = fu_color.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.

ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
*  fu_layout-f2code             = '&ETA'.
*  fu_layout-box_fieldname      = 'FLAG'.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-info_fieldname     = 'ERRFL'.

ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  IF p_grid = 'X'.
    CLEAR ld_sort.
    ld_sort-fieldname = 'MATNR'.
    ld_sort-up        = 'X'.
*    ld_sort-group     = '*'.
*    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.
  ELSE.
    CLEAR ld_sort.
    ld_sort-fieldname = 'MATNR'.
    ld_sort-up        = 'X'.
    ld_sort-group     = '*'.
*    ld_sort-subtot    = 'X'.
    APPEND ld_sort TO fu_sort.
  ENDIF.

  CLEAR ld_sort.
  ld_sort-fieldname = 'WERKS'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'LGORT'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

ENDFORM.                    "f_build_sortfield

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

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  DATA: l_material(100).

  CONCATENATE 'Material:' i_main-matnr i_main-maktx
              '(' i_main-matkl ')'
      INTO l_material SEPARATED BY space.

  PERFORM f_hdr_uline.
  PERFORM f_hdr_line1 USING sy-title.
  PERFORM f_hdr_line2 USING ''.
  PERFORM f_hdr_line3 USING l_material.
  PERFORM f_hdr_uline.

ENDFORM.                    "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  F_HDR_ULINE
*&---------------------------------------------------------------------*
*       Draw underline if flag set
*----------------------------------------------------------------------*
FORM f_hdr_uline.
  IF d_hdr_rpt_lines = 'X'.
    ULINE.
  ENDIF.
ENDFORM.                    " F_HDR_ULINE

*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE1
*&---------------------------------------------------------------------*
*       Header line with report, title and page
*----------------------------------------------------------------------*
FORM f_hdr_line1 USING fu_company.
  DATA:
    page_number(10) VALUE 'Page: nnnn',
    progname(42)    VALUE 'Program: xx',
    ld_progname(20),
    page(4).

*--- Page number
  page = sy-pagno.
  REPLACE 'nnnn' WITH page INTO page_number.
  IF sy-cprog EQ sy-repid.
    REPLACE 'xx' WITH sy-repid INTO progname.
  ELSE.
    CONCATENATE sy-repid '(' sy-cprog ')' INTO ld_progname.
    REPLACE 'xx' WITH ld_progname INTO progname.
  ENDIF.

*--- Output line
  PERFORM f_hdr_pad_title USING progname fu_company page_number.
ENDFORM.                    " F_HDR_LINE1


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE2
*&---------------------------------------------------------------------*
*       Client, User text 1, Date and time
*----------------------------------------------------------------------*
FORM f_hdr_line2 USING fu_title.
  DATA:
    ld_sysid(18) VALUE 'Client : XXX(YYY)',
*  ld_datum(18) value 'Date: AA/BB/CCCC'.
    ld_datum(10).

*--- system info
  REPLACE 'XXX' WITH sy-sysid(3) INTO ld_sysid.
  REPLACE 'YYY' WITH sy-mandt INTO ld_sysid.

*--- date
*  replace 'AA' with sy-datum+6(2) into ld_datum.
*  replace 'BB' with sy-datum+4(2) into ld_datum.
*  replace 'CCCC' with sy-datum+0(4) into ld_datum.
  WRITE sy-datum TO ld_datum.

*--- output line
  PERFORM f_hdr_pad_title USING ld_sysid fu_title ld_datum.
ENDFORM.                    " F_HDR_LINE2


*&---------------------------------------------------------------------*
*&      Form  F_HDR_LINE3
*&---------------------------------------------------------------------*
*       User name, text 2, time
*----------------------------------------------------------------------*
FORM f_hdr_line3 USING fu_title.
  DATA:
    ld_uzeit(5)  VALUE 'hh:mm',
    ld_uname(21) VALUE 'User:    xx'.

*--- time
  REPLACE 'hh' WITH sy-uzeit(2) INTO ld_uzeit.     " hour
  REPLACE 'mm' WITH sy-uzeit+2(2) INTO ld_uzeit.   " minute

*--- user
  REPLACE 'xx' WITH sy-uname INTO ld_uname.

*--- output line
  PERFORM f_hdr_pad_title USING ld_uname fu_title ld_uzeit.

ENDFORM.                    " F_HDR_LINE3

*&---------------------------------------------------------------------*
*&      Form  F_HDR_PAD_TITLE
*&---------------------------------------------------------------------*
*       Prepare the variable with the title text spaced correctly
*----------------------------------------------------------------------*
FORM f_hdr_pad_title USING v_left_text v_middle_text v_right_text.

  DATA:
    page_width    TYPE i,       " Width of page
    middle_length TYPE i,    " Length of title text
    left_length   TYPE i,      " Length of left text
    right_length  TYPE i,     " Length of right text
    left_start    TYPE i,       " Position on line for start of left tex
    middle_start  TYPE i,     " Position on line for start of middl tex
    right_start   TYPE i.      " Position on line for start of right tex

*--- Start with a blank title
  CLEAR d_hdr_title.
  page_width = sy-linsz - 1.

*--- Compute space on either side of title allowing vertical border
  COMPUTE middle_length = strlen( v_middle_text ).
  COMPUTE left_length = strlen( v_left_text ).
  COMPUTE right_length = strlen( v_right_text ).

  COMPUTE middle_start = ( sy-linsz - middle_length ) / 2.

*--- Allow for vertical lines
  left_start = 0.
  IF d_hdr_rpt_lines = 'X'.
    d_hdr_title(1) = sy-vline.
    d_hdr_title+page_width(1) = sy-vline.
    left_start = 1.
  ENDIF.
  right_start = sy-linsz - left_start - right_length - 1.
  WRITE:/ sy-vline.
*--- Insert texts
  IF left_length <> 0.
*    d_hdr_title+left_start(left_length) = v_left_text.
    WRITE AT (left_length) v_left_text.
  ENDIF.
  IF middle_length <> 0.
    WRITE AT middle_start(middle_length) v_middle_text.
*    d_hdr_title+middle_start(middle_length) = v_middle_text.
  ENDIF.
  IF right_length <> 0.
    WRITE AT right_start(right_length) v_right_text.
*    d_hdr_title+right_start(right_length) = v_right_text.
  ENDIF.
  WRITE AT sy-linsz sy-vline.
ENDFORM.                    " F_HDR_PAD_TITLE

*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.

  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.

ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.
  REFRESH: lt_dynpread.

  DATA: seltab    TYPE TABLE OF rsparams,
        seltab_wa LIKE LINE OF seltab,
        l_date1   TYPE sy-datum,
        l_date2   TYPE sy-datum,
        d_flag(1) TYPE c.

  CASE fu_ucomm.
    WHEN '&SAV'.
      PERFORM f_save_to_table.
    WHEN '&REFRESH'.
      PERFORM f_refresh_data.
    WHEN '&IC1'.
      READ TABLE i_main INDEX fu_selfield-tabindex.
      MOVE: 'EM_MATNR'  TO seltab_wa-selname,
            'S'      TO seltab_wa-kind,      " SELECT-OPTION
            'I'      TO seltab_wa-sign,
            'EQ'     TO seltab_wa-option,
        i_main-matnr TO seltab_wa-low.
      APPEND seltab_wa TO seltab.

      MOVE: 'EM_WERKS'  TO seltab_wa-selname,
        i_main-werks TO seltab_wa-low.
      APPEND seltab_wa TO seltab.

      IF i_main-werks(2) EQ '02'.
        MOVE: 'EM_EKORG'  TO seltab_wa-selname,
                'SOM'  TO seltab_wa-low.
      ELSEIF i_main-werks(2) EQ '07'.
        MOVE: 'EM_EKORG'  TO seltab_wa-selname,
                'SUT'  TO seltab_wa-low.
      ENDIF.
      APPEND seltab_wa TO seltab.

      MOVE: 'S_BSART' TO seltab_wa-selname,
            'UB'      TO seltab_wa-low.
      APPEND seltab_wa TO seltab.

      IF i_main-werks(2) EQ '02'.
        MOVE: 'ZB' TO seltab_wa-low.
      ELSEIF i_main-werks(2) EQ '07'.
        MOVE: 'ZSUT' TO seltab_wa-low.
      ENDIF.
      APPEND seltab_wa TO seltab.

      MOVE: 'NB' TO seltab_wa-low.
      APPEND seltab_wa TO seltab.
      MOVE: 'OB' TO seltab_wa-low.
      APPEND seltab_wa TO seltab.
      MOVE: 'ZICO' TO seltab_wa-low.
      APPEND seltab_wa TO seltab.
      MOVE: 'ZRL' TO seltab_wa-low.
      APPEND seltab_wa TO seltab.

      IF  p_incsut = ''.
        MOVE: 'S_EBELN' TO seltab_wa-selname.
        LOOP AT t_ebeln INTO d_ebeln.
          MOVE: d_ebeln TO seltab_wa-low.
          APPEND seltab_wa TO seltab.
        ENDLOOP.
      ENDIF.

      CONCATENATE p_spmon '01' INTO l_date1.
      CONCATENATE p_spmon '01' INTO l_date2.
      IF l_date2+4(2) = '12'.
        l_date2+4(2) = '01'.
        l_date2(4) = l_date2(4) + 1.
      ELSE.
        l_date2+4(2) = l_date2+4(2) + 1.
      ENDIF.
      l_date2 = l_date2 - 1.

      MOVE: 'S_BEDAT' TO seltab_wa-selname,
            'BT'      TO seltab_wa-option,
            l_date1   TO seltab_wa-low,
            l_date2   TO seltab_wa-high.
      APPEND seltab_wa TO seltab.

      MOVE: 'LISTU'  TO seltab_wa-selname,
             'P'     TO seltab_wa-kind,      " PARAMETER
             'EQ'    TO seltab_wa-option,
             'BEST'  TO seltab_wa-low.
      APPEND seltab_wa TO seltab.

      d_flag = 1.
      IF fu_selfield-value CO '0,00' OR
         fu_selfield-value CO '             0'.
        d_flag = 0.
      ENDIF.

      IF fu_selfield-fieldname EQ 'STKCR' OR
         fu_selfield-sel_tab_field EQ'1-STKCR'.
        SET PARAMETER ID 'MAT' FIELD i_main-matnr.
        SET PARAMETER ID 'WRK' FIELD i_main-werks.
        SET PARAMETER ID 'LAG' FIELD ''.
        CALL TRANSACTION 'MMBE' AND SKIP FIRST SCREEN.
      ELSEIF ( fu_selfield-fieldname EQ 'TOTPO' OR
             fu_selfield-sel_tab_field EQ '1-TOTPO' ) AND
             d_flag NE 0.
        SUBMIT rm06em00 WITH SELECTION-TABLE seltab
           AND RETURN.
      ELSEIF ( fu_selfield-fieldname EQ 'INTRS' OR
               fu_selfield-sel_tab_field EQ '1-INTRS' ) AND
             d_flag NE 0.
        MOVE: 'SELPA'  TO seltab_wa-selname,
              'S'      TO seltab_wa-kind,      " SELECT-OPTION
              'I'      TO seltab_wa-sign,
              'EQ'     TO seltab_wa-option,
              'WE101'  TO seltab_wa-low.
        APPEND seltab_wa TO seltab.

        SUBMIT rm06em00 WITH SELECTION-TABLE seltab
           AND RETURN.
      ELSEIF ( fu_selfield-fieldname EQ 'OPNSTO' OR
             fu_selfield-sel_tab_field EQ '1-OPNSTO' ) AND
             i_main-werks NE '0200' AND d_flag NE 0.
        MOVE: 'SELPA'  TO seltab_wa-selname,
              'S'      TO seltab_wa-kind,      " SELECT-OPTION
              'I'      TO seltab_wa-sign,
              'EQ'     TO seltab_wa-option,
              'WA351'  TO seltab_wa-low.
        APPEND seltab_wa TO seltab.

        SUBMIT rm06em00 WITH SELECTION-TABLE seltab
           AND RETURN.
      ELSEIF ( fu_selfield-fieldname EQ 'GRSTO' OR
             fu_selfield-sel_tab_field EQ '1-GRSTO' ) AND d_flag NE 0.
        MOVE: 'SELPA'  TO seltab_wa-selname,
              'S'      TO seltab_wa-kind,      " SELECT-OPTION
              'I'      TO seltab_wa-sign,
              'EQ'     TO seltab_wa-option,
              'WE102'  TO seltab_wa-low.
        APPEND seltab_wa TO seltab.

        SUBMIT rm06em00 WITH SELECTION-TABLE seltab
           AND RETURN.
      ELSEIF ( fu_selfield-fieldname EQ 'AVRSL' OR
             fu_selfield-sel_tab_field EQ '1-AVRSL' ) AND d_flag NE 0.

        REFRESH seltab.

        MOVE: 'PA_SPMON'  TO seltab_wa-selname,
              'P'     TO seltab_wa-kind,      " PARAMETER
              'EQ'    TO seltab_wa-option.
        IF p_spmon = sy-datum(6).
          CONCATENATE p_spmon sy-datum+4(2) INTO l_date1.
          MOVE  l_date1 TO seltab_wa-low.
        ELSE.
          MOVE p_spmon TO seltab_wa-low.
        ENDIF.
        APPEND seltab_wa TO seltab.

        MOVE: 'SO_MATNR'  TO seltab_wa-selname,
              'S'      TO seltab_wa-kind,      " SELECT-OPTION
              'I'      TO seltab_wa-sign,
              'EQ'     TO seltab_wa-option,
          i_main-matnr TO seltab_wa-low.
        APPEND seltab_wa TO seltab.

        MOVE: 'SO_PLANT'  TO seltab_wa-selname,
          i_main-werks TO seltab_wa-low.
        APPEND seltab_wa TO seltab.
        IF p_spmon = sy-datum(6).
          SUBMIT zs_sac7_2_sloff WITH SELECTION-TABLE seltab
             AND RETURN.
        ELSE.
          SUBMIT zs_sac7_3_sloff WITH SELECTION-TABLE seltab
             AND RETURN.
        ENDIF.
      ENDIF.
  ENDCASE.

ENDFORM.                    "f_user_command
