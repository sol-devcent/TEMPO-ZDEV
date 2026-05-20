*----------------------------------------------------------------------*
*   INCLUDE ZF_UPLPOSTTOP
*----------------------------------------------------------------------*
INCLUDE ole2incl.
INCLUDE <icon>.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: sscrfields, zflogtr.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: h_excel TYPE ole2_object,        " Excel object
      h_mapl  TYPE ole2_object,        " list of workbooks
      h_map   TYPE ole2_object,        " workbook
      h_zl    TYPE ole2_object,        " cell
      h_f     TYPE ole2_object.        " font

DATA: gv_error TYPE sy-subrc,
      gv_budat TYPE budat,
      gv_bldat TYPE bldat,
      gv_xblnr TYPE xblnr,
      gv_belnr TYPE belnr_d,
      gv_waers TYPE waers.

DATA: gv_copa(1).

DATA: gr_hkont TYPE RANGE OF hkont,
      gr_line  LIKE LINE OF gr_hkont.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_excel OCCURS 0,
        row   TYPE kcd_ex_row_n,
        col   TYPE kcd_ex_col_n,
        value TYPE char50,
      END OF gt_excel.

DATA: gt_user LIKE usdef OCCURS 10000 WITH HEADER LINE.

DATA: BEGIN OF gt_tbsl OCCURS 0,
        bschl TYPE bschl,
        shkzg TYPE shkzg,
        koart TYPE koart,
      END OF gt_tbsl.

DATA: BEGIN OF gt_ska1 OCCURS 0,
        ktopl TYPE ktopl,
        saknr TYPE saknr,
        xbilk TYPE xbilk,
      END OF gt_ska1.

DATA: BEGIN OF gt_header OCCURS 0,
        budat TYPE budat,
        bldat TYPE bldat,
        xblnr TYPE xblnr,
        bktxt TYPE bktxt,
        blart TYPE blart,
        bukrs TYPE bukrs,
        gsber TYPE gsber,
      END OF gt_header.

DATA: BEGIN OF gt_detail OCCURS 0,
        newbs   TYPE newbs,
        newko   TYPE newko,
        newum   TYPE newum,
        newbw   TYPE bwasl,
        buzei   TYPE buzei,
        dmbtr   TYPE summ9,
        mwskz   TYPE mwskz,
        gsber   TYPE gsber,
        vbund   TYPE vbund,
        kostl   TYPE kostl,
        aufnr   TYPE aufnr,
        prctr   TYPE prctr,
        werks   TYPE werks_d,
        sgtxt   TYPE sgtxt,
        vkorg   TYPE vkorg,
        vtweg   TYPE vtweg,
        vkbur   TYPE vkbur,
        wwsfr   TYPE rkeg_wwsfr,
        wwpfn   TYPE rkeg_wwpfn,
        wwpos   TYPE rkeg_wwpos,
        waers   TYPE waers,
        kursf   TYPE kursf,
        zuonr   TYPE dzuonr,
* Tambahan baru untuk upload COPA
        vkgrp   TYPE vkgrp,
        kndnr   TYPE kunde_pa,
        artnr   TYPE artnr,
        wwpbr   TYPE rkeg_wwpbr,
        wwpgr   TYPE rkeg_wwpgr,
        wwprc   TYPE rkeg_wwprc,
        spart   TYPE spart,
        kdgrp   TYPE kdgrp,
        matkl   TYPE matkl,
        wwctp   TYPE rkeg_wwctp,
        extwg   TYPE extwg,
        wwprr   TYPE rkeg_wwprr,
        wwprd   TYPE rkeg_wwprd,
        wwsec   TYPE rkeg_wwsec,
        wwtrz   TYPE rkeg_wwtrz,
*****
        matnr   TYPE mara-matnr,
*        zterm   TYPE dzterm,
        ztag1   TYPE dztage,
        icon(4),
      END OF gt_detail.

DATA: gt_t052 TYPE TABLE OF t052.

DATA: accountgl         LIKE TABLE OF bapiacgl09 WITH HEADER LINE,
      accountpayable    LIKE TABLE OF bapiacap09 WITH HEADER LINE,
      accountreceivable LIKE TABLE OF bapiacar09 WITH HEADER LINE,
      extension1        LIKE TABLE OF bapiacextc WITH HEADER LINE,
      currencyamount    LIKE TABLE OF bapiaccr09 WITH HEADER LINE,
      criteria          LIKE TABLE OF bapiackec9 WITH HEADER LINE,
      return            LIKE TABLE OF bapiret2 WITH HEADER LINE,
      documentheader    LIKE bapiache09.

DATA: BEGIN OF gt_error OCCURS 0,
        bktxt        TYPE bktxt,
        message(220),
      END OF gt_error.

DATA: BEGIN OF gt_zflogtr OCCURS 0.
        INCLUDE STRUCTURE zflogtr.
      DATA: END OF gt_zflogtr.
