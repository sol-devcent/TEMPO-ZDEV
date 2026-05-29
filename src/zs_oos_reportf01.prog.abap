*----------------------------------------------------------------------*
*   INCLUDE ZS_OOS_REPORTF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.
  SELECT SINGLE waers
    FROM t001
    INTO gv_waers
    WHERE bukrs = pa_vkorg.

  IF pa_vkorg = '8070'.
    pa_kkber = '8070'.
  ENDIF.
ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.
  PERFORM f_get_data_fr_legacy.

  PERFORM f_get_quotation_document.

  CHECK gt_quotation[] IS NOT INITIAL.

  PERFORM f_get_data_for_discontinued.

  PERFORM f_get_document_sales.

  CHECK gt_sales[] IS NOT INITIAL.

  PERFORM f_get_delivery.

ENDFORM.                    "F_GET_DATA

*---------------------------------------------------------------------*
*       FORM F_PRINT_DATA
*---------------------------------------------------------------------*
FORM f_print_data.
  PERFORM f_alv TABLES gt_out.
ENDFORM.                    "F_PRINT_DATA

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

  PERFORM f_build_event       TABLES  t_alv_event[].
  lv_func    = 'REUSE_ALV_LIST_DISPLAY'.

  CALL FUNCTION lv_func
    EXPORTING
      i_callback_program       = d_repid
      i_callback_pf_status_set = 'F_SET_PF_STATUS'
      i_callback_user_command  = 'F_USER_COMMAND'
      i_grid_title             = lv_title
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
  PERFORM f_fieldcatg USING 'GT_OUT' :
    'VKBUR' 'VBAK' 'VKBUR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'BSTNK' 'VBAK' 'BSTNK' '' '15' 'PO Number (SAP)' '' '' '' '' '' '' '' ''
    '' '',
    'VBELN' 'VBAK' 'VBELN' '' '25' 'Quot No.(SAP)/PO Lgc.' '' '' '' '' '' '' '' ''
    '' '',
    'ERDAT' 'VBAK' 'ERDAT' '' '10' 'PO Date' '' '' '' '' '' '' '' '' ''
    '',
    'MATNR' '' 'MATNR' '' '11' 'PO Material' '' '' '' '' '' '' '' '' ''
    '',
    'MATKL' 'MARA' 'MATKL' '' '' '' '' '' '' '' '' '' '' '' ''
    '',
    'PRDH1' '' '' '' '9' 'Principal' '' '' '' '' '' '' '' '' ''
    '',
    'PRDH2' '' '' '' '9' 'Prd.Group' '' '' '' '' '' '' '' '' ''
    '',
    'PRDH3' '' '' '' '9' 'Sub Prd.' '' '' '' '' '' '' '' '' ''
    '',
    'MAKTX' '' 'MAKTX' '' '25' 'PO Material Descriptions' '' '' '' ''
    '' '' '' '' '' '',
    'KNKLI' 'VBAK' 'KNKLI' '' '' 'Outlet' '' '' '' '' '' '' '' '' '' '',
    'NAME1' 'KNA1' 'NAME1' '' '' 'Name' '' '' '' '' '' '' '' '' '' '',
    'KDGRP' 'KNVV' 'KDGRP' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KVGR3' 'VBAK' 'KVGR3' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KVGR4' 'VBAK' 'KVGR4' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KWMENG' 'VBAP' 'KWMENG' '' '' 'PO Qty' '' '' '' '' '' '' 'VRKME' '' ''
    '',
    'VRKME' 'VBAP' 'VRKME' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'KZWI1' 'VBAP' 'KZWI1' '' '' 'PO Amount' '' '' '' '' '' 'WAERK' '' ''
    '' '',
    'WAERK' 'VBAP' 'WAERK' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
    'DLNUM' '' 'DLNUM' '' '10' 'DO Number' '' '' '' '' '' '' '' '' ''
    '',
    'DLDAT' '' 'DLDAT' '' '10 ' 'DO Date' '' '' '' '' '' '' '' '' '' '',
    'DLMAT' '' 'DLMAT' '' '11' 'DO Material' '' '' '' '' '' '' '' '' ''
    '',
    'DLMATX' '' 'DLMATX' '' '25' 'DO Material Descriptions' '' '' '' ''
    '' '' '' '' '' '',
    'DLQTY' 'VBAP' 'KWMENG' '' '8' 'DO Qty' '' '' '' '' '' '' 'DLVRKM' '' ''
    '',
    'DLVRKM' 'VBAP' 'VRKME' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
    'DLVAL' 'VBAP' 'KZWI1' '' '11' 'DO Amount' '' '' '' '' '' 'DLWAE' '' ''
    '' '',
    'DLWAE' 'VBAP' 'WAERK' 'X' '' '' '' '' '' '' '' '' '' '' '' '',
    'DISVAL' 'VBAP' 'KZWI1' '' '17' 'Discontinued Val.' '' '' '' '' ''
    'WAERK' '' '' '' '',
    'DISQTY' 'VBAP' 'KWMENG' '' '17' 'Discontinued Qty.' '' '' '' '' '' ''
    'VRKME' '' '' '',
    'OTHVAL' 'VBAP' 'KZWI1' '' '17' 'Other Val.' '' '' '' '' ''
    'WAERK' '' '' '' '',
    'OTHQTY' 'VBAP' 'KWMENG' '' '17' 'Other Qty.' '' '' '' '' '' ''
    'VRKME' '' '' '',
    'OOSVAL' 'VBAP' 'KZWI1' '' '17' 'OOS Val.' '' '' '' '' ''
    'WAERK' '' '' '' '',
    'OOSQTY' 'VBAP' 'KWMENG' '' '17' 'OOS Qty.' '' '' '' '' '' ''
    'VRKME' '' '' '',
    'LOSVAL' 'VBAP' 'KZWI1' '' '17' 'Lost Pick Val.' '' '' '' '' ''
    'WAERK' '' '' '' '',
    'LOSQTY' 'VBAP' 'KWMENG' '' '17' 'Lost Pick Qty.' '' '' '' '' '' ''
    'VRKME' '' '' '',
    'CLTOPQ' 'VBAP' 'KWMENG' '' '17' 'CL/TOP Qty.' '' '' '' '' '' ''
    'VRKME' '' '' '',
    'CLTOPV' 'VBAP' 'KZWI1' '' '17' 'CL/TOP Val.' '' '' '' '' ''
    'WAERK' '' '' '' '',
