*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_EX01TOP
*&---------------------------------------------------------------------*
TABLES : sscrfields, t100a.

TYPE-POOLS : vrm.

INCLUDE <icon>.

CONTROLS : tc_order      TYPE TABLEVIEW USING SCREEN 900,
           tc_material   TYPE TABLEVIEW USING SCREEN 900,
           tc_notes      TYPE TABLEVIEW USING SCREEN 400.

TYPES : BEGIN OF ty_order,
          aufnr   TYPE caufv-aufnr,
          plnbez  TYPE caufv-plnbez,
          ktext   TYPE caufv-ktext,
          charg   TYPE afpo-charg,
          gstrp   TYPE caufv-gstrp,
          mark,
        END OF ty_order.

TYPES : BEGIN OF ty_material,
          aufnr   TYPE caufv-aufnr,
          rspos   TYPE resb-rspos,
          matnr   TYPE resb-matnr,
          maktx   TYPE makt-maktx,
          bdmng   TYPE resb-bdmng,
          meins   TYPE mara-meins,
          gstrp   TYPE caufv-gstrp,
          icon(4),
          mark,
        END OF ty_material.

*rsnum rspos aufnr matnr charg werks lgort bdter umlgo
*      enmng bdmng meins baugr

TYPES : BEGIN OF ty_resb,
           matnr  LIKE resb-matnr,
           werks  LIKE resb-werks,
           lgort  LIKE resb-lgort,
           rsnum  LIKE resb-rsnum,
           aufnr  LIKE resb-aufnr,
           charg  LIKE resb-charg,
           bdter  LIKE resb-bdter,
           bdmng  LIKE resb-bdmng,
           enmng  LIKE resb-enmng,
           meins  LIKE resb-meins,
           baugr  LIKE resb-baugr,
           maktx  LIKE makt-maktx,
           objnr  LIKE resb-objnr,
           bstrf  LIKE marc-bstrf,
           umlgo  LIKE resb-lgort,
       END OF ty_resb.

DATA : gt_order       TYPE STANDARD TABLE OF ty_order,
       gs_order       LIKE LINE OF gt_order,
       gt_xmara       TYPE STANDARD TABLE OF ty_material,
       gt_material    TYPE STANDARD TABLE OF ty_material,
       gs_material    LIKE LINE OF gt_material,
       gt_caufv       TYPE STANDARD TABLE OF caufv,
       gt_afpo        TYPE STANDARD TABLE OF afpo,
       gt_bom         TYPE STANDARD TABLE OF ty_material,
       gt_error       TYPE STANDARD TABLE OF bapiret2,
       gt_xerror      TYPE STANDARD TABLE OF bapiret2.

DATA : gt_values      TYPE TABLE OF vrm_value,
       gv_name1       TYPE t001w-name1,
       gv_lgobe       TYPE t001l-lgobe,
       gv_umlbe       TYPE t001l-lgobe,
       gv_delete(4),
       list_aufnr     TYPE caufv-aufnr,
       gv_isi,
       gv_old.

DATA : ok_code        TYPE sy-ucomm,
       lines          TYPE i,
       forder         TYPE i,
       fmaterial      TYPE i,
       fnotes         TYPE i.

DATA : gt_ltba        TYPE STANDARD TABLE OF ltba,
       gt_warehouse   TYPE STANDARD TABLE OF t320.

DATA : gt_itab        TYPE ta_itab1 OCCURS 0,
       gt_resb        TYPE STANDARD TABLE OF resb,
       gs_ltbk        TYPE ltbk,
       gt_ltbp        TYPE STANDARD TABLE OF ltbp.

TYPES : BEGIN OF ta_mchb,
           matnr LIKE mchb-matnr,
           werks LIKE mchb-werks,
           lgort LIKE mchb-lgort,
           charg LIKE mchb-charg,
           clabs LIKE mchb-clabs,
        END OF ta_mchb.

DATA : gt_mchb TYPE ta_mchb OCCURS 0.
