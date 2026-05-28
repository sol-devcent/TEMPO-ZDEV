*&---------------------------------------------------------------------*
*&  Include           ZTDNFI_I003_TOP
*&---------------------------------------------------------------------*
TABLES: vbrk, vbrp, bsad, bsid, bseg, ztdnfidt007h, ztdnfidt007d.

TYPES: BEGIN OF ty_header,
         expand          TYPE char1,
         chkbx,
         bukrs           TYPE bsad-bukrs,
         vkbur           TYPE vbrp-vkbur,
         kunnr           TYPE bsad-kunnr,
         name1           TYPE kna1-name1,
         belnr           TYPE bsad-belnr,
         zuonr           TYPE bsad-zuonr,
         wrbtr           type bsad-wrbtr,
         waers           type bsad-waers,
         vbeln           TYPE vbrk-vbeln,
         kdgrp           TYPE vbrk-kdgrp,
         kvgr3           TYPE vbrp-kvgr3,
         budat           TYPE bsad-budat,
         zfbdt           TYPE bsad-zfbdt,
         shkzg           TYPE bsad-shkzg,
         zterm           TYPE bsad-zterm,
         gjahr           TYPE bsad-gjahr,
         augbl           TYPE bsad-augbl,
         knumh           TYPE konp-knumh,
         "         dmbtr           TYPE bsad-dmbtr,

         persen_discount TYPE vbrp-kzwi5,
         hari            TYPE numc3,
         tot_kzwi5       TYPE vbrp-kzwi5,
         cash_discount   TYPE vbrp-kzwi5,
         CPUDT           type bsad-cpudt,
         celltab         TYPE lvc_t_styl,

       END OF ty_header.
TYPES: BEGIN OF ty_detail,
         expand        TYPE char1,
         vbeln         TYPE vbrp-vbeln,
         belnr         TYPE bsad-belnr,
         posnr         TYPE vbrp-posnr,
         matnr         TYPE vbrp-matnr,
         arktx         TYPE vbrp-arktx,
         kzwi5         TYPE vbrp-kzwi5,
         mvgr1         TYPE vbrp-mvgr1,
         cash_discount TYPE vbrp-kzwi5,
         matkl         type vbrp-matkl,
         "         persen_dicount TYPE vbrp-kzwi5,
       END OF ty_detail.
TYPES : BEGIN OF ty_filter,
          index TYPE sy-tabix,
        END OF ty_filter.

DATA: gt_header   TYPE STANDARD TABLE OF ty_header,
      "gt_header_h TYPE STANDARD TABLE OF ty_header,
      gt_detail   TYPE STANDARD TABLE OF ty_detail.
DATA: gt_zghfidt002 TYPE STANDARD TABLE OF zghfidt002.
DATA: GT_TVBUR TYPE STANDARD TABLE OF TVBUR WITH HEADER LINE.
DATA: gt_binding TYPE salv_t_hierseq_binding,
      gs_binding TYPE salv_s_hierseq_binding.

*- ALV hierarchical Declarations
DATA:

*- Main class used to create the hierarchical-sequential list
  gr_selections  TYPE REF TO cl_salv_selections,
  gt_hierseq     TYPE REF TO cl_salv_hierseq_table,
  gt_layout      TYPE REF TO cl_salv_layout,
  gt_top_content TYPE REF TO cl_salv_form_element,
  gt_display     TYPE REF TO cl_salv_display_settings,
  key            TYPE salv_s_layout_key,

*- To add functions to the application toolbar
  gt_functions   TYPE REF TO cl_salv_functions_list,
  gt_print       TYPE REF TO cl_salv_print,
  gt_level       TYPE REF TO cl_salv_hierseq_level,
  gt_column      TYPE REF TO cl_salv_column_hierseq,
  gt_columns     TYPE REF TO cl_salv_columns_hierseq,
  gt_events      TYPE REF TO cl_salv_events_hierseq,
  gr_level       TYPE REF TO cl_salv_hierseq_level.

* Refrence Objects To Alv Grid & Custom Container Classes
DATA: g_container        TYPE scrfname VALUE 'CONTAINER',
      g_grid             TYPE REF TO cl_gui_alv_grid,
*      g_handler   TYPE REF TO lcl_event_responder,
*      g_event_handler TYPE REF TO lcl_event_handler,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      gt_fieldcat        TYPE lvc_t_fcat WITH HEADER LINE,
      gt_sort            TYPE lvc_t_sort WITH HEADER LINE,
      gs_layout          TYPE lvc_s_layo,
      gv_repid           LIKE sy-repid,
      gs_variant         TYPE disvariant,
      gt_exclude         TYPE ui_functions,
      e_object           TYPE REF TO cl_alv_event_toolbar_set.

DATA: it_fieldcat TYPE lvc_t_fcat,
      wa_fieldcat TYPE lvc_s_fcat.
DATA: gv_row     TYPE lvc_s_row,
      gv_column  TYPE lvc_s_col,
      gv_row_num TYPE lvc_s_roid.

DATA: dg_dyndoc_id   TYPE REF TO cl_dd_document,
      dg_splitter    TYPE REF TO cl_gui_splitter_container,
      dg_parent_grid TYPE REF TO cl_gui_container,
      dg_html_cntrl  TYPE REF TO cl_gui_html_viewer,
      dg_parent_html TYPE REF TO cl_gui_container.
"CLASS : lcl_application DEFINITION DEFERRED.

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
       "      event_receiver   TYPE REF TO lcl_application,
       selected         VALUE 'X',
       "gv_repid         LIKE sy-repid,
       "gs_variant       LIKE disvariant,
       "gs_layout_alv    TYPE lvc_s_layo,
       gt_main_sort     TYPE lvc_t_sort WITH HEADER LINE,
       gt_main_fieldcat TYPE lvc_t_fcat,
       gs_stable        TYPE lvc_s_stbl,
       gs_toolbar       TYPE stb_button,
       gr_hierseq       TYPE REF TO cl_salv_hierseq_table,
       gr_table         TYPE REF TO cl_salv_table,
       g_handle_alv     TYPE i,
       gt_bapiret2      TYPE STANDARD TABLE OF bapiret2,
       gt_filter        TYPE STANDARD TABLE OF ty_filter.
