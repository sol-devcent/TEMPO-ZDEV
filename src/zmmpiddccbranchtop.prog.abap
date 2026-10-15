*&---------------------------------------------------------------------*
*&  Include           ZMMPIDDCCBRANCHTOP
*&---------------------------------------------------------------------*
TABLES : sscrfields, mara, mard, mchb, zmdcc_branch.

CLASS : lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF ty_material,
          matnr   TYPE mara-matnr,
          meins   TYPE mara-meins,
          xchpf   TYPE mara-xchpf,
          werks   TYPE marc-werks,
        END OF ty_material.

TYPES : BEGIN OF ty_error.
        INCLUDE STRUCTURE bapiret2.
TYPES : END OF ty_error.

DATA : gv_repid             LIKE sy-repid,
       ok_code              TYPE sy-ucomm,
       gs_exclude           TYPE ui_functions,
       g_content            TYPE REF TO cl_salv_form_element,
       g_customcont         TYPE REF TO cl_gui_custom_container,
       g_splitter           TYPE REF TO cl_gui_splitter_container,
       g_contain            TYPE REF TO cl_gui_container,
       g_tabgrid            TYPE REF TO cl_gui_alv_grid,
       g_updgrid            TYPE REF TO cl_gui_alv_grid,
       event_receiver       TYPE REF TO lcl_application,
       selected             VALUE 'X',
       gs_stable            TYPE lvc_s_stbl,
       gt_main_fieldcat     TYPE lvc_t_fcat,
       gs_layout_alv        TYPE lvc_s_layo,
       g_handle_alv         TYPE i,
       gt_main_sort         TYPE lvc_t_sort WITH HEADER LINE,
       gs_variant           LIKE disvariant,
       gs_toolbar           TYPE stb_button.

DATA : dfies_tab            TYPE STANDARD TABLE OF dfies,
       gt_t001w             TYPE STANDARD TABLE OF t001w,
       gt_material          TYPE STANDARD TABLE OF ty_material,
       gt_mchb              TYPE STANDARD TABLE OF mchb,
       gt_mard              TYPE STANDARD TABLE OF mard,
       gt_save              TYPE STANDARD TABLE OF zmdcc_branch,
       gt_error             TYPE STANDARD TABLE OF ty_error,
       gt_zmdcc             TYPE STANDARD TABLE OF zmdcc_branch.

FIELD-SYMBOLS : <fs_gt>     TYPE STANDARD TABLE,
                <fs_gs>     TYPE ANY,
                <fs>        TYPE ANY.

DATA : gv_pos.
