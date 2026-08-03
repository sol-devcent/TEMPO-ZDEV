CLASS zcl_zdmp_get_order2_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zdmp_get_order2_mpc
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
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZDMP_GET_ORDER2_MPC_EXT IMPLEMENTATION.
ENDCLASS.
