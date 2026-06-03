*----------------------------------------------------------------------*
*   INCLUDE ZSSUT_R008TOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: zssutdt025.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*


*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_024 OCCURS 0,
        reasn(2),
        retxt(50),
      END OF gt_024.

DATA: BEGIN OF gt_025 OCCURS 0,
        vkorg   TYPE vkorg,
        vkbur   TYPE vkbur,
        pernr   TYPE persno,
        umjah   TYPE umjah,
        sdate   TYPE sdate,
        daily_call_num  TYPE num6,
      END OF gt_025.

DATA: BEGIN OF gt_026 OCCURS 0,
        vkbur   TYPE vkbur,
        daily_call_num  TYPE num6,
        kunnr   TYPE kunnr,
        umjah   TYPE umjah,
        kunn2   TYPE kunn2,
        eff_call_stat(1),
        vbeln   TYPE vbeln_vf,
        no_call_stat(1),
        reason_call_id(2),
        master_stat_indi(1),
        bistat_indi(1),
        bill_date TYPE sptag,
      END OF gt_026.

DATA: BEGIN OF gt_pa0002 OCCURS 0,
        pernr   TYPE persno,
        cname   TYPE pad_cname,
      END OF gt_pa0002.

DATA: BEGIN OF gt_kna1 OCCURS 0,
        kunnr   TYPE kunnr,
        name1   TYPE name1_gp,
      END OF gt_kna1.

DATA: BEGIN OF gt_out OCCURS 0,
        daily_call_num  TYPE num6,
        sdate   TYPE sdate,
        pernr   TYPE persno,
        cname   TYPE pad_cname,
        kunn2   TYPE kunn2,
        kunnr   TYPE kunnr,
        name1   TYPE name1_gp,
        vbeln   TYPE vbeln_vf,
        bill_date TYPE sptag,
        reason_call_id(2),
        retxt(50),
        master_stat_indi(1),
        bistat_indi(1),
      END OF gt_out.
