*----------------------------------------------------------------------*
*   INCLUDE ZS_OOS_REPORTTOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES : sscrfields, vbak, vbkd, vbap, mara, mvke.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA : ref_grid   TYPE REF TO cl_gui_alv_grid,
       gv_waers   LIKE t001-waers.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : BEGIN OF gt_makt OCCURS 0,
         matnr   TYPE matnr,
         maktx   TYPE maktx,
         matkl   TYPE matkl,
       END OF gt_makt.

DATA : BEGIN OF gt_kna1 OCCURS 0,
         kunnr   TYPE kunnr,
         name1   TYPE name1_gp,
       END OF gt_kna1.

DATA : BEGIN OF gt_mvke OCCURS 0,
         matnr   TYPE matnr,
       END OF gt_mvke.

DATA : BEGIN OF gt_mara OCCURS 0,
         matnr   TYPE matnr,
       END OF gt_mara.

DATA : BEGIN OF gt_marc OCCURS 0,
         matnr   TYPE matnr,
         werks   TYPE werks_d,
       END OF gt_marc.

DATA : BEGIN OF gt_quotation OCCURS 0,
         vbeln   TYPE vbeln_va,
         posnr   TYPE posnr_va,
         vkbur   TYPE vkbur,
         matnr   TYPE matnr,
         abgru   TYPE abgru_va,
         erdat   TYPE erdat,
         bstnk   TYPE bstnk,
         bstdk   TYPE bstdk,
         knkli   TYPE knkli,
         kvgr4   TYPE kvgr4,
         waerk   TYPE waerk,
         kwmeng  TYPE kwmeng,
         vrkme   TYPE vrkme,
         kzwi1   TYPE kzwi1,
         kdgrp   TYPE kdgrp,
         kvgr3   TYPE kvgr3,
         fonds   TYPE bp_geber,
         fistl   TYPE fistl,
       END OF gt_quotation.

DATA : BEGIN OF gt_sales OCCURS 0,
         vbeln   TYPE vbeln_va,
         vgbel   TYPE vgbel,
         posnr   TYPE posnr_va,
         vgpos   TYPE vgpos,
         abgru   TYPE abgru_va,
         waerk   TYPE waerk,
         kwmeng  TYPE kwmeng,
         vrkme   TYPE vrkme,
         kzwi1   TYPE kzwi1,
         fonds   TYPE bp_geber,
         fistl   TYPE fistl,
       END OF gt_sales.

DATA : BEGIN OF gt_vbuk OCCURS 0,
         vbeln   TYPE vbeln,
         cmgst   TYPE cmgst,
       END OF gt_vbuk.

DATA : BEGIN OF gt_vbup OCCURS 0,
         vbeln   TYPE vbeln,
         posnr   TYPE posnr,
         besta   TYPE besta,
         lfsta   TYPE lfsta,
       END OF gt_vbup.

DATA : BEGIN OF gt_delivery OCCURS 0,
         vbeln   TYPE vbeln_vl,
         posnr   TYPE posnr_vl,
         erdat   TYPE erdat,
         vgbel   TYPE vgbel,
         vgpos   TYPE vgpos,
         matnr   TYPE matnr,
         arktx   TYPE arktx,
       END OF gt_delivery.

DATA : BEGIN OF gt_out OCCURS 0,
         vkbur   TYPE vkbur,
         vbeln   TYPE vbeln_va,
         erdat   TYPE erdat,
         bstnk   TYPE bstnk,
         bstdk   TYPE bstdk,
         matnr   TYPE matnr,
         maktx   TYPE maktx,
         vrkme   TYPE vrkme,
         kwmeng  TYPE kwmeng,
         waerk   TYPE waerk,
         kzwi1   TYPE kzwi1,
         knkli   TYPE knkli,
         name1   TYPE name1_gp,
         kdgrp   TYPE kdgrp,
         kvgr3   TYPE kvgr3,
         kvgr4   TYPE kvgr4,
         dlnum   TYPE vbeln_vl,
         dldat   TYPE erdat,
         dlmat   TYPE matnr,
         dlmatx  TYPE maktx,
         dlvrkm  TYPE vrkme,
         dlqty   TYPE lfimg,
         dlwae   TYPE waerk,
         dlval   TYPE kzwi1,
         disqty  TYPE kwmeng,
         disval  TYPE kzwi1,
         othqty  TYPE kwmeng,
         othval  TYPE kzwi1,
         oosqty  TYPE kwmeng,
         oosval  TYPE kzwi1,
         losqty  TYPE kwmeng,
         losval  TYPE kzwi1,
         cltopq  TYPE kwmeng,
         cltopv  TYPE kzwi1,
         abgru   TYPE abgru_va,
         bezei   TYPE bezei40,
         matkl   LIKE mara-matkl,
         prdha   LIKE mara-prdha,
         prdh1(3),
         prdh2(3),
         prdh3(3),
       END OF gt_out.

DATA : BEGIN OF gt_tvkol OCCURS 0,
         vstel   LIKE tvkol-vstel,
         werks   LIKE tvkol-werks,
         lgort   LIKE tvkol-lgort,
       END OF gt_tvkol.

DATA : gt_zsd_po  LIKE zsd_po OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_kna1leg OCCURS 0,
         kunnr   LIKE kna1-kunnr,
         name1   LIKE kna1-name1,
         kdgrp   LIKE knvv-kdgrp,
         kvgr3   LIKE knvv-kvgr3,
         kvgr4   LIKE knvv-kvgr4,
       END OF gt_kna1leg.

DATA : BEGIN OF gt_maktleg OCCURS 0,
         matnr   LIKE makt-matnr,
         maktx   LIKE makt-maktx,
       END OF gt_maktleg.
