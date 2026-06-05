*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: mara,zfarpoth,zfarpotd,zfarpotd2.

INCLUDE <icon>.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
CONTROLS input TYPE TABLEVIEW USING SCREEN 100.
CONTROLS reverse TYPE TABLEVIEW USING SCREEN 200.

TYPES : BEGIN OF ty_status,
          h1(4),
        END OF ty_status.

TYPES : BEGIN OF ty_bi,
          bbeln(7) TYPE n,
          zuonr    TYPE zfbid-zuonr,
          wrbtr    TYPE zfbid-wrbtr,
          bidat    TYPE zfbih-bidat,
        END OF ty_bi.

*CONSTANTS c_mode(1) VALUE 'E'.

DATA: ok_code        TYPE sy-ucomm,
      save_ok        TYPE sy-ucomm,
      fill           TYPE i,
      gv_save(1),
      gv_error(1),
      gv_message(80),
      gv_mode(1)     VALUE 'E'.

DATA: bukrs     LIKE zfarpoth-bukrs,
      gsber     LIKE zfarpoth-gsber,
      vkbur     LIKE zfarpoth-vkbur,
      noarp     LIKE zfarpoth-noarp,
      mjahr     LIKE zfarpoth-mjahr,
      budat     LIKE zfarpoth-budat,
      hkont     LIKE zfarpoth-hkont,
      amount    LIKE zfarpoth-amount,
      voucr     LIKE zfarpoth-voucr,
      txarp     LIKE zfarpoth-txarp,
      bldat     LIKE zfarpoth-bldat,
      nodpy     LIKE zfarpoth-nodpy,
      txt20     LIKE skat-txt20,
      belnr(20),
      inpamt    LIKE zfarpotdcn-inpamt.

DATA : hkont1   LIKE zfarpoth-hkont,
       hkont2   LIKE zfarpoth-hkont,
       txt201   LIKE skat-txt20,
       txt202   LIKE skat-txt20,
       voucr1   LIKE zfarpoth-voucr,
       voucr2   LIKE zfarpoth-voucr,
       selisih1 LIKE zfbid-wrbtr,
       selisih2 LIKE zfbid-wrbtr.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_vdata OCCURS 0.
        INCLUDE STRUCTURE zfarpotd.
        DATA:   nou(6),
        icon(4),
        mark,
        name1    LIKE kna1-name1,
        zuonr    LIKE zfh_kr1at-zuonr,
        expand,
        vbeln    TYPE vbfa-vbeln,
        bbeln(7) TYPE n,
        wrbtr    LIKE zfbid-wrbtr,
        selisih  LIKE zfbid-wrbtr,
        xflag.
DATA: END OF gt_vdata.

DATA : gt_xdata LIKE gt_vdata OCCURS 0.

DATA: BEGIN OF gt_verror OCCURS 0.
        INCLUDE STRUCTURE zfarpotd.
        DATA:   text(100),
      END OF gt_verror.

DATA: BEGIN OF t_record OCCURS 0.
        INCLUDE STRUCTURE zfarpotd.
        DATA:   err(1),
        icon(4),
        info(3),
        msg(75),
        msg2(75).
DATA: END OF t_record.

DATA  BEGIN OF gt_zfarpoth OCCURS 1.
INCLUDE STRUCTURE zfarpoth.
DATA: belnrpay LIKE zfarpotd-belnr,
      gjahrpay LIKE zfarpotd-gjahr,
      check,
      expand.
DATA: END   OF gt_zfarpoth.

DATA  BEGIN OF gt_zfarpotd OCCURS 1.
INCLUDE STRUCTURE zfarpotd.
DATA: nou(6),
      icon(4),
      mark,
      name1    LIKE kna1-name1,
      zuonr    LIKE zfh_kr1at-zuonr,
      expand,
      vbeln    TYPE vbfa-vbeln,
      bbeln(7) TYPE n,
      wrbtr    LIKE zfbid-wrbtr,
      selisih  LIKE zfbid-wrbtr.
DATA: END   OF gt_zfarpotd.
DATA: gt_xfarpotd LIKE gt_zfarpotd OCCURS 0.

DATA  BEGIN OF gt_zfarpotd2 OCCURS 1.
INCLUDE STRUCTURE zfarpotd2.
DATA: name1  LIKE kna1-name1,
      zuonr  LIKE zfh_kr1at-zuonr,
      expand.
