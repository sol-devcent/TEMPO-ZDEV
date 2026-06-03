*----------------------------------------------------------------------*
*   INCLUDE ZTDS_REPORT_TEMPTOP                                        *
*----------------------------------------------------------------------*
INCLUDE <icon>.

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: zssutdt022,zv_kna1knvv.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: gd_extension(3).

CONSTANTS: gc_alfabet1 TYPE char26 VALUE 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
           gc_alfabet2 TYPE char26 VALUE 'abcdefghijklmnopqrtsuvwxyz'.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
TYPES: BEGIN OF t_excel,
         row   LIKE alsmex_tabline-row,
         col   LIKE alsmex_tabline-col,
         value LIKE alsmex_tabline-value,
       END OF t_excel.

DATA: i_excel    TYPE t_excel OCCURS 0,
      sw(1),
      wa_excel   TYPE t_excel.

DATA: BEGIN OF t_upload OCCURS 0,
        pernr TYPE pernr_d,
        kunn2 TYPE kunn2,
        kunnr TYPE kunnr,
        sun1 TYPE char1,
        mon1 TYPE char1,
        tue1 TYPE char1,
        wed1 TYPE char1,
        thu1 TYPE char1,
        fri1 TYPE char1,
        sat1 TYPE char1,
        sun2 TYPE char1,
        mon2 TYPE char1,
        tue2 TYPE char1,
        wed2 TYPE char1,
        thu2 TYPE char1,
        fri2 TYPE char1,
        sat2 TYPE char1,
        sun3 TYPE char1,
        mon3 TYPE char1,
        tue3 TYPE char1,
        wed3 TYPE char1,
        thu3 TYPE char1,
        fri3 TYPE char1,
        sat3 TYPE char1,
        sun4 TYPE char1,
        mon4 TYPE char1,
        tue4 TYPE char1,
        wed4 TYPE char1,
        thu4 TYPE char1,
        fri4 TYPE char1,
        sat4 TYPE char1,
        sun5 TYPE char1,
        mon5 TYPE char1,
        tue5 TYPE char1,
        wed5 TYPE char1,
        thu5 TYPE char1,
        fri5 TYPE char1,
        sat5 TYPE char1,
        counter LIKE zssutdt022-counter,
      END OF t_upload.

DATA: BEGIN OF t_out OCCURS 0.
        INCLUDE STRUCTURE zssutdt022.
DATA:   name1 LIKE kna1-name1,
        chkbox(1),
        icon(4),
        msg(2),
      END OF t_out.

DATA  BEGIN OF t_kna1 OCCURS 1.
DATA:   kunnr TYPE kunnr,
        name1 TYPE name1_gp,
        vkbur TYPE vkbur.
DATA  END   OF t_kna1.

DATA  BEGIN OF t_rout OCCURS 1.
        INCLUDE STRUCTURE knvp.
DATA  END   OF t_rout.

DATA  BEGIN OF t_slsmn OCCURS 1.
        INCLUDE STRUCTURE knvp.
DATA  END   OF t_slsmn.

DATA : gv_subrc   TYPE sy-subrc.

DATA : gt_022 TYPE STANDARD TABLE OF zssutdt022 INITIAL SIZE 0.
