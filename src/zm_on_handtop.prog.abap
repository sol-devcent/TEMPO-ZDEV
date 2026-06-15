*----------------------------------------------------------------------*
*   INCLUDE ZM_ON_HANDTOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: mard, sscrfields.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: gr_vfdat1   TYPE RANGE OF vfdat,
      gr_vfdat2   TYPE RANGE OF vfdat,
      gr_vfdat3   TYPE RANGE OF vfdat,
      gr_vfdat4   TYPE RANGE OF vfdat,
      gr_vfdat5   TYPE RANGE OF vfdat.

DATA: gr_werks    TYPE RANGE OF werks_d.

DATA: gv_header01(100),
      gv_header02(100),
      gv_header03(100),
      gv_header04(100),
      gv_header05(100).

DATA: t_top_of_page TYPE slis_t_listheader.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_t001w OCCURS 0,
        werks   TYPE werks_d,
      END OF gt_t001w.

DATA: BEGIN OF gt_mara OCCURS 0,
        matnr   TYPE matnr,
        werks   TYPE werks_d,
        lgort   TYPE lgort_d,
        meins   TYPE meins,
        ean11   TYPE ean11,
        bismt   TYPE bismt,
        maktx   TYPE maktx,
      END OF gt_mara.

DATA: BEGIN OF gt_mchb OCCURS 0,
        matnr   TYPE matnr,
        werks   TYPE werks_d,
        lgort   TYPE lgort_d,
        charg   TYPE charg_d,
        lfgja   TYPE lfgja,
        lfmon   TYPE lfmon,
        clabs   TYPE labst,
        cinsm   TYPE insme,
        cspem   TYPE speme,
        vfdat   TYPE vfdat,
      END OF gt_mchb.

DATA: BEGIN OF gt_vdata OCCURS 0,
        matnr   TYPE matnr,
        werks   TYPE werks_d,
        lgort   TYPE lgort_d,
        charg   TYPE charg_d,
        vfdat   TYPE vfdat,
        ean11   TYPE ean11,
        bismt   TYPE bismt,
        maktx   TYPE maktx,
        meins   TYPE meins,
        onhand  TYPE quan3,
        aging1  TYPE quan3,
        aging2  TYPE quan3,
        aging3  TYPE quan3,
        aging4  TYPE quan3,
        aging5  TYPE quan3,
      END OF gt_vdata.

DATA: gt_out  LIKE gt_vdata OCCURS 0 WITH HEADER LINE.
DATA: gt_mean TYPE TABLE OF mean WITH HEADER LINE.
