*&---------------------------------------------------------------------*
*&  Include           ZCO_E003TOP
*&---------------------------------------------------------------------*
TABLES : mbew, sscrfields.

TYPES : BEGIN OF ty_filter,
          index   TYPE sy-tabix,
        END OF ty_filter.

TYPES : BEGIN OF ty_bom,
          xmatn   TYPE mara-matnr.
        INCLUDE STRUCTURE cscmat.
TYPES :   kaln1   TYPE mbew-kaln1,
          dmbtr   TYPE bseg-dmbtr,
          menge   TYPE mseg-menge,
        END OF ty_bom.

TYPES : BEGIN OF ty_date,
          budat   TYPE mkpf-budat,
        END OF ty_date.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          bwkey   TYPE mbew-bwkey,
          poper   TYPE ckmlkeph-poper,
          bdatj   TYPE ckmlkeph-bdatj,
          xmatn   TYPE mbew-matnr,
          xmakt   TYPE makt-maktx,
          mtart   TYPE mara-mtart,
          waers   TYPE ckmlkeph-waers,
          dmbtr   TYPE bseg-dmbtr,
          kstel   TYPE ckmlkeph-kst001,
          matnr   TYPE mbew-matnr,
          maktx   TYPE makt-maktx,
          aufnr   TYPE mseg-aufnr,
          shkzg   TYPE mseg-shkzg,
          menge   TYPE mseg-menge,
          meins   TYPE mseg-meins,
          alloc   TYPE ckmlkeph-kst001,
          belnr   TYPE bkpf-belnr,
          gjahr   TYPE bkpf-gjahr,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code           TYPE sy-ucomm,
       dynlog            TYPE smp_dyntxt,
       dynpost           TYPE smp_dyntxt,
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
       gt_mbew           TYPE STANDARD TABLE OF mbew,
       gt_ckmlkeph       TYPE STANDARD TABLE OF ckmlkeph,
       gt_mara           TYPE STANDARD TABLE OF mara,
       gt_makt           TYPE STANDARD TABLE OF makt,
       gt_bom            TYPE STANDARD TABLE OF ty_bom,
       gt_date           TYPE STANDARD TABLE OF ty_date,
       gt_mkpf           TYPE STANDARD TABLE OF mkpf,
*       gt_mseg           TYPE STANDARD TABLE OF mseg,
       gt_aufm           TYPE STANDARD TABLE OF aufm,
       gt_mlcd           TYPE STANDARD TABLE OF mlcd,
       gt_bkpf           TYPE STANDARD TABLE OF bkpf,
       gt_bseg           TYPE STANDARD TABLE OF bseg.

DATA : gv_datum          TYPE sy-datum,
       gv_bukrs          TYPE mseg-bukrs,
       gv_blart          TYPE mkpf-blart,
       gv_categ          TYPE ckmlkeph-categ,
       gv_mlcct          TYPE ckmlkeph-mlcct,
       gv_bklas          TYPE mbew-bklas,
       gv_post.

DATA : gr_bwart          TYPE RANGE OF bwart,
       gr_mtart          TYPE RANGE OF mtart,
       gr_budat          TYPE RANGE OF budat,
       gr_hkont          TYPE RANGE OF hkont.

DATA : documentheader    TYPE bapiache09,
       obj_type          TYPE bapiache09-obj_type,
       accountgl         TYPE STANDARD TABLE OF bapiacgl09,
       currencyamount    TYPE STANDARD TABLE OF bapiaccr09,
       return            TYPE STANDARD TABLE OF bapiret2,
       extension1        TYPE STANDARD TABLE OF bapiacextc.

FIELD-SYMBOLS: <fs_out> TYPE ty_out.
