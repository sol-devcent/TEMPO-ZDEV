*&---------------------------------------------------------------------*
*&  Include           ZTIMDESFI_E001TOP
*&---------------------------------------------------------------------*
TABLES : bkpf, vbak, likp, sscrfields.

CONTROLS : tc_cust TYPE TABLEVIEW USING SCREEN 102,
           tc_main TYPE TABLEVIEW USING SCREEN 102.

TYPES : BEGIN OF ty_filter,
          index TYPE sy-tabix,
        END OF ty_filter.

TYPES : BEGIN OF ty_skat,
          saknr TYPE skat-saknr,
          txt50 TYPE skat-txt50,
        END OF ty_skat.

TYPES : BEGIN OF ty_cust,
          mark,
          kunnr TYPE vbak-kunnr,
          name1 TYPE kna1-name1,
          umbtr TYPE bseg-dmbtr,
          kzwi5 TYPE vbap-kzwi5,
          dmbtr TYPE bseg-dmbtr,
          waerk TYPE vbap-waerk,
        END OF ty_cust.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          bukrs   TYPE bkpf-bukrs,
          vkbur   TYPE vbak-vkbur,
          kunnr   TYPE vbak-kunnr,
          vbeva   TYPE vbak-vbeln,
          vbevl   TYPE likp-vbeln,
          pmbtr   TYPE bseg-dmbtr,
          kzwi5   TYPE vbap-kzwi5,
          dmbtr   TYPE bseg-dmbtr,
          waerk   TYPE vbap-waerk,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

TYPES : BEGIN OF ty_error,
          vbeln   TYPE vbak-vbeln,
          message TYPE bapi_msg,
        END OF ty_error.

TYPES : BEGIN OF ty_header,
          expand.
          INCLUDE STRUCTURE zfidt010.
          TYPES : name1  TYPE kna1-name1,
          outst  TYPE bseg-dmbtr,
        END OF ty_header.

TYPES : BEGIN OF ty_detail,
          expand,
          icon(4).
          INCLUDE STRUCTURE zfidt010.
          TYPES : stats(10),
          revnm     TYPE sy-uname,
        END OF ty_detail.

TYPES : BEGIN OF ty_soff,
          auart TYPE vbak-auart,
          vkorg TYPE vbak-vkorg,
          vkbur TYPE tvbur-vkbur,
        END OF ty_soff.

CLASS : lcl_application DEFINITION DEFERRED.

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

DATA : gt_out    TYPE STANDARD TABLE OF ty_out,
       gt_xout   TYPE STANDARD TABLE OF ty_out,
       gs_out    LIKE LINE OF gt_out,
       gt_cust   TYPE STANDARD TABLE OF ty_cust,
       gs_cust   LIKE LINE OF gt_cust,
       gt_003    TYPE STANDARD TABLE OF zcdssd_003,
       gt_skat   TYPE STANDARD TABLE OF skat,
       gt_010    TYPE STANDARD TABLE OF zfidt010,
       gt_vbuk   TYPE STANDARD TABLE OF vbuk,
       gt_knvv   TYPE STANDARD TABLE OF knvv,
       gt_soff   TYPE STANDARD TABLE OF ty_soff,
       gt_header TYPE STANDARD TABLE OF ty_header,
       gt_detail TYPE STANDARD TABLE OF ty_detail.

DATA : fill1    TYPE i,
       fill2    TYPE i,
       gv_subrc TYPE sy-subrc,
       gv_belnr TYPE bkpf-belnr,
       gv_gjahr TYPE bkpf-gjahr,
       gv_txt50 TYPE skat-txt50,
       gv_waers TYPE t001-waers,
       gv_dmbtr TYPE bseg-dmbtr,
       gv_uname TYPE sy-uname,
       gv_butxt TYPE t001-butxt,
       gv_bezei TYPE tvkbt-bezei,
       gv_budat TYPE bkpf-budat.

DATA : accountgl         TYPE STANDARD TABLE OF bapiacgl09,
       accountpayable    TYPE STANDARD TABLE OF bapiacap09,
       accountreceivable TYPE STANDARD TABLE OF bapiacar09,
       extension1        TYPE STANDARD TABLE OF bapiacextc,
       currencyamount    TYPE STANDARD TABLE OF bapiaccr09,
       criteria          TYPE STANDARD TABLE OF bapiackec9,
       return            TYPE STANDARD TABLE OF bapiret2,
       documentheader    TYPE bapiache09.

FIELD-SYMBOLS : <fs_out>    TYPE STANDARD TABLE.
