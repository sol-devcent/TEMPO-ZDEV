*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E009TOP
*&---------------------------------------------------------------------*
DATA : ok_code          TYPE sy-ucomm,
       gv_uri_addr      TYPE adr12-uri_addr,
       gv_print_dest    TYPE adr10-print_dest,
       gv_eqfnr         TYPE iloa-eqfnr,
       gv_remark        TYPE adrt-remark,
       gv_char          TYPE zchar1500,
       gv_tara          TYPE resb-bdmng,
       gv_bruto         TYPE resb-bdmng,
       gv_netto         TYPE resb-bdmng,
       gv_taras         TYPE resb-bdmng,
       gv_brutos        TYPE resb-bdmng,
       gv_nettos        TYPE resb-bdmng,
       gv_nmein         TYPE mara-meins,
       gv_others,gv_minmax,gv_rework,gv_ibupro.

DATA : gs_head          TYPE ztspppst004,
       gt_rawmat        TYPE STANDARD TABLE OF ztspppst004,
       gs_rawmat        TYPE ztspppst004,
       gt_002           TYPE STANDARD TABLE OF ztnpppdt002,
       gt_others        TYPE STANDARD TABLE OF ztspppst004,
       gs_others        LIKE LINE OF gt_others,
       gs_rwork         TYPE ztspppdt008.

DATA : idx   TYPE i,
       line  TYPE i,
       lines TYPE i,
       limit TYPE i,
       c1    TYPE i,
       n1    TYPE i VALUE 1,
       n2    TYPE i,
       c11   TYPE i,
       n11   TYPE i VALUE 1,
       n21   TYPE i.

DATA : gv_astad TYPE datum,
       gv_astau TYPE uzeit.
