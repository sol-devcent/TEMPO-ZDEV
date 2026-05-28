*&---------------------------------------------------------------------*
*&  Include           ZTSPMM_E003TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_merge,
          name(30),
          html     LIKE w3html OCCURS 100,
        END OF ty_merge.

TYPES : BEGIN OF ty_006.
          INCLUDE STRUCTURE ztspmmdt006.
          TYPES :   cmatnr(100),
          maktx       TYPE makt-maktx,
          pidtxt      TYPE ztspmmdt007-pidtxt,
          padest      TYPE tsp03-padest,
          stktypt     TYPE char10,
          actqty      TYPE labst,
          copy        TYPE numc3,
        END OF ty_006.

DATA : gt_006  TYPE STANDARD TABLE OF ztspmmdt006,
       gs_head TYPE ty_006,
*       gt_detl TYPE STANDARD TABLE OF ztspmmdt006,
       gt_detl TYPE STANDARD TABLE OF ty_006,
       gs_detl LIKE LINE OF gt_detl,
       gt_prnt TYPE STANDARD TABLE OF ty_006,
       gs_prnt LIKE LINE OF gt_prnt,
       gt_mchb TYPE STANDARD TABLE OF mchb,
       gt_007  TYPE STANDARD TABLE OF ztspmmdt007.

DATA : gv_subrc TYPE sy-subrc,
       gv_new, gv_tsp,
       gv_zeile TYPE mseg-zeile,
       gv_xeile TYPE mseg-zeile.

DATA : ok_code TYPE sy-ucomm,
       idx     TYPE i,
       line    TYPE i,
       lines   TYPE i,
       limit   TYPE i,
       c       TYPE i,
       n1      TYPE i VALUE 1,
       n2      TYPE i.

DATA : message1(20),
       message2(20),
       message3(20),
       message4(20),
       message5(20),
       message6(20),
       message7(20).

DATA : g_tabgrid TYPE REF TO cl_gui_alv_grid,
       gt_bmerge TYPE swww_t_merge_table,
       gt_fmerge TYPE swww_t_merge_table,
       gt_body   TYPE swww_t_html_table,
       gt_foot   TYPE swww_t_html_table,
       gt_html   TYPE STANDARD TABLE OF w3html.
