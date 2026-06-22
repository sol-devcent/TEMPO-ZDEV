CLASS zcl_ztimdes_service_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_ztimdes_service_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ts_post_settlement ,
             transaction_id    TYPE c LENGTH 20,
             sales_office      TYPE c LENGTH 10,
             deliveryman_idsap TYPE c LENGTH 10,
             keterangan        TYPE c LENGTH 100,
             posting_date      TYPE c LENGTH 10,
             voucher_no_bpv    TYPE c LENGTH 20,
             voucher_no_brv    TYPE c LENGTH 20,
             vehicle_no        TYPE c LENGTH 15,
             total             TYPE c LENGTH 20,
             doc_no_ujp_sap    TYPE c LENGTH 10,
             year_ujp_sap      TYPE c LENGTH 4,
             gl_account        TYPE c LENGTH 10,
             voucher_nosap_bpv TYPE c LENGTH 20,
             voucher_nosap_brv TYPE c LENGTH 20,
             no_doc_sap_bpv    TYPE c LENGTH 10,
             no_doc_sap_brv    TYPE c LENGTH 10,
             status            TYPE c LENGTH 1,
             message           TYPE c LENGTH 100,
             detail            TYPE TABLE OF ts_settlementdetail WITH DEFAULT KEY,
             detail_ship       TYPE TABLE OF ts_detail_shipment WITH DEFAULT KEY,
           END OF ts_post_settlement.
    TYPES:
      BEGIN OF ts_post_ship ,
        no_shipment         TYPE c LENGTH 10,
        shipment_start_date TYPE c LENGTH 8,
        shipment_start_time TYPE c LENGTH 8,
        shipment_end_date   TYPE c LENGTH 8,
        shipment_end_time   TYPE c LENGTH 8,
        no_shipmentsap      TYPE c LENGTH 10,
        status              TYPE c LENGTH 1,
        message             TYPE c LENGTH 100,
        detail              TYPE TABLE OF ts_shipdetail WITH DEFAULT KEY,
      END OF  ts_post_ship .

    METHODS define
        REDEFINITION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZTIMDES_SERVICE_MPC_EXT IMPLEMENTATION.


  METHOD define.
    DATA:
      lo_annotation   TYPE REF TO /iwbep/if_mgw_odata_annotation,
      lo_entity_type  TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
      lo_complex_type TYPE REF TO /iwbep/if_mgw_odata_cmplx_type,
      lo_property     TYPE REF TO /iwbep/if_mgw_odata_property,
      lo_entity_set   TYPE REF TO /iwbep/if_mgw_odata_entity_set.
    super->define( ).

    lo_entity_type = model->get_entity_type( iv_entity_name = 'post_shipment' ).
    lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZTIMDES_SERVICE_MPC_EXT=>TS_POST_SHIP' ).

    lo_entity_type = model->get_entity_type( iv_entity_name = 'post_settlement_ujp' ).
    "    IF lo_entity_type = 'post_settlement'.
    lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZTIMDES_SERVICE_MPC_EXT=>TS_POST_SETTLEMENT' ).
    "    ENDIF.

  ENDMETHOD.
ENDCLASS.
