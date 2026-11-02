class ZCL_ZATL_API_DPC_EXT definition
  public
  inheriting from ZCL_ZATL_API_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.

  methods CUSTOM_CREATE_GR_ATL
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
      !ER_DEEP_ENTITY type ZCL_ZATL_API_MPC_EXT=>TS_GR .
  methods CUSTOM_CREATE_INV_ATL
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
      !ER_DEEP_ENTITY type ZCL_ZATL_API_MPC_EXT=>TS_INV .
  methods CUSTOM_CREATE_MIRO_ATL
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
      !ER_DEEP_ENTITY type ZCL_ZATL_API_MPC_EXT=>TS_MIRO .
  methods CUSTOM_CREATE_PO_ATL
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
      !ER_DEEP_ENTITY type ZCL_ZATL_API_MPC_EXT=>TS_PO .

  methods PAYMENTSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZATL_API_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    DATA: ir_deep_entity_inv  TYPE zcl_zatl_api_mpc_ext=>ts_inv.
    DATA: ir_deep_entity_po  TYPE zcl_zatl_api_mpc_ext=>ts_po.
    DATA: ir_deep_entity_gr  TYPE zcl_zatl_api_mpc_ext=>ts_gr.
    DATA: ir_deep_entity_miro  TYPE zcl_zatl_api_mpc_ext=>ts_miro.

    CASE iv_entity_set_name.
*-------------------------------------------------------------------------*
*  When EntitySet 'HeaderSet' is been invoked via service Url
*-------------------------------------------------------------------------*
      WHEN 'invSet'.
        CALL METHOD me->custom_create_inv_atl
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
            er_deep_entity          = ir_deep_entity_inv.
        TRY.
            CALL METHOD me->copy_data_to_ref
              EXPORTING
                is_data = ir_deep_entity_inv
              CHANGING
                cr_data = er_deep_entity.
          CATCH cx_root.
        ENDTRY.
      WHEN 'poSet'.
        CALL METHOD me->custom_create_po_atl
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
            er_deep_entity          = ir_deep_entity_po.
        TRY.
            CALL METHOD me->copy_data_to_ref
              EXPORTING
                is_data = ir_deep_entity_po
              CHANGING
                cr_data = er_deep_entity.
          CATCH cx_root.
        ENDTRY.
      WHEN 'grSet'.
        CALL METHOD me->custom_create_gr_atl
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
            er_deep_entity          = ir_deep_entity_gr.
        TRY.
            CALL METHOD me->copy_data_to_ref
              EXPORTING
                is_data = ir_deep_entity_gr
              CHANGING
                cr_data = er_deep_entity.
          CATCH cx_root.
        ENDTRY.
      WHEN 'miroSet'.
        CALL METHOD me->custom_create_miro_atl
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
            er_deep_entity          = ir_deep_entity_miro.
        TRY.
            CALL METHOD me->copy_data_to_ref
              EXPORTING
                is_data = ir_deep_entity_miro
              CHANGING
                cr_data = er_deep_entity.
          CATCH cx_root.
        ENDTRY.
    ENDCASE.

  ENDMETHOD.


  METHOD custom_create_gr_atl.

    DATA : ls_gr TYPE zcl_zatl_api_mpc_ext=>ts_gr.
"    DATA: ls_gr TYPE zcl_zatl_api_mpc_ext=>ts_gr_atl.
    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string.

    CASE iv_entity_set_name.
      WHEN 'grSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = er_deep_entity.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_gr.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.

        CREATE OBJECT cl_json_data
          EXPORTING
            data = ls_gr.

        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).
        DATA: lv_po_atl(45), lv_po_num TYPE ebeln.
        DATA: obj_msg_con TYPE REF TO /iwbep/if_message_container,
              lv_matdoc type mblnr,
              lv_year type mjahr,
              lv_msgtyp   TYPE bapi_mtype,
              lv_message  TYPE bapi_msg.

        TRY.
            CALL FUNCTION 'ZATLMM_F001'
              EXPORTING
                pi_proses    = 'GRATL'
                pi_data      = lv_json
"                pi_po_atl    = ls_gr-po_number "lv_po_atl
              IMPORTING
                pe_gr_number = lv_matdoc "ls_gr-sap_matdoc "lv_po_num "
                pe_gr_year = lv_year "ls_gr-matdoc_year
                pe_type      = ls_gr-type "lv_msgtyp "
                pe_message   = ls_gr-message. "lv_message. "
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.

        IF lo_root_exception IS NOT INITIAL.
          ls_gr-type             = 'E'.
          ls_gr-message          = 'Data json tidak sesuai'.
