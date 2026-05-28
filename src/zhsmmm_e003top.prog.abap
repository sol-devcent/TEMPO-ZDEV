*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E003TOP
*&---------------------------------------------------------------------*
TABLES : ekko, sscrfields.

CLASS : lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF ty_tree,
          node_main(50),
          matnr   TYPE mara-matnr,
          lifnr   TYPE lfa1-lifnr,
          submi   TYPE ekko-submi,
          ebeln   TYPE ekko-ebeln,
        END OF ty_tree.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          loekz   TYPE ekpo-loekz,
          submi   TYPE ekko-submi,
          lifnr   TYPE ekko-lifnr,
          name1   TYPE lfa1-name1,
          ekgrp   TYPE ekko-ekgrp,
          ebeln   TYPE ekko-ebeln,
          ebelp   TYPE ekpo-ebelp,
          banfn   TYPE ekpo-banfn,
          bnfpo   TYPE ekpo-bnfpo,
          bedat   TYPE ekko-bedat,
          matnr   TYPE ekpo-matnr,
          maktx   TYPE makt-maktx,
          waers   TYPE ekko-waers,
          netpr   TYPE ekpo-netpr,
          menge   TYPE ekpo-menge,
          meins   TYPE ekpo-meins,
          ihran   TYPE ekko-ihran,
          aedat   TYPE ekko-aedat,
          bwbdt   TYPE ekko-bwbdt,
          angdt   TYPE ekko-angdt,
          kdatb   TYPE ekko-kdatb,
          kdate   TYPE ekko-kdate,
          bnddt   TYPE ekko-bnddt,
          ernam   TYPE ekko-ernam,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

TYPES : BEGIN OF ty_out1,
          icon(4),
          werks   TYPE ekpo-werks,
          submi   TYPE ekko-submi,
          ebeln   TYPE ekpo-ebeln,
          ebelp   TYPE ekpo-ebelp,
          banfn   TYPE ekpo-banfn,
          bnfpo   TYPE ekpo-bnfpo,
          lfdat   TYPE eban-lfdat,
          matnr   TYPE ekpo-matnr,
          txz01   TYPE ekpo-txz01,
          angdt   TYPE ekko-angdt,
          menge   TYPE ekpo-menge,
          meins   TYPE ekpo-meins,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out1.

TYPES : BEGIN OF ty_title,
          t01(50),
          t02(50),
          t03(50),
          t04(50),
          t05(50),
          t06(50),
          t07(50),
          t08(50),
          t09(50),
          t10(50),
        END OF ty_title.

TYPES : BEGIN OF ty_coll,
          ekgrp   TYPE ekko-ekgrp,
          submi   TYPE ekko-submi,
          ernam   TYPE ekko-ernam,
        END OF ty_coll.

TYPES : BEGIN OF ty_email,
          email   TYPE zhsmmmdt005-smtp_addr,
        END OF ty_email.

TYPES : BEGIN OF ty_filter,
          index   TYPE sy-tabix,
        END OF ty_filter.

DATA : BEGIN OF zus OCCURS 10.
        INCLUDE STRUCTURE t16fv.
DATA : END OF zus.

DATA : BEGIN OF zuskey,
         mandt LIKE ekko-mandt,
         frggr LIKE ekko-frggr,
         frgsx LIKE ekko-frgsx,
       END OF zuskey.

DATA : gt_tree              TYPE STANDARD TABLE OF ty_tree.

DATA : gt_ekko              TYPE STANDARD TABLE OF ekko,
       gt_ekpo              TYPE STANDARD TABLE OF ekpo,
       gt_eket              TYPE STANDARD TABLE OF eket,
       gt_lfa1              TYPE STANDARD TABLE OF lfa1,
       gt_makt              TYPE STANDARD TABLE OF makt,
       gt_eban              TYPE STANDARD TABLE OF eban,
       gt_data              TYPE STANDARD TABLE OF ty_out,
       gt_out               TYPE STANDARD TABLE OF ty_out,
       gt_xout              TYPE STANDARD TABLE OF ty_out,
       gt_out1              TYPE STANDARD TABLE OF ty_out1,
       gt_05                TYPE STANDARD TABLE OF zhsmmmdt005.

DATA : gt_fcat              TYPE lvc_t_fcat,
       gt_html              TYPE STANDARD TABLE OF w3html,
       gt_coll              TYPE STANDARD TABLE OF ty_coll.

DATA : ok_code              TYPE sy-ucomm,
       dyn_process          TYPE smp_dyntxt,
       dyn_reject           TYPE smp_dyntxt,
       dynlog               TYPE smp_dyntxt,
       gs_exclude           TYPE ui_functions,
       gs_exclude1          TYPE ui_functions,
       g_customcont         TYPE REF TO cl_gui_custom_container,
       g_splitter           TYPE REF TO cl_gui_splitter_container,
       g_splitter1          TYPE REF TO cl_gui_splitter_container,
       g_contain01          TYPE REF TO cl_gui_container,
       g_contain02          TYPE REF TO cl_gui_container,
       g_contain03          TYPE REF TO cl_gui_container,
       g_contain04          TYPE REF TO cl_gui_container,
       g_tabgrid01          TYPE REF TO cl_gui_alv_grid,
       g_tabgrid02          TYPE REF TO cl_gui_alv_grid,
       g_tree               TYPE REF TO cl_gui_alv_tree,
       g_header             TYPE treev_hhdr,
       g_docking            TYPE REF TO cl_gui_docking_container,
       event_receiver       TYPE REF TO lcl_application,
       selected             VALUE 'X',
       gv_repid             LIKE sy-repid,
       gv_dynnr             TYPE sy-dynnr,
       gs_variant           LIKE disvariant,
       gs_main_layout       TYPE lvc_s_layo,
       gs_detail_layout     TYPE lvc_s_layo,
       gt_main_sort         TYPE lvc_t_sort WITH HEADER LINE,
       gt_detail_sort       TYPE lvc_t_sort WITH HEADER LINE,
       gt_tree_fieldcat     TYPE lvc_t_fcat,
       gt_main_fieldcat     TYPE lvc_t_fcat,
       gt_detail_fieldcat   TYPE lvc_t_fcat,
       gs_stable            TYPE lvc_s_stbl,
       gs_toolbar           TYPE stb_button,
       gr_hierseq           TYPE REF TO cl_salv_hierseq_table,
       gr_table             TYPE REF TO cl_salv_table,
       g_handle_alv         TYPE i,
       gt_bapiret2          TYPE STANDARD TABLE OF bapiret2,
       gt_filter            TYPE STANDARD TABLE OF ty_filter.

DATA : gv_fieldname(30).
