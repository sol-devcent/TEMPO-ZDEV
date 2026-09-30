FUNCTION-POOL zwmsfg001.                    "MESSAGE-ID ..
TYPES:
  BEGIN OF ty_shipdetail,
    item_id            TYPE c LENGTH 20,
    material_number    TYPE c LENGTH 18,
    batch              TYPE c LENGTH 10,
    quantity_satuan    TYPE c LENGTH 15,
    uom_satuan         TYPE string,
    quantity_carton    TYPE c LENGTH 15,
    uom_carton         TYPE string,
    zero_indicator     TYPE c LENGTH 1,
    newbatch_indicator TYPE c LENGTH 1,
    newsn_indicator    TYPE c LENGTH 1,
    newmat_indicator   TYPE c LENGTH 1,
  END OF ty_shipdetail .

TYPES:
  BEGIN OF ty_to,
    shipment_number  TYPE c LENGTH 10,
    warehouse_number TYPE c LENGTH 3,
    pallet_number    TYPE c LENGTH 10,
    user_name        TYPE c LENGTH 12,
    flag_reject      TYPE c LENGTH 1,
    rusak_indicator  TYPE c LENGTH 1,
    unloading_start  TYPE c LENGTH 20,
    unloading_end    TYPE c LENGTH 20,
    nav_ship         TYPE TABLE OF ty_shipdetail WITH DEFAULT KEY,
  END OF ty_to.

TYPES :
  BEGIN OF ty_shipment,
    tknum      TYPE vttk-tknum,
    vbeln      TYPE lips-vbeln,
    posnr      TYPE lips-posnr,
    matnr      TYPE lips-matnr,
    lfimg      TYPE lips-lfimg,
    charg      TYPE lips-charg,
    meins      TYPE lips-meins,
    vrkme      TYPE lips-vrkme,
    zero       TYPE c LENGTH 1,
    newch      TYPE c LENGTH 1,
    newbc      TYPE c LENGTH 1,
    newsn      TYPE c LENGTH 1,
    zdtsul     TYPE zwmdt004-zdtsul,
    zuzsul     TYPE zwmdt004-zuzsul,
    zdteul     TYPE zwmdt004-zdteul,
    zuzeul     TYPE zwmdt004-zuzeul,
    pallet(10),
    itemid(20),
  END OF ty_shipment.

TYPES : BEGIN OF ty_shipcmplt,
          warehouse_number TYPE c LENGTH 3,
          shipment_number  TYPE c LENGTH 10,
          unloading_start  TYPE c LENGTH 20,
          unloading_end    TYPE c LENGTH 20,
          type             TYPE c LENGTH 1,
          message          TYPE c LENGTH 220,
        END OF ty_shipcmplt .

TYPES : BEGIN OF ty_loadrel,
          shipment_number TYPE c LENGTH 10,
          nav_load        TYPE TABLE OF zwmsst008 WITH DEFAULT KEY,
        END OF ty_loadrel.

TYPES : BEGIN OF ty_loadpos,
          shipment_number TYPE c LENGTH 10,
          nav_load        TYPE TABLE OF zwmsst009 WITH DEFAULT KEY,
        END OF ty_loadpos.

TYPES:
  BEGIN OF ty_picking,
    warehouse_number TYPE c LENGTH 3,
    to_number        TYPE c LENGTH 20,
    delivery_number  TYPE c LENGTH 10,
    nav_confpick     TYPE TABLE OF zwmsst002 WITH DEFAULT KEY,
  END OF ty_picking.

TYPES:
  BEGIN OF ty_checker,
    warehouse_number TYPE c LENGTH 3,
    to_number        TYPE c LENGTH 20,
    delivery_number  TYPE c LENGTH 20,
    nav_confcheck    TYPE TABLE OF zwmsst006 WITH DEFAULT KEY,
  END OF ty_checker.

TYPES:
  BEGIN OF ty_pickcmpl,
    warehouse_number TYPE c LENGTH 3,
    to_number        TYPE c LENGTH 20,
    koli_ori         TYPE c LENGTH 7,
    koli_ecer        TYPE c LENGTH 7,
    nav_cmplpick     TYPE TABLE OF zwmsst003 WITH DEFAULT KEY,
  END OF ty_pickcmpl.

TYPES:
  BEGIN OF ty_picka,
    warehouse_number TYPE c LENGTH 3,
    to_number        TYPE c LENGTH 20,
    nav_confpick     TYPE TABLE OF zwmsst005 WITH DEFAULT KEY,
  END OF ty_picka.

TYPES:
  BEGIN OF ty_pid,
    warehouse_number TYPE c LENGTH 3,
    storage_type     TYPE c LENGTH 3,
    storage_bin      TYPE c LENGTH 10,
    nav_pid          TYPE TABLE OF zwmsst011 WITH DEFAULT KEY,
  END OF ty_pid.

TYPES :
  BEGIN OF ty_sirh,
    lgnum   TYPE c LENGTH 3,
    lgtyp   TYPE c LENGTH 3,
    uname   TYPE c LENGTH 12,
    pidsap  TYPE c LENGTH 10,
    msgtyp  TYPE c LENGTH 1,
    msgdesc TYPE c LENGTH 220,
  END OF ty_sirh .

TYPES: BEGIN OF ty_po,
         ebeln         TYPE ekpo-ebeln,
         ebelp         TYPE ekpo-ebelp,
         matnr         TYPE ekpo-matnr,
         menge         TYPE ekpo-menge,
         charg         TYPE lips-charg,
         meins         TYPE ekpo-meins,
         werks         TYPE ekpo-werks,
         newch         TYPE c LENGTH 1,
         rusak         TYPE c LENGTH 1,
         item_id       TYPE string,
         pallet_number TYPE string,
         pallet_id     TYPE string,
         zdtsul        TYPE zwmdt004-zdtsul,
         zuzsul        TYPE zwmdt004-zuzsul,
         zdteul        TYPE zwmdt004-zdteul,
         zuzeul        TYPE zwmdt004-zuzeul,
       END OF ty_po.

TYPES: BEGIN OF ty_podetail,
         pallet_number      TYPE string,
         "         pallet_id          TYPE string,
         item_id            TYPE string,
         material_number    TYPE string,
         batch              TYPE string,
         quantity_satuan    TYPE string,
         uom_satuan         TYPE string,
         quantity_carton    TYPE string,
         uom_carton         TYPE string,
         destination_bin    TYPE string,
         zero_indicator     TYPE string,
         newbatch_indicator TYPE string,
         newsn_indicator    TYPE string,
         rusak_indicator    TYPE string,
         newmat_indicator   TYPE string,
         to_number          TYPE string,
         type               TYPE string,
         messages           TYPE string,
       END OF ty_podetail.

TYPES: BEGIN OF ty_to_po,
         po_number       TYPE c LENGTH 10,
         warehouse       TYPE c LENGTH 3,
         delivery_number TYPE c LENGTH 10,
         pallet_number   TYPE c LENGTH 10,
         user_name       TYPE c LENGTH 12,
         pallet_id       TYPE string,
         unloading_start TYPE c LENGTH 25,
         unloading_end   TYPE c LENGTH 25,
         flag_reject     TYPE c LENGTH 1,
         nav_po          TYPE TABLE OF ty_podetail WITH DEFAULT KEY,
       END OF ty_to_po.



* INCLUDE LZWMSFG001D...                     " Local class definition
