*----------------------------------------------------------------------*
***INCLUDE LZTDS_APIF09 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_CONTRACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_DATA  text
*      <--P_LV_RETURN  text
*      <--P_GV_STR  text
*----------------------------------------------------------------------*
FORM f_get_data_contract  USING    p_data
                          CHANGING p_return
                                   p_str.
  TYPES : BEGIN OF text,
            line(1500),
          END OF text.
  DATA : lt_response_body     TYPE TABLE OF text WITH HEADER LINE.
  DATA: lv_err(1).
  DATA:  lv_str TYPE string.
  DATA: lv_proses(15) VALUE 'MOB_CONTRACT'.
  DATA: lv_data(20).
  lv_data = p_data.
  CONCATENATE '{ "no_package": "' lv_data '" } ' INTO lt_response_body-line.
  APPEND lt_response_body.
  PERFORM f_get_data_json_json(ztdsit_i001) TABLES   lt_response_body
                                       USING    lv_proses
                                       CHANGING lv_str lv_err.
  FIND 'sales_off' IN lv_str.
  IF sy-subrc EQ 0.
    p_str = lv_str.
    CLEAR: p_return.
  ELSE.
    p_return = 'E'.
    p_str = lv_str.
  ENDIF.
ENDFORM.                 " F_GET_DATA_CONTRACT
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_JSON_CONTRACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_STR  text
*      <--P_P_SALES_ORDER  text
*      <--P_P_MESSAGE  text
*      <--P_P_STATUS  text
*----------------------------------------------------------------------*
FORM f_convert_json_contract  USING    p_str
                     CHANGING p_sales_order
                              p_message
                              p_status.
  TYPES: BEGIN OF ty_detail,
           material   TYPE string,
           target_qty TYPE string,
         END OF ty_detail.
  TYPES: BEGIN OF ty_header,
           sales_off    TYPE string,
           confirm_date TYPE string,
           purch_date   TYPE string,
           purch_no_c   TYPE string,
           ct_valid_f   TYPE string,
           ct_valid_t   TYPE string,
           partn_number TYPE string,
           order_item   TYPE STANDARD TABLE OF ty_detail WITH NON-UNIQUE DEFAULT KEY,
         END OF ty_header.

  TYPES: BEGIN OF ty_mob,
           result TYPE STANDARD TABLE OF ty_header WITH NON-UNIQUE DEFAULT KEY,
         END OF ty_mob.

  DATA: ls_order_header_in TYPE  bapisdhd1.
  DATA: lv_salesdocument LIKE  bapivbeln-vbeln.
  DATA: lt_return TYPE STANDARD TABLE OF bapiret2.
  DATA: lt_order_items_in TYPE STANDARD TABLE OF bapisditm.
  DATA: lt_order_partners TYPE STANDARD TABLE OF bapiparnr.
  DATA: lt_order_text TYPE STANDARD TABLE OF  bapisdtext.
  DATA: ls_return TYPE bapiret2.
  DATA: ls_order_items_in TYPE bapisditm.
  DATA: ls_order_partners TYPE bapiparnr.
  DATA: ls_order_text TYPE bapisdtext.
  DATA: ls_mob TYPE ty_mob.
  DATA: ls_header TYPE ty_header.
  DATA: ls_order_detail TYPE ty_detail.
  DATA:   lv_json_data     TYPE string.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer.
  DATA :       convert(1).
  DATA: lv_message(250).
  DATA: BEGIN OF ls_respon,
          no_package    TYPE string,
          no_contract   TYPE string,
          date_contract TYPE string,
          message       TYPE string,
        END OF ls_respon.
  DATA: lv_bstkd LIKE vbkd-bstkd_m.
  DATA: lv_vbeln LIKE vbkd-vbeln.
  DATA: lv_erdat LIKE vbak-erdat.
  DATA: ls_zmobsddt001 TYPE zmobsddt001.
  DATA: lv_nama(15).

  convert = 'X'.
  CLEAR: ls_zmobsddt001.

  lv_json_data = p_str.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_mob ).
  CLEAR: ls_order_header_in, lt_order_partners[], ls_order_partners, lt_order_text[],
         ls_order_text, ls_order_items_in, lt_order_items_in[], lt_return[], ls_return.
  ls_zmobsddt001-zproject = 'MOB'.
  ls_zmobsddt001-zevent   = 'MOB_CONTRACT'.
  ls_zmobsddt001-no_contract = gv_contract.
  IF ls_mob IS NOT INITIAL.
    LOOP AT ls_mob-result INTO ls_header.
      ls_order_header_in-sales_org = '8020'.
      ls_order_header_in-sales_off = ls_header-sales_off. ", sSlsOff)
      ls_zmobsddt001-vkbur = ls_header-sales_off.
      ls_order_header_in-doc_type = 'ZCB2'.
      ls_order_header_in-distr_chan = '10'. ", "10")
      ls_order_header_in-division = '00'. ", "00")
      ls_order_header_in-ord_reason = 'A12'. ", "A12")
      ls_order_header_in-dlvschduse = 'M'. ", "M")
      ls_order_header_in-req_date_h = ls_header-confirm_date. ", sConfDt)
      ls_order_header_in-purch_date = ls_header-purch_date. ", sPackageDt)
      ls_order_header_in-purch_no_c = ls_header-purch_no_c. ", sPackage)
      lv_bstkd = ls_header-purch_no_c.
      ls_order_header_in-qt_valid_t = ls_header-confirm_date. ", sConfDt)
      ls_order_header_in-price_date = ls_header-confirm_date. ", sConfDt)
      ls_order_header_in-dun_date = ls_header-confirm_date. ", sConfDt)
      ls_order_header_in-ct_valid_f = ls_header-ct_valid_f. ", sValidFrDt)
      ls_order_header_in-ct_valid_t = ls_header-ct_valid_t. ", sValidToDt)
      ls_order_partners-partn_role = 'AG'.
      ls_order_partners-partn_numb = ls_header-partn_number.
      APPEND ls_order_partners TO lt_order_partners.
      ls_order_text-text_id = '0002'.
      ls_order_text-langu = 'EN'.
      ls_order_text-text_line = 'ORDER BPJS'.
      APPEND ls_order_text TO lt_order_text.
      LOOP AT ls_header-order_item INTO ls_order_detail.
        ls_order_items_in-material = ls_order_detail-material.
        ls_order_items_in-cust_mat22 = ls_order_detail-material.
        ls_order_items_in-plant = ls_header-sales_off.
        ls_order_items_in-dlv_prio = '06'.
        ls_order_items_in-target_qty = ls_order_detail-target_qty.
        APPEND ls_order_items_in TO lt_order_items_in.
      ENDLOOP.
    ENDLOOP.
    IF lv_bstkd IS INITIAL.
      lv_bstkd = gv_contract.
    ENDIF.
    CONDENSE lv_bstkd.
    SELECT SINGLE a~vbeln erdat  INTO (lv_vbeln, lv_erdat)
      FROM vbkd AS a JOIN vbak AS b ON a~vbeln = b~vbeln
      WHERE bstkd_m = lv_bstkd AND
            vbtyp = 'G'.
    IF sy-subrc EQ 0.
      CONCATENATE 'No. Package : ' lv_bstkd ' sudah ada no contractnya : ' lv_vbeln INTO p_message.
      ls_respon-no_package = lv_bstkd.
      ls_respon-no_contract = lv_vbeln.
      ls_respon-date_contract = lv_erdat.
      p_sales_order = lv_vbeln.
      p_status = 'W'.
      CLEAR: ls_respon-message.
    ELSE.
      CALL FUNCTION 'BAPI_CONTRACT_CREATEFROMDATA'
        EXPORTING
          contract_header_in = ls_order_header_in
          convert            = convert
        IMPORTING
          salesdocument      = lv_salesdocument
        TABLES
          return             = lt_return
          contract_items_in  = lt_order_items_in
          contract_partners  = lt_order_partners
          contract_text      = lt_order_text.
      READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
      IF sy-subrc NE 0.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        p_sales_order = lv_salesdocument.
        p_status = 'S'.
        "      lv_json_data
        ls_respon-no_package = ls_header-purch_no_c.
        ls_respon-no_contract = lv_salesdocument.
        ls_respon-date_contract = sy-datum.
        CLEAR: ls_respon-message.
      ELSE.
        LOOP AT lt_return INTO ls_return  WHERE type = 'E'.
