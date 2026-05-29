*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPTOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: ekko,ekpo,ekbe,eket,sscrfields,bkpf,mara.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
CONSTANTS:only_po TYPE c  VALUE 'F'.

CONSTANTS c_program TYPE string VALUE 'ZM_OOS_PRODUCT'.

DATA: ihead    TYPE slis_t_listheader,
      ihead_ln TYPE slis_listheader.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_t156 OCCURS 0,
        bwart   TYPE bwart,
        xstbw   TYPE xstbw,
      END OF gt_t156.

DATA: BEGIN OF t_out OCCURS 0,
        lifnr LIKE ekko-lifnr,
        name1 LIKE lfa1-name1,
        werks LIKE ekpo-werks,
        lgort LIKE ekpo-lgort,
        bedat LIKE ekko-bedat,
        ebeln LIKE ekko-ebeln,
        aedat LIKE ekko-aedat,
*        ebelp LIKE ekpo-ebelp,
        matnr LIKE ekpo-matnr,
        maktx LIKE makt-maktx,
        ean11 LIKE mean-ean11,
        eindt LIKE eket-eindt,
        bednr LIKE ekpo-bednr,
        menge LIKE ekpo-menge,
        meins LIKE ekpo-meins,
        pocar LIKE ekpo-menge,
        mecar LIKE ekpo-meins,
        wemng LIKE eket-wemng,
        outqt LIKE ekpo-menge,
        budat LIKE ekbe-budat,
        belnr LIKE ekbe-belnr,
        grqty LIKE ekbe-menge,
        bwart LIKE ekbe-bwart,
        otd   TYPE zpercen,
        fullfil TYPE zpercen,
        infull  TYPE zpercen,
        prdha LIKE mara-prdha,
        extwg LIKE mara-extwg,
        lead  TYPE int2,
        xblnr TYPE xblnr,
        mnth_delv(20),
        week_delv  TYPE i,
        mnth_gr(20),
        week_gr  TYPE i,
        w1    LIKE ekbe-menge,
        w2    LIKE ekbe-menge,
        w3    LIKE ekbe-menge,
        w4    LIKE ekbe-menge,
        prdgr(3),
        tdline  TYPE tdline,
        poval   TYPE ekpo-netwr,
        grval   TYPE ekpo-netwr,
        otdval  TYPE ekpo-netwr,
      END OF t_out.

DATA: BEGIN OF t_header OCCURS 0,
        lifnr LIKE ekko-lifnr,
        name1 LIKE lfa1-name1,
        bedat LIKE ekko-bedat,
        ebeln LIKE ekko-ebeln,
        ebelp LIKE ekpo-ebelp,
        aedat LIKE ekko-aedat,
        matnr LIKE ekpo-matnr,
        maktx LIKE makt-maktx,
        ean11 LIKE mean-ean11,
        eindt LIKE eket-eindt,
        menge LIKE ekpo-menge,
        meins LIKE ekpo-meins,
        wemng LIKE eket-wemng,
        outqt LIKE ekpo-menge,
        expand,
      END OF t_header.

DATA: BEGIN OF t_detail OCCURS 0,
        ebeln LIKE ekko-ebeln,
        ebelp LIKE ekpo-ebelp,
        budat LIKE ekbe-budat,
        belnr LIKE ekbe-belnr,
        grqty LIKE ekbe-menge,
        bwart LIKE ekbe-bwart,
        otd   TYPE zpercen,
        fullfil TYPE zpercen,
      END OF t_detail.

DATA  BEGIN OF t_ekpo OCCURS 1.
DATA:   ebeln LIKE ekko-ebeln,
        bukrs LIKE ekko-bukrs,
        bstyp LIKE ekko-bstyp,
        bsart LIKE ekko-bsart,
        lifnr LIKE ekko-lifnr,
        ekorg LIKE ekko-ekorg,
        bedat LIKE ekko-bedat,
        aedat LIKE ekko-aedat,
        ekgrp LIKE ekko-ekgrp,
        ebelp LIKE ekpo-ebelp,
        matnr LIKE ekpo-matnr,
        menge LIKE ekpo-menge,
        meins LIKE ekpo-meins,
        werks LIKE ekpo-werks,
        lgort LIKE ekpo-lgort,
        bednr LIKE ekpo-bednr.
DATA  END   OF t_ekpo.

DATA  BEGIN OF t_eket OCCURS 1.
DATA:   ebeln LIKE eket-ebeln,
        ebelp LIKE eket-ebelp,
        etenr LIKE eket-etenr,
        eindt LIKE eket-eindt,
        menge LIKE eket-menge,
        wemng LIKE eket-wemng,
        wamng LIKE eket-wamng.
DATA  END   OF t_eket.

DATA  BEGIN OF t_ekbe OCCURS 1.
DATA:   ebeln LIKE ekbe-ebeln,
        ebelp LIKE ekbe-ebelp,
        zekkn LIKE ekbe-zekkn,
        vgabe LIKE ekbe-vgabe,
        gjahr LIKE ekbe-gjahr,
        belnr LIKE ekbe-belnr,
        buzei LIKE ekbe-buzei,
        bewtp LIKE ekbe-bewtp,
        bwart LIKE ekbe-bwart,
        budat LIKE ekbe-budat,
        menge LIKE ekbe-menge,
        xblnr LIKE ekbe-xblnr,
        w1    LIKE ekbe-menge,
        w2    LIKE ekbe-menge,
        w3    LIKE ekbe-menge,
        w4    LIKE ekbe-menge.
DATA  END   OF t_ekbe.

DATA  BEGIN OF t_makt OCCURS 1.
DATA:   matnr LIKE makt-matnr,
        maktx LIKE makt-maktx,
        prdha LIKE mara-prdha,
        extwg LIKE mara-extwg.
DATA  END   OF t_makt.

DATA  BEGIN OF t_lfa1 OCCURS 1.
DATA:   lifnr LIKE lfa1-lifnr,
        name1 LIKE lfa1-name1,
        werks LIKE lfa1-werks.
DATA  END   OF t_lfa1.

DATA : BEGIN OF i_nsp OCCURS 0,
         vkorg LIKE a567-vkorg,
         vkbur LIKE a567-vkbur,
         regio LIKE a567-regio,
         matnr LIKE a567-matnr,
         knumh LIKE a567-knumh,
         datab LIKE a567-datab,
         datbi LIKE a567-datbi,
         kbetr LIKE konp-kbetr.
DATA : END OF i_nsp.

DATA : gt_zmmt0001    TYPE STANDARD TABLE OF zmmt0001,
       gs_out         LIKE t_out,
       gv_spmon       LIKE zmmt0001-spmon,
       gv_spmon1      LIKE zmmt0001-spmon,
       gv_remgrw4qty  LIKE zmmt0001-remgrw4qty.
DATA : gt_mean        TYPE TABLE OF mean WITH HEADER LINE.

DATA : BEGIN OF gt_weeksum OCCURS 0,
         matnr    LIKE mara-matnr,
         menge    LIKE ekpo-menge,
         w1       TYPE int4,
         w2       TYPE int4,
         w3       TYPE int4,
         w4       TYPE int4,
       END OF gt_weeksum.
