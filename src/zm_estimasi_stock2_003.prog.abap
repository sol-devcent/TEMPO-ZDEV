*----------------------------------------------------------------------*
*   INCLUDE ZGHMMTOP001                                                *
*----------------------------------------------------------------------*
TABLES : t001w,mard,mb_mdbs,s039,s931,makt,mara,s603.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : BEGIN OF i_werks OCCURS 0,
         werks LIKE  t001w-werks,
         name1 LIKE  t001w-name1,
       END OF i_werks.

DATA : BEGIN OF i_vkbur OCCURS 0,
         vkbur LIKE  tvkbt-vkbur,
         bezei LIKE  tvkbt-bezei,
       END OF i_vkbur.

DATA : BEGIN OF i_makt OCCURS 0,
         matnr LIKE  makt-matnr,
         maktx LIKE  makt-maktx,
         meins LIKE  mara-meins,
         matkl LIKE  mara-matkl,
         zeinr LIKE  mara-zeinr,
         zeiar LIKE  mara-zeiar,
         nfmat LIKE  marc-nfmat,
         kzaus LIKE  marc-kzaus,
       END OF i_makt.

DATA : BEGIN OF i_marc OCCURS 0,
         matnr LIKE  marc-matnr,
         werks LIKE  marc-werks,
         umlmc LIKE  marc-umlmc,
         kausf LIKE  marc-kausf,
         lfgja LIKE  marc-lfgja,
         lfmon LIKE  marc-lfmon,
         maabc LIKE  marc-maabc,
       END OF i_marc.

DATA : BEGIN OF i_march OCCURS 0,
         matnr LIKE  march-matnr,
         werks LIKE  march-werks,
         umlmc LIKE  march-umlmc,
         lfgja LIKE  march-lfgja,
         lfmon LIKE  march-lfmon,
       END OF i_march.

DATA : BEGIN OF i_mard OCCURS 0,
         matnr LIKE  mard-matnr,
         werks LIKE  mard-werks,
         lgort LIKE  mard-lgort,
         labst LIKE  mard-labst,
         insme LIKE  mard-insme,
         speme LIKE  mard-speme,
         exppg LIKE  mard-exppg,
       END OF i_mard.

DATA : BEGIN OF i_mdbs OCCURS 0,
         matnr LIKE  mb_mdbs-matnr,
         werks LIKE  mb_mdbs-werks,
         lgort LIKE  mb_mdbs-lgort,
         bsart LIKE  ekko-bsart,
         bstyp LIKE  mb_mdbs-bstyp,
         ebeln LIKE  mb_mdbs-ebeln,
         ebelp LIKE  mb_mdbs-ebelp,
         bedat LIKE  mb_mdbs-bedat,
         menge LIKE  mb_mdbs-menge,
         wemng LIKE  mb_mdbs-wemng,
         wamng LIKE  mb_mdbs-wamng,
         glmng LIKE  mb_mdbs-glmng,
       END OF i_mdbs.

DATA : BEGIN OF i_s039 OCCURS 0,
         matnr   LIKE  s039-matnr,
         werks   LIKE  s039-werks,
         lgort   LIKE  s039-lgort,
         gsbest  LIKE  s039-gsbest,
         mbwbest LIKE  s039-mbwbest,
       END OF i_s039.

DATA : BEGIN OF i_s931 OCCURS 0,
         matnr LIKE  s931-matnr,
         werks LIKE  s931-werks,
         lgort LIKE  s931-lgort,
         menge LIKE  s931-menge,
       END OF i_s931.

DATA : BEGIN OF i_s611 OCCURS 0,
         matnr   LIKE  s611-matnr,
         werks   LIKE  s611-werks,
         ummenge LIKE s611-ummenge,
         gumenge LIKE s611-gumenge,
       END OF i_s611.

DATA : BEGIN OF i_s603 OCCURS 0,
         matnr   LIKE  s603-matnr,
         vkbur   LIKE  s603-vkbur,
         ummenge LIKE s603-ummenge,
         gumenge LIKE s603-gumenge,
       END OF i_s603.

DATA : BEGIN OF i_s912 OCCURS 0,
         spmon    LIKE  s912-spmon,
         matnr    LIKE  s912-matnr,
         werks    LIKE  s912-werks,
         zqnetsls LIKE s912-zqnetsls,
         zrunrate LIKE s912-zrunrate,
         zavg_sls LIKE s912-zavg_sls,
       END OF i_s912.

DATA : BEGIN OF i_po_oos OCCURS 0,
         vkbur  LIKE zmm_po_oos-vkbur,
         matnr  LIKE zmm_po_oos-matnr,
         poqty  LIKE zmm_po_oos-poqty,
         oosqty LIKE zmm_po_oos-oosqty,
         waers  LIKE zmm_po_oos-waers,
         oosval LIKE zmm_po_oos-oosval,
       END OF i_po_oos.

* added by idub, 20060130
* according to leo request, add 2 additional fields
*--------------------------------------------------
DATA : BEGIN OF i_s912cm OCCURS 0,
         matnr LIKE  s912-matnr,
         werks LIKE  s912-werks,
         ktmng LIKE  s912-ktmng,
       END OF i_s912cm.

DATA : BEGIN OF i_s912cmsum OCCURS 0,
         matnr LIKE  s912-matnr,
         werks LIKE  s912-werks,
         ktmng LIKE  s912-ktmng,
       END OF i_s912cmsum.

