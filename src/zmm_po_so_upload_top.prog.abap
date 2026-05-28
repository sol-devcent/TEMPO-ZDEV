*----------------------------------------------------------------------*
***INCLUDE ZMM_PO_SO_UPLOAD_TOP .
*----------------------------------------------------------------------*
INCLUDE <icon>.

CLASS : lcl_application DEFINITION DEFERRED.

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
       gs_variant           LIKE disvariant,
       gs_toolbar           TYPE stb_button.

DATA : BEGIN OF gt_error OCCURS 0,
         icon(4),
         banfn   LIKE eban-banfn,
         mess    TYPE bdc_vtext1,
       END OF gt_error.
