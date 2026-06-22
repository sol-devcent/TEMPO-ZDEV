class ZCL_ZSFA_API_DPC_EXT definition
  public
  inheriting from ZCL_ZSFA_API_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
    redefinition .
protected section.

  methods CUSTOM_CREATE_ORDER_SFA
    importing
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER
      !IO_EXPAND type ref to /IWBEP/IF_MGW_ODATA_EXPAND
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
    exporting
      !ER_DEEP_ENTITY type ZCL_ZSFA_API_MPC_EXT=>TS_CREATE_ORDER_SFA .

  methods DN_HSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZSFA_API_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    DATA: ir_deep_entity  TYPE zcl_zsfa_api_mpc_ext=>ts_create_order_sfa.

    DATA: lv_low TYPE rvari_val_255.
    DATA: lv_destination TYPE rfcdisplay-rfcdest.

    CASE iv_entity_set_name.
*-------------------------------------------------------------------------*
*  When EntitySet 'HeaderSet' is been invoked via service Url
*-------------------------------------------------------------------------*
      WHEN 'order_sfaSet'.
        CALL METHOD me->custom_create_order_sfa
          EXPORTING
            iv_entity_name          = iv_entity_name
            iv_entity_set_name      = iv_entity_set_name
            iv_source_name          = iv_source_name
            it_key_tab              = it_key_tab
            it_navigation_path      = it_navigation_path
            io_expand               = io_expand
            io_tech_request_context = io_tech_request_context
            io_data_provider        = io_data_provider
          IMPORTING
            er_deep_entity          = ir_deep_entity.
        TRY.
            CALL METHOD me->copy_data_to_ref
              EXPORTING
                is_data = ir_deep_entity
              CHANGING
                cr_data = er_deep_entity.
          CATCH cx_root.
        ENDTRY.
    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.
    DATA: lt_dndetail    TYPE STANDARD TABLE OF zcl_zsfa_api_mpc_ext=>ts_dn_d.
    DATA: lt_lips TYPE STANDARD TABLE OF lips.
    DATA: ls_lips LIKE LINE OF lt_lips.
    DATA ls_dndetail LIKE LINE OF lt_dndetail.
    DATA: lv_char(100), lv_len TYPE i.
    "    DATA: lv_vbeln TYPE lips-vbeln.
    CASE iv_entity_name.
      WHEN 'dn_d'.
        lv_char = VALUE #( it_key_tab[ name = 'delivery_number' ]-value OPTIONAL ). "New syntax
        CONDENSE lv_char.
        lv_len = strlen( lv_char ).
        IF lv_len > 10.
          DATA(lv_vbeln) = lv_char(10).
        ELSE.
          lv_vbeln = lv_char.
        ENDIF.
        IF lv_vbeln CO '0123456789'.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_lips
            FROM lips WHERE vbeln = lv_vbeln.
        ELSE.
          sy-subrc = 4.
        ENDIF.
        IF sy-subrc EQ 0.
          CLEAR: ls_dndetail, ls_lips.
          DELETE lt_lips[] WHERE lfimg = 0.
          LOOP AT lt_lips INTO ls_lips.
            ls_dndetail-item_number = ls_lips-posnr.
            ls_dndetail-material_number = ls_lips-matnr.
            ls_dndetail-material_description = ls_lips-arktx.
            ls_dndetail-batch = ls_lips-charg.
            WRITE ls_lips-lfimg  TO ls_dndetail-quantity_satuan UNIT ls_lips-vrkme.
            TRANSLATE ls_dndetail-quantity_satuan USING '. '.
            CONDENSE ls_dndetail-quantity_satuan NO-GAPS.
            CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
              EXPORTING
                input          = ls_lips-vrkme
              IMPORTING
                output         = ls_lips-vrkme
              EXCEPTIONS
                unit_not_found = 1
                OTHERS         = 2.
            ls_dndetail-uom_satuan = ls_lips-vrkme.
            APPEND ls_dndetail TO lt_dndetail.
            CLEAR: ls_dndetail, ls_lips.
          ENDLOOP.
        ELSE.
          ls_dndetail-type = 'E'.
          CONCATENATE 'DN : ' lv_vbeln ' tidak ditemukan'
             INTO ls_dndetail-message SEPARATED BY space.
          "          ls_dndetail-message = 'Data tidak ditemukan'.
          APPEND ls_dndetail TO lt_dndetail.
        ENDIF.
        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
          EXPORTING
            is_data = lt_dndetail
          CHANGING
            cr_data = er_entityset.
    ENDCASE.
  ENDMETHOD.


  METHOD custom_create_order_sfa.
    DATA : ls_order_sfa TYPE zcl_zsfa_api_mpc_ext=>ts_create_order_sfa.
    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string.
    DATA: lv_status(1),
          lv_proses(15),
          lv_order_sfa  TYPE submi_sd,
          lv_quotation  TYPE vbeln,
          lv_message    TYPE char200.
    DATA: lv_text1024 TYPE text1024.

    CASE iv_entity_set_name.
      WHEN 'order_sfaSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = er_deep_entity.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_order_sfa.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.
        lv_order_sfa = ls_order_sfa-nomor_order_sfa.
        lv_proses = 'ORDER_SFA'. "ls_order_sfa-proses.

        CREATE OBJECT cl_json_data
          EXPORTING
            data = ls_order_sfa.

        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).
        TRY.
            CALL FUNCTION 'ZSFASD_F003'
              EXPORTING
                pi_proses        = lv_proses
                pi_data          = lv_json
                pi_order_sfa     = lv_order_sfa
              IMPORTING
                quotation        = lv_quotation
                pe_status        = lv_status
                pe_message_error = lv_message
              EXCEPTIONS
                error_message    = 99.
            IF sy-subrc = 99.
              lv_status = 'E'.
              CALL FUNCTION 'FORMAT_MESSAGE'
                EXPORTING
                  id        = sy-msgid
                  lang      = sy-langu
                  no        = sy-msgno
                  v1        = sy-msgv1
                  v2        = sy-msgv2
                  v3        = sy-msgv3
                  v4        = sy-msgv4
                IMPORTING
                  msg       = lv_message
                EXCEPTIONS
                  not_found = 1
                  OTHERS    = 2.
            ENDIF.
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          lv_message = 'Error pada saat create order TIMOS mohon cek kembali'.
          lv_status = 'E'.
        ELSE.
          lv_text1024 = lv_message.
          CALL FUNCTION 'ZTDSIT_F0002'
            EXPORTING
              ztextin  = lv_text1024
            IMPORTING
              ztextout = lv_text1024.
          lv_message = lv_text1024.
        ENDIF.
        er_deep_entity-nomor_quotation  = lv_quotation.
        er_deep_entity-status        = lv_status.
        er_deep_entity-error_message = lv_message.
    ENDCASE.
  ENDMETHOD.


  METHOD dn_hset_get_entity.
    "    DATA: ws_likp TYPE likp.
    DATA: lv_char(100), lv_len TYPE i.
    DATA: lv_vbeln TYPE likp-vbeln.
    DATA: lv_erdat     TYPE sy-datum, lv_wadat_ist TYPE sy-datum.
    CASE iv_entity_name.
      WHEN 'dn_h'.
        lv_char = er_entity-delivery_number = VALUE #( it_key_tab[ name = 'delivery_number' ]-value OPTIONAL ).
        CONDENSE lv_char.
        lv_len = strlen( lv_char ).
        IF lv_len > 10.
          lv_vbeln = lv_char(10).
        ELSE.
          lv_vbeln = lv_char.
        ENDIF.
        IF lv_vbeln CO '0123456789'.
          SELECT SINGLE
             vkorg vstel a~kunnr name1 a~erdat wadat_ist
             INTO (er_entity-sales_org, er_entity-sales_office,
                   er_entity-customer_number, er_entity-customer_name,
                   lv_erdat, lv_wadat_ist)
             FROM likp AS a JOIN kna1 AS b ON a~kunnr = b~kunnr
            WHERE vbeln = lv_vbeln.
        ELSE.
          sy-subrc = 4.
        ENDIF.
        IF sy-subrc EQ 0.
          er_entity-delivery_date = lv_erdat.
          er_entity-issue_date = lv_wadat_ist.
          er_entity-delivery_number = lv_vbeln.
        ELSE.
          er_entity-type = 'E'.
          CONCATENATE 'DN : ' lv_vbeln ' tidak ditemukan'
             INTO er_entity-message SEPARATED BY space.
          "          er_entity-message = 'DN tidak ditemukan'.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
