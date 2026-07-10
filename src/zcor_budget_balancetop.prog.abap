*----------------------------------------------------------------------*
*   INCLUDE ZGDMMF0005TOP                                              *
*----------------------------------------------------------------------*
  TABLES: s626,csks,bkpf,zcodt001,sscrfields.

  CLASS lcl_handle_events DEFINITION DEFERRED.

  TYPE-POOLS: slis.

  TYPES: BEGIN OF ty_bseg,
          bukrs TYPE bukrs,
          belnr TYPE belnr_d,
          gjahr TYPE gjahr,
          blart TYPE blart,
          bldat TYPE bldat,
          budat TYPE budat,
          monat TYPE monat,
          cpudt TYPE cpudt,
          cputm TYPE cputm,
          waers TYPE waers,
          buzei TYPE buzei,
          shkzg TYPE shkzg,
          gsber TYPE gsber,
          dmbtr TYPE dmbtr,
          wrbtr TYPE wrbtr,
          kostl TYPE kostl,
          hkont TYPE hkont,
         END OF ty_bseg.

  TYPES: BEGIN OF ty_ebkn,
          banfn TYPE banfn,
          bnfpo TYPE bnfpo,
          werks TYPE ewerk,
          bedat TYPE bedat,
          ebeln TYPE ebeln,
          ebelp TYPE ebelp,
          zebkn TYPE dzebkn,
          sakto TYPE saknr,
          kostl TYPE kostl,
          netwr TYPE bwert,
         END OF ty_ebkn.

  TYPES: BEGIN OF ty_out,
          mark,
          kgrp1   TYPE char50,  "zkgrp1,
          kgrp2   TYPE char50,  "zkgrp2,
          kostl   TYPE kostl,
          khinr   TYPE khinr,
          kstar   TYPE kstar,
          spmon   TYPE spmon,
          twaer   TYPE twaer,
          mtdbud  TYPE mc_umkzwi1,
          mtdact  TYPE mc_umkzwi1,
          mtdcom  TYPE mc_umkzwi1,
          mtdbal  TYPE mc_umkzwi1,
          ytdbud  TYPE mc_umkzwi1,
          ytdact  TYPE mc_umkzwi1,
          ytdcom  TYPE mc_umkzwi1,
          ytdbal  TYPE mc_umkzwi1,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
         END OF ty_out.

  TYPES : BEGIN OF ty_po,
            kstar   TYPE coej-kstar,
            kostl   TYPE csks-kostl,
            ebeln   TYPE ekpo-ebeln,
            ebelp   TYPE ekpo-ebelp,
            bedat   TYPE ekko-bedat,
            txz01   TYPE ekpo-txz01,
            waers   TYPE ekko-waers,
            netwr   TYPE ekpo-netwr,
            grwrb   TYPE ekpo-netwr,
            saldo   TYPE ekpo-netwr,
          END OF ty_po.

  TYPES : BEGIN OF ty_mpo,
            kstar   TYPE coej-kstar,
            kostl   TYPE csks-kostl,
            ebelm   TYPE ekpo-ebeln,
            ebelp   TYPE ekpo-ebelp,
            bedat   TYPE ekko-bedat,
            txz01   TYPE ekpo-txz01,
            waers   TYPE ekko-waers,
            netwr   TYPE ekpo-netwr,
            grwrb   TYPE ekpo-netwr,
            saldo   TYPE ekpo-netwr,
          END OF ty_mpo.

  TYPES : BEGIN OF ty_ypo,
            kstar   TYPE coej-kstar,
            kostl   TYPE csks-kostl,
            ebely   TYPE ekpo-ebeln,
            ebelp   TYPE ekpo-ebelp,
            bedat   TYPE ekko-bedat,
            txz01   TYPE ekpo-txz01,
            waers   TYPE ekko-waers,
            netwr   TYPE ekpo-netwr,
            grwrb   TYPE ekpo-netwr,
            saldo   TYPE ekpo-netwr,
          END OF ty_ypo.

  DATA: gr_alv      TYPE REF TO cl_salv_table,
        gr_function TYPE REF TO cl_salv_functions.

  DATA: g_repid     TYPE sy-repid,
        gt_out      TYPE TABLE OF ty_out,
        gt_zcodt001 TYPE TABLE OF zcodt001 WITH HEADER LINE,
        gt_coej     TYPE TABLE OF coej WITH HEADER LINE,
        gt_csks     TYPE TABLE OF csks WITH HEADER LINE,
        gt_bkpf     TYPE TABLE OF bkpf WITH HEADER LINE,
        gt_bseg     TYPE TABLE OF bseg WITH HEADER LINE,
        gt_ebkn     TYPE TABLE OF ty_ebkn WITH HEADER LINE,
        gr_bedat    TYPE RANGE OF bedat WITH HEADER LINE,
        gr_mbedat   TYPE RANGE OF bedat WITH HEADER LINE,
        gr_ybedat   TYPE RANGE OF bedat WITH HEADER LINE,
        gt_ekko     TYPE TABLE OF ekko WITH HEADER LINE,
        gt_ekpo     TYPE TABLE OF ekpo WITH HEADER LINE,
        gt_ekkn     TYPE TABLE OF ekkn WITH HEADER LINE,
        gt_eket     TYPE TABLE OF eket WITH HEADER LINE.

  DATA : selections TYPE TABLE OF vimsellist.

  FIELD-SYMBOLS: <fs_out>  TYPE ty_out.

  DATA gr_events TYPE REF TO lcl_handle_events.

  DATA gt_fieldcat TYPE slis_t_fieldcat_alv WITH HEADER LINE.

  CLASS : lcl_application DEFINITION DEFERRED.

  DATA : ok_code           TYPE sy-ucomm,
         gs_exclude        TYPE ui_functions,
         g_customcont      TYPE REF TO cl_gui_custom_container,
         g_splitter        TYPE REF TO cl_gui_splitter_container,
         g_splitter1       TYPE REF TO cl_gui_splitter_container,
         g_contain01       TYPE REF TO cl_gui_container,
         g_contain02       TYPE REF TO cl_gui_container,
         g_contain03       TYPE REF TO cl_gui_container,
         g_contain04       TYPE REF TO cl_gui_container,
         g_maingrid        TYPE REF TO cl_gui_alv_grid,
         g_mtdgrid         TYPE REF TO cl_gui_alv_grid,
         g_ytdgrid         TYPE REF TO cl_gui_alv_grid,
         event_receiver    TYPE REF TO lcl_application,
         selected          VALUE 'X',
         gv_repid          LIKE sy-repid,
         gs_variant        LIKE disvariant,
         gs_main_alv       TYPE lvc_s_layo,
         gs_mtd_alv        TYPE lvc_s_layo,
         gs_ytd_alv        TYPE lvc_s_layo,
         gt_main_sort      TYPE lvc_t_sort WITH HEADER LINE,
         gt_mtd_sort       TYPE lvc_t_sort WITH HEADER LINE,
         gt_ytd_sort       TYPE lvc_t_sort WITH HEADER LINE,
         gt_main_fieldcat  TYPE lvc_t_fcat,
         gt_mtd_fieldcat   TYPE lvc_t_fcat,
         gt_ytd_fieldcat   TYPE lvc_t_fcat,
         gs_stable         TYPE lvc_s_stbl,
         gs_toolbar        TYPE stb_button,
         gr_hierseq        TYPE REF TO cl_salv_hierseq_table,
         gr_table          TYPE REF TO cl_salv_table,
         g_handle_alv      TYPE i,
         gt_bapiret2       TYPE STANDARD TABLE OF bapiret2.

  DATA : gt_mpo            TYPE STANDARD TABLE OF ty_mpo,
         gt_ypo            TYPE STANDARD TABLE OF ty_ypo.

  DATA : dynpfields        TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0.

  FIELD-SYMBOLS <fs_tab>   TYPE STANDARD TABLE.
