*&---------------------------------------------------------------------*
*&  Include           ZWM_E001TOP
*&---------------------------------------------------------------------*
INCLUDE <icon>.

TABLES : sscrfields, mlgt.

CLASS : lcl_application DEFINITION DEFERRED.

TYPES : BEGIN OF ty_001a,
          znou  TYPE znou,
          lgtyp TYPE lgtyp,
        END OF ty_001a.
TYPES : BEGIN OF ty_filter,
          index TYPE sy-tabix,
        END OF ty_filter.

DATA : gv_repid         LIKE sy-repid,
       ok_code          TYPE sy-ucomm,
       gs_exclude       TYPE ui_functions,
       g_content        TYPE REF TO cl_salv_form_element,
       g_customcont     TYPE REF TO cl_gui_custom_container,
       g_splitter       TYPE REF TO cl_gui_splitter_container,
       g_container      TYPE REF TO cl_gui_container,
       g_maingrid       TYPE REF TO cl_gui_alv_grid,
       event_receiver   TYPE REF TO lcl_application,
       selected         VALUE 'X',
       gs_stable        TYPE lvc_s_stbl,
       gt_main_fieldcat TYPE lvc_t_fcat,
       gs_layout_alv    TYPE lvc_s_layo,
       g_handle_alv     TYPE i,
       gt_filter        TYPE STANDARD TABLE OF ty_filter,
       gt_main_sort     TYPE lvc_t_sort WITH HEADER LINE,
       gs_variant       LIKE disvariant,
       gs_toolbar       TYPE stb_button.

DATA : gt_001       TYPE STANDARD TABLE OF zwmdt001 INITIAL SIZE 0,
       gt_lagp      TYPE STANDARD TABLE OF lagp INITIAL SIZE 0,
       gt_lqua      TYPE STANDARD TABLE OF lqua INITIAL SIZE 0,
       gt_mlgn      TYPE STANDARD TABLE OF mlgn INITIAL SIZE 0,
       gt_zwmdt001a TYPE STANDARD TABLE OF zwmdt001a INITIAL SIZE 0,
       gt_001a      TYPE STANDARD TABLE OF ty_001a,
       lt_zwmdt001x TYPE STANDARD TABLE OF zwmdt001x INITIAL SIZE 0,
       ls_zwmdt001x LIKE LINE OF lt_zwmdt001x.

DATA : BEGIN OF gt_out OCCURS 0,
         lgnum      TYPE ltak-lgnum,
         tanum      TYPE ltak-tanum,
         matnr      TYPE ltap-matnr,
         maktx      TYPE makt-maktx,
         werks      TYPE ltap-werks,
         lgort      TYPE ltap-lgort,
         charg      TYPE ltap-charg,
         letyp      TYPE ltap-letyp,
         anfme      TYPE rl03t-anfme,
         altme      TYPE ltap-altme,
         karton     TYPE rl03t-anfme,
         uom_karton TYPE mara-meins,
         ecer       TYPE rl03t-anfme,
         uom_ecer   TYPE mara-meins,
         vltyp      TYPE ltap-vltyp,
         vlpla      TYPE ltap-vlpla,
         wdatu      TYPE lqua-wdatu,
         nltyp      TYPE ltap-nltyp,
         nlpla      TYPE ltap-nlpla,
         remark(150),
         nourut     TYPE i,
         check,
         icon(4),
         style      TYPE lvc_t_styl,
       END OF gt_out,
       wa_out LIKE gt_out.

DATA : gt_error TYPE STANDARD TABLE OF bapiret2 INITIAL SIZE 0.
