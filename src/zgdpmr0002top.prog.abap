*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TABLES: mara,
        iflo,
        imptt,
        imrg,
        mseg,
        t001w.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : BEGIN OF t_mara OCCURS 0,
         matnr  LIKE mara-matnr,
       END OF t_mara.

DATA : BEGIN OF t_mardh OCCURS 0,
         lfgja  LIKE mardh-lfgja,
         lfmon  LIKE mardh-lfmon,
         labst  LIKE mardh-labst,
       END OF t_mardh.

DATA : BEGIN OF t_mseg OCCURS 0,
         mblnr  LIKE mseg-mblnr,
         mjahr  LIKE mseg-mjahr,
         bwart  LIKE mseg-bwart,
         menge  LIKE mseg-menge,
       END OF t_mseg.

DATA : BEGIN OF t_mkpf OCCURS 0,
         mblnr  LIKE mkpf-mblnr,
         mjahr  LIKE mkpf-mjahr,
         bldat  LIKE mkpf-bldat,
         budat  LIKE mkpf-budat,
       END OF t_mkpf.

DATA : BEGIN OF t_iflo OCCURS 0,
         tplnr  LIKE iflo-tplnr,
         pltxt  LIKE iflo-pltxt,
         objnr  LIKE iflo-objnr,
         swerk  LIKE iflo-swerk,
         eqart  LIKE iflo-eqart,
       END OF t_iflo.

DATA : BEGIN OF t_imptt OCCURS 0,
         mpobj  LIKE imptt-mpobj,
         psort  LIKE imptt-psort,
         point  LIKE imptt-point,
         pttxt  LIKE imptt-pttxt,
       END OF t_imptt.

DATA : BEGIN OF t_imrg OCCURS 0,
         point  LIKE imrg-point,
         idate  LIKE imrg-idate,
         mdocm  LIKE imrg-mdocm,
         readg  LIKE imrg-readg,
         recdv  LIKE imrg-recdv,
         recdu  LIKE imrg-recdu,
       END OF t_imrg.

DATA : BEGIN OF t_main OCCURS 0,
         index(6) TYPE n,
*         tplnr    LIKE iflo-tplnr,
         tplnr(60),
         pltxt    LIKE iflo-pltxt,
         objnr    LIKE iflo-objnr,
         point    LIKE imptt-point,
         recdu    LIKE imrg-recdu,
         doc1    LIKE imrg-mdocm,
         use1    TYPE wisp_promo_amount,
         doc2    LIKE imrg-mdocm,
         use2    TYPE wisp_promo_amount,
         doc3    LIKE imrg-mdocm,
         use3    TYPE wisp_promo_amount,
         doc4    LIKE imrg-mdocm,
         use4    TYPE wisp_promo_amount,
         doc5    LIKE imrg-mdocm,
         use5    TYPE wisp_promo_amount,
         doc6    LIKE imrg-mdocm,
         use6    TYPE wisp_promo_amount,
         doc7    LIKE imrg-mdocm,
         use7    TYPE wisp_promo_amount,
         doc8    LIKE imrg-mdocm,
         use8    TYPE wisp_promo_amount,
         doc9    LIKE imrg-mdocm,
         use9    TYPE wisp_promo_amount,
         doc10    LIKE imrg-mdocm,
         use10    TYPE wisp_promo_amount,
         doc11    LIKE imrg-mdocm,
         use11    TYPE wisp_promo_amount,
         doc12    LIKE imrg-mdocm,
         use12    TYPE wisp_promo_amount,
         total    TYPE wisp_promo_amount,"    LIKE mseg-menge,
         info(3),
       END OF t_main.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: wa_genset LIKE t_main,
      wa_boiler LIKE t_main,
      wa_forklift LIKE t_main,
      wa_peminjaman LIKE t_main,
      wa_water LIKE t_main,
      wa_electric LIKE t_main,
      wa_other LIKE t_main,
      wa_other1 LIKE t_main,
      wa_solar  LIKE t_main,
      wa_akhir  LIKE t_main,
      va_text(10),
      p_year(4) TYPE n,
      p_month(2) TYPE n,
      t_mondesc LIKE t247 OCCURS 0 WITH HEADER LINE.

RANGES: r_eqart FOR iflo-eqart.
