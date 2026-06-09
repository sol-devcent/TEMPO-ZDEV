*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TABLES: mara,
        pbim,
        pbid,
        pbed,
        makt,
        t001w,
        tvko,
        tvbur,
        kna1,
        vbrk,
        vbrp,
        vbak,
        ekko,
        ekbe,
        zgdsdkomer.

TYPES: BEGIN OF ta_detail,
         kunag       LIKE vbrk-kunag,
         kunrg       LIKE vbrk-kunag,
         name1       LIKE kna1-name1,
         name2       LIKE kna1-name1,
*      ABPER LIKE BSEG-ABPER,
         abper       LIKE s603-spmon,
         fkdat       LIKE vbrk-fkdat,
         erdat       LIKE vbrk-erdat,
         vkbur       LIKE vbrp-vkbur,
**    For temporary vkbur replaced by werks
         werks       LIKE vbrp-werks,
         matnr       LIKE vbrp-matnr,
         arktx       LIKE vbrp-arktx,
         vgtyp       LIKE vbrp-vgtyp,
         brtwr       LIKE vbrp-brtwr,
         waerk       LIKE vbrk-waerk,
         brtwr_iv    LIKE vbrp-brtwr,
         brtwr_cm    LIKE vbrp-brtwr,
         kbetr       LIKE konv-kbetr,
         kbetr_iv    LIKE konv-kbetr,
         kbetr_cm    LIKE konv-kbetr,
         kwert_val   LIKE konv-kwert,
         kwert_iv    LIKE konv-kwert,
         kwert_cm    LIKE konv-kwert,
         grosls      LIKE vbrp-brtwr,
         netsls      LIKE vbrp-brtwr,
         fkimg       LIKE vbrp-fkimg,
         fkimg_iv    LIKE vbrp-fkimg,
         vrkme       LIKE vbrp-vrkme,
         fkimg_cm    LIKE vbrp-fkimg,
         vbeln       LIKE vbrp-vbeln,
         komernr(16),
         posnr       LIKE vbrp-posnr,
         knumv       LIKE vbrk-knumv,
         kposn       LIKE konv-kposn,
         kwert       LIKE konv-kwert,
         waers       LIKE konv-waers,
         zn01        LIKE konv-kwert,
         zdb3        LIKE konv-kwert,
         zdb4        LIKE konv-kwert,
**      VV819 LIKE CE18010-VV819,
**      RBELN LIKE CE18010-RBELN,
**      RPOSN LIKE CE18010-RPOSN,
**      POSNR LIKE CE18010-POSNR,
         fkdat_d     LIKE vbrk-fkdat,
         fkdat_m     LIKE vbrk-fkdat,
         matkl       LIKE mara-matkl,
         auart       LIKE vbak-auart,
         mwsbp       LIKE vbrk-mwsbk,
         tax         LIKE vbrk-mwsbk,
         ztx1        LIKE vbrk-mwsbk,
         ztx5        LIKE vbrk-mwsbk,
         cntax       LIKE vbrk-mwsbk,
         xblnr       LIKE vbrk-xblnr,
         ebeln       LIKE ekbe-ebeln,
         vbelv       LIKE vbfa-vbelv,
         bsart       LIKE ekko-bsart,
         fkart       LIKE vbrk-fkart,
         sfakn       LIKE vbrk-sfakn,
         fakno       LIKE zgdtxdt0002-fakturno,
         vgbel       LIKE vbrp-vgbel.
TYPES: END OF ta_detail.

TYPES: BEGIN OF ta_cust,
         kunnr LIKE kna1-kunnr,
         name1 LIKE kna1-name1.
TYPES: END OF ta_cust.

TYPES: BEGIN OF ta_konv,
         knumv LIKE konv-knumv,
         kposn LIKE konv-kposn,
         kschl LIKE konv-kschl,
         kwert LIKE konv-kwert,
         kbetr LIKE konv-kbetr,
         waers LIKE konv-waers.
TYPES: END OF ta_konv.

TYPES: BEGIN OF ta_matnr,
         matnr LIKE mara-matnr,
         matkl LIKE mara-matkl.
TYPES: END OF ta_matnr.

