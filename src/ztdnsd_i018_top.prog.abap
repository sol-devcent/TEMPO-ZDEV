*----------------------------------------------------------------------*
***INCLUDE ZTDNSD_I012_TOP .
*----------------------------------------------------------------------*
TABLES: ztdnfidt005.
TYPES: BEGIN OF t_update,
         no_dn         TYPE string,
         no_order      TYPE string,
         status_update TYPE string,
       END OF t_update.

TYPES: BEGIN OF t_payment,
         no_dn          TYPE string,
         no_order       TYPE string,
         payment_status TYPE string,
         bayar_via      TYPE string,
         bayar_tgl      TYPE string,
       END OF t_payment.
TYPES: BEGIN OF payment,
         payment TYPE STANDARD TABLE OF t_payment WITH NON-UNIQUE DEFAULT KEY,
       END OF payment.
TYPES: BEGIN OF result,
         result TYPE STANDARD TABLE OF t_update WITH NON-UNIQUE DEFAULT KEY,
       END OF result.
DATA: gv_str TYPE string.
