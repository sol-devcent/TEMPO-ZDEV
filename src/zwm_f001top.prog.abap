*&---------------------------------------------------------------------*
*&  Include           ZWM_F001TOP
*&---------------------------------------------------------------------*
TABLES : zwmdt004, zwmdt006, zwmdt007, ltap, sscrfields.

TYPES : BEGIN OF ty_plant,
          lgnum   TYPE t320-lgnum,
          werks   TYPE t001w-werks,
          name1   TYPE t001w-name1,
        END OF ty_plant.

TYPES : BEGIN OF ty_sum,
          lgnum   TYPE zwmdt004-lgnum,
          tknum   TYPE zwmdt004-tknum,
          posnr   TYPE zwmdt004-posnr,
          matnr   TYPE zwmdt004-matnr,
          charg   TYPE zwmdt004-charg,
          lfimg   TYPE zwmdt004-lfimg,
          vrkme   TYPE zwmdt004-vrkme,
          nsolm   TYPE zwmdt004-lfimg,
          rusak   TYPE zwmdt004-lfimg,
        END OF ty_sum.

DATA : gt_004     TYPE STANDARD TABLE OF zwmdt004,
       gt_006     TYPE STANDARD TABLE OF zwmdt006,
       gt_ltap    TYPE STANDARD TABLE OF ltap,
       gt_head    TYPE STANDARD TABLE OF zwmst004,
       gs_head    TYPE zwmst004,
       gt_detl    TYPE STANDARD TABLE OF zwmst004,
       gt_kond    TYPE STANDARD TABLE OF zwmst004x,
       gt_plant   TYPE STANDARD TABLE OF ty_plant,
       gt_makt    TYPE STANDARD TABLE OF makt,
       gt_lips    TYPE STANDARD TABLE OF lips,
       gt_vttp    TYPE STANDARD TABLE OF vttp.

DATA : gv_vbeln(10),
       gv_object  TYPE inri-object,
       gv_sub(50).

FIELD-SYMBOLS : <fs_gt>   TYPE zwmst004x,
                <fs_tab>  TYPE STANDARD TABLE.

DATA : gt_007     TYPE STANDARD TABLE OF zwmdt007,
       gt_ekpo    TYPE STANDARD TABLE OF ekpo,
       gt_ekko    TYPE STANDARD TABLE OF ekko,
       gt_mseg    TYPE STANDARD TABLE OF mseg.
