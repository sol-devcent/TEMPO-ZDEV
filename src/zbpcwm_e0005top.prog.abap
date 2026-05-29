*----------------------------------------------------------------------*
*   INCLUDE ZBPCWM_E0005TOP
*----------------------------------------------------------------------*
INCLUDE <icon>.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES : sscrfields, lagp, lqua, zbpc0005, zbpc0006.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA : ref_grid  TYPE REF TO cl_gui_alv_grid,
       selected  VALUE 'X',
       gs_layout TYPE lvc_s_layo.

DATA : gv_01c(20), gv_01  TYPE p DECIMALS 5,
gv_02c(20), gv_02  TYPE p DECIMALS 5,
gv_03c(20), gv_03  TYPE p DECIMALS 5,
gv_04c(20), gv_04  TYPE p DECIMALS 5,
gv_05c(20), gv_05  TYPE p DECIMALS 0,
gv_06c(20), gv_06  TYPE p DECIMALS 0,
gv_07c(20),
gv_08c(20),
gv_09c(20).

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : gt_header TYPE slis_t_listheader,
       wa_header TYPE slis_listheader.

DATA : gt_zbpc0005 LIKE zbpc0005 OCCURS 0 WITH HEADER LINE,
       gt_zbpc0006 LIKE zbpc0006 OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_lagp OCCURS 0,
         lgnum LIKE lagp-lgnum,
         lgtyp LIKE lagp-lgtyp,
         lgpla LIKE lagp-lgpla,
       END OF gt_lagp.

DATA : BEGIN OF gt_makt OCCURS 0,
         matnr LIKE makt-matnr,
         maktx LIKE makt-maktx,
       END OF gt_makt.

DATA : BEGIN OF gt_out OCCURS 0.
         INCLUDE STRUCTURE zbpc0005.
DATA :   maktx      LIKE makt-maktx,
         selisih    LIKE zbpc0005-gesme,
         ausme      TYPE lqua-ausme,
         gudang(40),
         check(1),
         icon(4),
       END OF gt_out.

DATA : BEGIN OF gt_error OCCURS 0,
         icon(4),
         lgnum   LIKE zbpc0005-lgnum,
         lgtyp   LIKE zbpc0005-lgtyp,
         lgpla   LIKE zbpc0005-lgpla,
         ivnum   LIKE zbpc0005-ivnum,
         mess    TYPE bdc_vtext1,
       END OF gt_error.

DATA : gt_lqua    TYPE STANDARD TABLE OF lqua.
