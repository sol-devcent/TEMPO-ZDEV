class ZCL_ZTIMDES_SERVICE_DPC_EXT definition
  public
  inheriting from ZCL_ZTIMDES_SERVICE_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.

  methods CUSTOM_CREATE_POST_SETTLEMENT
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
      !ER_DEEP_ENTITY type ZCL_ZTIMDES_SERVICE_MPC_EXT=>TS_POST_SETTLEMENT .
  methods CUSTOM_CREATE_POST_SHIPMENT
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
      !ER_DEEP_ENTITY type ZCL_ZTIMDES_SERVICE_MPC_EXT=>TS_POST_SHIP .

  methods GET_VENDORSET_GET_ENTITY
    redefinition .
  methods POST_DELIVERYMAN_CREATE_ENTITY
    redefinition .
  methods POST_ESTIMASI_UJ_CREATE_ENTITY
    redefinition .
  methods POST_VEHICLESET_CREATE_ENTITY
    redefinition .
  methods POST_CANCEL_ADVS_CREATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZTIMDES_SERVICE_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    DATA: ir_deep_entity  TYPE zcl_ztimdes_service_mpc_ext=>ts_post_ship.
    DATA: ir_deep_entity_settlement  TYPE zcl_ztimdes_service_mpc_ext=>ts_post_settlement.

    DATA: lv_low TYPE rvari_val_255.
    DATA: lv_destination TYPE rfcdisplay-rfcdest.

    CASE iv_entity_set_name.
