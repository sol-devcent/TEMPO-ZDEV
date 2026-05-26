*&---------------------------------------------------------------------*
*&  Include           ZFF_VAT_RETURN_NEWF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data .
  CASE 'X'.
    WHEN p_type5.
      PERFORM f_alv TABLES gt_nr.
    WHEN OTHERS.
      PERFORM f_alv TABLES i_itab1.
  ENDCASE.
ENDFORM.                    " F_PRINT_DATA

*---------------------------------------------------------------------*
*       FORM F_ALV
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.
  DATA: lv_func(22),
        lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
*  PERFORM f_alv_variant_exist USING   p_vari
*                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      is_layout                = d_layout
      it_fieldcat              = t_alv_fieldcat[]
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
FORM f_build_fieldcat TABLES ft_report.
  REFRESH: t_alv_fieldcat.

  CASE 'X'.
    WHEN p_type5.
      PERFORM f_fieldcatg USING ft_report:
        'BUKRS' 'ZFVATIN_NR' 'BUKRS' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GSBER' 'ZFVATIN_NR' 'GSBER' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BELNR' 'ZFVATIN_NR' 'BELNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'GJAHR' 'ZFVATIN_NR' 'GJAHR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUDAT' 'RBKP' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BLDAT' 'RBKP' 'BLDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LIFNR' 'ZFVATIN_NR' 'LIFNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NAME1' 'LFA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'STREET' 'ZFVATIN_NR' 'STREET' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'CITY1' 'ZFVATIN_NR' 'CITY1' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'STCEG' 'ZFVATIN_NR' 'STCEG' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NONR' 'ZFVATIN_NR' 'NONR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VATPR1' 'ZFVATIN_NR' 'VATPR1' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'VATDT1' 'ZFVATIN_NR' 'VATDT1' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'TOTAL' 'RBKP' 'RMWWR' '' '' 'Total' '' '' '' 'IDR' '' '' '' '' '' '',
        'DPP' 'RBKP' 'RMWWR' '' '' 'DPP' '' '' '' 'IDR' '' '' '' '' '' '',
        'PPN' 'RBKP' 'WMWST1' '' '' 'PPN' '' '' '' 'IDR' '' '' '' '' '' ''.
    WHEN OTHERS.
      PERFORM f_fieldcatg USING ft_report:
        'BELNR' 'BSIS' 'BELNR' '' '' '' '' 'X' '' '' '' '' '' '' '' 'C601',
        'AUGBL' 'BSIS' 'AUGBL' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'BUDAT' 'BSIS' 'BUDAT' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'LIFNR' 'BSIK' 'LIFNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'NAME1' 'LFA1' 'NAME1' '' '' '' '' '' '' '' '' '' '' '' '' '',
*    'ZUONR' 'BSIK' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' '',
        'ZUONR1' 'RBKP' 'ZUONR' '' '' '' '' '' '' '' '' '' '' '' '' ''.
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
                          value(fu_input)
                          value(fu_emphasize).

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
ENDFORM.                    "F_BUILD_EVENT_EXIT

*---------------------------------------------------------------------*
*       FORM F_BUILD_LAYOUT
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
  fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-detail_popup       = 'X'.
  CASE 'X'.
    WHEN p_type5..
    WHEN OTHERS.
      fu_layout-box_fieldname      = 'CHECK'.
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
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CLEAR ld_sort.
  ld_sort-fieldname = 'BELNR'.
  ld_sort-up        = 'X'.
