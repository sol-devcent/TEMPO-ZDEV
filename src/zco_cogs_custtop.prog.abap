*&---------------------------------------------------------------------*
*&  Include           ZCO_COGS_CUSTTOP
*&---------------------------------------------------------------------*

TABLES : sscrfields, ekko.

CLASS : lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF ty_mkpf,
          mblnr   TYPE mkpf-mblnr,
          mjahr   TYPE mkpf-mjahr,
          budat   TYPE mkpf-budat,
        END OF ty_mkpf.

TYPES : BEGIN OF ty_out,
          matnr   TYPE mseg-matnr,
          maktx   TYPE makt-maktx,
          meins   TYPE mseg-meins,
          kunnr   TYPE mseg-kunnr,
          name1   TYPE kna1-name1,
          lbkum   TYPE ckmlpp-lbkum,
          waers   TYPE ckmlcr-waers,
          kzwi1   TYPE vbrp-kzwi1,
          salkv   TYPE ckmlcr-salkv,
        END OF ty_out.

DATA : gv_repid             LIKE sy-repid,
       ok_code              TYPE sy-ucomm,
       gs_exclude           TYPE ui_functions,
       g_content            TYPE REF TO cl_salv_form_element,
       g_customcont         TYPE REF TO cl_gui_custom_container,
       g_splitter           TYPE REF TO cl_gui_splitter_container,
       g_container          TYPE REF TO cl_gui_container,
       g_maingrid           TYPE REF TO cl_gui_alv_grid,
       event_receiver       TYPE REF TO lcl_application,
       selected             VALUE 'X',
       gs_stable            TYPE lvc_s_stbl,
       gt_main_fieldcat     TYPE lvc_t_fcat,
       gs_layout_alv        TYPE lvc_s_layo,
       g_handle_alv         TYPE i,
       gt_main_sort         TYPE lvc_t_sort WITH HEADER LINE,
       gs_variant           LIKE disvariant.

DATA : gt_mkpf    TYPE STANDARD TABLE OF ty_mkpf INITIAL SIZE 0,
       gt_mseg    TYPE STANDARD TABLE OF mseg INITIAL SIZE 0,
       gt_mbew    TYPE STANDARD TABLE OF mbew INITIAL SIZE 0,
       gt_mlcd    TYPE STANDARD TABLE OF mlcd INITIAL SIZE 0,
       gt_makt    TYPE STANDARD TABLE OF makt INITIAL SIZE 0,
       gt_kna1    TYPE STANDARD TABLE OF kna1 INITIAL SIZE 0,
       gt_out     TYPE STANDARD TABLE OF ty_out INITIAL SIZE 0,
       gs_out     TYPE ty_out.

DATA : gt_vbrk    TYPE STANDARD TABLE OF vbrk INITIAL SIZE 0
                  WITH HEADER LINE.
DATA : gt_vbrp    TYPE STANDARD TABLE OF vbrp INITIAL SIZE 0
                  WITH HEADER LINE.

DATA : BEGIN OF gt_error OCCURS 0,
         icon(4),
         vbeln   TYPE vbeln,
         mess    TYPE bdc_vtext1,
       END OF gt_error.

DATA : gv_name1   TYPE t001w-name1.