*-------------------------------------------------------------------------*
*  When EntitySet 'HeaderSet' is been invoked via service Url
*-------------------------------------------------------------------------*
      WHEN 'post_shipmentSet'.
        CALL METHOD me->custom_create_post_shipment
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


      WHEN 'post_settlement_ujpSet'.
        CALL METHOD me->custom_create_post_settlement
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
            er_deep_entity          = ir_deep_entity_settlement.
        TRY.
            CALL METHOD me->copy_data_to_ref
              EXPORTING
                is_data = ir_deep_entity_settlement
              CHANGING
                cr_data = er_deep_entity.
          CATCH cx_root.
        ENDTRY.
    ENDCASE.



  ENDMETHOD.


  METHOD custom_create_post_settlement.

    DATA : ls_post_settlement TYPE zcl_ztimdes_service_mpc_ext=>ts_post_settlement.
    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string, lv_export TYPE string.
    DATA: lv_status(1), lv_proses(30), lv_reference(40),
          lv_name(40), lv_documentsap(40),
          lv_message         TYPE bapi_msg,
          lv_text(100), lv_text1(20), lv_text2(20), lv_text3(10), lv_text4(10)..

    CASE iv_entity_set_name.
      WHEN 'post_settlement_ujpSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_post_settlement.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.

        CREATE OBJECT cl_json_data
          EXPORTING
            data = ls_post_settlement.

        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).

        lv_proses = 'SETTLEMENT_UJP'.
        CALL FUNCTION 'ZMDSFI_F001'
          EXPORTING
            pi_process   = lv_proses
            pi_data      = lv_json
            pi_reference = lv_reference
          IMPORTING
            pi_type      = lv_status
            pi_message   = lv_message
            pi_document  = lv_documentsap
            pi_export    = lv_export.
        CLEAR: lv_text.
        er_deep_entity-voucher_nosap_bpv = lv_documentsap.
        lv_text = lv_export.
        IF lv_text IS NOT INITIAL.
          SPLIT lv_text AT '|' INTO lv_text1 lv_text2 lv_text3 lv_text4.
          CONDENSE: lv_text1, lv_text2, lv_text3, lv_text4.
          er_deep_entity-voucher_nosap_bpv = lv_text1.
          er_deep_entity-voucher_nosap_brv = lv_text2.
          er_deep_entity-no_doc_sap_bpv = lv_text4.
          er_deep_entity-no_doc_sap_brv = lv_text3.
        ENDIF.
        er_deep_entity-message = lv_message.
        er_deep_entity-status = lv_status.


    ENDCASE.
  ENDMETHOD.


  METHOD custom_create_post_shipment.

    DATA : ls_post_ship TYPE zcl_ztimdes_service_mpc_ext=>ts_post_ship.
    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string, lv_export TYPE string.
    DATA: lv_status(1), lv_proses(30), lv_reference(40),
          lv_name(40), lv_documentsap(40),
          lv_message       TYPE bapi_msg.

    CASE iv_entity_set_name.
      WHEN 'post_shipmentSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_post_ship.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.

        CREATE OBJECT cl_json_data
          EXPORTING
            data = ls_post_ship.

        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).

        lv_proses = 'POST_SHIPMENT'.
        CALL FUNCTION 'ZMDSFI_F001'
          EXPORTING
            pi_process   = lv_proses
            pi_data      = lv_json
            pi_reference = lv_reference
          IMPORTING
            pi_type      = lv_status
            pi_message   = lv_message
            pi_document  = lv_documentsap
            pi_export    = lv_export.
        er_deep_entity-no_shipmentsap = lv_documentsap.
        er_deep_entity-message = lv_message.
        er_deep_entity-status = lv_status.
    ENDCASE.
  ENDMETHOD.


  METHOD get_vendorset_get_entity.
    DATA: lv_vendor_code TYPE lfa1-lifnr.
    DATA: ls_vendor_data TYPE lfa1.

    CASE iv_entity_set_name.
      WHEN 'get_vendorSet'.
        lv_vendor_code = VALUE #( it_key_tab[ name = 'vendor_code' ]-value OPTIONAL ). "New syntax
        lv_vendor_code = |{ lv_vendor_code ALPHA = IN }|.
        SELECT SINGLE * INTO ls_vendor_data FROM lfa1 WHERE lifnr = lv_vendor_code.
        IF sy-subrc EQ 0.
          er_entity-vendor_code = ls_vendor_data-lifnr.
          er_entity-vendor_name = ls_vendor_data-name1.
          er_entity-status = 'S'.
        Else.
          er_entity-vendor_code = lv_vendor_code.
          er_entity-status = 'E'.
          CONCATENATE 'Vendor Code :' lv_vendor_code 'Tidak ditemukan'
          into er_entity-error_message SEPARATED BY space.
        ENDIF.
    ENDCASE.

  ENDMETHOD.


  METHOD post_cancel_advs_create_entity.
    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string, lv_export TYPE string.
    io_data_provider->read_entry_data( IMPORTING es_data = er_entity ).
    DATA: lv_status(1), lv_proses(30), lv_reference(40),
          lv_name(40), lv_documentsap(40),
          lv_message       TYPE bapi_msg.


    CREATE OBJECT cl_json_data
      EXPORTING
        data = er_entity.

    cl_json_data->serialize( ).
    lv_json = cl_json_data->get_data( ).

    lv_proses = 'CANCEL_ADV'.
    CALL FUNCTION 'ZMDSFI_F001'
      EXPORTING
        pi_process   = lv_proses
        pi_data      = lv_json
        pi_reference = lv_reference
      IMPORTING
        pi_type      = lv_status
        pi_message   = lv_message
        pi_document  = lv_documentsap
        pi_export    = lv_export.

    "     er_entity-voucher_nosap = lv_documentsap.
    er_entity-message = lv_message.
    er_entity-status = lv_status.
    IF lv_documentsap IS NOT INITIAL.
      er_entity-no_doc_sap = lv_documentsap.
    ENDIF.


  ENDMETHOD.


  METHOD post_deliveryman_create_entity.

    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string, lv_export TYPE string.
    io_data_provider->read_entry_data( IMPORTING es_data = er_entity ).
    DATA: lv_status(1), lv_proses(30), lv_reference(40),
          lv_name(40), lv_documentsap(40),
          lv_message       TYPE bapi_msg.


