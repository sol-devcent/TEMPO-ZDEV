FUNCTION-POOL ztdn_api.                     "MESSAGE-ID ..
TYPE-POOLS sbdst.

TABLES: ztdnsddt022, ztdnsddt022d, ztdnsddt023, ztdnsddt010, ztdnsddt011, ztdnsdst004.

TYPES: BEGIN OF ty_url,
         page     TYPE i,
         namafile TYPE string,
         url_awb  TYPE string,
       END OF ty_url.

TYPES: BEGIN OF ty_data,
         no_transaksi TYPE string, " : "YYYYMMDD_HHMMSS",
         kode_mp      TYPE string, " : "kode mp",
         kode_shop    TYPE string, " : "kode shop",
         no_order     TYPE string, " : "no order",
         no_awb       TYPE string, " : "no awb",
         no_dn        TYPE string, " : "no dn",
         count_page   TYPE p DECIMALS 0, " : 3,
         status       TYPE string, " : ""
         url_awb      TYPE STANDARD TABLE OF ty_url WITH NON-UNIQUE DEFAULT KEY,
       END OF ty_data.
TYPES: BEGIN OF ty_awbimage,
         awb_image TYPE STANDARD TABLE OF ty_data WITH NON-UNIQUE DEFAULT KEY,
       END OF ty_awbimage.

TYPES: BEGIN OF ty_items,
         material    TYPE string,
         vcrno       TYPE string,
         vcrgenerate TYPE string,
         vcramt      TYPE string,
         vcrexp      TYPE string,
       END OF ty_items.

TYPES: BEGIN OF ty_order,
         order_id         TYPE string,
         email_cust       TYPE string,
         nama_cust        TYPE string,
         method           TYPE string,
         transaction_date TYPE string,
         items            TYPE STANDARD TABLE OF ty_items WITH NON-UNIQUE DEFAULT KEY,
       END OF ty_order.
**TYPES: BEGIN OF ty_voucher,
**          order TYPE STANDARD TABLE OF ty_order WITH NON-UNIQUE DEFAULT KEY,
**      END OF ty_voucher.

DATA: gt_evoucher TYPE STANDARD TABLE OF ty_order.
DATA: gs_evoucher TYPE ty_order.
DATA: gs_items TYPE ty_items.



CONSTANTS:
  c_bds_classname TYPE sbdst_classname VALUE 'DEVC_STXD_BITMAP',
  c_bds_classtype TYPE sbdst_classtype VALUE 'OT',          " others
  c_bds_mimetype  TYPE bds_mimetp      VALUE 'application/octet-stream',
  c_bds_original  TYPE sbdst_doc_var_tg VALUE 'OR'.

DATA: gv_noawb TYPE znoawb.
DATA: gv_belnr TYPE belnr_d.
DATA: gv_message TYPE char250_d.
DATA: gv_status(1).
RANGES s_matnr FOR s940-matnr.
DATA  gv_no_order(40) .
DATA : gt_awbimage   TYPE ty_awbimage.
DATA:  gs_ztdnsddt022 TYPE ztdnsddt022.
DATA:  gt_ztdnsddt022 TYPE STANDARD TABLE OF ztdnsddt022.
DATA:  gs_ztdnsddt022d TYPE ztdnsddt022d.
DATA:  gt_ztdnsddt022d TYPE STANDARD TABLE OF ztdnsddt022d.
DATA: gt_ztdnsddt010  LIKE TABLE OF ztdnsddt010 WITH HEADER LINE.
DATA: gt_out          TYPE TABLE OF ztdnsddt010 WITH HEADER LINE.
DATA: gt_error        TYPE TABLE OF ztdnsddt011.

DATA: gw_out          LIKE LINE OF  gt_out.
DATA: gt_outlog       TYPE TABLE OF ztdnsddt010 WITH HEADER LINE.
FIELD-SYMBOLS: <fs_out> LIKE ztdnsddt010,
               <fs_err> LIKE ztdnsddt011.
