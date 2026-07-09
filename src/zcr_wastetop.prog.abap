*&---------------------------------------------------------------------*
*&  Include           ZDG2FI_F0013TOP
*&---------------------------------------------------------------------*
TABLES: sscrfields,mara,caufv,makt.

TYPE-POOLS: truxs.

* Refrence Objects To Alv Grid & Custom Container Classes
DATA: g_container TYPE scrfname VALUE 'CONTAINER',
      g_grid      TYPE REF TO cl_gui_alv_grid,
*      g_handler   TYPE REF TO lcl_event_responder,
*      g_event_handler TYPE REF TO lcl_event_handler,
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

DATA:
* Reference to document
       dg_dyndoc_id       TYPE REF TO cl_dd_document,
* Reference to split container
       dg_splitter        TYPE REF TO cl_gui_splitter_container,
* Reference to grid container
       dg_parent_grid     TYPE REF TO cl_gui_container,
* Reference to html container
       dg_html_cntrl      TYPE REF TO cl_gui_html_viewer,
* Reference to html container
       dg_parent_html     TYPE REF TO cl_gui_container.

DATA: BEGIN OF gt_caufv OCCURS 0,
        aufnr   TYPE aufnr,
        werks   TYPE werks_d,
        gstri   TYPE co_gstri,
        gltri   TYPE co_gltri,
        plnbez  TYPE matnr,
        plnty   TYPE plnty,
        plnnr   TYPE plnnr,
        prueflos  TYPE caufv-prueflos,
      END OF gt_caufv.

DATA: BEGIN OF gt_afpo OCCURS 0,
        aufnr   TYPE aufnr,
        posnr   TYPE co_posnr,
        charg   TYPE charg_d,
      END OF gt_afpo.

DATA: BEGIN OF gt_makt OCCURS 0,
        matnr   TYPE matnr,
        meins   TYPE meins,
        maktx   TYPE maktx,
      END OF gt_makt.

DATA: BEGIN OF gt_mbew OCCURS 0,
        matnr   TYPE matnr,
        bwkey   TYPE bwkey,
        stprs   TYPE stprs,
        peinh   TYPE peinh,
      END OF gt_mbew.

DATA: BEGIN OF gt_afru OCCURS 0,
        rueck   TYPE co_rueck,
        rmzhl   TYPE co_rmzhl,
        aufnr   TYPE aufnr,
        vornr   TYPE vornr,
        lmnga   TYPE ru_lmnga,
        smeng   TYPE mgvrg,
        meinh   TYPE ru_vorme,
        aufpl   TYPE co_aufpl,
        aplzl   TYPE co_aplzl,
        ltxa1   TYPE ltxa1,
      END OF gt_afru.

DATA: BEGIN OF gt_out OCCURS 0,
        matnr   TYPE matnr,
        aufnr   TYPE aufnr,
        vornr   TYPE vornr,
        ltxa1   TYPE ltxa1,
        werks   TYPE werks_d,
        plnty   TYPE plnty,
        plnnr   TYPE plnnr,
        maktx   TYPE maktx,
        gstri   TYPE co_gstri,
        gltri   TYPE co_gltri,
        lmnga   TYPE p DECIMALS 3, "ru_lmnga,
        smeng   TYPE p DECIMALS 3, "mgvrg,
        waste   TYPE p DECIMALS 3,
        waste%  TYPE p DECIMALS 3,
        meinh   TYPE ru_vorme,
        lmnga2  TYPE p DECIMALS 3, "ru_lmnga,
        dlvqty  TYPE p DECIMALS 3, "ru_lmnga,
        smeng2  TYPE p DECIMALS 3, "mgvrg,
        waste2  TYPE p DECIMALS 3,
        waste2% TYPE p DECIMALS 3,
        meinh2  TYPE ru_vorme,
        wastet  TYPE p DECIMALS 3,
        textt   TYPE char40,
        charg   TYPE charg_d,
        period  TYPE numc2,
        umren   TYPE umren,
        bobot   TYPE p DECIMALS 3,
        bobotx(22),
      END OF gt_out.

DATA: gv_ltxa1 TYPE RANGE OF ltxa1 WITH HEADER LINE,
      gt_marm  LIKE TABLE OF marm WITH HEADER LINE,
      gv_cetak1 TYPE text40,
      gv_cetak2 TYPE text40,
      gv_kemas1 TYPE text40,
      gv_kemas2 TYPE text40.

FIELD-SYMBOLS: <fs_out> LIKE gt_out.

DATA: gt_plmk TYPE STANDARD TABLE OF plmk INITIAL SIZE 0,
      gt_qamr TYPE STANDARD TABLE OF qamr INITIAL SIZE 0.
