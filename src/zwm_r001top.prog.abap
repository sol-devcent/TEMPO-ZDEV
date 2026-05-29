*&---------------------------------------------------------------------*
*&  Include           ZWM_R001TOP
*&---------------------------------------------------------------------*
TABLES : ltap, vttk, sscrfields, likp.

TYPES : BEGIN OF ty_tree,
          node_main(15),
          datum         TYPE sy-datum,
        END OF ty_tree.

TYPES : BEGIN OF ty_econf,
          edatu TYPE ltap-edatu,
          ezeit TYPE ltap-ezeit,
        END OF ty_econf.

TYPES : BEGIN OF ty_qconf,
          qdatu TYPE ltap-qdatu,
          qzeit TYPE ltap-qzeit,
        END OF ty_qconf.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          tknum   TYPE zwmdt004-tknum,
          vbeln   TYPE zwmdt004-vbeln,
          posnr   TYPE zwmdt004-posnr,
          tanum   TYPE zwmdt004-tanum,
          matnr   TYPE zwmdt004-matnr,
          charg   TYPE zwmdt004-charg,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

TYPES : BEGIN OF ty_custgrp,
          lgnum TYPE ltap-lgnum,
          tanum TYPE ltap-tanum,
          edatu TYPE ltap-edatu,
          qdatu TYPE ltap-qdatu,
          kdgrp TYPE likp-kdgrp,
        END OF ty_custgrp.

TYPES : BEGIN OF ty_times,
          uname TYPE sy-uname,
          total TYPE i,
        END OF ty_times.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code          TYPE sy-ucomm,
       gs_exclude       TYPE ui_functions,
       g_customcont     TYPE REF TO cl_gui_custom_container,
       g_splitter       TYPE REF TO cl_gui_splitter_container,
       g_splitter1      TYPE REF TO cl_gui_splitter_container,
       g_contain01      TYPE REF TO cl_gui_container,
       g_contain02      TYPE REF TO cl_gui_container,
       g_contain03      TYPE REF TO cl_gui_container,
       g_contain04      TYPE REF TO cl_gui_container,
       g_tabgrid        TYPE REF TO cl_gui_alv_grid,
       g_tree           TYPE REF TO cl_gui_alv_tree,
       g_header         TYPE treev_hhdr,
       g_docking        TYPE REF TO cl_gui_docking_container,
       g_title          TYPE REF TO cl_gui_container,
       g_html_cntrl     TYPE REF TO cl_gui_html_viewer,
       g_dyndoc_id      TYPE REF TO cl_dd_document,
       event_receiver   TYPE REF TO lcl_application,
       selected         VALUE 'X',
       gv_repid         LIKE sy-repid,
       gv_dynnr         TYPE sy-dynnr,
       gs_variant       LIKE disvariant,
       gs_layout_alv    TYPE lvc_s_layo,
       gt_main_sort     TYPE lvc_t_sort WITH HEADER LINE,
       gt_tree_fieldcat TYPE lvc_t_fcat,
       gt_main_fieldcat TYPE lvc_t_fcat,
       gt_lvc_cat       TYPE lvc_t_fcat,
       gs_stable        TYPE lvc_s_stbl,
       gs_toolbar       TYPE stb_button,
       gr_hierseq       TYPE REF TO cl_salv_hierseq_table,
       gr_table         TYPE REF TO cl_salv_table,
       g_handle_alv     TYPE i,
       gt_bapiret2      TYPE STANDARD TABLE OF bapiret2.

DATA : gt_tofcat TYPE lvc_t_fcat,
       gt_dnfcat TYPE lvc_t_fcat,
       gt_usfcat TYPE lvc_t_fcat,
       gt_uslvcc TYPE lvc_t_fcat,
       gt_nmfcat TYPE lvc_t_fcat,
       gt_nmlvcc TYPE lvc_t_fcat,
       gt_tmfcat TYPE lvc_t_fcat,
       gt_tmlvcc TYPE lvc_t_fcat,
       gt_shfcat TYPE lvc_t_fcat.
