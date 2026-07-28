*----------------------------------------------------------------------*
*   INCLUDE ZM_LEAD_TIMETOP                                            *
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: ekko, ekpo, ekbe, sscrfields, tcurx.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*


*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF t_vdata OCCURS 0,
        ebeln  LIKE ekko-ebeln,
        ebelp  LIKE ekpo-ebelp,
        bsart  LIKE ekko-bsart,
        ekgrp  LIKE ekko-ekgrp,
        bukrs  LIKE ekko-bukrs,
        lifnr  LIKE ekko-lifnr,
        bedat  LIKE ekko-bedat,
        waers  LIKE ekko-waers,
        wkurs  LIKE ekko-wkurs,
        knumv  LIKE ekko-knumv.
DATA:   werks  LIKE ekpo-werks,
        matnr  LIKE ekpo-matnr,
        txz01  LIKE ekpo-txz01,
        meins  LIKE ekpo-meins,
        netwr  TYPE p DECIMALS 2,
        lewed  LIKE ekpo-lewed,
        menge  LIKE ekpo-menge.
DATA:   name1  LIKE lfa1-name1,
        elikz  LIKE ekpo-elikz.
DATA: END OF t_vdata.

DATA: BEGIN OF t_lifnr OCCURS 0,
        lifnr  LIKE ekko-lifnr.
DATA: END OF t_lifnr.
DATA: BEGIN OF t_knumv OCCURS 0,
        knumv  LIKE ekko-knumv,
        kposn  LIKE konv-kposn.
DATA: END OF t_knumv.
DATA: BEGIN OF t_matnr OCCURS 0,
        matnr  LIKE mara-matnr.
DATA: END OF t_matnr.

DATA: BEGIN OF t_lfa1 OCCURS 0,
        lifnr  LIKE lfa1-lifnr,
        name1  LIKE lfa1-name1.
DATA: END OF t_lfa1.

DATA: BEGIN OF t_konv OCCURS 0,
        knumv  LIKE konv-knumv,
        kposn  LIKE konv-kposn,
        kbetr  LIKE konv-kbetr,
        kkurs  LIKE konv-kkurs,
        kpein  LIKE konv-kpein,
        kschl  LIKE konv-kschl,
        waers  LIKE konv-waers.
DATA: END OF t_konv.

DATA: BEGIN OF t_mara OCCURS 0,
        matnr  LIKE mara-matnr,
        bismt  LIKE mara-bismt.
DATA: END OF t_mara.
DATA: BEGIN OF t_marc OCCURS 0,
        matnr  LIKE marc-matnr,
        plifz  LIKE marc-plifz.
DATA: END OF t_marc.

DATA: BEGIN OF t_ekbe OCCURS 0,
        ebeln  LIKE ekbe-ebeln,
        ebelp  LIKE ekbe-ebelp,
        belnr  LIKE ekbe-belnr,
        buzei  LIKE ekbe-buzei,
        bwart  LIKE ekbe-bwart,
        budat  LIKE ekbe-budat,
        shkzg  LIKE ekbe-shkzg,
        menge  LIKE ekbe-menge,
        matnr  LIKE ekbe-matnr,
        bldat  LIKE ekbe-bldat,
        lfbnr  LIKE ekbe-lfbnr.
DATA: END OF t_ekbe.
DATA: BEGIN OF t_ekbe1 OCCURS 0.
        INCLUDE STRUCTURE t_ekbe.
DATA: END OF t_ekbe1.

DATA: BEGIN OF t_ekbedata OCCURS 0.
        INCLUDE STRUCTURE t_ekbe.
DATA: count    TYPE i,
      cancel   TYPE i.
DATA: END OF t_ekbedata.

DATA: BEGIN OF t_ekbetime OCCURS 0.
        INCLUDE STRUCTURE t_ekbe.