"          PERFORM write_message CHANGING lv_message.
          p_message = ls_return-message.
          CLEAR: p_sales_order.
          p_status = 'E'.
          ls_respon-no_package = ls_header-purch_no_c.
          ls_respon-message = ls_return-message.
          ls_respon-date_contract = sy-datum.
          CLEAR: ls_respon-no_contract. ", ls_respon-contract_date.
          EXIT.
        ENDLOOP.
        p_status = 'E'.
      ENDIF.
    ENDIF.
  ELSE.
    p_status = 'E'.
    p_message = 'Data tidak ditemukan'.
    CLEAR: p_sales_order.
  ENDIF.
  "  IF p_status NE 'E'.
  ls_zmobsddt001-vbeln = ls_respon-no_contract. "lv_salesdocument.
  ls_zmobsddt001-erdat = sy-datum.
  ls_zmobsddt001-erzet = sy-uzeit.
  ls_zmobsddt001-ernam = sy-uname.
  ls_zmobsddt001-zstatus = p_status.
  ls_zmobsddt001-zmessage = p_message.
  IF p_status = 'E' AND p_message IS INITIAL.
    p_message = 'Gagal Proses create contract'.
  ENDIF.
  CREATE OBJECT cl_json_data
    EXPORTING
      data = ls_respon.
  cl_json_data->serialize( ).
  lv_json_data = cl_json_data->get_data( ).
  PERFORM f_post_data_json(ztdsit_i001) USING lv_json_data 'MOB_CONTRACT' sy-subrc p_str.
  lv_nama = gv_contract.
  PERFORM f_create_text_json(ztdsit_i001) USING lv_json_data lv_nama '/outbound/sfa/api/' 'MOB_CONTRACT'.
  ls_zmobsddt001-zmessage = p_message.
  MODIFY  zmobsddt001 FROM ls_zmobsddt001.
  CLEAR: ls_zmobsddt001, ls_respon.
ENDFORM.                    " F_CONVERT_JSON_CONTRACT
