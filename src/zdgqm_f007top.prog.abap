*----------------------------------------------------------------------*
*   INCLUDE ZTDSFORMTEMPTOP                                            *
*----------------------------------------------------------------------*
  TABLES: nast,
          tnapr.

  DATA: BEGIN OF t_nast_key,
          qmnum LIKE qmel-qmnum,
        END OF t_nast_key.

  DATA: xscreen(1) TYPE c.

  DATA: wa_zgdqmst0007 LIKE zgdqmst0007.

*  DATA: BEGIN OF gt_detail OCCURS 0.
*          INCLUDE STRUCTURE zshipd.
*  DATA: END OF gt_detail.

*  TYPES: BEGIN OF ty_header.
*          INCLUDE STRUCTURE zshiph.
*  TYPES: END OF ty_header.

*  DATA: wa_header TYPE ty_header.
