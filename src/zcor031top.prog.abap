*&---------------------------------------------------------------------*
*&  Include           ZCOR031TOP
*&---------------------------------------------------------------------*
TABLES : ckmlcr, sscrfields.

TYPE-POOLS : ckmv0, ccs01.

TYPES : BEGIN OF ty_row,
          buzei   TYPE co_buzei,
          bkbez   TYPE t025t-bkbez,
          low     TYPE t025t-bklas,
          high    TYPE t025t-bklas,
          sign(1),
          option(2),
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_row.

TYPES : BEGIN OF ty_x,
          perio	  TYPE jahrper,
          ktx     TYPE t247-ktx,
          bdatj   TYPE ckmlcr-bdatj,
          salkv   TYPE ckmlcr-salkv,
        END OF ty_x.

TYPES : BEGIN OF ty_wip,
          perio	  TYPE jahrper,
          tslvt_h TYPE glt0-tslvt,
          tslvt_s TYPE glt0-tslvt,
        END OF ty_wip.

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
       g_grid1           TYPE REF TO cl_gui_alv_grid,
       g_grid2           TYPE REF TO cl_gui_alv_grid,
       g_grid3           TYPE REF TO cl_gui_alv_grid,
       g_grid4           TYPE REF TO cl_gui_alv_grid,
       event_receiver    TYPE REF TO lcl_application,
       selected          VALUE 'X',
       gv_repid          LIKE sy-repid,
       gs_variant        LIKE disvariant,
       gs_layout_alv     TYPE lvc_s_layo,
       gt_sort1          TYPE lvc_t_sort WITH HEADER LINE,
       gt_sort2          TYPE lvc_t_sort WITH HEADER LINE,
       gt_sort3          TYPE lvc_t_sort WITH HEADER LINE,
       gt_sort4          TYPE lvc_t_sort WITH HEADER LINE,
       gt_fieldcat1      TYPE lvc_t_fcat,
       gt_fieldcat2      TYPE lvc_t_fcat,
       gt_fieldcat2x     TYPE lvc_t_fcat,
       gt_fieldcat3      TYPE lvc_t_fcat,
       gt_fieldcat4      TYPE lvc_t_fcat,
       gs_stable         TYPE lvc_s_stbl,
       gs_toolbar        TYPE stb_button,
       gr_hierseq        TYPE REF TO cl_salv_hierseq_table,
       gr_table          TYPE REF TO cl_salv_table,
       g_handle_alv      TYPE i,
       gt_bapiret2       TYPE STANDARD TABLE OF bapiret2.

DATA : gt_row1           TYPE STANDARD TABLE OF ty_row,
       gt_row2           TYPE STANDARD TABLE OF ty_row,
       gt_row3           TYPE STANDARD TABLE OF ty_row,
       gt_row4           TYPE STANDARD TABLE OF ty_row,
       gt_marc           TYPE STANDARD TABLE OF marc,
       gt_mbew           TYPE STANDARD TABLE OF mbew,
       gt_ckmlcr         TYPE STANDARD TABLE OF ckmlcr,
       gt_glt0           TYPE STANDARD TABLE OF glt0,
       gt_ckmlprkeph     TYPE STANDARD TABLE OF ckmlprkeph,
       gt_mlcd           TYPE STANDARD TABLE OF mlcd,
       gt_keko           TYPE STANDARD TABLE OF keko,
       gt_ckmlmv005      TYPE STANDARD TABLE OF ckmlmv005,
       gt_wip            TYPE STANDARD TABLE OF ty_wip,
       gt_x1             TYPE STANDARD TABLE OF ty_x,
       gt_x2             TYPE STANDARD TABLE OF ty_x.

DATA : gr_bklas          TYPE RANGE OF bklas.

FIELD-SYMBOLS : <fs_1>      TYPE STANDARD TABLE,
                <fs_l1>     TYPE ANY,
                <fs_2>      TYPE STANDARD TABLE,
                <fs_l2>     TYPE ANY,
                <fs_2x>     TYPE STANDARD TABLE,
                <fs_l2x>    TYPE ANY,
                <fs_3>      TYPE STANDARD TABLE,
                <fs_l3>     TYPE ANY,
                <fs_4>      TYPE STANDARD TABLE,
                <fs_l4>     TYPE ANY,
                <fs_style>  TYPE ANY.
