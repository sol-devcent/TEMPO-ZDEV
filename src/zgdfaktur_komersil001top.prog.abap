*----------------------------------------------------------------------*
*   INCLUDE ZGDFAKTUR_KOMERSIL001TOP                                   *
*----------------------------------------------------------------------*
INCLUDE <icon>.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: vbrk, zkomernr, sscrfields.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: va_sts   TYPE i,
      va_vatno LIKE zkomernr-vatno,
      va_tabix LIKE sy-tabix,
      va_update(1),
      va_datab  LIKE zproject-datab.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF t_vbrk OCCURS 0.
        INCLUDE STRUCTURE vbrk.
DATA: END OF t_vbrk.

DATA: BEGIN OF t_zgdsdkomer OCCURS 0.
        INCLUDE STRUCTURE zgdsdkomer.
DATA: END OF t_zgdsdkomer.

DATA: BEGIN OF t_zkomernr OCCURS 0.
        INCLUDE STRUCTURE zkomernr.
DATA: END OF t_zkomernr.

DATA: BEGIN OF t_out OCCURS 0.
        INCLUDE STRUCTURE zgdsdkomer.
DATA: icon(4).
DATA: END OF t_out.
DATA: BEGIN OF t_out1 OCCURS 0.
        INCLUDE STRUCTURE zgdsdkomer.
DATA: check(1).
DATA: END OF t_out1.
DATA: BEGIN OF t_data OCCURS 0.
        INCLUDE STRUCTURE zgdsdkomer.
DATA: END OF t_data.
