*----------------------------------------------------------------------*
*   INCLUDE ZTNPQM_F001TOP
*----------------------------------------------------------------------*
  TABLES: nast,tnapr,mkpf,mseg.

  CONSTANTS : c_smartform_name  TYPE tdsfname VALUE 'ZTSPQM_SF004QR_A7'.

  DATA: BEGIN OF t_nast_key,
          matnr LIKE mara-matnr,
          mjahr LIKE mseg-mjahr,
        END OF t_nast_key.

  DATA: xscreen(1) TYPE c.

  DATA: BEGIN OF gt_grlabel OCCURS 0.
          INCLUDE STRUCTURE ztnpqmst004.
  DATA: END OF gt_grlabel.

  DATA : gw_qclabel LIKE LINE OF gt_grlabel,
         gt_mkpf  TYPE TABLE OF mkpf WITH HEADER LINE,
         gt_mseg  TYPE TABLE OF mseg WITH HEADER LINE,
         gt_t001w TYPE TABLE OF t001w WITH HEADER LINE,
         gt_mara  TYPE TABLE OF mara WITH HEADER LINE,
         gt_makt  TYPE TABLE OF makt WITH HEADER LINE,
         gt_marm  TYPE TABLE OF marm WITH HEADER LINE,
         gt_mch1  TYPE TABLE OF mch1 WITH HEADER LINE,
         gt_001   TYPE STANDARD TABLE OF zppdt001,
         gs_001   TYPE zppdt001.

  DATA : gv_lblno TYPE numc10.

  DATA : t_marm         TYPE STANDARD TABLE OF marm INITIAL SIZE 0,
         t_mch1         TYPE STANDARD TABLE OF mch1 INITIAL SIZE 0,
         gt_zwmpalvnd   TYPE STANDARD TABLE OF zwmpalvnd INITIAL SIZE 0.

  DATA : gv_error   TYPE sy-subrc,
         gv_add     TYPE i.

  DATA gv_host   TYPE rfcdisplay-rfchost.
  DATA gv_flag.

  FIELD-SYMBOLS: <fs_grlabel> LIKE gt_grlabel.
