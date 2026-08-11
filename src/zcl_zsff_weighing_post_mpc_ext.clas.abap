CLASS zcl_zsff_weighing_post_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zsff_weighing_post_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ts_fp_pgi_deep,
        aufnr     TYPE c LENGTH 12,
        werks     TYPE c LENGTH 4,
        wdesc     TYPE c LENGTH 40,
        rmscn     TYPE c LENGTH 30,
        matnr     TYPE c LENGTH 18,
        maktx     TYPE c LENGTH 40,
        charg     TYPE c LENGTH 10,
        packs     TYPE c LENGTH 10,
        packt     TYPE c LENGTH 10,
        operator  TYPE c LENGTH 40,
        pengawas  TYPE c LENGTH 40,
        plnbez    TYPE c LENGTH 18,
        fmaktx    TYPE c LENGTH 40,
        fcharg    TYPE c LENGTH 10,
        mblnr     TYPE c LENGTH 10,
        mjahr     TYPE c LENGTH 4,
        ipno      TYPE c LENGTH 18,
        hazcom    TYPE c LENGTH 30,
        name1     TYPE c LENGTH 35,
        datum     TYPE c LENGTH 20,
        fp_pginav TYPE TABLE OF ts_fp_pgi_dtl WITH DEFAULT KEY,
      END OF ts_fp_pgi_deep .

    TYPES:
      BEGIN OF ts_wh_getweight_deep,
        aufnr           TYPE c LENGTH 12,
        werks           TYPE c LENGTH 4,
        rmscn           TYPE c LENGTH 30,
        matnr           TYPE c LENGTH 18,
        maktx           TYPE c LENGTH 40,
        vornr           TYPE c LENGTH 4,
        posnr           TYPE c LENGTH 4,
        rsnum           TYPE c LENGTH 10,
        rspos           TYPE c LENGTH 4,
        lgort           TYPE c LENGTH 4,
        aufpl           TYPE c LENGTH 10,
        ltxa1           TYPE c LENGTH 40,
        plnbez          TYPE c LENGTH 18,
        print           TYPE c LENGTH 1,
        equnr           TYPE c LENGTH 18,
        wh_getweightnav TYPE TABLE OF ts_wh_getweight_dtl WITH DEFAULT KEY,
      END OF ts_wh_getweight_deep.

    TYPES:
      BEGIN OF ts_wh_print_deep,
        aufnr            TYPE c LENGTH 12,
        werks            TYPE c LENGTH 4,
        wdesc            TYPE c LENGTH 40,
        matnr            TYPE c LENGTH 18,
        maktx            TYPE c LENGTH 40,
        vornr            TYPE c LENGTH 4,
        posnr            TYPE c LENGTH 4,
        ltxa1            TYPE c LENGTH 40,
        rsnum            TYPE c LENGTH 10,
        rspos            TYPE c LENGTH 4,
        wb               TYPE c LENGTH 10,
        equnr            TYPE c LENGTH 18,
        eqktx            TYPE c LENGTH 40,
        operator         TYPE c LENGTH 40,
        pengawas         TYPE c LENGTH 40,
        plnbez           TYPE c LENGTH 18,
        fmaktx           TYPE c LENGTH 40,
        fcharg           TYPE c LENGTH 10,
        hazcom           TYPE c LENGTH 30,
        netto            TYPE c LENGTH 12,
        tara             TYPE c LENGTH 12,
        bruto            TYPE c LENGTH 12,
        erfme            TYPE c LENGTH 3,
        qrcode           TYPE c LENGTH 100,
        datum            TYPE c LENGTH 30,
        wh_printtovndnav TYPE TABLE OF ts_wh_print_vnd WITH DEFAULT KEY,
        wh_printnav      TYPE TABLE OF ts_wh_print_dtl WITH DEFAULT KEY,
      END OF ts_wh_print_deep.
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZSFF_WEIGHING_POST_MPC_EXT IMPLEMENTATION.
ENDCLASS.