DATA: gt_sdfcat TYPE lvc_t_fcat.
DATA: gt_mpfcat TYPE lvc_t_fcat.
DATA: gt_dfcat TYPE lvc_t_fcat.
DATA : gt_tree    TYPE STANDARD TABLE OF ty_tree,
       gt_out     TYPE STANDARD TABLE OF ty_out,
       gt_xout    TYPE STANDARD TABLE OF ty_out,
       gt_setnode TYPE STANDARD TABLE OF setnode,
       gt_ltak    TYPE STANDARD TABLE OF ltak,
       gt_ltap    TYPE STANDARD TABLE OF ltap,
       gt_likp    TYPE STANDARD TABLE OF likp,
       gt_likp2   TYPE STANDARD TABLE OF likp,
       gt_vttp    TYPE STANDARD TABLE OF vttp,
       gt_vttk    TYPE STANDARD TABLE OF vttk,
       gt_lips    TYPE STANDARD TABLE OF lips,
       gt_mara    TYPE STANDARD TABLE OF mara,
       holidays   TYPE STANDARD TABLE OF iscal_day,
       gt_a511    TYPE STANDARD TABLE OF a511,
       gt_t151t   TYPE STANDARD TABLE OF t151t,
       gt_times   TYPE STANDARD TABLE OF ty_times,
       gt_003     TYPE STANDARD TABLE OF zwmdt003,
       gt_004     TYPE STANDARD TABLE OF zwmdt004,
       gt_usr21   TYPE STANDARD TABLE OF usr21,
       gt_adrp    TYPE STANDARD TABLE OF adrp.

DATA: lt_lrf_wkqu TYPE STANDARD TABLE OF lrf_wkqu.

DATA : gv_low         TYPE sy-datum,
       gv_high        TYPE sy-datum,
       gv_interval    TYPE i,
       gv_process(30),
       gv_werks       TYPE t320-werks,
       gv_bukrs       TYPE t001k-bukrs,
       gv_uname       TYPE sy-uname,
       gr_vorga       TYPE RANGE OF vorga,
       gr_bwlvs       TYPE RANGE OF bwlvs.

FIELD-SYMBOLS : <fs_utab>   TYPE STANDARD TABLE,
                <fs_uname>  TYPE STANDARD TABLE,
                <fs_lutab>  TYPE any,
                <fs_luname> TYPE any,

                <fs_ktab>   TYPE STANDARD TABLE,
                <fs_ktext>  TYPE STANDARD TABLE,
                <fs_lktab>  TYPE any,
                <fs_lktext> TYPE any,

                <fs_ttab>   TYPE STANDARD TABLE,
                <fs_time>   TYPE STANDARD TABLE,
                <fs_lttab>  TYPE any,
                <fs_ltime>  TYPE any,

                <fs_tree>   TYPE STANDARD TABLE,
                <fs_data>   TYPE STANDARD TABLE,
                <fs_to>     TYPE STANDARD TABLE,
                <fs_dn>     TYPE STANDARD TABLE,
                <fs_delv>   TYPE STANDARD TABLE,
                <fs_kdgrp>  TYPE STANDARD TABLE,
                <fs_ship>   TYPE STANDARD TABLE,
                <fs_sdo>    TYPE STANDARD TABLE,
                <fs_sdo2>   TYPE STANDARD TABLE,
                <fs_mp>     TYPE STANDARD TABLE,
                <fs_mp2>    TYPE STANDARD TABLE,
                <fs_detl>   TYPE STANDARD TABLE,
                <fs_out>    TYPE STANDARD TABLE,
                <fs_ldata>  TYPE any,
                <fs_ltree>  TYPE any,
                <fs_lout>   TYPE any,
                <fs_ldelv>  TYPE any,
                <fs_lkdgrp> TYPE any,
                <fs_lship>  TYPE any,
                <fs_lsdo>   TYPE any,
                <fs_lsdo2>  TYPE any,
                <fs_lmp>    TYPE any,
                <fs_lmp2>   TYPE any,
                <fs_ldetl>  TYPE any,
                <fs_lto>    TYPE any,
                <fs_ldn>    TYPE any,
                <fs>        TYPE any,
                <fs1>       TYPE any.

DATA  : v_lines       TYPE i.
DATA  : v_line(3)     TYPE c.

TYPES: BEGIN OF ty_check_pick,
         tknum  TYPE vttp-tknum,
         erdat  TYPE vttp-erdat,
         lznum  TYPE ltak-lznum,
         tanum  TYPE ltak-tanum,
         vbeln  TYPE ltap-vbeln,
         lgnum  TYPE ltap-lgnum,
         kquit  TYPE ltak-kquit,
         pvqui  TYPE ltap-pvqui,
         queue  TYPE ltak-queue,
         status TYPE char100,
       END OF ty_check_pick.

DATA: gt_check_pick TYPE TABLE OF ty_check_pick,
      ls_check_pick TYPE ty_check_pick.
