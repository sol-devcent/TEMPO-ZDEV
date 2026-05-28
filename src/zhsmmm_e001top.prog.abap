*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E001TOP
*&---------------------------------------------------------------------*
TABLES : pgmi, sscrfields.

CONTROLS : tc_rfq        TYPE TABLEVIEW USING SCREEN 102.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          ekgrp   TYPE eban-ekgrp,
          ekorg   TYPE eban-ekorg,
          werks   TYPE marc-werks,
          banfn   TYPE eban-banfn,
          bnfpo   TYPE eban-bnfpo,
          matnr   TYPE mara-matnr,
          maktx   TYPE makt-maktx,
          menge   TYPE eban-menge,
          meins   TYPE eban-meins,
          lfdat   TYPE eban-lfdat,
          statu   TYPE dd07v-ddtext,
          fkztx   TYPE t161u-fkztx,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

TYPES : BEGIN OF ty_rfq,
          check,
          icon(4),
          werks   TYPE lfa1-werks,
          anfnr   TYPE ekpo-anfnr,
          lifnr   TYPE lfa1-lifnr,
          name1   TYPE adrc-name1,
          matnr   TYPE mara-matnr,
          maktx   TYPE makt-maktx,
          bstyp   TYPE t161-bstyp,
          asart   TYPE rm06e-asart,
          bukrs   TYPE ekko-bukrs,
          anfdt   TYPE rm06e-anfdt,
          ekorg   TYPE ekko-ekorg,
          angdt   TYPE ekko-angdt,
          ekgrp   TYPE ekko-ekgrp,
          submi   TYPE ekko-submi,
          newmi   TYPE ekko-submi,
          kdatb   TYPE ekko-kdatb,
          kdate   TYPE ekko-kdate,
          bwbdt   TYPE ekko-bwbdt,
          frei    TYPE qinf-frei_dat,
          bmatn   TYPE mara-bmatn,
          bnddt   TYPE ekko-bnddt,
          waers   TYPE ekko-waers,
          status(4),
          count   TYPE i,
          style,
          mark,
        END OF ty_rfq.

TYPES : BEGIN OF ty_head,
          text01(30),
          matnr   TYPE mara-matnr,
        END OF ty_head.

TYPES : BEGIN OF ty_mara,
          matnr   TYPE mara-matnr,
          werks   TYPE marc-werks,
          mtart   TYPE mara-mtart,
          meins   TYPE mara-meins,
          mprof   TYPE mara-mprof,
          qmpur   TYPE mara-qmpur,
        END OF ty_mara.

TYPES : BEGIN OF ty_makt,
          matnr   TYPE makt-matnr,
          maktx   TYPE makt-maktx,
        END OF ty_makt.

TYPES : BEGIN OF ty_pir,
          infnr TYPE infnr,
          matnr TYPE matnr,
          matkl TYPE matkl,
          lifnr TYPE elifn,
          ekorg TYPE ekorg,
          esokz TYPE esokz,
          werks TYPE ewerk,
          inco1 TYPE inco1,
          waers TYPE waers,
      END OF ty_pir.

TYPES : BEGIN OF ty_return,
          lifnr   TYPE lfa1-lifnr,
          matnr   TYPE mara-matnr.
        INCLUDE STRUCTURE bapiret2.
TYPES : END OF ty_return.

TYPES : BEGIN OF ty_prcheck,
          lifnr   TYPE ekko-lifnr,
          banfn   TYPE eban-banfn,
          bnfpo   TYPE eban-bnfpo,
          submi   TYPE ekko-submi,
        END OF ty_prcheck.

TYPES : BEGIN OF ty_mail,
          submi     TYPE ekko-submi,
          maktx     TYPE makt-maktx,
          anfnr     TYPE ekpo-anfnr,
        END OF ty_mail.

TYPES : BEGIN OF ty_filter,
          index   TYPE sy-tabix,
        END OF ty_filter.

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
       gt_bapiret2       TYPE STANDARD TABLE OF bapiret2,
       gt_filter         TYPE STANDARD TABLE OF ty_filter.

DATA : gt_xekko          TYPE STANDARD TABLE OF ekko,
       gt_xekpo          TYPE STANDARD TABLE OF ekpo,
       gt_out            TYPE STANDARD TABLE OF ty_out,
       gt_xout           TYPE STANDARD TABLE OF ty_out,
       gs_head           TYPE ty_head,
       gt_pmara          TYPE STANDARD TABLE OF ty_makt,
       gt_nmara          TYPE STANDARD TABLE OF ty_makt,
       gt_pgmi           TYPE STANDARD TABLE OF pgmi,
       gt_mara           TYPE STANDARD TABLE OF ty_mara,
       gt_makt           TYPE STANDARD TABLE OF makt,
       gt_eban           TYPE STANDARD TABLE OF eban,
       gt_matnr          TYPE STANDARD TABLE OF range_matnr,
       gt_pir            TYPE STANDARD TABLE OF ty_pir,
       gt_lfa1           TYPE STANDARD TABLE OF lfa1,
       gs_rfqh           TYPE ty_rfq,
       gt_rfqd           TYPE STANDARD TABLE OF ty_rfq,
       gt_xrfqd          TYPE STANDARD TABLE OF ty_rfq,
       gs_rfqd           LIKE LINE OF gt_rfqd,
       gt_return         TYPE STANDARD TABLE OF ty_return,
       gt_t161           TYPE STANDARD TABLE OF t161,
       gt_t161t          TYPE STANDARD TABLE OF t161t,
       gt_t161u          TYPE STANDARD TABLE OF t161u,
       gs_t026z          TYPE t026z,
       gt_prcheck        TYPE STANDARD TABLE OF ty_prcheck,
       gt_list           TYPE STANDARD TABLE OF zhsmmmst001,
       gt_material       TYPE STANDARD TABLE OF ty_head,
       gt_005            TYPE STANDARD TABLE OF zhsmmmdt005.

DATA : gt_tfcat          TYPE lvc_t_fcat,
       gt_ffcat          TYPE lvc_t_fcat,
       gt_thtml          TYPE STANDARD TABLE OF w3html,
       gt_fhtml          TYPE STANDARD TABLE OF w3html.

DATA : gt_mail           TYPE STANDARD TABLE OF ty_mail.

DATA : gr_mtart          TYPE RANGE OF mtart,
       gr_frgkz          TYPE RANGE OF frgkz,
       gr_badat          TYPE RANGE OF badat,
       gr_statu          TYPE RANGE OF banst.

DATA : gv_mtart          TYPE mara-mtart,
       gv_lpein          TYPE tprg-prgbz,
       lines             TYPE i,
       fill              TYPE i,
       line1             TYPE i,
       gv_object         TYPE nriv-object,
       gv_sub            TYPE nriv-subobject,
       gv_range          TYPE nriv-nrrangenr,
       gv_gjahr          TYPE nriv-toyear,
       gv_werks          TYPE pgmi-werks,
       gv_ekorg          TYPE t026z-ekorg,
       gv_domname        TYPE dd07l-domname,
       gv_subrc          TYPE sy-subrc,
       gv_trtyp          TYPE t160-trtyp,
       gv_material.

DATA : value_tab         TYPE STANDARD TABLE OF dd07v.

FIELD-SYMBOLS : <fs_tab>  TYPE STANDARD TABLE.
