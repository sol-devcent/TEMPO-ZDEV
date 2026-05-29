*&---------------------------------------------------------------------*
*&  Include           ZTDS_RTMPTOP
*&---------------------------------------------------------------------*
TABLES : ztspppdt009, sscrfields.

TYPES : BEGIN OF ty_filter,
          index   TYPE sy-tabix,
        END OF ty_filter.

TYPES : BEGIN OF ty_out.
          INCLUDE STRUCTURE ztspppdt009.
TYPES :   fgmat   TYPE matnr,
          fgdes   TYPE maktx,
          fgbat   TYPE charg_d,
          mark,
          icon(4),
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code           TYPE sy-ucomm,
       dynlog            TYPE smp_dyntxt,
       gs_exclude        TYPE ui_functions,
       g_customcont      TYPE REF TO cl_gui_custom_container,
       g_splitter        TYPE REF TO cl_gui_splitter_container,
       g_splitter1       TYPE REF TO cl_gui_splitter_container,
       g_contain01       TYPE REF TO cl_gui_container,
       g_contain02       TYPE REF TO cl_gui_container,
       g_contain03       TYPE REF TO cl_gui_container,
       g_contain04       TYPE REF TO cl_gui_container,
       g_tabgrid         TYPE REF TO cl_gui_alv_grid,
       event_receiver    TYPE REF TO lcl_application,
       selected          VALUE 'X',
       gv_repid          LIKE sy-repid,
       gs_variant        LIKE disvariant,
       gs_layout_alv     TYPE lvc_s_layo,
       gt_main_sort      TYPE lvc_t_sort WITH HEADER LINE,
       gt_main_fieldcat  TYPE lvc_t_fcat,
       gs_stable         TYPE lvc_s_stbl,
       gs_toolbar        TYPE stb_button,
       gr_hierseq        TYPE REF TO cl_salv_hierseq_table,
       gr_table          TYPE REF TO cl_salv_table,
       g_handle_alv      TYPE i,
       gt_bapiret2       TYPE STANDARD TABLE OF bapiret2,
       gt_filter         TYPE STANDARD TABLE OF ty_filter.

DATA : gt_out            TYPE STANDARD TABLE OF ty_out,
       gt_xout           TYPE STANDARD TABLE OF ty_out,
       gt_afpo           TYPE STANDARD TABLE OF afpo,
       gt_makt           TYPE STANDARD TABLE OF makt,
       gt_ztspppdt009    TYPE STANDARD TABLE OF ztspppdt009.

FIELD-SYMBOLS: <fs_out>  TYPE ty_out.
