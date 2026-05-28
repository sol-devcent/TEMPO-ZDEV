*----------------------------------------------------------------------*
*   INCLUDE ZM_AUTO_DNF01
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM F_INIT_DATA
*---------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    "F_INIT_DATA

*---------------------------------------------------------------------*
*       FORM F_GET_DATA
*---------------------------------------------------------------------*
FORM f_get_data.

  CASE 'X'.
    WHEN radio1.
      SELECT vbeln vstel vkorg wadat
        FROM likp
        INTO TABLE gt_likp
        WHERE vbeln EQ pa_vbeln
          AND vstel EQ pa_vstel
          AND vkorg EQ pa_vkorg.
    WHEN radio2.
      SELECT vbeln vstel vkorg wadat
        FROM likp
        INTO TABLE gt_likp
        WHERE vbeln IN so_vbeln
          AND vstel EQ pa_vstel
          AND vkorg EQ pa_vkorg
          AND erdat IN so_erdat.
  ENDCASE.

  IF gt_likp[] IS NOT INITIAL.
    SELECT vbeln posnr matnr charg lfimg vrkme vgbel vgpos uecha
      FROM lips
      INTO TABLE gt_lips
      FOR ALL ENTRIES IN gt_likp
      WHERE vbeln EQ gt_likp-vbeln.

    SELECT vbeln
      FROM vbuk
      INTO TABLE gt_vbuk
      FOR ALL ENTRIES IN gt_likp
      WHERE vbeln EQ gt_likp-vbeln
        AND wbstk EQ 'C'.

    CASE 'X'.
      WHEN radio1.
        LOOP AT gt_likp.
          PERFORM f_read_text USING gt_likp-vbeln gt_likp-vbeln
                              CHANGING gt_text-vbeln gt_text-lines.
          APPEND gt_text.
          CLEAR gt_text.
        ENDLOOP.
    ENDCASE.
  ENDIF.
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

  PERFORM f_fieldcatg USING ft_report:
    'VBELN' 'LIKP' 'VBELN' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
    'POSNR' 'LIPS' 'POSNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MATNR' 'LIPS' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'CHARG' 'LIPS' 'CHARG' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'LFIMG' 'LIPS' 'LFIMG' '' '' '' '' '' '' '' '' '' 'VRKME' '' '' '',
    'VRKME' 'LIPS' 'VRKME' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'VGBEL' 'LIPS' 'VGBEL' '' '' '' '' 'X' '' '' '' '' '' '' '' '',
    'VGPOS' 'LIPS' 'VGPOS' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  IF radio2 EQ 'X'.
    PERFORM f_fieldcatg USING ft_report:
      'GI_NO' '' '' '' '12' 'GI. No.' '' 'X' '' '' '' '' '' '' '' ''.
  ENDIF.
  PERFORM f_fieldcatg USING ft_report:
    'VSTEL' 'EKPV' 'VSTEL' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'XBLNR' 'EKBE' 'XBLNR' '' '' '' '' 'X' '' '' '' '' '' '' '' ''.

  CASE 'X'.
    WHEN radio2.
      PERFORM f_fieldcatg USING ft_report:
        'DN_NO' '' '' '' '12' 'Auto DN. No.' '' 'X' '' '' '' '' '' ''
        '' ''.
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
  IF radio1 EQ 'X'.
    fu_layout-box_fieldname      = 'CHECK'.
  ENDIF.
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
  ld_sort-group     = 'UL'.
  APPEND ld_sort TO fu_sort.

  CLEAR ld_sort.
  ld_sort-fieldname = 'POSNR'.
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
  CASE 'X'.
    WHEN radio1.
      IF gv_status IS INITIAL.
        SET PF-STATUS 'TOEXECUTE'.
      ELSE.
        SET PF-STATUS 'ERRORLOG'.
      ENDIF.
    WHEN radio2.
      SET PF-STATUS 'STANDARD'.
  ENDCASE.
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
  SORT gt_lips BY vbeln posnr.
  SORT gt_vbuk BY vbeln.

  LOOP AT gt_lips.
    READ TABLE gt_text WITH KEY vbeln = gt_lips-vbeln.
    IF sy-subrc EQ 0.
      CONTINUE.
    ELSE.
      READ TABLE gt_vbuk WITH KEY vbeln = gt_lips-vbeln
                         BINARY SEARCH.
      IF sy-subrc EQ 0.
        gt_out  = gt_lips.
        gt_out-check  = '2'.

        ON CHANGE OF gt_lips-vbeln.
          CLEAR gt_out-check.
        ENDON.

        PERFORM f_bapi_po_getdetail
        USING gt_lips-vbeln gt_lips-vgbel gt_lips-vgpos
              gt_lips-uecha
        CHANGING gt_out-vstel gt_out-xblnr gt_out-dn_no
                 gt_out-gi_no.

        APPEND gt_out.
        CLEAR gt_out.

        gt_batch-ebeln       = gt_lips-vgbel.
        gt_batch-ebelp       = gt_lips-vgpos.
        gt_batch-mblnr       = gt_lips-vbeln.
        gt_batch-menge       = gt_lips-lfimg.
        gt_batch-matnr       = gt_lips-matnr.
        gt_batch-charg       = gt_lips-charg.
        gt_batch-posnr       = gt_lips-posnr.
        gt_batch-uecha       = gt_lips-uecha.
        COLLECT gt_batch.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PROCESS_DATA

