*----------------------------------------------------------------------*
*   INCLUDE ZM_POTOP
*----------------------------------------------------------------------*

*----------------------------------------------------------*
* Tables
*----------------------------------------------------------*
TABLES: ekko, ekpo, sscrfields, vetvg, eket.

*----------------------------------------------------------*
* Global Data
*----------------------------------------------------------*
DATA: gv_status TYPE sy-subrc.

*----------------------------------------------------------*
* Internal Table
*----------------------------------------------------------*
DATA: BEGIN OF gt_ekko OCCURS 0,
        ebeln TYPE ebeln,
        bsart TYPE bsart,
        lifnr TYPE lifnr,
      END OF gt_ekko.

DATA: BEGIN OF gt_ekpo OCCURS 0,
        ebeln TYPE ebeln,
        ebelp TYPE ebelp,
        matnr TYPE matnr,
        werks TYPE ewerk,
        lgort TYPE lgort_d,
        menge TYPE bstmg,
        meins TYPE bstme,
      END OF gt_ekpo.

DATA: gt_eket  TYPE STANDARD TABLE OF eket INITIAL SIZE 0 WITH HEADER LINE,
      gt_seket TYPE STANDARD TABLE OF eket INITIAL SIZE 0 WITH HEADER LINE,
      gt_ekbe  TYPE STANDARD TABLE OF ekbe INITIAL SIZE 0 WITH HEADER LINE.

DATA: BEGIN OF gt_out OCCURS 0,
        ebeln         TYPE ebeln,
        ebelp         TYPE ebelp,
        bsart         TYPE bsart,
        lifnr         TYPE lifnr,
        matnr         TYPE matnr,
        werks         TYPE ewerk,
        lgort         TYPE lgort_d,
        menge         TYPE bstmg,
        meins         TYPE bstme,
        ebeln1        TYPE ebeln,
        eindt         TYPE eindt,
        belnr         TYPE ekbe-belnr,
        wamng         TYPE wamng,
        deliv_no(255),
        check(4),
      END OF gt_out.

DATA: BEGIN OF gt_error OCCURS 0,
        type     TYPE bapi_mtype,
        ebeln    TYPE ebeln,
        msg(100),
      END OF gt_error.

DATA : gt_vetvg TYPE STANDARD TABLE OF vetvg INITIAL SIZE 0,
       gt_zmpo  TYPE STANDARD TABLE OF zmpo INITIAL SIZE 0.

DATA : gv_bsart TYPE bsart.

DATA: lr_bsart TYPE RANGE OF bsart,
      ls_bsart LIKE LINE OF lr_bsart.