**    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
**           lv_json      TYPE string.
**    io_data_provider->read_entry_data( IMPORTING es_data = er_entity ).
**
**    DATA: gs_zf63masterkend TYPE zf63masterkend.
**    DATA: gs_zf63masterperson TYPE zf63masterperson.
**    DATA: lv_zidno TYPE zf63masterperson-zidno.
**    DATA: lv_message(200), lv_status(1).
**    DATA: lv_zidke TYPE zf63masterkend-zidke.
    "    data: lv_ TYPE zbpc0005-ivnum.
**
**    VENDOR_CODE type C length 10,
**     SALES_OFFICE type C length 4,
**     VEHICLE_NO type C length 10,
**     DELIVERYMAN_ID type C length 20,
**     DELIVERYMAN_NAME type C length 40,
**     JENIS_VENDOR type C length 40,
**     DELIVERYMAN_IDSAP type C length 10,
**     MESSAGE type C length 200,
**     STATUS type C length 1,

    CASE iv_entity_set_name.
      WHEN 'post_deliverymanSet'.
        CREATE OBJECT cl_json_data
          EXPORTING
            data = er_entity.

        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).

        lv_proses = 'MST_DELIVERYMAN'.
        CALL FUNCTION 'ZMDSFI_F001'
          EXPORTING
            pi_process   = lv_proses
            pi_data      = lv_json
            pi_reference = lv_reference
          IMPORTING
            pi_type      = lv_status
            pi_message   = lv_message
            pi_document  = lv_documentsap
            pi_export    = lv_export.

        "     er_entity-voucher_nosap = lv_documentsap.
        er_entity-message = lv_message.
        er_entity-status = lv_status.
        IF lv_documentsap IS NOT INITIAL.
          er_entity-deliveryman_idsap = lv_documentsap.
        ENDIF.