*  ld_sort-group     = 'UL'.
*  ld_sort-subtot    = 'X'.
  APPEND ld_sort TO fu_sort.

  CASE 'X'.
    WHEN p_type5.
    WHEN OTHERS.
      CLEAR ld_sort.
      ld_sort-fieldname = 'AUGBL'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.

      CLEAR ld_sort.
      ld_sort-fieldname = 'BUDAT'.
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
  CLEAR: i_itab1, i_itab1[].
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
  DATA : fcode TYPE TABLE OF sy-ucomm.

  sy-lsind = 0.
  CASE 'X'.
    WHEN p_type1.
      APPEND '&PREV'  TO fcode.
    WHEN p_type2.
      APPEND '&PREV'  TO fcode.
    WHEN p_type3.
    WHEN p_type5.
      APPEND '&PREV'  TO fcode.
      APPEND '&POS'  TO fcode.
  ENDCASE.

  SET PF-STATUS 'STANDARD' EXCLUDING fcode.
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

ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&IC1'.
      PERFORM f_submit_fb03 USING fu_selfield.
    WHEN '&POS' OR '&PREV'.
      PERFORM f_post_entries USING fu_ucomm.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries USING fu_ucomm.
  DATA: lt_itab1 TYPE ta_itab1 OCCURS 0 WITH HEADER LINE.

  lt_itab1[] = i_itab1[].
  DELETE lt_itab1 WHERE check IS INITIAL.

  IF lt_itab1[] IS INITIAL.
    MESSAGE 'No data processed' TYPE 'I'.
  ELSE.
    CASE 'X'.
      WHEN p_type1.
        DELETE i_itab1 WHERE check IS INITIAL.
        PERFORM f_process_itab1.
        LEAVE TO SCREEN 0.
      WHEN p_type2.
        DELETE i_itab1 WHERE check IS INITIAL.
        PERFORM f_process_itab2.
        LEAVE TO SCREEN 0.
      WHEN p_type3 OR p_type4.
*        IF p_type3 IS NOT INITIAL.
        lt_itab1[] = i_itab1[].
        DELETE lt_itab1 WHERE check IS INITIAL.
*        ENDIF.
*        PERFORM f_process_itab3 TABLES lt_itab1
*                                USING fu_ucomm.

        PERFORM f_cetak_form_new USING fu_ucomm.

        IF fu_ucomm = '&POS'.
          LEAVE TO SCREEN 0.
        ENDIF.
    ENDCASE.
  ENDIF.
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
*&      Form  F_PROCESS_ITAB1
*&---------------------------------------------------------------------*
FORM f_process_itab1.
  LOOP AT i_itab1 INTO wa_itab1.
**** Proses validasi data
    va_blart = c_blart_re.
    IF wa_itab1-budat EQ space OR wa_itab1-budat EQ 0.
      MOVE sy-datum TO wa_itab1-budat.
    ENDIF.
    IF wa_itab1-zfbdt EQ space OR wa_itab1-zfbdt EQ 0.
      MOVE wa_itab1-budat TO wa_itab1-zfbdt.
    ENDIF.
    PERFORM f_post_f04.
    CLEAR wa_itab1.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_ITAB1

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_ITAB2
*&---------------------------------------------------------------------*
FORM f_process_itab2.
  DATA: l_rbeln(10),
        ld_tabix TYPE int4,
        ld_lines TYPE int4.
  CLEAR page1.
  DESCRIBE TABLE i_itab1 LINES ld_lines.
  PERFORM hitung_record.

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      form   = 'ZFF_VAT_RETURN'
    EXCEPTIONS
      OTHERS = 1.

  SORT i_itab1 BY belnr rbeln DESCENDING.
  LOOP AT i_itab1 INTO wa_itab1.
    CLEAR: cntr,cntr1,va_bukrs,va_belnr,va_gjahr.
    ADD 1 TO page1.
    MOVE wa_itab1-bukrs TO va_bukrs.
    MOVE wa_itab1-belnr TO va_belnr.
    MOVE wa_itab1-gjahr TO va_gjahr.

    MOVE wa_itab1-rbeln TO l_rbeln.
    MOVE wa_itab1-gsber TO va_gsber.
    MOVE wa_itab1-name1 TO va_name1.
    MOVE wa_itab1-name2 TO va_name2.
    MOVE wa_itab1-stras TO va_stras.
    MOVE wa_itab1-ort01 TO va_ort01.
    MOVE wa_itab1-stceg TO va_stceg.
    MOVE wa_itab1-stcd1 TO va_stcd1.
    MOVE wa_itab1-zuonr1 TO va_zuonr1.
    MOVE wa_itab1-bktxt TO va_bktxt.

    PERFORM cek_print.

    AT NEW rbeln.
      PERFORM cetak_form.
    ENDAT.

    va_belnr = wa_itab1-belnr.
    PERFORM print_update USING wa_itab1-belnr.

    ADD 1 TO ld_tabix.
    IF ld_tabix LT ld_lines.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'SKIP'
          window  = 'MAIN'
        EXCEPTIONS
          OTHERS  = 1.
      CLEAR: va_amnt, va_ppn, va_amnt1,
             amnt2, amnt1, amnt3,ppn.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'CLOSE_FORM'.
