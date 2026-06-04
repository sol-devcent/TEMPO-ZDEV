*----------------------------------------------------------------------*
*   INCLUDE ZGHMMTOP001                                                *
*----------------------------------------------------------------------*
TABLES : t001w,mard,mb_mdbs,s039,s931,makt,mara.

TYPE-POOLS: slis,abap,truxs.

DATA : gt_download TYPE truxs_t_text_data,
       gs_download TYPE LINE OF truxs_t_text_data.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : BEGIN OF i_werks OCCURS 0,
         werks  LIKE  t001w-werks,
         name1  LIKE  t001w-name1,
       END OF i_werks.

DATA : BEGIN OF i_makt OCCURS 0,
         matnr  LIKE  makt-matnr,
         maktx  LIKE  makt-maktx,
         meins  LIKE  mara-meins,
         matkl  LIKE  mara-matkl,
       END OF i_makt.

DATA : BEGIN OF i_marc OCCURS 0,
         matnr  LIKE  marc-matnr,
         werks  LIKE  marc-werks,
         kausf  LIKE  marc-kausf,
       END OF i_marc.

DATA : BEGIN OF i_mard OCCURS 0,
         matnr  LIKE  mard-matnr,
         werks  LIKE  mard-werks,
         lgort  LIKE  mard-lgort,
         labst  LIKE  mard-labst,
         insme  LIKE  mard-insme,
         speme  LIKE  mard-speme,
       END OF i_mard.

DATA : BEGIN OF i_mdbs OCCURS 0,
         matnr  LIKE  mb_mdbs-matnr,
         werks  LIKE  mb_mdbs-werks,
         lgort  LIKE  mb_mdbs-lgort,
         bsart  LIKE  ekko-bsart,
         bstyp  LIKE  mb_mdbs-bstyp,
         ebeln  LIKE  mb_mdbs-ebeln,
         ebelp  LIKE  mb_mdbs-ebelp,
         bedat  LIKE  mb_mdbs-bedat,
         menge  LIKE  mb_mdbs-menge,
         wemng  LIKE  mb_mdbs-wemng,
         wamng  LIKE  mb_mdbs-wamng,
         glmng  LIKE  mb_mdbs-glmng,
       END OF i_mdbs.

DATA : BEGIN OF i_s039 OCCURS 0,
         matnr  LIKE  s039-matnr,
         werks  LIKE  s039-werks,
         lgort  LIKE  s039-lgort,
         gsbest LIKE  s039-gsbest,
         mbwbest LIKE  s039-mbwbest,
       END OF i_s039.

DATA : BEGIN OF i_s931 OCCURS 0,
         matnr  LIKE  s931-matnr,
         werks  LIKE  s931-werks,
         lgort  LIKE  s931-lgort,
         bwart  LIKE  s931-bwart,
         menge  LIKE  s931-menge,
       END OF i_s931.

DATA : BEGIN OF i_s611 OCCURS 0,
         matnr  LIKE  s611-matnr,
         werks  LIKE  s611-werks,
         ummenge LIKE s611-ummenge,
         gumenge LIKE s611-gumenge,
       END OF i_s611.

DATA : BEGIN OF i_s603 OCCURS 0,
         matnr  LIKE  s603-matnr,
         vkbur  LIKE  s603-vkbur,
         ummenge LIKE s603-ummenge,
         gumenge LIKE s603-gumenge,
       END OF i_s603.

DATA : BEGIN OF i_s912 OCCURS 0,
         spmon  LIKE  s912-spmon,
         matnr  LIKE  s912-matnr,
         werks  LIKE  s912-werks,
         zqnetsls LIKE s912-zqnetsls,
         zrunrate LIKE s912-zrunrate,
         zavg_sls LIKE s912-zavg_sls,
       END OF i_s912.

* added by idub, 20060130
* according to leo request, add 2 additional fields
*--------------------------------------------------
DATA : BEGIN OF i_s912cm OCCURS 0,
         matnr  LIKE  s912-matnr,
         werks  LIKE  s912-werks,
         ktmng  LIKE  s912-ktmng,
       END OF i_s912cm.

DATA : BEGIN OF i_s912cmsum OCCURS 0,
         matnr  LIKE  s912-matnr,
         werks  LIKE  s912-werks,
         ktmng  LIKE  s912-ktmng,
       END OF i_s912cmsum.

DATA : BEGIN OF i_s912nm OCCURS 0,
         matnr  LIKE  s912-matnr,
         werks  LIKE  s912-werks,
         ktmng  LIKE  s912-ktmng,
       END OF i_s912nm.

DATA : BEGIN OF i_s912nmsum OCCURS 0,
         matnr  LIKE  s912-matnr,
         werks  LIKE  s912-werks,
         ktmng  LIKE  s912-ktmng,
       END OF i_s912nmsum.
*--------------------------------------------------

