*----------------------------------------------------------------------*
*   INCLUDE ZS_CL_SEMESTER_HITUNG_TOP                                        *
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: s603, kna1, knkk, knvv, knka, zplbc, sscrfields.

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
        user1(8),
        user2(8),
        user3(8),
        check(1),
        input(1),
        color(3),
        message(30),
        flag(1),
      END OF t_itab.

DATA: BEGIN OF t_kna1 OCCURS 0,
         kunnr LIKE kna1-kunnr,
         sortl LIKE kna1-sortl,
         name1 LIKE kna1-name1,
         aufsd LIKE kna1-aufsd,
      END OF t_kna1.

DATA: BEGIN OF t_zknkk OCCURS 0.
        INCLUDE STRUCTURE knkk.
DATA: vkbur  LIKE knvv-vkbur,
      sortl  LIKE kna1-sortl.
DATA: END OF t_zknkk.

DATA: BEGIN OF t_dwn_field OCCURS 0,
        txt_field(15),
      END OF t_dwn_field.

DATA: BEGIN OF t_download OCCURS 0,
        brcod LIKE zplbc-legacy_branch,
        raycod(2),
        outgr(1),
        outcd(6),
        limit(17),
*        limit LIKE zscl_sm-klimk,
*        trn(3) TYPE n,
*        userid(2),
*        waktu(20),
*        limitent LIKE zscl_sm-klimk,
*        userident(2),
*        group(3),
*        ke(2) type n,
*        limit6mr LIKE zscl_sm-klimk,
*        userid6mr(2),
*        growth(6) type n,
*        top(3) type n,
*        userid1(2),
*        waktu1(16),
*        group1(3),
*        gol1(1),
*        userid2(2),
*        waktu2(16),
*        group2(3),
*        gol2(1),
*        userid3(2),
*        waktu3(16),
*        group3(3),
*        gol4(1),
*        cca(4),
*        gjahr LIKE zscl_sm-gjahr,
*        zsmst LIKE zscl_sm-zsmst,
*        vkbur LIKE zscl_sm-vkbur,
*        knkli LIKE zscl_sm-knkli,
*        sortl LIKE zscl_sm-sortl,
*        name1 LIKE kna1-name1,
*        klimk LIKE zscl_sm-klimk,
      END OF t_download.

DATA: t_zscl_ctr LIKE zscl_ctr OCCURS 0 WITH HEADER LINE,
      ok_code LIKE sy-ucomm.
