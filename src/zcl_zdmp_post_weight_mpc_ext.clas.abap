class ZCL_ZDMP_POST_WEIGHT_MPC_EXT definition
  public
  inheriting from ZCL_ZDMP_POST_WEIGHT_MPC
  create public .

public section.

  types:
    BEGIN OF ts_text,
        tdline TYPE c LENGTH 132,
      END OF ts_text .
  types:
    BEGIN OF ts_yield2,
        aufpl      TYPE c LENGTH 10,
        aplzl      TYPE c LENGTH 8,
        aufnr      TYPE c LENGTH 12,
        vornr      TYPE c LENGTH 4,
        yield      TYPE p LENGTH 8 DECIMALS 3,
        meins      TYPE c LENGTH 3,
        dates_opr  TYPE c LENGTH 8,
        times_opr  TYPE c LENGTH 8,
        dates_conf TYPE c LENGTH 8,
        times_conf TYPE c LENGTH 8,
        datef      TYPE c LENGTH 8,
        timef      TYPE c LENGTH 8,
        rooms      TYPE c LENGTH 20,
        budat      TYPE c LENGTH 8,
        mhour      TYPE p LENGTH 8 DECIMALS 3,
        lhour      TYPE p LENGTH 8 DECIMALS 3,
        stats      TYPE c LENGTH 4,
        operator   TYPE c LENGTH 40,
        pengawas   TYPE c LENGTH 40,
        ltxa1      TYPE c LENGTH 40,
      END OF ts_yield2 .
  types:
    BEGIN OF ts_yield_deep,
        aufpl           TYPE c LENGTH 10,
        aplzl           TYPE c LENGTH 8,
        aufnr           TYPE c LENGTH 12,
        vornr           TYPE c LENGTH 4,
        yield           TYPE p LENGTH 8 DECIMALS 3,
        meins           TYPE c LENGTH 3,
        dates_opr       TYPE c LENGTH 8,
        times_opr       TYPE c LENGTH 8,
        dates_conf      TYPE c LENGTH 8,
        times_conf      TYPE c LENGTH 8,
        datef           TYPE c LENGTH 8,
        timef           TYPE c LENGTH 8,
        rooms           TYPE c LENGTH 20,
        budat           TYPE c LENGTH 8,
        mhour           TYPE p LENGTH 8 DECIMALS 3,
        lhour           TYPE p LENGTH 8 DECIMALS 3,
        stats           TYPE c LENGTH 4,
        operator        TYPE c LENGTH 40,
        pengawas        TYPE c LENGTH 40,
        ltxa1           TYPE c LENGTH 40,
        yieldtolinesnav TYPE TABLE OF ts_text WITH DEFAULT KEY,
      END OF ts_yield_deep .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZDMP_POST_WEIGHT_MPC_EXT IMPLEMENTATION.
ENDCLASS.
