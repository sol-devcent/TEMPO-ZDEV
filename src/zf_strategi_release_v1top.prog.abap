*----------------------------------------------------------------------*
*   INCLUDE ZF_STRATEGI_RELEASE_V1TOP                                  *
*----------------------------------------------------------------------*
INCLUDE <icon>.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: bsid, zfh_kr1at, sscrfields.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF usergroups OCCURS 0.
        INCLUDE STRUCTURE usgroups.
DATA: END OF usergroups.

DATA: BEGIN OF t_zfh_kr1at OCCURS 0.
        INCLUDE STRUCTURE zfh_kr1at.
DATA: name1   LIKE kna1-name1,
      zddesc1 LIKE zfdept-zdesc,
      zddesc2 LIKE zfdept-zdesc.
DATA: END OF t_zfh_kr1at.

DATA: BEGIN OF t_kunnr OCCURS 0.
        INCLUDE STRUCTURE zfh_kr1at.
DATA: END OF t_kunnr.

DATA: BEGIN OF t_kna1 OCCURS 0.
        INCLUDE STRUCTURE kna1.
DATA:   kvgr3 LIKE knvv-kvgr3,
      END OF t_kna1.

DATA: BEGIN OF t_out OCCURS 0.
        INCLUDE STRUCTURE zfhstblokd.
DATA: noform     LIKE zfh_kr1at-noform,
      zgoluser1  LIKE zfh_kr1at-stsrel1,
      zgoluser2  LIKE zfh_kr1at-stsrel2,
      zgoluser3  LIKE zfh_kr1at-stsrel3,
      zgoluser4  LIKE zfh_kr1at-stsrel4,
      zgoluser5  LIKE zfh_kr1at-stsrel5,
      usrgroup1  LIKE zfh_kr1at-usrgroup1,
      usrgroup2  LIKE zfh_kr1at-usrgroup2,
      usrgroup3  LIKE zfh_kr1at-usrgroup3,
      usrgroup4  LIKE zfh_kr1at-usrgroup4,
      usrgroup5  LIKE zfh_kr1at-usrgroup5,
      zdept1     LIKE zfh_kr1at-zdept1,
      zdept2     LIKE zfh_kr1at-zdept2,
      zddesc1    LIKE zfdept-zdesc,
      zddesc2    LIKE zfdept-zdesc,
      check(1),
      icon(4).
DATA: END OF t_out.

DATA: BEGIN OF t_out1 OCCURS 0.
        INCLUDE STRUCTURE zfhstblokd.
DATA: noform LIKE zfh_kr1at-noform,
      zgoluser1  LIKE zfh_kr1at-stsrel1,
      zgoluser2  LIKE zfh_kr1at-stsrel2,
      zgoluser3  LIKE zfh_kr1at-stsrel3,
      zgoluser4  LIKE zfh_kr1at-stsrel4,
      zgoluser5  LIKE zfh_kr1at-stsrel5,
      usrgroup1  LIKE zfh_kr1at-usrgroup1,
      usrgroup2  LIKE zfh_kr1at-usrgroup2,
      usrgroup3  LIKE zfh_kr1at-usrgroup3,
      usrgroup4  LIKE zfh_kr1at-usrgroup4,
      usrgroup5  LIKE zfh_kr1at-usrgroup5,
      zdept1     LIKE zfh_kr1at-zdept1,
      zdept2     LIKE zfh_kr1at-zdept2,
      zddesc1    LIKE zfdept-zdesc,
      zddesc2    LIKE zfdept-zdesc,
      check(1),
      icon(4).
DATA: END OF t_out1.

DATA: BEGIN OF t_out2 OCCURS 0.
        INCLUDE STRUCTURE zfhstblokd.
