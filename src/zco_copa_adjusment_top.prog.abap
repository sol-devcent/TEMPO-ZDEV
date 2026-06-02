*&---------------------------------------------------------------------*
*&  Include           ZCO_NDCCTOP
*&---------------------------------------------------------------------*
TABLES : ce18010,bkpf,bseg,sscrfields.

CLASS lcl_application DEFINITION DEFERRED.

DATA : BEGIN OF gt_out OCCURS 0,
         bukrs      TYPE bukrs,
         gsber      TYPE gsber,
         perio      TYPE jahrper,
         gjahr      TYPE gjahr,
         artnr      TYPE artnr,
         maktx      TYPE maktx,
         prctr      TYPE prctr,
         dmbtr      TYPE dmbtr,
         vvd00      TYPE rke2_vvd00,
         vvd11      TYPE rke2_vvd11,
         vvd12      TYPE rke2_vvd12,
         vvd13      TYPE rke2_vvd13,
         vvd14      TYPE rke2_vvd14,
         vvd15      TYPE rke2_vvd15,
         vvd16      TYPE rke2_vvd16,
         vv845      TYPE rke2_vv845,
         variant    TYPE rke2_vvd00,
         posval     TYPE zcodt011-posval,
         waers      TYPE waers,
         celltab    TYPE lvc_t_styl,
         message    TYPE bapi_msg,
         status(10),
         chkbox(1),
       END OF gt_out.

DATA : BEGIN OF gt_zcor018 OCCURS 0,
         bukrs      TYPE bukrs,
         bwkey      LIKE mbew-bwkey,
         poper      LIKE ckmlkeph-poper,
         bdatj      LIKE ckmlkeph-bdatj,
         matnr      LIKE mbew-matnr,
         status(10),
       END OF gt_zcor018.

DATA : gt_ce18010   TYPE STANDARD TABLE OF ce18010,
       gt_bkpf      TYPE STANDARD TABLE OF bkpf,
       gt_bseg      TYPE STANDARD TABLE OF bseg,
       gt_makt      TYPE STANDARD TABLE OF makt,
       gt_marc      TYPE STANDARD TABLE OF marc,
       gv_status(5).

DATA : gr_bstat TYPE RANGE OF bstat_d,
       gr_budat TYPE RANGE OF budat,
       gr_hkont TYPE RANGE OF hkont.

DATA : gv_repid       TYPE sy-repid,
       ok_code        TYPE sy-ucomm,
       g_outcont      TYPE REF TO cl_gui_custom_container,
       g_splitter     TYPE REF TO cl_gui_splitter_container,
       g_container    TYPE REF TO cl_gui_container,
       g_outgrid      TYPE REF TO cl_gui_alv_grid,
       gs_exclude     TYPE ui_functions,
       event_receiver TYPE REF TO lcl_application,
       selected       VALUE 'X',
       gs_variant     LIKE disvariant,
       gs_layout_alv  TYPE lvc_s_layo,
       gt_sort_grid   TYPE lvc_t_sort WITH HEADER LINE,
       gt_fieldcat    TYPE lvc_t_fcat,
       gs_stable      TYPE lvc_s_stbl,
       gs_toolbar     TYPE stb_button.

CONSTANTS : co_mlcct  LIKE ckmlkeph-mlcct VALUE 'E'.

FIELD-SYMBOLS: <fs_out> LIKE LINE OF gt_out.
