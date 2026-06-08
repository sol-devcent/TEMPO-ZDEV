*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TABLES: mara,
        makt,
        s933,
        t171t,
        t247,
        t001w.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: d_month(2) TYPE n,
      d_month_begin LIKE sy-datum,
      d_month_end LIKE sy-datum,
      d_plnmg(4).

*RANGES: r_versb FOR pbim-versb,
*        r_pdatu FOR pbed-pdatu,
*        r_pdatu1 FOR pbed-pdatu,
*        r_pdatu2 FOR pbed-pdatu,
*        r_pdatu3 FOR pbed-pdatu,
*        r_pdatu4 FOR pbed-pdatu,
*        r_pdatu5 FOR pbed-pdatu.
*
*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA t_user LIKE usdef OCCURS 0 WITH HEADER LINE.

TYPES: BEGIN OF s_struc.
TYPES: matnr LIKE mara-matnr,
       maktx LIKE makt-maktx,
       spmon LIKE s933-spmon,
       menge LIKE s933-menge,
       meins LIKE mara-meins.
TYPES: END OF s_struc.

DATA: BEGIN OF t_s933_sum OCCURS 0.
INCLUDE TYPE s_struc.
DATA:
      per1  LIKE s933-menge,
      per2  LIKE s933-menge,
      per3  LIKE s933-menge,
      per4  LIKE s933-menge,
      per5  LIKE s933-menge,
      per6  LIKE s933-menge,
      per7  LIKE s933-menge,
      per8  LIKE s933-menge,
      per9  LIKE s933-menge,
      per10  LIKE s933-menge,
      per11  LIKE s933-menge,
      per12  LIKE s933-menge,
      total  LIKE s933-menge.
DATA: END OF t_s933_sum.

DATA: t_result LIKE t_s933_sum OCCURS 0 WITH HEADER LINE.

DATA: wa_data LIKE t_s933_sum.

DATA: BEGIN OF t_mara OCCURS 0,
        matnr LIKE mara-matnr,
        meins LIKE mara-meins,
        mtart LIKE mara-mtart,
      END OF t_mara.

DATA: BEGIN OF t_makt OCCURS 0,
        matnr LIKE mara-matnr,
        maktx LIKE makt-maktx,
      END OF t_makt.

DATA : d_exch_rate	LIKE	bapi1093_0,
       d_return	LIKE	bapireturn1.
*DATA: t_main_tmp LIKE t_main OCCURS 0.
DATA: wa_main LIKE t_s933_sum.

DATA: t_period(6) OCCURS 0 WITH HEADER LINE.
DATA: d_nline TYPE i.

DATA: ihead    TYPE slis_t_listheader,
      ihead_ln TYPE slis_listheader.

DATA: va_name2  LIKE adrc-name2,
      va_street LIKE adrc-street.

RANGES: ra_lgort FOR s933-lgort.
