*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <symbol>.

TABLES: mara,
        marc.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA t_user LIKE usdef OCCURS 10000 WITH HEADER LINE.

DATA: BEGIN OF t_data OCCURS 0,
        matnr LIKE mara-matnr,
        maktx LIKE makt-maktx,
        basme LIKE s933-basme,
        menge LIKE s933-menge,
        dmbtr LIKE s933-dmbtr,
        hwaer LIKE s933-hwaer,
        werks LIKE s933-werks,
        name2 LIKE t001w-name2,
        lifnr LIKE s933-lifnr,
        name1 LIKE lfa1-name1,
        no(4) TYPE p DECIMALS 0,
      END OF t_data.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: va_name1  LIKE t001w-name1,
      va_name2  LIKE t001w-name2,
      va_stras  LIKE t001w-stras,
      va_ort01  LIKE t001w-ort01,
      va_adrnr  LIKE t001w-adrnr.

RANGES: r_bwart FOR mseg-bwart,
        r_bwart_masuk FOR mseg-bwart,
        r_bwart_guna FOR mseg-bwart.
