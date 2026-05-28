*&---------------------------------------------------------------------*
*&  Include           ZMMCOODCTOP
*&---------------------------------------------------------------------*
INCLUDE <icon>.

TYPE-POOLS : slis, vrm.

TABLES : ekko, ekpo, sscrfields, zbdcdt02, lqua.

CLASS : lcl_application DEFINITION DEFERRED.

CONTROLS : tc_bdc01 TYPE TABLEVIEW USING SCREEN 101,
           tc_bdc02 TYPE TABLEVIEW USING SCREEN 102.

TYPES : BEGIN OF ty_makt,
          matnr   TYPE mara-matnr,
          meins   TYPE mara-meins,
          maktx   TYPE makt-maktx,
        END OF ty_makt.

TYPES : BEGIN OF ty_alvl1,
          mark,
          icon(4),
          objkey(50),
          flag,
          matnr   TYPE mara-matnr,
          maktx   TYPE makt-maktx,
          meins   TYPE mara-meins,
          vstel1  TYPE ekpv-vstel,
          ebeln1  TYPE ekpo-ebeln,
          ebelp1  TYPE ekpo-ebelp,
          menge1  TYPE ekpo-menge,
          labst1  TYPE mchb-clabs,
          vbeln1  TYPE zbdcdt02-vbeln_al,
          vstel2  TYPE ekpv-vstel,
          ebeln2  TYPE ekpo-ebeln,
          ebelp2  TYPE ekpo-ebelp,
          menge2  TYPE ekpo-menge,
          labst2  TYPE mchb-clabs,
          vbeln2  TYPE zbdcdt02-vbeln_mk,
          vstel3  TYPE ekpv-vstel,
          ebeln3  TYPE ekpo-ebeln,
          ebelp3  TYPE ekpo-ebelp,
          menge3  TYPE ekpo-menge,
          labst3  TYPE mchb-clabs,
          vbeln3  TYPE zbdcdt02-vbeln_fc,
          dnqty   TYPE mchb-clabs,
          carqty  TYPE mchb-clabs,
          cooqty  TYPE mchb-clabs,
          coono   TYPE ekpo-ebeln,
          coodt   TYPE zbdcdt02-coodt,
          cootm   TYPE zbdcdt02-cootm,
          coonm   TYPE zbdcdt02-coonm,
          coodn   TYPE ekpo-ebeln,
          posnr   TYPE lips-posnr,
          lgnum   TYPE lqua-lgnum,
          werks   TYPE lqua-werks,
          lgort   TYPE lqua-lgort,
          charg   TYPE lqua-charg,
          lgtyp   TYPE lqua-lgtyp,
          lgpla   TYPE lqua-lgpla,
          verme   TYPE lqua-verme,
          bestq   TYPE lqua-bestq,
          sobkz   TYPE lqua-sobkz,
          zendm(1),
          zqty    TYPE zbdcdt02-zqty,
          reswk   TYPE ekko-reswk,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_alvl1.

TYPES : BEGIN OF ty_post1,
          vstel   TYPE ekpv-vstel,
          ebeln   TYPE ekpo-ebeln,
          ebelp   TYPE ekpo-ebelp,
          menge(20),
          meins   TYPE mara-meins,
          coono   TYPE zbdcdt02-coono,
          coodn   TYPE likp-vbeln,
        END OF ty_post1.

TYPES : BEGIN OF ty_error,
          msgid  LIKE sy-msgid,
          msgty  LIKE sy-msgty,
          msgno  LIKE sy-msgno,
          msgv1  LIKE sy-msgv1,
          msgv2  LIKE sy-msgv2,
          msgv3  LIKE sy-msgv3,
          msgv4  LIKE sy-msgv4,
          objkey(50),
        END OF ty_error.

TYPES : BEGIN OF ty_lqua,
          objkey(50),
          txz01   TYPE ekpo-txz01,
          tbpos   TYPE mseg-tbpos,
          coodn   TYPE likp-vbeln,
          matnr   TYPE lqua-matnr,
          charg   TYPE lqua-charg,
          verme   TYPE lqua-verme,
          meins   TYPE lqua-meins,
          lgtyp   TYPE lqua-lgtyp,
          lgpla   TYPE lqua-lgpla,
        END OF ty_lqua.

DATA : gs_exclude        TYPE ui_functions,
       g_customcont      TYPE REF TO cl_gui_custom_container,
       g_splitter        TYPE REF TO cl_gui_splitter_container,
       g_contain01       TYPE REF TO cl_gui_container,
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
       g_handle_alv      TYPE i.

