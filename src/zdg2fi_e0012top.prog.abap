*&---------------------------------------------------------------------*
*&  Include           ZUPLOAD_FORECASTTOP
*&---------------------------------------------------------------------*
TABLES: sscrfields,anla,anlb,anlz,bkpf.

TYPE-POOLS: truxs.

TYPES : BEGIN OF ty_header,
          budat TYPE bkpf-budat,
          bldat TYPE bkpf-bldat,
          xblnr TYPE bkpf-xblnr,
          bktxt TYPE bkpf-bktxt,
          blart TYPE bkpf-blart,
          bukrs TYPE bkpf-bukrs,
          gsber TYPE bseg-gsber,
          waers TYPE bkpf-waers,
        END OF ty_header.

TYPES : BEGIN OF ty_detail,
          icon(4),
          newbs   TYPE rf05a-newbs,
          newko   TYPE rf05a-newko,
          newum   TYPE rf05a-newum,
          newbw   TYPE rf05a-newbw,
          buzei   TYPE bseg-buzei,
          dmbtr   TYPE bseg-dmbtr,
          mwskz   TYPE bseg-mwskz,
          gsber   TYPE bseg-gsber,
          vbund   TYPE bseg-vbund,
          kostl   TYPE bseg-kostl,
          aufnr   TYPE bseg-aufnr,
          prctr   TYPE bseg-prctr,
          werks   TYPE bseg-werks,
          sgtxt   TYPE bseg-sgtxt,
          vkorg   TYPE tvko-vkorg,
          vtweg   TYPE tvtw-vtweg,
          vkbur   TYPE tvbur-vkbur,
          wwsfr   TYPE ce18010-wwsfr,
          wwpfn   TYPE ce18010-wwpfn,
          wwpos   TYPE ce18010-wwpos,
          waers   TYPE bkpf-waers,
          kursf   TYPE bkpf-kursf,
          zuonr   TYPE bseg-zuonr,
          vkgrp   TYPE tvkgr-vkgrp,
          kndnr   TYPE kna1-kunnr,
          artnr   TYPE mara-matnr,
          wwpbr   TYPE ce18010-wwpbr,
          wwpgr   TYPE ce18010-wwpgr,
          wwprc   TYPE ce18010-wwprc,
          spart   TYPE tspa-spart,
          kdgrp   TYPE t151-kdgrp,
          matkl   TYPE mara-matkl,
          wwctp   TYPE ce18010-wwctp,
          extwg   TYPE mara-extwg,
          wwprr   TYPE ce18010-wwprr,
          wwprd   TYPE ce18010-wwprd,
          wwsec   TYPE ce18010-wwsec,
          wwtrz   TYPE ce18010-wwtrz,
          matnr   TYPE bseg-matnr,
          koart   TYPE bseg-koart,
          msgv    TYPE bapiret2-message,
        END OF ty_detail.

TYPES : BEGIN OF ty_data,
          icon(4),
          anln1   TYPE anla-anln1,
          anln2   TYPE anla-anln2,
          txt50   TYPE anla-txt50,
          txa50   TYPE anla-txa50,
          meins   TYPE anla-meins,
          kostl   TYPE anlz-kostl,
          caufn   TYPE anlz-caufn,
          afasl01 TYPE anlb-afasl,
          ndjar01 TYPE anlb-ndjar,
          ndper01 TYPE anlb-ndper,
          afasl10 TYPE anlb-afasl,
          ndjar10 TYPE anlb-ndjar,
          ndper10 TYPE anlb-ndper,
          afabg   TYPE anlb-afabg,
          msgv    TYPE bapiret2-message,
        END OF ty_data.

TYPES : BEGIN OF ty_asset,
          icon(4),
          anln1   TYPE anla-anln1,
          anln2   TYPE anla-anln2,
          anln3   TYPE anla-anln1,
          anln4   TYPE anla-anln2,
          anbtr   TYPE anep-anbtr,
          nbval   TYPE anlcv-bchwrt_gje,
          msgv    TYPE bapiret2-message,
        END OF ty_asset.

TYPES : BEGIN OF ty_exclfield,
          fieldname(30),
        END OF ty_exclfield.

* Refrence Objects To Alv Grid & Custom Container Classes
DATA: g_container        TYPE scrfname VALUE 'CONTAINER',
      g_grid             TYPE REF TO cl_gui_alv_grid,
