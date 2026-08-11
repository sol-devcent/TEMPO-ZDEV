CLASS zcl_zsff_weighing_get_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zsff_weighing_get_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ts_equipment2,
        equnr    TYPE c LENGTH 18,
        eqktx    TYPE c LENGTH 40,
        swerk    TYPE c LENGTH 4,
        uri_addr TYPE c LENGTH 50,
        remark   TYPE tdline,
        ipprnt   TYPE c LENGTH 50,
        bruto    TYPE c LENGTH 10,
      END OF ts_equipment2 .

    TYPES :
      BEGIN OF ts_fp_mat_scan,
        aufnr              TYPE c LENGTH 12,
        werks              TYPE c LENGTH 4,
        rmscn              TYPE c LENGTH 30,
        matnr              TYPE c LENGTH 18,
        maktx              TYPE c LENGTH 40,
        charg              TYPE c LENGTH 10,
        packs              TYPE c LENGTH 10,
        packt              TYPE c LENGTH 10,
        fp_materialscannav TYPE TABLE OF ts_fp_material_scan_dtl WITH DEFAULT KEY,
      END OF ts_fp_mat_scan .

    TYPES :
      BEGIN OF ts_wh_mat_scan,
        aufnr              TYPE c LENGTH 12,
        werks              TYPE c LENGTH 4,
        rmscn              TYPE c LENGTH 30,
        matnr              TYPE c LENGTH 18,
        maktx              TYPE c LENGTH 40,
        vornr              TYPE c LENGTH 4,
        posnr              TYPE c LENGTH 4,
        rsnum              TYPE c LENGTH 10,
        rspos              TYPE c LENGTH 4,
        lgort              TYPE c LENGTH 4,
        aufpl              TYPE c LENGTH 10,
        ltxa1              TYPE c LENGTH 40,
        plnbez             TYPE c LENGTH 18,
        fgbatch            TYPE c LENGTH 10,
        print              TYPE c LENGTH 1,
        equnr              TYPE c LENGTH 18,
        wh_materialscannav TYPE TABLE OF ts_wh_material_scan_dtl WITH DEFAULT KEY,
      END OF ts_wh_mat_scan .

    TYPES:
      BEGIN OF ts_pgi_order_scan,
        aufnr        TYPE c LENGTH 12,
        vornr        TYPE c LENGTH 4,
        werks        TYPE c LENGTH 4,
        matnr_fg     TYPE c LENGTH 18,
        maktx_fg     TYPE c LENGTH 40,
        charg_fg     TYPE c LENGTH 10,
        oprtyp       TYPE c LENGTH 10,
        qrcode       TYPE c LENGTH 100,
        pgi          TYPE c LENGTH 1,
        pgi_ordernav TYPE TABLE OF ts_pgi_order_dtl WITH DEFAULT KEY,
      END OF ts_pgi_order_scan .

    TYPES:
      BEGIN OF ts_pgi_matflag,
        aufnr               TYPE c LENGTH 12,
        vornr               TYPE c LENGTH 4,
        werks               TYPE c LENGTH 4,
        matnr_fg            TYPE c LENGTH 18,
        maktx_fg            TYPE c LENGTH 40,
        charg_fg            TYPE c LENGTH 10,
        oprtyp              TYPE c LENGTH 10,
        qrcode              TYPE c LENGTH 100,
        pgi                 TYPE c LENGTH 1,
        pgi_materialflagnav TYPE TABLE OF ts_pgi_materialflag_dtl WITH DEFAULT KEY,
      END OF ts_pgi_matflag .

    TYPES:
      BEGIN OF ts_reprint_out,
        aufnr      TYPE c LENGTH 12,
        posnr      TYPE c LENGTH 4,
        reprintnav TYPE TABLE OF ts_reprint_dtl WITH DEFAULT KEY,
      END OF ts_reprint_out .

    TYPES:
      BEGIN OF ts_fp_reprint_out,
        aufnr         TYPE c LENGTH 12,
        vornr         TYPE c LENGTH 4,
        prntyp        TYPE c LENGTH 12,
        werks         TYPE c LENGTH 4,
        meanv         TYPE c LENGTH 22,
        wdesc         TYPE c LENGTH 40,
        matnr         TYPE c LENGTH 18,
        posnr         TYPE c LENGTH 4,
        maktx         TYPE c LENGTH 40,
        charg         TYPE c LENGTH 10,
        packs         TYPE c LENGTH 10,
        packt         TYPE c LENGTH 10,
        operator      TYPE c LENGTH 40,
        pengawas      TYPE c LENGTH 40,
        plnbez        TYPE c LENGTH 18,
        fmaktx        TYPE c LENGTH 40,
        fcharg        TYPE c LENGTH 10,
        mblnr         TYPE c LENGTH 10,
        mjahr         TYPE c LENGTH 4,
        ipno          TYPE c LENGTH 18,
        hazcom        TYPE c LENGTH 30,
        name1         TYPE c LENGTH 35,
        datum         TYPE c LENGTH 20,
        fp_reprintnav TYPE TABLE OF ts_fp_reprint_dtl WITH DEFAULT KEY,
      END OF ts_fp_reprint_out .

    TYPES:
      BEGIN OF ts_wh_reprint_out,
        aufnr            TYPE c LENGTH 12,
        werks            TYPE c LENGTH 4,
        prntyp           TYPE c LENGTH 12,
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
        ipno             TYPE c LENGTH 18,
        netto            TYPE c LENGTH 12,
        tara             TYPE c LENGTH 12,
        bruto            TYPE c LENGTH 12,
        erfme            TYPE c LENGTH 3,
        qrcode           TYPE c LENGTH 100,
        datum            TYPE c LENGTH 30,
        wh_reprintdtlnav TYPE TABLE OF ts_wh_reprint_dtl WITH DEFAULT KEY,
        wh_reprintvndnav TYPE TABLE OF ts_wh_reprint_vnd WITH DEFAULT KEY,
      END OF ts_wh_reprint_out .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZSFF_WEIGHING_GET_MPC_EXT IMPLEMENTATION.
ENDCLASS.