*---------------------------------------------------------------------*
*       FORM F_USER_COMMAND
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.
  DATA: lt_dynpread   LIKE dynpread OCCURS 0 WITH HEADER LINE,
        lv_vgbel      TYPE vgbel,
        lv_vbeln      TYPE vbeln_vl,
        lv_mblnr      TYPE mblnr,
        lv_dn(10),
        lv_gi(10).

  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&IC1'.
      IF fu_selfield-value IS NOT INITIAL.
        CASE fu_selfield-sel_tab_field.
          WHEN 'GT_OUT-VBELN'.
            lv_vbeln  = fu_selfield-value.
            SET PARAMETER ID 'VL' FIELD lv_vbeln.
            CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
          WHEN 'GT_OUT-VGBEL'.
            lv_vgbel  = fu_selfield-value.
            SET PARAMETER ID 'BES' FIELD lv_vgbel.
            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
          WHEN 'GT_OUT-XBLNR'.
            lv_vgbel  = fu_selfield-value.
            SET PARAMETER ID 'BES' FIELD lv_vgbel.
            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
          WHEN 'GT_OUT-DN_NO'.
            lv_vbeln  = fu_selfield-value.
            SET PARAMETER ID 'VL' FIELD lv_vbeln.
            CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
          WHEN 'GT_OUT-GI_NO'.
            lv_mblnr  = fu_selfield-value.
            SET PARAMETER ID 'MBN' FIELD lv_mblnr.
            CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.
        ENDCASE.
      ENDIF.

    WHEN '&POS'.
      PERFORM f_post_entries TABLES gt_error
                             CHANGING lv_dn lv_gi.
      IF gt_error[] IS INITIAL.
        IF lv_dn IS INITIAL.
          MESSAGE e000(zab)
          WITH 'There was an error when creating delivery'.
          LEAVE TO SCREEN 0.
        ELSEIF lv_gi IS INITIAL.
          MESSAGE e000(zab)
          WITH 'There was an error when posting goods issue'.
          LEAVE TO SCREEN 0.
        ELSE.
          MESSAGE s000(zab)
          WITH 'Data already processed' lv_dn '/' lv_gi.
          LEAVE TO SCREEN 0.
        ENDIF.
      ELSE.
        READ TABLE gt_error WITH KEY type = 'E'.
        IF sy-subrc EQ 0.
          gv_status = 1.
          MESSAGE s000(zab)
          WITH 'There is an error during the process'.
          PERFORM f_alv TABLES gt_out.
          LEAVE TO SCREEN 0.
        ELSE.
          IF lv_dn IS INITIAL.
            MESSAGE e000(zab)
            WITH 'There was an error when creating delivery'.
            LEAVE TO SCREEN 0.
          ELSEIF lv_gi IS INITIAL.
            MESSAGE e000(zab)
            WITH 'There was an error when posting goods issue'.
            LEAVE TO SCREEN 0.
          ELSE.
            MESSAGE s000(zab)
            WITH 'Data already processed' lv_dn '/' lv_gi.
            LEAVE TO SCREEN 0.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN '&LOG'.
      CALL SCREEN 500 STARTING AT 10 10 ENDING AT 132 22.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_POST_ENTRIES