*    'ABGRU' 'VBAP' 'ABGRU' '' '6' 'Reason' '' '' '' '' '' '' '' '' '' '',
    'BEZEI' '' '' '' '40' 'Reason Reject' '' '' '' '' '' '' '' '' '' ''.
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
  ld_sort-fieldname = 'VBELN'.
  ld_sort-up        = 'X'.
  APPEND ld_sort TO fu_sort.
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
  CLEAR: gt_out, gt_out[].
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
  sy-lsind = 0.
  SET PF-STATUS 'STANDARD'.

  CLEAR ref_grid.
  IF ref_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref_grid.
  ENDIF.
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
  DATA : lv_fonds   TYPE kwmeng,
         lv_fistl   TYPE kwmeng,
         lv_subrc   TYPE sy-subrc,
         lr_abgru   TYPE RANGE OF abgru,
         lv_abgru   LIKE LINE OF lr_abgru,
         lv_cmgst   TYPE flag,
         lv_zero(1).

  DATA : lt_tvagt TYPE TABLE OF tvagt WITH HEADER LINE.

  "Get Reason desc.
  SELECT * INTO TABLE lt_tvagt
    FROM tvagt
    WHERE spras EQ sy-langu.

  lv_abgru-low    = '01'.
  lv_abgru-high   = '02'.
  lv_abgru-sign   = 'I'.
  lv_abgru-option = 'BT'.
  APPEND lv_abgru TO lr_abgru.

  SORT gt_quotation BY vbeln posnr.
  SORT gt_sales BY vgbel vgpos.
  SORT gt_delivery BY vgbel vgpos.
  SORT gt_vbuk BY vbeln.

  LOOP AT gt_quotation.
    CLEAR lt_tvagt.
    READ TABLE lt_tvagt WITH KEY abgru = gt_quotation-abgru.

    gt_out-vkbur    = gt_quotation-vkbur.
    gt_out-vbeln    = gt_quotation-vbeln.
    gt_out-erdat    = gt_quotation-erdat.
    gt_out-matnr    = gt_quotation-matnr.
    gt_out-vrkme    = gt_quotation-vrkme.
    gt_out-kwmeng   = gt_quotation-kwmeng.
    gt_out-waerk    = gt_quotation-waerk.
    gt_out-kzwi1    = gt_quotation-kzwi1.
    gt_out-knkli    = gt_quotation-knkli.
    gt_out-kdgrp    = gt_quotation-kdgrp.
    gt_out-kvgr3    = gt_quotation-kvgr3.
    gt_out-kvgr4    = gt_quotation-kvgr4.
    gt_out-bstnk    = gt_quotation-bstnk.
    gt_out-bezei    = lt_tvagt-bezei.

    PERFORM f_field_modify USING gt_quotation-fonds
                           CHANGING lv_fonds.
    PERFORM f_field_modify USING gt_quotation-fistl
                           CHANGING lv_fistl.

    READ TABLE gt_makt WITH KEY matnr = gt_quotation-matnr.
    IF sy-subrc = 0.
      gt_out-maktx    = gt_makt-maktx.
    ENDIF.

    READ TABLE gt_kna1 WITH KEY kunnr = gt_quotation-knkli.
    IF sy-subrc = 0.
      gt_out-name1    = gt_kna1-name1.
    ENDIF.

    CLEAR gt_sales.
    READ TABLE gt_sales WITH KEY vgbel = gt_quotation-vbeln
                                 vgpos = gt_quotation-posnr
                        BINARY SEARCH.
    IF sy-subrc = 0.
      CLEAR lt_tvagt.
      READ TABLE lt_tvagt WITH KEY abgru = gt_sales-abgru.

      PERFORM f_field_modify USING gt_sales-fonds
                             CHANGING lv_fonds.
      PERFORM f_field_modify USING gt_sales-fistl
                             CHANGING lv_fistl.

      CLEAR : gt_vbuk, lv_zero.
      READ TABLE gt_vbuk WITH KEY vbeln = gt_sales-vbeln BINARY SEARCH.
      IF sy-subrc = 0.
        IF gt_vbuk-cmgst = 'B' OR
          gt_vbuk-cmgst = 'C'.
          gt_out-cltopq = gt_sales-kwmeng.
          gt_out-cltopv = gt_sales-kzwi1.
          lv_zero = 'X'.
        ENDIF.
      ENDIF.

      CLEAR: gt_delivery.
      READ TABLE gt_delivery WITH KEY vgbel = gt_sales-vbeln
                                      vgpos = gt_sales-posnr
                             BINARY SEARCH.
      IF sy-subrc = 0.
        gt_out-dlnum = gt_delivery-vbeln.
        gt_out-dldat  = gt_delivery-erdat.
        gt_out-dlmat  = gt_delivery-matnr.
        gt_out-dlmatx = gt_delivery-arktx.
        gt_out-dlvrkm = gt_sales-vrkme.
        gt_out-dlqty  = gt_sales-kwmeng.
        gt_out-dlwae  = gt_sales-waerk.
        gt_out-dlval  = gt_sales-kzwi1.
      ENDIF.
    ENDIF.

    PERFORM f_discotinued_column USING gt_quotation-matnr gt_quotation-vkbur
                                       gt_out-kzwi1 gt_out-dlval gt_out-kwmeng
                                       gt_out-dlqty
                                 CHANGING gt_out-disval gt_out-disqty.

    IF gt_out-disqty IS INITIAL.
      CLEAR lv_cmgst.
      READ TABLE gt_vbuk WITH KEY vbeln = gt_sales-vbeln.
      IF sy-subrc = 0.
        lv_subrc = sy-subrc.
        lv_cmgst = 'X'.
      ELSE.
        IF gt_sales-abgru IN lr_abgru.
          lv_subrc = sy-subrc.
        ELSE.
          lv_subrc = 4.
          gt_out-oosqty   = lv_fonds.
          gt_out-oosval   = lv_fonds * ( gt_out-kzwi1 / gt_out-kwmeng ).
          gt_out-losqty   = lv_fistl.
          gt_out-losval   = lv_fistl * ( gt_out-kzwi1 / gt_out-kwmeng ).
        ENDIF.
      ENDIF.

      PERFORM f_other_fomula USING gt_sales-vbeln gt_sales-posnr
                                   gt_out-kzwi1 gt_out-dlval
                                   gt_out-oosval gt_out-losval
                                   lv_subrc lv_fonds lv_cmgst
                             CHANGING gt_out-othval gt_out-oosval.
      PERFORM f_other_fomula USING gt_sales-vbeln gt_sales-posnr
                                   gt_out-kwmeng gt_out-dlqty
                                   gt_out-oosqty gt_out-losqty
                                   lv_subrc lv_fonds lv_cmgst
                             CHANGING gt_out-othqty gt_out-oosqty.

      IF gt_out-othqty IS NOT INITIAL.
        gt_out-abgru = gt_sales-abgru.
        gt_out-bezei = lt_tvagt-bezei.
      ENDIF.
    ENDIF.

    IF lv_zero IS NOT INITIAL.
      CLEAR : gt_out-disval, gt_out-disqty, gt_out-othval, gt_out-othqty,
              gt_out-oosval, gt_out-oosqty, gt_out-losval, gt_out-losqty.
    ENDIF.

    APPEND gt_out.
    CLEAR : gt_out, lv_fonds, lv_fistl, lv_subrc.
  ENDLOOP.

  PERFORM f_output_modify.

  PERFORM f_add_data_fr_legacy.

  PERFORM f_product_hierarchy.
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
      CHECK NOT fu_selfield-tabindex IS INITIAL.
      READ TABLE gt_out INDEX fu_selfield-tabindex.
      CASE fu_selfield-sel_tab_field.
        WHEN 'GT_OUT-DLNUM'.
          SET PARAMETER ID 'VL' FIELD gt_out-dlnum.
          CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
        WHEN 'GT_OUT-VBELN'.
          SET PARAMETER ID 'AUN' FIELD gt_out-vbeln.
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
        WHEN OTHERS.
      ENDCASE.

    WHEN '&POS'.
      PERFORM f_post_entries.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries.

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
*&      Form  F_GET_PARAMETERS
*&---------------------------------------------------------------------*
FORM f_get_parameters  USING    fu_value
                       CHANGING fc_value.
  CALL FUNCTION 'ACC_USER_PARAMETER_GET'
    EXPORTING
      i_param_id    = fu_value
    IMPORTING
      e_param_value = fc_value.
