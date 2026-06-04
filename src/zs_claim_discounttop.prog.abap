*----------------------------------------------------------------------*
*   INCLUDE ZS_CLAIM_DISCOUNTTOP                                       *
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: s626.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
CONSTANTS: c_kappl      LIKE a603-kappl VALUE 'V',
           c_kschl_zclm LIKE a603-kschl VALUE 'ZCLM',
           c_vkorg      LIKE a603-kschl VALUE '8020'.

RANGES: ra_sptag  FOR s626-sptag.

DATA: va_prodh1  LIKE zsts626-prodh1.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF t_vbrk OCCURS 0,
        vbeln LIKE vbrk-vbeln,
        knumv LIKE vbrk-knumv,
        posnr LIKE vbrp-posnr,
        prodh LIKE vbrp-prodh,
        matnr LIKE vbrp-matnr,
        uepos LIKE vbrp-uepos,
      END OF t_vbrk.

DATA: t_konv TYPE TABLE OF konv WITH HEADER LINE.

DATA: BEGIN OF t_s626 OCCURS 0.
        INCLUDE STRUCTURE s626.
      DATA: END OF t_s626.

DATA: BEGIN OF t_kna1 OCCURS 0.
        INCLUDE STRUCTURE kna1.
      DATA: END OF t_kna1.

DATA: BEGIN OF t_makt OCCURS 0.
        INCLUDE STRUCTURE makt.
      DATA: END OF t_makt.

DATA: BEGIN OF t_adrc OCCURS 0.
        INCLUDE STRUCTURE adrc.
      DATA: END OF t_adrc.

DATA: BEGIN OF t_vdata OCCURS 0.
        INCLUDE STRUCTURE zsts626.
      DATA: END OF t_vdata.
DATA: BEGIN OF t_out OCCURS 0.
        INCLUDE STRUCTURE zsts626.
      DATA: END OF t_out.

DATA: BEGIN OF t_dataset OCCURS 0,
        type(2),
        vbeln(10),
        prodh1(3),
        matkl(9),
        matnr(18),
        vkbur(4),
        sptag(8),
        pkunwe(10),
        name1(40),
        maktx(40),
        stwae(5),
        basme(3),
        gross(17),
        qty(15),
        zdisa(13),
        zdisb(13),
        prct1(12),
        zdisc(13),
        prct2(12),
        zdise(13),
        prct3(12),
        zdisf(13),
        prct4(12),
        tdisc(13).
DATA: END OF t_dataset.

DATA: BEGIN OF t_out1 OCCURS 0,
        prodh1 LIKE zsts626-prodh1,
        matkl  LIKE zsts626-matkl,
        matnr  LIKE zsts626-matnr,
        vkbur  LIKE zsts626-vkbur.
DATA: type    LIKE zsts626-type,
      vbeln   LIKE zsts626-vbeln,
      sptag   LIKE zsts626-sptag,
      pkunwe  LIKE zsts626-pkunwe,
      name1   LIKE zsts626-name1,
      maktx   LIKE zsts626-maktx,
      stwae   LIKE zsts626-stwae,
      basme   LIKE zsts626-basme,
      gross   LIKE zsts626-gross,
      qty     LIKE zsts626-qty,
      zdisa   LIKE zsts626-zdisa,
      zdisb   LIKE zsts626-zdisb,
      prct1   LIKE zsts626-prct1,
      zdisc   LIKE zsts626-zdisc,
      prct2   LIKE zsts626-prct1,
      zdise   LIKE zsts626-zdise,
      prct3   LIKE zsts626-prct1,
      zdisf   LIKE zsts626-zdisf,
      prct4   LIKE zsts626-prct1,
      zdisf3  LIKE zsts626-zdisf3,
      prct5   LIKE zsts626-prct1,
      zdisvol LIKE zsts626-zdisvol,
      prct6   LIKE zsts626-prct1,
      tdisc   LIKE zsts626-tdisc.
DATA: END OF t_out1.

