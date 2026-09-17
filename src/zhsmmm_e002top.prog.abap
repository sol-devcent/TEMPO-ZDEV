*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E002TOP
*&---------------------------------------------------------------------*
TABLES: zhsmmmdt003.

****TYPES: BEGIN OF ty_schedule,
****          rfq_no  TYPE string,
****          schedule_quotation TYPE string,
****          schedule_counter  TYPE string,
****          item_delivery_date TYPE string,
****          qty_schedule TYPE p DECIMALS 2,
****          delivery_date_quotation TYPE string,    "----> Entry dari WEB
****          scheduled_qty_quotation TYPE p DECIMALS 2,  "----> Entry dari WEB
****          pr_number TYPE string,
****          item_pr TYPE string,
****          indicator TYPE string,
****       END OF ty_schedule.
****TYPES: BEGIN OF ty_detail,
****          item_quotation TYPE string,
****          item_rfq TYPE string,
****          short_text TYPE string,
****          material_number TYPE string,
****          material_vendor TYPE string,
****          company_code TYPE string,
****          plant TYPE string,
****          storage_location TYPE string,
****          qty_rfq TYPE p DECIMALS 2,
****          uom_rfq TYPE string,
****          price TYPE p DECIMALS 2,        "----> Entry dari WEB
****          uom_price TYPE string,          "----> Entry dari WEB
****          valid_price TYPE string,        "----> tgl masa berlaku price
****          product_group_by type string,
****          schedule TYPE STANDARD TABLE OF ty_schedule WITH NON-UNIQUE DEFAULT KEY,
****       END OF ty_detail.
****TYPES: BEGIN OF ty_header,
****          quotation_no TYPE string, "----> Entry dari WEB
****          quotation_date TYPE string, "----> Entry dari WEB
****          rfq_no TYPE string,
****          rfq_date TYPE string,
****          vendor_code TYPE string,
****          tender_no TYPE string,   "Collective no
****          payment_terms TYPE string, "ZTERM,
****          currency TYPE string,      "----> Entry dari WEB
****          moq TYPE string,           "----> Entry dari WEB
****          incoterm1 TYPE string,     "----> Entry dari WEB
****          incoterm2 TYPE string,     "----> Entry dari WEB
****          packingsize TYPE string,   "----> Entry dari WEB
****          production_capacity TYPE string, "----> Entry dari WEB
****          detail TYPE STANDARD TABLE OF ty_detail WITH NON-UNIQUE DEFAULT KEY,
****       END OF ty_header.
****TYPES: BEGIN OF ty_tender,
****          tender TYPE STANDARD TABLE OF ty_header WITH NON-UNIQUE DEFAULT KEY,
****       END OF ty_tender.


TYPES: BEGIN OF ty_trn_final_rfq_schedule,
          rfq_no  TYPE string,
          schedule_quotation TYPE string,
          schedule_counter  TYPE string,
          item_delivery_date TYPE string,
          qty_schedule TYPE p DECIMALS 2,
          delivery_date_quotation TYPE string,    "----> Entry dari WEB
          scheduled_qty_quotation TYPE p DECIMALS 2,  "----> Entry dari WEB
          pr_number TYPE string,
          item_pr TYPE string,
          indicator TYPE string,
       END OF ty_trn_final_rfq_schedule.
TYPES: BEGIN OF ty_trn_price_scale,
          rfq_no  TYPE string,
          item_rfq TYPE string,
          urutan TYPE i, "p DECIMALS 0, "string, "
"          qty_from TYPE p DECIMALS 0,
"          qty_to TYPE p DECIMALS 0,
          amount_scale TYPE p DECIMALS 2,
          nourut TYPE i,
          klfn1 LIKE konm-klfn1,
          qty_scale TYPE p DECIMALS 0,
          material_number TYPE string,
          uom_rfq TYPE string,
          currency TYPE string,      "----> Entry dari WEB
          per TYPE string,
         END OF ty_trn_price_scale.
TYPES: BEGIN OF ty_trn_final_rfq_detail,
          item_quotation TYPE string,
          item_rfq TYPE string,
          short_text TYPE string,
          material_number TYPE string,
          material_vendor TYPE string,
          company_code TYPE string,
          plant TYPE string,
          storage_location TYPE string,
          qty_rfq TYPE p DECIMALS 2,
          uom_rfq TYPE string,
          price TYPE p DECIMALS 2,        "----> Entry dari WEB
          per TYPE string,
          per_vendor TYPE string,
          uom_price TYPE string,          "----> Entry dari WEB
          valid_price TYPE string,        "----> tgl masa berlaku price
          product_group_by TYPE string,
          trn_final_rfq_schedule TYPE STANDARD TABLE OF ty_trn_final_rfq_schedule WITH NON-UNIQUE DEFAULT KEY,
          trn_price_scale TYPE STANDARD TABLE OF ty_trn_price_scale WITH NON-UNIQUE DEFAULT KEY,
       END OF ty_trn_final_rfq_detail.

TYPES: BEGIN OF ty_data,
          quotation_no TYPE string, "----> Entry dari WEB
          quotation_date TYPE string, "----> Entry dari WEB
          rfq_no TYPE string,
          rfq_date TYPE string,
          vendor_code TYPE string,
          tender_no TYPE string,   "Collective no
          payment_terms TYPE string, "ZTERM,
          currency TYPE string,      "----> Entry dari WEB
          moq TYPE string,           "----> Entry dari WEB
          incoterm1 TYPE string,     "----> Entry dari WEB
          incoterm2 TYPE string,     "----> Entry dari WEB
          packingsize TYPE string,   "----> Entry dari WEB
          production_capacity TYPE string, "----> Entry dari WEB
          trn_final_rfq_detail TYPE STANDARD TABLE OF ty_trn_final_rfq_detail WITH NON-UNIQUE DEFAULT KEY,
       END OF ty_data.
TYPES: BEGIN OF ty_quot,
          status_code TYPE string,
          success TYPE string,
          data TYPE STANDARD TABLE OF ty_data WITH NON-UNIQUE DEFAULT KEY,
       END OF ty_quot.


DATA : gv_quot   TYPE ty_quot.
"DATA : gv_tender   TYPE ty_tender.

DATA : gv_quotation   TYPE ty_quot. "ty_header.
"DATA : gs_detail      TYPE ty_detail .
"DATA : gs_schedule    TYPE ty_schedule .

DATA : gv_str         TYPE string,
       gv_anfnr       TYPE ekpo-anfnr.

DATA : gt_quoi        TYPE STANDARD TABLE OF bs01mmitem,
       gt_quois       TYPE STANDARD TABLE OF bs01mmschedule,
       gt_quoh        TYPE STANDARD TABLE OF bs01mmhead,
       gt_price_scale TYPE TABLE OF ty_trn_price_scale WITH HEADER LINE,
       return         TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.
DATA: BEGIN OF gt_return OCCURS 0,
        DOC_NUMBER like bs01mmhead-DOC_NUMBER.
        INCLUDE STRUCTURE bdcmsgcoll.
DATA: END OF gt_return.
DATA: gt_zhsmmmdt003 TYPE STANDARD TABLE OF zhsmmmdt003 WITH HEADER LINE.
DATA: gs_zhsmmmdt003 TYPE zhsmmmdt003.

DATA : gt_004         TYPE STANDARD TABLE OF zhsmmmdt004.
DATA: BEGIN OF gt_post OCCURS 0,
         coll_no TYPE string,
         rfq_no TYPE ebeln,
         status(1),
      END OF gt_post.
