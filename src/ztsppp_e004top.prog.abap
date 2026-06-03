*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E004TOP
*&---------------------------------------------------------------------*
DATA : ok_code          TYPE sy-ucomm,
       gs_label         TYPE ztspppst005,
       gt_kalib         TYPE STANDARD TABLE OF ztspppst005,
       gv_equnr         TYPE equi-equnr,
       gv_posnr         TYPE resb-posnr.

DATA : gv_uri_addr      TYPE adr12-uri_addr,
       gv_print_dest    TYPE tsp03d-name,
       gv_remark        TYPE adrt-remark,
       gv_eqfnr         TYPE iloa-eqfnr,
       gv_char          TYPE zchar1500,
       gv_message(100).