"          CLEAR: lv_po_num.
        ENDIF.
        ls_gr-sap_matdoc  =  lv_matdoc.
        ls_gr-matdoc_year = lv_year.
        er_deep_entity = ls_gr.
    ENDCASE.
  ENDMETHOD.


  METHOD custom_create_inv_atl.
    DATA : ls_inv TYPE zcl_zatl_api_mpc_ext=>ts_inv.
    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string.
    DATA: lv_reference TYPE char35, lv_po_num TYPE ebeln.
    DATA: obj_msg_con TYPE REF TO /iwbep/if_message_container,
          lv_msgtyp   TYPE bapi_mtype,
          lv_message  TYPE bapi_msg.
    DATA: lv_inv_no   TYPE BELNR_D,
          lv_inv_year TYPE gjahr.

    CASE iv_entity_set_name.
      WHEN 'invSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = er_deep_entity.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_inv.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.

        CREATE OBJECT cl_json_data
          EXPORTING
            data = ls_inv.

        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).
        lv_reference = ls_inv-reference.

        TRY.
            CALL FUNCTION 'ZATLMM_F001'
              EXPORTING
                pi_proses     = 'INVATL'
                pi_data       = lv_json
                pi_po_atl     = lv_reference "ls_inv-reference
              IMPORTING
                pe_inv_number = lv_inv_no "ls_inv-sap_inv_no "lv_po_num "
                pe_inv_year   = lv_inv_year "ls_inv-sap_inv_year "lv_po_num "
                pe_type       = lv_msgtyp "
                pe_message    = lv_message. "
          CATCH cx_root INTO DATA(lo_root_exception).

        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_inv-type             = 'E'.
          ls_inv-message          = 'Data json tidak sesuai'.
        ELSE.
          ls_inv-sap_inv_no =  lv_inv_no.
          ls_inv-sap_inv_year =  lv_inv_year.
        ENDIF.
        ls_inv-type = lv_msgtyp.
        ls_inv-message = lv_message.
"        er_deep_entity = ls_miro.
         er_deep_entity = ls_inv.
    ENDCASE.
  ENDMETHOD.


  METHOD custom_create_miro_atl.
    DATA : ls_miro TYPE zcl_zatl_api_mpc_ext=>ts_miro.
    "    DATA: ls_gr TYPE zcl_zatl_api_mpc_ext=>ts_gr_atl.
    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string.

    CASE iv_entity_set_name.
      WHEN 'miroSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = er_deep_entity.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_miro.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.

        CREATE OBJECT cl_json_data
          EXPORTING
            data = ls_miro.

        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).
        DATA: lv_po_atl(45), lv_po_num TYPE ebeln.
        data: lv_miro_no type mblnr, lv_miro_year type mjahr.
        DATA: obj_msg_con TYPE REF TO /iwbep/if_message_container,
              lv_msgtyp   TYPE bapi_mtype,
              lv_message  TYPE bapi_msg.

        TRY.
            CALL FUNCTION 'ZATLMM_F001'
              EXPORTING
                pi_proses      = 'MIROATL'
                pi_data        = lv_json
"               pi_po_atl      = ls_gr-po_number "lv_po_atl
              IMPORTING
                pe_miro_number = lv_miro_no "ls_miro-sap_miro_no "lv_po_num "
                pe_miro_year   = lv_miro_year "ls_miro-sap_miro_year
                pe_type        = lv_msgtyp "ls_miro-type "lv_msgtyp "
                pe_message     = lv_message. "ls_miro-message. "lv_message. "
          CATCH cx_root INTO DATA(lo_root_exception).
        ENDTRY.
        IF lo_root_exception IS NOT INITIAL.
          ls_miro-type             = 'E'.
          ls_miro-message          = 'Data json tidak sesuai'.
        ELSE.
          ls_miro-sap_miro_no = lv_miro_no.
          ls_miro-sap_miro_year = lv_miro_year.
          ls_miro-type       = lv_msgtyp. "ls_miro-type "lv_msgtyp "
          ls_miro-message = lv_message.   "ls_miro-message. "lv_message. "
        ENDIF.
        er_deep_entity = ls_miro.
    ENDCASE.
  ENDMETHOD.


  METHOD custom_create_po_atl.

    DATA : ls_po TYPE zcl_zatl_api_mpc_ext=>ts_po.
    DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer,
           lv_json      TYPE string.

    CASE iv_entity_set_name.
      WHEN 'poSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = er_deep_entity.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_po.
          CATCH /iwbep/cx_mgw_tech_exception.
        ENDTRY.

        CREATE OBJECT cl_json_data
          EXPORTING
            data = ls_po.

        cl_json_data->serialize( ).
        lv_json = cl_json_data->get_data( ).
        DATA: lv_po_atl(45), lv_po_num TYPE ebeln.
        DATA: obj_msg_con TYPE REF TO /iwbep/if_message_container,

              lv_msgtyp   TYPE bapi_mtype,
              lv_message  TYPE bapi_msg.
        lv_po_atl = ls_po-po_atl.

        TRY.
            CALL FUNCTION 'ZATLMM_F001'
              EXPORTING
                pi_proses    = 'CREATE_POATL'
                pi_data      = lv_json
                pi_po_atl    = ls_po-po_atl "lv_po_atl
              IMPORTING
                pe_po_number = ls_po-posap_number "lv_po_num "
                pe_type      = ls_po-type "lv_msgtyp "
                pe_message   = ls_po-message. "lv_message. "
          CATCH cx_root INTO DATA(lo_root_exception).

        ENDTRY.

        IF lo_root_exception IS NOT INITIAL.
          ls_po-type             = 'E'.
          ls_po-message          = 'Data json tidak sesuai'.
        ENDIF.

        er_deep_entity = ls_po.
