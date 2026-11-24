*----------------------------------------------------------------------*
*   INCLUDE ZF_FKTOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES : sscrfields, tvbur, kna1, vbrk, alpfautoreport.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
CONSTANTS : gc_zfakty   TYPE zfakty VALUE 'FK'.

DATA : gv_filename  TYPE string,
       gv_files(20),
       gv_nomor     TYPE znumber1.

DATA : gv_subrc   TYPE sy-subrc.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
*DATA : gt_out     LIKE zfstefktr_fk OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_out OCCURS 0.
         INCLUDE STRUCTURE zfstefktr_fk.
         DATA :   vkorg TYPE vkorg,
         kvgr3 TYPE kvgr3,
         kunnr TYPE kunnr,
         zuonr TYPE ordnr_v,
       END OF gt_out.
DATA : wa_vdata1 LIKE zfstefktr_fk,
       wa_out    LIKE zfstefktr_fk.

DATA : BEGIN OF gt_of OCCURS 0.
         INCLUDE STRUCTURE zfstefktr_of.
         DATA :   diskonv TYPE wertv8,
         dppv    TYPE wertv8,
         zuonr   TYPE ordnr_v,
         zdueyr  TYPE zdueyr,
       END OF gt_of.
DATA : wa_vdata2 LIKE zfstefktr_of,
       wa_of     LIKE zfstefktr_of.

DATA: BEGIN OF gt_zfvato OCCURS 0.
        INCLUDE STRUCTURE zfvato.
        DATA:  nama_text(255),
      END OF gt_zfvato.
DATA : gt_zfnoefaktur LIKE zfnoefaktur OCCURS 0 WITH HEADER LINE,
       "gt_zfvato       TYPE STANDARD TABLE OF zfvato,
       wa_zfvato      LIKE gt_zfvato.
DATA : gt_zfvatshipbtm TYPE STANDARD TABLE OF zfvatshipbtm,
       wa_zfvatshipbtm TYPE zfvatshipbtm.

DATA : gt_vbfa TYPE STANDARD TABLE OF vbfa,
       wa_vbfa TYPE vbfa.

DATA : gt_zplbc TYPE STANDARD TABLE OF zplbc,
       wa_zplbc LIKE zplbc.

DATA : gt_vatdec TYPE STANDARD TABLE OF zfvat_decimal INITIAL SIZE 0.

DATA : BEGIN OF gt_kna1 OCCURS 0,
         kunnr TYPE kunnr,
         city2 TYPE ad_city2,
         stcd1 TYPE kna1-stcd1,
         cityc TYPE kna1-cityc,
         stceg TYPE kna1-stceg,
       END OF gt_kna1.

DATA : BEGIN OF gt_vbrp OCCURS 0,
         vbeln TYPE vbeln_vf,
         vkorg TYPE vbrk-vkorg,
         posnr TYPE posnr_vf,
         uepos TYPE uepos,
         fkimg TYPE fkimg,
         vrkme TYPE vrkme,
         matnr TYPE matnr,
         arktx TYPE arktx,
         netwr TYPE netwr_fp,
         kvgr3 TYPE vbrp-kvgr3,
         mwsbp TYPE mwsbp,
         upmat TYPE upmat,
         ktgrm TYPE ktgrm,
       END OF gt_vbrp.

DATA : BEGIN OF gt_vbrp2 OCCURS 0,
         vbeln TYPE vbeln_vf,
         vkorg TYPE vbrk-vkorg,
         posnr TYPE posnr_vf,
         uepos TYPE uepos,
         fkimg TYPE fkimg,
         vrkme TYPE vrkme,
         matnr TYPE matnr,
         arktx TYPE arktx,
         netwr TYPE netwr_fp,
         kvgr3 TYPE vbrp-kvgr3,
         mwsbp TYPE mwsbp,
         upmat TYPE upmat,
         ktgrm TYPE ktgrm,
       END OF gt_vbrp2.

