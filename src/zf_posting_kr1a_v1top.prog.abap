*----------------------------------------------------------------------*
*   INCLUDE ZF_POSTING_KR1A_V1TOP                                      *
*----------------------------------------------------------------------*
INCLUDE <icon>.

TYPE-POOLS : tpit.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: bsid, zfh_kr1at, sscrfields, knvv.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: t_user LIKE usdef OCCURS 10000 WITH HEADER LINE.

DATA: BEGIN OF t_zfhstatus OCCURS 0.
        INCLUDE STRUCTURE zfhstatus.
DATA: END OF t_zfhstatus.

DATA: BEGIN OF t_zfusrrel_form3 OCCURS 0.
        INCLUDE STRUCTURE zfusrrel_form3.
DATA: END OF t_zfusrrel_form3.

DATA: BEGIN OF t_out OCCURS 0.
        INCLUDE STRUCTURE zfhstblokd.
DATA:   noform LIKE zfh_kr1at-noform,
        stsrel1(1),
        stsrel2(1),
        stsrel3(1),
        stsrel4(1),
        stsrel5(1),
        usrgroup1  LIKE zfh_kr1at-usrgroup1,
        usrgroup2  LIKE zfh_kr1at-usrgroup2,
        umskz1 LIKE zfh_kr1at-umskz1,
        check(1),
        icon(4),
        error(4),
        msg(100).
DATA: END OF t_out.

DATA: BEGIN OF t_data OCCURS 0.
        INCLUDE STRUCTURE zfh_kr1at.
DATA:   name1 LIKE kna1-name1,
        check(1),
        icon(4),
        msg(100).
DATA: END OF t_data.

DATA: BEGIN OF t_zfh_kr1at OCCURS 0.
        INCLUDE STRUCTURE zfh_kr1at.
DATA:   name1 LIKE kna1-name1,
        check(1),
        icon(4),
        msg(100).
DATA: END OF t_zfh_kr1at.

DATA: BEGIN OF t_belnr OCCURS 0.
        INCLUDE STRUCTURE t_zfh_kr1at.
DATA: END OF t_belnr.
DATA: BEGIN OF t_zuonr OCCURS 0.
        INCLUDE STRUCTURE t_zfh_kr1at.
DATA: END OF t_zuonr.

DATA: BEGIN OF t_zfbid OCCURS 0.
        INCLUDE STRUCTURE zfbid.
DATA: END OF t_zfbid.
DATA: BEGIN OF t_bsid OCCURS 0.
        INCLUDE STRUCTURE bsid.
DATA: END OF t_bsid.
DATA: BEGIN OF t_bsidsum OCCURS 0.
        INCLUDE STRUCTURE bsid.
DATA: count  TYPE i.
DATA: END OF t_bsidsum.

DATA: BEGIN OF t_error1 OCCURS 0.
        INCLUDE STRUCTURE t_zfh_kr1at.
DATA: END OF t_error1.

DATA: BEGIN OF t_error2 OCCURS 0.
        INCLUDE STRUCTURE t_zfh_kr1at.
DATA: END OF t_error2.

DATA: BEGIN OF t_error3 OCCURS 0,
        kunnr  LIKE bsid-kunnr,
        vbeln  LIKE zfbid-vbeln,
        bbeln  LIKE zfbid-bbeln,
        msg(100).
DATA: END OF t_error3.

DATA: BEGIN OF t_kunnr OCCURS 0.
        INCLUDE STRUCTURE zfh_kr1at.
DATA: END OF t_kunnr.

DATA: BEGIN OF t_kna1 OCCURS 0.
        INCLUDE STRUCTURE kna1.
DATA: END OF t_kna1.

DATA: BEGIN OF t_t001b OCCURS 0.
        INCLUDE STRUCTURE t001b.
DATA: END OF t_t001b.

DATA: BEGIN OF t_zfusrrel_form3x OCCURS 0.
        INCLUDE STRUCTURE zfusrrel_form3.
DATA: END OF t_zfusrrel_form3x.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
RANGES: ra_blart FOR bsid-blart.

DATA: va_error    TYPE i,
      va_lock     TYPE i,
      va_errcnt   TYPE i,
      va_success  TYPE i,
      va_valid    TYPE i,
      va_status   TYPE i,
      va_level1(12),
      va_level2(12),
      va_level3(12),
      va_level4(12).

DATA : gv_gsber    TYPE gsber,
       gv_bukrs    TYPE bukrs.

DATA : gr_gsber    TYPE RANGE OF gsber,
       gs_gsber    LIKE LINE OF gr_gsber.
