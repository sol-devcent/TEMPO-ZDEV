*&---------------------------------------------------------------------*
*&  Include           ZPP_R002TOP
*&---------------------------------------------------------------------*
TABLES : zppresb_add, sscrfields.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4).
          INCLUDE STRUCTURE zppresb_add.
          TYPES :   baugr   TYPE resb-baugr,
          makt1   TYPE makt-maktx,
          char1   TYPE resb-charg,
          makt2   TYPE makt-maktx,
          char2   TYPE resb-charg,
*          vornr   TYPE resb-vornr,
          erfmg   TYPE resb-erfmg,
          erfme   TYPE resb-erfme,
          ket     TYPE char30,
          atwtb   TYPE atwtb,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code          TYPE sy-ucomm,
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
       gt_bapiret2      TYPE STANDARD TABLE OF bapiret2.

DATA : gt_out          TYPE STANDARD TABLE OF ty_out,
       gt_add          TYPE STANDARD TABLE OF zppresb_add,
       gt_ztspppdt011  TYPE STANDARD TABLE OF ztspppdt011,
       gt_ztspppdt007  TYPE STANDARD TABLE OF ztspppdt007,
       gt_ztspppdt007d TYPE STANDARD TABLE OF ztspppdt007d,
       gt_makt         TYPE STANDARD TABLE OF makt,
       gt_makt2        TYPE STANDARD TABLE OF makt,
       gt_makt3        TYPE STANDARD TABLE OF makt,
       gt_resb         TYPE STANDARD TABLE OF resb,
       gt_resb2        TYPE STANDARD TABLE OF resb,
       gt_resb3        TYPE STANDARD TABLE OF resb,
       gt_afvc         TYPE STANDARD TABLE OF afvc,
       gt_afpo         TYPE STANDARD TABLE OF afpo,
       gt_afpo2        TYPE STANDARD TABLE OF afpo,
       gt_afpo3        TYPE STANDARD TABLE OF afpo,
       gt_mkpf3        TYPE STANDARD TABLE OF mkpf.
