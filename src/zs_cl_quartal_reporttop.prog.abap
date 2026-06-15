*----------------------------------------------------------------------*
*   INCLUDE ZS_CL_SEMESTER_HITUNG_TOP                                        *
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: s603, kna1, knkk, knvv, zscl_sm, sscrfields.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF t_itab OCCURS 0.
        INCLUDE STRUCTURE zscl_sm.
DATA:   name1 LIKE kna1-name1,
        klimk_usl% LIKE s603-umkzwi1,
        klimk_kp% LIKE s603-umkzwi1,
        zgoluser  LIKE zscl_goluser-zgoluser,
        zusergroup LIKE zscl_goluser-usrgroup,
        sts_desc(15),
        user1(8),
        user2(8),
        user3(8),
        check(1),
        input(1),
        color(3),
        vtext LIKE tvast-vtext,
      END OF t_itab.

DATA: BEGIN OF t_s603key OCCURS 0,
         vkbur LIKE s603-vkbur,
         pkunwe LIKE s603-pkunwe,
         spmon LIKE s603-spmon,
         kdgrp LIKE s603-kdgrp,
         kvgr3 LIKE s603-kvgr3,
      END OF t_s603key.

DATA: BEGIN OF t_s603 OCCURS 0,
         vkbur LIKE s603-vkbur,
         pkunwe LIKE s603-pkunwe,
         spmon LIKE s603-spmon,
         kdgrp LIKE s603-kdgrp,
         kvgr3 LIKE s603-kvgr3,
         umkzwi1 LIKE s603-umkzwi1,
         gukzwi1 LIKE s603-gukzwi1,
      END OF t_s603.

DATA: BEGIN OF t_knvv OCCURS 0,
        kunnr LIKE knvv-kunnr,
        vkorg LIKE knvv-vkorg,
        vtweg LIKE knvv-vtweg,
        spart LIKE knvv-spart,
        kdgrp LIKE knvv-kdgrp,
        kvgr3 LIKE knvv-kvgr3,
      END OF t_knvv.

DATA: BEGIN OF t_kna1 OCCURS 0,
         kunnr LIKE kna1-kunnr,
         sortl LIKE kna1-sortl,
         name1 LIKE kna1-name1,
         aufsd LIKE kna1-aufsd,
         vtext LIKE tvast-vtext,
      END OF t_kna1.

DATA: BEGIN OF t_knkk OCCURS 0,
         knkli LIKE knkk-knkli,
         kkber LIKE knkk-kkber,
         klimk LIKE knkk-klimk,
      END OF t_knkk.

DATA: t_zscl_gro LIKE zscl_gro OCCURS 0 WITH HEADER LINE,
      t_itab_conf LIKE t_itab OCCURS 0 WITH HEADER LINE,
      usergroup LIKE zscl_goluser-usrgroup,
      zgoluser  LIKE zscl_goluser-zgoluser,
      va_list  TYPE slist_listline,
      sw(1),
      va_mark(1),
      ok_code LIKE sy-ucomm,
      t_tvkbt LIKE tvkbt OCCURS 0 WITH HEADER LINE.

RANGES: r_vkbur FOR zscl_sm-vkbur.

DATA: BEGIN OF t_zsbankgrs_knkli OCCURS 0.
        INCLUDE STRUCTURE zsbankgrs.
DATA: END OF t_zsbankgrs_knkli.
DATA: BEGIN OF t_zsbankgrs_kdgrp OCCURS 0.
        INCLUDE STRUCTURE zsbankgrs.
DATA: END OF t_zsbankgrs_kdgrp.
DATA: BEGIN OF t_kdgrp OCCURS 0.
        INCLUDE STRUCTURE t_itab.
DATA: END OF t_kdgrp.
DATA: BEGIN OF t_knkli OCCURS 0.
        INCLUDE STRUCTURE t_itab.
DATA: END OF t_knkli.
