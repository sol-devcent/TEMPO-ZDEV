*&---------------------------------------------------------------------*
*&  Include           ZACCPP_R001TOP
*&---------------------------------------------------------------------*
TABLES : sscrfields, afpo.

CLASS : lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF ty_out.
        INCLUDE STRUCTURE zv_accdtm.
TYPES :   vbeln     TYPE zaccdtm-vbeln,
          maktx     TYPE makt-maktx,
          aggr1     TYPE zaccdta-aggr1,
          packdat1  TYPE zaccdta-packdat1,
          zact1     TYPE zaccdta-zact1,
          aggr2     TYPE zaccdta-aggr2,
          packdat2  TYPE zaccdta-packdat2,
          zact2     TYPE zaccdta-zact2,
          kbetr     TYPE konp-kbetr,
          count     TYPE p DECIMALS 0,
        END OF ty_out.

DATA : gv_repid             LIKE sy-repid,
       ok_code              TYPE sy-ucomm,
       gs_exclude_t         TYPE ui_functions,
       gs_exclude_b         TYPE ui_functions,
       g_content            TYPE REF TO cl_salv_form_element,
       g_maincont           TYPE REF TO cl_gui_custom_container,
       g_splitter           TYPE REF TO cl_gui_splitter_container,
       g_top                TYPE REF TO cl_gui_container,
       g_bottom             TYPE REF TO cl_gui_container,
       g_tgrid              TYPE REF TO cl_gui_alv_grid,
       g_bgrid              TYPE REF TO cl_gui_alv_grid,
       event_receiver       TYPE REF TO lcl_application,
       selected             VALUE 'X',
       gs_stable            TYPE lvc_s_stbl,
       gt_fieldcat_t        TYPE lvc_t_fcat,
       gt_fieldcat_b        TYPE lvc_t_fcat,
       gs_layout_alv        TYPE lvc_s_layo,
       g_handle_alv         TYPE i,
       gt_main_sort         TYPE lvc_t_sort WITH HEADER LINE,
       gs_variant           LIKE disvariant,
       gs_toolbar           TYPE stb_button.

FIELD-SYMBOLS : <fs_top>        TYPE STANDARD TABLE,
                <fs_bottom>     TYPE STANDARD TABLE,
                <fs_ltop>       TYPE ANY,
                <fs_lbottom>    TYPE ANY.

DATA : gt_out     TYPE STANDARD TABLE OF ty_out,
       gt_t001k   TYPE STANDARD TABLE OF t001k,
       gt_a989    TYPE STANDARD TABLE OF a989,
       gt_konp    TYPE STANDARD TABLE OF konp,
       gt_makt    TYPE STANDARD TABLE OF makt,
       gt_zaccdta TYPE STANDARD TABLE OF zaccdta.
