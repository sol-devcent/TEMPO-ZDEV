*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E003TOP
*&---------------------------------------------------------------------*
DATA : gt_mkpf        TYPE STANDARD TABLE OF mkpf,
       gt_mseg        TYPE STANDARD TABLE OF mseg,
       gt_afpo        TYPE STANDARD TABLE OF afpo,
       gt_resb        TYPE STANDARD TABLE OF resb,
       gt_afvu        TYPE STANDARD TABLE OF afvu,
       gs_print       TYPE ztspppst004,
       gt_label       TYPE STANDARD TABLE OF ztspppst004,
       gt_003         TYPE STANDARD TABLE OF ztspppdt003.

DATA : ok_code    TYPE sy-ucomm,
       gv_message(128),
       gv_werks   TYPE mseg-werks.
