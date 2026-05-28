*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E007TOP
*&---------------------------------------------------------------------*
TABLES : zgdmmt004z, sscrfields.

TYPES : BEGIN OF ty_filter,
          index   TYPE sy-tabix,
        END OF ty_filter.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          zalno     TYPE zgdmmt004x-zalno,
          lifnr     TYPE zgdmmt004x-lifnr,
          name1     TYPE zgdmmt004x-name1,
          matnr     TYPE zgdmmt004x-matnr,
          maktx     TYPE zgdmmt004x-maktx,
          meins     TYPE zgdmmt004x-bamei,
          menge     TYPE zgdmmt004x-bamng,
          kbetr     TYPE zgdmmt004x-kbetr,
          alloc     TYPE zgdmmt004x-menge,
          kbet1     TYPE zgdmmt004x-kbet1,
          ekgrp     TYPE zgdmmt004z-ekgrp,
          frgco     TYPE zgdmmt004z-frgco,
          anzef     TYPE rm06b-anzef,
          procstat  TYPE zgdmmt004z-procstat,
          atach(4),
          fpkh(4),
          lamp(4),
          submi     TYPE ekko-submi,
          vrsio     TYPE zgdmmt004z-vrsio,
          netpr     TYPE eine-netpr,
          style     TYPE lvc_t_styl,
          color     TYPE lvc_t_scol,
        END OF ty_out.

TYPES : BEGIN OF ty_temp,
          document    TYPE string,
        END OF ty_temp.

TYPES : BEGIN OF ty_poemail,
          ebeln   TYPE ekko-ebeln,
          zalno   TYPE zgdmmt004z-zalno,
          ernam   TYPE zgdmmt004z-ernam,
        END OF ty_poemail.

TYPES : BEGIN OF ty_return,
          zalno   TYPE zgdmmt004x-zalno.
        INCLUDE STRUCTURE bapiret2.
TYPES : END OF ty_return.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code           TYPE sy-ucomm,
       dynlog            TYPE smp_dyntxt,
       dyn_appr          TYPE smp_dyntxt,
       dyn_rjct          TYPE smp_dyntxt,
       dyn_merge         TYPE smp_dyntxt,
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
       gt_filter         TYPE STANDARD TABLE OF ty_filter,
       g_html_container  TYPE REF TO cl_gui_custom_container,
       g_html_control    TYPE REF TO cl_gui_html_viewer.

DATA : gt_out            TYPE STANDARD TABLE OF ty_out,
       gt_xout           TYPE STANDARD TABLE OF ty_out,
       gt_05             TYPE STANDARD TABLE OF zhsmmmdt005,
       gt_08             TYPE STANDARD TABLE OF zhsmmmdt008,
       gt_04x            TYPE STANDARD TABLE OF zgdmmt004x,
       gt_04y            TYPE STANDARD TABLE OF zgdmmt004y,
       gt_04z            TYPE STANDARD TABLE OF zgdmmt004z,
       gt_04e            TYPE STANDARD TABLE OF zgdmmt004e,
       gt_04p            TYPE STANDARD TABLE OF zgdmmt004p,
       gt_temp           TYPE STANDARD TABLE OF ty_temp,
       gt_qinf           TYPE STANDARD TABLE OF qinf,
       gt_ekpo           TYPE STANDARD TABLE OF ekpo,
       gt_xekpo          TYPE STANDARD TABLE OF ekpo,
       gt_lfm1           TYPE STANDARD TABLE OF lfm1,
       gt_eina           TYPE STANDARD TABLE OF eina,
       gt_eine           TYPE STANDARD TABLE OF eine,
       gt_return         TYPE STANDARD TABLE OF ty_return,
       gt_objbin         TYPE TABLE OF solix.

DATA : gv_subrc          TYPE sy-subrc,
*       gv_frgco          TYPE t16fc-frgco,
*       gv_procstat       TYPE zgdmmt004z-procstat,
       gv_ekorg          TYPE ekko-ekorg,
       gv_mail,
       gv_guname         TYPE seqg3-guname.

DATA : gt_poemail        TYPE STANDARD TABLE OF ty_poemail,
       gt_createpo       TYPE STANDARD TABLE OF zgdmmt004z,
       gt_tfcat          TYPE lvc_t_fcat,
       gt_ffcat          TYPE lvc_t_fcat,
       gt_thtml          TYPE STANDARD TABLE OF w3html,
       gt_fhtml          TYPE STANDARD TABLE OF w3html.

DATA : gv_srno1          TYPE zhsmmmdt005-srno1.

FIELD-SYMBOLS : <fs_tab>    TYPE STANDARD TABLE.

DATA : gt_merge_fieldcat    TYPE slis_t_fieldcat_alv.
