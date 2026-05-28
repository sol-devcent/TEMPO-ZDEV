*----------------------------------------------------------------------*
*   INCLUDE ZM_RELEASE_DNTOP
*----------------------------------------------------------------------*
INCLUDE <icon>.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: likp, sscrfields.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_kna1 OCCURS 0,
        kunnr   TYPE kunnr,
        name1   TYPE name1_gp.
DATA  END   OF gt_kna1.

DATA: BEGIN OF gt_mara OCCURS 0,
        matnr   TYPE matnr,
        maktx   TYPE maktx.
DATA  END   OF gt_mara.

DATA: BEGIN OF gt_likp OCCURS 0,
        vbeln   TYPE vbeln_vl,
        vstel   TYPE vstel,
        vkorg   TYPE vkorg,
        kunnr   TYPE kunnr,
        lfart   type lfart.
DATA  END   OF gt_likp.

DATA: BEGIN OF gt_vbuk OCCURS 0,
        vbeln   TYPE vbeln_vl,
        wbstk   TYPE wbstk.
DATA  END   OF gt_vbuk.

DATA: BEGIN OF gt_lips OCCURS 0,
        vbeln   TYPE vbeln_vl,
        posnr   TYPE posnr_vl,
        matnr   TYPE matnr,
        lfimg   TYPE lfimg,
        vrkme   TYPE vrkme,
        kcmeng  TYPE kcmeng.
DATA  END   OF gt_lips.

DATA: gt_zmreldn LIKE zmreldn OCCURS 0 WITH HEADER LINE.
DATA: gv_alkes.

DATA: BEGIN OF gt_out OCCURS 0,
        vbeln   TYPE vbeln_vl,
        kunnr   TYPE kunnr,
        name1   TYPE name1_gp,
        matnr   TYPE matnr,
        maktx   TYPE maktx,
        lfimg   TYPE lfimg,
        vrkme   TYPE vrkme,
        zrelby  TYPE zrelby,
        zreldt  TYPE zreldt,
        zreltm  TYPE zreltm,
        icon(4),
        check(1),
        message(100),
      END OF gt_out.