DATA: END   OF gt_zfarpotd2.

DATA  BEGIN OF gt_greport OCCURS 1.
INCLUDE STRUCTURE zfarpoth.
DATA: posnr     LIKE zfarpotd-posnr,
      kunnr     LIKE zfarpotd-kunnr,
      name1     LIKE kna1-name1,
      rtvtyp    LIKE zfarpotd-rtvtyp,
      rtvnr     LIKE zfarpotd-rtvnr,
      rtvdt     LIKE zfarpotd-rtvdt,
      rtvamt    LIKE zfarpotd-rtvamt,
      posamt    LIKE zfarpotd-posamt,
      inpamt    LIKE zfarpotd-inpamt,
      rtvket    LIKE zfarpotd-rtvket,
      xblnr     LIKE zfarpotd-xblnr,
      dhkont    LIKE zfarpotd-hkont,
      dbelnr    LIKE zfarpotd-belnr,
      dgjahr    LIKE zfarpotd-gjahr,
      dbudat    LIKE zfarpotd-budat,
      dbuzet    LIKE zfarpotd-buzet,
      dbunam    LIKE zfarpotd-bunam,
      dbelnrrev LIKE zfarpotd-belnrrev,
      ddaterev  LIKE zfarpotd-daterev,
      duserrev  LIKE zfarpotd-userrev,
      dtxarp    LIKE zfarpotd-txarp,
      dvoucr    LIKE zfarpotd-voucr.
DATA: END   OF gt_greport.

DATA  BEGIN OF gt_zfhkr1at OCCURS 1.
DATA: bukrs     LIKE zfh_kr1at-bukrs,
      gsber     LIKE zfh_kr1at-gsber,
      vkbur     LIKE zfh_kr1at-vkbur,
      noform    LIKE zfh_kr1at-noform,
      zuonr     LIKE zfh_kr1at-zuonr,
      belnrpos2 LIKE zfh_kr1at-belnrpos2.
DATA  END   OF gt_zfhkr1at.

DATA: gt_zfarpoth_sv   LIKE zfarpoth OCCURS 0 WITH HEADER LINE,
      gt_zfarpoth_pay  LIKE gt_zfarpoth OCCURS 0 WITH HEADER LINE,
      gt_zfarpotd_sv   LIKE zfarpotd OCCURS 0 WITH HEADER LINE,
      gt_zfarpotd2_sv  LIKE zfarpotd2 OCCURS 0 WITH HEADER LINE,
      gt_zfarpotd_rvs  LIKE gt_zfarpotd OCCURS 0 WITH HEADER LINE,
      gt_zfarpotd2_rvs LIKE gt_zfarpotd2 OCCURS 0 WITH HEADER LINE,
      gt_zfarpotdet    LIKE gt_zfarpotd OCCURS 0 WITH HEADER LINE,
      wa_zfarpotd      LIKE gt_zfarpotd.

DATA: gt_vbak TYPE STANDARD TABLE OF vbak,
      gt_vbfa TYPE STANDARD TABLE OF vbfa,
      gt_bi   TYPE STANDARD TABLE OF ty_bi,
      gt_tbsl TYPE STANDARD TABLE OF tbsl.

FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.

CONTROLS : t_tabstrip TYPE TABSTRIP.

CONSTANTS : BEGIN OF ct_tabstrip,
              tab1 TYPE sy-ucomm VALUE '&TAB1',
              tab2 TYPE sy-ucomm VALUE '&TAB2',
              tab3 TYPE sy-ucomm VALUE '&TAB3',
            END OF ct_tabstrip.

CONSTANTS : BEGIN OF gc_subscreen,
              0100 TYPE sy-dynnr VALUE '0100',
            END OF gc_subscreen.

DATA : BEGIN OF gt_tabstrip,
         subscreen   TYPE sy-dynnr,
         prog        TYPE sy-repid,
         pressed_tab TYPE sy-ucomm VALUE ct_tabstrip-tab1,
       END OF gt_tabstrip.

DATA : gt_status TYPE STANDARD TABLE OF ty_status,
       gs_status LIKE LINE OF gt_status.

DATA : gt_zfarpotdcn    TYPE STANDARD TABLE OF zfarpotdcn.
