*&---------------------------------------------------------------------*
*&  Include           ZCO_E003TOP
*&---------------------------------------------------------------------*
TABLES : zclnumber,anla,sscrfields.

TYPES : BEGIN OF ty_filter,
          index TYPE sy-tabix,
        END OF ty_filter.

TYPES : BEGIN OF ty_bom,
          xmatn TYPE mara-matnr.
          INCLUDE STRUCTURE cscmat.
          TYPES :   kaln1 TYPE mbew-kaln1,
          dmbtr TYPE bseg-dmbtr,
          menge TYPE mseg-menge,
        END OF ty_bom.

TYPES : BEGIN OF ty_date,
          budat TYPE mkpf-budat,
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

TYPES: BEGIN OF ty_upload.
         INCLUDE STRUCTURE zstclnumber.
       TYPES:
*                wgbez60 TYPE wgbez60,
                msg     TYPE message-msgtx,
                mark,
                icon    TYPE icon_d,
                style   TYPE lvc_t_styl,
                color   TYPE lvc_t_scol,
              END OF ty_upload.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code          TYPE sy-ucomm,
       dynlog           TYPE smp_dyntxt,
       dynpost          TYPE smp_dyntxt,
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

DATA : documentheader    TYPE bapiache09,
       obj_type          TYPE bapiache09-obj_type,
       accountreceivable TYPE STANDARD TABLE OF bapiacar09,
       accountgl         TYPE STANDARD TABLE OF bapiacgl09,
       currencyamount    TYPE STANDARD TABLE OF bapiaccr09,
       return            TYPE STANDARD TABLE OF bapiret2,
       criteria          TYPE STANDARD TABLE OF bapiackec9,
       extension1        TYPE STANDARD TABLE OF bapiacextc,
       extension2        TYPE STANDARD TABLE OF bapiparex.

DATA: gt_excel     TYPE STANDARD TABLE OF zstclnumber,
      gt_upload    TYPE STANDARD TABLE OF ty_upload,
      gt_zclnumber TYPE STANDARD TABLE OF zclnumber.

DATA: gv_post.

DATA: h_excel TYPE ole2_object,        " Excel object
      h_mapl  TYPE ole2_object,        " list of workbooks
      h_map   TYPE ole2_object,        " workbook
      h_zl    TYPE ole2_object,        " cell
      h_f     TYPE ole2_object.        " font
