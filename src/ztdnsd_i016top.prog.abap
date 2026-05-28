*----------------------------------------------------------------------*
***INCLUDE ZTDNSD_I006_TOP .
*----------------------------------------------------------------------*
TYPE-POOLS: slis.

TABLES: s642.
TYPES: BEGIN OF ty_aunr3 ,
         nourut TYPE num10,
         wadat_ist LIKE likp-wadat_ist,
         vstel LIKE likp-vstel,
         kunnr LIKE likp-kunnr,
         lfart LIKE likp-lfart,
         matnr LIKE lips-matnr,
         charg LIKE lips-charg,
         lgort LIKE lips-lgort,
         werks LIKE lips-werks,
         lfimg LIKE lips-lfimg,
         vrkme LIKE lips-vrkme,
         vkbur TYPE vkbur,
      END OF ty_aunr3.
TYPES: BEGIN OF ty_po_all ,
         nourut TYPE num10,
         wadat_ist LIKE likp-wadat_ist,
         "vstel LIKE likp-vstel,
         "kunnr LIKE likp-kunnr,
         "lfart LIKE likp-lfart,
         matnr LIKE lips-matnr,
         "charg LIKE lips-charg,
         lgort LIKE lips-lgort,
         "werks LIKE lips-werks,
         lfimg LIKE lips-lfimg,
         vrkme LIKE lips-vrkme,
         vkbur TYPE vkbur,
         lifnr TYPE lifnr,
      END OF ty_po_all.
TYPES: BEGIN OF ty_point ,
         aunr3  LIKE s642-aunr3,
         sptag  LIKE s642-sptag,
         vstel LIKE s642-vstel,
         matnr LIKE mseg-matnr,
         werks LIKE mseg-werks,
         menge LIKE mseg-menge,
         meins LIKE mseg-meins,
         vkbur TYPE vkbur,
         ebeln LIKE ekpo-ebeln,
      END OF ty_point.
TYPES: BEGIN OF ty_docflow,
         vstel LIKE likp-vstel,
         nourut TYPE num10,
         vbeln  LIKE likp-vbeln,
         aunr3  LIKE s642-aunr3,
         po_int  LIKE s642-po_int,
         doint  LIKE s642-doint,
         aunr2  LIKE s642-aunr2,
         docust LIKE s642-docust,
         vkbur TYPE vkbur,
      END OF ty_docflow.
TYPES: BEGIN OF ty_likp,
        wadat_ist LIKE likp-wadat_ist,
        vbeln LIKE likp-vbeln,
        kunnr LIKE likp-kunnr,
        vstel LIKE likp-vstel,
        lfart LIKE likp-lfart,
        matnr LIKE lips-matnr,
        charg LIKE lips-charg,
        lgort LIKE lips-lgort,
        werks LIKE lips-werks,
        lfimg LIKE lips-lfimg,
        vrkme LIKE lips-vrkme,
        nourut TYPE num10,
        vkbur TYPE vkbur,
        stge_loc LIKE lips-lgort,
      END OF ty_likp.
TYPES: BEGIN OF ty_mseg,
         mblnr LIKE mseg-mblnr,
         mjahr LIKE mseg-mjahr,
         matnr LIKE mseg-matnr,
         charg LIKE mseg-charg,
         menge LIKE mseg-menge,
         meins LIKE mseg-meins,
         shkzg LIKE mseg-shkzg,
         lgort LIKE mseg-lgort,
         werks LIKE mseg-werks,
       END OF ty_mseg.
TYPES: BEGIN OF ty_mblnr,
         mblnr LIKE mseg-mblnr,
       END OF ty_mblnr.
DATA: gt_mblnr TYPE STANDARD TABLE OF ty_mblnr WITH HEADER LINE.
DATA: gt_s642 TYPE STANDARD TABLE OF s642.
DATA: gt_s642_all TYPE STANDARD TABLE OF s642.
DATA: gt_s642_po TYPE STANDARD TABLE OF s642.
DATA: gt_saunr3 TYPE STANDARD TABLE OF s642.
DATA: gt_spoint TYPE STANDARD TABLE OF s642.
DATA: gt_sdoint TYPE STANDARD TABLE OF s642.
DATA: gt_sdocust TYPE STANDARD TABLE OF s642.
DATA: gt_ssocust TYPE STANDARD TABLE OF s642.
DATA: gs_s642 TYPE s642.

RANGES: ra_mblnr FOR mseg-mblnr.
**DATA: rspar_tab           TYPE TABLE OF rsparams,
**      rspar_line          LIKE LINE OF rspar_tab.
DATA: gt_mseg TYPE ty_mseg OCCURS 0 WITH HEADER LINE.
DATA: gs_mseg TYPE ty_mseg.
DATA: gt_lips TYPE STANDARD TABLE OF lips.
DATA: gt_lips2 TYPE STANDARD TABLE OF lips.
DATA: gt_lips3 TYPE STANDARD TABLE OF lips.
DATA: gs_lips TYPE lips.
DATA: gt_likp TYPE ty_likp OCCURS 0 WITH HEADER LINE.
DATA: gs_likp TYPE ty_likp.
DATA: gt_vbuk TYPE vbuk OCCURS 0 WITH HEADER LINE.
DATA: gs_vbuk TYPE vbuk.
DATA: gt_aunr3 TYPE ty_aunr3 OCCURS 0 WITH HEADER LINE.
DATA: gt_docust TYPE ty_aunr3 OCCURS 0 WITH HEADER LINE.
DATA: gs_aunr3 TYPE ty_aunr3.
DATA: gt_po_all TYPE ty_po_all OCCURS 0 WITH HEADER LINE.
DATA: gs_po_all TYPE ty_po_all.
DATA: gt_point TYPE ty_point OCCURS 0 WITH HEADER LINE.
DATA: gs_point TYPE ty_point.

DATA: gt_docflow TYPE ty_docflow OCCURS 0 WITH HEADER LINE.
DATA: gs_docflow TYPE ty_docflow.
DATA: gv_usrtrd.
DATA gv_xruem TYPE xruem.