ENDFORM.                    " F_GET_PARAMETERS

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
*  LOOP AT SCREEN.
*    IF screen-group1 = 'AUA'.
*      screen-input = '0'.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .

ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_GET_QUOTATION_DOCUMENT
*&---------------------------------------------------------------------*
FORM f_get_quotation_document .
  DATA : lt_mara  LIKE gt_quotation OCCURS 0 WITH HEADER LINE,
         lt_kna1  LIKE gt_quotation OCCURS 0 WITH HEADER LINE.

  SELECT vbak~vbeln vbak~erdat vbak~vkbur bstnk bstdk knkli vbak~kvgr4
         posnr matnr abgru vbap~waerk kwmeng vrkme kzwi1
         fonds fistl
         kdgrp vbak~kvgr3
    FROM vbak JOIN vbap ON vbak~vbeln = vbap~vbeln
              JOIN knvv ON vbak~vkorg = knvv~vkorg
                       AND vbak~vtweg = knvv~vtweg
                       AND vbak~spart = knvv~spart
                       AND vbak~knkli = knvv~kunnr
    INTO CORRESPONDING FIELDS OF TABLE gt_quotation
    WHERE vbak~kkber = pa_kkber
      AND vbak~vkorg = pa_vkorg
      AND vbak~vkbur IN so_vkbur
      AND vbak~auart IN so_auart
      AND vbak~vbeln IN so_vbeln
      AND vbak~erdat IN so_erdat
      AND vbap~matnr IN so_matnr
      AND knvv~kdgrp IN so_kdgrp
      AND vbak~kvgr3 IN so_kvgr3.

  lt_mara[] = gt_quotation[].
  SORT lt_mara BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING matnr.

  IF lt_mara[] IS NOT INITIAL.
    SELECT makt~matnr maktx matkl
      FROM makt JOIN mara ON makt~matnr = mara~matnr
      INTO TABLE gt_makt
      FOR ALL ENTRIES IN lt_mara
      WHERE makt~matnr = lt_mara-matnr
        AND spras = sy-langu.
  ENDIF.

  IF so_matkl[] IS NOT INITIAL.
    LOOP AT gt_quotation.
      READ TABLE gt_makt WITH KEY matnr = gt_quotation.
      IF sy-subrc = 0.
        IF gt_makt-matkl IN so_matkl.
          CONTINUE.
        ELSE.
          DELETE gt_quotation.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  lt_kna1[] = gt_quotation[].
  SORT lt_kna1 BY knkli.
  DELETE ADJACENT DUPLICATES FROM lt_kna1 COMPARING knkli.

  SELECT kunnr name1
    FROM kna1
    INTO TABLE gt_kna1
    FOR ALL ENTRIES IN lt_kna1
    WHERE kunnr = lt_kna1-knkli.
