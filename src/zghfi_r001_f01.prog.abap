*----------------------------------------------------------------------*
***INCLUDE ZTDNFI_I003_F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_get_data.
*  Get data from header, join bsad and kna1 table based on the condition
  DATA: lt_zghfidt001 TYPE STANDARD TABLE OF zghfidt001.
  DATA: ls_zghfidt001 LIKE LINE OF lt_zghfidt001.
  SELECT zghfidt001~vkorg, zghfidt001~vkbur, zghfidt001~vbeln, bsad~zuonr, zghfidt001~kunnr, kna1~name1,
    zghfidt001~kzwi5, zghfidt001~hari, zghfidt001~persen, zghfidt001~reward, zghfidt001~knumh,
    zghfidt001~erdat, zghfidt001~erzet, zghfidt001~ernam, zghfidt001~budat, zghfidt001~waers, bsad~gjahr,
    zghfidt001~wrbtr, bsad~wrbtr AS wrbtr_bsad,
    a945~knumh AS knumh_a945
    INTO CORRESPONDING FIELDS OF TABLE @header
    FROM zghfidt001
    INNER JOIN bsad ON zghfidt001~vbeln = bsad~belnr AND
                       zghfidt001~kunnr = bsad~kunnr
    INNER JOIN kna1 ON kna1~kunnr = bsad~kunnr
    INNER JOIN a945 ON a945~kappl = 'V' AND
                       a945~kschl = 'ZD08' AND
                       a945~vkorg = zghfidt001~vkorg AND
                       a945~kunwe = zghfidt001~kunnr
    WHERE zghfidt001~vkorg = @p_vkorg AND
          zghfidt001~vkbur IN @s_vkbur AND
          zghfidt001~kunnr IN @s_kunnr AND
          zghfidt001~budat IN @s_erdat AND
          bsad~blart = 'RV' AND
          bsad~shkzg = 'S'.

* If header is 1 or more than 1 records
  IF header IS NOT INITIAL.
*    Get data from bsad and retrieve header data based on the condition
    SELECT bukrs, kunnr, umsks, umskz, augdt, augbl, zuonr, gjahr, belnr, buzei, budat, blart
      INTO CORRESPONDING FIELDS OF TABLE @lt_bsad
      FROM bsad FOR ALL ENTRIES IN @header
      WHERE bukrs = @header-vkorg AND zuonr = @header-zuonr AND kunnr = @header-kunnr AND gjahr = @header-gjahr AND blart = 'DZ'.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE  lt_zghfidt001 FROM zghfidt001
      FOR ALL ENTRIES IN header
      WHERE vkorg = header-vkorg
        AND vkbur = header-vkbur
        AND vbeln = header-vbeln.

* Get data from likp and retrieve header data based on the condition
    SELECT vbeln, wadat_ist INTO CORRESPONDING FIELDS OF TABLE @lt_likp
      FROM likp FOR ALL ENTRIES IN @header
      WHERE vbeln = @header-zuonr(10).

* Get data from vbrp and retrieve header data based on the condition
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE detail
      FROM vbrp FOR ALL ENTRIES IN header
      WHERE vkbur = header-vkbur
        AND vbeln = header-vbeln
        AND ( ( mvgr1 = '00' OR mvgr1 = '01' ) OR
         ( matkl LIKE 'ERV%' OR matkl LIKE 'TRF%' ) )
        AND kzwi5 <> 0.
  ENDIF.

* Loop using assigning field symbol
  LOOP AT header ASSIGNING FIELD-SYMBOL(<fs_header>).     "Loop to FS
    READ TABLE lt_bsad INTO DATA(ls_bsad)
                       WITH KEY bukrs = <fs_header>-vkorg
                                zuonr = <fs_header>-zuonr
                                kunnr = <fs_header>-kunnr.
    IF sy-subrc = 0.
      <fs_header>-budat = ls_bsad-budat.
      <fs_header>-belnr = ls_bsad-belnr.
      <fs_header>-gjahr = ls_bsad-gjahr.
    ENDIF.

    READ TABLE lt_likp INTO DATA(ls_likp)
                       WITH KEY vbeln = <fs_header>-zuonr(10).
    IF sy-subrc = 0.
      <fs_header>-wadat_ist = ls_likp-wadat_ist.
    ENDIF.
    <fs_header>-reward = <fs_header>-reward." * 100.
    SORT lt_zghfidt001 BY vkorg vkbur vbeln.
    READ TABLE lt_zghfidt001 INTO ls_zghfidt001
    WITH KEY vkorg = <fs_header>-vkorg
             vkbur = <fs_header>-vkbur
             vbeln = <fs_header>-vbeln.
    IF sy-subrc EQ 0.
      IF ls_zghfidt001-budat IS INITIAL OR ls_zghfidt001-wadat_ist IS INITIAL OR
         ls_zghfidt001-wrbtr IS INITIAL OR ls_zghfidt001-knumh IS INITIAL.
        IF ls_zghfidt001-wrbtr IS INITIAL.
          <fs_header>-wrbtr = <fs_header>-wrbtr_bsad.
        ENDIF.
        IF ls_zghfidt001-knumh IS INITIAL.
          <fs_header>-knumh = <fs_header>-knumh_a945.
        ENDIF.
        UPDATE zghfidt001 SET budat = <fs_header>-budat
                              wadat_ist = <fs_header>-wadat_ist
                              wrbtr = <fs_header>-wrbtr
                              knumh = <fs_header>-knumh
               WHERE vkorg = <fs_header>-vkorg
                 AND vkbur = <fs_header>-vkbur
                 AND vbeln = <fs_header>-vbeln.
      ENDIF.
    ENDIF.
  ENDLOOP.

