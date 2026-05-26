*&---------------------------------------------------------------------*
*&  Include           ZFF_VAT_RETURNTOP
*&---------------------------------------------------------------------*
TABLES: sscrfields.

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

DATA: gv_jumlah   LIKE zfist001-amnt1,
      gv_discount LIKE zfist001-amnt2,
      gv_dpp      LIKE zfist001-amnt4,
      gv_ppn      LIKE zfist001-amnt5,
      gv_refresh  TYPE flag,
      gv_print    TYPE flag.
