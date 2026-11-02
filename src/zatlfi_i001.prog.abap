*&---------------------------------------------------------------------*
*& Report  ZRVTPSC00                                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*&   Versendung einer Lieferung an eine Spediteur zwecks Frachtplanung *
*&---------------------------------------------------------------------*

REPORT  zatlfi_i001 MESSAGE-ID v6.

INCLUDE zabp_alv_common.
INCLUDE zabp_header.

TABLES: zatldt001.
DATA: gt_zatldt001 TYPE STANDARD TABLE OF zatldt001 WITH HEADER LINE.
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.

PARAMETERS p_bukrs TYPE zatldt001-bukrs DEFAULT '8180' NO-DISPLAY.
SELECT-OPTIONS s_erdat FOR zatldt001-erdat.
SELECT-OPTIONS s_belnr FOR zatldt001-belnr.
SELECT-OPTIONS s_gjahr FOR zatldt001-gjahr.
SELECT-OPTIONS s_stat FOR zatldt001-status NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK data.
SELECTION-SCREEN SKIP 1.
PARAMETERS p_back AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN SKIP 1.
PARAMETERS p_repro AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN SKIP 1.

INITIALIZATION.
  CLEAR: s_erdat[].
  s_erdat-high = sy-datum.
  s_erdat-low = sy-datum - 10.
  s_erdat-sign   = 'I'.
  s_erdat-option = 'BT'.
  APPEND s_erdat.

START-OF-SELECTION.
  IF s_erdat[] IS INITIAL.
    CLEAR: s_erdat[].
    s_erdat-high = sy-datum.
    s_erdat-low = sy-datum - 10.
    s_erdat-sign   = 'I'.
    s_erdat-option = 'BT'.
    APPEND s_erdat.
  ENDIF.
  PERFORM f_get_data. " TABLES gt_zatldt001.
  IF p_back = 'X'.
    PERFORM f_send_data.
  ELSE.
    PERFORM f_print_data.
  ENDIF.


FORM f_get_data. " TABLES p_table.

  IF p_repro = 'X'.
    SELECT * INTO  TABLE gt_zatldt001
      FROM zatldt001
      WHERE erdat IN s_erdat
        AND belnr IN s_belnr
        AND gjahr IN s_gjahr
        AND status EQ 'P'.
  ELSE.
    SELECT * INTO  TABLE gt_zatldt001
      FROM zatldt001
      WHERE erdat IN s_erdat
        AND belnr IN s_belnr
        AND gjahr IN s_gjahr
        AND status NE 'P'. " s_stat.
  ENDIF.
  "  p_table[] = gt_zatldt001[].
  IF gt_zatldt001[] IS NOT INITIAL.
    READ TABLE gt_zatldt001 ASSIGNING FIELD-SYMBOL(<fs_result>) INDEX 1.
    p_bukrs = <fs_result>-bukrs.
    SELECT * INTO TABLE @DATA(lt_bsak) FROM bsak
      FOR ALL ENTRIES IN @gt_zatldt001
      WHERE bukrs = @gt_zatldt001-bukrs
        AND lifnr = @gt_zatldt001-lifnr
        AND belnr = @gt_zatldt001-belnr
        AND gjahr = @gt_zatldt001-gjahr.
    IF lt_bsak[] IS NOT INITIAL.
      SELECT * INTO TABLE @DATA(lt_bsak1) FROM bsak
        FOR ALL ENTRIES IN @lt_bsak
        WHERE bukrs = @lt_bsak-bukrs
          AND lifnr = @lt_bsak-lifnr
          AND belnr = @lt_bsak-augbl
          AND gjahr = @lt_bsak-gjahr.

      LOOP AT gt_zatldt001 ASSIGNING <fs_result> WHERE status NE 'P'.
        READ TABLE lt_bsak ASSIGNING FIELD-SYMBOL(<fs_bsak>)
           WITH KEY belnr = <fs_result>-belnr
                    gjahr = <fs_result>-gjahr
                    lifnr = <fs_result>-lifnr.
        IF sy-subrc EQ 0. " and <fs_result>-status ne 'P'.
          <fs_result>-augbl = <fs_bsak>-augbl.
          <fs_result>-budat = <fs_bsak>-budat.
          <fs_result>-aedat = sy-datum.
          <fs_result>-aezet = sy-uzeit.
          <fs_result>-aenam = sy-uname.
          p_bukrs = <fs_bsak>-bukrs.
          READ TABLE lt_bsak1 ASSIGNING FIELD-SYMBOL(<fs_bsak1>)
           WITH KEY belnr = <fs_result>-augbl
                    gjahr = <fs_result>-gjahr
                    lifnr = <fs_result>-lifnr.
          IF sy-subrc EQ 0.
            <fs_result>-zuonr1 = <fs_bsak1>-zuonr.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
