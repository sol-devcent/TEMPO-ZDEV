*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TABLES: mara,
        s034,
        makt,
        t001w.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA t_user LIKE usdef OCCURS 10000 WITH HEADER LINE.

DATA: BEGIN OF t_matnr OCCURS 0,
        matnr  LIKE  mara-matnr,
        maktx  LIKE  makt-maktx,
        meins  LIKE  mara-meins,
      END OF t_matnr.

DATA: BEGIN OF t_s035 OCCURS 0,
        matnr  LIKE  s035-matnr,
        werks  LIKE  s035-werks,
        cmbwbest LIKE s035-cmbwbest,
        cwbwbest LIKE s035-cwbwbest,
      END OF t_s035.

DATA: BEGIN OF t_s034 OCCURS 0,
        matnr  LIKE  s034-matnr,
        werks  LIKE  s034-werks,
        cmagbb LIKE  s034-cmagbb,
*        cwzubb like  s034-cwzubb,
        cmzubb LIKE  s034-cmzubb,
      END OF t_s034.

DATA: BEGIN OF t_s931 OCCURS 0,
        matnr  LIKE  s931-matnr,
        werks  LIKE  s931-werks,
        menge  LIKE  s931-menge,
      END OF t_s931.

DATA: BEGIN OF t_s933 OCCURS 0,
        matnr  LIKE  s933-matnr,
        werks  LIKE  s933-werks,
        budat  LIKE  s933-budat,
        aufnr  LIKE  s933-aufnr,
        menge  LIKE  s933-menge,
      END OF t_s933.

DATA: BEGIN OF t_afko OCCURS 0,
        aufnr  LIKE  afko-aufnr,
        plnbez LIKE  afko-plnbez,
        gmein  LIKE  afko-gmein,
        igmng  LIKE  afko-igmng,
        gamng  LIKE  afko-gamng,
      END OF t_afko.

DATA: BEGIN OF t_main OCCURS 0,
        spmon  LIKE  s034-spmon,
        werks  LIKE  s034-werks,
        matnr  LIKE  s034-matnr,
        maktx  LIKE  makt-maktx,
        sawal  LIKE  s034-cmagbb,
        spino(10),
        jumlah LIKE  s931-menge,
        total  LIKE  s931-menge,
        basme  LIKE  s034-basme,
        menge  LIKE  s933-menge,
        budat  LIKE  s933-budat,
        plnbez LIKE  afko-plnbez,
        plnbex LIKE  makt-maktx,
        charg  LIKE  afpo-charg,
        igmng  LIKE  afko-igmng,
        gmein  LIKE  afko-gmein,
        sakhir LIKE  s034-cmagbb,
      END OF t_main.

DATA: BEGIN OF t_mainhdr OCCURS 0,
        spmon  LIKE  s034-spmon,
        werks  LIKE  s034-werks,
        matnr  LIKE  s034-matnr,
        maktx  LIKE  makt-maktx,
        sawal  LIKE  s034-cmagbb,
        spino(10),
        jumlah LIKE  s931-menge,
        total  LIKE  s931-menge,
        basme  LIKE  s034-basme,
      END OF t_mainhdr.

DATA: BEGIN OF t_maindtl OCCURS 0,
        spmon  LIKE  s034-spmon,
        werks  LIKE  s034-werks,
        matnr  LIKE  s034-matnr,
        maktx  LIKE  makt-maktx,
        menge  LIKE  s933-menge,
        budat  LIKE  s933-budat,
        plnbez LIKE  afko-plnbez,
        plnbex LIKE  makt-maktx,
        charg  LIKE  afpo-charg,
        igmng  LIKE  afko-igmng,
        gamng  LIKE  afko-gamng,
        gmein  LIKE  afko-gmein,
        sakhir LIKE  s034-cmagbb,
      END OF t_maindtl.
