*----------------------------------------------------------------------*
*   INCLUDE ZTDSFORMTEMPTOP                                            *
*----------------------------------------------------------------------*
  TABLES: nast, tnapr, knvp, zssutdt025, sscrfields, ZSCUST_CONTROL.

  DATA: BEGIN OF t_nast_key,
          matnr LIKE mara-matnr,
        END OF t_nast_key.

  DATA: xscreen(1) TYPE c.

  DATA: BEGIN OF gt_detail OCCURS 0.
          INCLUDE STRUCTURE zshipd.
  DATA: END OF gt_detail.

  TYPES: BEGIN OF ty_header.
          INCLUDE STRUCTURE zshiph.
  TYPES: END OF ty_header.

  DATA: wa_header TYPE ty_header.

  DATA: p_tdform    LIKE ssfscreen-fname VALUE 'ZSSUT_F006',
        p_dest      LIKE tsp03-padest,
        p_disp      LIKE ssfctrlop-preview.

  DATA: gs_header TYPE zssutst010,
        gv_end(1),
        gv_page(1),
        gv_pages(1).

  DATA: BEGIN OF gt_kna1 OCCURS 0,
          kunnr   TYPE kunnr,
          name1   TYPE name1_gp,
          name2   TYPE name2_gp,
          stras   TYPE stras_gp,
        END OF gt_kna1.

  DATA: BEGIN OF gt_025 OCCURS 0,
        vkorg   TYPE vkorg,
        vkbur   TYPE vkbur,
        pernr   TYPE persno,
        umjah   TYPE umjah,
        sdate   TYPE sdate,
        daily_call_num  TYPE num6,
        zrelease(1),
        zprint(1),
        check(1),
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
          counter  LIKE zssutdt022-counter,
        END OF gt_026.

  DATA: BEGIN OF gt_itab OCCURS 0,
          kunn2 TYPE gpanr,
          kunnr TYPE zssutdt022-kunnr,
          name1 TYPE kna1-name1,
          addrs TYPE char50,
        END OF gt_itab.

  DATA : gt_022 LIKE zssutdt022 OCCURS 0 WITH HEADER LINE.
  DATA : gt_ZSCUST_CONTROL LIKE ZSCUST_CONTROL OCCURS 0 WITH HEADER LINE,
         gs_ZSCUST_CONTROL LIKE ZSCUST_CONTROL .