*  Loop using working area
  LOOP AT detail INTO DATA(row1).     "Loop to WA
    READ TABLE header WITH KEY vbeln = row1-vbeln INTO DATA(row2).
    IF sy-subrc = 0.
      row1-discount = row2-persen * row1-kzwi5 / 100. " * 100.
      row1-kzwi5 = row1-kzwi5. " * 100.
      MODIFY detail FROM row1 TRANSPORTING discount kzwi5.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_data .

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_DOCUMENT_HEADER
*&---------------------------------------------------------------------*
FORM f_document_header . " USING    fu_vbeln.

ENDFORM.                    " F_DOCUMENT_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data .
**  IF gt_ztdnfidt007h[] IS NOT INITIAL.
*  PERFORM f_alv TABLES gt_header gt_detail.
  PERFORM f_alv TABLES header detail.
**  ELSE.
**    MESSAGE i000(zab) WITH 'Tidak ada data'.
**  ENDIF.

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
                          "VALUE(fu_edit)
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

*  ld_fieldcat-do_sum            = fu_dosum.
*  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out        = fu_dec.
  ld_fieldcat-currency          = fu_waers.
*  ld_fieldcat-quantity          = fu_meins.
*  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
*  ld_fieldcat-emphasize         = fu_emphasize.
*  ld_fieldcat-hotspot           = fu_hotspot.
*  ld_fieldcat-edit              = fu_edit.
*  ld_fieldcat-no_zero           = fu_no_zero.

  APPEND ld_fieldcat TO  t_alv_fieldcat.
  CLEAR ld_fieldcat.
ENDFORM.                    " F_FIELDCATG

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report ft_report1.
* Enter field name, reference table and field
  REFRESH: t_alv_fieldcat.
*  itable, fieldname, reference table, reference fieldname, nothing comes out, length of the column name, output column name
  PERFORM f_fieldcatg USING 'HEADER' :
  'VKORG'       ''  '' '' '13' 'Company Code' '' '' '' '' '' '' '' '' '',
  'VKBUR'    ''  '' '' '12' 'Sales Office' '' '' '' '' '' '' '' '' '',
  'VBELN'       ''  '' '13' 'Billing No.' 'Billing No.' 'Billing No.' '' '' '' '' '' '' '' '',
  'ZUONR'       'ZGHFIDT001'  'ZUONR' '' 'DN No.' 'DN No.' 'DN No.' '' '' '' '' '' '' '' '',
  'KUNNR'       ''  '' '' '14' 'Customer Code' '' '' '' '' '' '' '' '' '',
  'NAME1'       ''         '' '' '13' 'Customer Name' '' '' '' '' '' '' '' '' '',
  'WRBTR'       ''  '' '' '13' 'AR Amount' '' '' '' '' '' '' '' 'WAERS' '0',
  'KZWI5'       ''  '' '' '13' 'Amount' '' '' '' '' '' '' '' 'WAERS' '0',
  'WAERS'       'ZGHFIDT001'  'WAERS' '' '' '' '' '' '' '' '' '' '' '' '',
  'HARI'       ''  '' '' '4' 'Days' '' '' '' '' '' '' '' '' '',
  'PERSEN'   ''  '' '' '8' 'Discount' '' '' '' '' '' '' '' '' '',
  'REWARD'  ''  '' '' '14' 'Value Discount' '' '' '' '' '' '' '' 'WAERS' '0',
  'KNUMH'     'ZGHFIDT001'  'KNUMH' '' '15' '' '' '' '' '' '' '' '' '' '',
  'ERDAT'       ''        '' '' 'Entry Date' 'Entry Date' 'Entry Date' '' '' '' '' '' '' '' '',
  'ERZET'       ''        '' '' '10' 'Entry Time' '' '' '' '' '' '' '' '' '',
  'ERNAM'       ''        '' '' '10' 'Entry Name' 'Entry Name' '' '' '' '' '' '' '' '',
  'BUDAT'       ''        '' '' '10' 'Payment Date' '' '' '' '' '' '' '' '' '',
  'WADAT_IST'       ''        '' '' '10' 'GI Date' '' '' '' '' '' '' '' '' '',
  'BELNR'       ''        '' 'X' '16' 'Payment Document' '' '' '' '' '' '' '' '' '',
  'GJAHR'       ''        '' 'X' '5' 'Year' '' '' '' '' '' '' '' '' ''.

  PERFORM f_fieldcatg USING 'DETAIL' :
     'VBELN'       ''  '' '' '11' 'Billing No.' '' '' '' '' '' '' '' '' '',
     'POSNR'    '' '' '' '3' 'Nou' '' '' '' '' '' '' '' '' '',
     'MATNR'       'VBRP'  'MATNR' '' '10' '' '' '' '' '' '' '' '' '' '',
     'ARKTX'       ''         '' '' '15' 'Material Description' '' '' '' '' '' '' '' '' '',
     'KZWI5'       '' '' '' '6' 'Amount' '' '' '' '' '' '' '' 'WAERS' '0',
     'MVGR1'       'VBRP'  'MVGR1' '' '16' '' '' '' '' '' '' '' '' '' '',
     'MATKL'       'VBRP'  'MATKL' '' '14' '' '' '' '' '' '' '' '' '' '',
     'DISCOUNT'   ''  '' '' '30' 'Cash discount (Value Discount)' '' '' '' '' '' '' '' 'WAERS' '0'.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'HEADER'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = 'DETAIL'
    CHANGING
      ct_fieldcat            = t_alv_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

