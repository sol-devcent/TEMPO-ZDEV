*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TABLES: caufv, afru, usdef, mcha.

TYPES: BEGIN OF ta_tj02t,
         istat LIKE tj02t-istat,
       END OF ta_tj02t.

TYPES: BEGIN OF ta_itab.
        INCLUDE STRUCTURE zgdppst0050.
TYPES:   msg(100),
         icon(4),
       END OF ta_itab.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*

RANGES: r_istat FOR tj02t-istat.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*

DATA: i_tj02t  TYPE ta_tj02t OCCURS 0,
      wa_tj02t TYPE ta_tj02t,
      i_itab   TYPE ta_itab OCCURS 0 WITH HEADER LINE,
      wa_itab  TYPE ta_itab,
      i_charg  TYPE ta_itab OCCURS 0,
      wa_charg TYPE ta_itab,
      i_iedd   TYPE ta_itab OCCURS 0,
      wa_iedd  TYPE ta_itab,
      i_objnr  TYPE ta_itab OCCURS 0,
      wa_objnr TYPE ta_itab.

DATA t_user LIKE usdef OCCURS 10000 WITH HEADER LINE.

DATA: BEGIN OF t_mcha OCCURS 1,
        matnr LIKE mcha-matnr,
        charg LIKE mcha-charg,
      END OF t_mcha.
DATA wa_mcha LIKE t_mcha.

DATA: d_execute,
      d_update.

DATA : gt_0015  TYPE STANDARD TABLE OF zgdppdt0015.
