*&---------------------------------------------------------------------*
*&  Include           ZWM_E003TOP
*&---------------------------------------------------------------------*
TABLES : vttk, zwmdt004, sscrfields, ekko, lips.
TYPES : BEGIN OF ty_004.
        INCLUDE STRUCTURE zwmdt004.
TYPES : flag,
        END OF ty_004.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          tknum      TYPE zwmdt004-tknum,
          vbeln(16),
          posnr      TYPE zwmdt004-posnr,
          matnr      TYPE zwmdt004-matnr,
          charg      TYPE zwmdt004-charg,
          tanum      TYPE zwmdt004-tanum,
          lfimg      TYPE zwmdt004-lfimg,
          vrkme      TYPE zwmdt004-vrkme,
          nsolm      TYPE ltap-nsolm,
          mored      TYPE ltap-nsolm,
          lessd      TYPE ltap-nsolm,
          rusak      TYPE ltap-nsolm,
          mblnr101   TYPE mkpf-mblnr,
          mjahr101   TYPE mkpf-mjahr,

          mblnr303l  TYPE mkpf-mblnr,
          mjahr303l  TYPE mkpf-mjahr,
          mblnr343l  TYPE mkpf-mblnr,
          mjahr343l  TYPE mkpf-mjahr,
          mblnr344l  TYPE mkpf-mblnr,
          mjahr344l  TYPE mkpf-mjahr,

          mblnr303r  TYPE mkpf-mblnr,
          mjahr303r  TYPE mkpf-mjahr,
          mblnr343r  TYPE mkpf-mblnr,
          mjahr343r  TYPE mkpf-mjahr,
          mblnr344r  TYPE mkpf-mblnr,
          mjahr344r  TYPE mkpf-mjahr,

          style      TYPE lvc_t_styl,
          color      TYPE lvc_t_scol,
        END OF ty_out.

TYPES : BEGIN OF ty_xout,
          tknum      TYPE zwmdt004-tknum,
          vbeln(16),
          posnr      TYPE zwmdt004-posnr,
          matnr      TYPE zwmdt004-matnr,
          charg      TYPE zwmdt004-charg,
          lfimg      TYPE zwmdt004-lfimg,
          vrkme      TYPE zwmdt004-vrkme,
          nsolm      TYPE ltap-nsolm,
          mored      TYPE ltap-nsolm,
          lessd      TYPE ltap-nsolm,
          rusak      TYPE ltap-nsolm,

          mblnr101   TYPE mkpf-mblnr,
          mjahr101   TYPE mkpf-mjahr,

          mblnr303l  TYPE mkpf-mblnr,
          mjahr303l  TYPE mkpf-mjahr,
          mblnr343l  TYPE mkpf-mblnr,
          mjahr343l  TYPE mkpf-mjahr,
          mblnr344l  TYPE mkpf-mblnr,
          mjahr344l  TYPE mkpf-mjahr,

          mblnr303r  TYPE mkpf-mblnr,
          mjahr303r  TYPE mkpf-mjahr,
          mblnr343r  TYPE mkpf-mblnr,
          mjahr343r  TYPE mkpf-mjahr,
          mblnr344r  TYPE mkpf-mblnr,
          mjahr344r  TYPE mkpf-mjahr,
        END OF ty_xout.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code           TYPE sy-ucomm,
       gs_exclude        TYPE ui_functions,
       g_customcont      TYPE REF TO cl_gui_custom_container,
       g_splitter        TYPE REF TO cl_gui_splitter_container,
       g_contain01       TYPE REF TO cl_gui_container,
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
       gt_bapiret2       TYPE STANDARD TABLE OF bapiret2.

DATA : gt_out            TYPE STANDARD TABLE OF ty_out,
       gt_004            TYPE STANDARD TABLE OF zwmdt004,
       gt_ltak           TYPE STANDARD TABLE OF ltak,
       gt_ltap           TYPE STANDARD TABLE OF ltap,
       gt_vttp           TYPE STANDARD TABLE OF vttp,
       gt_lips           TYPE STANDARD TABLE OF lips,
       gt_ekpo           TYPE STANDARD TABLE OF ekpo,
       gt_post           TYPE STANDARD TABLE OF ztwsmmst01,
       rspar_tab         TYPE TABLE OF rsparams,
       rspar_line        LIKE LINE OF rspar_tab.

DATA : gv_subrc   TYPE sy-subrc,
       gv_lgnum   TYPE ltap-lgnum,
       gv_werks   TYPE t320-werks.

DATA : gv_vbeln(16).
