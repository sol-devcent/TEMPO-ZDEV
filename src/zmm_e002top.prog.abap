*&---------------------------------------------------------------------*
*&  Include           ZMM_E002TOP
*&---------------------------------------------------------------------*
TABLES : vttk, zwmdt004, sscrfields.

TYPES : BEGIN OF ty_filter,
          index   TYPE sy-tabix,
        END OF ty_filter.

TYPES : BEGIN OF ty_rdoc,
          xblnr   TYPE bkpf-xblnr,
        END OF ty_rdoc.

TYPES : BEGIN OF ty_bdoc,
          bukrs   TYPE bkpf-bukrs,
          bstat   TYPE bkpf-bstat,
          xblnr   TYPE bkpf-xblnr,
        END OF ty_bdoc.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          bukrs   TYPE bkpf-bukrs,
          xblnr   TYPE bkpf-xblnr,
          belnr   TYPE bkpf-belnr,
          gjahr   TYPE bkpf-gjahr,
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
       gt_bapiret2       TYPE STANDARD TABLE OF bapiret2,
       gt_filter         TYPE STANDARD TABLE OF ty_filter.

DATA : gt_out            TYPE STANDARD TABLE OF ty_out,
       gt_xout           TYPE STANDARD TABLE OF ty_out,
       gt_rdoc           TYPE STANDARD TABLE OF ty_rdoc,
       gt_bdoc           TYPE STANDARD TABLE OF ty_bdoc,
       gt_rbkp           TYPE STANDARD TABLE OF rbkp,
       gt_bkpf           TYPE STANDARD TABLE OF bkpf.

DATA : gs_rdoc           LIKE LINE OF gt_rdoc,
       gs_bdoc           LIKE LINE OF gt_bdoc.

FIELD-SYMBOLS : <fs_thead>   TYPE STANDARD TABLE,
                <fs_titem>   TYPE STANDARD TABLE,
                <fs_tglac>   TYPE STANDARD TABLE,
                <fs_tmatn>   TYPE STANDARD TABLE.

FIELD-SYMBOLS : <fs_shead>   TYPE ANY,
                <fs_sitem>   TYPE ANY,
                <fs_sglac>   TYPE ANY,
                <fs_smatn>   TYPE ANY.

DATA : gt_thead_fieldcat  TYPE lvc_t_fcat,
       gt_titem_fieldcat  TYPE lvc_t_fcat,
       gt_tglac_fieldcat  TYPE lvc_t_fcat,
       gt_tmatn_fieldcat  TYPE lvc_t_fcat.

DATA : gt_sthead          TYPE STANDARD TABLE OF dfies,
       gt_stitem          TYPE STANDARD TABLE OF dfies,
       gt_stglac          TYPE STANDARD TABLE OF dfies,
       gt_stmatn          TYPE STANDARD TABLE OF dfies.

DATA : headerdata         TYPE bapi_incinv_create_header,
       itemdata           TYPE STANDARD TABLE OF bapi_incinv_create_item,
       glaccountdata      TYPE STANDARD TABLE OF bapi_incinv_create_gl_account,
       materialdata       TYPE STANDARD TABLE OF bapi_incinv_create_material.
