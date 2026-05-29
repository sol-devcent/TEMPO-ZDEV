*----------------------------------------------------------------------*
*   INCLUDE ZDG2SD_F003TOP                                            *
*----------------------------------------------------------------------*
  TABLES: nast,
          tnapr.

  CONSTANTS: gc_taxcode LIKE a003-mwskz VALUE 'K2'.

  DATA: BEGIN OF t_nast_key,
          vbeln LIKE vbrk-vbeln,
        END OF t_nast_key.

  DATA: xscreen(1) TYPE c.

  DATA: p_tdform2 LIKE ssfscreen-fname.

  DATA: gv_petugas1 LIKE zgdtxdt0005-petugas,
        gv_jabat1 LIKE zgdtxdt0005-jabat,
        gv_petugas2 LIKE zgdtxdt0005-petugas2,
        gv_jabat2 LIKE zgdtxdt0005-jabat2,
        gv_petugas3 LIKE zgdtxdt0005-nameadm,
        gv_jabat3 LIKE zgdtxdt0005-jabatadm,
        gv_brnch LIKE zgdtxdt0005-brnch,
        gv_object LIKE zgdtxdt0005-objrange.

  DATA gv_header LIKE ztntsdstf0001h.
  DATA gt_detail TYPE TABLE OF ztntsdstf0001d WITH HEADER LINE.
  DATA gt_xkomv  TYPE TABLE OF komv WITH HEADER LINE.
  DATA gt_xvbpa  TYPE TABLE OF vbpavb WITH HEADER LINE.
  DATA gt_xvbrk  TYPE TABLE OF vbrkvb WITH HEADER LINE.
  DATA gt_xvbrp  TYPE TABLE OF vbrpvb WITH HEADER LINE.
  DATA gt_vbkd   TYPE TABLE OF vbkd WITH HEADER LINE.
  DATA gt_likp   TYPE TABLE OF likp WITH HEADER LINE.
  DATA gt_bseg   TYPE TABLE OF bseg WITH HEADER LINE.
  DATA gt_kna1   TYPE TABLE OF kna1 WITH HEADER LINE.
  DATA gt_adrc   TYPE TABLE OF adrc WITH HEADER LINE.
  DATA gt_makt   TYPE TABLE OF makt WITH HEADER LINE.
  DATA gt_t052   TYPE TABLE OF t052 WITH HEADER LINE.
  DATA gt_t052u  TYPE TABLE OF t052u WITH HEADER LINE.
  DATA gt_zgdtxdt0003 TYPE TABLE OF zgdtxdt0003 WITH HEADER LINE.
  DATA gv_tax    TYPE kbetr_kond.     " tax rate
  DATA gv_fakno(17).
  DATA gt_monthnames TYPE TABLE OF t247 WITH HEADER LINE.
  DATA gt_lampiran   TYPE TABLE OF ztntsdstf0003 WITH HEADER LINE.

  DATA gv_dmbtr  TYPE dmbtr.
  DATA gv_multi  TYPE flag.