DATA: BEGIN OF t_out2 OCCURS 0,
        prodh1 LIKE zsts626-prodh1,
        vkbur  LIKE zsts626-vkbur,
        pkunwe LIKE zsts626-pkunwe,
        vbeln  LIKE zsts626-vbeln,
        matnr  LIKE zsts626-matnr.
DATA: type    LIKE zsts626-type,
      sptag   LIKE zsts626-sptag,
      name1   LIKE zsts626-name1,
      matkl   LIKE zsts626-matkl,
      maktx   LIKE zsts626-maktx,
      stwae   LIKE zsts626-stwae,
      basme   LIKE zsts626-basme,
      gross   LIKE zsts626-gross,
      qty     LIKE zsts626-qty,
      zdisa   LIKE zsts626-zdisa,
      zdisb   LIKE zsts626-zdisb,
      prct1   LIKE zsts626-prct1,
      zdisc   LIKE zsts626-zdisc,
      prct2   LIKE zsts626-prct1,
      zdise   LIKE zsts626-zdise,
      prct3   LIKE zsts626-prct1,
      zdisf   LIKE zsts626-zdisf,
      prct4   LIKE zsts626-prct1,
      zdisf3  LIKE zsts626-zdisf3,
      prct5   LIKE zsts626-prct1,
      zdisvol LIKE zsts626-zdisvol,
      prct6   LIKE zsts626-prct1,
      tdisc   LIKE zsts626-tdisc.
DATA: END OF t_out2.

DATA: BEGIN OF t_out3 OCCURS 0,
        prodh1 LIKE zsts626-prodh1,
        matkl  LIKE zsts626-matkl,
        vkbur  LIKE zsts626-vkbur,
        pkunwe LIKE zsts626-pkunwe,
        matnr  LIKE zsts626-matnr.
DATA: type    LIKE zsts626-type,
      vbeln   LIKE zsts626-vbeln,
      sptag   LIKE zsts626-sptag,
      name1   LIKE zsts626-name1,
      maktx   LIKE zsts626-maktx,
      stwae   LIKE zsts626-stwae,
      basme   LIKE zsts626-basme,
      gross   LIKE zsts626-gross,
      qty     LIKE zsts626-qty,
      zdisa   LIKE zsts626-zdisa,
      zdisb   LIKE zsts626-zdisb,
      prct1   LIKE zsts626-prct1,
      zdisc   LIKE zsts626-zdisc,
      prct2   LIKE zsts626-prct1,
      zdise   LIKE zsts626-zdise,
      prct3   LIKE zsts626-prct1,
      zdisf   LIKE zsts626-zdisf,
      prct4   LIKE zsts626-prct1,
      zdisf3  LIKE zsts626-zdisf3,
      prct5   LIKE zsts626-prct1,
      zdisvol LIKE zsts626-zdisvol,
      prct6   LIKE zsts626-prct1,
      tdisc   LIKE zsts626-tdisc.
DATA: END OF t_out3.

DATA: BEGIN OF vkbur OCCURS 0.
        INCLUDE STRUCTURE rsparams.
      DATA: END OF vkbur.
DATA: BEGIN OF prodh OCCURS 0.
        INCLUDE STRUCTURE rsparams.
      DATA: END OF prodh.
DATA: BEGIN OF matkl OCCURS 0.
        INCLUDE STRUCTURE rsparams.
      DATA: END OF matkl.

DATA  BEGIN OF t_a603 OCCURS 1.
DATA: kappl  LIKE a603-kappl,
      kschl  LIKE a603-kschl,
      vkorg  LIKE a603-vkorg,
      vkbur  LIKE a603-vkbur,
      prodh1 LIKE a603-prodh1,
      prodh2 LIKE a603-prodh2,
      prodh3 LIKE a603-prodh3,
      matnr  LIKE a603-matnr,
      datbi  LIKE a603-datbi,
      datab  LIKE a603-datab,
      knumh  LIKE a603-knumh,
      kbetr  LIKE konp-kbetr.
DATA  END   OF t_a603.
