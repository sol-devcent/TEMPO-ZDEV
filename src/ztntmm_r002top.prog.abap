*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPTOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: mardh,mard,bkpf,mkpf,mseg.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*


*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA  BEGIN OF gt_makt OCCURS 1.
DATA:   matnr TYPE matnr,
        maktx TYPE maktx,
        meins TYPE meins.
DATA  END   OF gt_makt.

DATA: BEGIN OF gt_mseg OCCURS 0,
        mblnr	TYPE mblnr,
        mjahr	TYPE mjahr,
        zeile	TYPE mblpo,
        bwart	TYPE bwart,
        xauto	TYPE mb_xauto,
        matnr	TYPE matnr,
        werks	TYPE werks_d,
        lgort	TYPE lgort_d,
        charg	TYPE charg_d,
        lifnr	TYPE elifn,
        kunnr	TYPE ekunn,
        menge	TYPE menge_d,
        meins	TYPE meins,
        ebeln	TYPE bstnr,
        ebelp	TYPE ebelp,
        sjahr	TYPE mjahr,
        smbln	TYPE mblnr,
        smblp	TYPE mblpo,
        elikz	TYPE elikz,
        sgtxt	TYPE sgtxt,
        shkzg TYPE shkzg,
        budat TYPE budat,
        xblnr TYPE xblnr1,
        frbnr TYPE frbnr1,
        flag  TYPE flag,
      END OF gt_mseg.

DATA: BEGIN OF gt_detail OCCURS 0,
        budat     TYPE budat,
        ebeln	    TYPE bstnr,
        name1     TYPE name1_gp,
        xblnr     TYPE xblnr1,
        in_bbm    TYPE menge_d,
        in_retur  TYPE menge_d,
        out_bbk	  TYPE menge_d,
        out_scrap	TYPE menge_d,
        saldo	    TYPE menge_d,
        licha	    TYPE lichn,
        vfdat	    TYPE vfdat,
        meins     TYPE meins,
        bwart     TYPE bwart,
        batchprin TYPE lichn,
        delnote   TYPE xblnr1,
        bolno     TYPE frbnr1,
        vbeln     TYPE vbeln_va,
        zflag     TYPE flag,
      END OF gt_detail.

DATA: gt_kna1 TYPE TABLE OF kna1 WITH HEADER LINE,
      gt_lfa1 TYPE TABLE OF lfa1 WITH HEADER LINE,
      gt_mch1 TYPE TABLE OF mch1 WITH HEADER LINE,
      gt_ekbe TYPE TABLE OF ekbe WITH HEADER LINE,
      gt_vbfa TYPE TABLE OF vbfa WITH HEADER LINE,
      gt_vbfa2 TYPE TABLE OF vbfa WITH HEADER LINE,
      gt_s933 TYPE TABLE OF s933 WITH HEADER LINE,
      gt_vbak TYPE TABLE OF vbak WITH HEADER LINE,
      gt_vbrk TYPE TABLE OF vbrk WITH HEADER LINE.

DATA: gr_in_bbm    TYPE RANGE OF bwart WITH HEADER LINE,
      gr_in_retur  TYPE RANGE OF bwart WITH HEADER LINE,
      gr_out_bbk   TYPE RANGE OF bwart WITH HEADER LINE,
      gr_out_scrap TYPE RANGE OF bwart WITH HEADER LINE,
      gr_other     TYPE RANGE OF bwart WITH HEADER LINE.

DATA: wa_makt   LIKE gt_makt,
      gt_opnstk TYPE zmmtt_opnstk,
      wa_opnstk LIKE LINE OF gt_opnstk,
      gv_opnstk LIKE mard-labst.
