*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TABLES: sscrfields,
        koth700,
        mchb,
        mcha,
        mch1,
        mara,
        makt,
        t001w.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
*RANGES: r_date FOR koth700-datbi.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF t_main OCCURS 0,
        werks LIKE mchb-werks,
        matnr LIKE mchb-matnr,
        maktx LIKE makt-maktx,
        charg LIKE mchb-charg,
        lgort LIKE mchb-lgort,
        clabs LIKE mchb-clabs,
        slabs LIKE mkol-slabs,
        lblab LIKE mslb-lblab,
        ceinm LIKE mchb-ceinm,
        cspem TYPE mchb-cspem,
        seinm LIKE mkol-seinm,
        sspem LIKE mkol-sspem,
        cinsm LIKE mchb-cinsm,
        sinsm LIKE mkol-sinsm,
        lbins LIKE mslb-lbins,
        lbein LIKE mslb-lbein,
        ersda LIKE mchb-ersda,
        meins LIKE mara-meins,
        qndat LIKE mcha-qndat,
        vfdat LIKE mch1-vfdat,
        qnday TYPE int4,
        xlabs LIKE mchb-clabs,
        text(30),
        note  TYPE dfbatch-kztxt,
        icon(4),
      END OF t_main.

DATA: BEGIN OF t_matnr OCCURS 0,
        matnr LIKE mara-matnr,
        meins LIKE mara-meins,
      END OF t_matnr.

DATA: BEGIN OF t_mcha OCCURS 0,
        matnr LIKE mcha-matnr,
        werks LIKE mcha-werks,
        charg LIKE mcha-charg,
        qndat LIKE mcha-qndat,
        vfdat LIKE mch1-vfdat,
      END OF t_mcha.

DATA: BEGIN OF t_mseg OCCURS 0,
        mblnr   LIKE mseg-mblnr,
        mjahr   LIKE mseg-mjahr,
        zeile   LIKE mseg-zeile,
        matnr   LIKE mseg-matnr,
        lgort   LIKE mseg-lgort,
        charg   LIKE mseg-charg,
        tcode2  LIKE mkpf-tcode2,
        cpudt   LIKE mkpf-cpudt,
      END OF t_mseg.

DATA gr_date   TYPE RANGE OF datum.
