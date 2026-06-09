*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TABLES: mara,
        pbim,
        pbid,
        pbed,
        makt,
        vbak,
        vbrp,
        vbap,
        vbrk,
        kna1,
        knvv,
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
TYPES: vkorg TYPE vbak-vkorg,
       vkbur TYPE vbak-vkbur,
       vbeln TYPE vbrp-vbeln,
       vbels TYPE vbrp-vbeln,
      land1 TYPE kna1-land1,
      landx TYPE t005t-landx,
      kunnr TYPE kna1-kunnr,
      name1 TYPE kna1-name1,
      matnr TYPE mara-matnr,
      maktx TYPE makt-maktx,
      bezei1 TYPE tvm1t-bezei,
      bezei4 TYPE tvm4t-bezei,
      fkimg TYPE vbrp-fkimg,
      bzirk TYPE knvv-bzirk,
      bztxt TYPE t171t-bztxt,
      kwmeng TYPE vbap-kwmeng,
      vrkme TYPE vbap-vrkme,
      kwert TYPE konv-kwert,
      waerk TYPE vbak-waerk,
      waerkusd TYPE vbak-waerk,
      vrkmeb TYPE vbap-vrkme,
      fkimgb TYPE vbrp-fkimg,
*      umrez TYPE smeinh-umrez,
      umrez(16) TYPE p DECIMALS 5,
      umren TYPE smeinh-umren,
      fkdat TYPE vbrk-fkdat,
*      kurrf TYPE vbrk-kurrf,
      kurrf(16) TYPE p DECIMALS 5,
      kurusd  TYPE vbrk-kurrf,
      kuridr  TYPE vbrk-kurrf,
      kwertidr TYPE konv-kwert,
      kwertusd TYPE konv-kwert,
*      kwertidr TYPE p DECIMALS 0,
*      kwertusd TYPE p DECIMALS 2,
      fkimgx   TYPE vbrp-fkimg.
TYPES: END OF s_struc.

DATA: BEGIN OF t_main OCCURS 0.
INCLUDE TYPE s_struc.
DATA:
      per1  LIKE vbap-kwmeng,
      per2  LIKE vbap-kwmeng,
      per3  LIKE vbap-kwmeng,
      per4  LIKE vbap-kwmeng,
      per5  LIKE vbap-kwmeng,
      per6  LIKE vbap-kwmeng,
      per7  LIKE vbap-kwmeng,
      per8  LIKE vbap-kwmeng,
      per9  LIKE vbap-kwmeng,
      per10  LIKE vbap-kwmeng,
      per11  LIKE vbap-kwmeng,
      per12  LIKE vbap-kwmeng.
DATA: END OF t_main.

DATA: t_data LIKE t_main OCCURS 0 WITH HEADER LINE.
DATA: t_result LIKE t_main OCCURS 0 WITH HEADER LINE.

DATA: wa_data LIKE t_main.

*DATA : d_exch_rate	LIKE	bapi1093_0,
DATA : d_exch_rate_usd LIKE	 bapi1093_0,
       d_exch_rate_idr LIKE	 bapi1093_0,
       d_return_usd	LIKE	bapireturn1,
       d_return_idr	LIKE	bapireturn1.
*DATA: t_main_tmp LIKE t_main OCCURS 0.
DATA: wa_main LIKE t_main.

DATA: t_vbrk LIKE vbrk OCCURS 0 WITH HEADER LINE.
DATA: t_vbrp LIKE vbrp OCCURS 0 WITH HEADER LINE.
DATA: t_vbak LIKE vbak OCCURS 0 WITH HEADER LINE.
DATA: t_kna1 LIKE kna1 OCCURS 0 WITH HEADER LINE.
DATA: t_makt LIKE makt OCCURS 0 WITH HEADER LINE.
DATA: t_t005t LIKE t005t OCCURS 0 WITH HEADER LINE.
DATA: t_knvv LIKE knvv OCCURS 0 WITH HEADER LINE.
DATA: t_t171t LIKE t171t OCCURS 0 WITH HEADER LINE.
DATA: t_konv LIKE konv OCCURS 0 WITH HEADER LINE.
DATA: t_mara LIKE mara OCCURS 0 WITH HEADER LINE.
DATA: t_marm LIKE marm OCCURS 0 WITH HEADER LINE.
DATA: t_mvke LIKE mvke OCCURS 0 WITH HEADER LINE.
DATA: t_tvm1t LIKE tvm1t OCCURS 0 WITH HEADER LINE.
DATA: t_tvm4t LIKE tvm4t OCCURS 0 WITH HEADER LINE.


DATA: t_period(6) OCCURS 0 WITH HEADER LINE.
DATA: d_nline TYPE i.

DATA: ihead    TYPE slis_t_listheader,
      ihead_ln TYPE slis_listheader.

RANGES: ra_fkart FOR vbrk-fkart,
        ra_kschl FOR konv-kschl.
