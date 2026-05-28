*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E004TOP
*&---------------------------------------------------------------------*
TABLES : ekpo, sscrfields, eban.

TYPE-POOLS : p99sg.

CONTROLS : tc_vendor        TYPE TABLEVIEW USING SCREEN 102,
           tc_splitq        TYPE TABLEVIEW USING SCREEN 105,
           tc_pir           TYPE TABLEVIEW USING SCREEN 106.

TYPES : BEGIN OF ty_filter,
          index   TYPE sy-tabix,
        END OF ty_filter.

TYPES : BEGIN OF ty_head,
          submi   TYPE ekko-submi,
          vrsio   TYPE zgdmmt004z-vrsio,
          werks   TYPE ekpo-werks,
          name1w  TYPE t001w-name1,
          matnr   TYPE mara-matnr,
          maktx   TYPE makt-maktx,
          kbetr   TYPE konp-kbetr,
          konwa   TYPE konp-konwa,
          bsmng   TYPE eban-bsmng,
          menge   TYPE ekpo-menge,
          meins   TYPE ekpo-meins,
          datlb   TYPE eine-datlb,
          lifnr   TYPE ekko-lifnr,
          name1l  TYPE lfa1-name1,
          banfn   TYPE eban-banfn,
          bnfpo   TYPE eban-bnfpo,
          bedat   TYPE eipa-bedat,
          bwaer   TYPE eipa-bwaer,
          preis   TYPE eipa-preis,
          peinh   TYPE eipa-peinh,
          bprme   TYPE eipa-bprme,
          ppeinh  TYPE eipa-peinh,
          pprme   TYPE eipa-bprme,
          waers   TYPE ekko-waers,
          kpein   TYPE konv-kpein,
          kmein   TYPE konv-kmein,
          ebeln   TYPE ekko-ebeln,
          netpr   TYPE ekpo-netpr,
          mfrpn   TYPE mara-mfrpn,
          alloc   TYPE ekpo-menge,
          tabix   TYPE sy-tabix,
          anzef   TYPE rm06b-anzef,
          mein1   TYPE ekpo-meins,
          mein2   TYPE ekpo-meins,
          aedat   TYPE ekko-aedat,
          highp   TYPE eipa-preis,
          pwaer   TYPE eipa-bwaer,
          lgort   TYPE ekpo-lgort,
          act01   TYPE zbobottop,
          act02   TYPE zbobottop,
          act03   TYPE zbobottop,
          act04   TYPE zbobottop,
          merge   TYPE zgdmmt004z-merge,
        END OF ty_head.

TYPES : BEGIN OF ty_chk1,
          werks   TYPE ekpo-werks,
          matnr   TYPE ekpo-matnr,
          banfn   TYPE eket-banfn,
        END OF ty_chk1.

TYPES : BEGIN OF ty_data,
          werks   TYPE ekpo-werks,
          matnr   TYPE ekpo-matnr,
          banfn   TYPE eket-banfn,
          bnfpo   TYPE eket-bnfpo,
          eindt   TYPE eket-eindt,
          menge   TYPE eket-menge,
          meins   TYPE ekpo-meins,
        END OF ty_data.

TYPES : BEGIN OF ty_out,
          node_main(50),
          mark,
          icon(4),
          bnfpo   TYPE eket-bnfpo,
          eindt   TYPE eket-eindt,
          menge   TYPE eket-menge,
          meins   TYPE ekpo-meins,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

TYPES : BEGIN OF ty_vendor,
          mark,
          banfn   TYPE eket-banfn,
          bnfpo   TYPE eket-bnfpo,
          zeile   TYPE mseg-zeile,
          lifnr   TYPE ekko-lifnr,
          name1   TYPE lfa1-name1,
          kbetr   TYPE konp-kbetr,
          meins   TYPE ekpo-meins,
          alloc   TYPE ekpo-menge,
          kbetr1  TYPE konp-kbetr,
          revis   TYPE ekpo-menge,
          lgort   TYPE ekpo-lgort,
          split,
        END OF ty_vendor.

TYPES : BEGIN OF ty_zm73,
          lifnr   TYPE elifn,
          harga   TYPE zstvend_eval-harga,
          bobot   TYPE zbobottop,
          sdiff   TYPE zbobottop,
          %aloc   TYPE zbobottop,
        END OF ty_zm73.

TYPES : BEGIN OF ty_004.
        INCLUDE STRUCTURE zgdmmt0004x.
TYPES : xeile   TYPE zgdmmt0004x-zeile,
        END OF ty_004.

TYPES : BEGIN OF ty_lfa1.
        INCLUDE STRUCTURE lfa1.
