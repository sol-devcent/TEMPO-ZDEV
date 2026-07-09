*&---------------------------------------------------------------------*
*&  Include           ZDG2FI_F0013TOP
*&---------------------------------------------------------------------*
TABLES: sscrfields,mara,caufv,jcds,afpo.

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

DATA: BEGIN OF gt_out OCCURS 0.
DATA:   aufnr TYPE aufnr,
        plnbez TYPE matnr,
        ktext TYPE maktx,
        gstrp LIKE caufv-gstrp,
        udate TYPE cddatum,
        days(10),
        gamng TYPE gamng,
        gmein TYPE meins,
        waers TYPE waers,
        wemng TYPE co_wemng,
        wewrt TYPE wewrt,
        yield TYPE co_wemng,
        yield1 TYPE co_wemng,
        megbtr  LIKE covp-megbtr,
        chbox TYPE char1,
*        celltab     TYPE lvc_t_styl,
      END OF gt_out.

DATA gt_caufv TYPE TABLE OF caufv WITH HEADER LINE.
DATA gt_afpo TYPE TABLE OF afpo WITH HEADER LINE.
DATA gt_jcds TYPE TABLE OF jcds WITH HEADER LINE.

DATA : BEGIN OF gt_mara OCCURS 0,
         matnr  LIKE mara-matnr,
         mtart  LIKE mara-mtart,
       END OF gt_mara.

DATA : BEGIN OF gt_covp OCCURS 0,
         belnr    LIKE covp-belnr,
         objnr    LIKE covp-objnr,
         megbtr   LIKE covp-megbtr,
         budat    LIKE covp-budat,
       END OF gt_covp.

FIELD-SYMBOLS: <fs_out> LIKE gt_out.
