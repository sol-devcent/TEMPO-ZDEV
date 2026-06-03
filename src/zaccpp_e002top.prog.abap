*&---------------------------------------------------------------------*
*&  Include           ZACCPP_E002TOP
*&---------------------------------------------------------------------*
TABLES : sscrfields, rstable, zaccppdt001.

CLASS : lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF ty_a989_key,
          vkorg TYPE a989-vkorg,
          matnr TYPE a989-matnr,
        END OF ty_a989_key.

 TYPES: BEGIN OF text,
           line(4045),
         END OF text.

DATA : obj_container  TYPE REF TO cl_gui_custom_container.
DATA : o_error       TYPE REF TO i_oi_error,
       o_control     TYPE REF TO i_oi_container_control,
       o_document    TYPE REF TO i_oi_document_proxy,
       o_spreadsheet TYPE REF TO i_oi_spreadsheet.

DATA : gv_repid       LIKE sy-repid,
       ok_code        TYPE sy-ucomm,
       gs_exclude_t   TYPE ui_functions,
       gs_exclude_b   TYPE ui_functions,
       g_content      TYPE REF TO cl_salv_form_element,
       g_maincont     TYPE REF TO cl_gui_custom_container,
       g_splitter     TYPE REF TO cl_gui_splitter_container,
       g_top          TYPE REF TO cl_gui_container,
       g_bottom       TYPE REF TO cl_gui_container,
       g_tgrid        TYPE REF TO cl_gui_alv_grid,
       g_bgrid        TYPE REF TO cl_gui_alv_grid,
       event_receiver TYPE REF TO lcl_application,
       selected       VALUE 'X',
       gs_stable      TYPE lvc_s_stbl,
       gt_fieldcat_t  TYPE lvc_t_fcat,
       gt_fieldcat_b  TYPE lvc_t_fcat,
       gs_layout_alv  TYPE lvc_s_layo,
       g_handle_alv   TYPE i,
       gt_main_sort   TYPE lvc_t_sort WITH HEADER LINE,
       gs_variant     LIKE disvariant,
       gs_toolbar     TYPE stb_button.

DATA : gt_upload  TYPE STANDARD TABLE OF zaccstp,
       gt_cancel  TYPE STANDARD TABLE OF zaccstc,
       gt_accdtm  TYPE STANDARD TABLE OF zv_accdtm,
       gt_accdtm_dlv  TYPE STANDARD TABLE OF zv_accdtm,
       gt_accdtm_crtd  TYPE STANDARD TABLE OF zv_accdtm,
       gt_accdtd  TYPE STANDARD TABLE OF zaccdtd,
       gt_accdta  TYPE STANDARD TABLE OF zaccdta,
       gt_s501    TYPE STANDARD TABLE OF s501,
       gt_mch1    TYPE STANDARD TABLE OF mch1,
       gt_t001k   TYPE STANDARD TABLE OF t001k,
       gt_a989    TYPE STANDARD TABLE OF a989,
       gt_konp    TYPE STANDARD TABLE OF konp,
       gt_mara    TYPE STANDARD TABLE OF mara,
       gt_zaccdtu TYPE STANDARD TABLE OF zaccdtu.

DATA : gt_zaccdtm     TYPE STANDARD TABLE OF zaccdtm.

DATA : gt_eaccdtm     TYPE STANDARD TABLE OF zaccstp.

FIELD-SYMBOLS : <fs_top>     TYPE STANDARD TABLE,
                <fs_bottom>  TYPE STANDARD TABLE,
                <fs_ltop>    TYPE any,
                <fs_lbottom> TYPE any.

DATA : gs_header TYPE bapi2017_gm_head_01,
       gt_item   TYPE STANDARD TABLE OF bapi2017_gm_item_create.

DATA : status_code(5),
       status_text(300),
       len TYPE i.

DATA : gt_request_header  TYPE TABLE OF sbcheader WITH HEADER LINE,
       gt_request_body    TYPE TABLE OF text WITH HEADER LINE,
       gt_response_header TYPE TABLE OF sbcheader WITH HEADER LINE,
       gt_response_body   TYPE TABLE OF text WITH HEADER LINE.
DATA: gt_zaccppdt001 TYPE STANDARD TABLE OF zaccppdt001,
      gs_zaccppdt001 TYPE zaccppdt001.

DATA : gv_token(100),
       gv_login      TYPE zaccdtu-uri,
       gv_uri        TYPE zaccdtu-uri,
       gv_uri1       TYPE zaccdtu-uri,
       gv_backg      VALUE 'X',
       gv_running,
       gv_upload     TYPE i.
