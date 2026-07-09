*&---------------------------------------------------------------------*
*&  Include           ZCO_COCOTOP
*&---------------------------------------------------------------------*
CLASS lcl_application DEFINITION DEFERRED.

TABLES : mbew.

TYPE-POOLS : ccs01, ckmv0.

TYPES : BEGIN OF ty_mara,
          matnr   LIKE mara-matnr,
          matkl   LIKE mara-matkl,
          maktx   LIKE makt-maktx,
        END OF ty_mara.

TYPES : BEGIN OF ty_out,
          bwkey       LIKE mbew-bwkey,
          poper       LIKE ckmlprkeph-poper,
          bdatj       LIKE ckmlprkeph-bdatj,
          matnr       LIKE mbew-matnr,
          maktx       LIKE makt-maktx,
          matkl       LIKE mara-matkl,
          wgbez       LIKE t023t-wgbez,
          prctr       LIKE marc-prctr,
          valid_name  TYPE ckml_edit_name,
          waers       LIKE ckmlprkeph-waers,
          rawco       LIKE ckmlprkeph-kst001,
          pacco       LIKE ckmlprkeph-kst003,
          labco       LIKE ckmlprkeph-kst005,
          macco       LIKE ckmlprkeph-kst007,
          mfeco       LIKE ckmlprkeph-kst009,
          fgsco       LIKE ckmlprkeph-kst011,
          total       LIKE ckmlprkeph-kst011,
          menge       LIKE mlcd-lbkum,
          meins       LIKE mlcd-meins,
        END OF ty_out.

DATA : gt_mbew        TYPE STANDARD TABLE OF mbew,
       gt_ckmlprkeph  TYPE STANDARD TABLE OF ckmlprkeph,
       gt_mara        TYPE ty_mara OCCURS 0,
       gt_t023t       TYPE STANDARD TABLE OF t023t,
       gt_marc        TYPE STANDARD TABLE OF marc,
       gt_mlcd        TYPE STANDARD TABLE OF mlcd,
       gt_keko        TYPE STANDARD TABLE OF keko,
       gt_out         TYPE ty_out OCCURS 0,
       gt_ckmlmv005   TYPE STANDARD TABLE OF ckmlmv005,
       gs_ckmlmv005   TYPE ckmlmv005.

DATA : gt_keph_mlcd     TYPE ccs01_t_keph_mlcd,
       gs_keph_mlcd     LIKE LINE OF gt_keph_mlcd,
       gt_text_read     TYPE ckml_t_text_read,
       gs_text_read     LIKE LINE OF gt_text_read.

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
