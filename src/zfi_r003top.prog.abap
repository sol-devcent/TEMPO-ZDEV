*&---------------------------------------------------------------------*
*&  Include           ZFI_R003TOP
*&---------------------------------------------------------------------*
TABLES : sscrfields, vbak, knvv, kna1, likp, vbrk, zfppnnrh, zfarpotd,
         bsid.

TYPES : BEGIN OF ty_filter,
          index   TYPE sy-tabix,
        END OF ty_filter.

TYPES : BEGIN OF ty_kna1,
          kunnr   TYPE kna1vv-kunnr,
          name1   TYPE kna1vv-name1,
          vkorg   TYPE kna1vv-vkorg,
          vkbur   TYPE kna1vv-vkbur,
          kdgrp   TYPE kna1vv-kdgrp,
        END OF ty_kna1.

TYPES : BEGIN OF ty_vbfa,
          vbelv   TYPE vbfa-vbelv,
          vbeln   TYPE vbfa-vbeln,
          vbtyp_n TYPE vbfa-vbtyp_n,
          vbtyp_v TYPE vbfa-vbtyp_v,
          erdat   TYPE vbfa-erdat,
          erzet   TYPE vbfa-erzet,
        END OF ty_vbfa.

TYPES : BEGIN OF ty_vbak,
          vbeln   TYPE vbak-vbeln,
          erdat   TYPE vbak-erdat,
          erzet   TYPE vbak-erzet,
          auart   TYPE vbak-auart,
          netwr   TYPE vbak-netwr,
          waerk   TYPE vbak-waerk,
          vkbur   TYPE vbak-vkbur,
          bstnk   TYPE vbak-bstnk,
          bstdk   TYPE vbak-bstdk,
          kunnr   TYPE vbak-kunnr,
          knkli   TYPE vbak-knkli,
        END OF ty_vbak.

TYPES : BEGIN OF ty_vbap,
          vbeln   TYPE vbap-vbeln,
          posnr   TYPE vbap-posnr,
          mwsbp   TYPE vbap-mwsbp,
        END OF ty_vbap.

TYPES : BEGIN OF ty_likp,
          vbeln   TYPE likp-vbeln,
          erdat   TYPE likp-erdat,
          erzet   TYPE likp-erzet,
          fkdat   TYPE likp-fkdat,
          kodat   TYPE likp-kodat,
        END OF ty_likp.

TYPES : BEGIN OF ty_vbrk,
          vbeln   TYPE vbrk-vbeln,
          fkdat   TYPE vbrk-fkdat,
          erzet   TYPE vbrk-erzet,
          netwr   TYPE vbrk-netwr,
          mwsbk   TYPE vbrk-mwsbk,
          waerk   TYPE vbrk-waerk,
          kunag   TYPE vbrk-kunag,
        END OF ty_vbrk.

TYPES : BEGIN OF ty_fidoc,
          zuonr	  TYPE bsid-zuonr,
          kunnr	  TYPE bsid-kunnr,
        END OF ty_fidoc.

TYPES : BEGIN OF ty_arpot,
          bukrs   TYPE zfarpotd-bukrs,
          vkbur   TYPE zfarpotd-vkbur,
          kunnr   TYPE zfarpotd-kunnr,
          rtvnr   TYPE zfarpotd-rtvnr,
        END OF ty_arpot.

TYPES : BEGIN OF ty_bi,
          zuonr	  TYPE bsid-zuonr,
          kunnr	  TYPE bsid-kunnr,
          bbeln   TYPE zfbih_sfa-bbeln,
          bidat   TYPE zfbih-bidat,
          bflag   TYPE zfbid-bflag,
          ptype   TYPE zfbid-ptype,
        END OF ty_bi.

TYPES : BEGIN OF ty_bsid,
          bukrs	  TYPE bsid-bukrs,
          kunnr	  TYPE bsid-kunnr,
          umsks	  TYPE bsid-umsks,
          umskz	  TYPE bsid-umskz,
          augdt	  TYPE bsid-augdt,
          augbl	  TYPE bsid-augbl,
          zuonr	  TYPE bsid-zuonr,
          gjahr	  TYPE bsid-gjahr,
          belnr	  TYPE bsid-belnr,
          buzei	  TYPE bsid-buzei,
          budat	  TYPE bsid-budat,
          bldat	  TYPE bsid-bldat,
        END OF ty_bsid.

TYPES : BEGIN OF ty_zfarpotd,
          bukrs   TYPE zfarpotd-bukrs,
          gsber   TYPE zfarpotd-gsber,
          vkbur   TYPE zfarpotd-vkbur,
          noarp   TYPE zfarpotd-noarp,
          mjahr   TYPE zfarpotd-mjahr,
          posnr   TYPE zfarpotd-posnr,
          kunnr   TYPE zfarpotd-kunnr,
          rtvtyp  TYPE zfarpotd-rtvtyp,
          rtvnr   TYPE zfarpotd-rtvnr,
          rtvdt   TYPE zfarpotd-rtvdt,
        END OF ty_zfarpotd.

TYPES : BEGIN OF ty_zfppnnrd,
          vrsio	  TYPE zfppnnrd-vrsio,
          bukrs	  TYPE zfppnnrd-bukrs,
          vkbur	  TYPE zfppnnrd-vkbur,
          belnr	  TYPE zfppnnrd-belnr,
          zuonr	  TYPE zfppnnrd-zuonr,
          kunnr	  TYPE zfppnnrd-kunnr,
          monat	  TYPE zfppnnrd-monat,
          gjahr	  TYPE zfppnnrd-gjahr,
          nonr    TYPE zfppnnrd-nonr,
          nrdt    TYPE zfppnnrd-nrdt,
        END OF ty_zfppnnrd.