ENDFORM.                    " F_PROCESS_ITAB2

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_ITAB3
*&---------------------------------------------------------------------*
FORM f_process_itab3 TABLES ft_itab1 LIKE i_itab1
                     USING fu_ucomm.
  DATA: l_rbeln(10),
        ld_tabix TYPE int4,
        ld_lines TYPE int4.

  DATA : options  TYPE itcpo.
  DATA : lt_itab  TYPE ta_itab1 OCCURS 0.

  CLEAR: cntr,cntr1,page1.

  lt_itab[] = i_itab1[].
  DELETE lt_itab WHERE check = space.

  DESCRIBE TABLE lt_itab LINES ld_lines.
  PERFORM hitung_record.

  CASE fu_ucomm.
    WHEN '&POS'.
      options-tdnoprev  = 'X'.
    WHEN '&PREV'.
      options-tdnoprint = 'X'.
  ENDCASE.

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      form    = 'ZFF_VAT_RETURN'
      OPTIONS = options
    EXCEPTIONS
      OTHERS  = 1.

  SORT ft_itab1 BY belnr rbeln DESCENDING.
  LOOP AT ft_itab1 INTO wa_itab1.
    CLEAR: va_bukrs, va_belnr, va_gjahr.
    ADD 1 TO page1.
    MOVE wa_itab1-bukrs TO va_bukrs.
    MOVE wa_itab1-belnr TO va_belnr.
    MOVE wa_itab1-gjahr TO va_gjahr.

    MOVE wa_itab1-rbeln TO l_rbeln.
    MOVE wa_itab1-gsber TO va_gsber.
    MOVE wa_itab1-name1 TO va_name1.
    MOVE wa_itab1-name2 TO va_name2.
    MOVE wa_itab1-stras TO va_stras.
    MOVE wa_itab1-ort01 TO va_ort01.
    MOVE wa_itab1-stceg TO va_stceg.
    MOVE wa_itab1-stenr TO va_stenr.
    MOVE wa_itab1-stcd1 TO va_stcd1.
    MOVE wa_itab1-zuonr1 TO va_zuonr1.
    MOVE wa_itab1-bktxt TO va_bktxt.
    MOVE wa_itab1-lifnr TO va_lifnr.
    MOVE wa_itab1-blart TO va_blart.
    MOVE wa_itab1-budat TO va_date.

    PERFORM cek_print.

    AT NEW rbeln.
      PERFORM cetak_form1 USING fu_ucomm.
      IF fu_ucomm = '&POS'.
        IF p_type3 IS NOT INITIAL.
          PERFORM f_insert_to_table.
        ENDIF.
      ENDIF.
    ENDAT.

    va_belnr = wa_itab1-belnr.
    IF p_type3 IS NOT INITIAL.
      PERFORM print_update USING wa_itab1-belnr.
    ENDIF.

    ADD 1 TO ld_tabix.
    IF ld_tabix LT ld_lines.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'SKIP'
          window  = 'MAIN'
        EXCEPTIONS
          OTHERS  = 1.
      CLEAR: va_amnt,va_ppn,va_amnt1,va_disc,va_dpp,va_ppn,
             amnt2, amnt1, amnt3,ppn.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'CLOSE_FORM'.
ENDFORM.                    " F_PROCESS_ITAB3

*&---------------------------------------------------------------------*
*&      Form  F_SUBMIT_FB03
*&---------------------------------------------------------------------*
FORM f_submit_fb03  USING    p_fu_selfield TYPE slis_selfield.
  DATA: lw_itab1 TYPE ta_itab1.

  IF  p_fu_selfield-fieldname EQ 'BELNR'.
    CLEAR lw_itab1.
    READ TABLE i_itab1 INTO lw_itab1 INDEX p_fu_selfield-tabindex.
    SET PARAMETER ID : 'BLN' FIELD lw_itab1-belnr,
                       'BUK' FIELD p_bukrs,
                       'GJR' FIELD lw_itab1-gjahr.
    CALL TRANSACTION 'FB03'  AND SKIP FIRST SCREEN.
  ENDIF.
ENDFORM.                    " F_SUBMIT_FB03

