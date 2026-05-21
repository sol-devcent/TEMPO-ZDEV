*&---------------------------------------------------------------------*
*&  Include           ZDG2FI_E0007F01
*&---------------------------------------------------------------------*
FORM f_initialization .
  title = 'Input File'.
  %_p_file_%_app_%-text = 'File Name'.
  DEFINE m_fldcat.
    clear x_fldcat.
    x_fldcat-fieldname = &1.
    x_fldcat-key       = &2.
    x_fldcat-seltext_l = &3.
    x_fldcat-currency  = &4.
    x_fldcat-just      = &5.
    x_fldcat-no_out    = &6.
    x_fldcat-datatype  = &7.
    x_fldcat-qfieldname = &8.
    append x_fldcat to t_fldcat.
  END-OF-DEFINITION.
ENDFORM. " F_INITIALIZATION

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_raw TYPE truxs_t_text_data.
  DATA : BEGIN OF lt_tbsl OCCURS 0,
          bschl TYPE tbsl-bschl,
          shkzg TYPE tbsl-shkzg,
         END OF lt_tbsl.
  FIELD-SYMBOLS : <fs_data_raw> LIKE LINE OF t_data_raw.


  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_line_header        = 'X'
      i_tab_raw_data       = lt_raw
      i_filename           = p_file
    TABLES
      i_tab_converted_data = t_data_raw[]
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.


  IF sy-subrc EQ 0.
* move from t_data_raw to t_data
    SELECT bschl shkzg FROM tbsl INTO TABLE lt_tbsl
                                 FOR ALL ENTRIES IN t_data_raw
                                 WHERE bschl = t_data_raw-bschl.
    SORT lt_tbsl BY bschl.
    LOOP AT t_data_raw ASSIGNING <fs_data_raw>.
      MOVE-CORRESPONDING <fs_data_raw> TO x_data.
*      x_data-light = icon_yellow_light.
*      x_data-status = 'Ready'.
      CLEAR lt_tbsl.
      READ TABLE lt_tbsl WITH KEY bschl = x_data-bschl BINARY SEARCH.
      IF lt_tbsl-shkzg = 'H'.
        MULTIPLY x_data-dmbtr BY -1.
        MULTIPLY x_data-wrbtr BY -1.
      ENDIF.
      APPEND x_data TO t_data.
    ENDLOOP.
  ENDIF.
ENDFORM. " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA
*&---------------------------------------------------------------------*
*       tex
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_data .
  PERFORM f_gui_message USING 'Preparing display data ...' ''.
  PERFORM f_build_fieldcat.
  PERFORM f_build_layout.
  PERFORM f_build_sort.
  PERFORM f_build_event.
  PERFORM f_build_event_exit.
  PERFORM f_build_print.

  d_repid = sy-repid.
  x_variant-variant = variant.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = d_repid
      i_callback_pf_status_set = 'F_STATUS_SET'
*     i_background_id    = 'ALV_BACKGROUND'
      i_callback_user_command = 'USER_COMMAND'
      is_layout          = x_layout
      it_fieldcat        = t_fldcat[]
      it_sort            = t_sort[]
      i_default          = 'X'
      i_save             = 'A'
      is_variant         = x_variant
      it_events          = t_events[]
