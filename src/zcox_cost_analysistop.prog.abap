*&---------------------------------------------------------------------*
*&  Include           ZCO_COST_ANALYSISTOP
*&---------------------------------------------------------------------*
INCLUDE <icon>.

TABLES : caufv, sscrfields, tj02t.

CLASS : lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF ty_material,
          matnr TYPE mara-matnr,
          meins TYPE mara-meins,
          mtart TYPE mara-mtart,
        END OF ty_material.

TYPES : BEGIN OF ty_header,
          plnbez    LIKE caufv-plnbez,
          aufnr     LIKE caufv-aufnr,
          meins     LIKE mara-meins,
          ktext     LIKE caufv-ktext,
          gamng     LIKE caufv-gamng,
          wemng     LIKE afpo-wemng,
          wewrt     LIKE afpo-wewrt,
          waers     LIKE caufv-waers,
          descr(60),
          yield     TYPE p DECIMALS 2,
          stat      LIKE bsvx-sttxt,
        END OF ty_header.

TYPES : BEGIN OF ty_detail,
          objnr     LIKE caufv-objnr,
          aufnr     LIKE caufv-aufnr,
          gltri     LIKE caufv-gltri,
          kstar     LIKE covp-kstar,
          ltext     LIKE cskt-ltext,
          sourc(22),
          sourt(40),
          twaer     LIKE covp-twaer,
          actqty    LIKE covp-mbgbtr,
          plnqty    LIKE covp-megbtr,
          tgtqty    LIKE covp-megbtr,
          meinb     LIKE covp-meinb,
          actval    LIKE covp-wtgbtr,
          plnval    LIKE covp-wtgbtr,
          tgtval    LIKE covp-wtgbtr,
          matnr     LIKE mara-matnr,
          hrkft     LIKE cosp-hrkft,
          uspob     LIKE coss-uspob,
          tbma_val  LIKE rsrd1-tbma_val,
          pvprs     LIKE ckmlcr-pvprs,
          megbtr    LIKE covp-megbtr,
          actamt    LIKE ckmlcr-pvprs,
          bukrs     LIKE caufv-bukrs,
          werks     LIKE caufv-werks,
        END OF ty_detail.

TYPES : BEGIN OF ty_stat,
          objnr LIKE caufv-objnr,
          sttxt LIKE bsvx-sttxt,
        END OF ty_stat.

TYPES : BEGIN OF ty_tj02t,
          istat TYPE tj02t-istat,
          txt04 TYPE tj02t-txt04,
        END OF ty_tj02t.

DATA : ok_code    TYPE sy-ucomm,
       gv_repid   TYPE sy-repid,
       gv_dynnr   TYPE sy-dynnr,
       gs_variant LIKE disvariant,
       selected   VALUE 'X',
       gv_meins   LIKE mara-meins,
       gv_waers   LIKE tka01-waers,
       gv_kaln1   LIKE mbew-kaln1,
       gv_menge   LIKE ckhs-menge.

DATA : g_custom_container TYPE REF TO cl_gui_custom_container,
       g_docking          TYPE REF TO cl_gui_docking_container,
       g_splitter         TYPE REF TO cl_gui_splitter_container,
       g_container        TYPE REF TO cl_gui_container,
       event_receiver     TYPE REF TO lcl_application.

DATA : gt_fieldcat          TYPE lvc_t_fcat.

* Tree
DATA : g_tree             TYPE REF TO cl_gui_alv_tree,
       g_hierarchy_header TYPE treev_hhdr.

TYPES : BEGIN OF ty_tree,
          node_main(15),
          node_n01(15),
          node_n02(15),
          node_n03(15),
        END OF ty_tree.

DATA : gt_tree TYPE ty_tree OCCURS 0,
       wa_tree LIKE LINE OF gt_tree.

* ALV
DATA : g_grid        TYPE REF TO cl_gui_alv_grid,
       gs_layout_alv TYPE lvc_s_layo,
       gs_exclude    TYPE ui_functions,
       gs_stable     TYPE lvc_s_stbl,
       gt_sort_grid  TYPE lvc_t_sort WITH HEADER LINE.

DATA : gt_detail TYPE STANDARD TABLE OF ty_detail,
       gt_alv    TYPE STANDARD TABLE OF ty_detail,
       gt_all    TYPE STANDARD TABLE OF ty_detail,
       gt_stat   TYPE STANDARD TABLE OF ty_stat,
       gt_tj02t  TYPE STANDARD TABLE OF ty_tj02t.

DATA : gt_caufv TYPE STANDARD TABLE OF caufv,
       gt_sfg   TYPE STANDARD TABLE OF caufv,
       gt_afpo  TYPE STANDARD TABLE OF afpo,
       gt_covp  TYPE STANDARD TABLE OF covp,
       gt_coss  TYPE STANDARD TABLE OF coss,
       gt_cosp  TYPE STANDARD TABLE OF cosp,
       gt_csku  TYPE STANDARD TABLE OF csku,
       gt_cokey TYPE STANDARD TABLE OF cokey,
       gt_cskt  TYPE STANDARD TABLE OF cskt,
       gt_mara  TYPE STANDARD TABLE OF mara,
       gt_makt  TYPE STANDARD TABLE OF makt,
       gt_resb  TYPE STANDARD TABLE OF resb,
       gt_s026  TYPE STANDARD TABLE OF s026,
       gt_ckis  TYPE STANDARD TABLE OF ckis,
       gt_ckhs  TYPE STANDARD TABLE OF ckhs.

DATA : gt_mbew   TYPE STANDARD TABLE OF mbew,
       gt_xmara  TYPE STANDARD TABLE OF mara,
       gt_ckmlcr TYPE STANDARD TABLE OF ckmlcr.

DATA : gs_header   TYPE ty_header.

DATA : gt_detlgen  TYPE ty_detail OCCURS 0 WITH HEADER LINE,
       gt_material TYPE STANDARD TABLE OF ty_material,
       gt_xcaufv   TYPE STANDARD TABLE OF caufv.