**        CREATE OBJECT cl_json_data
**          EXPORTING
**            data = er_entity.
**
**        IF er_entity-sales_office(2) = '02'.
**          gs_zf63masterperson-bukrs = '8020'.
**        ELSE.
**          gs_zf63masterperson-bukrs = '8070'.
**        ENDIF.
**        gs_zf63masterperson-vkbur = er_entity-sales_office.
**        gs_zf63masterperson-gsber = er_entity-sales_office.
**        gs_zf63masterperson-gtype = '24'.
**        CONDENSE: er_entity-vehicle_no, er_entity-deliveryman_id, er_entity-vendor_code.
**
**        gs_zf63masterperson-lifnr = er_entity-vendor_code.
**        gs_zf63masterperson-delivery_id = er_entity-deliveryman_id.
**
**        SELECT SINGLE * INTO CORRESPONDING FIELDS OF gs_zf63masterperson
**          FROM zf63masterperson
**          WHERE lifnr = gs_zf63masterperson-lifnr
**            AND delivery_id = gs_zf63masterperson-delivery_id.
**        IF sy-subrc NE 0.
**          gs_zf63masterperson-name1 = er_entity-deliveryman_name.
**          CONCATENATE '000' gs_zf63masterperson-vkbur+1(3) '0201' INTO gs_zf63masterperson-kostl.
**          gs_zf63masterperson-wwpos = '035'.
**          gs_zf63masterperson-jabatpd = 'Delivery'.
**          gs_zf63masterperson-vbund = 'OTHERS'.
**          gs_zf63masterperson-jnsvendor = er_entity-jenis_vendor.
**          CALL FUNCTION 'NUMBER_GET_NEXT'
**            EXPORTING
**              nr_range_nr             = '01'
**              object                  = 'ZIDPERSON'
**   "          subobject               = lv_zidke
**            IMPORTING
**              number                  = lv_zidno
**            EXCEPTIONS
**              interval_not_found      = 1
**              number_range_not_intern = 2
**              object_not_found        = 3
**              quantity_is_0           = 4
**              quantity_is_not_1       = 5
**              interval_overflow       = 6
**              buffer_overflow         = 7
**              OTHERS                  = 8.
**          IF sy-subrc EQ 0.
**            lv_status = 'S'.
**            gs_zf63masterperson-zidno = lv_zidno.
**          ELSE.
**            lv_status = 'E'.
**          ENDIF.
**          gs_zf63masterkend-znopol  =  er_entity-vehicle_no.
**          gs_zf63masterkend-bukrs = gs_zf63masterperson-bukrs.
**          gs_zf63masterkend-vkbur = gs_zf63masterperson-vkbur.
**          CLEAR: lv_zidke.
**          SELECT SINGLE zidke INTO lv_zidke FROM zf63masterkend
**            WHERE znopol = gs_zf63masterkend-znopol.
**          gs_zf63masterperson-zidke = lv_zidke.
**          "          MODIFY zf63masterperson FROM gs_zf63masterperson.
**        ELSE.
**          gs_zf63masterperson-name1 = er_entity-deliveryman_name.
**          gs_zf63masterperson-jnsvendor = er_entity-jenis_vendor.
**          gs_zf63masterkend-znopol  =  er_entity-vehicle_no.
**          gs_zf63masterkend-bukrs = gs_zf63masterperson-bukrs.
**          gs_zf63masterkend-vkbur = gs_zf63masterperson-vkbur.
**          CLEAR: lv_zidke.
**          SELECT SINGLE zidke INTO lv_zidke FROM zf63masterkend
**            WHERE znopol = gs_zf63masterkend-znopol.
**
**          gs_zf63masterperson-zidke = lv_zidke.
**          lv_status = 'S'.
**        ENDIF.
**
**        IF lv_status NE 'E'.
**          er_entity-DELIVERYMAN_IDSAP = gs_zf63masterperson-zidno.
**          MODIFY zf63masterperson FROM gs_zf63masterperson.
**          IF sy-subrc EQ 0.
**            CONCATENATE 'Delivery id. ' er_entity-deliveryman_id ' Berhasil di update dengan id sap'
**            er_entity-deliveryman_idsap INTO lv_message SEPARATED BY space.
**          ELSE.
**            lv_status = 'E'.
**            CONCATENATE 'Delivery id. ' er_entity-deliveryman_id ' Gagal Proses Cek SNRO IDPERSON'
**            er_entity-deliveryman_idsap INTO lv_message SEPARATED BY space.
**          ENDIF.
**        ENDIF.
**        er_entity-status = lv_status.
**        er_entity-message = lv_message.
    ENDCASE.
  ENDMETHOD.


  METHOD post_estimasi_uj_create_entity.
    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string, lv_export type string.
    io_data_provider->read_entry_data( IMPORTING es_data = er_entity ).
    DATA: lv_status(1), lv_proses(30), lv_reference(40),
          lv_name(40), lv_documentsap(40),
          lv_message       TYPE bapi_msg.


    CREATE OBJECT cl_json_data
      EXPORTING
        data = er_entity.

    cl_json_data->serialize( ).
    lv_json = cl_json_data->get_data( ).

    lv_proses = 'ADV_UJP'.
    CALL FUNCTION 'ZMDSFI_F001'
      EXPORTING
        pi_process   = lv_proses
        pi_data      = lv_json
        pi_reference = lv_reference
      IMPORTING
        pi_type      = lv_status
        pi_message   = lv_message
        pi_document  = lv_documentsap
        pi_export    = lv_export.

     er_entity-voucher_nosap = lv_documentsap.
     er_entity-message = lv_message.
     er_entity-status = lv_status.
     if lv_export is not INITIAL.
       er_entity-no_doc_sap = lv_export.
     endif.