FORM f_fieldcatg USING    VALUE(fu_types)
                          VALUE(fu_fname)
                          VALUE(fu_reftb)
                          VALUE(fu_refld)
                          VALUE(fu_noout)
                          VALUE(fu_outln)
                          VALUE(fu_fltxt)
                          VALUE(fu_scrtext_s)
                          VALUE(fu_scrtext_m)
                          VALUE(fu_scrtext_l)

*                          value(fu_dosum)
*                          value(fu_hotsp)
*                          value(fu_waers)
*                          value(fu_meins)
*                          value(fu_meins_f)
                          VALUE(fu_checkbox)
                          VALUE(fu_waers)
                          VALUE(fu_input)
*                          value(fu_emphasize)
*                          value(fu_hotspot)
                          VALUE(fu_edit)
                          VALUE(fu_just) ""just(1)        type c,        " (R)ight (L)eft (C)ent.
                          VALUE(fu_waers_f)
                          VALUE(fu_dec).
*                          value(fu_no_zero).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.

  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname   = fu_reftb.
  ld_fieldcat-ref_fieldname = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-reptext_ddic  = fu_fltxt.

  ld_fieldcat-seltext_l  = fu_scrtext_l.
  ld_fieldcat-seltext_m  = fu_scrtext_m.
  ld_fieldcat-seltext_s  = fu_scrtext_s.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-just = fu_just.
  ld_fieldcat-input = fu_input.
*  ld_fieldcat-do_sum            = fu_dosum.
*  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out        = fu_dec.
  ld_fieldcat-currency          = fu_waers.
*  ld_fieldcat-quantity          = fu_meins.
*  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
*  ld_fieldcat-emphasize         = fu_emphasize.
*  ld_fieldcat-hotspot           = fu_hotspot.
  ld_fieldcat-edit              = fu_edit.
*  ld_fieldcat-no_zero           = fu_no_zero.

  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

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
*
FORM f_build_fieldcat TABLES ft_report.
* Enter field name, reference table and field
  REFRESH: t_alv_fieldcat.
*  itable, fieldname, reference table, reference fieldname, nothing comes out, length of the column name, output column name
  PERFORM f_fieldcatg USING 'GT_RESULT' :
"   'MARK'       ''  '' '' '' 'Check' '' '' '' 'X' '' 'X' 'X' '' '' '',
"   'ICON'       ''  '' '' '' 'Sts.' '' '' '' '' '' '' '' '' '' '',
  'BUKRS'       'ZATLDT001'  'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
  'GSBER'       'ZATLDT001'  'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
  'BELNR'       'ZATLDT001'  'BELNR' '' '' 'MIRO Doc' '' '' '' '' '' '' '' '' '' '',
  'GJAHR'       'ZATLDT001'  'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
  'LIFNR'       'ZATLDT001'  'LIFNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
  'XBLNR'       'ZATLDT001'  'XBLNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
  'ZUONR'       'ZATLDT001'  'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' '',
  'ERDAT'       'ZATLDT001'  'ERDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
  'ERZET'       'ZATLDT001'  'ERZET' '' '' '' '' '' '' '' '' '' '' '' '' '',
  'ERNAM'       'ZATLDT001'  'ERNAM' '' '' '' '' '' '' '' '' '' '' '' '' '',
  'ZUONR1'       'ZATLDT001'  'ZUONR1' '' '' '' '' '' '' '' '' '' '' '' '' '',
  'BUDAT'       'ZATLDT001'  'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
  'AUGBL'       'ZATLDT001'  'AUGBL' '' '' '' '' '' '' '' '' '' '' '' '' '',
  'STATUS'       'ZATLDT001'  'STATUS' '' '' 'Status' '' '' '' '' '' '' '' '' '' '',
  'AEDAT'       'ZATLDT001'  'AEDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
  'AEZET'       'ZATLDT001'  'AEZET' '' '' '' '' '' '' '' '' '' '' '' '' '',
  'AENAM'       'ZATLDT001'  'AENAM' '' '' '' '' '' '' '' '' '' '' '' '' ''.

ENDFORM.                    " F_BUILD_FIELDCAT

**&---------------------------------------------------------------------*
**&      Form  F_BUILD_LAYOUT
**&---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra = 'X'.
  fu_layout-colwidth_optimize = space.
  fu_layout-no_colhead = space.
  fu_layout-group_change_edit = 'X'.
*  fu_layout-detail_popup = 'X'.
*  fu_layout-expand_fieldname = 'EXPAND'.
*  fu_layout-expand_all = 'X'.
*  fu_layout-box_fieldname     = 'MARK'.
ENDFORM.                    " F_BUILD_LAYOUT
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
*       FORM F_BUILD_PRINT
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos    = 'X'.
  fu_print-no_print_selinfos     = 'X'.
  fu_print-no_coverpage          = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "F_BUILD_PRINT

FORM f_alv TABLES ft_report.
  DATA: g_repid   TYPE sy-repid.
  g_repid = sy-repid.

  PERFORM f_clear_alv_data.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_fieldcat TABLES ft_report.

  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.

  PERFORM f_build_event       TABLES  t_alv_event[].

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
   "  i_callback_top_of_page   = 'TOP-OF-PAGE'
      it_fieldcat              = t_alv_fieldcat[]
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout                = d_layout
      it_events                = t_alv_event[]
      it_event_exit            = t_event_exit[]
      i_default                = 'X'
      i_save                   = 'A'
      is_print                 = d_print