ENDFORM.                    " F_GET_QUOTATION_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DOCUMENT_SALES
*&---------------------------------------------------------------------*
FORM f_get_document_sales .
  DATA : lr_cmgst   TYPE RANGE OF cmgst,
         lv_cmgst   LIKE LINE OF lr_cmgst.

  SELECT vbak~vbeln vbak~vgbel
         posnr vgpos abgru vbap~waerk kwmeng vrkme kzwi1 fonds fistl
    FROM vbak JOIN vbap ON vbak~vbeln = vbap~vbeln
    INTO TABLE gt_sales
    FOR ALL ENTRIES IN gt_quotation
    WHERE vbak~vgbel = gt_quotation-vbeln.

  SORT gt_quotation BY vbeln.
  SORT gt_sales BY vgbel.

*  LOOP AT gt_quotation.
*    READ TABLE gt_sales WITH KEY vgbel = gt_quotation-vbeln
*                        BINARY SEARCH.
*    IF sy-subrc <> 0.
*      DELETE gt_quotation.
*    ENDIF.
*  ENDLOOP.

  CHECK gt_sales[] IS NOT INITIAL.

  lv_cmgst-low    = 'B'.
  lv_cmgst-high   = 'C'.
  lv_cmgst-sign   = 'I'.
  lv_cmgst-option = 'BT'.
  APPEND lv_cmgst TO lr_cmgst.

  SELECT vbeln cmgst
    FROM vbuk
    INTO TABLE gt_vbuk
    FOR ALL ENTRIES IN gt_sales
    WHERE vbeln = gt_sales-vbeln
      AND cmgst IN lr_cmgst.

  SELECT vbeln posnr besta lfsta
    FROM vbup
    INTO TABLE gt_vbup
    FOR ALL ENTRIES IN gt_sales
    WHERE vbeln = gt_sales-vbeln.