*      g_handler   TYPE REF TO lcl_event_responder,
*      g_event_handler TYPE REF TO lcl_event_handler,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      g_splitter         TYPE REF TO cl_gui_splitter_container,
      g_contain01        TYPE REF TO cl_gui_container,
      gt_fieldcat        TYPE lvc_t_fcat WITH HEADER LINE,
      gt_sort            TYPE lvc_t_sort WITH HEADER LINE,
      gs_layout          TYPE lvc_s_layo,
      gs_stable          TYPE lvc_s_stbl,
      gv_repid           LIKE sy-repid,
      gs_variant         TYPE disvariant,
      gt_exclude         TYPE ui_functions,
      e_object           TYPE REF TO cl_alv_event_toolbar_set.

DATA: gv_row     TYPE lvc_s_row,
      gv_column  TYPE lvc_s_col,
      gv_row_num TYPE lvc_s_roid.

DATA: dg_dyndoc_id   TYPE REF TO cl_dd_document,
      dg_splitter    TYPE REF TO cl_gui_splitter_container,
      dg_parent_grid TYPE REF TO cl_gui_container,
      dg_html_cntrl  TYPE REF TO cl_gui_html_viewer,
      dg_parent_html TYPE REF TO cl_gui_container.

* OLE data
DATA: h_excel TYPE ole2_object,        " Excel object
      h_mapl  TYPE ole2_object,        " list of workbooks
      h_map   TYPE ole2_object,        " workbook
      h_zl    TYPE ole2_object,        " cell
      h_f     TYPE ole2_object.        " font

DATA: gv_key        TYPE bapi1022_key,
      gv_gendata    TYPE bapi1022_feglg001,
      gv_gendatax   TYPE bapi1022_feglg001x,
      gv_timedep    TYPE bapi1022_feglg003,
      gv_timedepx   TYPE bapi1022_feglg003x,
      gv_inventory  TYPE bapi1022_feglg011,
      gv_inventoryx TYPE bapi1022_feglg011x,
      gv_origin	    TYPE bapi1022_feglg009,
      gv_originx    TYPE bapi1022_feglg009x,
      gv_invest     TYPE bapi1022_feglg010,
      gv_investx    TYPE bapi1022_feglg010x,
      gt_depareas   TYPE TABLE OF bapi1022_dep_areas WITH HEADER LINE,
      gt_depareasx  TYPE TABLE OF bapi1022_dep_areasx WITH HEADER LINE.

DATA: gt_excel    TYPE TABLE OF alsmex_tabline WITH HEADER LINE.
DATA: gt_out      TYPE TABLE OF ztiamfist002 WITH HEADER LINE.
DATA: gv_mode     TYPE char1.    "A=All, E=Error
DATA: gv_post     TYPE char1.
DATA: gv_test     TYPE char1.
DATA: gv_create   TYPE char1.
DATA: gt_tbsl     TYPE STANDARD TABLE OF tbsl.
DATA: gs_003      TYPE ztiamfidt003.

FIELD-SYMBOLS: <fs_out>  TYPE ztiamfist002,
               <fs_out1> TYPE STANDARD TABLE.

FIELD-SYMBOLS: <fs_data> TYPE STANDARD TABLE,
               <fs_line> TYPE any.

DATA : gt_exclfield TYPE STANDARD TABLE OF ty_exclfield,
       gt_header    TYPE STANDARD TABLE OF ty_header,
       gt_detail    TYPE STANDARD TABLE OF ty_detail,
       gt_data      TYPE STANDARD TABLE OF ty_data,
       gt_asset     TYPE STANDARD TABLE OF ty_asset,
       gt_bapiret2  TYPE STANDARD TABLE OF bapiret2,
       gt_anla      TYPE STANDARD TABLE OF anla,
       gt_t095      TYPE STANDARD TABLE OF t095.

DATA : gt_002  TYPE TABLE OF ztiamfist002,
       gt_002n TYPE TABLE OF ztiamfist002n.

DATA : gv_subrc   TYPE sy-subrc,
       gv_end,
       gv_xblnr   TYPE bkpf-xblnr,
       gv_testrun,
       dynlog     TYPE smp_dyntxt,
       ok_code    TYPE sy-ucomm,
       gv_datum   TYPE sy-datum.

DATA : gt_ants   TYPE STANDARD TABLE OF ants,
       gt_anlb   TYPE STANDARD TABLE OF anlb,
       gt_anlbza TYPE STANDARD TABLE OF anlbza,
       gt_anlc   TYPE STANDARD TABLE OF anlc,
       gt_anlz   TYPE STANDARD TABLE OF anlz,
       gt_anea   TYPE STANDARD TABLE OF anea,
       gt_anep   TYPE STANDARD TABLE OF anep.
