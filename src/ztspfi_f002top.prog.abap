*----------------------------------------------------------------------*
*   INCLUDE ZGDMMF0005TOP                                              *
*----------------------------------------------------------------------*
  TABLES: zfibphd001,zfibpdt001,skat.

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

  DATA: gv_butxt    TYPE text40,
        gv_gtext    TYPE text40,
        gv_print    TYPE flag,
        gv_delvno   TYPE char20.

  DATA: BEGIN OF gt_detail OCCURS 0.
          INCLUDE TYPE zfibpdt001.
  DATA:   account TYPE text60,
          icon    TYPE char4,
          sel,
          check,
        END OF gt_detail.

  DATA: gs_header LIKE zfibphd001,
        gt_delete LIKE TABLE OF gt_detail WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_detail> LIKE gt_detail.
