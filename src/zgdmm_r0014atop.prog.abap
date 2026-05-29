*----------------------------------------------------------------------*
*   INCLUDE ZIBM_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: mara, s933.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: t_text LIKE ztxw_note OCCURS 0 WITH HEADER LINE,
      t_user LIKE usdef OCCURS 0 WITH HEADER LINE.

DATA: va_name2  LIKE adrc-name2,
      va_street LIKE adrc-street.

RANGES: ra_period FOR sy-datum,
        ra_matnr  FOR mara-matnr,
        ra_datum  FOR sy-datum.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
TYPES: BEGIN OF s_struc.
TYPES: matnr LIKE mara-matnr,
       maktx LIKE makt-maktx,
       period LIKE zgdppdt0004-period,
       dlvfac LIKE zgdppdt0004-dlvfac,
       lmenge01 LIKE qals-lmenge01,
       ratio TYPE dec07,
       meins LIKE mara-meins.
TYPES: END OF s_struc.

DATA: BEGIN OF gt_zgdppdt0004 OCCURS 0,
        period  TYPE abper_rf,
        matnr   TYPE matnr,
        werks   TYPE werks_d,
        kunnr   TYPE kunnr,
        podist  TYPE zgdppde_podist,
      END OF gt_zgdppdt0004.

DATA: t_period(6) OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF t_main OCCURS 0.
INCLUDE TYPE s_struc.
DATA:
      rofo01     TYPE zgdppde_podist,
      rofo02     TYPE zgdppde_podist,
      rofo03     TYPE zgdppde_podist,
      rofo04     TYPE zgdppde_podist,
      rofo05     TYPE zgdppde_podist,
      rofo06     TYPE zgdppde_podist,

      po01       LIKE eket-menge,
      po02       LIKE eket-menge,
      po03       LIKE eket-menge,
      po04       LIKE eket-menge,
      po05       LIKE eket-menge,
      po06       LIKE eket-menge,

      supply01   LIKE eket-wamng,
      supply02   LIKE eket-wamng,
      supply03   LIKE eket-wamng,
      supply04   LIKE eket-wamng,
      supply05   LIKE eket-wamng,
      supply06   LIKE eket-wamng,

      persen01   TYPE dec07,
      persen02   TYPE dec07,
      persen03   TYPE dec07,
      persen04   TYPE dec07,
      persen05   TYPE dec07,
      persen06   TYPE dec07,

      tot_po     LIKE eket-menge,
      tot_supply LIKE eket-wamng,
      tot_persen TYPE dec07.
DATA: END OF t_main.

DATA: t_result LIKE t_main OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF t_mara OCCURS 0,
        matnr LIKE mara-matnr,
        meins LIKE mara-meins,
        mtart LIKE mara-mtart,
      END OF t_mara.

DATA: BEGIN OF t_makt OCCURS 0,
        matnr LIKE mara-matnr,
        maktx LIKE makt-maktx,
      END OF t_makt.

DATA: BEGIN OF t_ekko OCCURS 0,
        ebeln LIKE ekko-ebeln,
      END OF t_ekko.

DATA: BEGIN OF t_ekpo OCCURS 0,
        ebeln LIKE ekpo-ebeln,
        ebelp LIKE ekpo-ebelp,
        matnr LIKE ekpo-matnr,
        umrez LIKE ekpo-umrez,
      END OF t_ekpo.

DATA: BEGIN OF t_eket OCCURS 0,
        ebeln LIKE eket-ebeln,
        ebelp LIKE eket-ebelp,
        eindt LIKE eket-eindt,
        menge LIKE eket-menge,
      END OF t_eket.

DATA: BEGIN OF t_ekbe OCCURS 0,
        ebeln LIKE ekbe-ebeln,
        ebelp LIKE ekbe-ebelp,
        belnr LIKE ekbe-belnr,
        buzei LIKE ekbe-buzei,
        budat LIKE ekbe-budat,
        shkzg LIKE ekbe-shkzg,
        menge LIKE ekbe-menge,
      END OF t_ekbe.

