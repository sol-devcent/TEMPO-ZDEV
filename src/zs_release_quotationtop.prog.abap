*----------------------------------------------------------------------*
*   INCLUDE ZS_RELEASE_QUOTATIONTOP                                    *
*----------------------------------------------------------------------*
INCLUDE <icon>.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: vbak, jsto.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: va_error  LIKE sy-subrc.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF t_jest OCCURS 0,
        objnr  LIKE jest-objnr,
        vbeln  LIKE vbak-vbeln.
DATA: END OF t_jest.

DATA: BEGIN OF t_vbak OCCURS 0.
        INCLUDE STRUCTURE vbak.
DATA: END OF t_vbak.

DATA: BEGIN OF t_vbap OCCURS 0.
        INCLUDE STRUCTURE vbap.
DATA:   profl TYPE mara-profl,
      END OF t_vbap.

DATA: gt_zplbc TYPE TABLE OF zplbc WITH HEADER LINE.

DATA: BEGIN OF t_out OCCURS 0,
         objnr  LIKE jest-objnr,
         vbeln  LIKE vbak-vbeln,
         vtweg  LIKE vbak-vtweg,
         spart  LIKE vbak-spart,
         vkbur  LIKE vbak-vkbur,
         kunnr  LIKE vbak-kunnr,
         name1  LIKE adrc-name1,
         waerk  LIKE vbak-waerk,
         kvgr3  LIKE vbak-kvgr3,
         auart  LIKE vbak-auart,
         value  LIKE vbak-netwr,
         vsnmr_v LIKE vbak-vsnmr_v,
         text   TYPE char50,
         check(1),
         icon(4).
DATA: END OF t_out.

DATA: BEGIN OF t_error OCCURS 0,
         icon(4),
         vbeln  LIKE vbak-vbeln,
         msg(220).
DATA: END OF t_error.

FIELD-SYMBOLS: <fs_out> LIKE t_out.

DATA : gv_alkes,
       gv_tds.
