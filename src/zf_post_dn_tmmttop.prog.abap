*&---------------------------------------------------------------------*
*&  Include           ZUPLOAD_FORECASTTOP
*&---------------------------------------------------------------------*
TABLES: sscrfields,zfgscab,zfgscab_dtl,zfgscab_map,zfgstype,zfgscab_map1,ce18010.

TYPE-POOLS: truxs.

TYPES: BEGIN OF ty_hdr,
         bukrs        TYPE bukrs,
         gjahr        TYPE gjahr,
         bukrs_dtl    TYPE bukrs,
         gjahr_dtl    TYPE gjahr,
         vbund        TYPE vbund,
         xref2        TYPE xref2,
         tglpost      TYPE zdpos,
         kunnr        TYPE kunnr,
         name1        TYPE name1_gp,
         amount       TYPE wrbtr,
         ppn          TYPE wrbtr,
         pph          TYPE wrbtr,
         waers        TYPE waers,
         fi_posting   TYPE belnr_d,
         posting_date TYPE budat,
         msg          TYPE char50,
         perfr        TYPE budat,
         perto        TYPE budat,
         sgtxt        TYPE sgtxt,
         icon         TYPE icon_d,
         expand       TYPE char1,
         chkbx(1),
       END OF ty_hdr.

TYPES: BEGIN OF ty_itm,
         bukrs        TYPE bukrs,
         gjahr        TYPE gjahr,
         xref2        TYPE xref2,
         prctr        TYPE prctr,
         matnr        TYPE matnr,
         maktx        TYPE maktx,
         ltext        TYPE ltext,
         exp_desc(40),
         exp_type     TYPE zexptyp,
         nm_break     TYPE char20,
         hkont        TYPE hkont,
         aufnr        TYPE aufnr,
         cust_grp     TYPE char20,
         cust_sub_grp TYPE char20,
         amount       TYPE wrbtr,
         currency     TYPE waers,
         gsber        TYPE gsber,
         wwtrz        TYPE rkeg_wwtrz,
         wwsec        TYPE rkeg_wwsec,
         exp_sub_grp  TYPE c LENGTH 40,
       END OF ty_itm.

* Relat tables
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

DATA: gv_row     TYPE lvc_s_row,
      gv_column  TYPE lvc_s_col,
      gv_row_num TYPE lvc_s_roid.

DATA: dg_dyndoc_id   TYPE REF TO cl_dd_document,
      dg_splitter    TYPE REF TO cl_gui_splitter_container,
      dg_parent_grid TYPE REF TO cl_gui_container,
      dg_html_cntrl  TYPE REF TO cl_gui_html_viewer,
      dg_parent_html TYPE REF TO cl_gui_container.

DATA: gt_zfgscab      TYPE TABLE OF zfgscab WITH HEADER LINE,
      gt_zfgscab_hdr  TYPE TABLE OF zfgscab_hdr WITH HEADER LINE,
      gt_zfgscab_dtl  TYPE TABLE OF zfgscab_dtl WITH HEADER LINE,
      gt_zfgscab_map  TYPE TABLE OF zfgscab_map WITH HEADER LINE,
      gt_zfgscab_map1 TYPE TABLE OF zfgscab_map1 WITH HEADER LINE,
      gt_zfgscab_map2 TYPE TABLE OF zfgscab_map2 WITH HEADER LINE,
      gt_kna1         TYPE TABLE OF kna1 WITH HEADER LINE,
      gt_knvv         TYPE TABLE OF knvv WITH HEADER LINE,
      gt_makt         TYPE TABLE OF makt WITH HEADER LINE,
      gt_marc         TYPE TABLE OF marc WITH HEADER LINE,
      gv_vbund        TYPE vbund,
      gt_cepct        TYPE STANDARD TABLE OF cepct,
      gt_t25a6        TYPE STANDARD TABLE OF t25a6,
      gt_zfiprctr     TYPE STANDARD TABLE OF zfiprctr,
      gt_013          TYPE STANDARD TABLE OF zfidt013.

DATA: gt_hdr      TYPE STANDARD TABLE OF ty_hdr,
      gt_itm      TYPE STANDARD TABLE OF ty_itm,
      gt_itms     TYPE STANDARD TABLE OF ty_itm,
      gs_hdr      LIKE LINE OF gt_hdr,
      gs_itm      LIKE LINE OF gt_itm,
      gv_ucomm    TYPE sy-ucomm,
      gv_chkbx(1),
      gv_err(1).

CONSTANTS: gc_lifnr TYPE lifnr VALUE 'NSB8020',
           gc_bschl TYPE bschl VALUE '40',
           gc_bukrs TYPE bukrs VALUE '8020'.

DATA : gs_lfb1  TYPE lfb1.

FIELD-SYMBOLS: <fs_hdr> TYPE ty_hdr,
               <fs_itm> TYPE ty_itm.

DATA: gt_map1 TYPE TABLE OF zfgscab_map1_struct,
      gs_map1 TYPE zfgscab_map1_struct.
DATA: in_gt_map1 TYPE TABLE OF zfgscab_map1,
      in_gs_map1 TYPE zfgscab_map1.
DATA : ref_grid   TYPE REF TO cl_gui_alv_grid.
DATA: intern LIKE alsmex_tabline OCCURS 0 WITH HEADER LINE.