DATA: BEGIN OF t_ekbesum OCCURS 0,
        ebeln LIKE ekbe-ebeln,
        ebelp LIKE ekbe-ebelp,
        perio(6) TYPE n,
        menge LIKE ekbe-menge,
      END OF t_ekbesum.

DATA: BEGIN OF t_po OCCURS 0,
        ebeln  LIKE eket-ebeln,
        ebelp  LIKE eket-ebelp,
        matnr  LIKE ekpo-matnr,
        eindt  LIKE eket-eindt,
        perio(6) TYPE n,
        menge  LIKE eket-menge,
        menge1 LIKE ekbe-menge,
      END OF t_po.

DATA: BEGIN OF t_posum OCCURS 0,
        matnr   LIKE ekpo-matnr,
        menge01 LIKE eket-menge,
        menge02 LIKE eket-menge,
        menge03 LIKE eket-menge,
        menge04 LIKE eket-menge,
        menge05 LIKE eket-menge,
        menge06 LIKE eket-menge,
        menge11 LIKE eket-wamng,
        menge12 LIKE eket-wamng,
        menge13 LIKE eket-wamng,
        menge14 LIKE eket-wamng,
        menge15 LIKE eket-wamng,
        menge16 LIKE eket-wamng,
      END OF t_posum.

DATA: BEGIN OF t_vbak OCCURS 0,
        vbeln LIKE vbak-vbeln,
      END OF t_vbak.

DATA: BEGIN OF t_vbap OCCURS 0,
        vbeln LIKE vbap-vbeln,
        posnr LIKE vbap-posnr,
        matnr LIKE vbap-matnr,
        umziz LIKE vbap-umziz,
      END OF t_vbap.

DATA: BEGIN OF t_vbep OCCURS 0,
        vbeln LIKE vbep-vbeln,
        posnr LIKE vbep-posnr,
        edatu LIKE vbep-edatu,
        bmeng LIKE vbep-bmeng,
      END OF t_vbep.

DATA: BEGIN OF t_vbfa OCCURS 0,
        vbelv   LIKE vbfa-vbelv,
        posnv   LIKE vbfa-posnv,
        vbeln   LIKE vbfa-vbeln,
        posnn   LIKE vbfa-posnn,
        erdat   LIKE vbfa-erdat,
        vbtyp_n LIKE vbfa-vbtyp_n,
        rfmng   LIKE vbfa-rfmng,
      END OF t_vbfa.

DATA: BEGIN OF t_vbfasum OCCURS 0,
        vbelv LIKE vbfa-vbelv,
        posnv LIKE vbfa-posnv,
        perio(6) TYPE n,
        rfmng LIKE vbfa-rfmng,
      END OF t_vbfasum.

DATA: BEGIN OF t_so OCCURS 0,
        vbeln LIKE vbep-vbeln,
        posnr LIKE vbep-posnr,
        matnr LIKE vbap-matnr,
        edatu LIKE vbep-edatu,
        perio(6) TYPE n,
        bmeng LIKE vbep-bmeng,
        rfmng LIKE vbfa-rfmng,
      END OF t_so.

DATA: BEGIN OF t_sosum OCCURS 0,
        matnr   LIKE vbap-matnr,
        bmeng01 LIKE vbep-bmeng,
        bmeng02 LIKE vbep-bmeng,
        bmeng03 LIKE vbep-bmeng,
        bmeng04 LIKE vbep-bmeng,
        bmeng05 LIKE vbep-bmeng,
        bmeng06 LIKE vbep-bmeng,
        rfmng01 LIKE vbfa-rfmng,
        rfmng02 LIKE vbfa-rfmng,
        rfmng03 LIKE vbfa-rfmng,
        rfmng04 LIKE vbfa-rfmng,
        rfmng05 LIKE vbfa-rfmng,
        rfmng06 LIKE vbfa-rfmng,
      END OF t_sosum.
