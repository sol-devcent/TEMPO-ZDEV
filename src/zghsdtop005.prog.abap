*----------------------------------------------------------------------*
*   INCLUDE ZGHSDTOP005                                                *
*----------------------------------------------------------------------*
TABLES : vbrk,bsis,bsad,knvv,kna1,mara.

CONSTANTS: c_kappl LIKE a561-kappl VALUE 'V',
           c_kschl LIKE a561-kschl VALUE 'ZTOP'.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : BEGIN OF gt_branch OCCURS 0,
         vstel  LIKE  tvkol-vstel,
         werks  LIKE  tvkol-werks,
         lgort  LIKE  tvkol-lgort,
         legacy_branch LIKE zplbc-legacy_branch,
         live   LIKE  zplbc-live,
         mixlive  TYPE zmixlive,
       END OF gt_branch.

DATA : BEGIN OF i_cust OCCURS 0,
         kunnr  LIKE  knvv-kunnr,
         vkbur  LIKE  knvv-vkbur,
         vwerk  LIKE  knvv-vwerk,
         zterm  LIKE  knvv-zterm,
         kdgrp  LIKE  knvv-kdgrp,
         name1  LIKE  kna1-name1,
       END OF i_cust.

DATA : BEGIN OF i_vbrk OCCURS 0,
         vkorg  LIKE  vbrk-vkorg,
         gjahr  LIKE  vbrk-gjahr,
         kunrg  LIKE  vbrk-kunrg,
         zuonr  LIKE  vbrk-zuonr,
         fkart  LIKE  vbrk-fkart,
         fkdat  LIKE  vbrk-fkdat,
         vbeln  LIKE  vbrk-vbeln,
       END OF i_vbrk.

DATA : BEGIN OF i_hsales OCCURS 0,
         vkorg  LIKE  zsl_hsales-vkorg,
         plant  LIKE  zsl_hsales-plant,
         vkbur  LIKE  zsl_hsales-vkbur,
         gjahr  LIKE  zsl_hsales-gjahr,
         kunnr  LIKE  zsl_hsales-kunnr,
         vbeln  LIKE  vbrk-zuonr,
         account_no  LIKE  zsl_hsales-account_no,
         fkart  LIKE  zsl_hsales-fkart,
         bldat  LIKE  zsl_hsales-bldat,
         ztop   LIKE  zsl_hsales-ztop,
       END OF i_hsales.

DATA : BEGIN OF i_bsid OCCURS 0,
         kunnr  LIKE  bsid-kunnr,
         zuonr  LIKE  bsid-zuonr,
         zbd1t  LIKE  bsid-zbd1t,
         zfbdt  LIKE  bsid-zfbdt,
         budat  LIKE  bsid-budat,
         wrbtr  LIKE  bsid-wrbtr,
         waers  LIKE  bsid-waers,
         bukrs  LIKE  bsid-bukrs,
         gjahr  LIKE  bsid-gjahr,
         blart  LIKE  bsid-blart,
         belnr  LIKE  bsid-belnr,
         shkzg  LIKE  bsid-shkzg,
         dmbtr  LIKE  bsid-dmbtr,
       END OF i_bsid.

DATA : BEGIN OF i_vbrp OCCURS 0,
         vbeln  LIKE  vbrp-vbeln,
         matkl  LIKE  mara-matkl,
         posnr  LIKE  vbrp-posnr,
         matnr  LIKE  vbrp-matnr,
         kzwi1  LIKE  vbrp-kzwi1,
         netwr  LIKE  vbrp-netwr,
         mwsbp  LIKE  vbrp-mwsbp,
       END OF i_vbrp.

DATA : BEGIN OF i_dsales OCCURS 0,
         vbeln  LIKE  vbrk-zuonr,
         matkl  LIKE  mara-matkl,
         gjahr  LIKE  zsl_dsales-gjahr,
         posnr  LIKE  zsl_dsales-posnr,
         matnr  LIKE  zsl_dsales-matnr,
         nsp    LIKE  zsl_dsales-nsp,

         disa   TYPE  zsl_dsales-disa,
         disb   TYPE  zsl_dsales-disb,
         disc   TYPE  zsl_dsales-disc,
         disd   TYPE  zsl_dsales-disd,
         disdc  TYPE  zsl_dsales-disdc,
         dise   TYPE  zsl_dsales-dise,
         disf   TYPE  zsl_dsales-disf,
         dissp  TYPE  zsl_dsales-dissp,
         disvol TYPE  zsl_dsales-disvol,
         cod    TYPE  zsl_dsales-cod,
       END OF i_dsales.

DATA : BEGIN OF i_vbrpsum OCCURS 0,
         vbeln  LIKE  vbrp-vbeln,
         matkl  LIKE  mara-matkl,
         kzwi1  LIKE  vbrp-kzwi1,
         netwr  LIKE  vbrp-netwr,
         mwsbp  LIKE  vbrp-mwsbp,
       END OF i_vbrpsum.

DATA : BEGIN OF i_dsalessum OCCURS 0,
         zuonr  LIKE  vbrk-zuonr,
         vbeln  LIKE  vbrk-zuonr,
         matkl  LIKE  mara-matkl,
         nsp    LIKE  zsl_dsales-nsp,
         disa   TYPE  z_disa,
         disb   TYPE  z_disb,
         disc   TYPE  z_disc,
         disd   TYPE  z_disd1,
         disdc  TYPE  z_disdc,
         dise   TYPE  z_dise,
         disf   TYPE  z_disf,
         dissp  TYPE  z_dissp,
         disvol TYPE  z_disvol,
         cod    TYPE  z_cod,
       END OF i_dsalessum.

