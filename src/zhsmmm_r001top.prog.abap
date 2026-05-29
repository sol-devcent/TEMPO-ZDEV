*&---------------------------------------------------------------------*
*&  Include           ZTDS_RTMPTOP
*&---------------------------------------------------------------------*
TYPE-POOLS : slis.

TABLES : zgdmmt004z, sscrfields.

TYPES : BEGIN OF ty_filter,
          index   TYPE sy-tabix,
        END OF ty_filter.

TYPES : BEGIN OF ty_temp,
          document    TYPE string,
        END OF ty_temp.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4).
        INCLUDE STRUCTURE zgdmmt004z.
TYPES :   banfn   TYPE eban-banfn,
          maktx   TYPE makt-maktx,
          name1   TYPE lfa1-name1,
          relst   TYPE dd07t-ddtext,
          atach(4),
          fpkh(4),
          lamp(4),
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
       gt_filter         TYPE STANDARD TABLE OF ty_filter,
       g_html_container  TYPE REF TO cl_gui_custom_container,
       g_html_control    TYPE REF TO cl_gui_html_viewer.

DATA : gt_out            TYPE STANDARD TABLE OF ty_out,
       gt_xout           TYPE STANDARD TABLE OF ty_out,
       gt_004z           TYPE STANDARD TABLE OF zgdmmt004z,
       gt_004y           TYPE STANDARD TABLE OF zgdmmt004y,
       gt_004p           TYPE STANDARD TABLE OF zgdmmt004p,
       gt_temp           TYPE STANDARD TABLE OF ty_temp,
       gt_makt           TYPE STANDARD TABLE OF makt,
       gt_lfa1           TYPE STANDARD TABLE OF lfa1,
       dd07v_tab         TYPE STANDARD TABLE OF dd07v,
       gt_005            TYPE STANDARD TABLE OF zhsmmmdt005,
       gt_008            TYPE STANDARD TABLE OF zhsmmmdt008,
       gt_objbin         TYPE TABLE OF solix.

FIELD-SYMBOLS : <fs_out>    TYPE STANDARD TABLE,
                <fs_lout>   TYPE ANY.
