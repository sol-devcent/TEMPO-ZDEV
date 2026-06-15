*----------------------------------------------------------------------*
*   INCLUDE ZS_CL_SEMESTER_HITUNG_TOP                                        *
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: s603, kna1, knkk, knvv, knka, sscrfields.

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
      END OF t_itab.

DATA: BEGIN OF t_kna1 OCCURS 0,
         kunnr LIKE kna1-kunnr,
         sortl LIKE kna1-sortl,
         name1 LIKE kna1-name1,
      END OF t_kna1.

DATA: BEGIN OF t_knkk OCCURS 0,
         knkli LIKE knkk-knkli,
         kkber LIKE knkk-kkber,
         klimk LIKE knkk-klimk,
      END OF t_knkk.

DATA: BEGIN OF t_zknkk OCCURS 0.
        INCLUDE STRUCTURE knkk.
DATA: END OF t_zknkk.

DATA: t_zscl_gro LIKE zscl_gro OCCURS 0 WITH HEADER LINE,
      t_itab_err LIKE t_itab OCCURS 0 WITH HEADER LINE,
      t_zscl_sm LIKE zscl_sm OCCURS 0 WITH HEADER LINE,
      yknkk      LIKE knkk,
      va_update TYPE i,
      va_error TYPE i,
      ok_code LIKE sy-ucomm.

DATA: r_status TYPE RANGE OF zflag1 WITH HEADER LINE.