*&---------------------------------------------------------------------*
FORM f_post_entries TABLES ft_error STRUCTURE gt_error
                    CHANGING fc_dn fc_gi.
  DATA: lwa_out   LIKE gt_out,
        lt_out    LIKE gt_out OCCURS 0 WITH HEADER LINE,
        lv_error  TYPE sy-subrc.

  lt_out[] = gt_out[].
  LOOP AT gt_out INTO lwa_out WHERE check EQ 'X'.
    CLEAR: gv_vbeln, gv_vbnum.

    PERFORM f_create_sto TABLES lt_out ft_error
                         USING lwa_out
                         CHANGING gv_vbeln gv_vbnum.

    IF gv_vbeln IS NOT INITIAL.
      PERFORM f_change_delivery USING lwa_out
                                      gv_vbeln gv_vbnum
                                CHANGING lv_error fc_gi.
      fc_dn = gv_vbeln.
    ENDIF.
  ENDLOOP.
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
*&      Form  F_BAPI_PO_GETDETAIL
*&---------------------------------------------------------------------*
FORM f_bapi_po_getdetail  USING    fu_vbeln fu_vgbel fu_vgpos fu_uecha
                          CHANGING fc_vstel fc_xblnr fc_dn_no fc_gi_no.

  DATA: lv_ebeln       TYPE ebeln,
        lv_ebelp       TYPE ebelp,
        lv_lines       TYPE tdline,
        lv_vbeln       TYPE vbeln_vl,
        poitem         LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
        poshippingexp  LIKE bapimeposhippexp OCCURS 0 WITH HEADER LINE,
        pohistory      LIKE bapiekbe OCCURS 0 WITH HEADER LINE,
        lt_hist        LIKE bapiekbe OCCURS 0 WITH HEADER LINE.

  lv_ebeln  = fu_vgbel.
  lv_ebelp  = fu_vgpos.

  CLEAR: pohistory[], pohistory[].
  DO 2 TIMES.
    CLEAR: poitem[], poitem, poshippingexp[], poshippingexp.
    CALL FUNCTION 'BAPI_PO_GETDETAIL1'
      EXPORTING
        purchaseorder = lv_ebeln
      TABLES
        poitem        = poitem
        poshippingexp = poshippingexp
        pohistory     = pohistory.

    IF sy-subrc EQ 0.
      IF fu_uecha IS INITIAL.
        READ TABLE poitem WITH KEY po_item = lv_ebelp.
        IF sy-subrc EQ 0.
          lv_ebeln  = poitem-trackingno.
          READ TABLE poshippingexp WITH KEY po_item = lv_ebelp.
          IF sy-subrc EQ 0.
            fc_vstel  = poshippingexp-ship_point.
          ENDIF.
        ENDIF.
      ENDIF.

      READ TABLE pohistory WITH KEY po_item   = lv_ebelp
                                    hist_type = 'U'.
      IF sy-subrc EQ 0.
        fc_xblnr  = pohistory-ref_doc_no.
      ENDIF.
    ENDIF.
  ENDDO.

  CASE 'X'.
    WHEN radio2.
      IF fu_uecha IS INITIAL.
        PERFORM f_document_flow USING fu_vbeln
                                CHANGING fc_gi_no.

        PERFORM f_read_text USING fu_vbeln gt_likp-vbeln
                            CHANGING lv_vbeln lv_lines.
        fc_dn_no  = lv_lines(10).
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_BAPI_PO_GETDETAIL

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_STO
*&---------------------------------------------------------------------*
FORM f_create_sto  TABLES   ft_out STRUCTURE gt_out
                            ft_error STRUCTURE gt_error
                   USING    fwa_out STRUCTURE gt_out
                   CHANGING fc_vbeln fc_vbnum.

  DATA: stock_trans_item  LIKE bapidlvreftosto OCCURS 0
                          WITH HEADER LINE,
        serial_numbers    LIKE bapidlvserialnumber OCCURS 0
                          WITH HEADER LINE,
        return            LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF lt_shpt OCCURS 0,
          vstel   TYPE vstel,
        END OF lt_shpt.

  DATA: lv_lines    TYPE i,
        lv_xblnr    TYPE xblnr.

  CLEAR: stock_trans_item[], stock_trans_item, serial_numbers[],
         serial_numbers, return[], return.

  LOOP AT ft_out WHERE vbeln EQ fwa_out-vbeln.
    lv_xblnr  = ft_out-xblnr.
    stock_trans_item-ref_doc     = ft_out-xblnr.
    stock_trans_item-ref_item    = ft_out-vgpos.
