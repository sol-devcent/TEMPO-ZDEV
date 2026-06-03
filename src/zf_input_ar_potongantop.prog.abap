*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: mara,zfarpoth,zfarpotd.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
CONTROLS input TYPE TABLEVIEW USING SCREEN 100.

*CONSTANTS c_mode(1) VALUE 'E'.

DATA: ok_code        TYPE sy-ucomm,
      save_ok        TYPE sy-ucomm,
      fill           TYPE i,
      gv_save(1),
      gv_error(1),
      gv_message(80),
      gv_mode(1)     VALUE 'E'.

DATA: bukrs  LIKE zfarpoth-bukrs,
      gsber  LIKE zfarpoth-gsber,
      vkbur  LIKE zfarpoth-vkbur,
      noarp  LIKE zfarpoth-noarp,
      mjahr  LIKE zfarpoth-mjahr,
      budat  LIKE zfarpoth-budat,
      bbeln  LIKE zfarpoth-bbeln,
      hkont  LIKE zfarpoth-hkont,
      amount LIKE zfarpoth-amount,
      voucr  LIKE zfarpoth-voucr,
      txarp  LIKE zfarpoth-txarp,
      bldat  LIKE zfarpoth-bldat,
      nodpy  LIKE zfarpoth-nodpy,
      txt20  LIKE skat-txt20.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_vdata OCCURS 0.
        INCLUDE STRUCTURE zfarpotd.
        DATA:   name1 LIKE kna1-name1.
DATA: END OF gt_vdata.

DATA: BEGIN OF gt_verror OCCURS 0.
        INCLUDE STRUCTURE zfarpotd.
        DATA:   text(100),
      END OF gt_verror.

DATA BEGIN OF t_record OCCURS 0.
INCLUDE STRUCTURE zfarpotd.
DATA: err(1),
      icon(4),
      info(3),
      msg(75),
      msg2(75).
DATA END OF t_record.

DATA: gt_zfarpoth_sv LIKE zfarpoth OCCURS 0 WITH HEADER LINE,
      gt_zfarpotd_sv LIKE zfarpotd OCCURS 0 WITH HEADER LINE.

DATA  BEGIN OF gt_zfarpoth OCCURS 1.
INCLUDE STRUCTURE zfarpoth.
DATA:   check,
        expand,
      END   OF gt_zfarpoth.

DATA  BEGIN OF gt_zfarpotd OCCURS 1.
INCLUDE STRUCTURE zfarpotd.
DATA: name1  LIKE kna1-name1,
      expand,
      END   OF gt_zfarpotd.

DATA: BEGIN OF gt_tvzbt OCCURS 0,
        zterm TYPE dzterm,
        vtext TYPE dzterm_bez,
        ztag1 TYPE dztage,
      END OF gt_tvzbt.

FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.
