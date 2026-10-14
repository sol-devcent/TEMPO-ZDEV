*----------------------------------------------------------------------*
***INCLUDE LZTNF_GROUPF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_PR_TNF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PI_DATA  text
*      -->P_PI_PO_ATL  text
*      <--P_PE_TYPE  text
*      <--P_PE_MESSAGE  text
*      <--P_PE_PO_NUMBER  text
*      <--P_PE_PO_DATE  text
*----------------------------------------------------------------------*
FORM f_create_pr_tnf  USING    p_data
                               p_pr_tnf
                      CHANGING p_type
                               p_message
                               p_pr_number
                               p_pr_date.
  TYPES:
    BEGIN OF ts_pr_detail,
      pr_seq                TYPE string,
      pr_produk             TYPE string,
      pr_text               TYPE string,
      pr_produk_qty         TYPE string,
      pr_produk_uom_base    TYPE string,
      pr_produk_amt_price   TYPE string,
      pr_pur_org            TYPE string,
      pr_pur_group          TYPE string,
      pr_delivery_date      TYPE string,
      product_sap           TYPE string,
      product_name          TYPE string,
      product_sap_konvharga TYPE string,
      acct_assignment       TYPE string,
      pr_gl_acc             TYPE string,
      pr_cost_center        TYPE string,
      product_group         TYPE string,
    END OF ts_pr_detail .

  TYPES:
    BEGIN OF tt_pr ,
      pr_company  TYPE string,
      pr_tnf      TYPE string,
      pr_plant    TYPE string,
      pr_tahun    TYPE string,
      pr_type     TYPE string,
      pr_sub_type TYPE string,
      pr_doc_no   TYPE string,
      pr_date     TYPE string,
      pr_desc     TYPE string,
      pr_sap_no   TYPE string,
      type        TYPE string,
      message     TYPE string,
      details     TYPE TABLE OF ts_pr_detail WITH DEFAULT KEY,
    END OF tt_pr .
  TYPES: BEGIN OF ty_pr,
           data TYPE tt_pr, " WITH DEFAULT KEY,
         END OF ty_pr.
  DATA : ls_pr TYPE ty_pr.
  DATA : lv_json_data  TYPE string.
  DATA:  ls_detail TYPE ts_pr_detail.

  DATA: ls_pritem     TYPE          bapimereqitemimp,
        lt_pritem     TYPE TABLE OF bapimereqitemimp,
        ls_pritemx    TYPE          bapimereqitemx,
        lt_pritemx    TYPE TABLE OF bapimereqitemx,
        lt_praccount  TYPE TABLE OF bapimereqaccount,
        ls_praccount  LIKE LINE OF lt_praccount,
        lt_praccountx TYPE TABLE OF bapimereqaccountx,
        ls_praccountx LIKE LINE OF lt_praccountx,
        ls_prheader   TYPE bapimereqheader,
        ls_prheaderx  TYPE bapimereqheaderx,
        lt_return2    TYPE TABLE OF bapiret2,
        ls_return     LIKE LINE OF lt_return2,
        lv_number     LIKE  bapiebanc-preq_no,
        lv_bednr      TYPE eban-bednr,
        lv_date       TYPE sy-datum,
        lv_wertu      TYPE t134m-wertu..
  DATA: lv_name(15).

  lv_json_data = p_data.
  lv_name = p_pr_tnf..
  PERFORM f_create_text_json(ztdsit_i001) USING lv_json_data lv_name '/inbound/tnf/' 'TNF_SENDPO'.

  zcl_json=>deserialize(
      EXPORTING
        json             = lv_json_data
      CHANGING
        data             = ls_pr ).

  lv_bednr = p_pr_tnf.
  SELECT SINGLE banfn erdat INTO (lv_number, lv_date) FROM eban WHERE bednr = lv_bednr.
  IF sy-subrc EQ 0.
    p_type  = 'S'.
    CONCATENATE 'PR no.' lv_bednr 'Sudah terbentuk PR SAP no.' lv_number
    INTO p_message SEPARATED BY space.
    p_pr_number = lv_number.
    p_pr_date = lv_date.
    RETURN.
  ENDIF.
  SET PARAMETER ID  'M_WERKS' FIELD  '1601'.

  LOOP AT ls_pr-data-details INTO ls_detail.
    ls_pritem-plant         = ls_pr-data-pr_plant. "pi_plant_dest.
    ls_pritem-material      = ls_detail-product_sap. "pi_output-material.
    IF ls_detail-product_sap IS NOT INITIAL.
      ls_pritemx-material      = 'X'.
    ENDIF.
    IF ls_pr-data-pr_sub_type NE '05'.
      IF ls_pritem-material IS NOT INITIAL.
        SELECT SINGLE matnr INTO ls_pritem-material FROM marc
          WHERE matnr = ls_pritem-material AND
                werks = ls_pritem-plant.
        IF sy-subrc NE 0.
          ls_pritem-short_text = ls_detail-product_name.
          CONCATENATE ls_pritem-material ls_pritem-short_text
          INTO ls_pritem-short_text SEPARATED BY '-'.
          CLEAR: ls_pritem-material, ls_pritemx-material.
          ls_pritemx-short_text = 'X'.
        ENDIF.
      ELSE.
        ls_pritem-short_text = ls_detail-product_name.
        CLEAR: ls_pritem-material, ls_pritemx-material.
        ls_pritemx-short_text = 'X'.
      ENDIF.
      IF ls_detail-acct_assignment = 'K'.
        ls_pritem-acctasscat   = ls_detail-acct_assignment.
        ls_pritemx-acctasscat  = 'X'.

        ls_praccount-preq_item     = ls_detail-pr_seq. "'10'.
        ls_praccount-creat_date = sy-datum.
        ls_praccount-serial_no = '01'.
        ls_praccount-quantity = ls_detail-pr_produk_qty.
        ls_praccount-unload_pt = ls_pr-data-pr_company. "'unloading point'.
        IF ls_praccount-unload_pt IS NOT INITIAL.
          ls_praccountx-unload_pt = 'X'. "'unloading point'.
        ENDIF.
        IF ls_detail-pr_gl_acc IS NOT INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ls_detail-pr_gl_acc
            IMPORTING
              output = ls_praccount-gl_account.
          ls_praccountx-gl_account = 'X'.
        ENDIF.
        IF ls_detail-pr_cost_center IS NOT INITIAL.
          ls_praccount-profit_ctr = ls_detail-pr_cost_center.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ls_detail-pr_cost_center
            IMPORTING
              output = ls_praccount-profit_ctr.
          ls_praccountx-profit_ctr = 'X'.
        ENDIF.
        ls_praccountx-preq_item     = ls_detail-pr_seq. "'10'.
        ls_praccountx-creat_date = 'X'.
        ls_praccountx-serial_no = '01'.
        ls_praccountx-quantity = 'X'.

        ls_pritem-gr_ind = 'X'. "wa_tpr-wepos.
        ls_pritem-ir_ind = 'X'. "wa_tpr-repos.
        ls_pritemx-gr_ind = 'X'. "wa_tpr-wepos.
        ls_pritemx-ir_ind = 'X'. "wa_tpr-repos.
        APPEND ls_praccount TO lt_praccount.
        APPEND ls_praccountx TO lt_praccountx.
      ENDIF.
    ELSE.
      ls_pritem-material      = ls_detail-product_sap. "pi_output-material.
      ls_pritemx-material      = 'X'.
      SELECT SINGLE matnr INTO ls_pritem-material FROM marc
        WHERE matnr = ls_pritem-material AND
              werks = ls_pritem-plant.
      IF sy-subrc NE 0.
        CONCATENATE 'Material : ' ls_pritem-material 'Belum di-maintenance di SAP'
        INTO p_message SEPARATED BY space.
        p_type = 'E'.
        CLEAR: lt_pritem[].
        RETURN.
      ENDIF.
    ENDIF.
    ls_pritem-preq_item     = ls_detail-pr_seq. "'10'.
    ls_pritem-ctrl_ind      = 'R'.
    ls_pritem-trackingno    = ls_pr-data-pr_doc_no. "pr_tnf.
    ls_pritem-preq_name     = ls_pr-data-pr_company.
    ls_pritem-purch_org     = ls_detail-pr_pur_org. " lv_ekorg.
    ls_pritem-pur_group     = ls_detail-pr_pur_group. "lv_ekgrp.
    ls_pritem-preq_date     = ls_pr-data-pr_date. "lv_date.
    ls_pritem-quantity      = ls_detail-pr_produk_qty. "pi_output-quantity.
    ls_pritem-unit          = ls_detail-pr_produk_uom_base. "pi_output-unitofmeas.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = ls_detail-pr_produk_uom_base
      IMPORTING
        output         = ls_pritem-unit
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF ls_pritem-unit IS INITIAL.
      ls_pritem-unit = 'UNT'.
    ENDIF.
    ls_pritem-deliv_date    = ls_detail-pr_delivery_date. "lv_date.
    ls_pritem-preq_price    = ls_detail-pr_produk_amt_price.
    ls_pritem-price_unit    = ls_detail-product_sap_konvharga.
    CONDENSE ls_detail-product_group.
    IF ls_detail-product_group IS NOT INITIAL.
      ls_pritem-matl_group = ls_detail-product_group.
      ls_pritemx-matl_group = 'X'.
    ENDIF.
    APPEND ls_pritem TO lt_pritem.
    ls_pritemx-preq_item     = ls_pritem-preq_item. "'10'.
    ls_pritemx-preq_itemx    = 'X'.
    ls_pritemx-ctrl_ind      = 'X'.
    ls_pritemx-trackingno    = 'X'.
    ls_pritemx-purch_org     = 'X'.
    ls_pritemx-pur_group     = 'X'.
    ls_pritemx-preq_date     = 'X'.
    ls_pritemx-plant         = 'X'.
    ls_pritemx-quantity      = 'X'.
    ls_pritemx-unit          = 'X'.
    ls_pritemx-deliv_date    = 'X'.
    ls_pritemx-preq_name     = 'X'.
    ls_pritemx-preq_price    = 'X'.
    ls_pritemx-price_unit    = 'X'.
    APPEND ls_pritemx TO lt_pritemx.
    CLEAR: ls_pritem, ls_pritemx, ls_praccount.
  ENDLOOP.
  ls_prheader-pr_type	= ls_pr-data-pr_type. "lv_bsart.
  ls_prheader-ctrl_ind  = 'R'.
  ls_prheaderx-pr_type  = 'X'.
  ls_prheaderx-last_item = '1601'.
  ls_prheaderx-ctrl_ind    = 'X'.
  IF lt_pritem[] IS NOT INITIAL.
    CLEAR: lv_wertu.
    SELECT SINGLE wertu INTO lv_wertu FROM t134m WHERE bwkey = '1601' AND mtart = 'ZPCC'.
    IF lv_wertu NE 'X'.
      UPDATE t134m SET wertu = 'X'
      WHERE bwkey = '1601' AND mtart = 'ZPCC'.
    ENDIF.
    IF lt_praccount[] IS NOT INITIAL.
      CALL FUNCTION 'BAPI_PR_CREATE'
        EXPORTING
          prheader   = ls_prheader
          prheaderx  = ls_prheaderx
        IMPORTING
          number     = lv_number
        TABLES
          return     = lt_return2
          pritem     = lt_pritem
          praccount  = lt_praccount
          praccountx = lt_praccountx
          pritemx    = lt_pritemx.
    ELSE.
      CALL FUNCTION 'BAPI_PR_CREATE'
        EXPORTING
          prheader  = ls_prheader
          prheaderx = ls_prheaderx
        IMPORTING
          number    = lv_number
        TABLES
          return    = lt_return2
          pritem    = lt_pritem
          pritemx   = lt_pritemx.
    ENDIF.
    READ TABLE lt_return2 INTO ls_return WITH KEY type = 'E'.
    IF sy-subrc EQ 0.
      p_type = 'E'.
      CLEAR: p_pr_number, p_pr_date.
      LOOP AT lt_return2 INTO ls_return WHERE type NE 'S'.
        p_message =  ls_return-message.
        "        EXIT.
      ENDLOOP.
    ELSE.
      p_type = 'S'.
      p_pr_number = lv_number.
      p_pr_date = sy-datum.
      LOOP AT lt_return2 INTO ls_return WHERE type EQ 'S'.
        p_message =  ls_return-message.
        EXIT.
      ENDLOOP.
    ENDIF.
    UPDATE t134m SET wertu = ''
    WHERE bwkey = '1601' AND mtart = 'ZPCC'.
  ENDIF.
ENDFORM.
