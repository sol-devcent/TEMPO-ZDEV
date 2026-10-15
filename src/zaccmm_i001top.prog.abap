*&---------------------------------------------------------------------*
*&  Include           ZSFASD_I0001T01
*&---------------------------------------------------------------------*
  TYPE-POOLS: truxs.

  TABLES: zaccmmdt001.

  TYPES: BEGIN OF ty_c,
            company(2),
*            ivnr TYPE zivnr,
            ivnr(5),
            brcod(1),
            ivtyp(1),
            acode(3),
            sqcode(2),
            scode(2),
            nobatch(10),
            ed(10),
            sn(20),
            aggr1(20),
            aggr2(20),
            matnr TYPE matnr,
            ivnr7 TYPE zivnr,
         END OF ty_c.

  CONSTANTS : c_starttext(20) TYPE c    VALUE 'CSN'.

  DATA: gt_zaccmmdt001 TYPE TABLE OF zaccmmdt001 WITH HEADER LINE.

  DATA: gt_zaccdta TYPE TABLE OF zaccdta WITH HEADER LINE.

  DATA: gt_itab_c TYPE ty_c OCCURS 0 WITH HEADER LINE,
        gt_mara   TYPE TABLE OF mara WITH HEADER LINE.

  DATA: gv_type(1), gv_error(1), gv_flag(1).
  DATA: fileindex TYPE i.
  DATA: gv_msg TYPE char200.

  DATA: v_interfacein(125) TYPE c,
        v_interfacedone(125) TYPE c,
        v_interfaceerror(125) TYPE c,
        v_file_prefix(20) TYPE c.

  FIELD-SYMBOLS: <fs_zaccmmdt001> LIKE gt_zaccmmdt001.
