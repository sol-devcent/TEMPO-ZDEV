*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E011TOP
*&---------------------------------------------------------------------*
TABLES : caufv, sscrfields.

TYPES : BEGIN OF ty_caufv,
          aufnr   TYPE caufv-aufnr,
          gstrp   TYPE caufv-gstrp,
          werks   TYPE caufv-werks,
          plnbez  TYPE caufv-plnbez,
          ktext   TYPE caufv-ktext,
        END OF ty_caufv.

TYPES : BEGIN OF ty_resb,
          aufnr   TYPE resb-aufnr,
          objnr   TYPE resb-objnr,
        END OF ty_resb.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          aufnr   TYPE resb-aufnr,
          gstrp   TYPE caufv-gstrp,
          werks   TYPE caufv-werks,
          objnr   TYPE resb-objnr,
          plnbez  TYPE caufv-plnbez,
          ktext   TYPE caufv-ktext,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

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

DATA : gt_out            TYPE STANDARD TABLE OF ty_out,
       gt_caufv          TYPE STANDARD TABLE OF ty_caufv,
       gt_resb           TYPE STANDARD TABLE OF ty_resb,
       gt_jest           TYPE STANDARD TABLE OF jest,
       gt_jsto           TYPE STANDARD TABLE OF jsto.
