*----------------------------------------------------------------------*
*   INCLUDE ZKMMMM_R002TOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES : s076.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
TYPES : BEGIN OF ty_933,
          spmon TYPE spmon,
          werks TYPE werks_d,
          matnr TYPE matnr,
          bwart TYPE bwart.
TYPES : END OF ty_933.


*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA : BEGIN OF gt_out OCCURS 0,
         wenux   TYPE wenux,
         pmnux   TYPE pmnux,
         maktx   TYPE maktx,
         spmon   TYPE spmon,
         absat   TYPE bstmg,
         rofo1   TYPE bstmg,
         rofo2   TYPE bstmg,
         rofo3   TYPE bstmg,
         rofo4   TYPE bstmg,
         rofo5   TYPE bstmg,
         rofo6   TYPE bstmg,
         menge   TYPE bstmg,
         meins   TYPE bstme,
         produ   TYPE mc_meng,
         subcon  TYPE mc_meng,
         deliv   TYPE mc_meng,
         end30   TYPE gsbest,
         end30x  TYPE gsbest,
         end2010 TYPE gsbest,
         end3010 TYPE gsbest,
         end2300 TYPE gsbest,
         end2310 TYPE gsbest,

         total   TYPE mc_meng,
         end20   TYPE gsbest,
         end20x  TYPE gsbest,
         gr3006  TYPE gsbest,
         outst   TYPE mc_meng,

         labst TYPE labst,
         insme TYPE insme.
DATA   END OF gt_out.

DATA : BEGIN OF gt_s076 OCCURS 0,
         vrsio TYPE vrsio,
         spmon TYPE spmon,
         pmnux TYPE pmnux,
         wenux TYPE wenux,
         absat TYPE absat,
         produ TYPE produ.
DATA   END   OF gt_s076.

DATA : BEGIN OF gt_rofo OCCURS 0,
         vrsio TYPE vrsio,
         spmon TYPE spmon,
         pmnux TYPE pmnux,
         wenux TYPE wenux,
         absat TYPE absat,
         produ TYPE produ.
DATA   END   OF gt_rofo.

DATA : BEGIN OF gt_makt OCCURS 0,
         matnr TYPE matnr,
         maktx TYPE maktx,
         meins TYPE meins.
DATA : END OF gt_makt.

DATA : BEGIN OF gt_po OCCURS 0,
         ebeln TYPE ebeln,
         matnr TYPE matnr,
         reswk TYPE reswk,
         menge TYPE bstmg,
         ebelp TYPE ebelp.
DATA : END OF gt_po.

DATA : BEGIN OF gt_931 OCCURS 0,
         werks TYPE werks_d,
         matnr TYPE matnr,
         spmon TYPE spmon,
         lgort TYPE lgort_d,
         bwart TYPE bwart.
DATA : END OF gt_931.

DATA : BEGIN OF gt_s931 OCCURS 0,
         werks TYPE werks_d,
         matnr TYPE matnr,
         shkzg TYPE shkzg,
         spmon TYPE spmon,
         lgort TYPE lgort_d,
         bwart TYPE bwart,
         basme TYPE meins,
         mzubb TYPE mzubb,
         magbb TYPE magbb,
         menge TYPE mc_meng.
DATA : END OF gt_s931.

DATA : BEGIN OF gt_039 OCCURS 0,
         werks TYPE werks_d,
         matnr TYPE matnr,
         spmon TYPE spmon,
         lgort TYPE lgort_d.
DATA : END OF gt_039.

DATA : BEGIN OF gt_mardh OCCURS 0,
         werks TYPE werks_d,
         matnr TYPE matnr,
         lgort TYPE lgort_d,
         labst TYPE labst,
         insme TYPE insme,
         einme TYPE einme,
         lfgja TYPE lfgja,
         lfmon TYPE lfmon.
DATA : END OF gt_mardh.

DATA : gt_933   TYPE STANDARD TABLE OF ty_933.

DATA : gt_s933  TYPE STANDARD TABLE OF s933.

DATA : BEGIN OF gt_mardh_qi_uu OCCURS 0,
         werks TYPE werks_d,
         matnr TYPE matnr,
         lgort TYPE lgort_d,
*         labst TYPE labst,
*         insme TYPE insme,
*         einme TYPE einme,
         lfgja TYPE lfgja,
         labst TYPE labst,
         insme TYPE insme,
         lfmon TYPE lfmon.
DATA : END OF gt_mardh_qi_uu.