TYPES : BEGIN OF ty_zfbih6,
          bukrs	  TYPE zfbih-bukrs,
          vkbur	  TYPE zfbih-vkbur,
          bbeln	  TYPE zfbih-bbeln,
          bidat	  TYPE zfbih-bidat,
        END OF ty_zfbih6.

TYPES : BEGIN OF ty_zfbid6,
          bukrs	  TYPE zfbid-bukrs,
          vkbur	  TYPE zfbid-vkbur,
          bbeln	  TYPE zfbid-bbeln,
          ebelp	  TYPE zfbid-ebelp,
          vbeln	  TYPE zfbid-vbeln,
          zuonr	  TYPE zfbid-zuonr,
          gsber	  TYPE zfbid-gsber,
          kunnr	  TYPE zfbid-kunnr,
          bflag   TYPE zfbid-bflag,
          ptype   TYPE zfbid-ptype,
        END OF ty_zfbid6.

TYPES : BEGIN OF ty_zfbih7,
          bukrs	  TYPE zfbih_sfa-bukrs,
          vkbur	  TYPE zfbih_sfa-vkbur,
          bbeln	  TYPE zfbih_sfa-bbeln,
          bidat	  TYPE zfbih_sfa-bidat,
        END OF ty_zfbih7.

TYPES : BEGIN OF ty_zfbid7,
          bukrs	  TYPE zfbid_sfa-bukrs,
          vkbur	  TYPE zfbid_sfa-vkbur,
          bbeln	  TYPE zfbid_sfa-bbeln,
          ebelp	  TYPE zfbid_sfa-ebelp,
          vbeln	  TYPE zfbid_sfa-vbeln,
          zuonr	  TYPE zfbid_sfa-zuonr,
          gsber	  TYPE zfbid_sfa-gsber,
          kunnr	  TYPE zfbid_sfa-kunnr,
          bflag   TYPE zfbid_sfa-bflag,
          ptype   TYPE zfbid_sfa-ptype,
        END OF ty_zfbid7.

TYPES : BEGIN OF ty_out,
          mark,
          icon(4),
          vkbur   TYPE vbak-vkbur,
          kdgrp   TYPE knvv-kdgrp,
          ktext   TYPE t151t-ktext,
          kunnr   TYPE vbak-kunnr,
          name1   TYPE kna1-name1,
          knkli   TYPE vbak-knkli,
          name2   TYPE kna1-name1,
          auart   TYPE vbak-auart,
          total   TYPE komp-netwr,
          dppcn   TYPE komp-netwr,
          ppncn   TYPE komp-netwr,
          waerk   TYPE komk-waerk,
          rtvnr   TYPE zfarpotd-rtvnr,
          rtvdt   TYPE zfarpotd-rtvdt,
          bstnk   TYPE vbak-bstnk,
          bstdk   TYPE vbak-bstdk,
          vbeva   TYPE vbak-vbeln,
          erdva   TYPE vbak-erdat,
          erzva   TYPE vbak-erzet,
          vbevl   TYPE likp-vbeln,
          erdvl   TYPE likp-erdat,
          erzvl   TYPE likp-erzet,
          vbevf   TYPE vbrk-vbeln,
          fkdat   TYPE vbrk-fkdat,
          erzvf   TYPE vbrk-erzet,
          refdo   TYPE vbak-vbeln,
          refdt   TYPE vbak-erdat,
          vatpr   TYPE zfppnnrh-vatpr1,
          vatdt(10),
          noarp   TYPE zfarpotd-noarp,
          style   TYPE lvc_t_styl,
          color   TYPE lvc_t_scol,
        END OF ty_out.

CLASS : lcl_application DEFINITION DEFERRED.

DATA : ok_code           TYPE sy-ucomm,
       dynlog            TYPE smp_dyntxt,
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
       gt_filter         TYPE STANDARD TABLE OF ty_filter.

DATA : gt_out            TYPE STANDARD TABLE OF ty_out,
       gt_xout           TYPE STANDARD TABLE OF ty_out,
       gt_vbfa           TYPE STANDARD TABLE OF ty_vbfa,
       gt_kna1           TYPE STANDARD TABLE OF ty_kna1,
       gt_zfarpotd       TYPE STANDARD TABLE OF ty_zfarpotd,
       gt_vbak           TYPE STANDARD TABLE OF ty_vbak,
       gt_vbap           TYPE STANDARD TABLE OF ty_vbap,
       gt_likp           TYPE STANDARD TABLE OF ty_likp,
       gt_vbrk           TYPE STANDARD TABLE OF ty_vbrk,
       gt_t151t          TYPE STANDARD TABLE OF t151t,
       gt_zfppnnrd       TYPE STANDARD TABLE OF ty_zfppnnrd,
       gt_bsid           TYPE STANDARD TABLE OF ty_bsid,
       gt_fidoc          TYPE STANDARD TABLE OF ty_fidoc,
       gt_bi             TYPE STANDARD TABLE OF ty_bi,
       gt_arpot          TYPE STANDARD TABLE OF ty_arpot.

DATA : gr_auart          TYPE RANGE OF auart,
       gr_vbtyp          TYPE RANGE OF vbtyp_n,
       gr_vbtva          TYPE RANGE OF vbtyp_n,
       gr_vbtvl          TYPE RANGE OF vbtyp_n,
       gr_vbtvf          TYPE RANGE OF vbtyp_n.

DATA : gv_count          TYPE i.

FIELD-SYMBOLS : <fs_out>    TYPE STANDARD TABLE,
                <fs_tab>    TYPE STANDARD TABLE,
                <fs_line>   TYPE ANY.