ENDFORM.                    " F_GET_DOCUMENT_SALES

*&---------------------------------------------------------------------*
*&      Form  F_GET_DELIVERY
*&---------------------------------------------------------------------*
FORM f_get_delivery .
  SELECT vbeln posnr erdat vgbel vgpos matnr arktx
    INTO CORRESPONDING FIELDS OF TABLE gt_delivery
    FROM lips
    FOR ALL ENTRIES IN gt_sales
    WHERE vgbel = gt_sales-vbeln
      AND fkrel = 'A'.
*      AND matnr IN so_matnr.
ENDFORM.                    " F_GET_DELIVERY

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_MODIFY
*&---------------------------------------------------------------------*
FORM f_field_modify  USING    fu_value
                     CHANGING fc_value.
  DATA : lv_value   TYPE p.

  CONDENSE fu_value NO-GAPS.

  CALL FUNCTION 'MOVE_CHAR_TO_NUM'
    EXPORTING
      chr             = fu_value
    IMPORTING
      num             = lv_value
    EXCEPTIONS
      convt_no_number = 1
      convt_overflow  = 2
      OTHERS          = 3.

  ADD lv_value TO fc_value.
ENDFORM.                    " F_FIELD_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_OTHER_FOMULA
*&---------------------------------------------------------------------*
FORM f_other_fomula  USING    fu_vbeln fu_posnr fu_value1 fu_value2
                              fu_value3 fu_value4 fu_subrc fu_fonds
                              fu_cmgst
                     CHANGING fc_value fc_value1.

  DATA : lv_besta	  TYPE besta,
         lv_lfsta	  TYPE lfsta.

  IF fu_cmgst = 'X'.
    fc_value  = fu_value1 - fu_value2.
  ELSE.
    READ TABLE gt_vbup WITH KEY vbeln = fu_vbeln
                                posnr = fu_posnr.
    IF sy-subrc = 0.
      lv_besta = gt_vbup-besta.
      lv_lfsta = gt_vbup-lfsta.
    ENDIF.

    IF fu_subrc IS INITIAL.
      IF fu_fonds IS INITIAL.
        IF lv_besta = 'A' AND
          lv_lfsta = 'A'.
          fc_value1  = fu_value1 - fu_value2.
        ELSE.
          fc_value  = fu_value1 - fu_value2.
        ENDIF.
      ELSE.
        fc_value  = fu_value1 - fu_value2.
      ENDIF.
    ELSE.
      IF fu_fonds IS INITIAL.
        IF lv_besta = 'A' AND
          lv_lfsta = 'A'.
          fc_value1  = fu_value1 - fu_value2 - fu_value3 - fu_value4.
        ELSE.
          fc_value  = fu_value1 - fu_value2 - fu_value3 - fu_value4.
        ENDIF.
      ELSE.
        fc_value  = fu_value1 - fu_value2 - fu_value3 - fu_value4.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_OTHER_FOMULA

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_FOR_DISCONTINUED
*&---------------------------------------------------------------------*
FORM f_get_data_for_discontinued .
  CHECK gt_makt[] IS NOT INITIAL.

  SELECT matnr
    FROM mvke
    INTO TABLE gt_mvke
    FOR ALL ENTRIES IN gt_makt
    WHERE matnr = gt_makt-matnr
      AND vkorg = pa_vkorg
      AND vmsta <> space.

  SELECT matnr
    FROM mara
    INTO TABLE gt_mara
    FOR ALL ENTRIES IN gt_makt
    WHERE matnr = gt_makt-matnr
      AND mstav <> space.

  SELECT matnr werks
      FROM marc
      INTO TABLE gt_marc
      FOR ALL ENTRIES IN gt_makt
      WHERE matnr = gt_makt-matnr
        AND werks IN so_vkbur
        AND lvorm <> space.
ENDFORM.                    " F_GET_DATA_FOR_DISCONTINUED