**        obj_msg_con->add_message_text_only(
**          EXPORTING
**            iv_msg_type               = lv_msgtyp
**            iv_msg_text               = lv_message
**            iv_add_to_response_header = abap_true ).


    ENDCASE.
  ENDMETHOD.


  METHOD paymentset_get_entity.

    DATA: gs_zatldt001 TYPE  zatldt001. " WITH HEADER LINE.
    DATA: lv_subrc TYPE sy-subrc.
    er_entity-sap_miro_no = VALUE #( it_key_tab[ name = 'sap_miro_no' ]-value OPTIONAL ). "New syntax
    er_entity-sap_miro_no = |{ er_entity-sap_miro_no ALPHA = IN }|.
    er_entity-sap_miro_year = VALUE #( it_key_tab[ name = 'sap_miro_year' ]-value OPTIONAL ). "New syntax
    er_entity-sap_miro_year = |{ er_entity-sap_miro_year ALPHA = IN }|.
    CLEAR lv_subrc.
    SELECT SINGLE * INTO  gs_zatldt001
      FROM zatldt001
      WHERE belnr = er_entity-sap_miro_no
        AND gjahr = er_entity-sap_miro_year.

****   SAP_MIRO_NO type C length 10,
****     SAP_MIRO_YEAR type C length 4,
****     NO_PAYMENT_SAP type C length 10,
****     PAYMENT_DATE type C length 10,
****     ASSIGNMENT type C length 20,
****     TYPE type C length 1,
****     MESSAGE type C length 220,
    IF sy-subrc EQ 0.
      IF gs_zatldt001-status = 'P'.
        er_entity-no_payment_sap = gs_zatldt001-augbl.
        er_entity-payment_date = gs_zatldt001-budat.
        er_entity-assignment = gs_zatldt001-zuonr1.
        er_entity-type = 'S'.
      ELSE.
        SELECT SINGLE * INTO  @DATA(ls_bsak) FROM bsak
          WHERE bukrs = @gs_zatldt001-bukrs
            AND lifnr = @gs_zatldt001-lifnr
            AND belnr = @gs_zatldt001-belnr
            AND gjahr = @gs_zatldt001-gjahr.
        IF sy-subrc EQ 0.
          er_entity-no_payment_sap = ls_bsak-augbl.
          gs_zatldt001-augbl = ls_bsak-augbl.
          gs_zatldt001-budat = ls_bsak-budat.
          er_entity-payment_date = ls_bsak-budat.
          SELECT SINGLE * INTO @DATA(ls_bsak1) FROM bsak
            WHERE bukrs = @ls_bsak-bukrs
              AND lifnr = @ls_bsak-lifnr
              AND belnr = @ls_bsak-augbl
              AND gjahr = @ls_bsak-gjahr.
          IF sy-subrc EQ 0.
            er_entity-assignment = ls_bsak1-zuonr.
            gs_zatldt001-zuonr1 = ls_bsak1-zuonr.
            gs_zatldt001-status = 'P'.
            gs_zatldt001-aedat = sy-datum.
            gs_zatldt001-aezet = sy-uzeit.
            gs_zatldt001-aenam = sy-uname.

            er_entity-type = 'S'.
            MODIFY zatldt001 FROM gs_zatldt001.
          ELSE.
            lv_subrc = 4.
          ENDIF.
        ELSE.
          lv_subrc = 4.
        ENDIF.
      ENDIF.
    ELSE.
      lv_subrc = 4.
    ENDIF.
    IF  lv_subrc = 4.
      er_entity-type = 'E'.
      er_entity-message = 'Belum ada data payment'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
