*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
TABLES: qals.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: va_mtart  LIKE mara-mtart,
      va_charg  LIKE qals-charg,
      va_count  TYPE i,
      va_count1 TYPE i.

DATA: va_month00 TYPE faper,
      va_month01 TYPE faper,
      va_month03 TYPE faper,
      va_month06 TYPE faper,
      va_month09 TYPE faper,
      va_month12 TYPE faper,
      va_month24 TYPE faper,
      va_month36 TYPE faper,
      va_month48 TYPE faper,
      va_month60 TYPE faper.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA t_user LIKE usdef OCCURS 10000 WITH HEADER LINE.

TYPES: BEGIN OF ta_hd,
         prueflos  LIKE qals-prueflos,
         werk      LIKE qals-werk,
         art       LIKE qals-art,
         matnr     LIKE qals-matnr,
         charg     LIKE qals-charg,
         enstehdat LIKE qals-enstehdat,
         pastrterm LIKE qals-pastrterm,
         plnty     LIKE qals-plnty,
         plnnr     LIKE qals-plnnr,
         plnal     LIKE qals-plnal,
         plnkn     LIKE plas-plnkn,
         aufnr     LIKE qals-aufnr,
       END OF ta_hd.

TYPES: BEGIN OF ta_dt,
         kurztext   LIKE plmk-kurztext,
         masseinhsw LIKE plmk-masseinhsw,
         merknr     LIKE plmk-merknr,
         dummy40    LIKE plmk-dummy40,
         toleranzun LIKE plmk-toleranzun,
         toleranzob LIKE plmk-toleranzob,
         stellen    LIKE plmk-stellen,
         plnty      LIKE plmk-plnty,
         plnnr      LIKE plmk-plnnr,
         plnkn      LIKE plmk-plnkn,
         vornr      LIKE plpo-vornr,
         verwmerkm  LIKE plmk-verwmerkm,
       END OF ta_dt.

TYPES: BEGIN OF ta_gab,
         period     TYPE abper_rf,
         prueflos   LIKE qals-prueflos,
         vornr      LIKE plpo-vornr,
         merknr     LIKE plmk-merknr,
         kurztext   LIKE plmk-kurztext,
         verwmerkm  LIKE plmk-verwmerkm,
         enstehdat  LIKE qals-enstehdat,
         pastrterm  LIKE qals-pastrterm,
         plnty      LIKE plmk-plnty,
         plnnr      LIKE plmk-plnnr,
         result(40),
       END OF ta_gab.

TYPES: BEGIN OF ta_out,
         kurztext   LIKE plmk-kurztext,
         specific(40),
         month00(40),
         month01(40),
         month03(40),
         month06(40),
         month09(40),
         month12(40),
         month24(40),
         month36(40),
         month48(40),
         month60(40),
         info(3),
       END OF ta_out.

DATA: i_hd    TYPE ta_hd OCCURS 0,
      wa_hd   TYPE ta_hd,
      i_hd1   TYPE ta_hd OCCURS 0,
      wa_hd1  TYPE ta_hd,
      i_link  TYPE ta_hd OCCURS 0,
      wa_link TYPE ta_hd,
      i_dt    TYPE ta_dt OCCURS 0,
      wa_dt   TYPE ta_dt,
      i_gab   TYPE ta_gab OCCURS 0,
      i_gab1  TYPE ta_gab OCCURS 0,
      wa_gab  TYPE ta_gab,
      wa_gab1 TYPE ta_gab,
      i_out   TYPE ta_out OCCURS 0,
      wa_out  TYPE ta_out.

DATA: char_result   TYPE bapi2045d2,
      sample_result TYPE bapi2045d3.