*    stock_trans_item-dlv_qty     = ft_out-lfimg.
*    stock_trans_item-sales_unit  = ft_out-vrkme.
    COLLECT stock_trans_item.
    CLEAR stock_trans_item.

    IF ft_out-vstel IS NOT INITIAL.
      lt_shpt-vstel  = ft_out-vstel.
      COLLECT lt_shpt.
      CLEAR lt_shpt.
    ENDIF.
  ENDLOOP.

  LOOP AT stock_trans_item.
    MOVE-CORRESPONDING stock_trans_item TO serial_numbers.
    APPEND serial_numbers.
  ENDLOOP.

  CLEAR: stock_trans_item, serial_numbers.

  DESCRIBE TABLE lt_shpt LINES lv_lines.
  IF lv_lines EQ 0.
    ft_error-type   = 'E'.
    ft_error-ebeln  = ft_out-vgbel.
    ft_error-msg    = 'List contains no data'.
    APPEND ft_error.
  ELSEIF lv_lines GT 1.
    ft_error-type   = 'E'.
    ft_error-ebeln  = ft_out-vgbel.
    ft_error-msg    = 'There is a difference Shipping Point'.
    APPEND ft_error.
  ELSEIF lv_lines EQ 1.
    READ TABLE lt_shpt INDEX 1.

    CALL FUNCTION 'BAPI_OUTB_DELIVERY_CREATE_STO'
      EXPORTING
        ship_point        = lt_shpt-vstel
      IMPORTING
        delivery          = fc_vbeln
        num_deliveries    = fc_vbnum
      TABLES
        stock_trans_items = stock_trans_item
        serial_numbers    = serial_numbers
        return            = return.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.

  IF return[] IS NOT INITIAL.
    LOOP AT return.
      ft_error-type   = return-type.
      ft_error-ebeln  = lv_xblnr.
      ft_error-msg    = return-message.
      APPEND ft_error.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_CREATE_STO

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DELIVERY
*&---------------------------------------------------------------------*
FORM f_change_delivery  USING    fwa_out STRUCTURE gt_out
                                 fu_vbeln fu_vbnum
                        CHANGING fc_error fc_gi.
  DATA: header_data     LIKE bapiobdlvhdrchg,
        header_control  LIKE bapiobdlvhdrctrlchg,
        delivery        LIKE bapiobdlvhdrchg-deliv_numb,
        techn_control   LIKE bapidlvcontrol,
        item_data       LIKE bapiobdlvitemchg OCCURS 0
                        WITH HEADER LINE,
        item_control    LIKE bapiobdlvitemctrlchg OCCURS 0
                        WITH HEADER LINE,
        return          LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

  DATA: lt_batch  LIKE gt_batch OCCURS 0 WITH HEADER LINE.

  CLEAR: lt_batch[], lt_batch.

  lt_batch[] = gt_batch[].
  DELETE lt_batch WHERE uecha IS NOT INITIAL.

  SORT lt_batch BY ebeln ebelp.
  DELETE ADJACENT DUPLICATES FROM lt_batch COMPARING ebeln ebelp.

  header_data-deliv_numb    = fu_vbeln.
  header_control-deliv_numb = fu_vbeln.
  delivery                  = fu_vbeln.

  techn_control-upd_ind     = 'U'.

  LOOP AT lt_batch WHERE ebeln EQ fwa_out-vgbel.
    LOOP AT gt_batch WHERE ebeln EQ lt_batch-ebeln
                       AND ebelp EQ lt_batch-ebelp
                       AND mblnr EQ fwa_out-vbeln.
      IF gt_batch-charg IS NOT INITIAL.
        item_data-deliv_numb      = fu_vbeln.
        item_data-hieraritem      = lt_batch-posnr.
        item_data-usehieritm      = '1'.
        item_data-material        = gt_batch-matnr.
        item_data-batch           = gt_batch-charg.
        item_data-dlv_qty         = gt_batch-menge.
        item_data-dlv_qty_imunit  = gt_batch-menge.
        item_data-fact_unit_nom   = '1'.
        item_data-fact_unit_denom = '1'.
        APPEND item_data.
      ELSE.
        item_data-deliv_numb      = fu_vbeln.
        item_data-hieraritem      = lt_batch-posnr.
        item_data-usehieritm      = '1'.
        item_data-material        = gt_batch-matnr.
        item_data-batch           = gt_batch-charg.
        item_data-dlv_qty         = 0.
        item_data-dlv_qty_imunit  = 0.
        item_data-fact_unit_nom   = '1'.
        item_data-fact_unit_denom = '1'.
        APPEND item_data.
      ENDIF.

      item_control-deliv_numb   = fu_vbeln.
      item_control-deliv_item   = gt_batch-posnr.
      item_control-chg_delqty   = 'X'.
      APPEND item_control.
    ENDLOOP.

    CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
      EXPORTING
        header_data    = header_data
        header_control = header_control
        delivery       = delivery
        techn_control  = techn_control
      TABLES
        item_data      = item_data
        item_control   = item_control
        return         = return.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    CLEAR: item_data[], item_data, item_control[], item_control,
           return[], return.
  ENDLOOP.

  IF return[] IS INITIAL.
    PERFORM f_post_goods_issue USING fu_vbeln fwa_out-vbeln
                               CHANGING fc_gi.
  ENDIF.