*      it_event_exit      = t_event_exit[]
      is_print           = x_print
    TABLES
      t_outtab           = t_data[]
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM. " F_DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  r_ucomm   text
*----------------------------------------------------------------------*
FORM f_posting_data USING fu_rucomm LIKE sy-ucomm.
  DATA : lx_doc_header TYPE bapiache09,
         lt_accgl TYPE TABLE OF bapiacgl09 WITH HEADER LINE,
         lt_accrec TYPE TABLE OF bapiacar09 WITH HEADER LINE,
         lt_accap TYPE TABLE OF bapiacap09 WITH HEADER LINE,
         lt_acctax TYPE TABLE OF bapiactx09 WITH HEADER LINE,
         lt_curramt TYPE TABLE OF bapiaccr09 WITH HEADER LINE,
         lt_extension TYPE TABLE OF bapiparex WITH HEADER LINE,
         lt_extension1 TYPE TABLE OF bapiacextc WITH HEADER LINE,
         ls_extension1 LIKE LINE OF lt_extension1,
         lt_return TYPE TABLE OF bapiret2 WITH HEADER LINE,
         lt_criteria TYPE TABLE OF bapiackec9 WITH HEADER LINE,
         lv_itemno TYPE bapiacgl09-itemno_acc,
         lt_data LIKE TABLE OF x_data.

  DATA : BEGIN OF lt_tbsl OCCURS 0,
          bschl TYPE tbsl-bschl,
          shkzg TYPE tbsl-shkzg,
          koart TYPE tbsl-koart,
         END OF lt_tbsl.

  FIELD-SYMBOLS : <fs_header> LIKE LINE OF t_data,
                  <fs_item> LIKE LINE OF t_data.

  break dg2_co01.

  lt_data[] = t_data[].
  SORT lt_data BY doc_no.
  DELETE ADJACENT DUPLICATES FROM lt_data COMPARING doc_no.

  SELECT bschl shkzg koart FROM tbsl INTO TABLE lt_tbsl
                           WHERE koart IN ('D','K','S').

  SORT lt_tbsl BY bschl.

  LOOP AT lt_data ASSIGNING <fs_header> WHERE status IS INITIAL OR
                                              status = 'Ready to post'.
* fill document header
    CLEAR lx_doc_header.
    CLEAR : lt_accgl[], lt_accrec[], lt_accap[], lt_curramt[], lt_return[], lt_criteria[].
    CASE fu_rucomm.
      WHEN '&SIM'.
        lx_doc_header-bus_act     = 'RFBU'.
      WHEN '&POS'.
        lx_doc_header-bus_act     = 'RFBU'.
      WHEN '&PARK'.
        lx_doc_header-bus_act     = 'RFBU'.
    ENDCASE.
    lx_doc_header-username = sy-uname.
    lx_doc_header-doc_type = <fs_header>-blart.
    lx_doc_header-doc_date = <fs_header>-bldat.
    lx_doc_header-comp_code = <fs_header>-bukrs.
    lx_doc_header-pstng_date = <fs_header>-budat.
    lx_doc_header-fis_period = <fs_header>-monat.  "Add DID Abaper '14.05.2014
    lx_doc_header-header_txt = <fs_header>-bktxt.
    lx_doc_header-ref_doc_no = <fs_header>-xblnr.
    LOOP AT t_data WHERE doc_no = <fs_header>-doc_no.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = t_data-hkont
        IMPORTING
          output = t_data-hkont.
      ADD 1 TO lv_itemno.
* fill accountgl
      CLEAR lt_tbsl.
      READ TABLE lt_tbsl WITH KEY bschl = t_data-bschl BINARY SEARCH.
      IF sy-subrc EQ 0 AND lt_tbsl-koart = 'S'. "G/L accounts
        CLEAR lt_accgl.
        lt_accgl-itemno_acc = lv_itemno.
        lt_accgl-gl_account = t_data-hkont.
        lt_accgl-item_text = t_data-sgtxt.
        lt_accgl-ref_key_1 = t_data-xref1.
        lt_accgl-ref_key_2 = t_data-xref2.
        lt_accgl-ref_key_3 = t_data-xref3.
        lt_accgl-doc_type = t_data-blart.
        lt_accgl-comp_code = t_data-bukrs.
        lt_accgl-bus_area = t_data-gsber.
        lt_accgl-func_area = t_data-fkber.
*        lt_accgl-costcenter = t_data-kostl.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = t_data-kostl
          IMPORTING
            output = lt_accgl-costcenter.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = t_data-prctr
          IMPORTING
            output = lt_accgl-profit_ctr.

