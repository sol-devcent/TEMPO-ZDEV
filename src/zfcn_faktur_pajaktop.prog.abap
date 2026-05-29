*----------------------------------------------------------------------*
*   INCLUDE ZFCN_FAKTUR_PAJAKTOP                                       *
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: vbrk, kna1vv.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*


*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF t_vbrk OCCURS 0.
        INCLUDE STRUCTURE vbrk.
DATA: END OF t_vbrk.

DATA: BEGIN OF t_knkli OCCURS 0.
        INCLUDE STRUCTURE vbrk.
DATA: END OF t_knkli.

DATA: BEGIN OF t_kna1vv OCCURS 0.
        INCLUDE STRUCTURE kna1vv.
DATA: END OF t_kna1vv.

DATA: BEGIN OF t_itab OCCURS 0,
         vkbur  LIKE kna1vv-vkbur,
         knkli  LIKE vbrk-knkli,
         name1  LIKE kna1vv-name1,
         vbeln  LIKE vbrk-vbeln,
         fkdat  LIKE vbrk-fkdat,
         text(132).
DATA: END OF t_itab.
