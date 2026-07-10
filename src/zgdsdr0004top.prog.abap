*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <icon>.
INCLUDE <symbol>.

TABLES: mara,
        pbim,
        pbid,
        pbed,
        makt,
        t001w,
        vbrk,
        vbak,
        t005t.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: d_month(2) TYPE n,
      d_month_begin LIKE sy-datum,
      d_month_end LIKE sy-datum,
      d_plnmg(4).

RANGES: r_period FOR likp-wadat.
*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA t_user LIKE usdef OCCURS 10000 WITH HEADER LINE.

DATA: BEGIN OF t_main OCCURS 0.
DATA: hrdesc LIKE zgdppdt0012-hrdesc,
      ferth LIKE mara-ferth,
      matnr LIKE mara-matnr,
      arktx LIKE vbrp-arktx,
      vrkme LIKE vbrp-vrkme,
      fkimg LIKE vbrp-fkimg,
      netwr LIKE vbrp-netwr,
      kwert LIKE konv-kwert,
      vtext LIKE tvkot-vtext,
      landx LIKE v_t005-landx,
      wadat_ist LIKE likp-wadat_ist,
      kurusd LIKE vbrk-kurrf,
      tdline(132).
DATA: END OF t_main.

DATA: BEGIN OF t_likp OCCURS 0.
        INCLUDE STRUCTURE likp.
DATA: END OF t_likp.

DATA: BEGIN OF t_mara OCCURS 0.
*        INCLUDE STRUCTURE mara.
DATA:  matnr LIKE mara-matnr,
       ferth LIKE mara-ferth.
DATA: END OF t_mara.

DATA: BEGIN OF t_vbrk OCCURS 0.
        INCLUDE STRUCTURE vbrk.
DATA: END OF t_vbrk.

DATA: BEGIN OF t_vbak OCCURS 0.
        INCLUDE STRUCTURE vbak.
DATA: END OF t_vbak.

DATA: BEGIN OF t_vbrp OCCURS 0.
        INCLUDE STRUCTURE vbrp.
DATA: END OF t_vbrp.
DATA: BEGIN OF t_pbed OCCURS 0.
DATA: pdatu LIKE pbed-pdatu,
      bdzei LIKE pbed-bdzei,
      plnmg LIKE pbed-plnmg.
DATA: END OF t_pbed.

DATA: BEGIN OF wa_tvkot,
        vkorg LIKE tvkot-vkorg,
        vtext LIKE tvkot-vtext,
      END OF wa_tvkot.

DATA : d_exch_rate	LIKE	bapi1093_0,
       d_return	LIKE	bapireturn1.

DATA : d_exch_rate_idr LIKE	bapi1093_0,
       d_return_idr	  LIKE	bapireturn1.

DATA: t_main_tmp LIKE t_main OCCURS 0.

TYPES: BEGIN OF ta_zgdppdt0012.
        INCLUDE STRUCTURE zgdppdt0012.
TYPES:  ferth   LIKE mara-ferth,
       END OF ta_zgdppdt0012.

DATA: i_zgdppdt0012  TYPE ta_zgdppdt0012 OCCURS 0,
      wa_zgdppdt0012 TYPE ta_zgdppdt0012,
      t_lines        LIKE tline OCCURS  0 WITH HEADER LINE,
      wa_lines       LIKE tline.

RANGES: ra_ferth FOR mara-ferth.