*        lt_accgl-profit_ctr = t_data-prctr.
        lt_accgl-alloc_nmbr = t_data-zuonr.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = t_data-aufnr
          IMPORTING
            output = lt_accgl-orderid.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = t_data-vbund
          IMPORTING
            output = lt_accgl-trade_id.


*        lt_accgl-trade_id = t_data-vbund.

        lt_accgl-tax_code = t_data-mwskz.

*        lt_accgl-orderid = t_data-aufnr.
        APPEND lt_accgl.
      ENDIF.
* fill accountar
      CLEAR lt_tbsl.
      READ TABLE lt_tbsl WITH KEY bschl = t_data-bschl BINARY SEARCH.
      IF sy-subrc EQ 0 AND lt_tbsl-koart = 'D'. "Customer
        CLEAR lt_accrec.
        lt_accrec-itemno_acc = lv_itemno.
        lt_accrec-customer = t_data-hkont.
        lt_accrec-ref_key_1 = t_data-xref1.
        lt_accrec-ref_key_2 = t_data-xref2.
        lt_accrec-ref_key_3 = t_data-xref3.
        lt_accrec-comp_code = t_data-bukrs.
        lt_accrec-bus_area = t_data-gsber.
        lt_accrec-pmnttrms = t_data-zterm.
        lt_accrec-bline_date = t_data-zfbdt.
        lt_accrec-pymt_meth = t_data-zlsch.
        lt_accrec-pmnt_block = t_data-zlspr.
        lt_accrec-paymt_ref = t_data-kidno.
        lt_accrec-alloc_nmbr = t_data-zuonr.
        lt_accrec-c_ctr_area = t_data-kkber.
*        lt_accrec-tax_code = t_data-mwskz.
        lt_accrec-item_text = t_data-sgtxt.
        lt_accrec-sp_gl_ind = t_data-umskz.
*        lt_accrec-profit_ctr = t_data-prctr.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = t_data-prctr
          IMPORTING
            output = lt_accrec-profit_ctr.
*        lt_accrec-businessplace = t_data-bupla. "not used
        lt_accrec-tax_code = t_data-mwskz.

        APPEND lt_accrec.
      ENDIF.
* fill accountap
      CLEAR lt_tbsl.
      READ TABLE lt_tbsl WITH KEY bschl = t_data-bschl BINARY SEARCH.
      IF sy-subrc EQ 0 AND lt_tbsl-koart = 'K'. "Vendor
        CLEAR lt_accap.
        lt_accap-itemno_acc = lv_itemno.
        lt_accap-vendor_no = t_data-hkont.
        lt_accap-ref_key_1 = t_data-xref1.
        lt_accap-ref_key_2 = t_data-xref2.
        lt_accap-ref_key_3 = t_data-xref3.
        lt_accap-comp_code = t_data-bukrs.
        lt_accap-bus_area = t_data-gsber.
        lt_accap-pmnttrms = t_data-zterm.
        lt_accap-bline_date = t_data-zfbdt.
        lt_accap-pymt_meth = t_data-zlsch.
        lt_accap-pmnt_block = t_data-zlspr.
        lt_accap-alloc_nmbr = t_data-zuonr.
*        lt_accap-tax_code = t_data-mwskz.
        lt_accap-item_text = t_data-sgtxt.
        lt_accap-sp_gl_ind = t_data-umskz.
*        lt_accap-profit_ctr = t_data-prctr.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = t_data-prctr
          IMPORTING
            output = lt_accap-profit_ctr.
*        lt_accap-businessplace = t_data-bupla.
        lt_accap-tax_code = t_data-mwskz.

        APPEND lt_accap.
      ENDIF.
* fill currency amount (doc currency)
      CLEAR lt_curramt.
      lt_curramt-itemno_acc = lv_itemno.
      lt_curramt-curr_type = '00'. "doc currency
      lt_curramt-currency = t_data-waers.
      lt_curramt-exch_rate = t_data-kursf.
