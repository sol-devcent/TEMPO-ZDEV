*&---------------------------------------------------------------------*
*&  Include           ZCORETAX_E004TOP
*&---------------------------------------------------------------------*
TABLES : sscrfields, vbrk, vbrp, likp, vttk, zdg2fidt0008, zmm_cust_rec.

TYPES : BEGIN OF ty_filter,
          index TYPE sy-tabix,
        END OF ty_filter.

TYPES : BEGIN OF ty_008,
          bukrs     TYPE zdg2fidt0008-bukrs,
          bbill     TYPE zdg2fidt0008-bbill,
          bidat     TYPE zdg2fidt0008-bidat,
          monat     TYPE zdg2fidt0008-monat,
          gjahr     TYPE zdg2fidt0008-gjahr,
          zzkdctr   TYPE zdg2fidt0008-zzkdctr,
          zzkunn2   TYPE zdg2fidt0008-zzkunn2,
          kode_ae   TYPE zdg2fidt0008-kode_ae,
          p_name1   TYPE zdg2fidt0008-p_name1,
          zzcur     TYPE zdg2fidt0008-zzcur,
          nilai_dpp TYPE zdg2fidt0008-nilai_dpp,
          nilai_ppn TYPE zdg2fidt0008-nilai_ppn,
        END OF ty_008.

TYPES : BEGIN OF ty_kna1,
          kunnr      TYPE kna1-kunnr,
          name1      TYPE kna1-name1,
          stceg      TYPE kna1-stceg,
          stcd5      TYPE kna1-stcd5,
          gform      TYPE kna1-gform,
          name_co    TYPE adrc-name_co,
          str_suppl1 TYPE adrc-str_suppl1,
          str_suppl2 TYPE adrc-str_suppl2,
          str_suppl3 TYPE adrc-str_suppl3,
          city1      TYPE adrc-city1,
*          stcd1      TYPE kna1-stcd1,
*          stcd3      TYPE kna1-stcd3,
*          counc      TYPE kna1-counc,
*          cityc      TYPE kna1-cityc,
**          stcd5      TYPE kna1-stcd5,
*          stcd6      TYPE kna1-stcd6,
        END OF ty_kna1.

TYPES : BEGIN OF ty_out,
          bukrs         TYPE vbrk-bukrs,
          vkbur         TYPE vbrp-vkbur,
          kunrg         TYPE vbrk-kunrg,
          zzkdctr       TYPE zdg3fidt0008-zzkdctr,
          vbeln         TYPE vbrk-vbeln,
          fkdat         TYPE vbrk-fkdat,
          vgbel         TYPE bseg-zuonr,
          lfdat         TYPE likp-lfdat,
          wadat_ist     TYPE likp-wadat_ist,
          tknum         TYPE vttk-tknum,
          erdat         TYPE vttk-erdat,
          name_co       TYPE adrc-name_co,
          stceg         TYPE kna1-stceg,
          stcd1         TYPE kna1-stcd1,
          stcd3         TYPE kna1-stcd3,
          counc         TYPE kna1-counc,
          cityc         TYPE kna1-cityc,
*          stcd5         TYPE kna1-stcd5,
          nitku         TYPE kna1-stcd5,
          stcd6         TYPE kna1-stcd6,
          txdat         TYPE zmm_cust_rec-txdat,
          taxcode(2),
          waers         TYPE bkpf-waers,
          vatpr         TYPE zfvato-vatpr,
          dppgl         TYPE bseg-wrbtr,
          ppngl         TYPE bseg-wrbtr,
          taxbase       TYPE bseg-wrbtr,
          otaxbase      TYPE bseg-wrbtr,
          vat           TYPE bseg-wrbtr,
          vatrate(2),
          filename(100),
          pdffile(100),
          style         TYPE lvc_t_styl,
          color         TYPE lvc_t_scol,
        END OF ty_out.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code          TYPE sy-ucomm,
       dynlog           TYPE smp_dyntxt,
       gs_exclude       TYPE ui_functions,
       g_customcont     TYPE REF TO cl_gui_custom_container,
       g_splitter       TYPE REF TO cl_gui_splitter_container,
       g_splitter1      TYPE REF TO cl_gui_splitter_container,
       g_contain01      TYPE REF TO cl_gui_container,
       g_contain02      TYPE REF TO cl_gui_container,
       g_contain03      TYPE REF TO cl_gui_container,
       g_contain04      TYPE REF TO cl_gui_container,
       g_tabgrid        TYPE REF TO cl_gui_alv_grid,
       event_receiver   TYPE REF TO lcl_application,
       selected         VALUE 'X',
       gv_repid         LIKE sy-repid,
       gs_variant       LIKE disvariant,
       gs_layout_alv    TYPE lvc_s_layo,
       gt_main_sort     TYPE lvc_t_sort WITH HEADER LINE,
       gt_main_fieldcat TYPE lvc_t_fcat,
       gs_stable        TYPE lvc_s_stbl,
       gs_toolbar       TYPE stb_button,
       gr_hierseq       TYPE REF TO cl_salv_hierseq_table,
       gr_table         TYPE REF TO cl_salv_table,
       g_handle_alv     TYPE i,
       gt_bapiret2      TYPE STANDARD TABLE OF bapiret2,
       gt_filter        TYPE STANDARD TABLE OF ty_filter.

DATA : gt_out         TYPE STANDARD TABLE OF ty_out,
       gt_xout        TYPE STANDARD TABLE OF ty_out,
       gt_zgdtxdt0104 TYPE STANDARD TABLE OF zgdtxdt0104,
*       gt_sd001       TYPE STANDARD TABLE OF zcdssd_001,
       gt_sd002       TYPE STANDARD TABLE OF zcdssd_002,
       gt_sd004       TYPE STANDARD TABLE OF zcdssd_004,
       gt_fi001       TYPE STANDARD TABLE OF zcdsfi_001,
       gt_008         TYPE STANDARD TABLE OF ty_008,
       gt_kna1        TYPE STANDARD TABLE OF ty_kna1,
       gr_hkont       TYPE RANGE OF hkont,
       gr_blart       TYPE RANGE OF blart,
       gt_zfvattrn    TYPE STANDARD TABLE OF zfvattrn.

DATA : gt_likp     TYPE STANDARD TABLE OF likp,
       gt_custrec  TYPE STANDARD TABLE OF zmm_cust_rec,
       gt_zfarsoff TYPE STANDARD TABLE OF zfarsoff.

DATA : gt_010      TYPE STANDARD TABLE OF zcoretax0010.

CONSTANTS : co_dmbtr1 TYPE bseg-dmbtr VALUE 100000,
            co_dmbtr2 TYPE bseg-dmbtr VALUE 200000.

FIELD-SYMBOLS : <fs_out>    TYPE STANDARD TABLE.