ENDFORM.                    " F_BUILD_FIELDCAT

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
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.
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

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.

  REFRESH: lt_dynpread.
  DATA: vbeln_var TYPE ty_header.

  CASE fu_ucomm.
    WHEN '&EXECUTE'.
    WHEN '&IC1'.
      READ TABLE header INDEX fu_selfield-tabindex INTO vbeln_var.
      IF sy-subrc = 0.
        CASE fu_selfield-fieldname.
          WHEN 'VBELN'.
            SET PARAMETER ID 'VF' FIELD vbeln_var-vbeln.
            CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
          WHEN 'BELNR'.
            SET PARAMETER ID 'BLN' FIELD vbeln_var-belnr.
            SET PARAMETER ID 'BUK' FIELD vbeln_var-vkorg.
            SET PARAMETER ID 'GJR' FIELD vbeln_var-gjahr.
            CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
          WHEN 'ZUONR'.
            SET PARAMETER ID 'VL' FIELD vbeln_var-zuonr.
            CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
        ENDCASE.
      ENDIF.
**      IF rb_1 = 'X'.
**        PERFORM f_proses_data.
**      ENDIF.
      "      LEAVE TO SCREEN 0.

  ENDCASE.

*  CASE i_ucomm.
*    WHEN '&IC1'.
*      READ TABLE header INDEX header-vbeln INTO header.
*      IF sy-subrc = 0.
*        CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
*      ENDIF.
*   ENDCASE.
ENDFORM.                    "F_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_KEYINFO
*&---------------------------------------------------------------------*
FORM f_build_keyinfo  USING    fu_keyinfo TYPE slis_keyinfo_alv.
*  fu_keyinfo-header01 = 'VKBUR'.
*  fu_keyinfo-item01   = 'VKBUR'.
  fu_keyinfo-header01 = 'VBELN'.
  fu_keyinfo-item01   = 'VBELN'.
ENDFORM.                    " F_BUILD_KEYINFO


*&---------------------------------------------------------------------*
*&      Form  F_ALV
*&---------------------------------------------------------------------*
FORM f_alv TABLES ft_report ft_report2.
  DATA: lv_title    TYPE lvc_title.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report ft_report2.         "1. List display field
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].                "2. Field sorting
  PERFORM f_build_keyinfo     USING   d_alv_keyinfo.                "3. Join field
  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.

  PERFORM f_build_event       TABLES  t_alv_event[].

*  Initialize variant layout variable with the p_layout
  d_alv_variant-variant = p_layout.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
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
      i_tabname_header         = 'HEADER'
      i_tabname_item           = 'DETAIL'
      is_keyinfo               = d_alv_keyinfo
      is_print                 = d_print
    TABLES
      t_outtab_header          = ft_report
      t_outtab_item            = ft_report2
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.


ENDFORM.                    "F_ALV
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
  fu_layout-expand_fieldname   = 'EXPAND'.
  fu_layout-expand_all         = 'X'.
  "  fu_layout-expand_all = 'X'.
**  IF rb_1 = 'X'.
**    fu_layout-box_fieldname      = 'CHKBX'.
**  ENDIF.
*  fu_layout-box_fieldname      = 'CHECK'.
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
  ld_sort-tabname   = 'DETAIL'.
  ld_sort-fieldname = 'VBELN'.
  ld_sort-spos      = '01'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-tabname   = 'DETAIL'.
  ld_sort-fieldname = 'POSNR'.
  ld_sort-spos      = '02'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.


**  CLEAR ld_sort.
**  ld_sort-fieldname = 'FKDAT'.
**  ld_sort-up        = 'X'.
**  APPEND ld_sort TO fu_sort.

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
*&      Form  F_LAST_DAY
*&---------------------------------------------------------------------*
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
