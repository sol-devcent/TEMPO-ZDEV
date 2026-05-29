*&---------------------------------------------------------------------*
*&  Include           ZDG2FI_F0013TOP
*&---------------------------------------------------------------------*
TABLES: sscrfields,mara,vttk.

TYPE-POOLS: truxs.

TYPES: BEGIN OF g_ty_s_event,
         user_command                 TYPE char1,
         before_user_command          TYPE char1,
         after_user_command           TYPE char1,
         double_click                 TYPE char1,
         hotspot_click                TYPE char1,
         button_click                 TYPE char1,
         onf1                         TYPE char1,
         onf4                         TYPE char1,
         menu_button                  TYPE char1,
         toolbar                      TYPE char1,
         context_menu_request         TYPE char1,
         ondrag                       TYPE char1,
         ondrop                       TYPE char1,
         ondropcomplete               TYPE char1,
         ondropgetflavor              TYPE char1,
         subtotal_text                TYPE char1,
         data_changed                 TYPE char1,
         data_changed_finished        TYPE char1,
         after_refresh                TYPE char1,
         delayed_callback             TYPE char1,
         delayed_changed_sel_callback TYPE char1,
         top_of_page                  TYPE char1,
         end_of_list                  TYPE char1,
         print_top_of_page            TYPE char1,
         print_end_of_page            TYPE char1,
         print_top_of_list            TYPE char1,
         print_end_of_list            TYPE char1,
       END   OF g_ty_s_event,

       BEGIN OF g_ty_s_onf4,
         register        TYPE char1,
         get_before      TYPE char1,
         change_after    TYPE char1,
         internal_format TYPE char1,
       END   OF g_ty_s_onf4,

       BEGIN OF g_ty_s_test,
         select_amount      TYPE i,
         no_info_popup      TYPE char1,
         info_popup_once    TYPE char1,
         events_info_popup  TYPE lvc_fname OCCURS 0,
         application_events TYPE char1,
         event              TYPE g_ty_s_event,
         onf4               TYPE g_ty_s_onf4,
         button_fields      TYPE lvc_fname OCCURS 0,
         hotspot_fields     TYPE lvc_fname OCCURS 0,
         onf1_fields        TYPE lvc_fname OCCURS 0,
         onf4_fields        TYPE lvc_fname OCCURS 0,
         bypassing_buffer   TYPE char1,
         buffer_active      TYPE char1,
       END   OF g_ty_s_test.

* Refrence Objects To Alv Grid & Custom Container Classes
DATA: g_container TYPE scrfname VALUE 'CONTAINER',
      g_grid      TYPE REF TO cl_gui_alv_grid,
*      g_handler   TYPE REF TO lcl_event_responder,
*      g_event_handler TYPE REF TO lcl_event_handler,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      gt_fieldcat TYPE lvc_t_fcat WITH HEADER LINE,
      gt_sort     TYPE lvc_t_sort WITH HEADER LINE,
      gs_layout   TYPE lvc_s_layo,
      gv_repid    LIKE sy-repid,
      gs_variant  TYPE disvariant,
      gt_exclude  TYPE ui_functions,
      e_object    TYPE REF TO cl_alv_event_toolbar_set.

DATA: gs_test TYPE g_ty_s_test.

DATA: gv_row      TYPE lvc_s_row,
      gv_column   TYPE lvc_s_col,
      gv_row_num  TYPE lvc_s_roid.

DATA:
* Reference to document
       dg_dyndoc_id       TYPE REF TO cl_dd_document,
* Reference to split container
       dg_splitter        TYPE REF TO cl_gui_splitter_container,
* Reference to grid container
       dg_parent_grid     TYPE REF TO cl_gui_container,
* Reference to html container
       dg_html_cntrl      TYPE REF TO cl_gui_html_viewer,
* Reference to html container
       dg_parent_html     TYPE REF TO cl_gui_container.

DATA: BEGIN OF gt_out OCCURS 0.
DATA:   tplst       TYPE tplst,
        tdlnr       TYPE tdlnr,
        name_vnd    TYPE name1_gp,
        tknum       TYPE tknum,
        shtyp       TYPE shtyp,
        erdat       TYPE erdat,
        erzet       TYPE erzet,
        sttrg       TYPE sttrg,
        exti2       TYPE exti2,
        route       TYPE routr,
        kunnr       TYPE kunwe,
        lfart       TYPE lfart,
        name_cust   TYPE name1_gp,
        lzone       TYPE lzone,
        wadat_ist   TYPE wadat_ist,
        vbeln       TYPE vbeln_vl,
        zreason     TYPE zreason2,
        crexrsdesc  TYPE zcrexrsdesc,
        crdat       TYPE crdat,
        crtim       TYPE potim,
        ztype       TYPE zjasdesc,
        brgew       TYPE brgew_vekp,
        btvol       TYPE btvol_vekp,
        koli        TYPE btvol_vekp,
        tndr_maxp   TYPE tndr_maxp,
        tndr_trkid  TYPE tndr_trkid,
        count       TYPE int2,
*        maktx       TYPE maktx,
*        chbox       TYPE char1,
*        celltab     TYPE lvc_t_styl,
      END OF gt_out.

DATA: BEGIN OF gt_vttk OCCURS 0.
        INCLUDE STRUCTURE vttk.
DATA:   vpobjkey  TYPE vpobjkey,
      END OF gt_vttk.

DATA: BEGIN OF gt_inhalt OCCURS 0,
        inhalt LIKE vekp-inhalt,
      END OF gt_inhalt.

DATA: gt_vttp TYPE TABLE OF vttp WITH HEADER LINE,
      gt_likp TYPE TABLE OF likp WITH HEADER LINE,
      gt_kna1 TYPE TABLE OF kna1 WITH HEADER LINE,
      gt_zmshphist TYPE TABLE OF zmshphist WITH HEADER LINE,
      gt_zmshphistr TYPE TABLE OF zmshphistr WITH HEADER LINE,
      gt_zsextrecreas TYPE TABLE OF zsextrecreas WITH HEADER LINE,
      gt_zsextrec TYPE TABLE OF zsextrec WITH HEADER LINE,
      gt_vekp TYPE TABLE OF vekp WITH HEADER LINE,
      gt_vekp2 TYPE TABLE OF vekp WITH HEADER LINE,
      gt_vepo TYPE TABLE OF vepo WITH HEADER LINE,
      gt_zsmatjas TYPE TABLE OF zsmatjas WITH HEADER LINE,
      gt_lfa1 TYPE TABLE OF lfa1 WITH HEADER LINE.

FIELD-SYMBOLS: <fs_out> LIKE gt_out,
               <fs_vttk> LIKE gt_vttk.