*&---------------------------------------------------------------------*
*&      Form  F_DISCOTINUED_COLUMN
*&---------------------------------------------------------------------*
FORM f_discotinued_column  USING    fu_matnr fu_vkbur fu_kzwi1 fu_dlval
                                    fu_kwmeng fu_dlqty
                           CHANGING fc_disval fc_disqty.

  DATA : lv_subrc TYPE sy-subrc.

  CLEAR lv_subrc.
  READ TABLE gt_mvke WITH KEY matnr = fu_matnr.
  IF sy-subrc = 0.
    lv_subrc = sy-subrc.
  ELSE.
    READ TABLE gt_mara WITH KEY matnr = fu_matnr.
    IF sy-subrc = 0.
      lv_subrc = sy-subrc.
    ELSE.
      READ TABLE gt_marc WITH KEY matnr = fu_matnr
                                  werks = fu_vkbur.
      IF sy-subrc = 0.
        lv_subrc = sy-subrc.
      ELSE.
        lv_subrc = sy-subrc.
      ENDIF.
    ENDIF.
  ENDIF.
  IF lv_subrc IS INITIAL.
    fc_disval = fu_kzwi1 - fu_dlval.
    fc_disqty = fu_kwmeng - fu_dlqty.
  ENDIF.
ENDFORM.                    " F_DISCOTINUED_COLUMN

*&---------------------------------------------------------------------*
*&      Form  F_OUTPUT_MODIFY
*&---------------------------------------------------------------------*
FORM f_output_modify .
  DATA : lv_selisih   TYPE kwmeng.

  LOOP AT gt_out.
    CLEAR lv_selisih.

    lv_selisih  = gt_out-kwmeng - gt_out-dlqty.

    IF lv_selisih <= 0.
      CLEAR : gt_out-disval, gt_out-disqty, gt_out-othval, gt_out-othqty,
              gt_out-oosval, gt_out-oosqty, gt_out-losval, gt_out-losqty,
              gt_out-abgru.
      MODIFY gt_out TRANSPORTING disval disqty othval othqty
                                 oosval oosqty losval losqty
                                 abgru.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_OUTPUT_MODIFY

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_FR_LEGACY
*&---------------------------------------------------------------------*
FORM f_get_data_fr_legacy .
  DATA : lt_zsd_po  LIKE gt_zsd_po OCCURS 0 WITH HEADER LINE,
         lv_vbeln   LIKE vbak-vbeln,
         lv_kunnr   LIKE kna1-kunnr.

  SELECT vstel werks lgort
    FROM tvkol
    INTO TABLE gt_tvkol
    WHERE vstel IN so_vkbur.

  IF gt_tvkol[] IS NOT INITIAL.
    SELECT *
      FROM zsd_po
      INTO CORRESPONDING FIELDS OF TABLE gt_zsd_po
      FOR ALL ENTRIES IN gt_tvkol
      WHERE bukrs = pa_vkorg
        AND werks = gt_tvkol-werks
        AND lgort = gt_tvkol-lgort
        AND podat IN so_erdat
        AND matnr IN so_matnr.

    IF so_vbeln[] IS NOT INITIAL.
      LOOP AT gt_zsd_po.
        lv_vbeln  = gt_zsd_po-ponum.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_vbeln
          IMPORTING
            output = lv_vbeln.

        IF lv_vbeln IN so_vbeln.
          CONTINUE.
        ELSE.
          DELETE gt_zsd_po.
        ENDIF.
        CLEAR lv_vbeln.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF gt_zsd_po[] IS NOT INITIAL.
    LOOP AT gt_zsd_po.
      lv_kunnr  = gt_zsd_po-kunnr.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_kunnr
        IMPORTING
          output = lv_kunnr.

      IF lv_kunnr IS NOT INITIAL.
        gt_zsd_po-kunnr = lv_kunnr.
        MODIFY gt_zsd_po TRANSPORTING kunnr.
        CLEAR : lv_kunnr, gt_zsd_po-kunnr.
      ENDIF.
    ENDLOOP.

    CLEAR : lt_zsd_po[], lt_zsd_po.
    lt_zsd_po[] = gt_zsd_po[].
    SORT lt_zsd_po BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_zsd_po COMPARING kunnr.
    SELECT kna1~kunnr name1 kdgrp kvgr3 kvgr4
      FROM kna1 JOIN knvv ON kna1~kunnr = knvv~kunnr
      INTO TABLE gt_kna1leg
      FOR ALL ENTRIES IN lt_zsd_po
      WHERE kna1~kunnr = lt_zsd_po-kunnr
        AND kdgrp IN so_kdgrp
        AND kvgr3 IN so_kvgr3.

    CLEAR : lt_zsd_po[], lt_zsd_po.
    lt_zsd_po[] = gt_zsd_po[].
    SORT lt_zsd_po BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_zsd_po COMPARING matnr.
    SELECT matnr maktx
      FROM makt
      INTO TABLE gt_maktleg
      FOR ALL ENTRIES IN lt_zsd_po
      WHERE matnr = lt_zsd_po-matnr.
  ENDIF.
