*----------------------------------------------------------------------*
*   INCLUDE ZS_CL_SEMESTER_HITUNG_TOP                                        *
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: s603, kna1, knkk, knvv, sscrfields.

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
        check(1),
      END OF t_itab.

DATA: BEGIN OF t_s603key OCCURS 0,
         vkbur LIKE s603-vkbur,
         pkunwe LIKE s603-pkunwe,
         spmon LIKE s603-spmon,
         kdgrp LIKE s603-kdgrp,
         kvgr3 LIKE s603-kvgr3,
         ZCLASS like ZSCL_CLASS-ZCLASS,
      END OF t_s603key.

DATA: BEGIN OF t_s603 OCCURS 0,
         vkbur LIKE s603-vkbur,
         pkunwe LIKE s603-pkunwe,
         spmon LIKE s603-spmon,
         kdgrp LIKE s603-kdgrp,
         kvgr3 LIKE s603-kvgr3,
         ZCLASS like ZSCL_CLASS-ZCLASS,
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
        zterm LIKE knvv-zterm,
        ztag1 LIKE t052-ztag1,
      END OF t_knvv.

DATA: BEGIN OF t_kna1 OCCURS 0,
         kunnr LIKE kna1-kunnr,
         sortl LIKE kna1-sortl,
         name1 LIKE kna1-name1,
         erdat LIKE kna1-erdat,
      END OF t_kna1.

DATA: BEGIN OF t_knkk OCCURS 0,
         knkli LIKE knkk-knkli,
         kkber LIKE knkk-kkber,
         klimk LIKE knkk-klimk,
      END OF t_knkk.

DATA: t_zscl_gro LIKE zscl_gro OCCURS 0 WITH HEADER LINE,
      t_itab_err LIKE t_itab OCCURS 0 WITH HEADER LINE,
      t_zscl_sm LIKE zscl_sm OCCURS 0 WITH HEADER LINE,
      va_update TYPE i,
      va_error TYPE i, "pa_zsmst(1),
      ok_code LIKE sy-ucomm.

DATA: BEGIN OF t_zsbankgrs_knkli OCCURS 0.
        INCLUDE STRUCTURE zsbankgrs.
DATA: END OF t_zsbankgrs_knkli.
DATA: BEGIN OF t_zsbankgrs_kdgrp OCCURS 0.
        INCLUDE STRUCTURE zsbankgrs.
DATA: END OF t_zsbankgrs_kdgrp.
DATA: BEGIN OF t_kdgrp OCCURS 0.
        INCLUDE STRUCTURE t_s603key.
DATA: END OF t_kdgrp.
DATA: BEGIN OF t_knkli OCCURS 0.
        INCLUDE STRUCTURE t_s603key.
DATA: END OF t_knkli.
