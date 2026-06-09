*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <symbol>.

TABLES: mseg, mbewh.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA t_user LIKE usdef OCCURS 10000 WITH HEADER LINE.

TYPES: BEGIN OF ta_zgdppdt0012.
        INCLUDE STRUCTURE zgdppdt0012.
TYPES:  ferth   LIKE mara-ferth,
       END OF ta_zgdppdt0012.

TYPES: BEGIN OF ta_itab.
        INCLUDE STRUCTURE zgdppdt0012.
TYPES:   matnr  LIKE mara-matnr,
         ferth  LIKE mara-ferth,
         maktx  LIKE makt-maktx,
         stprs  LIKE mbew-stprs,
         peinh  LIKE mbew-peinh,
         satuan TYPE sumha,
         menge  LIKE mseg-menge,
         meins  LIKE mseg-meins,
         nilai  TYPE sumha,
         mseh6  LIKE t006a-mseh6,
         waers  LIKE tcurc-waers,
         tdline(132),
       END OF ta_itab.

TYPES: BEGIN OF ta_mkpf,
         mblnr  LIKE mkpf-mblnr,
         mjahr  LIKE mkpf-mblnr,
         budat  LIKE mkpf-budat,
       END OF ta_mkpf.

TYPES: BEGIN OF ta_total,
         matnr  LIKE mseg-matnr,
         mblnr  LIKE mseg-mblnr,
         menge  LIKE mseg-menge,
         meins  LIKE mseg-meins,
         shkzg  LIKE mseg-shkzg,
         mseh6  LIKE t006a-mseh6,
       END OF ta_total.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: i_zgdppdt0012  TYPE ta_zgdppdt0012 OCCURS 0,
      wa_zgdppdt0012 TYPE ta_zgdppdt0012,
      i_mkpf         TYPE ta_mkpf OCCURS 0,
      i_mbew         TYPE ta_itab OCCURS 0,
      wa_mbew        TYPE ta_itab,
      i_mseg         TYPE ta_total OCCURS 0,
      wa_mseg        TYPE ta_total,
      i_total        TYPE ta_total OCCURS 0,
      wa_total       TYPE ta_total,
      i_itab         TYPE ta_itab OCCURS 0,
      wa_itab        TYPE ta_itab,
      t_lines        LIKE tline OCCURS  0 WITH HEADER LINE,
      wa_lines       LIKE tline.

DATA: option    TYPE i,
      va_hrtype LIKE zgdppdt0012-hrtype,
      va_name1  LIKE t001w-name1,
      va_name2  LIKE t001w-name2,
      va_stras  LIKE t001w-stras,
      va_ort01  LIKE t001w-ort01.

RANGES: ra_bwart FOR mseg-bwart,
        ra_ferth FOR mara-ferth,
        ra_budat FOR mkpf-budat.
