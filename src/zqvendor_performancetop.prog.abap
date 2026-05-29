*----------------------------------------------------------------------*
*   INCLUDE ZQVENDOR_PERFORMANCETOP                                    *
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: sscrfields, mseg, mkpf.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: va_error  TYPE i,
      va_plant(3).
RANGES: ra_bwart  FOR mseg-bwart.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF t_mkpf OCCURS 0,
        mblnr  LIKE mkpf-mblnr,
        mjahr  LIKE mkpf-mjahr,
        budat  LIKE mkpf-budat,
        cpudt  LIKE mkpf-cpudt,
        cputm  LIKE mkpf-cputm,
        tcode2 LIKE mkpf-tcode2.
DATA: END OF t_mkpf.

DATA: BEGIN OF t_mseg OCCURS 0,
        mblnr  LIKE mseg-mblnr,
        budat  LIKE mkpf-budat,
        mjahr  LIKE mseg-mjahr,
        zeile  LIKE mseg-zeile,
        bwart  LIKE mseg-bwart,
        shkzg  LIKE mseg-shkzg,
        matnr  LIKE mseg-matnr,
        werks  LIKE mseg-werks,
        charg  LIKE mseg-charg,
        lifnr  LIKE mseg-lifnr,
        menge  LIKE mseg-menge,
        meins  LIKE mseg-meins,
        ebeln  LIKE mseg-ebeln,
        ebelp  LIKE mseg-ebelp,
        smbln  LIKE mseg-smbln,
        cpudt  LIKE mkpf-cpudt,
        cputm  LIKE mkpf-cputm,
        tcode2 LIKE mkpf-tcode2.
DATA: END OF t_mseg.

DATA: BEGIN OF t_msegdata OCCURS 0.
        INCLUDE STRUCTURE t_mseg.
DATA: END OF t_msegdata.

DATA: BEGIN OF t_lifnr OCCURS 0.
        INCLUDE STRUCTURE t_mseg.
DATA: END OF t_lifnr.
DATA: BEGIN OF t_matnr OCCURS 0.
        INCLUDE STRUCTURE t_mseg.
DATA: END OF t_matnr.

DATA: BEGIN OF t_lfa1 OCCURS 0,
        lifnr  LIKE lfa1-lifnr,
        name1  LIKE lfa1-name1.
DATA: END OF t_lfa1.

DATA: BEGIN OF t_makt OCCURS 0,
        matnr  LIKE makt-matnr,
        maktx  LIKE makt-maktx.
DATA: END OF t_makt.

DATA: BEGIN OF t_qmdata OCCURS 0,
        mblnr      LIKE qals-mblnr,
        zeile      LIKE qals-zeile,
        mjahr      LIKE qals-mjahr,
        matnr      LIKE qals-matnr,
        charg      LIKE qals-charg,
        lmenge01   LIKE qals-lmenge01,
        lmenge04   LIKE qals-lmenge04,
        qkennzahl  LIKE qave-qkennzahl,
        vcode      LIKE qave-vcode,
        vdatum     LIKE qave-vdatum.
DATA: END OF t_qmdata.

DATA: BEGIN OF t_viqmel OCCURS 0,
        matnr     LIKE viqmel-matnr,
        mawerk    LIKE viqmel-mawerk,
        charg     LIKE viqmel-charg,
        qmdat     LIKE viqmel-qmdat,
        qmnum     LIKE viqmel-qmnum,
        qmtxt     LIKE viqmel-qmtxt,
        prueflos  LIKE viqmel-prueflos,
        rkmng     LIKE viqmel-rkmng,
        qmgrp     LIKE viqmel-qmgrp,
        qmcod     LIKE viqmel-qmcod,
        mblnr     LIKE viqmel-mblnr.
DATA: END OF t_viqmel.

DATA: BEGIN OF t_eket OCCURS 0,
        ebeln  LIKE eket-ebeln,
        ebelp  LIKE eket-ebelp,
        etenr  LIKE eket-etenr,
        eindt  LIKE eket-eindt,
        wemng  LIKE eket-wemng,
        menge  LIKE eket-menge.