* remark by jony - 15.08.2013
*      CLEAR lt_tbsl.
*      READ TABLE lt_tbsl WITH KEY bschl = t_data-bschl BINARY SEARCH.
*      IF sy-subrc EQ 0 AND lt_tbsl-shkzg = 'H'.
*        MULTIPLY t_data-wrbtr BY -1.
*      ENDIF.
* remark end
      lt_curramt-amt_doccur = t_data-wrbtr.
      IF t_data-wrbtr NE 0.
        APPEND lt_curramt.
      ENDIF.
* fill currency amount (loc currency)
      CLEAR lt_curramt.
      lt_curramt-itemno_acc = lv_itemno.
      lt_curramt-curr_type = '10'. "loc currency
*      lt_curramt-currency = t_data-waers.
      lt_curramt-currency = 'IDR'.
      lt_curramt-exch_rate = t_data-kursf.
* remark by jony - 15.08.2013
*      CLEAR lt_tbsl.
*      READ TABLE lt_tbsl WITH KEY bschl = t_data-bschl BINARY SEARCH.
*      IF sy-subrc EQ 0 AND lt_tbsl-shkzg = 'H'.
*        MULTIPLY t_data-dmbtr BY -1.
*      ENDIF.
* remark end
      lt_curramt-amt_doccur = t_data-dmbtr.
      IF t_data-dmbtr NE 0 AND t_data-waers NE 'IDR'. "Local currency cannot filled in amount IDR
        APPEND lt_curramt.
      ENDIF.
* fill extension table (posting key and business place)
*      CLEAR lt_extension.
*      lt_extension-structure = 'POSTING_KEY'.
*      lt_extension-valuepart1 = lv_itemno.
*      lt_extension-valuepart2 = t_data-bschl.
*      APPEND lt_extension.
*      CLEAR lt_extension.
*      lt_extension-structure = 'BUSINESS_PLACE'.
*      lt_extension-valuepart1 = lv_itemno.
*      lt_extension-valuepart2 = t_data-bupla.
*      APPEND lt_extension.

      "fill copa data
      IF t_data-vkorg_copa IS NOT INITIAL.
        CLEAR lt_criteria.
        lt_criteria-itemno_acc        = lv_itemno.
        lt_criteria-fieldname         = 'VKORG'.
        lt_criteria-character         = t_data-vkorg_copa.
        APPEND lt_criteria.
      ENDIF.
      IF t_data-kndnr_copa IS NOT INITIAL.
        CLEAR lt_criteria.
        lt_criteria-itemno_acc        = lv_itemno.
        lt_criteria-fieldname         = 'KNDNR'.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = t_data-kndnr_copa
          IMPORTING
            output = t_data-kndnr_copa.
        lt_criteria-character         = t_data-kndnr_copa.
        APPEND lt_criteria.
      ENDIF.
      IF t_data-bukrs_copa IS NOT INITIAL.
        CLEAR lt_criteria.
        lt_criteria-itemno_acc        = lv_itemno.
        lt_criteria-fieldname         = 'BUKRS'.
        lt_criteria-character         = t_data-bukrs_copa.
        APPEND lt_criteria.
      ENDIF.
      IF t_data-werks_copa IS NOT INITIAL.
        CLEAR lt_criteria.
        lt_criteria-itemno_acc        = lv_itemno.
        lt_criteria-fieldname         = 'WERKS'.
        lt_criteria-character         = t_data-werks_copa.
        APPEND lt_criteria.
      ENDIF.
      IF t_data-vkbur_copa IS NOT INITIAL.
        CLEAR lt_criteria.
        lt_criteria-itemno_acc        = lv_itemno.
        lt_criteria-fieldname         = 'VKBUR'.
        lt_criteria-character         = t_data-vkbur_copa.
        APPEND lt_criteria.
      ENDIF.
      IF t_data-prctr_copa IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = t_data-prctr_copa
          IMPORTING
            output = t_data-prctr_copa.

        CLEAR lt_criteria.
        lt_criteria-itemno_acc        = lv_itemno.
        lt_criteria-fieldname         = 'PRCTR'.
        lt_criteria-character         = t_data-prctr_copa.
        APPEND lt_criteria.
      ENDIF.
      IF t_data-spart_copa IS NOT INITIAL.
        CLEAR lt_criteria.
        lt_criteria-itemno_acc        = lv_itemno.
        lt_criteria-fieldname         = 'SPART'.
        lt_criteria-character         = t_data-spart_copa.
        APPEND lt_criteria.
      ENDIF.
      IF t_data-kunwe_copa IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = t_data-kunwe_copa
          IMPORTING
            output = t_data-kunwe_copa.

        CLEAR lt_criteria.
        lt_criteria-itemno_acc        = lv_itemno.
        lt_criteria-fieldname         = 'KUNWE'.
        lt_criteria-character         = t_data-kunwe_copa.
        APPEND lt_criteria.
      ENDIF.
      IF t_data-artnr_copa IS NOT INITIAL.
        CLEAR lt_criteria.
        lt_criteria-itemno_acc        = lv_itemno.
        lt_criteria-fieldname         = 'ARTNR'.
        lt_criteria-character         = t_data-artnr_copa.
        APPEND lt_criteria.
      ENDIF.
      IF t_data-matkl_copa IS NOT INITIAL.
        CLEAR lt_criteria.
        lt_criteria-itemno_acc        = lv_itemno.
        lt_criteria-fieldname         = 'MATKL'.
        lt_criteria-character         = t_data-matkl_copa.
        APPEND lt_criteria.
      ENDIF.
      IF t_data-extwg_copa IS NOT INITIAL.
        CLEAR lt_criteria.
        lt_criteria-itemno_acc        = lv_itemno.
        lt_criteria-fieldname         = 'EXTWG'.
        lt_criteria-character         = t_data-extwg_copa.
        APPEND lt_criteria.
      ENDIF.
    ENDLOOP.

    IF lt_criteria[] IS NOT INITIAL.
      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
        EXPORTING
          documentheader    = lx_doc_header
        TABLES
          accountgl         = lt_accgl
          accountreceivable = lt_accrec
          accountpayable    = lt_accap
          currencyamount    = lt_curramt
          criteria          = lt_criteria
          extension1        = lt_extension1