DATA: i_hd        TYPE ta_detail OCCURS 0,
      i_dttemp    TYPE ta_detail OCCURS 0,
      i_dt        TYPE ta_detail OCCURS 0,
      i_cust      TYPE ta_cust OCCURS 0,
      i_konv      TYPE ta_konv OCCURS 0 WITH HEADER LINE,
      i_konvsum   TYPE ta_konv OCCURS 0 WITH HEADER LINE,
      i_konvzn01  TYPE ta_konv OCCURS 0 WITH HEADER LINE,
      i_konvzdb3  TYPE ta_konv OCCURS 0 WITH HEADER LINE,
      i_konvzdb4  TYPE ta_konv OCCURS 0 WITH HEADER LINE,
      i_konv2     TYPE ta_konv OCCURS 0 WITH HEADER LINE,
      i_konv2sum  TYPE ta_konv OCCURS 0 WITH HEADER LINE,
      i_konv3     TYPE ta_konv OCCURS 0 WITH HEADER LINE,
      i_matnr     TYPE ta_matnr OCCURS 0,
      wa_hd       TYPE ta_detail,
      wa_dt       TYPE ta_detail,
      wa_cust     TYPE ta_cust,
      wa_konv     TYPE ta_konv,
      wa_konvsum  TYPE ta_konv,
      wa_konv2    TYPE ta_konv,
      wa_konv2sum TYPE ta_konv,
      wa_konv3    TYPE ta_konv,
      wa_matnr    TYPE ta_matnr.


TYPES: BEGIN OF ta_zgdtxdt0002,
         vbeln    LIKE zgdtxdt0002-vbeln,
         fakturno LIKE zgdtxdt0002-fakturno.
TYPES: END OF ta_zgdtxdt0002.

DATA: i_zgdtxdt0002  TYPE ta_zgdtxdt0002 OCCURS 0,
      wa_zgdtxdt0002 TYPE ta_zgdtxdt0002.


TYPES: BEGIN OF ta_komernr,
         vbeln LIKE zgdsdkomer-vbeln,
         invo1 LIKE zgdsdkomer-invo1,
         invo2 LIKE zgdsdkomer-invo2,
         gjahr LIKE zgdsdkomer-gjahr.
TYPES: END OF ta_komernr.

DATA: i_komernr  TYPE ta_komernr OCCURS 0,
      wa_komernr TYPE ta_komernr.


RANGES: r_kschl  FOR konv-kschl,
        r_kschl2 FOR konv-kschl,
        r_kschl3 FOR konv-kschl,
        r_cancl  FOR vbrk-fkart.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: d_month(2)    TYPE n,
      d_month_begin LIKE sy-datum,
      d_month_end   LIKE sy-datum,
      d_plnmg(4).

RANGES: r_versb FOR pbim-versb,
        r_pdatu FOR pbed-pdatu,
        r_pdatu1 FOR pbed-pdatu,
        r_pdatu2 FOR pbed-pdatu,
        r_pdatu3 FOR pbed-pdatu,
        r_pdatu4 FOR pbed-pdatu,
        r_pdatu5 FOR pbed-pdatu.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA t_user LIKE usdef OCCURS 10000 WITH HEADER LINE.

DATA: BEGIN OF t_main OCCURS 0.
DATA: werks  LIKE pbim-werks,
      name1  LIKE t001w-name1,
      versb  LIKE pbim-versb,
      matnr  LIKE pbim-matnr,
      maktx  LIKE makt-maktx,
      bdzei  LIKE pbim-bdzei,
      m01(4),
      m02(4),
      m03(4),
      m04(4),
      m05(4),
      m06(4),
      m07(4),
      m08(4),
      m09(4),
      m10(4),
      m11(4),
      m12(4),
      m13(4),
      m14(4),
      m15(4),
      m16(4),
      m17(4),
      m18(4),
      m19(4),
      m20(4),
      m21(4),
      m22(4),
      m23(4),
      m24(4),
      m25(4),
      m26(4),
      m27(4),
      m28(4),
      m29(4),
      m30(4),
      m31(4),
      mn1(4),
      mn2(4),
      mn3(4),
      mn4(4),
      mn5(4),
      end(7),
      tot    LIKE pbed-plnmg.
DATA: END OF t_main.


DATA: BEGIN OF t_pbed OCCURS 0.
DATA: pdatu LIKE pbed-pdatu,
      bdzei LIKE pbed-bdzei,
      plnmg LIKE pbed-plnmg.
DATA: END OF t_pbed.


DATA: t_main_tmp LIKE t_main OCCURS 0.
