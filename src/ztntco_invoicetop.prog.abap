*&---------------------------------------------------------------------*
*&  Include           ZUPLOAD_FORECASTTOP
*&---------------------------------------------------------------------*
TABLES: sscrfields,zrevtr001,zratetr001,zaloktr01,zaloktr02.

TYPE-POOLS: truxs.

TYPES: BEGIN OF ty_hdr,
         chkbx(1),
         icon       TYPE icon_d,
         bukrs      TYPE bukrs,
         gjahr      TYPE gjahr,
         linno      TYPE zlinno,
         bktxt      TYPE bktxt,
         invno      TYPE zinvno,
         invdt      TYPE zinvdt,
         kunnr      TYPE kunnr,
         name1      TYPE name1_gp,
         zqty       TYPE zquan,
         tarif      TYPE wrbtr,
         amount     TYPE dmbtr,
         net_amount TYPE wrbtr,
         waerk      TYPE waerk,
         postdoc    TYPE belnr_d,
         postyear   TYPE gjahr,
         postname   TYPE uname,
         postdate   TYPE datum,
         fakturno   TYPE zgdtxde_fakno,
         ratetyp    TYPE zratetyp,
         expand     TYPE char1,
         msg        TYPE char50,
       END OF ty_hdr.

TYPES: BEGIN OF ty_itm,
         bukrs   TYPE bukrs,
         gjahr   TYPE gjahr,
         linno   TYPE zlinno,
         invno   TYPE zinvno,
         kostl   TYPE kostl,
         zxref   TYPE zxref,
         bgitm   TYPE zbgitm,
         itmdsc  TYPE zitmdsc,
         amount  TYPE dmbtr,
         waerk   TYPE waerk,
         ratetyp TYPE zratetyp,
         ratetxt TYPE zratetr001-ratetxt,
         zgrp    TYPE zgrp,
         revtyp  TYPE zrevtyp,
         subdt   TYPE zrevtr001-subdt,
         aprdt   TYPE zrevtr001-aprdt,
         factory TYPE zrevtr001-factory,
         zqty    TYPE zrevtr001-zqty,
       END OF ty_itm.


TYPES: BEGIN OF ty_out4.
         INCLUDE STRUCTURE zaloktr02.
         TYPES:  revtyp     TYPE zrevtyp,
         zgrp       TYPE zgrp,
         zsgrp      TYPE matkl,
         net_amount TYPE wrbtr,
         factor     TYPE zcofactor,
       END OF ty_out4.

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

DATA: gv_cond TYPE edpline,
      gt_cond TYPE TABLE OF edpline.

DATA: gt_out     TYPE TABLE OF ztrcost001 WITH HEADER LINE,
      gt_out2    TYPE TABLE OF zrevtr001 WITH HEADER LINE,
      gt_out3    TYPE TABLE OF zaloktr01 WITH HEADER LINE,
      gt_out4    TYPE TABLE OF ty_out4 WITH HEADER LINE,
      gw_out     LIKE LINE OF  gt_out,
      gw_out2    LIKE LINE OF  gt_out2,
      gt_outlog  TYPE TABLE OF ztdnsddt010 WITH HEADER LINE,
      gt_error   TYPE TABLE OF ztdnsddt011,
      gt_upload  LIKE TABLE OF ztrcost001,
      gw_upload  LIKE LINE OF  gt_upload,
      gt_upload2 LIKE TABLE OF ztrcost002,
      gw_upload2 LIKE LINE OF  gt_upload2,
      gt_upload3 LIKE TABLE OF ztrcost003,
      gw_upload3 LIKE LINE OF  gt_upload3.

DATA: gt_zrevtr001     TYPE TABLE OF zrevtr001 WITH HEADER LINE,
      gt_zaloktr02     TYPE TABLE OF zaloktr02 WITH HEADER LINE,
      gt_zaloktr02sum  TYPE TABLE OF zaloktr02 WITH HEADER LINE,
      gt_zratetr001    TYPE TABLE OF zratetr001 WITH HEADER LINE,
      gt_ztr_order_mst TYPE TABLE OF ztr_order_mst WITH HEADER LINE,
      gs_header        LIKE ztrcost003h,
      gt_detail        TYPE TABLE OF ztrcost003d,
      gs_detail        LIKE LINE OF gt_detail,
      gt_adrc          TYPE TABLE OF adrc WITH HEADER LINE,
      gt_makt          TYPE TABLE OF makt WITH HEADER LINE,
      gt_csks          TYPE TABLE OF csks WITH HEADER LINE,
      gt_coas          TYPE TABLE OF coas WITH HEADER LINE.

DATA: gv_name1       TYPE kna1-name1,
      gs_ztrcost003h TYPE ztrcost003h,
      gt_ztrcost003d TYPE TABLE OF ztrcost003d WITH HEADER LINE.

DATA: gt_hdr      TYPE STANDARD TABLE OF ty_hdr,
      gs_hdr      TYPE ty_hdr,
      gt_itm      TYPE STANDARD TABLE OF ty_itm,
      gs_itm      TYPE ty_itm,
      gv_chkbx(1),
      gv_err(1).

CONSTANTS: gc_kokrs TYPE kokrs VALUE '8010',
           gc_gsber TYPE gsber VALUE '1600',
           gc_aufnr TYPE aufnr VALUE '%8010'.

FIELD-SYMBOLS: <fs_out>  LIKE gt_out,
               <fs_out2> LIKE gt_out2,
               <fs_out3> LIKE gt_out3,
               <fs_out4> LIKE gt_out4,
               <fs_err>  LIKE ztdnsddt011,
               <fs_hdr>  TYPE ty_hdr.

DATA: gs_dpp      TYPE zproject,
      gr_coretax  TYPE RANGE OF datum,
      dynlog      TYPE smp_dyntxt,
      gt_bapiret2 TYPE STANDARD TABLE OF bapiret2.
