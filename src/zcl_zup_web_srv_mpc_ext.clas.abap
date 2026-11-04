CLASS zcl_zup_web_srv_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zup_web_srv_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_deep2,
        status            TYPE c LENGTH 1,
        message           TYPE c LENGTH 255,
        werks             TYPE c LENGTH 4,
        plant_description TYPE c LENGTH 16,
        lgort             TYPE c LENGTH 4,
        lgobe             TYPE c LENGTH 16,
*        mblnr             TYPE c LENGTH 10,
*        mjahr             TYPE c LENGTH 4,
        req_no            TYPE c LENGTH 30,
        req_date          TYPE c LENGTH 10,
        req_time          TYPE c LENGTH 8,
        requester         TYPE c LENGTH 30,
        zfrmtl            TYPE c LENGTH 10,
        bbk_no            TYPE c LENGTH 30,
        bbk_date          TYPE c LENGTH 10,
        bbk_time          TYPE c LENGTH 8,
        scrap_no          TYPE c LENGTH 10,
        scrap_year        TYPE c LENGTH 4,
        bap_no            TYPE c LENGTH 30,
        bap_date          TYPE c LENGTH 10,
        bap_time          TYPE c LENGTH 8,
        cla_no            TYPE c LENGTH 30,
        cla_date          TYPE c LENGTH 10,
        cla_time          TYPE c LENGTH 8,
        cla_sts           TYPE c LENGTH 10,
        nav_getdetailup   TYPE TABLE OF ts_materials WITH EMPTY KEY,
      END OF ty_deep2.
    TYPES:
      BEGIN OF ty_deep,
        up_number TYPE c LENGTH 30,
        werks     TYPE c LENGTH 4,
        lgort     TYPE c LENGTH 4,
        zfrmtl    TYPE c LENGTH 20,
        zurl      TYPE c LENGTH 128,
        status    TYPE c LENGTH 1,
        message   TYPE c LENGTH 255,
        details   TYPE TABLE OF ts_details WITH EMPTY KEY,
      END OF ty_deep .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZUP_WEB_SRV_MPC_EXT IMPLEMENTATION.
ENDCLASS.
