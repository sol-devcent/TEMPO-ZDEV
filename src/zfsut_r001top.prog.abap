*----------------------------------------------------------------------*
*   INCLUDE ZFSUT_R001TOP
*----------------------------------------------------------------------*
INCLUDE <icon>.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: bseg, sscrfields.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
CONSTANTS: gc_vrsio   TYPE vrsio VALUE '000'.

DATA: gv_budat  TYPE budat,
      gv_werks  TYPE werks_d,
      gr_budat  TYPE RANGE OF budat,
      gr_vkbur  TYPE RANGE OF vkbur.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_key OCCURS 0,
        bukrs   TYPE bukrs,
        hkont   TYPE hkont,
      END OF gt_key.

DATA: BEGIN OF gt_zplbc OCCURS 0,
        bukrs   TYPE bukrs,
        werks   TYPE werks_d,
        live    TYPE zlive_indicator,
      END OF gt_zplbc.

DATA: BEGIN OF gt_vdata OCCURS 0,
        bukrs   TYPE bukrs,
        hkont   TYPE hkont,
        augdt   TYPE augdt,
        augbl   TYPE augbl,
        zuonr   TYPE dzuonr,
        gjahr   TYPE gjahr,
        belnr   TYPE belnr_d,
        buzei   TYPE buzei,
        budat   TYPE budat,
        bldat   TYPE bldat,
        waers   TYPE waers,
        xblnr   TYPE xblnr,
  END OF gt_vdata.

DATA: BEGIN OF gt_vdatah OCCURS 0,
        bukrs   TYPE bukrs,
        hkont   TYPE hkont,
        augdt   TYPE augdt,
        augbl   TYPE augbl,
        zuonr   TYPE dzuonr,
        gjahr   TYPE gjahr,
        belnr   TYPE belnr_d,
        buzei   TYPE buzei,
        budat   TYPE budat,
        bldat   TYPE bldat,
        waers   TYPE waers,
        xblnr   TYPE xblnr,
  END OF gt_vdatah.

DATA: BEGIN OF gt_bseg OCCURS 0,
        bukrs   TYPE bukrs,
        belnr   TYPE belnr_d,
        gjahr   TYPE gjahr,
        buzei   TYPE buzei,
        shkzg   TYPE shkzg,
        gsber   TYPE gsber,
        dmbtr   TYPE dmbtr,
        hkont   TYPE hkont,
        matnr   TYPE matnr,
        werks   TYPE werks_d,
        prctr   TYPE prctr,
  END OF gt_bseg.

DATA: BEGIN OF gt_bsegh OCCURS 0,
        bukrs   TYPE bukrs,
        belnr   TYPE belnr_d,
        gjahr   TYPE gjahr,
        buzei   TYPE buzei,
        shkzg   TYPE shkzg,
        gsber   TYPE gsber,
        dmbtr   TYPE dmbtr,
        hkont   TYPE hkont,
        matnr   TYPE matnr,
        werks   TYPE werks_d,
        prctr   TYPE prctr,
  END OF gt_bsegh.

DATA: gt_sum1 LIKE gt_bseg OCCURS 0 WITH HEADER LINE,
      gt_sum2 LIKE gt_bseg OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_tgsbt OCCURS 0,
        gsber   TYPE gsber,
        gtext   TYPE gtext,
      END OF gt_tgsbt.

DATA: BEGIN OF gt_mara OCCURS 0,
        matnr   TYPE matnr,
        matkl   TYPE matkl,
        maktx   TYPE maktx,
      END OF gt_mara.

DATA: BEGIN OF gt_eina OCCURS 0,
        infnr   TYPE infnr,
        matnr   TYPE matnr,
        lifnr   TYPE lifnr,
      END OF gt_eina.

DATA: BEGIN OF gt_lfa1 OCCURS 0,
        lifnr   TYPE lifnr,
        name1   TYPE name1,
      END OF gt_lfa1.

DATA: BEGIN OF gt_s700 OCCURS 0,
        vrsio   TYPE vrsio,
        spmon   TYPE spmon,
        pkunwe  TYPE kunwe,
        matnr   TYPE matnr,
        waerk   TYPE waerk,
        vkorg   TYPE vkorg,
        vkbur   TYPE vkbur,
        totweek TYPE ztotweek,
      END OF gt_s700.

DATA: BEGIN OF gt_s703 OCCURS 0,
        vrsio   TYPE vrsio,
        spmon   TYPE spmon,
        pkunwe  TYPE kunwe,
        matnr   TYPE matnr,
        waerk   TYPE waerk,
        vkbur   TYPE vkbur,
        zoppout TYPE zoppout,
        zcddo   TYPE zcddo,
      END OF gt_s703.

DATA: BEGIN OF gt_out OCCURS 0,
        bukrs   TYPE bukrs,
        gsbert(40),
        gsber   TYPE gsber,
        lifnr   TYPE lifnr,
        name1   TYPE name1,
        matnr   TYPE matnr,
        maktx   TYPE maktx,
        matkl   TYPE matkl,
        prctr   TYPE prctr,
        budat   TYPE budat,
        bldat   TYPE bldat,
        gjahr   TYPE gjahr,
        belnr   TYPE belnr_d,
        buzei   TYPE buzei,
        zuonr   TYPE dzuonr,
        xblnr   TYPE xblnr,
        waers   TYPE waers,
        disca   TYPE dmbtr,
        discb   TYPE dmbtr,
        discc   TYPE dmbtr,
        discd   TYPE dmbtr,
        disce   TYPE dmbtr,
        discf   TYPE dmbtr,
        disvo   TYPE dmbtr,
        total   TYPE dmbtr,
        icon(4),
      END OF gt_out.

DATA: BEGIN OF gt_outs OCCURS 0,
        bukrs   TYPE bukrs,
        gsbert(40),
        gsber   TYPE gsber,
        extwg   TYPE extwg,
        waers   TYPE waers,
        disca   TYPE dmbtr,
        discb   TYPE dmbtr,
        discc   TYPE dmbtr,
        discd   TYPE dmbtr,
        disce   TYPE dmbtr,
        discf   TYPE dmbtr,
        disvo   TYPE dmbtr,
        total   TYPE dmbtr,
        icon(4),
      END OF gt_outs.
