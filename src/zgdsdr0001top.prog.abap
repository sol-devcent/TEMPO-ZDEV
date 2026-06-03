*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TABLES: mara,
        vbak,
        vbkd,
        vbap,
        ekko,
        ekpo,
        likp,
        lips.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : BEGIN OF i_matnr OCCURS 0,
         matnr  LIKE  mara-matnr,
         mtart  LIKE  mara-mtart,
       END OF i_matnr.

DATA : BEGIN OF i_so OCCURS 0,
         vkorg  LIKE  vbak-vkorg,
         vkbur  LIKE  vbak-vkbur,
         bstnk  LIKE  vbak-bstnk,
         bstdk  LIKE  vbak-bstdk,
         erdat  LIKE  vbak-erdat,
         vbeln  LIKE  vbak-vbeln,
         kunnr  LIKE  vbak-kunnr,
         posnr  LIKE  vbap-posnr,
         matnr  LIKE  vbap-matnr,
         arktx  LIKE  vbap-arktx,
         kwmeng LIKE  vbap-kwmeng,
         vrkme  LIKE  vbap-vrkme,
         wadat_ist LIKE likp-wadat_ist,
         lfimg  LIKE  lips-lfimg,
         omeng  LIKE  vbbe-omeng,
         bstkd  LIKE  vbkd-bstkd,
       END OF i_so.

DATA : BEGIN OF i_sodelv OCCURS 0,
         vgbel  LIKE  lips-vgbel,
         vgpos  LIKE  lips-vgpos,
         vbeln  LIKE  lips-vbeln,
         posnr  LIKE  lips-posnr,
         wadat_ist LIKE likp-wadat_ist,
         lfimg  LIKE  lips-lfimg,
         fkrel  LIKE  lips-fkrel,
       END OF i_sodelv.

DATA : BEGIN OF i_po OCCURS 0,
*         bukrs  LIKE  ekko-bukrs,
         vkorg  LIKE  ekpv-vkorg,
         reswk  LIKE  ekko-reswk,
         werks  LIKE  ekpo-werks,
         bedat  LIKE  ekko-bedat,
         aedat  LIKE  ekko-aedat,
         ledat  LIKE  ekpv-ledat,
         ebeln  LIKE  ekko-ebeln,
         kunnr  LIKE  ekpv-kunnr,
         ebelp  LIKE  ekpo-ebelp,
         matnr  LIKE  ekpo-matnr,
         txz01  LIKE  ekpo-txz01,
         menge  LIKE  ekpo-menge,
         meins  LIKE  ekpo-meins,
         wadat_ist LIKE likp-wadat_ist,
         lfimg  LIKE  lips-lfimg,
         omeng  LIKE  vbbe-omeng,
         bsart  LIKE  ekko-bsart,
       END OF i_po.

DATA : BEGIN OF i_podelv OCCURS 0,
         vgbel  LIKE  lips-vgbel,
         vgpos  LIKE  lips-vgpos,
         vbeln  LIKE  lips-vbeln,
         posnr  LIKE  lips-posnr,
         wadat_ist LIKE likp-wadat_ist,
         lfimg  LIKE  lips-lfimg,
         fkrel  LIKE  lips-fkrel,
       END OF i_podelv.

DATA : BEGIN OF i_popend OCCURS 0,
         ebeln  LIKE  ekbe-ebeln,
         ebelp  LIKE  ekbe-ebelp,
         zekkn  LIKE  ekbe-zekkn,
         vgabe  LIKE  ekbe-vgabe,
         gjahr  LIKE  ekbe-gjahr,
         belnr  LIKE  ekbe-belnr,
         buzei  LIKE  ekbe-buzei,
         bewtp  LIKE  ekbe-bewtp,
         menge  LIKE  ekbe-menge,
         shkzg  LIKE  ekbe-shkzg,
       END OF i_popend.

DATA : BEGIN OF i_main OCCURS 0,
         vkorg  LIKE  vbak-vkorg,
         vkbur  LIKE  vbak-vkbur,
         docdt  LIKE  vbak-bstdk,
         docno  LIKE  vbak-vbeln,
         kunnr  LIKE  vbak-kunnr,
         name1  LIKE  kna1-name1,
         itmno  LIKE  vbap-posnr,
         matnr  LIKE  vbap-matnr,
         descr  LIKE  vbap-arktx,
         quant  LIKE  vbap-kwmeng,
         uofme  LIKE  vbap-vrkme,
         wadat_ist LIKE likp-wadat_ist,
         lfimg  LIKE  lips-lfimg,
         peqty  LIKE  vbbe-omeng,
         info(3),
         flag(1),
       END OF i_main.

DATA : BEGIN OF i_mainhdr OCCURS 0,
         vkbur  LIKE  vbak-vkbur,
         docno  LIKE  vbak-vbeln,
         itmno  LIKE  vbap-posnr,
*         docpo  LIKE  vbak-bstnk,
         docpo  LIKE  vbkd-bstkd,
         docdt  LIKE  vbak-bstdk,
         entdt  LIKE  vbak-erdat,
         kunnr  LIKE  vbak-kunnr,
         name1  LIKE  kna1-name1,
         matnr  LIKE  vbap-matnr,
         descr  LIKE  vbap-arktx,
         quant  LIKE  vbap-kwmeng,
         uofme  LIKE  vbap-vrkme,
         peqty  LIKE  vbbe-omeng,
         info(3),
         flag(1),
       END OF i_mainhdr.

DATA : BEGIN OF i_maindtl OCCURS 0,
         docno  LIKE  vbak-vbeln,
         itmno  LIKE  vbap-posnr,
         vbeln  LIKE  lips-vbeln,
         wadat_ist LIKE likp-wadat_ist,
         lfimg  LIKE  lips-lfimg,
         text(132),
         info(3),
         flag(1),
       END OF i_maindtl.