ENDFORM.                    " F_GET_DATA_FR_LEGACY

*&---------------------------------------------------------------------*
*&      Form  F_ADD_DATA_FR_LEGACY
*&---------------------------------------------------------------------*
FORM f_add_data_fr_legacy .
  DATA : lt_out   LIKE gt_out OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF lt_zsl_dsales OCCURS 0,
           vbeln  LIKE zsl_dsales-vbeln,
           matnr  LIKE zsl_dsales-matnr,
           fkimg  LIKE zsl_dsales-fkimg,
           nsp    LIKE zsl_dsales-nsp,
         END OF lt_zsl_dsales,
         lt_mara  LIKE lt_zsl_dsales OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_makt OCCURS 0,
           matnr  LIKE makt-matnr,
           maktx  LIKE makt-maktx,
           meins  LIKE mara-meins,
         END OF lt_makt.

  LOOP AT gt_zsd_po.
    READ TABLE gt_tvkol WITH KEY werks  = gt_zsd_po-werks
                                 lgort  = gt_zsd_po-lgort.
    IF sy-subrc = 0.
      gt_out-vkbur  = gt_tvkol-vstel.
    ENDIF.
    gt_out-vbeln    = gt_zsd_po-ponum.

    gt_out-matnr    = gt_zsd_po-matnr.
    READ TABLE gt_maktleg WITH KEY matnr = gt_zsd_po-matnr.
    IF sy-subrc = 0.
      gt_out-maktx    = gt_maktleg-maktx.
    ENDIF.

    CONCATENATE gt_zsd_po-legacy_branch '0' gt_zsd_po-dnnum
    INTO gt_out-dlnum.

    CASE gt_zsd_po-bukrs.
      WHEN '8020'.
        CONCATENATE 'C' gt_out-dlnum
        INTO gt_out-dlnum.
      WHEN '8070'.
        CONCATENATE 'D' gt_out-dlnum
        INTO gt_out-dlnum.
    ENDCASE.

    lt_out-dlnum  = gt_out-dlnum.
    APPEND lt_out.
    CLEAR lt_out.

    gt_out-bezei    = gt_zsd_po-reacod.
    gt_out-erdat    = gt_zsd_po-podat.
    gt_out-kwmeng   = gt_zsd_po-menge.
    gt_out-vrkme    = gt_zsd_po-meins.
    gt_out-dldat    = gt_zsd_po-dndat.

    gt_out-knkli    = gt_zsd_po-kunnr.
    APPEND gt_out.
    CLEAR gt_out.
  ENDLOOP.

  IF lt_out[] IS NOT INITIAL.
    SELECT vbeln matnr fkimg nsp
      FROM zsl_dsales
      INTO TABLE lt_zsl_dsales
      FOR ALL ENTRIES IN lt_out
      WHERE vbeln = lt_out-dlnum.

    lt_mara[] = lt_zsl_dsales[].
    SORT lt_mara BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING matnr.

    IF lt_mara[] IS NOT INITIAL.
      SELECT makt~matnr maktx meins
        FROM makt JOIN mara ON makt~matnr = mara~matnr
        INTO TABLE lt_makt
        FOR ALL ENTRIES IN lt_mara
        WHERE makt~matnr = lt_mara-matnr.
    ENDIF.
  ENDIF.

  SORT gt_out BY dlnum matnr.
  SORT lt_zsl_dsales BY vbeln matnr.

  LOOP AT gt_out.
    READ TABLE lt_zsl_dsales WITH KEY vbeln = gt_out-dlnum
                                      matnr = gt_out-matnr
                             BINARY SEARCH.
    IF sy-subrc = 0.
      gt_out-dlmat  = lt_zsl_dsales-matnr.
      READ TABLE lt_makt WITH KEY matnr = lt_zsl_dsales-matnr.
      IF sy-subrc = 0.
        gt_out-dlmatx   = lt_makt-maktx.
        gt_out-dlvrkm   = lt_makt-meins.
      ENDIF.

      gt_out-dlqty  = lt_zsl_dsales-fkimg.
      gt_out-dlval  = lt_zsl_dsales-nsp.
      gt_out-dlwae  = gv_waers.
      gt_out-waerk  = gv_waers.

      CASE gt_out-bezei.
        WHEN '00'.
          gt_out-oosqty = gt_out-kwmeng - gt_out-dlqty.
        WHEN '01' OR '02'.
          gt_out-cltopq = gt_out-kwmeng - gt_out-dlqty.
        WHEN OTHERS.
          gt_out-othqty = gt_out-kwmeng - gt_out-dlqty.
      ENDCASE.

      READ TABLE gt_kna1leg WITH KEY kunnr = gt_out-knkli.
      IF sy-subrc = 0.
        gt_out-name1  = gt_kna1leg-name1.
        gt_out-kdgrp  = gt_kna1leg-kdgrp.
        gt_out-kvgr3  = gt_kna1leg-kvgr3.
        gt_out-kvgr4  = gt_kna1leg-kvgr4.
      ENDIF.