DATA: noform LIKE zfh_kr1at-noform,
      zgoluser1  LIKE zfh_kr1at-stsrel1,
      zgoluser2  LIKE zfh_kr1at-stsrel2,
      zgoluser3  LIKE zfh_kr1at-stsrel3,
      zgoluser4  LIKE zfh_kr1at-stsrel4,
      zgoluser5  LIKE zfh_kr1at-stsrel5,
      usrgroup1  LIKE zfh_kr1at-usrgroup1,
      usrgroup2  LIKE zfh_kr1at-usrgroup2,
      usrgroup3  LIKE zfh_kr1at-usrgroup3,
      usrgroup4  LIKE zfh_kr1at-usrgroup4,
      usrgroup5  LIKE zfh_kr1at-usrgroup5,
      zdept1     LIKE zfh_kr1at-zdept1,
      zdept2     LIKE zfh_kr1at-zdept2,
      zddesc1    LIKE zfdept-zdesc,
      zddesc2    LIKE zfdept-zdesc,
      check(1),
      icon(4).
DATA: END OF t_out2.

DATA: BEGIN OF t_data OCCURS 0.
        INCLUDE STRUCTURE zfhstblokd.
DATA: noform LIKE zfh_kr1at-noform,
      zgoluser1  LIKE zfh_kr1at-stsrel1,
      zgoluser2  LIKE zfh_kr1at-stsrel2,
      zgoluser3  LIKE zfh_kr1at-stsrel3,
      zgoluser4  LIKE zfh_kr1at-stsrel4,
      zgoluser5  LIKE zfh_kr1at-stsrel5,
      usrgroup1  LIKE zfh_kr1at-usrgroup1,
      usrgroup2  LIKE zfh_kr1at-usrgroup2,
      usrgroup3  LIKE zfh_kr1at-usrgroup3,
      usrgroup4  LIKE zfh_kr1at-usrgroup4,
      usrgroup5  LIKE zfh_kr1at-usrgroup5,
      zdept1     LIKE zfh_kr1at-zdept1,
      zdept2     LIKE zfh_kr1at-zdept2,
      zddesc1    LIKE zfdept-zdesc,
      zddesc2    LIKE zfdept-zdesc,
      check(1),
      icon(4).
DATA: END OF t_data.

DATA: BEGIN OF t_error1 OCCURS 0.
        INCLUDE STRUCTURE t_zfh_kr1at.
DATA: msg(100).
DATA: END OF t_error1.

DATA: BEGIN OF t_error5 OCCURS 0.
        INCLUDE STRUCTURE t_zfh_kr1at.
DATA: msg(100).
DATA: END OF t_error5.

DATA: BEGIN OF t_zfdept OCCURS 0.
        INCLUDE STRUCTURE zfdept.
DATA: END OF t_zfdept.
DATA: BEGIN OF t_zfusrrel_form3 OCCURS 0.
        INCLUDE STRUCTURE zfusrrel_form3.
DATA: END OF t_zfusrrel_form3.
DATA: BEGIN OF t_zfusrrel_form3x OCCURS 0.
        INCLUDE STRUCTURE zfusrrel_form3.
DATA: END OF t_zfusrrel_form3x.

DATA: BEGIN OF t_zscl_level OCCURS 0.
        INCLUDE STRUCTURE zscl_level.
DATA: END OF t_zscl_level.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: va_valid         TYPE i,
      va_error         TYPE i,
      va_zgoluser      LIKE zscl_goluser-zgoluser,
      va_usrgroup      LIKE usgroups-usergroup,
      va_zdept         LIKE zfdept-zdept,
      va_zvalue        LIKE zscl_level-zvalue,
      va_value(20),
      va_wrbtr         LIKE bsid-wrbtr,
      va_zlevel        LIKE zfusrrel_form3-zlevel,
      va_lock          TYPE i,
      va_level1(12),
      va_level2(12),
      va_level3(12),
      va_level4(12),
      va_count         TYPE i.

DATA: gv_gsber         TYPE gsber,
      gv_bukrs         TYPE bukrs.