DATA : BEGIN OF i_vbrpmat OCCURS 0,
         vbeln  LIKE  vbrp-vbeln,
         matkl  LIKE  mara-matkl,
         matnr  LIKE  vbrp-matnr,
         kzwi1  LIKE  vbrp-kzwi1,
         netwr  LIKE  vbrp-netwr,
         mwsbp  LIKE  vbrp-mwsbp,
       END OF i_vbrpmat.

DATA : BEGIN OF i_dsalesmat OCCURS 0,
         zuonr  LIKE  vbrk-zuonr,
         vbeln  LIKE  vbrk-zuonr,
         matkl  LIKE  mara-matkl,
         matnr  LIKE  vbrp-matnr,
         nsp    LIKE  zsl_dsales-nsp,
         disa   TYPE  z_disa,
         disb   TYPE  z_disb,
         disc   TYPE  z_disc,
         disd   TYPE  z_disd1,
         disdc  TYPE  z_disdc,
         dise   TYPE  z_dise,
         disf   TYPE  z_disf,
         dissp  TYPE  z_dissp,
         disvol TYPE  z_disvol,
         cod    TYPE  z_cod,
       END OF i_dsalesmat.

DATA : BEGIN OF i_main OCCURS 0,
         vkbur    LIKE  knvv-vkbur,
         kunrg    LIKE  vbrk-kunrg,
         fkart    LIKE  vbrk-fkart,
         fkdat    LIKE  vbrk-fkdat,
         name1    LIKE  kna1-name1,
         zuonr    LIKE  vbrk-zuonr,
         zbd1t    LIKE  bsid-zbd1t,
         zfbdt    LIKE  bsid-zfbdt,
         budat    LIKE  bsid-budat,
         dudat    LIKE  bsid-budat,
         aging    TYPE  i,
         tunda    TYPE  i,
         netval   TYPE  summ9,
         wvalue   TYPE  summ9,
         wdelay   TYPE  p DECIMALS 2,
         payday   TYPE  p DECIMALS 0,
         wpayday  TYPE  p DECIMALS 2,
         doval    LIKE  bsid-wrbtr,
         bival    LIKE  bsid-wrbtr,
         aropn    LIKE  bsid-wrbtr,
         wtval    TYPE  mc_dmbtr,
         waers    LIKE  bsid-waers,
         ztag1    LIKE  t052-ztag1,
         matkl    LIKE  mara-matkl,
         matnr    LIKE  vbrp-matnr,
         maktx    LIKE  makt-maktx,
         belnr    LIKE  bsid-belnr,
         kdgrp    LIKE  knvv-kdgrp,
         rate     TYPE  mc_dmbtr,
         dmbtr    TYPE  dmbtr,
         count    TYPE  i,
         count1   TYPE  i,
         tabindex TYPE  sy-tabix,
         top      TYPE  p DECIMALS 2,
         top1     TYPE  p DECIMALS 2,
         last     TYPE  i,
       END OF i_main.

DATA  BEGIN OF gt_a561 OCCURS 1.
        INCLUDE STRUCTURE a561.
DATA  END   OF gt_a561.

DATA  BEGIN OF gt_konp OCCURS 1.
DATA:   knumh LIKE konp-knumh,
        kopos LIKE konp-kopos,
        zterm LIKE konp-zterm.
DATA  END   OF gt_konp.

DATA: gt_main  LIKE i_main OCCURS 0 WITH HEADER LINE,
      gt_sub   LIKE i_main OCCURS 0 WITH HEADER LINE,
      gt_grand LIKE i_main OCCURS 0 WITH HEADER LINE.

DATA : i_bsad LIKE i_bsid OCCURS 0 WITH HEADER LINE,
       i_custleg LIKE i_cust OCCURS 0 WITH HEADER LINE,
       i_bsidleg LIKE i_bsid OCCURS 0 WITH HEADER LINE,
       i_bsadleg LIKE i_bsid OCCURS 0 WITH HEADER LINE.

DATA: t_zsrate LIKE zsrate OCCURS 0 WITH HEADER LINE.

DATA: gv_count    TYPE i,
      gv_record   TYPE p DECIMALS 0,
      gv_lines    TYPE p DECIMALS 0,
      gv_out      TYPE i,
      gv_vkbur    TYPE vkbur,
      gv_waers    TYPE waers,
      gv_netval   TYPE summ9,
      gv_wvalue   TYPE summ9,
      gv_tunda    TYPE i,
      gv_wdelay   TYPE p DECIMALS 2,
      gv_payday   TYPE p DECIMALS 0,
      gv_top      TYPE p DECIMALS 2,
      gv_last     TYPE i.

DATA: gv_netval1   TYPE summ9,
      gv_wvalue1   TYPE summ9,
      gv_tunda1    TYPE i,
      gv_wdelay1   TYPE p DECIMALS 2,
      gv_payday1   TYPE p DECIMALS 0,
      gv_top1      TYPE p DECIMALS 2.

RANGES: r_saknr FOR skat-saknr.
