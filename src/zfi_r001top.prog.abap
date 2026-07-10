*&---------------------------------------------------------------------*
*&  Include           ZFI_R001TOP
*&---------------------------------------------------------------------*
TABLES : vttk, zwmdt004, sscrfields, bkpf.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4).
        INCLUDE STRUCTURE zfist002.
*TYPES :   style       TYPE lvc_t_styl,
*          color       TYPE lvc_t_scol,
TYPES : END OF ty_out.

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
       gt_bapiret2       TYPE STANDARD TABLE OF bapiret2.

DATA : gt_data           TYPE STANDARD TABLE OF zfist002,
       gt_out            TYPE STANDARD TABLE OF ty_out,
       gt_bkpf           TYPE STANDARD TABLE OF bkpf,
       gt_xbkpf          TYPE STANDARD TABLE OF bkpf,
       gt_bseg           TYPE STANDARD TABLE OF bseg,
       gt_xbseg          TYPE STANDARD TABLE OF bseg,
       gt_ybseg          TYPE STANDARD TABLE OF bseg,
       gt_zbseg          TYPE STANDARD TABLE OF bseg,
       gt_abseg          TYPE STANDARD TABLE OF bseg,
       gt_addbseg        TYPE STANDARD TABLE OF bseg,
       gt_012            TYPE STANDARD TABLE OF zgdtxdt0012,
       gt_ekbe           TYPE STANDARD TABLE OF ekbe,
       gt_mseg           TYPE STANDARD TABLE OF mseg,
       gt_skat           TYPE STANDARD TABLE OF skat.

DATA : gt_blart1         TYPE STANDARD TABLE OF rsoblart,
       gt_blart2         TYPE STANDARD TABLE OF rsoblart.

DATA : gv_hkont          TYPE bseg-hkont,
       gv_waers          TYPE t001-waers,
       gv_ppn            TYPE bseg-hkont,
       gv_pph23          TYPE bseg-hkont,
       gv_pph42          TYPE bseg-hkont.

DATA : gr_hkont          TYPE RANGE OF hkont,
       gr_hkont_kmm      TYPE RANGE OF hkont,
       gr_hkont_sff      TYPE RANGE OF hkont,
       gr_hkont_pli      TYPE RANGE OF hkont,
       gr_buzid          TYPE RANGE OF buzid.
