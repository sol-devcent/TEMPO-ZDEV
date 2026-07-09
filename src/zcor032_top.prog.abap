*&---------------------------------------------------------------------*
*&  Include           ZCOR032_TOP
*&---------------------------------------------------------------------*

TABLES: ce18010, kna1, zcodt017, cepc, sscrfields.

TYPES: BEGIN OF ty_detl,
         prctr        TYPE ce18010-prctr,
         ktext        TYPE cepct-ktext,
         wwpgr        TYPE ce18010-wwpgr,
         kndnr        TYPE ce18010-kndnr,
         name1        TYPE kna1-name1,
         status       TYPE zcodt017-status,
         rec_waers    TYPE ce18010-rec_waers,
         net_sales    TYPE ce18010-vv801,
         cogs         TYPE ce18010-vvd11,
         gross_profit TYPE ce18010-vv801,
       END OF ty_detl.


DATA: it_detl     TYPE TABLE OF zcor32_struct,
      wa_detl     TYPE zcor32_struct,
      it_zcodt017 TYPE TABLE OF zcodt017,
      intern      LIKE alsmex_tabline OCCURS 0 WITH HEADER LINE.
