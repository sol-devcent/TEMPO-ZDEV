CLASS zcl_zatl_api_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zatl_api_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ts_po,
             po_atl           TYPE char35, "po_atl":"ATL1758684622",
             po_type          TYPE string, "po_type":"ZLOC",
             po_date          TYPE string, "po_date":"14102025",
             vendor           TYPE string, "vendor":"NSB8100",
             purchasing_org   TYPE string, "purchasing_org":"BCL",
             purchasing_group TYPE string, "purchasing_group":"ADV",
             company_code     TYPE string, "company_code":"8180",
             posap_number     TYPE char10,
             type             TYPE bapi_mtype,
             message          TYPE bapi_msg,
             detail           TYPE TABLE OF ts_po_detail WITH DEFAULT KEY,
           END OF ts_po.

    TYPES: BEGIN OF ts_gr,
             po_number       TYPE c LENGTH 10,
             posting_date    TYPE c LENGTH 10,
             doc_date        TYPE c LENGTH 10,
             delivery_note   TYPE string,
             unloading_point TYPE string,
             sap_matdoc      TYPE c LENGTH 10,
             matdoc_year     TYPE c LENGTH 4,
             type            TYPE c LENGTH 1,
             message         TYPE c LENGTH 220,
             detail          TYPE TABLE OF ts_gr_detail WITH DEFAULT KEY,
           END OF ts_gr.

    TYPES: BEGIN OF ts_miro,
             invoice_date   TYPE c LENGTH 10,
             posting_date   TYPE c LENGTH 10,
             ref_doc_no     TYPE c LENGTH 20,
             company_code   TYPE c LENGTH 4,
             currency       TYPE c LENGTH 5,
             gross_amount   TYPE c LENGTH 20,
             invoice_ind    TYPE c LENGTH 1,
             text           TYPE c LENGTH 40,
             payment_term   TYPE c LENGTH 10,
             baseline_date  TYPE c LENGTH 10,
             due_on         TYPE c LENGTH 10,
             assignment     TYPE c LENGTH 20,
             header_text    TYPE c LENGTH 40,
             exchange_rate  TYPE c LENGTH 20,
             inv_party      TYPE c LENGTH 10,
             gl_account     TYPE c LENGTH 10,
             bussiness_area TYPE c LENGTH 4,
             tax_code       TYPE c LENGTH 3,
             sap_miro_no    TYPE c LENGTH 10,
             sap_miro_year  TYPE c LENGTH 4,
             type           TYPE c LENGTH 1,
             message        TYPE c LENGTH 220,
             detail         TYPE TABLE OF ts_miro_detail WITH DEFAULT KEY,
             gl_data        TYPE TABLE OF ts_miro_gl_data WITH DEFAULT KEY,
           END OF ts_miro.
    TYPES: BEGIN OF ts_inv,
**             company_code    TYPE c LENGTH 4,
**             year            TYPE c LENGTH 4,
**             document_date   TYPE c LENGTH 10,
**             posting_date    TYPE c LENGTH 10,
**             reference       TYPE c LENGTH 40,
**             doc_header_text TYPE c LENGTH 30,
**             currency        TYPE c LENGTH 5,
**             calculate_tax   TYPE c LENGTH 10,
**             rate            TYPE c LENGTH 10,
**             payment_term    TYPE c LENGTH 10,
**             sap_inv_no      TYPE string, "c LENGTH 10,
**             sap_inv_year    TYPE string, "c LENGTH 4,
**             type            TYPE c LENGTH 1,
**             message         TYPE c LENGTH 220,
             company_code    TYPE c LENGTH 4,
             year            TYPE c LENGTH 4,
             document_date   TYPE c LENGTH 10,
             posting_date    TYPE c LENGTH 10,
             reference       TYPE c LENGTH 40,
             doc_header_text TYPE c LENGTH 30,
             currency        TYPE c LENGTH 5,
             calculate_tax   TYPE c LENGTH 10,
             rate            TYPE c LENGTH 10,
             payment_term    TYPE c LENGTH 10,
             sap_inv_no      TYPE c LENGTH 10,
             sap_inv_year     TYPE c LENGTH 4,
             type            TYPE c LENGTH 1,
             message         TYPE c LENGTH 220,
             detail          TYPE TABLE OF ts_inv_detail WITH DEFAULT KEY,
           END OF ts_inv.


    METHODS define
        REDEFINITION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZATL_API_MPC_EXT IMPLEMENTATION.


  method DEFINE.
   DATA:
      lo_annotation   TYPE REF TO /iwbep/if_mgw_odata_annotation,
      lo_entity_type  TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
      lo_complex_type TYPE REF TO /iwbep/if_mgw_odata_cmplx_type,
      lo_property     TYPE REF TO /iwbep/if_mgw_odata_property,
      lo_entity_set   TYPE REF TO /iwbep/if_mgw_odata_entity_set.

    super->define( ).

    lo_entity_type = model->get_entity_type( iv_entity_name = 'po_header' ).
    lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZATL_API_MPC_EXT=>TS_PO' ).

    lo_entity_type = model->get_entity_type( iv_entity_name = 'gr_header' ).
    lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZATL_API_MPC_EXT=>TS_GR' ).

    lo_entity_type = model->get_entity_type( iv_entity_name = 'miro_header' ).
    lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZATL_API_MPC_EXT=>TS_MIRO' ).

    lo_entity_type = model->get_entity_type( iv_entity_name = 'inv_header' ).
    lo_entity_type->bind_structure( iv_structure_name  = 'ZCL_ZATL_API_MPC_EXT=>TS_INV' ).

  endmethod.
ENDCLASS.
