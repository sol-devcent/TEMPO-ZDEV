*----------------------------------------------------------------------*
*   INCLUDE ZM_RETURN_STOCK_NEWTOP                                     *
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: zmm_ret_stock, sscrfields.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: va_budat  LIKE sy-datum.
RANGES: ra_budat  FOR mkpf-budat,
        ra_bwart  FOR s931-bwart,
        ra_inblk  FOR s931-bwart,
        ra_otblk  FOR s931-bwart,
        ra_inuu   FOR s931-bwart,
        ra_otuu   FOR s931-bwart,
        ra_inqi   FOR s931-bwart,
        ra_otqi   FOR s931-bwart.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF t_vdata OCCURS 0.
        INCLUDE STRUCTURE zmm_ret_stock.
DATA: maktx  LIKE makt-maktx,
      openb  LIKE zmm_ret_stock-speme,
      openu  LIKE zmm_ret_stock-labst,
      openq  LIKE zmm_ret_stock-insme,
      color(3),
      rows   TYPE i.
DATA: END OF t_vdata.

DATA: t_open    LIKE zmm_ret_stock OCCURS 0 WITH HEADER LINE,
      t_mutasi  LIKE t_vdata OCCURS 0 WITH HEADER LINE,
      t_s931    LIKE s931 OCCURS 0 WITH HEADER LINE,
      t_mkpf    LIKE mkpf OCCURS 0 WITH HEADER LINE,
      t_mseg    LIKE mseg OCCURS 0 WITH HEADER LINE,
      t_s934    LIKE s934 OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF t_result OCCURS 0.
        INCLUDE STRUCTURE zmm_ret_stock.
DATA: maktx   LIKE makt-maktx,
      openb1  LIKE zmm_ret_stock-speme,
      openb(17),
      inb1(17),
      otb1(17),
      endb1  LIKE zmm_ret_stock-speme,
      endb(17),
      endvb(17),

      openu1  LIKE zmm_ret_stock-labst,
      openu(17),
      inu1(17),
      otu1(17),
      endu1  LIKE zmm_ret_stock-labst,
      endu(17),
      endvu(17),

      openq1  LIKE zmm_ret_stock-insme,
      openq(17),
      inq1(17),
      otq1(17),
      endq1  LIKE zmm_ret_stock-insme,
      endq(17),
      endvq(17),

      color(3),
      rows    TYPE i,
      lines   TYPE i,
      break   TYPE i.
DATA: END OF t_result.

DATA: BEGIN OF t_werks OCCURS 0,
        werks LIKE t001w-werks,
      END OF t_werks.

DATA: BEGIN OF t_matkl OCCURS 0,
        matkl LIKE t023-matkl,
      END OF t_matkl.
