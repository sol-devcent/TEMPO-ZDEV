CLASS zcl_ztnf_api_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_ztnf_api_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF tt_pr ,
             pr_company  TYPE c LENGTH 4,
             pr_tnf      TYPE c LENGTH 16,
             pr_plant    TYPE c LENGTH 4,
             pr_tahun    TYPE c LENGTH 4,
             pr_type     TYPE c LENGTH 4,
             pr_sub_type TYPE c LENGTH 5,
             pr_doc_no   TYPE c LENGTH 10,
             pr_date     TYPE c LENGTH 10,
             pr_desc     TYPE c LENGTH 40,
             pr_sap_no   TYPE c LENGTH 10,
             type        TYPE c LENGTH 1,
             message     TYPE c LENGTH 220,
             details     TYPE TABLE OF ts_pr_detail WITH DEFAULT KEY,
           END OF tt_pr .

 TYPES:
      BEGIN OF ty_pr,
        data  TYPE tt_pr,
      END OF ty_pr .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZTNF_API_MPC_EXT IMPLEMENTATION.
ENDCLASS.
