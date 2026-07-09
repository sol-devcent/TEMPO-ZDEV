*&---------------------------------------------------------------------*
*&  Include           ZCO_WIPTOP
*&---------------------------------------------------------------------*
INCLUDE <icon>.

TABLES : sscrfields, afpo, aufk.

CLASS lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF ty_mara,
          matnr   LIKE mara-matnr,
          meins   LIKE mara-meins,
          maktx   LIKE makt-maktx,
        END OF ty_mara.

TYPES : BEGIN OF ty_out,
         werks    LIKE aufk-werks,
         monat    LIKE bkpf-monat,
         gjahr    LIKE cosb-gjahr,
         matnr    LIKE afpo-matnr,
         maktx    LIKE makt-maktx,
         meins    LIKE mara-meins,
         objnr    LIKE cosb-objnr,
         aufnr    LIKE aufk-aufnr,
         wemng    LIKE afpo-wemng,
         gamng    LIKE afko-gamng,
         vaqty    LIKE afko-gamng,
         beqty    LIKE cosb-wog001,
         adqty    LIKE cosb-wog001,
         deqty    LIKE cosb-wog001,
         enqty    LIKE cosb-wog001,
       END OF ty_out.

DATA : gv_repid              TYPE sy-repid,
       gv_dynnr              TYPE sy-dynnr,
       ok_code               TYPE sy-ucomm,
       g_content             TYPE REF TO cl_salv_form_element,
       g_docking             TYPE REF TO cl_gui_docking_container,
       g_outcont             TYPE REF TO cl_gui_custom_container,
       g_splitter            TYPE REF TO cl_gui_splitter_container,
       g_container           TYPE REF TO cl_gui_container,
       g_container1          TYPE REF TO cl_gui_container,
       g_outgrid             TYPE REF TO cl_gui_alv_grid,
       g_outgrid1            TYPE REF TO cl_gui_alv_grid,
       gs_exclude            TYPE ui_functions,
       event_receiver        TYPE REF TO lcl_application,
       selected              VALUE 'X',
       gs_variant            LIKE disvariant,
       gs_layout_alv         TYPE lvc_s_layo,
       gs_layout_alv1        TYPE lvc_s_layo,
       gt_sort_grid          TYPE lvc_t_sort WITH HEADER LINE,
       gt_fieldcat           TYPE lvc_t_fcat,
       gt_fieldcat1          TYPE lvc_t_fcat,
       gs_stable             TYPE lvc_s_stbl,
       gs_toolbar            TYPE stb_button.

DATA : BEGIN OF gt_cosb OCCURS 0.
         INCLUDE STRUCTURE cosb.
DATA :   aufnr  TYPE caufv-aufnr,
       END OF gt_cosb.

DATA : gt_caufv  TYPE STANDARD TABLE OF caufv INITIAL SIZE 0,
       gt_afpo   TYPE STANDARD TABLE OF afpo INITIAL SIZE 0.

DATA : gt_out    TYPE STANDARD TABLE OF ty_out INITIAL SIZE 0,
       gt_out1   TYPE STANDARD TABLE OF ty_out INITIAL SIZE 0,
       gt_out2   TYPE STANDARD TABLE OF ty_out INITIAL SIZE 0.

DATA : gt_mara   TYPE STANDARD TABLE OF ty_mara INITIAL SIZE 0.

DATA : gv_matnr(70),
       gv_werks(10),
       gv_name1   LIKE t001w-name1,
       gv_perio(100).