DATA : BEGIN OF gt_konv OCCURS 0,
         knumv TYPE knumv,
         kposn TYPE kposn,
         koaid TYPE koaid,
         kschl TYPE kscha,
         kwert TYPE kwert,
         kbetr TYPE kbetr,
         kinak TYPE kinak,
       END OF gt_konv.

DATA : gt_tax   TYPE STANDARD TABLE OF konv.

DATA : BEGIN OF gt_zsl_dsales OCCURS 0,
         vbeln      TYPE vbeln,
         posnr      TYPE posnr,
         matnr      TYPE matnr,
         fkimg      TYPE z_fkimg,
         nsp        TYPE z_nsp,
         ppn        TYPE z_ppn,
         disa       TYPE z_disa,
         disb       TYPE z_disb,
         disc       TYPE z_disc,
         disd       TYPE z_disd1,
         disdc      TYPE z_disdc,
         dise       TYPE z_dise,
         disf       TYPE z_disf,
         disvol     TYPE z_disvol,
         cod        TYPE z_cod,
         kunnr      TYPE zsl_hsales-kunnr,
         account_no TYPE zsl_hsales-account_no,
         taxcode    TYPE zsl_hsales-taxcode,
       END OF gt_zsl_dsales.

DATA : BEGIN OF gt_mseg OCCURS 0,
         mblnr TYPE mblnr,
         mjahr TYPE mjahr,
         zeile TYPE mblpo,
         matnr TYPE matnr,
         menge TYPE menge_d,
         meins TYPE meins,
         dmbtr TYPE dmbtr,
         waers TYPE waers,
         bukrs TYPE bukrs,
         umwrk TYPE umwrk,
       END OF gt_mseg.

DATA : BEGIN OF gt_makt OCCURS 0,
         matnr TYPE matnr,
         maktx TYPE maktx,
         meins TYPE meins.
DATA   END   OF gt_makt.
DATA : gt_maktship  LIKE gt_makt OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_mara OCCURS 0,
         matnr TYPE matnr,
         meins TYPE meins.
DATA   END   OF gt_mara.

DATA : BEGIN OF gt_knvv OCCURS 0,
         kunnr TYPE kunnr,
         kvgr3 TYPE kvgr3.
DATA   END   OF gt_knvv.

DATA : BEGIN OF gt_error OCCURS 0,
         baris    TYPE int4,
         msg(100),
       END OF gt_error.

DATA : BEGIN OF gt_diskon OCCURS 0,
         vbeln      TYPE vbeln,
         ttldis(19),
       END OF gt_diskon.

DATA gt_zftypebpjs TYPE TABLE OF zftypebpjs WITH HEADER LINE.
DATA gt_marc TYPE TABLE OF marc WITH HEADER LINE.

DATA: BEGIN OF gt_vbrk OCCURS 0,
        vbeln	TYPE vbeln_vf,
        fkart	TYPE fkart,
        vkorg	TYPE vkorg,
        posnr	TYPE posnr_vf,
        vbelv	TYPE vbelv,
        posnv	TYPE posnv,
        vgbel	TYPE vgbel,
        vgpos	TYPE vgpos,
        aubel	TYPE vbeln_va,
        aupos	TYPE posnr_va,
        vkbur	TYPE vkbur,
      END OF gt_vbrk,

      BEGIN OF gt_zfvat OCCURS 0,
        vkorg	TYPE vkorg,
        vkbur	TYPE vkbur,
        vatno	TYPE zvano,
        vbeln	TYPE vbeln_vf,
        zuonr	TYPE ordnr_v,
        dueyr	TYPE zdueyr,
        fkart	TYPE fkart,
        vbelv	TYPE vbelv,
      END OF gt_zfvat,

      BEGIN OF gt_vbak OCCURS 0,
        vbeln	TYPE vbeln_va,
        auart	TYPE auart,
      END OF gt_vbak.

DATA : gt_vbkd    TYPE STANDARD TABLE OF vbkd.

DATA : gr_vkburi TYPE RANGE OF vkbur,
       gr_vkbure TYPE RANGE OF vkbur.

DATA : gv_tds.

DATA : gs_dpp   TYPE zproject.
