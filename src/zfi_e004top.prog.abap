*&---------------------------------------------------------------------*
*&  Include           ZFI_E004TOP
*&---------------------------------------------------------------------*
TABLES : bseg, bkpf, zfidt002, sscrfields.

TYPES : BEGIN OF ty_filter,
          index TYPE sy-tabix,
        END OF ty_filter.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          budat      TYPE zfidt003-budat,
          bukrs      TYPE zfidt003-bukrs,
          cabang     TYPE zfidt003-cabang,
          zbank      TYPE zfidt003-zbank,
          jenis      TYPE zfidt003-jenis,
          keterangan TYPE c LENGTH 100,
          dmbtr      TYPE zfidt003-dmbtr,
          waers      TYPE zfidt003-waers,
          style      TYPE lvc_t_styl,
          color      TYPE lvc_t_scol,
        END OF ty_out.

TYPES : BEGIN OF ty_report,
          bukrs  TYPE zfidt003-bukrs,
          budat  TYPE zfidt003-budat,
          zbank  TYPE zfidt003-zbank,
          cabang TYPE zfidt003-cabang,
          hkont  TYPE zfidt002-hkont,
          dmbtr  TYPE zfidt003-dmbtr,
          waers  TYPE zfidt003-waers,
          zbrvn  TYPE zfidt003-zbrvn,
          belnr  TYPE zfidt003-belnr,
          gjahr  TYPE zfidt003-gjahr,
        END OF ty_report.

TYPES : BEGIN OF ty_data,
          c01 TYPE string,
          c02 TYPE string,
          c03 TYPE string,
          c04 TYPE string,
          c05 TYPE string,
          c06 TYPE string,
          c07 TYPE string,
          c08 TYPE string,
          c09 TYPE string,
          c10 TYPE string,
          c11 TYPE string,
          c12 TYPE string,
          c13 TYPE string,
          c14 TYPE string,
          c15 TYPE string,
          c16 TYPE string,
          c17 TYPE string,
          c18 TYPE string,
          c19 TYPE string,
          c20 TYPE string,
        END OF ty_data.

CLASS : lcl_application DEFINITION DEFERRED.

CONSTANTS : c_separator TYPE c LENGTH 1 VALUE ',',
            c_tabulator TYPE c VALUE ' '. "cl_abap_char_utilities=>cr_lf.

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
       gt_filter        TYPE STANDARD TABLE OF ty_filter.

DATA : gt_data   TYPE STANDARD TABLE OF ty_data,
       gt_out    TYPE STANDARD TABLE OF ty_out,
       gt_xout   TYPE STANDARD TABLE OF ty_out,
       gt_002    TYPE STANDARD TABLE OF zfidt002,
       gt_003    TYPE STANDARD TABLE OF zfidt003,
       gt_x003   TYPE STANDARD TABLE OF zfidt003,
       gt_tbsl   TYPE STANDARD TABLE OF tbsl,
       gs_out    LIKE LINE OF gt_out,
       gt_report TYPE STANDARD TABLE OF ty_report.

FIELD-SYMBOLS : <fs_table> TYPE STANDARD TABLE,
                <fs_tab>   TYPE STANDARD TABLE,
                <fs_wa>    TYPE any,
                <fs_out>   TYPE STANDARD TABLE.

DATA : gv_zrow       TYPE zfidt002-zrow,
       gv_zkcol      TYPE zfidt002-zkcol,
       gv_zacol      TYPE zfidt002-zacol,
       gv_subrc      TYPE sy-subrc,
       gv_keterangan TYPE c LENGTH 100,
       gv_dmbtr      TYPE bseg-dmbtr,
       gv_waers      TYPE bkpf-waers,
       gv_cabang     TYPE zfidt002-cabang,
       gv_row        TYPE lvc_s_row,
       gv_delimiter  TYPE c LENGTH 1.

DATA : gs_header  TYPE zfexpstprnt,
       gt_detail  TYPE STANDARD TABLE OF zfexpstprnt,
       gt_window3 TYPE STANDARD TABLE OF zfexpstprnt.

DATA : accountgl      TYPE STANDARD TABLE OF bapiacgl09,
       extension1     TYPE STANDARD TABLE OF bapiextc,
       currencyamount TYPE STANDARD TABLE OF bapiaccr09,
       return         TYPE STANDARD TABLE OF bapiret2,
       documentheader TYPE bapiache09.