TYPES :   mfrpn   TYPE mara-mfrpn,
          mfrnr   TYPE mara-mfrnr,
          aplfz   TYPE eine-aplfz,
          kbetr   TYPE konp-kbetr,
          konwa   TYPE konp-konwa,
          kpein   TYPE konp-kpein,
          kmein   TYPE konp-kmein,
          datab   TYPE a018-datab,
          modif,
        END OF ty_lfa1.

TYPES : BEGIN OF ty_sekko,
          lifnr   TYPE ekko-lifnr,
          meins   TYPE ekpo-meins,
          menge   TYPE ekpo-menge,
          total   TYPE ekpo-menge,
        END OF ty_sekko.

TYPES : BEGIN OF ty_text,
          head    TYPE thead,
          line(132),
        END OF ty_text.

TYPES : BEGIN OF ty_actal,
          lifnr   TYPE lfa1-lifnr,
          act01   TYPE zbobottop,
          act02   TYPE zbobottop,
          act03   TYPE zbobottop,
          act04   TYPE zbobottop,
        END OF ty_actal.

TYPES : BEGIN OF ty_material,
          matnr   TYPE mara-matnr,
          werks   TYPE pgmi-werks,
          maktx   TYPE makt-maktx,
        END OF ty_material.

TYPES : BEGIN OF ty_prdgrp,
          matnr   TYPE mara-matnr,
          maktx   TYPE makt-maktx,
        END OF ty_prdgrp.

TYPES : BEGIN OF ty_alloc,
          zalno   TYPE zgdmmt004z-zalno,
        END OF ty_alloc.

TYPES : BEGIN OF ty_graph,
          category(20),
        END OF ty_graph.

TYPES : BEGIN OF ty_label,
          times       TYPE i,
        END OF ty_label.

TYPES : BEGIN OF ty_chart,
          lifnr   TYPE mseg-lifnr,
          banfn   TYPE eban-banfn,
          bnfpo   TYPE eban-bnfpo,
          zeile   TYPE mseg-zeile,
          menge   TYPE ekpo-menge,
          check,
        END OF ty_chart.

TYPES : BEGIN OF ty_aloc,
          lifnr   TYPE a968-lifnr,
          datab   TYPE a968-datab,
          kbetr   TYPE konp-kbetr,
          konwa   TYPE konp-konwa,
        END OF ty_aloc.

TYPES : BEGIN OF ty_pir,
          check,
          zalno   TYPE zgdmmt004z-zalno,
          submi   TYPE ekko-submi,
          ebeln   TYPE ekko-ebeln,
          lifnr   TYPE lfa1-lifnr,
          name1   TYPE lfa1-name1,
          matnr   TYPE makt-matnr,
          maktx   TYPE makt-maktx,
          kstbm   TYPE konm-kstbm,
          konms   TYPE rv13a-konms,
          kbetr   TYPE konm-kbetr,
          skonwa  TYPE rv13a-skonwa,
          kpein   TYPE rv13a-kpein,
          kmein   TYPE rv13a-kmein,
        END OF ty_pir.

DATA gv_plant type ekpo-werks..
CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code           TYPE sy-ucomm,
       dynlog            TYPE smp_dyntxt,
       gs_exclude1       TYPE ui_functions,
       gs_exclude2       TYPE ui_functions,
       g_customcont      TYPE REF TO cl_gui_custom_container,
       g_chartcont       TYPE REF TO cl_gui_custom_container,
       g_splitter        TYPE REF TO cl_gui_splitter_container,
       g_splitter1       TYPE REF TO cl_gui_splitter_container,
       g_splitchart      TYPE REF TO cl_gui_splitter_container,
       g_contain01       TYPE REF TO cl_gui_container,
       g_contain02       TYPE REF TO cl_gui_container,
       g_contain03       TYPE REF TO cl_gui_container,
       g_contain04       TYPE REF TO cl_gui_container,
       g_chartcontain    TYPE REF TO cl_gui_container,
       g_tabgrid01       TYPE REF TO cl_gui_alv_grid,
       g_tabgrid02       TYPE REF TO cl_gui_alv_grid,
       g_tree            TYPE REF TO cl_gui_alv_tree,
       g_chart           TYPE REF TO cl_gui_chart_engine,
       g_header          TYPE treev_hhdr,
       g_docking         TYPE REF TO cl_gui_docking_container,
       event_receiver    TYPE REF TO lcl_application,
       selected          VALUE 'X',
       gv_repid          LIKE sy-repid,
       gv_dynnr          TYPE sy-dynnr,
       gs_variant        LIKE disvariant,
       gs_main_layout    TYPE lvc_s_layo,
       gs_detl_layout    TYPE lvc_s_layo,
       gt_main_sort      TYPE lvc_t_sort WITH HEADER LINE,
       gt_detl_sort      TYPE lvc_t_sort WITH HEADER LINE,
       gt_main_fieldcat  TYPE lvc_t_fcat,
       gt_detl_fieldcat  TYPE lvc_t_fcat,
       gt_label_fieldcat TYPE lvc_t_fcat,
       gt_graph_fieldcat TYPE lvc_t_fcat,
       gs_stable         TYPE lvc_s_stbl,
       gs_toolbar        TYPE stb_button,
       gr_hierseq        TYPE REF TO cl_salv_hierseq_table,
       gr_table          TYPE REF TO cl_salv_table,
       g_handle_alv      TYPE i,
       gt_bapiret2       TYPE STANDARD TABLE OF bapiret2,
       gt_filter         TYPE STANDARD TABLE OF ty_filter.