*     i_structure_name         = 'zco_e011_detl'
    TABLES
      t_outtab                 = ft_report.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM F_SET_PF_STATUS
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.
ENDFORM.                    " F_SET_PF_STATUS



FORM f_top_of_page.
  DATA: lt_header     TYPE slis_t_listheader,
        ls_header     TYPE slis_listheader,
        lt_line       LIKE ls_header-info,
        lv_lines      TYPE i,
        lv_linesc(10) TYPE c.

**&—– Alv report header —–*
  ls_header-typ = 'S'.
  SELECT SINGLE butxt INTO ls_header-info FROM t001
    WHERE bukrs = p_bukrs.
  CONCATENATE 'Company: ' p_bukrs '-' ls_header-info INTO ls_header-info SEPARATED BY space.

  APPEND ls_header TO lt_header.


  ls_header-typ = 'S'.
  "  CONCATENATE 'COMPANY CODE: ' p_bukrs INTO
  ls_header-info = 'Send Data Payment to WEB ATL'.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.
  ls_header-typ = 'S'.
  DATA: period(20) .
  "  WRITE sy-datum TO period.
  WRITE s_erdat-low TO period.
  "  CONCATENATE sy-datum+4(3) '.' sy-datum(4) ' - ' sy-datum+4(3) '.' sy-datum(4) INTO period.
  CONCATENATE 'Created on: ' period INTO ls_header-info SEPARATED BY ' '.
  WRITE s_erdat-high TO period.
  CONCATENATE ls_header-info '-' period INTO ls_header-info SEPARATED BY ' '.
  "ls_zco_e011_header-period ls_zco_e011_header-gjahr INTO ls_header-info SEPARATED BY space.
  APPEND ls_header TO lt_header.
  CLEAR ls_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.

ENDFORM. "top-of-page



FORM f_print_data.

  PERFORM f_alv TABLES gt_zatldt001.

ENDFORM.


FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  CASE fu_ucomm.
**    WHEN '&SALL'.
**      LOOP AT gt_result ASSIGNING FIELD-SYMBOL(<fs_result>) WHERE mark = space.
**        <fs_result>-mark = 'X'.
**      ENDLOOP.
**      fu_selfield-refresh = 'X'.
***    WHEN '&SAL'.
**    WHEN '&DSALL'.
**      LOOP AT gt_result ASSIGNING FIELD-SYMBOL(<fs_result2>) WHERE mark = 'X'.
**        <fs_result2>-mark = space.
**      ENDLOOP.
**      fu_selfield-refresh = 'X'.
**    WHEN 'EXEC'.
    WHEN '&POS'.
      PERFORM f_send_data.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_SEND_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_send_data .
  TYPES: BEGIN OF ty_send,
           sap_miro_no    TYPE string, ": "0510365435",
           sap_miro_year  TYPE string,                      ": "2025",
           no_payment_sap TYPE string, ":"VSU7678676",
           payment_date   TYPE string, ":"20251211"
           assignment     TYPE string,
         END OF ty_send.
  DATA: ls_send TYPE ty_send.
  DATA: lv_nama(15).
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
         gv_json      TYPE string.
  DATA: lv_str TYPE string.
  LOOP AT gt_zatldt001 ASSIGNING FIELD-SYMBOL(<gs_result>).
    ls_send-sap_miro_no = <gs_result>-belnr.
    ls_send-sap_miro_year = <gs_result>-gjahr.
    ls_send-no_payment_sap = <gs_result>-augbl.
    ls_send-payment_date = <gs_result>-budat.
    ls_send-assignment = <gs_result>-zuonr1.
    <gs_result>-aedat = sy-datum.
    <gs_result>-aezet = sy-uzeit.
    <gs_result>-aenam = sy-uname.
    <gs_result>-status = 'P'.
    MODIFY zatldt001 FROM <gs_result>.
    lv_nama = <gs_result>-belnr.
    "    CONCATENATE 'atlpay_' lv_nama into lv_nama.
    CREATE OBJECT cl_json_data
      EXPORTING
        data = ls_send.
    cl_json_data->serialize( ).
    gv_json = cl_json_data->get_data( ).
    PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'ATL_PAYMENT' sy-subrc lv_str. "ztiam_i0001
    WRITE: / 'Mesage Send Payment : ', lv_str.
    PERFORM f_create_text_json(ztdsit_i001) USING gv_json lv_nama '/outbound/TIAM/' 'ATL_PAYMENT'.
    CLEAR: ls_send.
  ENDLOOP.
ENDFORM.

FORM f_last_day  USING    fu_date
                 CHANGING fc_date.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = fu_date
    IMPORTING
      last_day_of_month = fc_date
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
ENDFORM.