*&---------------------------------------------------------------------*
*&      Form  F_TAX_CALC
*&---------------------------------------------------------------------*
FORM f_tax_calc  USING    fu_datum fu_wrbtr fu_calty
                 CHANGING fc_wrbtr.
  DATA : lv_wrbtr   TYPE netwr_ak.

  lv_wrbtr  = fu_wrbtr.

  CALL FUNCTION 'Z_PPN11'
    EXPORTING
      pi_wrbtr = lv_wrbtr
      pi_calty = fu_calty
      pi_datum = fu_datum
    IMPORTING
      po_wrbtr = lv_wrbtr.

  fc_wrbtr = lv_wrbtr.
ENDFORM.                    " F_TAX_CALC

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DETAIL
*&---------------------------------------------------------------------*
FORM f_modify_detail  USING    fu_bukrs fu_rbeln fu_gjahr fu_menge2
                      CHANGING fu_wrbtr.
  DATA: ls_detail LIKE LINE OF gt_detail,
        lv_dmbtrs TYPE dmbtr,
        lv_dmbtr  TYPE dmbtr,
        lv_dmbtr2 TYPE dmbtr,
        lv_hasat  TYPE dmbtr,
        lv_lines  TYPE i.

  IF fu_bukrs = '8020'.
    CLEAR: gt_bseg,fu_wrbtr.
    READ TABLE gt_bseg WITH KEY bukrs = fu_bukrs
                                belnr = fu_rbeln
                                gjahr = fu_gjahr.

    PERFORM f_modify_value USING gt_bseg-shkzg gt_bseg-dmbtr
                           CHANGING lv_dmbtrs.

    LOOP AT gt_detail INTO ls_detail.
      CLEAR: lv_dmbtr,lv_hasat,lv_dmbtr2.

      PERFORM f_modify_value USING gt_bseg-shkzg gt_bseg-dmbtr
                             CHANGING lv_dmbtr2.

*      lv_dmbtr = gt_bseg-dmbtr * ls_detail-menge2 / fu_menge2.
*      IF lv_dmbtr GT lv_dmbtrs.
*        lv_dmbtr = lv_dmbtrs.
*      ENDIF.

      lv_dmbtr = lv_dmbtr2 * ls_detail-menge2 / fu_menge2.

      IF gt_bseg-shkzg = 'S'.
        IF lv_dmbtr LT lv_dmbtrs.
          lv_dmbtr = lv_dmbtrs.
        ENDIF.
      ELSE.
        IF lv_dmbtr GT lv_dmbtrs.
          lv_dmbtr = lv_dmbtrs.
        ENDIF.
      ENDIF.

      ADD lv_dmbtr TO ls_detail-dmbtr2.
      WRITE ls_detail-dmbtr2 TO ls_detail-amnt CURRENCY 'IDR' .
      lv_hasat = ls_detail-dmbtr2 / ls_detail-menge2.
      WRITE lv_hasat TO ls_detail-hasat CURRENCY 'IDR'.

      MODIFY gt_detail FROM ls_detail TRANSPORTING dmbtr2 amnt hasat.
      ADD ls_detail-dmbtr2 TO fu_wrbtr.

      SUBTRACT lv_dmbtr FROM lv_dmbtrs.
    ENDLOOP.

    IF lv_dmbtrs IS NOT INITIAL.
      DESCRIBE TABLE gt_detail LINES lv_lines.

      CLEAR lv_hasat.
      ADD lv_dmbtrs TO ls_detail-dmbtr2.
      WRITE ls_detail-dmbtr2 TO ls_detail-amnt CURRENCY 'IDR' .
      lv_hasat = ls_detail-dmbtr2 / ls_detail-menge2.
      WRITE lv_hasat TO ls_detail-hasat CURRENCY 'IDR'.

      MODIFY gt_detail FROM ls_detail
                       INDEX lv_lines
                       TRANSPORTING dmbtr2 amnt hasat.

      ADD ls_detail-dmbtr2 TO fu_wrbtr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_VALUE
*&---------------------------------------------------------------------*
FORM f_modify_value  USING    fu_shkzg fu_dmbtr
                     CHANGING fc_dmbtr.
  IF fu_shkzg = 'S'.
    fc_dmbtr = fu_dmbtr * -1.
  ELSE.
    fc_dmbtr = fu_dmbtr.
  ENDIF.
ENDFORM.                    " F_MODIFY_VALUE
