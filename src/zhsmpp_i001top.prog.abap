*&---------------------------------------------------------------------*
*&  Include           ZHSMPP_I001TOP
*&---------------------------------------------------------------------*
TABLES: pgmi, plaf, eban.
TYPES : BEGIN OF ty_mara,
          matnr   TYPE mara-matnr,
          werks   TYPE marc-werks,
          mtart   TYPE mara-mtart,
          meins   TYPE mara-meins,
          mprof   TYPE mara-mprof,
        END OF ty_mara.

TYPES : BEGIN OF ty_makt,
          matnr   TYPE makt-matnr,
          maktx   TYPE makt-maktx,
        END OF ty_makt.


TYPES: BEGIN OF ty_detail,
         no_item TYPE string,
         material TYPE string,
         qty TYPE string,
         satuan TYPE string,
       END OF ty_detail.

TYPES: BEGIN OF ty_header,
         plant TYPE string, "werks,
         sloc TYPE string,
         doc_type TYPE string,
         plan_order TYPE string, "plnum,
         delivery_date TYPE string, "plaf-psttr,
         release_date TYPE string,
         material TYPE string,
         qty TYPE string,
         uom TYPE string,
"         detail TYPE STANDARD TABLE OF ty_detail WITH NON-UNIQUE DEFAULT KEY,
       END OF ty_header.
TYPES: BEGIN OF ty_plan_order,
         plan_order TYPE STANDARD TABLE OF ty_header WITH NON-UNIQUE DEFAULT KEY,
       END OF ty_plan_order.
DATA: gt_out TYPE STANDARD TABLE OF ty_header WITH HEADER LINE.
DATA: gs_plan_order TYPE ty_plan_order.
DATA: gt_plaf TYPE STANDARD TABLE OF plaf WITH HEADER LINE.
DATA: gt_eban TYPE STANDARD TABLE OF eban WITH HEADER LINE.
DATA: gs_plaf TYPE plaf.
DATA: gs_eban TYPE eban.
DATA: gt_mara           TYPE STANDARD TABLE OF ty_mara.
DATA: gv_mtart          TYPE mara-mtart VALUE 'PROD'.
DATA: gs_count TYPE i.
