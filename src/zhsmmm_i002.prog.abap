REPORT  zhsmmm_i002 MESSAGE-ID v6.

TABLES: ekko, ekpo, eket.
TYPES: BEGIN OF ty_schedule,
          schedule_counter  TYPE string,  "0001",
          item_delivery_date  TYPE string,                  "20230404",
          item_preview_date TYPE string,
          qty_schedule(20), "  TYPE string,  "3000",
          schedule_vendor(20), " type string,
          pr_number  TYPE string,  "00710021493",
          item_pr  TYPE string,
          indicator TYPE string,                            "000010"
       END OF ty_schedule.
TYPES: BEGIN OF ty_detail,
          item_rfq  TYPE string,  "00010",
          short_text  TYPE string,  "PARACETAMOL USP,BP.",
          origin_text TYPE string,
          material_number  TYPE string,  "R1630",
          material_vendor  TYPE string,  "R1630",
          "product_group type string,
          "product_group_description type string,
          product_group1 type string,
          product_group1_description type string,
          product_group2 type string,
          product_group2_description type string,
          product_group3 type string,
          product_group3_description type string,
          company_code  TYPE string,  "8010",
          plant  TYPE string,  "0101",
          storage_location  TYPE string,  "1000",
          qty_rfq(20), "  TYPE string,  "15000",
          uom_rfq  TYPE string,  "kg",
          qty_vendor(20), " type string),
          uom_vendor TYPE string,
          delivery_address  TYPE string,
          valid_price TYPE string,
          schedule TYPE STANDARD TABLE OF ty_schedule WITH DEFAULT KEY ,
       END OF ty_detail.
TYPES: BEGIN OF ty_header,
          rfq_no  TYPE string,  "6500000023",
          rfq_date  TYPE string,                            "20230120",
          vendor_code  TYPE string,  "0900000001",
          tender_no  TYPE string,                           "T000001",
          start_tender  TYPE string,                        "20230201",
          end_submit_tender1  TYPE string,                  "20230205",
          end_submit_quotation  TYPE string,                "20230207",
          end_tender  TYPE string,                          "20230210",
          payment_terms  TYPE string,  "ZT45",
          currency  TYPE string,  "USD",
          purchasing_group TYPE string,
          detail TYPE STANDARD TABLE OF ty_detail WITH DEFAULT KEY ,
       END OF ty_header.
TYPES: BEGIN OF rfq,
          header TYPE  ty_header  ,
       END OF rfq.
TYPES: BEGIN OF tender,
          rfq TYPE STANDARD TABLE OF ty_header  WITH DEFAULT KEY,
       END OF tender.
DATA: gt_zhsmmmdt003 TYPE STANDARD TABLE OF zhsmmmdt003 WITH HEADER LINE.
DATA: gs_zhsmmmdt003 TYPE zhsmmmdt003.
DATA: gv_submi LIKE ekko-submi.
DATA: gv_erdat LIKE  sy-datum.

SELECTION-SCREEN SKIP 1.
PARAMETER pa_submi LIKE ekko-submi.
PARAMETER p_delete AS CHECKBOX.
SELECT-OPTIONS s_ebeln FOR ekko-ebeln.

START-OF-SELECTION.
  IF pa_submi IS INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_zhsmmmdt003 FROM zhsmmmdt003 WHERE zproses = 'HSM_SENDRFQ' AND status NE 'D'.
    IF sy-subrc EQ 0.
      LOOP AT gt_zhsmmmdt003 INTO gs_zhsmmmdt003.
        gv_submi = gs_zhsmmmdt003-zdata.
        CONDENSE gv_submi.
        PERFORM send_data USING gv_submi.
      ENDLOOP.
    ENDIF.
  ELSE.
    gv_submi = pa_submi.
    PERFORM send_data USING gv_submi.
  ENDIF.
  gv_erdat = sy-datum - 7.
  DELETE FROM zhsmmmdt003 WHERE erdat < gv_erdat AND status = 'D'.

  INCLUDE zhsmmm_i002f01.
*INCLUDE ZHSMMM_I001F01.
