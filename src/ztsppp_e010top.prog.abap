*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E010TOP
*&---------------------------------------------------------------------*
TABLES : resb, sscrfields.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          werks   TYPE werks_d,
          rsnum   TYPE resb-rsnum,
          rspos   TYPE resb-rspos,
          aufnr   TYPE resb-aufnr,
          vornr   TYPE resb-vornr,
          posnr   TYPE resb-posnr,
          charg   TYPE resb-charg,
          baugr   TYPE resb-baugr,
          matnr   TYPE resb-matnr,
          mblnr   TYPE mseg-mblnr,
          mjahr   TYPE mseg-mjahr,
          zeile   TYPE mseg-zeile,
          menge   TYPE mseg-menge,
          meins   TYPE mseg-meins,
          splkz   TYPE resb-splkz,
          wempf   TYPE resb-wempf,
          aufnr2  TYPE resb-aufnr,
          fw      TYPE char1,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code          TYPE sy-ucomm,
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
       dynlog           TYPE smp_dyntxt.

DATA : gt_out         TYPE STANDARD TABLE OF ty_out,
       gt_out_error   TYPE STANDARD TABLE OF ty_out,
       gs_zppresb_add TYPE zppresb_add,
       gt_resb        TYPE STANDARD TABLE OF resb,
       gs_resb        LIKE LINE OF gt_resb,
       gt_xresb       TYPE STANDARD TABLE OF resb,
       gt_mseg        TYPE STANDARD TABLE OF mseg.

DATA : gt_dresb       TYPE STANDARD TABLE OF resb,
       gt_uresb       TYPE STANDARD TABLE OF resb,
       gt_onr00       TYPE STANDARD TABLE OF onr00,
       gt_jest        TYPE STANDARD TABLE OF jest,
       gt_jsto        TYPE STANDARD TABLE OF jsto,
       gt_zkmmppdt019 TYPE STANDARD TABLE OF zkmmppdt019,
       gt_zkmmppdt023 TYPE STANDARD TABLE OF zkmmppdt023,
       gt_zkmmppdt024 TYPE STANDARD TABLE OF zkmmppdt024,
       gt_ztspppdt011 TYPE STANDARD TABLE OF ztspppdt011,
       gt_ztspppdt012 TYPE STANDARD TABLE OF ztspppdt012,
       gt_zsffppdt002 TYPE STANDARD TABLE OF zsffppdt002,
       gt_zsffppdt004 TYPE STANDARD TABLE OF zsffppdt004,
       gt_add         TYPE STANDARD TABLE OF zppresb_add.

DATA : gv_subrc          TYPE sy-subrc.
