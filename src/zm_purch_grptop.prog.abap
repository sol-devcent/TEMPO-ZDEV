*----------------------------------------------------------------------*
*   INCLUDE ZM_PURCH_GRPTOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES : zmmattnt, sscrfields.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
CONTROLS tc_zmmattnt TYPE TABLEVIEW USING SCREEN 500.

DATA : lines     TYPE i,
       fill      TYPE i,
       ok_code   TYPE sy-ucomm.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : BEGIN OF gt_zmmattnt OCCURS 0,
         ekorg  TYPE ekorg,
         ekgrp  TYPE ekgrp,
         zhier  TYPE zhier,
         zlvl	  TYPE zlvltnt,
         zdesc  TYPE zdesch_tnt,
         zdesc1 TYPE zdesc1_tnt,
         mark(1),
       END OF gt_zmmattnt.

DATA : gt_temp  LIKE gt_zmmattnt OCCURS 0 WITH HEADER LINE,
       gt_out   LIKE zmmattnt OCCURS 0 WITH HEADER LINE,
       gt_fr    LIKE zmmattnt OCCURS 0 WITH HEADER LINE,
       gt_to    LIKE zmmattnt OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_out1 OCCURS 0,
          zhier01   TYPE zhier,
          zdesc01   TYPE zdesc,
          ztext01(50),
          zhier02   TYPE zhier,
          zdesc02   TYPE zdesc,
          ztext02(50),
          zhier03   TYPE zhier,
          zdesc03   TYPE zdesc,
          ztext03(50),
          zhier04   TYPE zhier,
          zdesc04   TYPE zdesc,
          ztext04(50),
          zhier05   TYPE zhier,
          zdesc05   TYPE zdesc,
          ztext05(50),
          zdesc1 TYPE zdesc1_tnt,
        END OF gt_out1.
