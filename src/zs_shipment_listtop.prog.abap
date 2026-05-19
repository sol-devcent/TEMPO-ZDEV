*----------------------------------------------------------------------*
*   INCLUDE ZS_SHIPMENT_LISTTOP
*----------------------------------------------------------------------*
  TABLES : nast,
           tnapr.

  DATA : BEGIN OF t_nast_key,
           tknum TYPE tknum,
         END OF t_nast_key.

  DATA : xscreen(1) TYPE c.

  DATA : et_delivery_header  LIKE bapidlvhdr OCCURS 0 WITH HEADER LINE,
         et_delivery_item    LIKE bapidlvitem OCCURS 0 WITH HEADER LINE,
         et_delivery_partner LIKE bapidlvpartners OCCURS 0 WITH HEADER LINE,
         return              LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
         gt_detail           LIKE zsstshli OCCURS 0 WITH HEADER LINE,
         wa_header           LIKE zsstshli,
         gt_003              TYPE STANDARD TABLE OF zwmdt003.

  DATA : gv_active.


*  TYPES: BEGIN OF ty_sammg,
*    sammg TYPE vbss-sammg,
*  END OF ty_sammg.

  DATA: wa_sammg TYPE zgroup_vbss.
