*----------------------------------------------------------------------*
*   INCLUDE ZS_SHIPMENT_LIST1TOP
*----------------------------------------------------------------------*
  TABLES : nast,
           tnapr.

  DATA : BEGIN OF t_nast_key,
           tknum   TYPE tknum,
         END OF t_nast_key.

  DATA : xscreen(1) TYPE c.

  DATA : et_delivery_header   LIKE bapidlvhdr OCCURS 0 WITH HEADER LINE,
         et_delivery_item     LIKE bapidlvitem OCCURS 0 WITH HEADER LINE,
         et_delivery_partner  LIKE bapidlvpartners OCCURS 0 WITH HEADER LINE,
         return               LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
         gt_header            LIKE zsstshli OCCURS 0 WITH HEADER LINE,
         gt_detail            LIKE zsstshli OCCURS 0 WITH HEADER LINE,
         wa_header            LIKE zsstshli.

  DATA : BEGIN OF gt_kna1 OCCURS 0,
         vkorg  TYPE vkorg,
         kunnr  TYPE kunnr,
       END OF gt_kna1.