DATA : gt_out            TYPE STANDARD TABLE OF ty_out,
       gt_xout           TYPE STANDARD TABLE OF ty_out,
       gt_ekko           TYPE STANDARD TABLE OF ekko,
       gt_ekpo           TYPE STANDARD TABLE OF ekpo,
       gt_eket           TYPE STANDARD TABLE OF eket,
       gt_lfa1           TYPE STANDARD TABLE OF ty_lfa1,
       gt_makt           TYPE STANDARD TABLE OF makt,
       gt_eban           TYPE STANDARD TABLE OF eban,
       gt_pgmi           TYPE STANDARD TABLE OF pgmi,
       gt_pgmit          TYPE STANDARD TABLE OF pgmit,
       gs_head           TYPE ty_head,
       gs_quot           TYPE ty_head,
       gs_pr             TYPE ty_head,
       gt_chk1           TYPE STANDARD TABLE OF ty_chk1,
       gt_mess           TYPE STANDARD TABLE OF zhsmmmst002,
       gt_mara           TYPE STANDARD TABLE OF mara,
       gt_lfm1           TYPE STANDARD TABLE OF lfm1,
       gt_t052u          TYPE STANDARD TABLE OF t052u,
       gt_xekko          TYPE STANDARD TABLE OF ekko,
       gt_xekpo          TYPE STANDARD TABLE OF ekpo,
       gt_xeket          TYPE STANDARD TABLE OF eket,
       gt_sekko          TYPE STANDARD TABLE OF ty_sekko,
       gt_text           TYPE STANDARD TABLE OF ty_text.

DATA : gt_vendor         TYPE STANDARD TABLE OF ty_vendor,
       gt_xvendor        TYPE STANDARD TABLE OF ty_vendor,
       gs_vendor         LIKE LINE OF gt_vendor,
       gt_alloc          TYPE STANDARD TABLE OF zmtnt_scor_aloc,
       gt_aloc           TYPE STANDARD TABLE OF ty_aloc,
       gt_splitq         TYPE STANDARD TABLE OF ty_vendor,
       gt_xsplitq        TYPE STANDARD TABLE OF ty_vendor,
       gt_ysplitq        TYPE STANDARD TABLE OF ty_vendor,
       gs_splitq         LIKE LINE OF gt_splitq.

DATA : gs_header         TYPE zgdmmst0051x,
       gt_detail         TYPE STANDARD TABLE OF zgdmmst0052,
       gt_sub            TYPE STANDARD TABLE OF zgdmmst0052,
       gt_lampo          TYPE STANDARD TABLE OF zgdmmst0052,
       gt_xsuppl         TYPE STANDARD TABLE OF zgdmmst002x,
       gt_004            TYPE STANDARD TABLE OF ty_004,
       gt_palloc         TYPE STANDARD TABLE OF zgdmmst002x.

DATA : gt_heads          TYPE STANDARD TABLE OF zgdmmst0056,
       gt_detls          TYPE STANDARD TABLE OF zgdmmst0056,
       gt_texts          TYPE STANDARD TABLE OF zgdmmst0056,
       gt_total          TYPE STANDARD TABLE OF zgdmmst0056.

FIELD-SYMBOLS : <fs_main>       TYPE STANDARD TABLE,
                <fs_detl>       TYPE STANDARD TABLE,
                <fs_lmain>      TYPE ANY,
                <fs_ldetl>      TYPE ANY,
                <fs_tab>        TYPE STANDARD TABLE,
                <fs_graph>      TYPE STANDARD TABLE,
                <fs_sgraph>     TYPE ANY,
                <fs_label>      TYPE STANDARD TABLE,
                <fs_slabel>     TYPE ANY.

DATA : lines    TYPE i,
       fill     TYPE i.

DATA : gr_q1        TYPE RANGE OF datum,
       gr_q2        TYPE RANGE OF datum,
       gr_q3        TYPE RANGE OF datum,
       gr_q4        TYPE RANGE OF datum,
       gv_quarter   TYPE i,
       gv_d1        TYPE sy-datum,
       gv_d2        TYPE sy-datum,
       gv_d3        TYPE sy-datum,
       gv_d4        TYPE sy-datum.