*      gt_out-kzwi1  = ( gt_out-kwmeng /
*                      ( gt_out-dlqty + gt_out-othqty + gt_out-disqty +
*                        gt_out-oosqty + gt_out-cltopq ) ) * gt_out-dlval.

*      CASE gt_out-bezei.
*        WHEN '00'.
*          gt_out-oosval = gt_out-kzwi1 - gt_out-dlval.
*        WHEN '01' OR '02'.
*          gt_out-cltopv = gt_out-kzwi1 - gt_out-dlval.
*        WHEN OTHERS.
*          IF gt_out-bezei IS NOT INITIAL.
*            gt_out-othval = gt_out-kzwi1 - gt_out-dlval.
*          ENDIF.
*      ENDCASE.

      MODIFY gt_out TRANSPORTING dlmat dlmatx dlvrkm dlqty dlval dlwae
                                 waerk kzwi1 oosqty oosval cltopq cltopv
                                 othqty othval name1 kdgrp kvgr3 kvgr4.
    ELSE.
      CASE gt_out-bezei.
        WHEN '00'.
          gt_out-oosqty = gt_out-kwmeng - gt_out-dlqty.
        WHEN '01' OR '02'.
          gt_out-cltopq = gt_out-kwmeng - gt_out-dlqty.
        WHEN OTHERS.
          gt_out-othqty = gt_out-kwmeng - gt_out-dlqty.
      ENDCASE.

      gt_out-dlvrkm   = gt_out-vrkme.
      gt_out-dlwae  = gv_waers.
      gt_out-waerk  = gv_waers.

      READ TABLE gt_kna1leg WITH KEY kunnr = gt_out-knkli.
      IF sy-subrc = 0.
        gt_out-name1  = gt_kna1leg-name1.
        gt_out-kdgrp  = gt_kna1leg-kdgrp.
        gt_out-kvgr3  = gt_kna1leg-kvgr3.
        gt_out-kvgr4  = gt_kna1leg-kvgr4.
      ENDIF.

      MODIFY gt_out TRANSPORTING dlmat dlmatx dlvrkm dlqty dlval dlwae
                                 waerk kzwi1 oosqty oosval cltopq cltopv
                                 othqty othval name1 kdgrp kvgr3 kvgr4.
    ENDIF.
    CLEAR gt_out.
  ENDLOOP.
ENDFORM.                    " F_ADD_DATA_FR_LEGACY

*&---------------------------------------------------------------------*
*&      Form  F_PRODUCT_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_product_hierarchy .
  DATA : lt_out   LIKE gt_out OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_mara OCCURS 0,
           matnr  LIKE mara-matnr,
           matkl  LIKE mara-matkl,
           prdha  LIKE mara-prdha,
         END OF lt_mara.

  DATA : lv_length  TYPE int4.

  lt_out[]  = gt_out[].
  SORT lt_out BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_out COMPARING matnr.

  LOOP AT so_prdha.
    IF so_prdha-option = 'EQ'.
      lv_length = STRLEN( so_prdha-low ).
      IF lv_length <= 6.
        so_prdha-option = 'CP'.
        CONCATENATE so_prdha-low '*' INTO so_prdha-low.
        MODIFY so_prdha TRANSPORTING option low.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lt_out[] IS NOT INITIAL.
    SELECT matnr matkl prdha
      FROM mara
      INTO TABLE lt_mara
      FOR ALL ENTRIES IN lt_out
      WHERE matnr = lt_out-matnr
        AND matkl IN so_matkl
        AND prdha IN so_prdha.
  ENDIF.

  LOOP AT gt_out.
    READ TABLE lt_mara WITH KEY matnr = gt_out-matnr.
    IF sy-subrc = 0.
      gt_out-matkl  = lt_mara-matkl.
      gt_out-prdh1  = lt_mara-prdha(3).
      gt_out-prdh2  = lt_mara-prdha+3(3).
      gt_out-prdh3  = lt_mara-prdha+6(3).
      MODIFY gt_out TRANSPORTING matkl prdh1 prdh2 prdh3.
    ELSE.
      DELETE gt_out.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PRODUCT_HIERARCHY
