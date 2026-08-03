CLASS zcl_zdmp_get_order_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zdmp_get_order_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ts_deep_wadah,
        aufpl       TYPE c LENGTH 10,
        aplzl       TYPE c LENGTH 8,
        plnbez      TYPE c LENGTH 18,
        aufnr       TYPE c LENGTH 12,
        vornr       TYPE c LENGTH 4,
        ltxa1       TYPE c LENGTH 40,
        phseq       TYPE c LENGTH 2,
        phseq2      TYPE c LENGTH 2,
        sortf       TYPE c LENGTH 10,
        oprdesc     TYPE c LENGTH 20,
        wadtomatnav TYPE TABLE OF ts_material WITH DEFAULT KEY,
      END OF ts_deep_wadah .

    TYPES:
      BEGIN OF ts_deep_operation,
        aufpl       TYPE c LENGTH 10,
        aplzl       TYPE c LENGTH 8,
        vornr       TYPE c LENGTH 4,
        steus       TYPE c LENGTH 4,
        ltxa1       TYPE c LENGTH 40,
        phseq       TYPE c LENGTH 2,
        oprdesc     TYPE c LENGTH 20,
        stats       TYPE c LENGTH 2,
        oprtowadnav TYPE TABLE OF ts_deep_wadah WITH DEFAULT KEY,
      END OF ts_deep_operation .

    TYPES:
      BEGIN OF ts_deep_entity,
        aufnr       TYPE c LENGTH 12,
        werks       TYPE c LENGTH 4,
        plnbez      TYPE c LENGTH 18,
        maktx       TYPE c LENGTH 40,
        strdate     TYPE c LENGTH 8,
        objnr       TYPE c LENGTH 22,
        stat        TYPE c LENGTH 5,
        txt04       TYPE c LENGTH 4,
        charg       TYPE c LENGTH 10,
        aufpl       TYPE c LENGTH 10,
        aplzl       TYPE c LENGTH 8,
        oprdesc     TYPE c LENGTH 10,
        ordtooprnav TYPE TABLE OF ts_deep_operation WITH DEFAULT KEY,
      END OF ts_deep_entity .

    TYPES:
      BEGIN OF ts_deep_2,
        werks           TYPE c LENGTH 4,
        plnbez          TYPE c LENGTH 18,
        maktx           TYPE c LENGTH 40,
        strdate         TYPE c LENGTH 8,
        charg           TYPE c LENGTH 10,
        oprtyptodescnav TYPE TABLE OF ts_operationdesc WITH DEFAULT KEY,
      END OF ts_deep_2 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZDMP_GET_ORDER_MPC_EXT IMPLEMENTATION.
ENDCLASS.