**** dilanjutkan ke function kumpulan proses timdes  --> posting ujp
**    TRANSACTION_ID type C length 20,
**     VENDOR_CODE type C length 10,
**     SALES_OFFICE type C length 4,
**     DELIVERYMAN_NAME type C length 20,
**     POSTING_DATE type C length 10,
**     VOUCHER_NO type C length 20,
**     VEHICLE_NO type C length 20,
**     TOTAL type C length 20,
**     GL_ACCOUNT_UJP type C length 20,
**     GL_ACCOUNT_CASHBANK type C length 20,
**     USER_REQUEST type C length 20,
**     DATE_PROCESS type C length 10,
**     TIME_PROCESS type C length 10,
**     SAP_DOCUMENT type C length 10,
  ENDMETHOD.


  METHOD post_vehicleset_create_entity.
    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string, lv_export TYPE string.
    io_data_provider->read_entry_data( IMPORTING es_data = er_entity ).
    DATA: lv_status(1), lv_proses(30), lv_reference(40),
          lv_name(40), lv_documentsap(40),
          lv_message       TYPE bapi_msg.


**    DATA: gs_zf63masterkend TYPE zf63masterkend.
**    DATA: lv_zidke TYPE zf63masterkend-zidke.
**    DATA: lv_message(200), lv_status(1).
    "    data: lv_ TYPE zbpc0005-ivnum.
    CASE iv_entity_set_name.
      WHEN 'post_vehicleSet'.

        CREATE OBJECT cl_json_data
          EXPORTING
            data = er_entity.

        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).

        lv_proses = 'MST_VEHICLE'.
        CALL FUNCTION 'ZMDSFI_F001'
          EXPORTING
            pi_process   = lv_proses
            pi_data      = lv_json
            pi_reference = lv_reference
          IMPORTING
            pi_type      = lv_status
            pi_message   = lv_message
            pi_document  = lv_documentsap
            pi_export    = lv_export.

        "     er_entity-voucher_nosap = lv_documentsap.
        er_entity-message = lv_message.
        er_entity-status = lv_status.
        IF lv_documentsap IS NOT INITIAL.
          er_entity-vehicle_id =  lv_documentsap.
        ENDIF.