DATA: count    TYPE i,
      date        LIKE sy-datum,
      qtylate01   LIKE eket-menge,
      qtylate02   LIKE eket-menge,
      qtylate03   LIKE eket-menge,
      qtylate04   LIKE eket-menge,
      qtyotim     LIKE eket-menge.
DATA: END OF t_ekbetime.

DATA: BEGIN OF t_eket OCCURS 0,
        ebeln  LIKE eket-ebeln,
        ebelp  LIKE eket-ebelp,
        etenr  LIKE eket-etenr,
        banfn  LIKE eket-banfn,
        bnfpo  LIKE eket-bnfpo,
        eindt  LIKE eket-eindt,
        menge  LIKE eket-menge,
        wemng  LIKE eket-wemng.
DATA: END OF t_eket.
DATA: BEGIN OF t_eketdata OCCURS 0,
        ebeln  LIKE eket-ebeln,
        ebelp  LIKE eket-ebelp,
        count  TYPE i,
        menge  TYPE i,
        wemng  TYPE i.
DATA: END OF t_eketdata.

DATA: BEGIN OF t_eketdat1 OCCURS 0,
        ebeln       LIKE eket-ebeln,
        ebelp       LIKE eket-ebelp,
        banfn       LIKE eket-banfn,
        badat       LIKE eban-badat,
        menge_eban  LIKE eban-menge,
        reldt       LIKE sy-datum,
        lfdat       LIKE eban-lfdat.
DATA: END OF t_eketdat1.

DATA: BEGIN OF t_eban OCCURS 0,
        banfn  LIKE eban-banfn,
        bnfpo  LIKE eban-bnfpo,
        badat  LIKE eban-badat,
        menge  LIKE eban-menge,
        lfdat  LIKE eban-lfdat,
        frgkz  LIKE eban-frgkz.
DATA: END OF t_eban.

DATA: BEGIN OF t_out OCCURS 0.
        INCLUDE STRUCTURE t_vdata.
DATA:   etenr       LIKE eket-etenr,
        banfn       LIKE eket-banfn,
        bnfpo       LIKE eket-bnfpo,
        eindt       LIKE eket-eindt,
        menge_eket  LIKE eket-menge,
        wemng       LIKE eket-wemng,
        badat       LIKE eban-badat,
        menge_eban  LIKE eban-menge,
        lfdat       LIKE eban-lfdat,
        bismt       LIKE mara-bismt,
        reldt       LIKE sy-datum,
        exc_rate    TYPE p DECIMALS 2,
        curr_sat    LIKE ekko-waers,
        hrgsat      TYPE p DECIMALS 2,
        value_idr   TYPE p DECIMALS 2,
        budget_curr LIKE ekko-waers,
        budat       LIKE ekbe-budat,
        firstbudat  LIKE ekbe-budat,
        plifz       LIKE marc-plifz,
        delrel      TYPE i,
        grpr        TYPE i,
        firstqtygr  LIKE eket-menge,
*        qtylate     LIKE eket-menge,
        qtylate01   LIKE eket-menge,
        qtylate02   LIKE eket-menge,
        qtylate03   LIKE eket-menge,
        qtylate04   LIKE eket-menge,
        qtyotim     LIKE eket-menge,
        vallate     TYPE p DECIMALS 2,
        vallate01   TYPE p DECIMALS 2,
        vallate02   TYPE p DECIMALS 2,
        vallate03   TYPE p DECIMALS 2,
        vallate04   TYPE p DECIMALS 2,
        valotim     TYPE p DECIMALS 2,
        grpo_first  TYPE p DECIMALS 0,
        grpo_last   TYPE p DECIMALS 0,
        grpo        LIKE eket-menge,
        text(100).
DATA: END OF t_out.

DATA: va_flag  TYPE i.

RANGES: ra_inter1 FOR ekbe-budat,
        ra_inter2 FOR ekbe-budat,
        ra_inter3 FOR ekbe-budat,
        ra_inter4 FOR ekbe-budat,
        ra_inter5 FOR ekbe-budat.