ENDFORM.                    " F_CHANGE_DELIVERY

*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
  SET PF-STATUS space.
ENDMODULE.                 " STATUS_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_0500  OUTPUT
*&---------------------------------------------------------------------*
MODULE list_processing_0500 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_error_log.
ENDMODULE.                 " LIST_PROCESSING_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_LOG
*&---------------------------------------------------------------------*
FORM f_error_log .
  DATA: lv_zebra  TYPE i.

  WRITE: / sy-uline(121).
  FORMAT COLOR 1.
  WRITE: / sy-vline, (20) 'Document',
           sy-vline, (94) 'Message',
           sy-vline.
  WRITE: / sy-uline(121).
  FORMAT COLOR OFF.
  LOOP AT gt_error.
    IF lv_zebra IS INITIAL.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED ON.
      lv_zebra  = 1.
    ELSE.
      FORMAT COLOR 2.
      FORMAT INTENSIFIED OFF.
      lv_zebra  = 0.
    ENDIF.
    WRITE: / sy-vline, (20) gt_error-ebeln,
             sy-vline, (94) gt_error-msg,
             sy-vline.
  ENDLOOP.
  WRITE: / sy-uline(121).
ENDFORM.                    " F_ERROR_LOG

*&---------------------------------------------------------------------*
*&      Form  F_POST_GOODS_ISSUE
*&---------------------------------------------------------------------*
FORM f_post_goods_issue USING fu_vbeln fu_vbeln1
                        CHANGING fc_gi.
  DATA: ls_header_data    TYPE bapiobdlvhdrcon,
        ls_header_control TYPE bapiobdlvhdrctrlcon,
        lt_return         TYPE STANDARD TABLE OF bapiret2,
        lt_deadlines      TYPE STANDARD TABLE OF bapidlvdeadln,
        lwa_deadlines     TYPE bapidlvdeadln,
        lv_timestamp      TYPE tzntstmps,
        lv_time           TYPE systtimlo,
        lv_wadat          TYPE wadak,
        lv_dn_no          TYPE vbeln_nach,
        text_lines        LIKE ibiptextln OCCURS 0 WITH HEADER LINE.

  ls_header_data-deliv_numb = fu_vbeln.
  ls_header_control-deliv_numb = fu_vbeln.
  ls_header_control-post_gi_flg = 'X'.
  ls_header_control-gdsi_date_flg = 'X'.

  CLEAR: lv_timestamp, lv_time.
  lv_time = '120000'.

  PERFORM f_timestamp USING sy-datum lv_time
                      CHANGING lv_timestamp.

