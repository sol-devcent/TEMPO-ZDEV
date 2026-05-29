*----------------------------------------------------------------------*
*   INCLUDE ZS_STATUS_DELIVERYTOP
*----------------------------------------------------------------------*
TYPE-POOLS cxtab.

INCLUDE <icon>.

CONTROLS tc_dn   TYPE TABLEVIEW USING SCREEN 500.
CONTROLS tc_out  TYPE TABLEVIEW USING SCREEN 100.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES : sscrfields, vttk, likp, zsextrec.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA : fill            TYPE i,
       lines           TYPE sy-loopc,
       ok_code         TYPE sy-ucomm,
       save_ok         TYPE sy-ucomm,
       gv_subrc        TYPE sy-subrc,
       g_tc_out_lines  LIKE sy-loopc.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : gt_zsdnstat      LIKE zmshphistr OCCURS 0 WITH HEADER LINE,
       gt_zsextrecreas  LIKE zsextrecreas OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF gt_dn OCCURS 0,
         vbeln  TYPE vbeln,
         sortf  TYPE numc4,
         check(1).
DATA   END   OF gt_dn.

DATA : wa_dn  LIKE gt_dn.

DATA : gt_vttk TYPE STANDARD TABLE OF vttk INITIAL SIZE 0
               WITH HEADER LINE.
DATA : gt_zsextrec TYPE STANDARD TABLE OF zsextrec INITIAL SIZE 0
                   WITH HEADER LINE.

DATA : BEGIN OF gt_vttp OCCURS 0,
         tknum  TYPE tknum,
         tpnum  TYPE tpnum,
         vbeln  TYPE vbeln_vl,
         erdat  TYPE erdat,
       END OF gt_vttp.

DATA : gt_likp TYPE STANDARD TABLE OF likp INITIAL SIZE 0
               WITH HEADER LINE.

DATA : BEGIN OF gt_kna1 OCCURS 0,
         kunnr   TYPE kna1-kunnr,
         name1   TYPE kna1-name1,
       END OF gt_kna1.

DATA : BEGIN OF gt_cust OCCURS 0,
         vbeln   TYPE vbeln_vl,
         crdat   TYPE podat,
         crtim   TYPE potim,
         predat  TYPE datum,
         pretim  TYPE uzeit,
       END OF gt_cust.

DATA : BEGIN OF gt_vbss OCCURS 0,
         sammg  TYPE sammg,
         vbeln  TYPE vbeln,
       END OF gt_vbss.

DATA : BEGIN OF gt_out OCCURS 0,
         tknum   TYPE tknum,
         vbeln   TYPE vbeln_vl,
         sammg   TYPE sammg,
         zstat   TYPE zreason2,
         zdesc   TYPE zreason1,
         crdat   TYPE podat,
         crtim   TYPE potim,
         predat  TYPE datum,
         pretim  TYPE uzeit,
         sortf   TYPE sortf4,
         icon(4),
         check(1),
         delvgrp(1),
         crexrsdesc   TYPE zsextrecreas-crexrsdesc,
         kunnr        TYPE kna1-kunnr,
         name1        TYPE kna1-name1,
         zreason      TYPE zmshphistr-zreason,
         zreason1     TYPE zreason1,
       END OF gt_out.
DATA : gs_out    LIKE gt_out.
DATA : gt_xout   LIKE gt_out OCCURS 0 WITH HEADER LINE.

DATA gt_zmshphist TYPE TABLE OF zmshphist WITH HEADER LINE.
DATA gt_zmshphistr TYPE TABLE OF zmshphistr WITH HEADER LINE.

DATA gs_cntrl TYPE zscust_control.

DATA gv_flag.
DATA : dynpfields     TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0.

DATA: gv_disable(1), gv_enable(1).

FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.
