*----------------------------------------------------------------------*
*   INCLUDE ZTNTSD_F0002TOP                                            *
*----------------------------------------------------------------------*
  TABLES : nast,
           tnapr.

  DATA : BEGIN OF t_nast_key,
           vbeln LIKE likp-vbeln,
         END OF t_nast_key.

  DATA : xscreen(1) TYPE c.

  DATA : gt_likp  LIKE likp OCCURS 0 WITH HEADER LINE,
         gt_lips  LIKE lips OCCURS 0 WITH HEADER LINE,
         gt_vbkd  LIKE vbkd OCCURS 0 WITH HEADER LINE,
         gt_marm  LIKE marm OCCURS 0 WITH HEADER LINE.

  DATA : wa_zsign LIKE zsign,
         wa_tvst  LIKE tvst,
         wa_adrc  LIKE adrc,
         wa_zpbf  LIKE zpbf.

  DATA : BEGIN OF gt_kna1 OCCURS 0,
           kunnr    TYPE kunnr,
           name1    TYPE ad_name1,
           name2    TYPE ad_name2,
           name3    TYPE ad_name3,
          END OF gt_kna1.

  DATA : BEGIN OF gt_detail OCCURS 0.
          INCLUDE STRUCTURE ztntsdstf0002.
  DATA : END OF gt_detail.

  TYPES : BEGIN OF ty_header.
          INCLUDE STRUCTURE ztntsdstf0002.
  TYPES : END OF ty_header.

  DATA : gs_header TYPE ty_header.
