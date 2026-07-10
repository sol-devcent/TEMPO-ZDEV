*&---------------------------------------------------------------------*
*&  Include           ZCO_NDCCTOP
*&---------------------------------------------------------------------*
TABLES : mbew, ckmlkeph, sscrfields.

CLASS lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF ty_mkpf,
          mblnr   TYPE mkpf-mblnr,
          mjahr   TYPE mkpf-mjahr,
          matnr   TYPE mseg-matnr,
        END OF ty_mkpf.

DATA : gt_mara      TYPE STANDARD TABLE OF mara,
       gt_marc      TYPE STANDARD TABLE OF marc,
       gt_makt      TYPE STANDARD TABLE OF makt,
       gt_t023t     TYPE STANDARD TABLE OF t023t,
       gt_mbew      TYPE STANDARD TABLE OF mbew,
       gt_ckmlkeph  TYPE STANDARD TABLE OF ckmlkeph.

DATA : gr_categ     TYPE RANGE OF categ.

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
         vn001w   LIKE ckmlkeph-kst001,
         vn001x   LIKE ckmlkeph-kst001,
         vn001y   LIKE ckmlkeph-kst001,
         vn001z   LIKE ckmlkeph-kst001,
         eb003    LIKE ckmlkeph-kst003,
         ab003    LIKE ckmlkeph-kst003,
         zu003    LIKE ckmlkeph-kst003,
         vn003w   LIKE ckmlkeph-kst003,
         vn003x   LIKE ckmlkeph-kst003,
         vn003y   LIKE ckmlkeph-kst003,
         vn003z   LIKE ckmlkeph-kst003,
         eb005    LIKE ckmlkeph-kst005,
         ab005    LIKE ckmlkeph-kst005,
         zu005    LIKE ckmlkeph-kst005,
         vn005w   LIKE ckmlkeph-kst005,
         vn005x   LIKE ckmlkeph-kst005,
         vn005y   LIKE ckmlkeph-kst005,
         vn005z   LIKE ckmlkeph-kst005,
         eb007    LIKE ckmlkeph-kst007,
         ab007    LIKE ckmlkeph-kst007,
         zu007    LIKE ckmlkeph-kst007,
         vn007w   LIKE ckmlkeph-kst005,
         vn007x   LIKE ckmlkeph-kst005,
         vn007y   LIKE ckmlkeph-kst005,
         vn007z   LIKE ckmlkeph-kst005,
         eb009    LIKE ckmlkeph-kst009,
         ab009    LIKE ckmlkeph-kst009,
         zu009    LIKE ckmlkeph-kst009,
         vn009w   LIKE ckmlkeph-kst005,
         vn009x   LIKE ckmlkeph-kst005,
         vn009y   LIKE ckmlkeph-kst005,
         vn009z   LIKE ckmlkeph-kst005,
         eb011    LIKE ckmlkeph-kst011,
         ab011    LIKE ckmlkeph-kst011,
         zu011    LIKE ckmlkeph-kst011,
         vn011w   LIKE ckmlkeph-kst005,
         vn011x   LIKE ckmlkeph-kst005,
         vn011y   LIKE ckmlkeph-kst005,
         vn011z   LIKE ckmlkeph-kst005,
       END OF gt_calc.

DATA : BEGIN OF gt_out OCCURS 0,
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
       END OF gt_out.

DATA : gt_mkpf    TYPE STANDARD TABLE OF ty_mkpf,
       gt_mseg    TYPE STANDARD TABLE OF mseg.
