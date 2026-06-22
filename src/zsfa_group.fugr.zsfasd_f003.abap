FUNCTION zsfasd_f003.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_PROSES) TYPE  CHAR15
*"     VALUE(PI_DATA) TYPE  STRING
*"     REFERENCE(PI_ORDER_SFA) TYPE  SUBMI_SD OPTIONAL
*"  EXPORTING
*"     REFERENCE(QUOTATION) TYPE  VBELN
*"     REFERENCE(PE_STATUS) TYPE  CHAR1
*"     REFERENCE(PE_MESSAGE_ERROR) TYPE  CHAR200
*"     REFERENCE(PE_NO_ERROR) TYPE  EDINUM
*"  EXCEPTIONS
*"      CUSTOM_EXCEPTION
*"----------------------------------------------------------------------
  TABLES: zsfasddt010.
  TYPES: BEGIN OF ty_item_err,
           no_item       TYPE numc06,
           message_error TYPE char255,
         END OF ty_item_err.

  DATA: BEGIN OF i_status,
          nomor_order_sfa(10),
          nomor_quotation(10),
          tanggal_quotation(10),
          nomor_dn(10),
          tanggal_dn(10),
          nomor_billing(10),
          tanggal_billing(10),
          nomor_shipment(10),
          tanggal_shipment(10),
          amount(15),
          status(1),
          idoc(20),
          items_err             TYPE STANDARD TABLE OF ty_item_err WITH DEFAULT KEY,
        END  OF i_status.
  DATA: gv_str TYPE string.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        gv_json      TYPE string.
  DATA: l_name(15).
  DATA : let_docflow           TYPE tdt_docflow.
  DATA: lw_docflow           TYPE tds_docflow. " OCCURS 0 WITH HEADER LINE.

  DATA: lv_proses(15),
        lv_date          TYPE sy-datum,
        lv_order_sfa     TYPE vbak-submi,
        lv_json          TYPE string,
        lv_quotation     TYPE vbeln,
        lv_status(1),
        lv_message_error TYPE char200,
        lv_idoc          TYPE edinum. "(4).
  DATA: gs_zsfasddt010 TYPE zsfasddt010.
  DATA: lv_flag(1).
  lv_proses = pi_proses.
  lv_order_sfa = pi_order_sfa.
  IF lv_order_sfa IS INITIAL.
    pe_status = 'S'.
    pe_message_error = 'No Data'.
    RETURN.
  ENDIF.
  CLEAR: lv_flag.
  CASE lv_proses.
    WHEN 'ORDER_SFA'.
      lv_json = pi_data.
      FIND 'nomor_order_sfa' IN lv_json.
      IF sy-subrc NE 0.
        CONCATENATE 'Order SFA' lv_order_sfa 'tidak ditemukan' INTO lv_message_error SEPARATED BY space.
        pe_status = 'E'.
        pe_message_error = lv_message_error.
      ELSE.
        SELECT SINGLE * INTO gs_zsfasddt010 FROM zsfasddt010
          WHERE submi = lv_order_sfa.
        IF sy-subrc NE 0.
          SELECT SINGLE * INTO CORRESPONDING FIELDS OF gs_zsfasddt010 FROM zsfasddt002
            WHERE submi = lv_order_sfa.
          IF sy-subrc EQ 0.
            lv_flag = 'F'.
          ENDIF.
        ELSE.
          lv_flag = 'F'.
        ENDIF.
        IF gs_zsfasddt010-vbeln IS NOT INITIAL.
          WAIT UP TO 2 SECONDS.
          SELECT SINGLE vbeln erdat INTO ( gs_zsfasddt010-vbeln, lv_date )
            FROM vbak WHERE submi = lv_order_sfa.
          "and erdat(4) = sy-datum(4).
          IF sy-subrc NE 0.
            CLEAR: gs_zsfasddt010-vbeln.
          ELSE.
            IF lv_date(4) NE sy-datum(4).
              CLEAR: gs_zsfasddt010-vbeln.
            ENDIF.
          ENDIF.
        ENDIF.
        "     ENDIF.
        IF gs_zsfasddt010-vbeln IS INITIAL.
          IF lv_flag = 'F'.
            "            WAIT UP TO 3 SECONDS.
            SELECT SINGLE vbeln erdat INTO ( gs_zsfasddt010-vbeln, lv_date )
              FROM vbak WHERE submi = lv_order_sfa.
            IF sy-subrc EQ 0.
              IF lv_date(4) EQ sy-datum(4).
              ELSE.
                CLEAR: lv_flag, gs_zsfasddt010-vbeln.
              ENDIF.
            ELSE.
              CLEAR: lv_flag, gs_zsfasddt010-vbeln.
            ENDIF.
          ENDIF.
          IF lv_flag IS INITIAL.
            lv_json = pi_data.
            CLEAR: lv_idoc.
            PERFORM f_create_order_sfa USING lv_order_sfa lv_json  CHANGING lv_idoc lv_quotation lv_status lv_message_error.
            quotation = lv_quotation.
            pe_status = lv_status.
            pe_no_error = lv_idoc.
            pe_message_error = lv_message_error.
          ENDIF.
        ENDIF.
        IF gs_zsfasddt010-vbeln IS NOT INITIAL.
          quotation = gs_zsfasddt010-vbeln.
          CLEAR: pe_no_error.
          CONCATENATE 'Order SFA no.' lv_order_sfa  'Sudah terbentuk di SAP no.' gs_zsfasddt010-vbeln  INTO pe_message_error
          SEPARATED BY space.
          pe_status = 'S'.
          CLEAR: let_docflow[], let_docflow.
          CLEAR: i_status-nomor_dn, i_status-tanggal_dn, i_status-nomor_billing, i_status-idoc,
                 i_status-tanggal_billing, i_status-nomor_shipment, i_status-tanggal_shipment, i_status-amount.