DATA : BEGIN OF i_s912nm OCCURS 0,
         matnr LIKE  s912-matnr,
         werks LIKE  s912-werks,
         ktmng LIKE  s912-ktmng,
       END OF i_s912nm.

DATA : BEGIN OF i_s912nmsum OCCURS 0,
         matnr LIKE  s912-matnr,
         werks LIKE  s912-werks,
         ktmng LIKE  s912-ktmng,
       END OF i_s912nmsum.
*--------------------------------------------------

DATA : BEGIN OF i_main OCCURS 0,
         matnr    LIKE  mard-matnr,
         maktx    LIKE  makt-maktx,
         matkl    LIKE  mara-matkl,
         meins    LIKE  mara-meins,
         zeiar    LIKE  mara-zeiar,
         werks    LIKE  mard-werks,
         name1    LIKE  t001w-name1,
         lgort    LIKE  tvkol-lgort,
         vkbur    LIKE  s603-vkbur,
         bezei    LIKE  tvkbt-bezei,
         stkcr    LIKE  mard-labst,      "Current Stock
         stkcrpl  LIKE mard-labst,     "Current Stock in Pallete
         blstkcr  LIKE  mard-speme,    "Current Block Stock
         intrs    LIKE  mb_mdbs-menge,   "Intransit CW ke Cabang
         opnpo    LIKE  mb_mdbs-menge,   "Open PO
         opnsto   LIKE  mb_mdbs-menge,   "Open STO
         opnsto1  LIKE  mb_mdbs-menge,  "Open STO
         totpo    LIKE  mb_mdbs-menge,   "Total PO / STO
         stkls    LIKE  s039-gsbest,     "Last Month Stock
         grsto    LIKE  s931-menge,      "GR STO
         avrsl    LIKE  s912-zavg_sls,   "Average Sales
         avrslutd LIKE  s912-zavg_sls,   "Average Sales United
         avrfc    LIKE  s912-zavg_sls,   "Average Forecast
         stdrt    LIKE  marc-kausf,      "Standard Stock Ratio
*         actrt  LIKE  s912-zstd_stock, "Actual Stock Ratio
*         actrt1 LIKE  s912-zstd_stock, "Actual Stock Ratio
         actrt    TYPE  zxx,             "Actual Stock Ratio
         actrt1   TYPE  zxx,             "Actual Stock Ratio
         sales    LIKE  s611-ummenge,    "Sales Month to date
         errfl(3),
         tacm     LIKE  s912-ktmng,
         tanm     LIKE  s912-ktmng,
         m0	      TYPE mc_ummenge,
         m1	      TYPE mc_ummenge,
         m2	      TYPE mc_ummenge,
         m3	      TYPE mc_ummenge,
         x1	      TYPE mc_ummenge,
         x2	      TYPE mc_ummenge,
         x3	      TYPE mc_ummenge,
         x4	      TYPE mc_ummenge,
         x5	      TYPE mc_ummenge,
         x6	      TYPE mc_ummenge,
         flg1     TYPE char1,           "SAT/IDM Flag
         maabc    LIKE marc-maabc,
         dnqty    LIKE s619-lfimg,
*        dnval  LIKE s619-grosval,
         dnval    LIKE zsac7_tmp-avamt, "MC_GUKZWI1,
         slobop   TYPE mc_ummenge,
         slobcr   TYPE mc_ummenge,
         karton   TYPE mc_ummenge,
         poqty    TYPE kwmeng,
         oosqty   TYPE menge_d,
         peroos   TYPE zxx,
         nfmat    TYPE nfmat,
         olmat    TYPE matnr,
         kzaus    TYPE kzaus,
         nsp      TYPE konp-kbetr,
         waers    TYPE zmm_po_oos-waers,
         oosval   TYPE zmm_po_oos-oosval,
         ftsm0w1  TYPE mc_ummenge,
         ftsm0w2 TYPE mc_ummenge,
         ftsm0w3 TYPE mc_ummenge,
         ftsm0w4 TYPE mc_ummenge,
         ftsm1w1  TYPE mc_ummenge,
         ftsm1w2 TYPE mc_ummenge,
         ftsm1w3 TYPE mc_ummenge,
         ftsm1w4 TYPE mc_ummenge,
         ftsm2w1  TYPE mc_ummenge,
         ftsm2w2 TYPE mc_ummenge,
         ftsm2w3 TYPE mc_ummenge,
         ftsm2w4 TYPE mc_ummenge,
         ftsm3w1  TYPE mc_ummenge,
         ftsm3w2 TYPE mc_ummenge,
         ftsm3w3 TYPE mc_ummenge,
         ftsm3w4 TYPE mc_ummenge,
       END OF i_main.

DATA: BEGIN OF i_marm OCCURS 0.
        INCLUDE STRUCTURE marm.
      DATA: END OF i_marm.

DATA : BEGIN OF i_nsp OCCURS 0,
         vkorg LIKE a567-vkorg,
         vkbur LIKE a567-vkbur,
         regio LIKE a567-regio,
         matnr LIKE a567-matnr,
         knumh LIKE a567-knumh,
         kbetr LIKE konp-kbetr.
DATA : END OF i_nsp.

DATA : i_original   LIKE i_main OCCURS 0 WITH HEADER LINE,
       i_tvkol      TYPE TABLE OF tvkol WITH HEADER LINE,
       i_mat_b2b    TYPE TABLE OF zsmat_b2b WITH HEADER LINE,
       va_input1(1),
       va_input2(2),
       va_usrgrp    LIKE usgrp_user-usergroup.
