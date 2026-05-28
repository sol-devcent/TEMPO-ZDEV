*&---------------------------------------------------------------------*
*&  Include           ZQM_COATOP
*&---------------------------------------------------------------------*
TABLES : zwmdt004, nast, tnapr, sscrfields, qals.

TYPES : BEGIN OF ty_key,
          ebeln   TYPE ekko-ebeln,
        END OF ty_key.

DATA : gv_kschl   TYPE sna_kschl,
       gv_subrc   TYPE sy-subrc.

DATA : xscreen.

DATA : gt_qals    TYPE STANDARD TABLE OF qals,
       gt_qcvm    TYPE STANDARD TABLE OF qcvm,
       gt_makt    TYPE STANDARD TABLE OF makt,
       gt_mch1    TYPE STANDARD TABLE OF mch1,
       gt_qamr    TYPE STANDARD TABLE OF qamr,
       gt_qasr    TYPE STANDARD TABLE OF qasr,
       gt_qase    TYPE STANDARD TABLE OF qase,
       gt_qpmt    TYPE STANDARD TABLE OF qpmt.

DATA : gt_head    TYPE STANDARD TABLE OF zqmstcoa,
       gs_head    LIKE LINE OF gt_head,
       gt_detl    TYPE STANDARD TABLE OF zqmstcoa.

DATA : t_nast_key TYPE STANDARD TABLE OF ty_key.
