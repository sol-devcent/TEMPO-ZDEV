CLASS zcl_zsfa_api_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zsfa_api_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ts_create_order_sfa ,
        sales_org_code       TYPE string, "c LENGTH 4,
        sales_office         TYPE string, "c LENGTH 4,
        sales_doc_type       TYPE string, "c LENGTH 4,
        customer_code        TYPE string, "c LENGTH 10,
        salesman_code        TYPE string, "c LENGTH 10,
        customer_nomor_po    TYPE string, "c LENGTH 35,
        customer_tgl_po      TYPE string, "c LENGTH 10,
        payment_type         TYPE string, "c LENGTH 1,
        tgl_jatuh_tempo      TYPE string, "c LENGTH 10,
        nomor_order_sfa      TYPE string, "c LENGTH 10,
        collector_route_list TYPE string, "c LENGTH 10,
        delivery_route_list  TYPE string, "c LENGTH 10,
        order_reason         TYPE string, "c LENGTH 4,
        nomor_call_id        TYPE string, "c LENGTH 10,
        keterangan           TYPE string, "c LENGTH 50,
        inco2                TYPE string, "c LENGTH 40,
        cashback_amt         TYPE string, "c LENGTH 20,
        nomor_quotation      TYPE string, "c LENGTH 10,
        status               TYPE string, "c LENGTH 1,
"        insert_date          TYPE string, "c LENGTH 10,
        error_message        TYPE string, "c LENGTH 200,
        sales_order_details  TYPE STANDARD TABLE OF ts_order_item WITH DEFAULT KEY,
      END OF ts_create_order_sfa .

    METHODS define
        REDEFINITION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZSFA_API_MPC_EXT IMPLEMENTATION.


  METHOD define.
    DATA:
      lo_annotation   TYPE REF TO /iwbep/if_mgw_odata_annotation,
      lo_entity_type  TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
      lo_complex_type TYPE REF TO /iwbep/if_mgw_odata_cmplx_type,
      lo_property     TYPE REF TO /iwbep/if_mgw_odata_property,
      lo_entity_set   TYPE REF TO /iwbep/if_mgw_odata_entity_set.
    super->define( ).

    lo_entity_type = model->get_entity_type( iv_entity_name = 'order_sfa' ).
    lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZSFA_API_MPC_EXT=>TS_CREATE_ORDER_SFA' ).


  ENDMETHOD.
ENDCLASS.
