*&---------------------------------------------------------------------*
*&  Include           ZWM_E005TOP
*&---------------------------------------------------------------------*
TABLES : ltak, sscrfields, vttp.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          lgnum   TYPE ltak-lgnum,
          bdatu   TYPE ltak-bdatu,
          tknum   TYPE vttp-tknum,
          vbeln   TYPE ltak-vbeln,
          tanum   TYPE ltak-tanum,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code          TYPE sy-ucomm,
       gs_exclude       TYPE ui_functions,
       g_customcont     TYPE REF TO cl_gui_custom_container,
       g_splitter       TYPE REF TO cl_gui_splitter_container,
       g_contain01      TYPE REF TO cl_gui_container,
       g_tabgrid        TYPE REF TO cl_gui_alv_grid,
       event_receiver   TYPE REF TO lcl_application,
       selected         VALUE 'X',
       gv_repid         LIKE sy-repid,
       gs_variant       LIKE disvariant,
       gs_layout_alv    TYPE lvc_s_layo,
       gt_main_sort     TYPE lvc_t_sort WITH HEADER LINE,
       gt_main_fieldcat TYPE lvc_t_fcat,
       gs_stable        TYPE lvc_s_stbl,
       gs_toolbar       TYPE stb_button,
       gr_hierseq       TYPE REF TO cl_salv_hierseq_table,
       gr_table         TYPE REF TO cl_salv_table,
       g_handle_alv     TYPE i,
       gt_bapiret2      TYPE STANDARD TABLE OF bapiret2.

DATA : gt_out  TYPE STANDARD TABLE OF ty_out,
       gt_ltak TYPE STANDARD TABLE OF ltak,
       gt_vttp TYPE STANDARD TABLE OF vttp.

DATA : matnr             TYPE mara-matnr.
