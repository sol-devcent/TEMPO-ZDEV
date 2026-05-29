*&---------------------------------------------------------------------*
*&  Include           ZTDNFI_I003_TOP
*&---------------------------------------------------------------------*
* Define tables
TABLES: vbrp, bsad, kna1, zghfidt001.

* Detail
TYPES: BEGIN OF ty_detail,
         expand   TYPE char1,
         vbeln    TYPE vbrp-vbeln,
         posnr    TYPE vbrp-posnr,
         matnr    TYPE vbrp-matnr,
         arktx    TYPE vbrp-arktx,
         kzwi5    TYPE vbrp-kzwi5,
         mvgr1    TYPE vbrp-mvgr1,
         matkl    TYPE vbrp-matkl,
         discount TYPE zghfidt001-persen,
       END OF ty_detail.

* Header
TYPES: BEGIN OF ty_header,
         expand     TYPE char1,
         vkorg      TYPE zghfidt001-vkorg,
         vkbur      TYPE zghfidt001-vkbur,
         vbeln      TYPE zghfidt001-vbeln,
         zuonr      TYPE bsad-zuonr,
         kunnr      TYPE zghfidt001-kunnr,
         name1      TYPE kna1-name1,
         kzwi5      TYPE zghfidt001-kzwi5,
         waers      TYPE zghfidt001-waers,
         wrbtr      TYPE zghfidt001-wrbtr,
         wrbtr_bsad TYPE bsad-wrbtr,
         hari       TYPE zghfidt001-hari,
         persen     TYPE zghfidt001-persen,
         reward     TYPE zghfidt001-reward,
         knumh      TYPE zghfidt001-knumh,
         knumh_a945 TYPE a945-knumh,
         erdat      TYPE zghfidt001-erdat,
         erzet      TYPE zghfidt001-erzet,
         ernam      TYPE zghfidt001-ernam,
         budat      TYPE bsad-budat,
         wadat_ist  TYPE likp-wadat_ist,
         belnr      TYPE bsad-belnr,
         gjahr      TYPE bsad-gjahr,
       END OF ty_header.
*
TYPES: BEGIN OF ty_bsad,
         expand TYPE char1,
         bukrs  TYPE bsad-bukrs,
         kunnr  TYPE bsad-kunnr,
         umsks  TYPE bsad-umsks,
         umskz  TYPE bsad-umskz,
         augdt  TYPE bsad-augdt,
         augbl  TYPE bsad-augbl,
         zuonr  TYPE bsad-zuonr,
         gjahr  TYPE bsad-gjahr,
         belnr  TYPE bsad-belnr, " Document payment FB03
         buzei  TYPE bsad-buzei,
         budat  TYPE bsad-budat,
         blart  TYPE bsad-blart,
       END OF ty_bsad.
*
TYPES: BEGIN OF ty_likp,
         vbeln     TYPE likp-vbeln,
         wadat_ist TYPE likp-wadat_ist,
       END OF ty_likp.

DATA: header  TYPE TABLE OF ty_header,
      detail  TYPE TABLE OF ty_detail,
      lt_bsad TYPE TABLE OF ty_bsad,
      lt_likp TYPE TABLE OF ty_likp.