* Populate Actual Goods Issue Date
  CLEAR: lt_deadlines[], lwa_deadlines.
  lwa_deadlines-deliv_numb = fu_vbeln.
  lwa_deadlines-timetype   = 'WSHDRWADTI'.
  lwa_deadlines-timestamp_utc = lv_timestamp.
  APPEND lwa_deadlines TO lt_deadlines.

  CLEAR: lwa_deadlines, lv_wadat.
  READ TABLE gt_likp WITH KEY vbeln = fu_vbeln1.
  IF sy-subrc EQ 0.
    lv_wadat  = gt_likp-wadat.
  ENDIF.

  PERFORM f_timestamp USING lv_wadat lv_time
                      CHANGING lv_timestamp.

  lwa_deadlines-deliv_numb = fu_vbeln.
  lwa_deadlines-timetype   = 'WSHDRWADAT'.
  lwa_deadlines-timestamp_utc = lv_timestamp.
  APPEND lwa_deadlines TO lt_deadlines.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CONFIRM_DEC'
    EXPORTING
      header_data      = ls_header_data
      header_control   = ls_header_control
      delivery         = fu_vbeln
    TABLES
      header_deadlines = lt_deadlines
      return           = lt_return.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  IF lt_return[] IS INITIAL.
    PERFORM f_document_flow USING fu_vbeln1
                            CHANGING lv_dn_no.
* Header text for KMM delivery
    text_lines-tdobject   = 'VBBK'.
    text_lines-tdname     = fu_vbeln1.
    text_lines-tdid       = 'ZH06'.
    text_lines-tdspras    = sy-langu.
    CONCATENATE fu_vbeln lv_dn_no INTO text_lines-tdline
    SEPARATED BY '/'.
    APPEND text_lines.

    CALL FUNCTION 'RFC_SAVE_TEXT'
      TABLES
        text_lines = text_lines.

* Header text for Inter company delivery
    CLEAR: text_lines[], text_lines.
    text_lines-tdobject   = 'VBBK'.
    text_lines-tdname     = fu_vbeln.
    text_lines-tdid       = 'ZH06'.
    text_lines-tdspras    = sy-langu.
    text_lines-tdline     = fu_vbeln1.
    APPEND text_lines.

    CALL FUNCTION 'RFC_SAVE_TEXT'
      TABLES
        text_lines = text_lines.

    fc_gi = lv_dn_no.

    UPDATE likp SET anzpk = pa_anzpk
                WHERE vbeln EQ fu_vbeln.
  ENDIF.
ENDFORM.                    " F_POST_GOODS_ISSUE

