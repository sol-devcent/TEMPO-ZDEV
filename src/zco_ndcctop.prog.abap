*&---------------------------------------------------------------------*
*&  Include           ZCO_NDCCTOP
*&---------------------------------------------------------------------*
TABLES : mbew, ckmlkeph, sscrfields.

CLASS lcl_application DEFINITION DEFERRED.

DATA : gt_mara      TYPE STANDARD TABLE OF mara,
       gt_marc      TYPE STANDARD TABLE OF marc,
       gt_makt      TYPE STANDARD TABLE OF makt,
       gt_t023t     TYPE STANDARD TABLE OF t023t,
       gt_mbew      TYPE STANDARD TABLE OF mbew,
       gt_ckmlkeph  TYPE STANDARD TABLE OF ckmlkeph.

DATA : gr_categ     TYPE RANGE OF categ,
       gv_bukrs     TYPE bukrs,
       gv_status(5).

CONSTANTS : co_mlcct  LIKE ckmlkeph-mlcct VALUE 'E'.

DATA : gv_repid              TYPE sy-repid,
       ok_code               TYPE sy-ucomm,
       g_outcont             TYPE REF TO cl_gui_custom_container,
       g_splitter            TYPE REF TO cl_gui_splitter_container,
       g_container           TYPE REF TO cl_gui_container,
       g_outgrid             TYPE REF TO cl_gui_alv_grid,
       gs_exclude            TYPE ui_functions,
       event_receiver        TYPE REF TO lcl_application,
       selected              VALUE 'X',
       gs_variant            LIKE disvariant,
       gs_layout_alv         TYPE lvc_s_layo,
       gt_sort_grid          TYPE lvc_t_sort WITH HEADER LINE,
       gt_fieldcat           TYPE lvc_t_fcat,
       gs_stable             TYPE lvc_s_stbl,
       gs_toolbar            TYPE stb_button.

DATA : BEGIN OF gt_calc OCCURS 0,
         eb001    LIKE ckmlkeph-kst001,
         ab001    LIKE ckmlkeph-kst001,
         zu001    LIKE ckmlkeph-kst001,
         vn001    LIKE ckmlkeph-kst001,
         eb003    LIKE ckmlkeph-kst003,
         ab003    LIKE ckmlkeph-kst003,
         zu003    LIKE ckmlkeph-kst003,
         vn003    LIKE ckmlkeph-kst003,
         eb005    LIKE ckmlkeph-kst005,
         ab005    LIKE ckmlkeph-kst005,
         zu005    LIKE ckmlkeph-kst005,
         vn005    LIKE ckmlkeph-kst005,
         eb007    LIKE ckmlkeph-kst007,
         ab007    LIKE ckmlkeph-kst007,
         zu007    LIKE ckmlkeph-kst007,
         vn007    LIKE ckmlkeph-kst007,
         eb009    LIKE ckmlkeph-kst009,
         ab009    LIKE ckmlkeph-kst009,
         zu009    LIKE ckmlkeph-kst009,
         vn009    LIKE ckmlkeph-kst009,
         eb011    LIKE ckmlkeph-kst011,
         ab011    LIKE ckmlkeph-kst011,
         zu011    LIKE ckmlkeph-kst011,
         vn011    LIKE ckmlkeph-kst011,
       END OF gt_calc.

DATA : BEGIN OF gt_out OCCURS 0,
         bukrs    TYPE bukrs,
         bwkey    LIKE mbew-bwkey,
         poper    LIKE ckmlkeph-poper,
         bdatj    LIKE ckmlkeph-bdatj,
         matnr    LIKE mbew-matnr,
         maktx    LIKE makt-maktx,
         matkl    LIKE mara-matkl,
         wgbez    LIKE t023t-wgbez,
         prctr    LIKE marc-prctr,
         waers    LIKE ckmlkeph-waers,
         kst001   LIKE ckmlkeph-kst001,
         kst003   LIKE ckmlkeph-kst003,
         kst005   LIKE ckmlkeph-kst005,
         kst007   LIKE ckmlkeph-kst007,
         kst009   LIKE ckmlkeph-kst009,
         kst011   LIKE ckmlkeph-kst011,
         total    LIKE ckmlkeph-kst001,
         message  TYPE bapi_msg,
         status(10),
       END OF gt_out.
