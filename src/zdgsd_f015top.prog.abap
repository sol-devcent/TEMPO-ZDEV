*----------------------------------------------------------------------*
*   INCLUDE ZDGSD_F015TOP                                              *
*----------------------------------------------------------------------*
TYPE-POOLS: vt04, vsep, v54a1.

TABLES: nast,
        tnapr.

CONSTANTS:
      BEGIN OF wbstk,                  "Warenbewegungsstatus
        blank    VALUE ' ',            "- nicht relevant
        a        VALUE 'A',            "- relevant, offen
        b        VALUE 'B',            "- teilweise erledigt
        c        VALUE 'C',            "- vollstaendig
      END   OF wbstk.

CONSTANTS:
  BEGIN OF c_scd_sim,
    so      TYPE i VALUE 1,    "sales order
    ship    TYPE i VALUE 2,    "shipment general, e.g. for comparison
    ship_d  TYPE i VALUE 3,    "shipment dialog, e.g.shipment processing
    info    TYPE i VALUE 4,    "generic info
  END   OF c_scd_sim.

DATA: BEGIN OF t_nast_key,
        tknum LIKE vttk-tknum,
      END OF t_nast_key.

DATA: xscreen(1) TYPE c.

DATA: t_bsik  LIKE bsik OCCURS 0 WITH HEADER LINE,
      t_vttk  LIKE vttk OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF t_tvrot OCCURS 0,
        route  LIKE tvrot-route,
        bezei  LIKE tvrot-bezei.
DATA: END OF t_tvrot.

DATA: BEGIN OF t_detail OCCURS 0.
        INCLUDE STRUCTURE zdgstsd_pv_detail.
DATA: END OF t_detail.

DATA: BEGIN OF t_simulate OCCURS 0.
        INCLUDE STRUCTURE zdgstsd_pv_detail.
DATA: END OF t_simulate.

DATA: t_header TYPE zdgstsd_pv_header.