*        extension2        = lt_extension
          return            = lt_return.
    ELSE.
      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
        EXPORTING
          documentheader    = lx_doc_header
        TABLES
          accountgl         = lt_accgl
          accountreceivable = lt_accrec
          accountpayable    = lt_accap
          currencyamount    = lt_curramt
          extension1        = lt_extension1
*        extension2        = lt_extension
          return            = lt_return.
    ENDIF.
    READ TABLE lt_return WITH KEY type = 'S'. "success
    IF sy-subrc EQ 0 AND lt_return-message_v2 IS NOT INITIAL.
      IF fu_rucomm = '&POS' OR
         fu_rucomm = '&PARK'.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.
      LOOP AT t_data ASSIGNING <fs_item> WHERE doc_no = <fs_header>-doc_no.
        <fs_item>-light = icon_green_light.
        IF fu_rucomm = '&SIM'.
          <fs_item>-status = 'Ready to post'.
        ELSEIF fu_rucomm = '&POS' OR
          fu_rucomm = '&PARK'.
          CONCATENATE 'Document ' lt_return-message_v2(10) 'posted successfully'
                      INTO <fs_item>-status SEPARATED BY space.
        ENDIF.
        MODIFY t_data FROM <fs_item> TRANSPORTING light status.
      ENDLOOP.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      LOOP AT t_data ASSIGNING <fs_item> WHERE doc_no = <fs_header>-doc_no.
        READ TABLE lt_return INDEX 2.
        <fs_item>-light = icon_red_light.
        <fs_item>-status = lt_return-message.
        MODIFY t_data FROM <fs_item> TRANSPORTING light status.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM. " F_POSTING_DATA