DATA: END OF t_eket.

DATA: BEGIN OF t_ekpo OCCURS 0,
        ebeln  LIKE ekpo-ebeln,
        ebelp  LIKE ekpo-ebelp,
        meins  LIKE ekpo-meins,
        menge  LIKE ekpo-menge,
        bprme  LIKE ekpo-bprme,
        lmein  LIKE ekpo-lmein,
        bpumn  LIKE ekpo-bpumn,
        bpumz  LIKE ekpo-bpumz,
        umren  LIKE ekpo-umren,
        umrez  LIKE ekpo-umrez.
DATA: END OF t_ekpo.

DATA: BEGIN OF t_ekbe OCCURS 0,
        ebeln  LIKE ekbe-ebeln,
        ebelp  LIKE ekbe-ebelp,
        belnr  LIKE ekbe-belnr,
        budat  LIKE ekbe-budat,
        cpudt  LIKE ekbe-cpudt,
        cputm  LIKE ekbe-cputm,
        shkzg  LIKE ekbe-shkzg,
        menge  LIKE ekbe-menge,
        charg  LIKE ekbe-charg,
        bwart  LIKE ekbe-bwart,
        lfbnr  LIKE ekbe-lfbnr,
        lfpos  LIKE ekbe-lfpos.
DATA: END OF t_ekbe.
DATA: BEGIN OF t_ekbe1 OCCURS 0.
        INCLUDE STRUCTURE t_ekbe.
DATA: END OF t_ekbe1.

DATA: BEGIN OF t_out OCCURS 0,
        mblnr     LIKE mseg-mblnr,
        lifnr     LIKE mseg-lifnr,
        name1     LIKE lfa1-name1,
        matnr     LIKE mseg-matnr,
        maktx     LIKE makt-maktx,
        werks     LIKE mseg-werks,
        budat     LIKE mkpf-budat,
        cputm     LIKE mkpf-cputm,
        cpudt     LIKE mkpf-cpudt,
        charg     LIKE mseg-charg,
        zeile     LIKE mseg-zeile,
        menge     LIKE mseg-menge,
        menge101  LIKE mseg-menge,
        menge102  LIKE mseg-menge,
        menge122  LIKE mseg-menge,
        menge123  LIKE mseg-menge,
        wemng     LIKE eket-wemng,
        meins     LIKE mseg-meins,
        ebeln     LIKE mseg-ebeln,
        ebelp     LIKE mseg-ebelp,
        lmenge01  LIKE qals-lmenge01,
        lmenge04  LIKE qals-lmenge04,
        vcode     LIKE qave-vcode,
        vdatum    LIKE qave-vdatum,
        qmdat     LIKE viqmel-qmdat,
        qmgrp     LIKE viqmel-qmgrp,
        qmcod     LIKE viqmel-qmcod,
        qmnum     LIKE viqmel-qmnum,
        prueflos  LIKE viqmel-prueflos,
        qmtxt     LIKE viqmel-qmtxt,
        rkmng     LIKE viqmel-rkmng,
        tmdif     TYPE i,
        pouom     LIKE ekpo-meins,
        poqty     LIKE ekpo-menge,
        poqtyout  LIKE ekpo-menge,
        podlvqty  LIKE eket-menge,
        openpo    LIKE ekpo-menge,
        povgr     LIKE ekpo-menge,
        rdtv      LIKE ekpo-menge,
        etenr     LIKE eket-etenr,
        eindt     LIKE eket-eindt,
        percen    TYPE p DECIMALS 2,
        atwrt     TYPE atwrt,
        qkennzahl TYPE qkennzahl.
DATA: END OF t_out.

DATA : BEGIN OF gt_mch1 OCCURS 0,
         matnr      TYPE matnr,
         charg      TYPE charg_d,
         cuobj_bm   TYPE cuobj_bm,
         objek      TYPE objnum,
       END   OF gt_mch1.

DATA : BEGIN OF gt_ausp OCCURS 0,
         objek      TYPE objnum,
         atwrt      TYPE atwrt,
       END   OF gt_ausp.
