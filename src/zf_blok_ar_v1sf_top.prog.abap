*----------------------------------------------------------------------*
*   INCLUDE ZF_BLOK_AR_V1SF_TOP                                        *
*----------------------------------------------------------------------*
INCLUDE <icon>.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: bsid, knvv, nast, zfhnoform3, zfh_kr1at, sscrfields.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF t_data OCCURS 0,
        bukrs  LIKE bsid-bukrs,
        kunnr  LIKE bsid-kunnr,
        zuonr  LIKE bsid-zuonr,
        gjahr  LIKE bsid-gjahr,
        belnr  LIKE bsid-belnr,
        buzei  LIKE bsid-buzei,
        budat  LIKE bsid-budat,
        bldat  LIKE bsid-bldat,
        waers  LIKE bsid-waers,
        xblnr  LIKE bsid-xblnr,
        monat  LIKE bsid-monat,
        shkzg  LIKE bsid-shkzg,
        gsber  LIKE bsid-gsber,
        wrbtr  LIKE bsid-wrbtr,
        hkont  LIKE bsid-hkont,
        zfbdt  LIKE bsid-zfbdt,
        zterm  LIKE bsid-zterm,
        zbd1t  LIKE bsid-zbd1t,
        zlspr  LIKE bsid-zlspr,
        vbund  LIKE bsid-vbund,
        xref1  LIKE bsid-xref1,
        xref2  LIKE bsid-xref2,
        xref3  LIKE bsid-xref3,
        blart  LIKE bsid-blart,
        umskz  LIKE bsid-umskz,
        vkbur  LIKE knvv-vkbur,
        spart  LIKE knvv-spart.
DATA: END OF t_data.

DATA: BEGIN OF t_kunnr OCCURS 0.
        INCLUDE STRUCTURE t_data.
DATA: END OF t_kunnr.
DATA: BEGIN OF t_belnr OCCURS 0.
        INCLUDE STRUCTURE t_data.
DATA: END OF t_belnr.

DATA: BEGIN OF t_zfh_kr1at OCCURS 0.
        INCLUDE STRUCTURE zfh_kr1at.
DATA: name1 LIKE kna1-name1.
DATA: END OF t_zfh_kr1at.

DATA: BEGIN OF t_zfh_kr1at_del OCCURS 0.
        INCLUDE STRUCTURE zfh_kr1at.
DATA: END OF t_zfh_kr1at_del.

DATA: BEGIN OF t_zfhnoform3 OCCURS 0.
        INCLUDE STRUCTURE zfhnoform3.
DATA: END OF t_zfhnoform3.

DATA: BEGIN OF t_zfhstatus OCCURS 0.
        INCLUDE STRUCTURE zfhstatus.
DATA: END OF t_zfhstatus.

DATA: BEGIN OF t_zfusrrel_form3 OCCURS 0.
        INCLUDE STRUCTURE zfusrrel_form3.
DATA: END OF t_zfusrrel_form3.
DATA: BEGIN OF t_zfusrrel_form3x OCCURS 0.
        INCLUDE STRUCTURE zfusrrel_form3.
DATA: END OF t_zfusrrel_form3x.

DATA: BEGIN OF t_kna1 OCCURS 0.
        INCLUDE STRUCTURE kna1.
DATA: END OF t_kna1.

DATA: BEGIN OF t_knvv OCCURS 0.
DATA: kunnr  LIKE knvv-kunnr,
      kvgr3  LIKE knvv-kvgr3,
      bezei  LIKE tvv3t-bezei,
      kvgr4  LIKE knvv-kvgr4,
      usrgroup LIKE zscl_top-usrgroup.
DATA: END OF t_knvv.

DATA: BEGIN OF t_knkk OCCURS 0.
        INCLUDE STRUCTURE knkk.
DATA: END OF t_knkk.

DATA: BEGIN OF t_out OCCURS 0.
        INCLUDE STRUCTURE zfhstblokd.
DATA: noform LIKE zfh_kr1at-noform,
      duedt  TYPE sy-datum,
      umskz1 LIKE zfh_kr1at-umskz1,
      stsrel1(1),
      stsrel2(1),
      stsrel3(1),
      stsrel4(1),
      stsrel5(1),
      icon(4),
      error(4),
      check(1).
DATA: END OF t_out.
DATA: BEGIN OF t_out1 OCCURS 0.
        INCLUDE STRUCTURE zfhstblokd.
DATA: END OF t_out1.
DATA: BEGIN OF t_out2 OCCURS 0.
        INCLUDE STRUCTURE zfhstblokd.
DATA: END OF t_out2.
DATA: BEGIN OF t_out4 OCCURS 0.
        INCLUDE STRUCTURE t_out.
DATA: END OF t_out4.

DATA: BEGIN OF t_error1 OCCURS 0.
        INCLUDE STRUCTURE t_data.
DATA: msg(100).
DATA: END OF t_error1.

DATA: BEGIN OF t_error2 OCCURS 0.
        INCLUDE STRUCTURE t_zfh_kr1at.
DATA: msg(100).
DATA: END OF t_error2.

DATA: BEGIN OF t_error3 OCCURS 0,
        kunnr  LIKE bsid-kunnr,
        vbeln  LIKE zfbid-vbeln,
        bbeln  LIKE zfbid-bbeln,
        zuonr  LIKE zfbid-zuonr,
        msg(100).
DATA: END OF t_error3.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
RANGES: ra_blart FOR bsid-blart.

DATA: va_noform  LIKE t_zfhnoform3-noform,
      va_error   TYPE i,
      va_valid   TYPE i,
      va_status  TYPE i,
      wa_header  TYPE zfhstblokh,
      va_lock    TYPE i,
      va_spld    TYPE usr01-spld,
      va_print   TYPE i,
      va_reprint(1),
      va_level1(12),
      va_level2(12),
      va_level3(12),
      va_level4(12),
      lv_level1(12),
      lv_level2(12),
      lv_level3(12),
      lv_level4(12).

DATA: p_tdform             LIKE ssfscreen-fname VALUE 'ZF_BLOK_AR_V5',  "'ZF_BLOK_AR_V3',
      p_disp               LIKE ssfctrlop-preview VALUE 'X',
      document_output_info TYPE ssfcrespd,
      job_output_info      TYPE ssfcrescl,
      job_output_options   TYPE ssfcresop.

DATA: c1   TYPE i VALUE 255,
      c2   TYPE i VALUE 3,
      c3   TYPE i VALUE 23,
      c4   TYPE i VALUE 10,
      c5   TYPE i VALUE 12,
      c6   TYPE i VALUE 15,
      c7   TYPE i VALUE 13,
      c8   TYPE i VALUE 18,
      c9   TYPE i VALUE 93,
      c10  TYPE i VALUE 4.

DATA: gv_gsber    TYPE gsber,
      gv_bukrs    TYPE bukrs.