***          CALL FUNCTION 'SD_DOCUMENT_FLOW_GET'
***            EXPORTING
***              iv_docnum  = gs_zsfasddt010-vbeln
***            IMPORTING
***              et_docflow = let_docflow.
***          IF let_docflow[] IS NOT INITIAL.
***            LOOP AT let_docflow INTO lw_docflow.
***              CASE lw_docflow-vbtyp_n.
***                WHEN 'J'.
***                  i_status-nomor_dn = lw_docflow-vbeln.
***                  i_status-tanggal_dn = lw_docflow-erdat.
***                WHEN '8'.
***                  i_status-nomor_shipment = lw_docflow-vbeln.
***                  i_status-tanggal_shipment = lw_docflow-erdat.
***                WHEN 'M'.
***                  i_status-nomor_billing = lw_docflow-vbeln.
***                  i_status-tanggal_billing = lw_docflow-erdat.
***              ENDCASE.
***            ENDLOOP.
***          ENDIF.
***          "          CLEAR: pe_message_error.
***          i_status-nomor_order_sfa = lv_order_sfa.
***          i_status-nomor_quotation = gs_zsfasddt010-vbeln.
***          i_status-tanggal_quotation = lv_date.
***          i_status-status = 'S'.
***          "        CLEAR: i_status.
***          "        CLEAR: i_status-items_err[].
***          CREATE OBJECT cl_json_data
***            EXPORTING
***              data = i_status.
***          cl_json_data->serialize( ).
***          gv_json = cl_json_data->get_data( ).
***          PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'SFA_UPDATE_STS' sy-subrc gv_str.
***          l_name  = lv_order_sfa.
***          CONCATENATE 'St_' l_name '_ReSend' INTO l_name.
***          CONDENSE l_name.
***          PERFORM f_create_text_json(ztdsit_i001) USING gv_json l_name '/outbound/sfa/api/' 'SFA_UPDATE_STS'.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
      CONCATENATE 'Proses' lv_proses 'tidak ditemukan' INTO lv_message_error SEPARATED BY space.
"      PE_NO_ERROR = '9999999999999999'.
      pe_status = 'E'.
      pe_message_error = lv_message_error.
  ENDCASE.
ENDFUNCTION.