DATA : gv_frgkz     TYPE eban-frgkz,
       gv_filename  TYPE ibipparms-path,
       gv_subrc     TYPE sy-subrc,
       gv_trtyp     TYPE t180-trtyp,
       gv_guname    TYPE seqg3-guname,
       gv_lifnr     TYPE lfa1-lifnr.

DATA : gr_badat     TYPE RANGE OF eban-badat,
       gr_frgkz     TYPE RANGE OF eban-frgkz,
       gr_icon      TYPE RANGE OF icon-id.

DATA : gt_zm73_1    TYPE STANDARD TABLE OF ty_zm73,
       gt_zm73_2    TYPE STANDARD TABLE OF ty_zm73,
       gt_zm73_3    TYPE STANDARD TABLE OF ty_zm73,
       gt_zm73_4    TYPE STANDARD TABLE OF ty_zm73.

DATA : gt_04a       TYPE STANDARD TABLE OF zgdmmt004a,
       gt_04b       TYPE STANDARD TABLE OF zgdmmt004b,
       gt_04c       TYPE STANDARD TABLE OF zgdmmt004c,
       gt_04d       TYPE STANDARD TABLE OF zgdmmt004d,
       gt_04x       TYPE STANDARD TABLE OF zgdmmt004x,
       gt_04y       TYPE STANDARD TABLE OF zgdmmt004y,
       gt_04z       TYPE STANDARD TABLE OF zgdmmt004z,
       gt_04p       TYPE STANDARD TABLE OF zgdmmt004p,
       gt_x04e      TYPE STANDARD TABLE OF zgdmmt004e,
       gt_x04x      TYPE STANDARD TABLE OF zgdmmt004x,
       gt_x04y      TYPE STANDARD TABLE OF zgdmmt004y,
       gt_x04z      TYPE STANDARD TABLE OF zgdmmt004z,
       gt_x04p      TYPE STANDARD TABLE OF zgdmmt004p,
       gt_x04c      TYPE STANDARD TABLE OF zgdmmt004c,
       gs_x04z      TYPE zgdmmt004z,
       gt_05        TYPE STANDARD TABLE OF zhsmmmdt005,
       gt_006       TYPE STANDARD TABLE OF zhsmmmdt006,
       gt_007       TYPE STANDARD TABLE OF zhsmmmdt007.

DATA : line_length      TYPE i VALUE 254,
       line             TYPE i VALUE 132,
       editor_container TYPE REF TO cl_gui_custom_container,
       text_editor      TYPE REF TO cl_gui_textedit,
       text             TYPE string.

DATA : gt_alko      TYPE STANDARD TABLE OF ekko,
       gt_alpo      TYPE STANDARD TABLE OF ekpo,
       gt_xalpo     TYPE STANDARD TABLE OF ekpo.

DATA : gt_actal     TYPE STANDARD TABLE OF ty_actal,
       gs_actal     LIKE LINE OF gt_actal.

DATA : gv_new,
       gv_cursor,
       gv_mail,
       gv_po,
       gv_upload.

DATA : gt_prdgrp    TYPE STANDARD TABLE OF ty_material,
       gt_material  TYPE STANDARD TABLE OF ty_material.

DATA : gv_caption         TYPE string,
       gv_dimension       TYPE string,
       gv_chartyp         TYPE string,
       gv_times           TYPE i,
       gv_menge           TYPE ekpo-menge,
       gv_zalno           TYPE zgdmmt004z-zalno.

DATA : lo_ixml            TYPE REF TO if_ixml,
       lo_ixml_sf         TYPE REF TO if_ixml_stream_factory,
       lo_ixml_data       TYPE REF TO if_ixml_document,
       lo_ixml_custm      TYPE REF TO if_ixml_document,
       lo_ostream         TYPE REF TO if_ixml_ostream,
       lo_xstr            TYPE xstring.

DATA : gt_graph           TYPE STANDARD TABLE OF ty_graph,
       gs_graph           TYPE ty_graph,
       gt_label           TYPE STANDARD TABLE OF ty_label,
       gs_label           TYPE ty_label,
       gt_chart           TYPE STANDARD TABLE OF ty_chart.

DATA : g_value_change.

DATA : gt_eina            TYPE STANDARD TABLE OF eina,
       gt_eine            TYPE STANDARD TABLE OF eine.

DATA : gs_hpir            TYPE ty_pir,
       gt_dpir            TYPE STANDARD TABLE OF ty_pir,
       gs_dpir            TYPE ty_pir,
       gv_upir.
