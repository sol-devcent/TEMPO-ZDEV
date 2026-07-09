*&---------------------------------------------------------------------*
*&  Include           ZDG2FI_F0013TOP
*&---------------------------------------------------------------------*
TABLES: sscrfields, mara, makt, mkal, plpo, mapl .

TYPE-POOLS: truxs.

* Refrence Objects To Alv Grid & Custom Container Classes
DATA: g_container TYPE scrfname VALUE 'CONTAINER',
      g_grid      TYPE REF TO cl_gui_alv_grid,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      gt_fieldcat TYPE lvc_t_fcat WITH HEADER LINE,
      gt_sort     TYPE lvc_t_sort WITH HEADER LINE,
      gs_layout   TYPE lvc_s_layo,
      gv_repid    LIKE sy-repid,
      gs_variant  TYPE disvariant,
      gt_exclude  TYPE ui_functions,
      e_object    TYPE REF TO cl_alv_event_toolbar_set.

DATA: gv_row      TYPE lvc_s_row,
      gv_column   TYPE lvc_s_col,
      gv_row_num  TYPE lvc_s_roid.

DATA: dg_dyndoc_id       TYPE REF TO cl_dd_document,
      dg_splitter        TYPE REF TO cl_gui_splitter_container,
      dg_parent_grid     TYPE REF TO cl_gui_container,
      dg_html_cntrl      TYPE REF TO cl_gui_html_viewer,
      dg_parent_html     TYPE REF TO cl_gui_container.

DATA: BEGIN OF gt_mkal OCCURS 0,
        matnr TYPE matnr,
        werks TYPE werks_d,
        verid TYPE verid,
        bdatu TYPE bdatm,
        adatu TYPE adatm,
        stlal TYPE stalt,
        stlan TYPE stlan,
        plnty TYPE plnty,
        plnnr TYPE plnnr,
        alnal TYPE plnal,
        beskz TYPE beskz,
        sobsl TYPE sobsl,
        bstmi TYPE sa_losvn,
        bstma TYPE sa_losbs,
        rgekz TYPE sa_rgekz,
        alort TYPE alort,
        pltyg TYPE plnty,
        plnng TYPE plnnr,
        alnag TYPE plnal,
        pltym TYPE plnty,
        plnnm TYPE plnnr,
        alnam TYPE plnal,
        csplt TYPE csplit,
        mksp  TYPE mksp,
        mtart TYPE mtart,
      END OF gt_mkal.

DATA: BEGIN OF gt_plpo OCCURS 0,
        plnty TYPE plnty,
        plnnr TYPE plnnr,
        plnkn TYPE plnkn,
        zaehl TYPE cim_count,
        loekz TYPE lkenz,
        umren TYPE cp_umren,
        meinh TYPE vorme,
        steus TYPE steus,
        phseq TYPE phseq,
        vgw02 TYPE vgwrt,
        vgw03 TYPE vgwrt,
        vgw04 TYPE vgwrt,
        bmsch TYPE bmsch,
        ltxa1 TYPE ltxa1,
      END OF gt_plpo.

DATA: BEGIN OF gt_marc OCCURS 0,
        matnr TYPE matnr,
        werks TYPE werks_d,
        fevor TYPE fevor,
        bstfe TYPE bstfe,
      END OF gt_marc.

DATA: gt_makt TYPE TABLE OF makt WITH HEADER LINE.

DATA: BEGIN OF gt_out OCCURS 0,
        werks TYPE werks_d,
        matnr LIKE mapl-matnr,
        maktx LIKE makt-maktx,
        mtart TYPE mtart,
        plnnr TYPE plnnr,
        stats TYPE char10,
        umren TYPE cp_umren,
        bstfe TYPE bstfe,
        bmsch TYPE bmsch,
        meinh TYPE vorme,
        vgw01 TYPE vgwrt,     "Weighing (1010802 ) Labor
        vgw02 TYPE vgwrt,     "Weighing (1010802 ) NonLabor
        vgw03 TYPE vgwrt,     "Mixing Solid (1010803) Labor
        vgw04 TYPE vgwrt,     "Mixing Solid (1010803) NonLabor
        vgw05 TYPE vgwrt,     "Tableting (1010804) Solid Labor
        vgw06 TYPE vgwrt,     "Tableting (1010804) NonLabor
        vgw07 TYPE vgwrt,     "Coating Solid (1010805) Labor
        vgw08 TYPE vgwrt,     "Coating Solid (1010805) NonLabor
        vgw09 TYPE vgwrt,     "Pack Primer Solid (1010806) Labor
        vgw10 TYPE vgwrt,     "Pack Primer Solid (1010806) NonLabor
        vgw11 TYPE vgwrt,     "Pack Secondary (1010807) Labor
        vgw12 TYPE vgwrt,     "Pack Secondary (1010807) NonLabor
        vgw13 TYPE vgwrt,     "Mixing Semi Solid (1010808) Labor
        vgw14 TYPE vgwrt,     "Mixing Semi Solid (1010808) NonLabor
        vgw15 TYPE vgwrt,     "Pack Prm Semi Solid (1010809) Labor
        vgw16 TYPE vgwrt,     "Pack Prm Semi Solid (1010809) NonLabor
        vgw17 TYPE vgwrt,     "Mixing Liquid (1010810) Labor
        vgw18 TYPE vgwrt,     "Mixing Liquid (1010810) NonLabor
        vgw19 TYPE vgwrt,     "Pack Primr Liquid (1010811) Labor
        vgw20 TYPE vgwrt,     "Pack Primr Liquid (1010811) NonLabor
        vgw21 TYPE vgwrt,     "IPC (1010816) Labor
        vgw22 TYPE vgwrt,     "IPC (1010816) NonLabor
        vgw99 TYPE vgwrt,     "Total Labor
        vgw00 TYPE vgwrt,     "Total NonLabor
        chbox(1),
      END OF gt_out.

DATA: gt_plas TYPE TABLE OF plas WITH HEADER LINE.

CONSTANTS: gc_good_receipt TYPE char40 VALUE 'GOOD RECEIPT',
           gc_goods_receipt TYPE char40 VALUE 'GOODS RECEIPT'.

FIELD-SYMBOLS: <fs_out> LIKE gt_out.
