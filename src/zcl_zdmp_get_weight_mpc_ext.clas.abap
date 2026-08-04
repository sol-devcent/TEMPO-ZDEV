CLASS zcl_zdmp_get_weight_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zdmp_get_weight_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ts_hasiltimbang_a,
        aufnr    TYPE c LENGTH 12,
        vornr    TYPE c LENGTH 4,
        equnr    TYPE c LENGTH 18,
        arbpl    TYPE c LENGTH 8,
        actwh    TYPE c LENGTH 4,
        bruto    TYPE p LENGTH 8 DECIMALS 3,
        tara     TYPE p LENGTH 8 DECIMALS 3,
        netto    TYPE p LENGTH 8 DECIMALS 3,
        meins    TYPE c LENGTH 3,
        tempt    TYPE c LENGTH 8,
        temme    TYPE c LENGTH 3,
        moist    TYPE c LENGTH 30,
        moime    TYPE c LENGTH 3,
        expdt    TYPE c LENGTH 8,
        exptm    TYPE c LENGTH 8,
        operator TYPE c LENGTH 40,
        pengawas TYPE c LENGTH 40,
        erdat    TYPE c LENGTH 8,
        ertim    TYPE c LENGTH 8,
        wadah    TYPE c LENGTH 2,
        twadah   TYPE c LENGTH 2,
        eqktx    TYPE c LENGTH 40,
        ktext    TYPE c LENGTH 40,
        ltxa1    TYPE c LENGTH 40,
        usr00    TYPE c LENGTH 40,
        lot      TYPE c LENGTH 1,
        rooms    TYPE c LENGTH 20,
        cwadah   TYPE c LENGTH 20,
      END OF ts_hasiltimbang_a .

    TYPES:
      BEGIN OF ts_hasiltimbang_b,
        aufnr    TYPE c LENGTH 12,
        vornr    TYPE c LENGTH 4,
        equnr    TYPE c LENGTH 18,
        arbpl    TYPE c LENGTH 8,
        actwh    TYPE c LENGTH 4,
        bruto    TYPE p LENGTH 8 DECIMALS 3,
        tara     TYPE p LENGTH 8 DECIMALS 3,
        netto    TYPE p LENGTH 8 DECIMALS 3,
        meins    TYPE c LENGTH 3,
        tempt    TYPE c LENGTH 8,
        temme    TYPE c LENGTH 3,
        moist    TYPE c LENGTH 30,
        moime    TYPE c LENGTH 3,
        expdt    TYPE c LENGTH 8,
        exptm    TYPE c LENGTH 8,
        operator TYPE c LENGTH 40,
        pengawas TYPE c LENGTH 40,
        erdat    TYPE c LENGTH 8,
        ertim    TYPE c LENGTH 8,
        wadah    TYPE c LENGTH 2,
        twadah   TYPE c LENGTH 2,
        eqktx    TYPE c LENGTH 40,
        ktext    TYPE c LENGTH 40,
        ltxa1    TYPE c LENGTH 40,
        usr00    TYPE c LENGTH 40,
        lot      TYPE c LENGTH 1,
        rooms    TYPE c LENGTH 20,
        cwadah   TYPE c LENGTH 20,
        tdname   TYPE c LENGTH 30,
      END OF ts_hasiltimbang_b .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZDMP_GET_WEIGHT_MPC_EXT IMPLEMENTATION.
ENDCLASS.