**
**
**
**
**
**
**
**        CREATE OBJECT cl_json_data
**          EXPORTING
**            data = er_entity.
**        CONDENSE er_entity-vehicle_no.
**        gs_zf63masterkend-znopol = er_entity-vehicle_no.
**        lv_message = gs_zf63masterkend-znopol.
**        IF gs_zf63masterkend-znopol IS NOT INITIAL.
**          SELECT SINGLE * INTO CORRESPONDING FIELDS OF gs_zf63masterkend
**            FROM zf63masterkend
**            WHERE znopol = gs_zf63masterkend-znopol.
**          IF sy-subrc EQ 0.
**            SELECT SINGLE MAX( buzei ) INTO gs_zf63masterkend-buzei
**              FROM zf63masterkend
**              WHERE znopol = gs_zf63masterkend-znorangka
**                AND bukrs = gs_zf63masterkend-bukrs
**                AND vkbur = gs_zf63masterkend-vkbur
**                AND gsber = gs_zf63masterkend-gsber
**                AND zidke = gs_zf63masterkend-zidke.
**            gs_zf63masterkend-buzei = gs_zf63masterkend-buzei + 10.
**            lv_status = 'U'.
**            gs_zf63masterkend-vkbur = er_entity-sales_office.
**            gs_zf63masterkend-gsber = er_entity-sales_office.
**            IF er_entity-sales_office(2) = '02'.
**              gs_zf63masterkend-bukrs = '8020'.
**            ELSE.
**              gs_zf63masterkend-bukrs = '8070'.
**            ENDIF.
**            gs_zf63masterkend-znorangka = er_entity-chassis_no.
**            gs_zf63masterkend-jnskend = er_entity-vehicle_type.
**            gs_zf63masterkend-txt50 = er_entity-vehicle_name.
**            gs_zf63masterkend-gtype = '24'.
**            gs_zf63masterkend-znopol = er_entity-vehicle_no.
**            CONCATENATE 'No.' lv_message 'Sdh ada Vehicle id :' gs_zf63masterkend-zidke
**                INTO lv_message SEPARATED BY space.
**            IF er_entity-is_active = 'N'.
**              gs_zf63masterkend-zaktif = 'X'.
**            ELSE.
**              CLEAR: gs_zf63masterkend-zaktif.
**            ENDIF.
**          ELSE.
**            lv_status = 'A'.
**            gs_zf63masterkend-buzei = '010'.
**            gs_zf63masterkend-vkbur = er_entity-sales_office.
**            IF er_entity-sales_office(2) = '02'.
**              gs_zf63masterkend-bukrs = '8020'.
**            ELSE.
**              gs_zf63masterkend-bukrs = '8070'.
**            ENDIF.
**            gs_zf63masterkend-gsber = er_entity-sales_office.
**            gs_zf63masterkend-znorangka = er_entity-chassis_no.
**            gs_zf63masterkend-jnskend = er_entity-vehicle_type.
**            gs_zf63masterkend-txt50 = er_entity-vehicle_name.
**            gs_zf63masterkend-gtype = '24'.
**            gs_zf63masterkend-znopol = er_entity-vehicle_no.
**            IF er_entity-is_active = 'N'.
**              gs_zf63masterkend-zaktif = 'X'.
**            ELSE.
**              CLEAR: gs_zf63masterkend-zaktif.
**            ENDIF.
**            CALL FUNCTION 'NUMBER_GET_NEXT'
**              EXPORTING
**                nr_range_nr             = '01'
**                object                  = 'ZIDKEND'
**     "          subobject               = lv_zidke
**              IMPORTING
**                number                  = lv_zidke
**              EXCEPTIONS
**                interval_not_found      = 1
**                number_range_not_intern = 2
**                object_not_found        = 3
**                quantity_is_0           = 4
**                quantity_is_not_1       = 5
**                interval_overflow       = 6
**                buffer_overflow         = 7
**                OTHERS                  = 8.
**            IF sy-subrc EQ 0.
**              gs_zf63masterkend-zidke = lv_zidke.
**              CONCATENATE 'No.' lv_message 'Vehicle id ' gs_zf63masterkend-zidke
**                  INTO lv_message SEPARATED BY space.
**            ELSE.
**              lv_status = 'E'.
**              CONCATENATE 'No.' lv_message ' tidak berhasil terbentuk di SAP (Mohon cek SNRO ZIDKEND)'
**                  INTO lv_message SEPARATED BY space.
**            ENDIF.
**          ENDIF.
**          er_entity-vehicle_id = gs_zf63masterkend-zidke.
**          IF gs_zf63masterkend-zidke IS NOT INITIAL AND lv_status NE 'E'.
**            MODIFY zf63masterkend FROM gs_zf63masterkend.
**            IF sy-subrc EQ 0.
**              CONCATENATE lv_message 'Berhasil disimpan di SAP'
**                  INTO lv_message SEPARATED BY space.
**            ELSE.
**              CONCATENATE lv_message 'Gagal disimpan di SAP'
**                  INTO lv_message SEPARATED BY space.
**              lv_status = 'E'.
**            ENDIF.
**          ENDIF.
**          er_entity-message = lv_message.
**          er_entity-status = lv_status.
**        ENDIF.
    ENDCASE.

*IV_ENTITY_NAME
***sales_office	GSBER dan VKBUR
***	ZIDKE (running Number dr SNRO-obj: ZIDKEND)
***Vehicle_no	ZNOPOL
***chassis_no	ZNORANGKA
***vehicle_type	JNSKEND
***Nama Kendaraan (Tambah)  TXT50
***is_active  ZAKTIF (tambah)
  ENDMETHOD.
ENDCLASS.
