*&---------------------------------------------------------------------*
*&  Include           ZFI_DEPR_KOSTLTOP
*&---------------------------------------------------------------------*
TABLES : anlp, t095b, sscrfields.

TYPES : BEGIN OF ty_tree,
          node_main(50),
        END OF ty_tree.

TYPES : BEGIN OF ty_key,
          setclass    TYPE setheadert-setclass,
          subclass    TYPE setheadert-subclass,
          setname     TYPE setheadert-setname,
          kostl       TYPE csks-kostl,
        END OF ty_key.

TYPES : BEGIN OF ty_aufk.
        INCLUDE STRUCTURE aufk.
TYPES :   mark,
        END OF ty_aufk.

TYPES : BEGIN OF ty_out.
        INCLUDE STRUCTURE zfistdepr.
TYPES :   mark,
          icon(4),
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

TYPES : BEGIN OF ty_t095b,
          ktogr   TYPE t095b-ktogr,
          ktnafg  TYPE t095b-ktnafg,
          ltext   TYPE csku-ltext,
        END OF ty_t095b.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code           TYPE sy-ucomm,
       gs_exclude        TYPE ui_functions,
       g_customcont      TYPE REF TO cl_gui_custom_container,
       g_splitter        TYPE REF TO cl_gui_splitter_container,
       g_splitter1       TYPE REF TO cl_gui_splitter_container,
       g_contain01       TYPE REF TO cl_gui_container,
       g_contain02       TYPE REF TO cl_gui_container,
       g_contain03       TYPE REF TO cl_gui_container,
       g_contain04       TYPE REF TO cl_gui_container,
       g_tabgrid         TYPE REF TO cl_gui_alv_grid,
       g_tree            TYPE REF TO cl_gui_alv_tree,
       g_header          TYPE treev_hhdr,
       g_docking         TYPE REF TO cl_gui_docking_container,
       event_receiver    TYPE REF TO lcl_application,
       selected          VALUE 'X',
       gv_repid          LIKE sy-repid,
       gv_dynnr          TYPE sy-dynnr,

       gs_variant        LIKE disvariant,
       gs_layout_alv     TYPE lvc_s_layo,
       gt_main_sort      TYPE lvc_t_sort WITH HEADER LINE,
       gt_main_fieldcat  TYPE lvc_t_fcat,
       gt_fieldcat       TYPE lvc_t_fcat,
       gs_stable         TYPE lvc_s_stbl,
       gs_toolbar        TYPE stb_button,
       gr_hierseq        TYPE REF TO cl_salv_hierseq_table,
       gr_table          TYPE REF TO cl_salv_table,
       g_handle_alv      TYPE i,
       gt_bapiret2       TYPE STANDARD TABLE OF bapiret2,
       gt_cellcolor      TYPE lvc_t_scol.

DATA : gt_data           TYPE STANDARD TABLE OF ty_out,
       gt_out            TYPE STANDARD TABLE OF ty_out,
       gt_tree           TYPE STANDARD TABLE OF ty_tree,
       gt_anlp           TYPE STANDARD TABLE OF anlp,
       gt_cskt           TYPE STANDARD TABLE OF cskt,
       gt_aufk           TYPE STANDARD TABLE OF ty_aufk,
       gt_anla           TYPE STANDARD TABLE OF anla,
       gt_anlb           TYPE STANDARD TABLE OF anlb,
       gt_anlc           TYPE STANDARD TABLE OF anlc,
       gt_t095b          TYPE STANDARD TABLE OF ty_t095b.

DATA : gs_t093b          TYPE t093b,
       gr_gjahr          TYPE RANGE OF gjahr,
       gr_peraf          TYPE RANGE OF peraf,
       gt_t247           TYPE STANDARD TABLE OF t247.

DATA : gv_gjahr          TYPE anlp-gjahr,
       gv_spmon          TYPE spmon.

DATA : gt_setnode        TYPE STANDARD TABLE OF setnode,
       gt_setleaf        TYPE STANDARD TABLE OF setleaf,
       gt_nodekstar      TYPE STANDARD TABLE OF setnode,
       gt_leafkstar      TYPE STANDARD TABLE OF setleaf,
       gt_nodekostl      TYPE STANDARD TABLE OF setnode,
       gt_leafkostl      TYPE STANDARD TABLE OF setleaf,
       gt_text           TYPE STANDARD TABLE OF setheadert,
       gt_text1          TYPE STANDARD TABLE OF setheadert,
       gt_key            TYPE STANDARD TABLE OF ty_key.

DATA: t_alv_fieldcat      TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      t_alv_event         TYPE slis_t_event WITH HEADER LINE,
      t_events            TYPE slis_t_event,
      t_alv_isort         TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      t_alv_filter        TYPE slis_t_filter_alv WITH HEADER LINE,
      t_event_exit        TYPE slis_t_event_exit WITH HEADER LINE,
      d_alv_isort         TYPE slis_sortinfo_alv,
      d_alv_variant       TYPE disvariant,
      d_alv_list_scroll   TYPE  slis_list_scroll,
      d_alv_sort_postn    TYPE i,
      d_alv_keyinfo       TYPE slis_keyinfo_alv,
      d_alv_fieldcat      TYPE slis_fieldcat_alv,
      d_alv_formname      TYPE slis_formname,
      d_alv_ucomm         TYPE slis_formname,
      d_alv_print         TYPE slis_print_alv,
      d_alv_repid         LIKE sy-repid,
      d_alv_tabix         LIKE sy-tabix,
      d_alv_subrc         LIKE sy-subrc,
      d_alv_screen_start_column TYPE i,
      d_alv_screen_start_line TYPE i,
      d_alv_screen_end_column TYPE i,
      d_alv_screen_end_line TYPE i,
      d_alv_layout TYPE slis_layout_alv.

DATA: d_layout           TYPE slis_layout_alv,
      d_repid            LIKE sy-repid,
      d_print            TYPE slis_print_alv.
