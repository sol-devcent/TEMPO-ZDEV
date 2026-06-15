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
CONSTANTS c_struc_down TYPE string VALUE 'ZSCL_ST001'.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF t_itab OCCURS 0.
        INCLUDE STRUCTURE zscl_sm.
DATA:   name1 LIKE kna1-name1,
        klimk_usl% LIKE s603-umkzwi1,
        klimk_kp% LIKE s603-umkzwi1,
        check(1),
        color(3),
        message(20),
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

DATA: BEGIN OF t_download OCCURS 0,
        gjahr(5),
        zsmst(3),
        vkorg(10),
        vkbur(10),
        kkber(10),
        kdgrp(10),
        kvgr3(10),
        knkli(12),
        sortl(10),
        name1(40),
        slsm1(20),
        slsm2(20),
        slsm3(20),
        slsm4(20),
        slsm5(20),
        slsm6(20),
        hist(20),
        klimk(20),
        klimk_hit(20),
        klimk_usl(20),
        message(30),
        vtext(20),
      END OF t_download.

DATA: BEGIN OF t_dwn_field OCCURS 0,
        txt_field(15),
      END OF t_dwn_field.

DATA: BEGIN OF t_excel OCCURS 0,
        row   LIKE alsmex_tabline-row,
        col   LIKE alsmex_tabline-col,
        value LIKE alsmex_tabline-value,
      END OF t_excel.

DATA: BEGIN OF t_upload OCCURS 0,
        gjahr LIKE zscl_sm-gjahr,
        zsmst LIKE zscl_sm-zsmst,
        vkorg LIKE zscl_sm-vkorg,
        vkbur LIKE zscl_sm-vkbur,
        kkber LIKE zscl_sm-kkber,
        kdgrp LIKE zscl_sm-kdgrp,
        kvgr3 LIKE zscl_sm-kvgr3,
        knkli LIKE zscl_sm-knkli,
        sortl LIKE zscl_sm-sortl,
        name1 LIKE kna1-name1,
        slsm1 LIKE zscl_sm-slsm1,
        slsm2 LIKE zscl_sm-slsm2,
        slsm3 LIKE zscl_sm-slsm3,
        slsm4 LIKE zscl_sm-slsm4,
        slsm5 LIKE zscl_sm-slsm5,
        slsm6 LIKE zscl_sm-slsm6,
        hist  LIKE zscl_sm-hist,
        klimk LIKE zscl_sm-klimk,
        klimk_hit LIKE zscl_sm-klimk_hit,
        klimk_usl LIKE zscl_sm-klimk_usl,
        message(30),
      END OF t_upload.

DATA: BEGIN OF t_uplkp OCCURS 0,
        gjahr LIKE zscl_sm-gjahr,
        zsmst LIKE zscl_sm-zsmst,
        knkli LIKE zscl_sm-knkli,
        klimk_usl LIKE zscl_sm-klimk_usl,
        message(30),
      END OF t_uplkp.

DATA: t_zscl_gro LIKE zscl_gro OCCURS 0 WITH HEADER LINE,
      t_itab_conf LIKE t_itab OCCURS 0 WITH HEADER LINE,
      t_itab_err LIKE t_itab OCCURS 0 WITH HEADER LINE,
      wa_excel   LIKE t_excel,
      va_update  TYPE i,
      va_error   TYPE i,
      ok_code LIKE sy-ucomm.

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
DATA  BEGIN OF i_zscl_kredit OCCURS 1.
        INCLUDE STRUCTURE zscl_kredit.
DATA  END   OF i_zscl_kredit.
