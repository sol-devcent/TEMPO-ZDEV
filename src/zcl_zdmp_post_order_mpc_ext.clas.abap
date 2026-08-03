class ZCL_ZDMP_POST_ORDER_MPC_EXT definition
  public
  inheriting from ZCL_ZDMP_POST_ORDER_MPC
  create public .

public section.

  types:
    BEGIN OF ts_deep,
      aufnr       TYPE c LENGTH 12,
      werks       TYPE c LENGTH 4,
      plnbez      TYPE c LENGTH 18,
      charg       TYPE c LENGTH 10,
      aufpl       TYPE c LENGTH 10,
      aplzl       TYPE c LENGTH 8,
      oprdesc     TYPE c LENGTH 20,
      ordtooprnav TYPE TABLE OF ts_operation WITH DEFAULT KEY,
    END OF ts_deep .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZDMP_POST_ORDER_MPC_EXT IMPLEMENTATION.
ENDCLASS.