*&---------------------------------------------------------------------*
*&      Form  F_TIMESTAMP
*&---------------------------------------------------------------------*
FORM f_timestamp  USING    fu_datum fu_time
                  CHANGING fc_timestamp.
  CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
    EXPORTING
      i_datlo     = fu_datum
      i_timlo     = fu_time
    IMPORTING
      e_timestamp = fc_timestamp.
ENDFORM.                    " F_TIMESTAMP

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_modify_screen_1000 .
  CASE 'X'.
    WHEN radio1.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'VB2' OR 'ERD'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
    WHEN radio2.
      LOOP AT SCREEN.
        CASE screen-group1.
          WHEN 'VB1' OR 'ANZ'.
            screen-active  = 0.
        ENDCASE.
        MODIFY SCREEN.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_MODIFY_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF pa_vkorg IS INITIAL.
    PERFORM f_error_selection_screen USING 'VKO' ''.
  ENDIF.
  IF pa_vstel IS INITIAL.
    PERFORM f_error_selection_screen USING 'VST' ''.
  ENDIF.
  IF radio1 EQ 'X'.
    IF pa_vbeln IS INITIAL.
      PERFORM f_error_selection_screen USING 'VB1' ''.
    ENDIF.
    IF pa_anzpk IS INITIAL.
      PERFORM f_error_selection_screen USING 'ANZ' ''.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_error_selection_screen  USING    fu_group fu_error.
  DATA: lv_mess(100).

  CASE fu_error.
    WHEN '0'.
      lv_mess = 'Fill in all required entry fields'.
    WHEN '1'.
      lv_mess = 'Error in Posting date'.
  ENDCASE.
  LOOP AT SCREEN.
    IF screen-group1 = fu_group.
      screen-input  = 1.
    ELSE.
      screen-input  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  MESSAGE e000(zab) WITH lv_mess.
ENDFORM.                    " F_ERROR_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_DOCUMENT_FLOW
*&---------------------------------------------------------------------*
FORM f_document_flow  USING    fu_vbeln
                      CHANGING fc_dn_no.
  DATA: lv_control      LIKE bapidlvbuffercontrol,
        lt_vbeln        LIKE bapidlv_range_vbeln OCCURS 0
                        WITH HEADER LINE,
        lt_docflow      LIKE bapidocflow OCCURS 0 WITH HEADER LINE,
        lt_return       LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

  lv_control-doc_flow     = 'X'.
  lt_vbeln-sign           = 'I'.
  lt_vbeln-option         = 'EQ'.
  lt_vbeln-deliv_numb_low = fu_vbeln.
  APPEND lt_vbeln.

  CALL FUNCTION 'BAPI_DELIVERY_GETLIST'
    EXPORTING
      is_dlv_data_control = lv_control
    TABLES
      it_vbeln            = lt_vbeln
      et_document_flow    = lt_docflow
      return              = lt_return.
  IF sy-subrc EQ 0.
    DELETE lt_docflow WHERE vbtyp_n NE 'R'.
    SORT lt_docflow BY vbeln DESCENDING.
    READ TABLE lt_docflow INDEX 1.
    IF sy-subrc EQ 0.
      fc_dn_no  = lt_docflow-vbeln.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DOCUMENT_FLOW

*&---------------------------------------------------------------------*
*&      Form  F_READ_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_NAME  text
*      <--P_GT_TEXT_VBELN  text
*      <--P_GT_TEXT_LINES  text
*----------------------------------------------------------------------*
FORM f_read_text  USING    fu_name fu_vbeln
                  CHANGING fc_vbeln fc_lines.
  DATA: lines     LIKE tline OCCURS 0 WITH HEADER LINE,
        lv_name   TYPE tdobname.

  CLEAR: lines[], lines.

  lv_name = fu_name.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ZH06'
      language                = sy-langu
      name                    = lv_name
      object                  = 'VBBK'
    TABLES
      lines                   = lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  IF lines[] IS NOT INITIAL.
    READ TABLE lines INDEX 1.
    IF sy-subrc EQ 0.
      fc_vbeln = fu_vbeln.
      fc_lines = lines-tdline.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_READ_TEXT