DATA : BEGIN OF i_main OCCURS 0,
         matnr  LIKE  mard-matnr,
         maktx  LIKE  makt-maktx,
         matkl  LIKE  mara-matkl,
         meins  LIKE  mara-meins,
         werks  LIKE  mard-werks,
         name1  LIKE  t001w-name1,
         stkcr  LIKE  mard-labst,      "Current Stock
         blstkcr  LIKE  mard-labst,    "Current Block Stock
         intrs  LIKE  mb_mdbs-menge,   "Intransit CW ke Cabang
         opnpo  LIKE  mb_mdbs-menge,   "Open PO
         opnsto LIKE  mb_mdbs-menge,   "Open STO
         opnsto1 LIKE  mb_mdbs-menge,   "Open STO
         totpo  LIKE  mb_mdbs-menge,   "Total PO / STO
         stkls  LIKE  s039-gsbest,     "Last Month Stock
         grsto  LIKE  s931-menge,      "GR STO
         avrsl  LIKE  s912-zavg_sls,   "Average Sales
         avrslutd  LIKE  s912-zavg_sls,   "Average Sales United
         stdrt  LIKE  marc-kausf,      "Standard Stock Ratio
*         actrt  LIKE  s912-zstd_stock, "Actual Stock Ratio
*         actrt1 LIKE  s912-zstd_stock, "Actual Stock Ratio
         actrt  TYPE  zxx,             "Actual Stock Ratio
         actrt1 TYPE  zxx,             "Actual Stock Ratio
         sales  LIKE  s611-ummenge,    "Sales Month to date
         errfl(3),
         tacm   LIKE  s912-ktmng,
         tanm   LIKE  s912-ktmng,
       END OF i_main.

DATA : BEGIN OF i_download OCCURS 0,
         matnr  LIKE  mard-matnr,
         maktx  LIKE  makt-maktx,
         matkl  LIKE  mara-matkl,
         meins  LIKE  mara-meins,
         werks  LIKE  mard-werks,
         name1  LIKE  t001w-name1,
         totpo  TYPE  char15,     "Total PO / STO
"         opnpo  TYPE  char15,     "Open PO
         opnsto TYPE  char15,     "Open STO
         grsto  TYPE  char15,     "GR STO
       END OF i_download.

DATA : i_original LIKE i_main OCCURS 0 WITH HEADER LINE,
       va_input1(1),
       va_input2(2),
       va_usrgrp LIKE usgrp_user-usergroup.

DATA : BEGIN OF i_matnr OCCURS 0,
       matnr LIKE mara-matnr,
       prodh LIKE mvke-prodh,
       zeinr LIKE mara-zeinr,
       END OF i_matnr.

DATA BEGIN OF i_outpl OCCURS 0.
        INCLUDE STRUCTURE zsac7_tmp.
DATA:   kausf LIKE marc-kausf,
        ratms LIKE zsac7_tmp-brems,
        ratid(4),
        final(1),
        region LIKE adrc-region,
        estsls LIKE zsac7_tmp-netsamt,
        varsls LIKE zsac7_tmp-netsamt,
        zeinr LIKE mara-zeinr,
        peran LIKE prop-peran,
     END OF i_outpl.

DATA : BEGIN OF i_dataset OCCURS 0,
       werks(4),
       prodh1(5),
       prodh2(5),
       prodh3(8),
       matnr(18),
       maktx(35),
       ummenge(15),
       umkzwi1(17),
       gumenge(15),
       gukzwi1(17),
       netsqty(15),
       netsamt(17),
       brems(13),
       brecv(13),
       bretp(13),
       breit(13),
       breus(13),
       bresp(13),
       bretl(13),
       cwems(13),
       cweit(13),
       cweus(13),
       cwetl(13),
       stval(17),
       avsqt(13),
       doamt(17),
       strat(17),
       basme(3),
       stwae(5),
       x1(13),
       x2(13),
       x3(13),
       x4(13),
       x5(13),
       x6(13),
       avqty(17),
       avamt(17),
       stratio(17),
       nsp(13),
       qdo_ip(15),
       vdo_ip(17),
       qcn_ip(15),
       vcn_ip(17),
       stkdo_ip(13),
       stkcn_ip(13),
       kausf(7),
       ratms(13),
       ratid(4),
       final(1),
       region(3),
       estsls(17).
DATA END OF i_dataset.

TYPES : BEGIN OF t_line,
          v_text(1500) TYPE c,
        END OF t_line.
TYPES : t_iline TYPE t_line OCCURS 10.

DATA :  itabline TYPE t_iline,
        itabline_sut TYPE t_iline,
        wa_itabline TYPE t_line,
        wa_itabline_sut TYPE t_line.

DATA :  i_zplbc TYPE TABLE OF zplbc WITH HEADER LINE,
        gv_utd(1).
