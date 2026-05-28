*----------------------------------------------------------------------*
*   INCLUDE ZM_AUTO_DNTOP
*----------------------------------------------------------------------*
INCLUDE <icon>.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: likp, sscrfields.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: gv_vbeln  TYPE vbeln_vl,
      gv_vbnum  TYPE vbnum,
      gv_status TYPE sy-subrc.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_likp OCCURS 0,
        vbeln   TYPE vbeln_vl,
        vstel   TYPE vstel,
        vkorg   TYPE vkorg,
        wadat   TYPE wadak,
      END OF gt_likp.

DATA: BEGIN OF gt_text OCCURS 0,
        vbeln   TYPE vbeln_vl,
        lines   TYPE tdline,
      END OF gt_text.

DATA: BEGIN OF gt_lips OCCURS 0,
        vbeln   TYPE vbeln_vl,
        posnr   TYPE posnr_vl,
        matnr   TYPE matnr,
        charg   TYPE charg_d,
        lfimg   TYPE lfimg,
        vrkme   TYPE vrkme,
        vgbel   TYPE vgbel,
        vgpos   TYPE vgpos,
        uecha   TYPE uecha,
      END OF gt_lips.

DATA: BEGIN OF gt_vbuk OCCURS 0,
        vbeln   TYPE vbeln_vl,
      END OF gt_vbuk.

DATA: BEGIN OF gt_ekpv OCCURS 0,
        ebeln   TYPE ebeln,
        ebelp   TYPE ebelp,
        vstel   TYPE vstel,
      END OF gt_ekpv.

DATA: BEGIN OF gt_batch OCCURS 0,
        ebeln   TYPE ebeln,
        ebelp   TYPE ebelp,
        mblnr   TYPE mblnr,
        menge   TYPE menge_d,
        matnr   TYPE matnr,
        charg   TYPE charg_d,
        posnr   TYPE posnr,
        uecha   TYPE uecha,
      END OF gt_batch.

DATA: BEGIN OF gt_mchb OCCURS 0,
        matnr	  TYPE matnr,
        werks	  TYPE werks_d,
        lgort	  TYPE lgort_d,
        charg	  TYPE charg_d,
        clabs	  TYPE labst,
      END OF gt_mchb.

DATA: BEGIN OF gt_out OCCURS 0.
        INCLUDE STRUCTURE gt_lips.
DATA:   wadat   TYPE wadak,
        vstel   TYPE vstel,
        xblnr   TYPE xblnr,
        dn_no   TYPE mblnr,
        gi_no   TYPE mblnr,
        werks   TYPE werks_d,
        lgort   TYPE lgort_d,
        icon(4),
        check(1),
      END OF gt_out.

DATA: BEGIN OF gt_error OCCURS 0,
        type    TYPE bapi_mtype,
        ebeln   TYPE ebeln,
        msg(100),
      END OF gt_error.