DATA : gt_zbdcdt01       TYPE STANDARD TABLE OF zbdcdt01,
       gt_zbdcdt02       TYPE STANDARD TABLE OF zbdcdt02,
       gt_zbdcdt02a      TYPE STANDARD TABLE OF zbdcdt02a,
       gt_lqua           TYPE STANDARD TABLE OF lqua,
       gt_ekko           TYPE STANDARD TABLE OF ekko,
       gt_ekpo           TYPE STANDARD TABLE OF ekpo,
       gt_eket           TYPE STANDARD TABLE OF eket,
       gt_mard           TYPE STANDARD TABLE OF mard,
       gt_vbbe           TYPE STANDARD TABLE OF vbbe,
       gt_ekpv           TYPE STANDARD TABLE OF ekpv,
       gt_vbuk           TYPE STANDARD TABLE OF vbuk,
       gt_makt           TYPE STANDARD TABLE OF ty_makt,
       gt_marm           TYPE STANDARD TABLE OF marm,
       gt_mlgn           TYPE STANDARD TABLE OF mlgn,
       gt_t001w          TYPE STANDARD TABLE OF t001w,
       gt_list           TYPE STANDARD TABLE OF makt,
       gt_error          TYPE STANDARD TABLE OF ty_error,
       gt_bapiret2       TYPE STANDARD TABLE OF bapiret2,
       gt_post1          TYPE STANDARD TABLE OF ty_post1,
       gt_xlqua          TYPE STANDARD TABLE OF ty_lqua.

DATA : gr_bsart          TYPE RANGE OF bsart WITH HEADER LINE,
       gr_bsart1         TYPE RANGE OF bsart WITH HEADER LINE,
       gr_bsart2         TYPE RANGE OF bsart WITH HEADER LINE,
       gr_bsart3         TYPE RANGE OF bsart WITH HEADER LINE.

DATA : gr_reswk          TYPE RANGE OF reswk WITH HEADER LINE,
       gr_reswk1         TYPE RANGE OF reswk WITH HEADER LINE,
       gr_reswk2         TYPE RANGE OF reswk WITH HEADER LINE,
       gr_reswk3         TYPE RANGE OF reswk WITH HEADER LINE.

DATA : gr_ekorg          TYPE RANGE OF ekorg WITH HEADER LINE,
       gr_ekorg1         TYPE RANGE OF ekorg WITH HEADER LINE,
       gr_ekorg2         TYPE RANGE OF ekorg WITH HEADER LINE,
       gr_ekorg3         TYPE RANGE OF ekorg WITH HEADER LINE.

DATA : gr_reslo1         TYPE RANGE OF reslo WITH HEADER LINE,
       gr_reslo2         TYPE RANGE OF reslo WITH HEADER LINE,
       gr_reslo3         TYPE RANGE OF reslo WITH HEADER LINE.

DATA : gr_eerks1         TYPE RANGE OF werks_d WITH HEADER LINE,
       gr_eerks2         TYPE RANGE OF werks_d WITH HEADER LINE,
       gr_eerks3         TYPE RANGE OF werks_d WITH HEADER LINE.

DATA : gr_egort1         TYPE RANGE OF lgort_d WITH HEADER LINE,
       gr_egort2         TYPE RANGE OF lgort_d WITH HEADER LINE,
       gr_egort3         TYPE RANGE OF lgort_d WITH HEADER LINE.

DATA : gr_merks          TYPE RANGE OF werks_d WITH HEADER LINE,
       gr_merks1         TYPE RANGE OF werks_d WITH HEADER LINE,
       gr_merks2         TYPE RANGE OF werks_d WITH HEADER LINE,
       gr_merks3         TYPE RANGE OF werks_d WITH HEADER LINE.

DATA : gr_mgort          TYPE RANGE OF lgort_d WITH HEADER LINE,
       gr_mgort1         TYPE RANGE OF lgort_d WITH HEADER LINE,
       gr_mgort2         TYPE RANGE OF lgort_d WITH HEADER LINE,
       gr_mgort3         TYPE RANGE OF lgort_d WITH HEADER LINE.

DATA : gr_proc           TYPE RANGE OF meprocstate WITH HEADER LINE.

DATA : gv_name1          TYPE t001w-name1,
       ok_code           TYPE sy-ucomm,
       line_count        TYPE i,
       rspar_tab         TYPE TABLE OF rsparams,
       rspar_line        LIKE LINE OF rspar_tab.

DATA : bdch              TYPE zbdcst01,
       gt_bdcd           TYPE STANDARD TABLE OF zbdcst01,
       bdcd              TYPE zbdcst01,
       gt_listd          TYPE STANDARD TABLE OF zbdcst01,
       listd             TYPE zbdcst01,
       gt_coo            TYPE STANDARD TABLE OF zbdcst01.

DATA : gt_alvl1          TYPE STANDARD TABLE OF ty_alvl1.
