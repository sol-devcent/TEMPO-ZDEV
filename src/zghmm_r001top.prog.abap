*&---------------------------------------------------------------------*
*&  Include           ZTDS_RTMPTOP
*&---------------------------------------------------------------------*
TABLES : rbkp,rseg,sscrfields.

TYPES : BEGIN OF ty_filter,
          index   TYPE sy-tabix,
        END OF ty_filter.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
          bldat   TYPE rbkp-bldat,
          budat   TYPE rbkp-budat,
          belnr   TYPE rbkp-belnr,
          xblnr   TYPE rbkp-xblnr,
          zuonr   TYPE rbkp-zuonr,
          bktxt   TYPE rbkp-bktxt,
          waers   TYPE rbkp-waers,
          dpp     TYPE rbkp-rmwwr,
          ppn     TYPE rbkp-rmwwr,
          dppppn  TYPE rbkp-rmwwr,
          nonr    TYPE zfvatin_nr-nonr,
          vatdt1  TYPE zfvatin_nr-vatdt1,
          dpppake TYPE rbkp-rmwwr,
          ppnpake TYPE rbkp-rmwwr,
          dppppnpake TYPE rbkp-rmwwr,
          dppsisa TYPE rbkp-rmwwr,
          ppnsisa TYPE rbkp-rmwwr,
          dppppnsisa TYPE rbkp-rmwwr,
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
       gt_rbkp           TYPE STANDARD TABLE OF rbkp,
       gt_rbkp2          TYPE STANDARD TABLE OF rbkp,
       gt_zfvatin_nr     TYPE STANDARD TABLE OF zfvatin_nr.

FIELD-SYMBOLS: <fs_out>  TYPE ty_out.
