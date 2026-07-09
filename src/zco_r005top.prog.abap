*&---------------------------------------------------------------------*
*&  Include           ZCORETAX_E004TOP
*&---------------------------------------------------------------------*
TABLES : sscrfields, bkpf, mkpf, covp, ce18010.

TYPES : BEGIN OF ty_filter,
          index TYPE sy-tabix,
        END OF ty_filter.


TYPES : BEGIN OF ty_out,
          mark(1),
          bukrs   TYPE ce18010-bukrs,
          gsber   TYPE ce18010-gsber,
          perio   TYPE ce18010-perio,
          gjahr   TYPE ce18010-gjahr,
          wwsec   TYPE ce18010-wwsec,
          wwtrz   TYPE ce18010-wwtrz,
          rbeln   TYPE ce18010-rbeln,
          belnr   TYPE ce18010-belnr,
          budat   TYPE ce18010-budat,
          vrgar   TYPE ce18010-vrgar,
          prctr   TYPE ce18010-prctr,
          kstar   TYPE ce18010-kstar,
          rkaufnr TYPE ce18010-rkaufnr, "rxaufnr,
          bldat   TYPE bkpf-bldat,
          sgtxt   TYPE bseg-sgtxt,
          "          vrgar   type ce18010-vrgar,
**CE18010-VV856 +
**CE18010-VV846
**
**CE18010-VV857 +
**CE18010-VV818 +
**CE18010-VVD01 +
**CE18010-VVD11 +
**CE18010-VV841 +
**CE18010-VVD02 +
**CE18010-VVD12 +
**CE18010-VV842 +
**CE18010-VV858 +
**CE18010-VV837 +
**CE18010-VV812 +
**CE18010-VV823 +
**CE18010-VV847 +
**CE18010-VVD03 +
**CE18010-VV859 +
**CE18010-VVD05 +
**CE18010-VV864 +
**CE18010-VV862 +
**CE18010-VV863 +
**CE18010-VVD16 +
**CE18010-VVD15 +
**CE18010-VVD13 +
**CE18010-VV810 +



          xblnr   TYPE bkpf-xblnr,
          vv001   TYPE ce18010-vv856,
          vv002   TYPE ce18010-vv856,
          vv000   TYPE ce18010-vv856,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code          TYPE sy-ucomm,
       dynlog           TYPE smp_dyntxt,
       gs_exclude       TYPE ui_functions,
       g_customcont     TYPE REF TO cl_gui_custom_container,
       g_splitter       TYPE REF TO cl_gui_splitter_container,
       g_splitter1      TYPE REF TO cl_gui_splitter_container,
       g_contain01      TYPE REF TO cl_gui_container,
       g_contain02      TYPE REF TO cl_gui_container,
       g_contain03      TYPE REF TO cl_gui_container,
       g_contain04      TYPE REF TO cl_gui_container,
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
       gt_bapiret2      TYPE STANDARD TABLE OF bapiret2,
       gt_filter        TYPE STANDARD TABLE OF ty_filter.

DATA : gt_out  TYPE STANDARD TABLE OF ty_out,
       gt_xout TYPE STANDARD TABLE OF ty_out.

DATA: gv_error(1).
DATA: gv_message(200).
FIELD-SYMBOLS : <fs_out>    TYPE STANDARD TABLE.
