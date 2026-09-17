*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E002F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data CHANGING p_err p_str TYPE string.
  TYPES : BEGIN OF text,
            line(1500),
          END OF text.
  DATA : lt_response_body     TYPE TABLE OF text WITH HEADER LINE.

  DATA: lv_err(1).
  DATA: lv_text TYPE text1024.

  IF p_demo = 'X'.
    CLEAR: p_str, lv_text.
    OPEN DATASET p_path FOR INPUT IN TEXT MODE ENCODING UTF-8
                           IGNORING CONVERSION ERRORS.
    IF sy-subrc EQ 0.
      DO.
        READ DATASET p_path INTO lv_text.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        CONCATENATE p_str lv_text INTO p_str.
        CLEAR: lv_text.
      ENDDO.
      CLOSE DATASET p_path.
      "      REPLACE ALL OCCURRENCES OF REGEX 'null' IN lv_str WITH '"  "'.
      REPLACE ALL OCCURRENCES OF REGEX '#' IN p_str WITH '"  "'.

    ENDIF.
  ELSE.
    IF p_back = 'X'.
      CLEAR: lt_response_body[].
      p_proses = 'HSM_QOUTFINAL'.
    ELSE.
      CONCATENATE '{ "params" : { "tender_no" : "' p_tender '" } } ' INTO lt_response_body-line.
      APPEND lt_response_body.
    ENDIF.
    PERFORM f_get_data_json_json(ztdsit_i001) TABLES   lt_response_body
                                         USING    p_proses
                                         CHANGING p_str lv_err.
  ENDIF.

ENDFORM.                    " F_GET_DATA
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_JSON
*&---------------------------------------------------------------------*
FORM f_convert_json  USING    p_str CHANGING p_quotation TYPE ty_quot. "ty_header.
  DATA:   lv_json_data     TYPE string. ",

  DATA: lv_temp(10).
  DATA: ls_data TYPE ty_data.
  DATA: ls_detail_rfq TYPE ty_trn_final_rfq_detail.
  DATA: ls_shedule_rfq TYPE ty_trn_final_rfq_schedule.
  DATA: ls_trn_price TYPE ty_trn_price_scale.
  DATA : ls_quoh  LIKE LINE OF gt_quoh,
         ls_quoi  LIKE LINE OF gt_quoi,
         ls_quois LIKE LINE OF gt_quois.
  DATA: lv_ctr TYPE i.
  DATA: ld_klfn1 LIKE konm-klfn1.
  DATA: ld_ctr TYPE i.
  lv_json_data = p_str.


  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = gv_quot ).

  p_quotation = gv_quot.

**  WRITE: / ' Get data from WEB'.
  CLEAR: gv_norfq, lv_ctr.
  LOOP AT gv_quot-data INTO ls_data.
    ADD 1 TO lv_ctr.
    ls_quoh-quotation       = ls_data-quotation_no.
    ls_quoh-quot_date       = ls_data-quotation_date.
    ls_quoh-doc_number      = ls_data-rfq_no.
    gv_norfq = ls_data-rfq_no.
    CONCATENATE ls_data-rfq_date(4) ls_data-rfq_date+5(2) ls_data-rfq_date+8(2) INTO lv_temp.
    ls_quoh-doc_date        = lv_temp. "ls_header-rfq_date.
    ls_quoh-vendor          = ls_data-vendor_code.
    ls_quoh-coll_no         = ls_data-tender_no.
    ls_quoh-pmnttrms        = ls_data-payment_terms.
    ls_quoh-currency        = ls_data-currency.
*    gs_quoh-                  ls_header-moq.
    ls_quoh-incoterms1      = ls_data-incoterm1.
    ls_quoh-incoterms2      = ls_data-incoterm2.
*    gs_quoh-                  ls_header-packingsize.
*    gs_quoh-                  ls_header-production_capacity
    ls_quoh-purch_org       = 'TNT'.
    ls_quoh-doc_type        = 'AN'.
    ls_quoh-pur_group       = 'R01'.
    ls_quoh-doc_cat         = 'A'.
    APPEND ls_quoh TO gt_quoh.
    CLEAR ls_quoh.
**    WRITE: / 'Tender No. : ', ls_data-tender_no.
**    WRITE: / 'RFQ no : ', ls_data-rfq_no.
**    WRITE: / 'Quotation no : ', ls_data-quotation_no.
**    WRITE: / 'Currency : ', ls_data-currency.
    LOOP AT ls_data-trn_final_rfq_detail INTO ls_detail_rfq.
**      WRITE: / ls_detail_rfq-item_rfq, sy-vline,
**               ls_detail_rfq-item_quotation, sy-vline,
**               ls_detail_rfq-material_number, sy-vline,
**               ls_detail_rfq-material_vendor, sy-vline,
**               ls_detail_rfq-qty_rfq.
**      WRITE: / 'Price : ', ls_detail_rfq-price, '/' , ls_detail_rfq-per, '  ', ls_detail_rfq-uom_rfq.
*      ls_quoi-            = ls_detail-item_rfq.
*      ls_quoi-            = ls_detail-item_quotation.
      ls_quoi-doc_number  = ls_data-rfq_no.
      ls_quoi-doc_item    = ls_detail_rfq-item_rfq.
      ls_quoi-material    = ls_detail_rfq-material_number.
      ls_quoi-pur_mat     = ls_detail_rfq-material_vendor.
      ls_quoi-quantity    = ls_detail_rfq-qty_rfq.
      ls_quoi-net_price   = ls_detail_rfq-price. " * 100 ) / 100.
      CONDENSE ls_detail_rfq-per_vendor.

      ls_quoi-price_unit = ls_detail_rfq-per_vendor.
      ls_quoi-unit        = ls_detail_rfq-uom_rfq.
      ls_quoi-vend_mat  = ls_detail_rfq-product_group_by.
      IF ls_detail_rfq-valid_price IS NOT INITIAL.
        CONCATENATE ls_detail_rfq-valid_price(4) ls_detail_rfq-valid_price+5(2) ls_detail_rfq-valid_price+8(2) INTO lv_temp.
        ls_quoi-trackingno  = lv_temp. "ls_detail-valid_price.
      ENDIF.
      APPEND ls_quoi TO gt_quoi.
      CLEAR ls_quoi.
      ls_quoh-co_code         = ls_detail_rfq-company_code.
      LOOP AT ls_detail_rfq-trn_final_rfq_schedule INTO ls_shedule_rfq.
***        WRITE: / ls_shedule_rfq-schedule_quotation, sy-vline,
***                 ls_shedule_rfq-schedule_counter, sy-vline,
***                 ls_shedule_rfq-item_delivery_date, sy-vline,
***                 ls_shedule_rfq-qty_schedule, sy-vline,
***                 ls_shedule_rfq-delivery_date_quotation, sy-vline,
***                 ls_shedule_rfq-scheduled_qty_quotation, sy-vline,
***                 ls_shedule_rfq-pr_number, sy-vline,
***                 ls_shedule_rfq-item_pr.

*        ls_quois-              = ls_schedule-schedule_quotation.
*        ls_quois-              = ls_schedule-schedule_counter.
        IF ls_shedule_rfq-item_delivery_date IS NOT INITIAL.
          CONCATENATE ls_shedule_rfq-item_delivery_date(4) ls_shedule_rfq-item_delivery_date+5(2) ls_shedule_rfq-item_delivery_date+8(2) INTO lv_temp.
          ls_quois-deliv_date    = lv_temp. "ls_schedule-item_delivery_date.
        ENDIF.
        ls_quois-quantity      = ls_shedule_rfq-qty_schedule.
        IF ls_shedule_rfq-delivery_date_quotation IS NOT INITIAL.
          CONCATENATE ls_shedule_rfq-delivery_date_quotation(4) ls_shedule_rfq-delivery_date_quotation+5(2) ls_shedule_rfq-delivery_date_quotation+8(2) INTO lv_temp.
          ls_quois-deliv_date    = lv_temp. "ls_schedule-delivery_date_quotation.
        ENDIF.
        ls_quois-doc_item      = ls_detail_rfq-item_rfq.
        ls_quois-serial_no     = ls_shedule_rfq-schedule_counter.
        ls_quois-quantity      = ls_shedule_rfq-scheduled_qty_quotation.
        ls_quois-preq_no       = ls_shedule_rfq-pr_number.
        ls_quois-preq_item     = ls_shedule_rfq-item_pr.
        ls_quois-reserv_no     = ls_shedule_rfq-rfq_no.
        APPEND ls_quois TO gt_quois.
        CLEAR ls_quois.
      ENDLOOP.
      CLEAR: ld_klfn1, ld_ctr.
      ld_klfn1 = 1.
      SORT ls_detail_rfq-trn_price_scale BY nourut.
      LOOP AT ls_detail_rfq-trn_price_scale INTO ls_trn_price.
        ADD 1 TO ld_ctr.
        ls_trn_price-urutan = ld_ctr.
        ls_trn_price-rfq_no  = ls_data-rfq_no.
        ls_trn_price-item_rfq = ls_detail_rfq-item_rfq.
        ls_trn_price-material_number = ls_detail_rfq-material_number.
        ls_trn_price-klfn1 = ls_trn_price-nourut. "urutan. ".
        ls_trn_price-uom_rfq = ls_detail_rfq-uom_rfq.
        ls_trn_price-currency = ls_data-currency.
        ls_trn_price-per = ls_detail_rfq-per_vendor.
        ls_trn_price-qty_scale = ls_trn_price-qty_scale.
        APPEND ls_trn_price TO gt_price_scale.
        ld_klfn1 = ld_klfn1 + 3.

**          urutan type string, "
**          qty_from TYPE p DECIMALS 0,
**          qty_to TYPE p DECIMALS 0,
**          price_scale TYPE p DECIMALS 2,
**          nourut type i,
**          klfn1 like konm-klfn1,
**          qty_scale TYPE p DECIMALS 0,
**          material_number TYPE string,
**          uom_rfq TYPE string,
**          currency TYPE string,      "----> Entry dari WEB
**          per TYPE string,

      ENDLOOP.
    ENDLOOP.
  ENDLOOP.
  IF lv_ctr > 1.
    WRITE lv_ctr TO lv_temp NO-GAP NO-GROUPING.
    IF p_tender IS INITIAL.
      gv_norfq = 'FINAL'.
    ELSE.
      gv_norfq = p_tender.
    ENDIF.
    CONDENSE: lv_temp, gv_norfq.
    CONCATENATE gv_norfq lv_temp INTO gv_norfq.
    "gv_norfq = p_tender.
  ENDIF.


**  LOOP AT gv_tender-tender INTO ls_header.
****    WRITE: / 'Tender no : ', ls_header-tender_no.
****    WRITE: / 'RFQ no : ', ls_header-rfq_no.
****    WRITE: / 'Quotation no : ', ls_header-quotation_no.
**
**    IF ls_header IS NOT INITIAL.
**      ls_quoh-quotation       = ls_header-quotation_no.
**      ls_quoh-quot_date       = ls_header-quotation_date.
**      ls_quoh-doc_number      = ls_header-rfq_no.
**      CONCATENATE ls_header-rfq_date(4) ls_header-rfq_date+5(2) ls_header-rfq_date+8(2) INTO lv_temp.
**      ls_quoh-doc_date        = lv_temp. "ls_header-rfq_date.
**      ls_quoh-vendor          = ls_header-vendor_code.
**      ls_quoh-coll_no         = ls_header-tender_no.
**      ls_quoh-pmnttrms        = ls_header-payment_terms.
**      ls_quoh-currency        = ls_header-currency.
***    gs_quoh-                  ls_header-moq.
**      ls_quoh-incoterms1      = ls_header-incoterm1.
**      ls_quoh-incoterms2      = ls_header-incoterm2.
***    gs_quoh-                  ls_header-packingsize.
***    gs_quoh-                  ls_header-production_capacity
**      ls_quoh-purch_org       = 'TNT'.
**      ls_quoh-doc_type        = 'AN'.
**      ls_quoh-pur_group       = 'R01'.
**      ls_quoh-doc_cat         = 'A'.
**      APPEND ls_quoh TO gt_quoh.
**      CLEAR ls_quoh.
**      WRITE: / 'Tender No. : ', ls_header-tender_no.
**      WRITE: / 'RFQ no : ', ls_header-rfq_no.
**      WRITE: / 'Quotation no : ', ls_header-quotation_no.
**
**      LOOP AT ls_header-detail INTO ls_detail.
**        WRITE: / ls_detail-item_rfq, sy-vline,
**                 ls_detail-item_quotation, sy-vline,
**                 ls_detail-material_number, sy-vline,
**                 ls_detail-material_vendor, sy-vline,
**                 ls_detail-qty_rfq.
**
***      ls_quoi-            = ls_detail-item_rfq.
***      ls_quoi-            = ls_detail-item_quotation.
**        ls_quoi-doc_number  = ls_header-rfq_no.
**        ls_quoi-doc_item    = ls_detail-item_rfq.
**        ls_quoi-material    = ls_detail-material_number.
**        ls_quoi-pur_mat     = ls_detail-material_vendor.
**        ls_quoi-quantity    = ls_detail-qty_rfq.
**        ls_quoi-net_price   = ( ls_detail-price * 100 ) / 100.
**        ls_quoi-unit        = ls_detail-uom_rfq.
**        IF ls_detail-valid_price IS NOT INITIAL.
**          CONCATENATE ls_detail-valid_price(4) ls_detail-valid_price+5(2) ls_detail-valid_price+8(2) INTO lv_temp.
**          ls_quoi-trackingno  = lv_temp. "ls_detail-valid_price.
**        ENDIF.
**        APPEND ls_quoi TO gt_quoi.
**        CLEAR ls_quoi.
**
**        ls_quoh-co_code         = ls_detail-company_code.
**
**        LOOP AT ls_detail-schedule INTO ls_schedule.
**          WRITE: / ls_schedule-schedule_quotation, sy-vline,
**                   ls_schedule-schedule_counter, sy-vline,
**                   ls_schedule-item_delivery_date, sy-vline,
**                   ls_schedule-qty_schedule, sy-vline,
**                   ls_schedule-delivery_date_quotation, sy-vline,
**                   ls_schedule-scheduled_qty_quotation, sy-vline,
**                   ls_schedule-pr_number, sy-vline,
**                   ls_schedule-item_pr.
**
***        ls_quois-              = ls_schedule-schedule_quotation.
***        ls_quois-              = ls_schedule-schedule_counter.
**          IF ls_schedule-item_delivery_date IS NOT INITIAL.
**            CONCATENATE ls_schedule-item_delivery_date(4) ls_schedule-item_delivery_date+5(2) ls_schedule-item_delivery_date+8(2) INTO lv_temp.
**            ls_quois-deliv_date    = lv_temp. "ls_schedule-item_delivery_date.
**          ENDIF.
**          ls_quois-quantity      = ls_schedule-qty_schedule.
**          IF ls_schedule-delivery_date_quotation IS NOT INITIAL.
**            CONCATENATE ls_schedule-delivery_date_quotation(4) ls_schedule-delivery_date_quotation+5(2) ls_schedule-delivery_date_quotation+8(2) INTO lv_temp.
**            ls_quois-deliv_date    = lv_temp. "ls_schedule-delivery_date_quotation.
**          ENDIF.
**          ls_quois-quantity      = ls_schedule-scheduled_qty_quotation.
**          ls_quois-preq_no       = ls_schedule-pr_number.
**          ls_quois-preq_item     = ls_schedule-item_pr.
**          ls_quois-reserv_no     = ls_schedule-rfq_no.
**          APPEND ls_quois TO gt_quois.
**          CLEAR ls_quois.
**        ENDLOOP.
**      ENDLOOP.
**    ENDIF.
**  ENDLOOP.
**  SKIP 2.
**  p_quotation = ls_header.
*ENDIF.
ENDFORM.                    " F_CONVERT_JSON

**        ASSIGN COMPONENT 'DETAIL' OF STRUCTURE <data1> TO <results2>.
**        IF <results2> IS ASSIGNED.
**          ASSIGN <results2>->* TO <table1>.
**          LOOP AT <table1> ASSIGNING <structure1>.
**            ASSIGN <structure1>->* TO <data2>.
**            ASSIGN COMPONENT 'SCHEDULE' OF STRUCTURE <data2> TO <results3>.
**            IF <results3> IS ASSIGNED.
**              ASSIGN <results3>->* TO <table2>.
**              LOOP AT <table2> ASSIGNING <structure2>.
**                ASSIGN <structure2>->* TO <data3>.
**                ASSIGN COMPONENT 'SCHEDULE_QUOTATION' OF STRUCTURE <data3> TO <field>.
**                IF <field> IS ASSIGNED.
**                  lr_data = <field>.
**                  ASSIGN lr_data->* TO <field_value>.
**                  ls_schedule-schedule_quotation = <field_value>.
**                ENDIF.
**                UNASSIGN: <field>, <field_value>.
**
**                ASSIGN COMPONENT 'SCHEDULE_COUNTER' OF STRUCTURE <data3> TO <field>.
**                IF <field> IS ASSIGNED.
**                  lr_data = <field>.
**                  ASSIGN lr_data->* TO <field_value>.
**                  ls_schedule-schedule_counter = <field_value>.
**                ENDIF.
**                UNASSIGN: <field>, <field_value>.
**
**                ASSIGN COMPONENT 'ITEM_DELIVERY_DATE' OF STRUCTURE <data3> TO <field>.
**                IF <field> IS ASSIGNED.
**                  lr_data = <field>.
**                  ASSIGN lr_data->* TO <field_value>.
**                  ls_schedule-item_delivery_date = <field_value>.
**                ENDIF.
**                UNASSIGN: <field>, <field_value>.
**
**                ASSIGN COMPONENT 'QTY_SCHEDULE' OF STRUCTURE <data3> TO <field>.
**                IF <field> IS ASSIGNED.
**                  lr_data = <field>.
**                  ASSIGN lr_data->* TO <field_value>.
**                  ls_schedule-qty_schedule = <field_value>.
**                ENDIF.
**                UNASSIGN: <field>, <field_value>.
**
**                ASSIGN COMPONENT 'DELIVERY_DATE_QUOTATION' OF STRUCTURE <data3> TO <field>.
**                IF <field> IS ASSIGNED.
**                  lr_data = <field>.
**                  ASSIGN lr_data->* TO <field_value>.
**                  ls_schedule-delivery_date_quotation = <field_value>.
**                ENDIF.
**                UNASSIGN: <field>, <field_value>.
**
**                ASSIGN COMPONENT 'SCHEDULED_QTY_QUOTATION' OF STRUCTURE <data3> TO <field>.
**                IF <field> IS ASSIGNED.
**                  lr_data = <field>.
**                  ASSIGN lr_data->* TO <field_value>.
**                  ls_schedule-scheduled_qty_quotation = <field_value>.
**                ENDIF.
**                UNASSIGN: <field>, <field_value>.
**
**                ASSIGN COMPONENT 'PR_NUMBER' OF STRUCTURE <data3> TO <field>.
**                IF <field> IS ASSIGNED.
**                  lr_data = <field>.
**                  ASSIGN lr_data->* TO <field_value>.
**                  ls_schedule-pr_number = <field_value>.
**                ENDIF.
**                UNASSIGN: <field>, <field_value>.
**
**                ASSIGN COMPONENT 'ITEM_PR' OF STRUCTURE <data3> TO <field>.
**                IF <field> IS ASSIGNED.
**                  lr_data = <field>.
**                  ASSIGN lr_data->* TO <field_value>.
**                  ls_schedule-item_pr = <field_value>.
**                ENDIF.
**                UNASSIGN: <field>, <field_value>.
**                APPEND ls_schedule TO ls_detail-schedule.
**                CLEAR: ls_schedule.
**              ENDLOOP.
**            ENDIF.
**            APPEND ls_detail TO ls_header-detail.
**            CLEAR: ls_detail, ls_detail-schedule[].
**          ENDLOOP.
**        ENDIF.
**      ENDIF.
**    ENDIF.

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_QUOTATION
*&---------------------------------------------------------------------*
FORM f_change_quotation  TABLES   quotation_items           STRUCTURE bs01mmitem
                                  quotation_item_schedules  STRUCTURE bs01mmschedule
                         USING    quotation_header          TYPE bs01mmhead
                         CHANGING fc_anfnr.
  DATA : return    TYPE STANDARD TABLE OF bapiret2,
         ls_return LIKE LINE OF return.

  DATA : lt_ekko   TYPE STANDARD TABLE OF ekko,
         lt_ekpo   TYPE STANDARD TABLE OF ekpo,
         ls_ekko   LIKE LINE OF lt_ekko,
         ls_ekpo   LIKE LINE OF lt_ekpo,
         ls_item   TYPE bs01mmitem,
         ls_header TYPE bs01mmhead.

  SELECT *
    FROM ekko
    INTO CORRESPONDING FIELDS OF TABLE lt_ekko
    WHERE ebeln = quotation_header-doc_number
    ORDER BY PRIMARY KEY.

  SELECT *
    FROM ekpo
    INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
    WHERE ebeln = quotation_header-doc_number
    ORDER BY PRIMARY KEY.

  IF sy-subrc = 0.
    LOOP AT lt_ekko INTO ls_ekko.
      ls_ekko-statu   = 'A'.
      ls_ekko-zterm   = 'ZDAP'.
      ls_ekko-kalsm   = 'ZGDIM'.
      ls_ekko-frggr   = '40'.
      ls_ekko-frgsx   = '01'.
      ls_ekko-frgke   = '1'.
      ls_ekko-frgzu   = 'XX'.

      CLEAR : ls_ekko-statu, ls_ekko-zterm, ls_ekko-kalsm, ls_ekko-frggr,
              ls_ekko-frgsx, ls_ekko-frgke, ls_ekko-frgzu.
      MODIFY lt_ekko FROM ls_ekko
                          TRANSPORTING statu zterm kalsm frggr frgsx
                                       frgke frgzu.
    ENDLOOP.

    LOOP AT lt_ekpo INTO ls_ekpo.
      READ TABLE quotation_items INTO ls_item
                                 WITH KEY doc_number  = ls_ekpo-ebeln
                                          doc_item    = ls_ekpo-ebelp.
      IF sy-subrc = 0.
        ls_ekpo-statu   = 'A'.
        ls_ekpo-netpr   = ls_item-net_price / 100.
        ls_ekpo-zwert   = ls_item-net_price.
        ls_ekpo-effwr   = ls_item-net_price.
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
          EXPORTING
            input          = ls_item-unit
          IMPORTING
            output         = ls_ekpo-bprme
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.
        ls_ekpo-bpumz   = 1.
        ls_ekpo-bpumn   = 1.
        ls_ekpo-prdat   = '99991231'.
        CLEAR : ls_ekpo-netpr, ls_ekpo-statu, ls_ekpo-zwert,
                ls_ekpo-effwr, ls_ekpo-bprme, ls_ekpo-bpumz,
                ls_ekpo-bpumn, ls_ekpo-prdat.
        MODIFY lt_ekpo FROM ls_ekpo
                             TRANSPORTING netpr statu zwert effwr
                                          bprme bpumz bpumn prdat.
      ENDIF.
    ENDLOOP.
  ENDIF.

  MODIFY ekko FROM TABLE lt_ekko.

  MODIFY ekpo FROM TABLE lt_ekpo.

*****  CALL FUNCTION 'BS01_MM_QUOTATION_CREATE'
*****    EXPORTING
*****      quotation_header         = quotation_header
*****    IMPORTING
*****      quotation                = fc_anfnr
*****    TABLES
*****      quotation_items          = quotation_items
*****      quotation_item_schedules = quotation_item_schedules
*****      return                   = return.
*****
*****  LOOP AT return INTO ls_return.
*****  ENDLOOP.
ENDFORM.                    " F_CHANGE_QUOTATION

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_QUOTATION_BDC
*&---------------------------------------------------------------------*
FORM f_change_quotation_bdc  TABLES   quotation_items           STRUCTURE bs01mmitem
                                      quotation_item_schedules  STRUCTURE bs01mmschedule
                                      quotation_header          STRUCTURE bs01mmhead.

  DATA : lv_ebeln     TYPE ekpo-ebeln,
         lv_ebelp     TYPE ekpo-ebelp,
         lv_ynetpr    TYPE char15,
         lv_quantity  TYPE char15,
         lv_datbi(10),
         lv_kpein     TYPE char10,
         lv_xwaers    TYPE waers,
         lv_xnetpr    TYPE ekpo-netpr,
         ls_ekko      TYPE ekko,
         ls_ekpo      TYPE ekpo,
         lv_dcpfm     LIKE usr01-dcpfm,
         ls_item      TYPE bs01mmitem,
         ls_schedule  TYPE bs01mmschedule,
         ls_header    TYPE bs01mmhead.

  DATA : lt_bdcdata TYPE TABLE OF bdcdata WITH HEADER LINE,
         lt_bdcmsg  TYPE TABLE OF bdcmsgcoll WITH HEADER LINE,
         ls_bdcmsg  LIKE LINE OF lt_bdcmsg,
         ls_bdcopt  TYPE ctu_params.

  DATA : ls_cdpos       TYPE cdpos.
  DATA : lv_tabkey    TYPE char70,
         lv_tabix(2)  TYPE n,
         lv_tabix1(2) TYPE n,
         lv_index     TYPE i,
         lv_count     TYPE i.

  DATA : lv_mode,
         lv_update,
         dynfval   TYPE bdc_fval,
         dynfval1  TYPE bdc_fval.
  DATA: lv_sw(1).
  DATA : lt_eket   TYPE STANDARD TABLE OF eket,
         lt_xitems TYPE STANDARD TABLE OF bs01mmitem,
         ls_eket   LIKE LINE OF lt_eket.
  DATA: lv_temp LIKE rm06e-licha.
  DATA : "lt_bapiret2    TYPE STANDARD TABLE OF bapiret2,
    "ls_bapiret2    LIKE LINE OF lt_bapiret2,
    lv_norut(9)  TYPE n,
    lv_operation TYPE bapicondct-operation,
    lv_varkey    TYPE char100,
    lv_kotabnr   TYPE kotabnr.
  DATA: ld_knumh LIKE konh-knumh.
  DATA: cr           LIKE TABLE OF komv WITH HEADER LINE,
        key_fields   LIKE TABLE OF komg WITH HEADER LINE,
        ls_komk      TYPE komk,
        ls_komp      TYPE komp,
        copy_staffel LIKE TABLE OF condscale WITH HEADER LINE,
        lt_knumh     TYPE STANDARD TABLE OF knumh_comp WITH HEADER LINE,
        t_komv_idoc  LIKE TABLE OF komv_idoc WITH HEADER LINE.
  "  DATA: lv_scale(20), lv_scale1(20), lv_scale2(20)..
  "  DATA: ls_a661 TYPE a661.

  DATA: lv_tabname TYPE tabname.
*        lv_varkey TYPE vim_enqkey,
  "lv_subrc  TYPE sy-subrc.
  DATA: ld_new_record, ld_datab LIKE sy-datum,  ld_datbi LIKE sy-datum, ld_prdat LIKE sy-datum.

  lv_mode   = 'N'.
  lv_update = 'S'.

  READ TABLE quotation_header INTO ls_header INDEX 1.
  ls_bdcopt-dismode   = 'N'.
  ls_bdcopt-updmode   = 'S'.
  ls_bdcopt-defsize   = 'X'.
  ls_bdcopt-racommit  = 'X'.

  SELECT SINGLE dcpfm INTO lv_dcpfm FROM usr01 WHERE bname = sy-uname.

  lt_xitems[] = quotation_items[].
  SORT lt_xitems BY doc_number.
  DELETE ADJACENT DUPLICATES FROM lt_xitems COMPARING doc_number.
  IF lt_xitems[] IS NOT INITIAL.
    SELECT *
      FROM eket
      INTO CORRESPONDING FIELDS OF TABLE lt_eket
      FOR ALL ENTRIES IN lt_xitems
      WHERE ebeln = lt_xitems-doc_number
      ORDER BY PRIMARY KEY.
  ENDIF.
  SKIP 1.
  WRITE: / 'Proses Create Quotation'.
  CLEAR: gt_post[].
  LOOP AT quotation_header INTO ls_header .
    CLEAR: lv_sw.
    LOOP AT quotation_items INTO ls_item WHERE doc_number = ls_header-doc_number.
      CLEAR : t_bdcdata[], t_bdcmsg[].

      PERFORM f_conversion_alpha USING ls_item-doc_number
                                 CHANGING lv_ebeln.

      PERFORM f_conversion_alpha USING ls_item-doc_item
                                 CHANGING lv_ebelp.

      CLEAR : ls_ekpo, ls_ekko.
      SELECT SINGLE *
        FROM ekko
        INTO ls_ekko
        WHERE ebeln = lv_ebeln
          AND loekz = space.
      IF ls_ekko IS INITIAL.
        CLEAR lt_bdcmsg.
        lt_bdcmsg-msgtyp = 'E'.
        lt_bdcmsg-msgv1  = 'RFQ Not found'.
        lt_bdcmsg-msgv2  = ls_item-doc_number.
        APPEND lt_bdcmsg TO return.
        WRITE: / 'RFQ No : ', ls_item-doc_number, ' Tidak ditemukan '.
        lv_sw = 'E'.
        EXIT.
      ENDIF.

      SELECT SINGLE *
        FROM ekpo INTO ls_ekpo
        WHERE ebeln = lv_ebeln
          AND ebelp = lv_ebelp.

      lv_tabix  = sy-tabix.

      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'          '0305',
        ' '  'BDC_OKCODE'        '/00',
        ' '  'RM06E-ANFNR'       lv_ebeln.

** tambahan untuk SOH
      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'          '0301',
        ' '  'BDC_OKCODE'        '=AB'.

      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'          '0323',
        ' '  'BDC_OKCODE'        '/00',
        ' '  'RM06E-EBELP'       lv_ebelp.

** tambahan untuk update vendor bath buat product group
      CONCATENATE 'RM06E-ANFPS(' lv_tabix ')' INTO dynfval.
      CONDENSE dynfval NO-GAPS.

      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'                  '0323',
        ' '  'BDC_CURSOR'                'RM06E-ANFPS(01)', "dynfval,
        ' '  'BDC_OKCODE'                '=DETZ',
        ' '  'RM06E-TCSELFLAG(01)'       'X'.
      lv_temp = ls_item-vend_mat.
      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'                  '0112',
        ' '  'BDC_CURSOR'                'EKPO-PLIFZ',
        ' '  'BDC_CURSOR'                'RM06E-LICHA',
        ' '  'BDC_OKCODE'                '/00',
        ' '  'RM06E-LICHA'                lv_temp.

**** tambahan untuk update price status untuk langsung update PIR
**      CONCATENATE 'RM06E-ANFPS(' lv_tabix ')' INTO dynfval.
**      CONDENSE dynfval NO-GAPS.

      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'          '0323',
        ' '  'BDC_OKCODE'        '/00',
        ' '  'RM06E-EBELP'       lv_ebelp.

      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'                  '0323',
        ' '  'BDC_CURSOR'                'RM06E-ANFPS(01)', "dynfval,
        ' '  'BDC_OKCODE'                '=DETA',
        ' '  'RM06E-TCSELFLAG(01)'       'X'.

      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'                  '0311',
        ' '  'BDC_CURSOR'                'EKPO-SPINF',
        ' '  'BDC_OKCODE'                '/00',
        ' '  'EKPO-SPINF'                ' '.

**      CONCATENATE 'RM06E-ANFPS(' lv_tabix ')' INTO dynfval.
**      CONDENSE dynfval NO-GAPS.

      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'          '0323',
        ' '  'BDC_OKCODE'        '/00',
        ' '  'RM06E-EBELP'       lv_ebelp.

      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'                  '0323',
        ' '  'BDC_CURSOR'                'RM06E-ANFPS(01)', "dynfval,
        ' '  'BDC_OKCODE'                '=ET',
        ' '  'RM06E-TCSELFLAG(01)'       'X'.

      CLEAR : lv_count, lv_index.
      LOOP AT lt_eket INTO ls_eket WHERE ebeln = ls_item-doc_number.
        ADD 1 TO lv_index.
      ENDLOOP.

      LOOP AT quotation_item_schedules INTO ls_schedule
                                       WHERE reserv_no = ls_item-doc_number
                                          AND doc_item = ls_item-doc_item.


        PERFORM f_bdc_data TABLES t_bdcdata USING :
          'X'  'SAPMM06E'                  '1117',
          ' '  'BDC_CURSOR'                'RM06E-ETNR1',
          ' '  'BDC_OKCODE'                '/00',
          ' '  'RM06E-ETNR1'               ls_schedule-serial_no.
        PERFORM f_conversion_unit USING ls_item-unit
                                  CHANGING ls_item-unit. "cr-kmein.

        WRITE ls_schedule-quantity TO lv_quantity UNIT ls_item-unit NO-GAP NO-GROUPING.
        CONDENSE lv_quantity NO-GAPS.

        PERFORM f_bdc_data TABLES t_bdcdata USING :
          'X'  'SAPMM06E'                  '1117',
          ' '  'BDC_CURSOR'                'EKET-MENGE(01)',
          ' '  'BDC_OKCODE'                '/00',
          ' '  'EKET-MENGE(01)'            lv_quantity.

      ENDLOOP.
      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'                  '1117',
        ' '  'BDC_CURSOR'                'EKET-MENGE(01)',
        ' '  'BDC_OKCODE'                '=BACK'.
      "            ' '  dynfval1                    lv_quantity.


      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'          '0323',
        ' '  'BDC_OKCODE'        '/00',
        ' '  'RM06E-EBELP'       lv_ebelp.

      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'                  '0323',
        ' '  'BDC_CURSOR'                'RM06E-ANFPS(01)', "dynfval,
        ' '  'BDC_OKCODE'                '=KO',
        ' '  'RM06E-TCSELFLAG(01)'       'X'.

      CLEAR lv_tabkey.
      CONCATENATE lv_ebeln lv_ebelp INTO lv_tabkey.
      SELECT SINGLE *
        FROM cdpos
        INTO ls_cdpos
        WHERE objectclas = 'EINKBELEG'
          AND objectid = lv_ebeln
          AND tabkey = lv_tabkey
          AND fname = 'NETPR'.

      IF ls_ekpo-netpr > 0 OR ls_cdpos IS NOT INITIAL.
**      Write: / 'Check Table CDPOS'.
**      Write: / 'Tabkey : ', lv_tabkey, sy-vline, ls_cdpos-tabkey.
        CONCATENATE 'VAKE-DATAB(' lv_tabix ')' INTO dynfval.
        CONDENSE dynfval NO-GAPS.
        PERFORM f_bdc_data TABLES t_bdcdata USING :
          'X'  'SAPLV14A'                  '0102',
          ' '  'BDC_CURSOR'                'VAKE-DATAB(01)', "dynfval,
          ' '  'BDC_OKCODE'                '=NEWD'.
      ENDIF.

      lv_xnetpr = ls_item-net_price.
      IF ls_header-currency  = 'IDR' OR ls_header-currency  = 'THB'.
*        IF ls_ekko-waers = 'IDR'.
        lv_xnetpr = lv_xnetpr / 100.
      ENDIF.
      WRITE lv_xnetpr TO lv_ynetpr CURRENCY ls_header-currency NO-GAP NO-GROUPING. "ls_ekko-waers.
      IF ls_item-trackingno > sy-datum.
        PERFORM f_date_conversion USING ls_item-trackingno
                                  CHANGING lv_datbi.
      ELSE.
        lv_datbi = '31.12.9999'. "   "ls_item-trackingno. "'20241231'.
      ENDIF.


      IF ls_item-price_unit IS INITIAL.
        ls_item-price_unit = 1.
      ENDIF.
      "CONDENSE ls_item-price_unit.
      lv_kpein = ls_item-price_unit.
      CONDENSE lv_kpein.
      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMV13A'                  '0201',
        ' '  'BDC_OKCODE'                '/00',
        ' '  'RV13A-DATBI'               lv_datbi,
        ' '  'KONP-KBETR(01)'            lv_ynetpr,
        ' '  'KONP-KONWA(01)'            ls_header-currency,
        ' '  'KONP-KPEIN(01)'            lv_kpein. "ls_ekko-waers.

**      PERFORM f_bdc_data TABLES t_bdcdata USING :
**        'X'  'SAPMV13A'                  '0201',
**        ' '  'BDC_OKCODE'                '=SICH',
**        ' '  'BDC_CURSOR'                'KONP-KBETR(01)'.
      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMV13A'                  '0201',
        ' '  'BDC_OKCODE'                '=BACK',
        ' '  'BDC_CURSOR'                'KONP-KBETR(01)'.

      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'                  '0323',
        ' '  'BDC_CURSOR'                'RM06E-ANFPS(01)',
        ' '  'BDC_OKCODE'                '=KOPF'.
      IF ls_header-quot_date IS INITIAL.
        ls_header-quot_date = sy-datum.
      ENDIF.
      PERFORM f_date_conversion USING ls_header-quot_date
                                CHANGING lv_datbi.

      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'                  '0301',
        ' '  'BDC_CURSOR'                'EKKO-IHRAN',
        ' '  'BDC_OKCODE'                '/00',
        ' '  'EKKO-ANGNR'                ls_header-quotation,
        ' '  'EKKO-IHRAN'                '31.12.9999'. "lv_datbi.

      PERFORM f_bdc_data TABLES t_bdcdata USING :
        'X'  'SAPMM06E'                  '0301',
        ' '  'BDC_CURSOR'                'EKKO-EKGRP',
        ' '  'BDC_OKCODE'                '=BU'.
      "        ' '  'EKKO-ANGNR'                ls_header-QUOTATION,
      "        ' '  'EKKO-IHRAN'                ls_header-QUOT_DATE.

      lv_sw = 'S'.
      CALL TRANSACTION 'ME47' USING t_bdcdata
                              MODE lv_mode
                              UPDATE lv_update
                              MESSAGES INTO t_bdcmsg.
      return = t_bdcmsg.
      gt_return = t_bdcmsg.
      gt_return-doc_number = ls_header-doc_number.
      "      APPEND LINES OF t_bdcmsg[] TO gt_return[].
      READ TABLE t_bdcmsg INTO ls_bdcmsg
                          WITH KEY msgtyp = 'E'.
      IF sy-subrc <> 0.
        "      COMMIT WORK AND WAIT.
        WRITE: / 'RFQ No-item : ', ls_item-doc_number,'-', ls_item-doc_item,
                sy-vline, 'Sukses create quotation', 'Price: ', lv_ynetpr, '  ',  ls_header-currency.

        IF gt_price_scale[] IS NOT INITIAL.
          CLEAR: cr[], lv_varkey, key_fields, ls_komk, ls_komp, t_komv_idoc,
                t_komv_idoc[], ld_new_record, ld_datab, ld_datbi, ld_prdat.
          lv_kotabnr = '016'.
          CONCATENATE ls_header-doc_number lv_ebelp
                      INTO lv_varkey RESPECTING BLANKS.
          CALL FUNCTION 'SD_CONDITION_KOMG_FILL'
            EXPORTING
              p_kotabnr = lv_kotabnr
              p_kvewe   = 'A'
              p_vakey   = lv_varkey
            IMPORTING
              p_komg    = key_fields.
*- Fill KOMK
          MOVE-CORRESPONDING key_fields TO ls_komk.
          ls_komk-mandt = sy-mandt.
          ls_komk-kappl = 'M'.

*- Fill KOMP
          MOVE-CORRESPONDING key_fields TO ls_komp.
          ls_komp-kposn = '000001'.

*- Fill KOMV_IDOC
          t_komv_idoc-kznep = ' '.
          t_komv_idoc-kosrt = ls_header-quotation.
          "      t_komv_idoc-anzauf = '01'.
          APPEND t_komv_idoc.

*- Fill KOMV
          cr-kappl = 'M'.
          cr-kschl = 'ZPB0'.
          cr-kopos = '01'.
          CLEAR: cr-kzbzg.
          cr-stfkz = 'A'. " A --> Base-scale, B --> To-scale
          cr-kzbzg = 'C'. " C --> quantity Scale
          "      cr-kstbm = 0.

**          PERFORM f_conversion_unit USING ls_item-unit
**                                    CHANGING ls_item-unit. "cr-kmein.
          cr-konms = ls_item-unit. "ls_mara-unit. "'KG'.
          CLEAR cr-konws.
          WRITE ls_item-price_unit TO lv_kpein NO-GAP NO-GROUPING. " DECIMALS 0.

          cr-krech = 'C'. "C --> berdasarkan qty
          cr-kpein = lv_kpein. "'1'.
          cr-kmein = ls_item-unit. "ls_mara-unit. "'KG'. "i_matnr-meins.
          "      cr-meins = ls_mara-unit.
**          IF ls_header-currency = 'IDR' OR ls_header-currency = 'THB'.
**            ls_item-net_price = ls_item-net_price / 1000.
**          ENDIF.
          PERFORM f_price_conversion USING ls_item-net_price ls_header-currency
                                           lv_dcpfm
                                     CHANGING lv_ynetpr.

          cr-waers = ls_header-currency. "'USD'. "gt_zediscst002-konwa. "'%'.
          cr-kbetr = lv_ynetpr.                             " -10000 .
          cr-kumza = 1.
          cr-kumne = 1.
          "cr-kstbw = 0.
          CONCATENATE '$' lv_norut INTO cr-knumh.
          cr-mandt = sy-mandt.
          "CLEAR: cr-kzbzg, cr-konms, cr-konws, cr-kzbzg. "
          APPEND cr.

          DATA: lv_scale(20), lv_scale1(20), lv_scale2(20)..
          CLEAR: copy_staffel[].
          SORT gt_price_scale BY rfq_no item_rfq klfn1.
          LOOP AT gt_price_scale WHERE rfq_no = ls_header-doc_number AND
                                       item_rfq = ls_item-doc_item.
            copy_staffel-klfn1      = gt_price_scale-klfn1.
            copy_staffel-kopos      = '01'.
            WRITE gt_price_scale-qty_scale TO lv_scale NO-GAP NO-GROUPING. "CURRENCY 'IDR'
            CONDENSE lv_scale NO-GAPS.
            SPLIT lv_scale AT '.' INTO lv_scale1 lv_scale2.
            TRANSLATE lv_scale1 USING '. '.
            TRANSLATE lv_scale1 USING ',.'.
            CONDENSE lv_scale1 NO-GAPS.
            copy_staffel-kstbm   = lv_scale1. " Scale Price
**            IF ls_header-currency = 'IDR' OR ls_header-currency  = 'THB'.
**              gt_price_scale-amount_scale = gt_price_scale-amount_scale / 1000.
**            ENDIF.
            CLEAR: lv_ynetpr.
            PERFORM f_price_conversion USING gt_price_scale-amount_scale ls_header-currency
                                             lv_dcpfm
                                       CHANGING lv_ynetpr.
**            WRITE gt_price_scale-amount_scale TO lv_scale NO-GAP NO-GROUPING CURRENCY ls_header-currency.
**            CONDENSE lv_scale NO-GAPS.
**            TRANSLATE lv_scale USING '. '.
**            TRANSLATE lv_scale USING ',.'.
            copy_staffel-kbetr      = lv_ynetpr. "lv_scale. "gt_zediscst002-kstbm. "'1'.
            copy_staffel-konpkonms = ls_item-unit.
            copy_staffel-rv13akonwa = ls_header-currency. "gt_price_scale-currency.
            copy_staffel-kzbzg      = 'C'. " C -  Scale By quantity

            "        copy_staffel-klfka = 'X'.
            copy_staffel-konpkmein = ls_item-unit.
            CLEAR: copy_staffel-konpkonws.
            copy_staffel-konpkonms = ls_item-unit.
            APPEND copy_staffel.
          ENDLOOP.

          ld_datab = sy-datum. " - 3.
          IF ls_item-trackingno > sy-datum.
            ld_datbi = ls_item-trackingno.
          ELSE.
            ld_datbi = '99991231'.   "ls_item-trackingno. "'20241231'.
          ENDIF.
          CALL FUNCTION 'RV_CONDITION_COPY'
            EXPORTING
              application              = 'M'
              condition_table          = '016' "lv_kotabnr "'661' "gt_zediscst001-KOTABNR "'304'
              condition_type           = 'ZPB0'
              date_from                = ld_datab "sy-datum "p_datab "sy-datum "gt_zediscst001-datab "'20131101'
              date_to                  = ld_datbi "p_datbi "sy-datum "gt_zediscst001-datbi "'99991231'
              enqueue                  = 'X'
              i_komk                   = ls_komk
              i_komp                   = ls_komp
              key_fields               = key_fields
              maintain_mode            = 'A'
              no_authority_check       = 'X'
              keep_old_records         = ' '
              used_by_idoc             = 'X'      " when suppling scales prices, this flag must be X else price will be created with Zero price.
              overlap_confirmed        = 'X'
            IMPORTING
              e_komk                   = ls_komk
              e_komp                   = ls_komp
              new_record               = ld_new_record
              e_datab                  = ld_datab
              e_datbi                  = ld_datbi
              e_prdat                  = ld_prdat
            TABLES
              copy_records             = cr
              copy_staffel             = copy_staffel
              copy_recs_idoc           = t_komv_idoc
            EXCEPTIONS
              enqueue_on_record        = 01
              invalid_application      = 02
              invalid_condition_number = 03
              invalid_condition_type   = 04
              no_authority_ekorg       = 05
              no_authority_kschl       = 06
              no_authority_vkorg       = 07
              no_selection             = 08
              table_not_valid          = 09.
          IF sy-subrc EQ 0.
            CALL FUNCTION 'RV_CONDITION_SAVE'
              TABLES
                knumh_map = lt_knumh.
            CALL FUNCTION 'RV_CONDITION_RESET'.
            COMMIT WORK AND WAIT.
          ELSE.
          ENDIF.
          LOOP AT lt_knumh.
            IF lt_knumh-knumh_new IS NOT INITIAL.
              WRITE: / 'No. RFQ ', ls_header-doc_number, 'Kode Knumh : ', lt_knumh-knumh_new.
            ELSE.
            ENDIF.
          ENDLOOP.
          REFRESH lt_knumh.
        ENDIF.
      ELSE.
        lv_sw = 'E'.
        "        WRITE: / 'RFQ No-item : ', ls_item-doc_number,'-', ls_item-doc_item, sy-vline, 'Gagal create quotation'.
        CONCATENATE 'RFQ No-item : ' ls_item-doc_number '-' ls_item-doc_item '-Gagal create quotation' INTO return-msgv1.
        CONCATENATE 'RFQ No-item : ' ls_item-doc_number '-' ls_item-doc_item '--> Gagal create quotation' INTO gt_return-msgv1.
        gt_return-msgtyp = 'E'.
        gt_return-msgid = 'ZZ'.
        gt_return-msgnr ='003'.
        APPEND return.
        APPEND gt_return.
        APPEND LINES OF t_bdcmsg[] TO return[].
**        APPEND LINES OF t_bdcmsg[] TO gt_return[].
        LOOP AT t_bdcmsg.
          gt_return-doc_number = ls_item-doc_number.
          MOVE-CORRESPONDING t_bdcmsg TO gt_return.
          APPEND gt_return.
        ENDLOOP.
**        LOOP AT gt_return.
**          gt_return-doc_number = ls_item-doc_number.
**          MODIFY gt_return.
**        ENDLOOP.
        ROLLBACK WORK.
      ENDIF.
      CLEAR: ls_item.
    ENDLOOP.
    IF lv_sw = 'S'.
      WRITE: / 'RFQ No : ', ls_header-doc_number, sy-vline, 'Berhasil create quotation'.
      gt_post-coll_no = ls_header-coll_no.
      gt_post-rfq_no = ls_header-doc_number.
      gt_post-status = 'S'.
      APPEND gt_post.
****** send data to WEB
**      SELECT SINGLE * INTO CORRESPONDING FIELDS OF   gs_zhsmmmdt003 FROM zhsmmmdt003
**        WHERE zproses = 'HSM_QOUT'
**              AND zdata = ls_header-coll_no.
**      IF sy-subrc EQ 0.
**        gs_zhsmmmdt003-status = 'D'.
**        MODIFY zhsmmmdt003 FROM gs_zhsmmmdt003.
**      ENDIF.
**      CONCATENATE '{ "RFQ_no" : "' ls_header-doc_number  '", "status" : "S" } ' INTO lv_json.
**      WRITE: / lv_json.
**      PERFORM f_post_data_json(ztdsit_i001) USING lv_json 'HSM_QOUT' sy-subrc lv_str.
**      CONCATENATE 'POST_' ls_header-doc_number INTO  lv_nama.
**      PERFORM f_create_text_json(ztdsit_i001) USING lv_json lv_nama '/inbound/tnt/' 'HSM_QOUT'.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHANGE_QUOTATION_BDC





*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_ALPHA
*&---------------------------------------------------------------------*
FORM f_conversion_alpha  USING    fu_value
                         CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fu_value
    IMPORTING
      output = fc_value.
ENDFORM.                    " F_CONVERSION_ALPHA

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_QUOTATION_BAPI
*&---------------------------------------------------------------------*
FORM f_change_quotation_bapi  TABLES   quotation_items           STRUCTURE bs01mmitem
                                       quotation_item_schedules  STRUCTURE bs01mmschedule
                                       quotation_header          STRUCTURE bs01mmhead.
  DATA : lt_item   TYPE STANDARD TABLE OF bapimeoutitem,
         lt_itemx	 TYPE STANDARD TABLE OF bapimeoutitemx,
         ls_item   LIKE LINE OF lt_item,
         ls_itemx  LIKE LINE OF lt_itemx,
         ls_qitem  TYPE bs01mmitem,
         lt_return TYPE STANDARD TABLE OF bapiret2,
         ls_return LIKE LINE OF lt_return.

  DATA : lv_mess(132).

  LOOP AT quotation_items INTO ls_qitem.
    ls_item-item_no     = ls_qitem-doc_item.
    ls_item-net_price   = ls_qitem-net_price.
    APPEND ls_item TO lt_item.

    ls_itemx-item_no    = ls_qitem-doc_item.
    ls_itemx-net_price  = 'X'.
    APPEND ls_itemx TO lt_itemx.

    CALL FUNCTION 'BAPI_CONTRACT_CHANGE'
      EXPORTING
        purchasingdocument = quotation_header-doc_number
      TABLES
        item               = lt_item
        itemx              = lt_itemx
        return             = lt_return.

    READ TABLE lt_return INTO ls_return
                         WITH KEY type = 'E'.
    IF sy-subrc <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ELSE.
      SKIP 5.
      LOOP AT lt_return INTO ls_return.
        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            msgid               = ls_return-id
            msgnr               = ls_return-number
            msgv1               = ls_return-message_v1
            msgv2               = ls_return-message_v2
            msgv3               = ls_return-message_v3
            msgv4               = ls_return-message_v4
          IMPORTING
            message_text_output = lv_mess.

        WRITE:/ lv_mess.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHANGE_QUOTATION_BAPI

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_PIR
*&---------------------------------------------------------------------*
FORM f_change_pir  TABLES   quotation_items           STRUCTURE bs01mmitem
                            quotation_item_schedules  STRUCTURE bs01mmschedule
                            quotation_header          STRUCTURE bs01mmhead.
  DATA : lt_xheader TYPE STANDARD TABLE OF bs01mmhead,
         ls_xheader TYPE bs01mmhead,
         ls_header  TYPE bs01mmhead.

  DATA : lt_mara   TYPE STANDARD TABLE OF bs01mmitem,
         ls_mara   LIKE LINE OF lt_mara,
         ls_bdcmsg LIKE LINE OF t_bdcmsg.

  DATA : lv_mode,
         lv_dcpfm         LIKE usr01-dcpfm,
         lv_update,
         lv_ekorg         TYPE eine-ekorg,
         lv_price_unit(5),
         lv_price(20).
  DATA: lv_norut(9) TYPE n, ld_ctr TYPE i, ld_cal TYPE i, ld_cal1 TYPE p DECIMALS 2, ld_cal2 TYPE i.
  SELECT SINGLE dcpfm INTO lv_dcpfm FROM usr01 WHERE bname = sy-uname.
  lv_mode   = 'N'.
  lv_update = 'S'.
  lv_ekorg  = 'TNT'.

  lt_xheader[]  = quotation_header[].
  SORT lt_xheader BY doc_number vendor.
  DELETE ADJACENT DUPLICATES FROM lt_xheader COMPARING doc_number vendor.
  SKIP 1.
  WRITE: / 'Proses Update PIR'.
  LOOP AT lt_xheader INTO ls_xheader.
    CLEAR : t_bdcdata[], t_bdcmsg[], t_bdcdata, t_bdcmsg, lt_mara[], lt_mara.


    PERFORM f_get_material_mpn  TABLES quotation_items
                                       lt_mara
                                USING ls_xheader-doc_number ls_xheader-vendor
                                      lv_ekorg.
    LOOP AT lt_mara INTO ls_mara WHERE doc_number = ls_xheader-doc_number.
      CLEAR: ld_ctr, ld_cal.

      CLEAR : t_bdcdata[], t_bdcmsg[], t_bdcdata, t_bdcmsg, lv_price_unit.


      LOOP AT gt_price_scale WHERE rfq_no = ls_xheader-doc_number AND
                                   item_rfq = ls_mara-doc_item.
        ADD 1 TO ld_ctr.
*** Untuk PIR khusus yang ada scale maka harga diambil adalah scale yg tengah.
      ENDLOOP.
      IF ld_ctr > 1.
        ld_cal2 = ld_ctr MOD 2.
        ld_cal1 = ld_ctr / 2 .
        CALL FUNCTION 'ROUND'
          EXPORTING
            input         = ld_cal1
            sign          = '-'
          IMPORTING
            output        = ld_cal
          EXCEPTIONS
            input_invalid = 1
            overflow      = 2
            type_invalid  = 3
            OTHERS        = 4.
        ld_cal = ld_cal + 1.
        SORT gt_price_scale BY  rfq_no item_rfq urutan.
        READ TABLE gt_price_scale WITH KEY rfq_no = ls_xheader-doc_number
                                     item_rfq = ls_mara-doc_item
                                     urutan = ld_cal
                                     BINARY SEARCH.
        IF sy-subrc EQ 0.
          PERFORM f_price_conversion_bdc USING gt_price_scale-amount_scale ls_xheader-currency
                                 lv_dcpfm
                           CHANGING lv_price.
        ENDIF.
      ELSE.
        PERFORM f_price_conversion_bdc USING ls_mara-net_price ls_xheader-currency
                                         lv_dcpfm
                                   CHANGING lv_price.
      ENDIF.
      IF ls_mara-price_unit IS INITIAL OR ls_mara-price_unit = 0.
        ls_mara-price_unit = 1.
      ENDIF.
      WRITE ls_mara-price_unit TO lv_price_unit NO-GAP NO-GROUPING DECIMALS 0.
      CONDENSE lv_price_unit.
      PERFORM f_bdc_data TABLES t_bdcdata USING :
           'X'  'SAPMM06I'          '0100',
           ' '  'BDC_OKCODE'        '/00',
           ' '  'EINA-LIFNR'        ls_xheader-vendor,
           ' '  'EINA-MATNR'        ls_mara-material,
           ' '  'EINE-EKORG'        ls_xheader-purch_org,
           ' '  'RM06I-NORMB'       'X'.
      PERFORM f_bdc_data TABLES t_bdcdata USING :
           'X'  'SAPMM06I'          '0101',
           ' '  'BDC_OKCODE'        '=KO',
           ' '  'EINA-MEINS'        ls_mara-unit.
      PERFORM f_bdc_data TABLES t_bdcdata USING :
           'X'  'SAPLV14A'          '0102',
           ' '  'BDC_OKCODE'        '=NEWD'.

      PERFORM f_bdc_data TABLES t_bdcdata USING :
           'X'  'SAPMV13A'          '0201',
           ' '  'BDC_OKCODE'        '=SICH',
           ' '  'RV13A-DATBI'       '31.12.9999', " 22-12-23 dihard code jadi 31 des 9999 ikut manual  tnt maintance pir ls_mara-trackingno,
           ' '  'KONP-KBETR(01)'    lv_price,
           ' '  'KONP-KONWA(01)'    ls_xheader-currency,
           ' '  'KONP-KPEIN(01)'    lv_price_unit,  "ls_mara-price_unit.
           ' '  'KONP-KMEIN(01)'    ls_mara-unit.
**      PERFORM f_bdc_data TABLES t_bdcdata USING :
**           'X'  'SAPMV13A'          '0200',
**           ' '  'BDC_OKCODE'        '=SICH'.
      CALL TRANSACTION 'ME12' USING t_bdcdata
                              MODE lv_mode
                              UPDATE lv_update
                              MESSAGES INTO t_bdcmsg.
      READ TABLE t_bdcmsg INTO ls_bdcmsg
                          WITH KEY msgtyp = 'E'.
      IF sy-subrc = 0.
        PERFORM f_add_error_table USING ls_xheader-doc_number ls_mara-material
                                        ls_mara-net_price ls_xheader-currency
                                        '' ''.
        "        WRITE: / 'Update PIR material. ', ls_mara-material, sy-vline, ls_xheader-vendor, sy-vline, lv_price, sy-vline, 'Gagal Change PIR'.
        APPEND LINES OF t_bdcmsg[] TO return[].
**        APPEND LINES OF t_bdcmsg[] TO gt_return[].
        CONCATENATE 'Update PIR :' ls_mara-material '- Vendor : ' ls_xheader-vendor INTO gt_return-msgv1 SEPARATED BY space.
        CONCATENATE '- Dgn Harga : ' ls_xheader-currency lv_price  INTO gt_return-msgv2 SEPARATED BY space.
        CONCATENATE '- Doc. RFQ : ' ls_xheader-doc_number '--> Gagal Change PIR' INTO gt_return-msgv3 SEPARATED BY space..
        gt_return-doc_number = ls_mara-material.
        gt_return-msgtyp = 'E'.
        gt_return-msgid = 'ZZ'.
        gt_return-msgnr ='003'.
        APPEND gt_return.
**        CONCATENATE 'Doc. RFQ : ' ls_xheader-doc_number INTO gt_return-msgv1.
**        gt_return-doc_number = ls_mara-material.
**        gt_return-msgtyp = 'E'.
**        gt_return-msgid = 'ZZ'.
**        gt_return-msgnr ='003'.
**        APPEND gt_return.
        LOOP AT t_bdcmsg.
          gt_return-doc_number = ls_mara-material.
          MOVE-CORRESPONDING t_bdcmsg TO gt_return.
          APPEND gt_return.
        ENDLOOP.
      ELSE.
        WRITE: / 'Update PIR material. ', ls_mara-material, sy-vline, ls_xheader-vendor, sy-vline, lv_price, sy-vline, 'Berhasil Change PIR'.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_CHANGE_PIR

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_PIR
*&---------------------------------------------------------------------*
FORM f_change_pir_function  TABLES   quotation_items           STRUCTURE bs01mmitem
                            quotation_item_schedules  STRUCTURE bs01mmschedule
                            quotation_header          STRUCTURE bs01mmhead.
  DATA : lt_xheader TYPE STANDARD TABLE OF bs01mmhead,
         ls_xheader TYPE bs01mmhead,
         ls_header  TYPE bs01mmhead.

  DATA : lt_mara   TYPE STANDARD TABLE OF bs01mmitem,
         ls_mara   LIKE LINE OF lt_mara,
         ls_bdcmsg LIKE LINE OF t_bdcmsg.

  DATA : lv_mode,
         lv_dcpfm         LIKE usr01-dcpfm,
         lv_update,
         lv_ekorg         TYPE eine-ekorg,
         lv_price_unit(5),
         lv_price(20).
  DATA: ld_ctr  TYPE i, ld_cal TYPE i, ld_cal1 TYPE p DECIMALS 2, ld_cal2 TYPE i.
  DATA : "lt_bapiret2    TYPE STANDARD TABLE OF bapiret2,
    "ls_bapiret2    LIKE LINE OF lt_bapiret2,
    lv_norut(9)  TYPE n,
    lv_operation TYPE bapicondct-operation,
    lv_varkey    TYPE char100,
    lv_kotabnr   TYPE kotabnr.
  DATA: ld_knumh LIKE konh-knumh.
  DATA: cr           LIKE TABLE OF komv WITH HEADER LINE,
        key_fields   LIKE TABLE OF komg WITH HEADER LINE,
        ls_komk      TYPE komk,
        ls_komp      TYPE komp,
        copy_staffel LIKE TABLE OF condscale WITH HEADER LINE,
        lt_knumh     TYPE STANDARD TABLE OF knumh_comp WITH HEADER LINE,
        t_komv_idoc  LIKE TABLE OF komv_idoc WITH HEADER LINE.
  "  DATA: lv_scale(20), lv_scale1(20), lv_scale2(20)..
  "  DATA: ls_a661 TYPE a661.

  DATA: lv_tabname TYPE tabname.
*        lv_varkey TYPE vim_enqkey,
  "lv_subrc  TYPE sy-subrc.
  DATA: ld_new_record, ld_datab LIKE sy-datum,  ld_datbi LIKE sy-datum, ld_prdat LIKE sy-datum.

  SELECT SINGLE dcpfm INTO lv_dcpfm FROM usr01 WHERE bname = sy-uname.
  lv_mode   = 'N'.
  lv_update = 'S'.
  lv_ekorg  = 'TNT'.

  lt_xheader[]  = quotation_header[].
  SORT lt_xheader BY doc_number vendor.
  DELETE ADJACENT DUPLICATES FROM lt_xheader COMPARING doc_number vendor.
  SKIP 1.
  WRITE: / 'Proses Update PIR'.
  LOOP AT lt_xheader INTO ls_xheader.
    CLEAR : t_bdcdata[], t_bdcmsg[], t_bdcdata, t_bdcmsg, lt_mara[], lt_mara.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_xheader-vendor
      IMPORTING
        output = ls_xheader-vendor.

    PERFORM f_get_material_mpn  TABLES quotation_items
                                       lt_mara
                                USING ls_xheader-doc_number ls_xheader-vendor
                                      lv_ekorg.
    LOOP AT lt_mara INTO ls_mara WHERE doc_number = ls_xheader-doc_number.
      CLEAR : t_bdcdata[], t_bdcmsg[], t_bdcdata, t_bdcmsg, lv_price_unit.
      IF ls_mara-price_unit IS INITIAL OR ls_mara-price_unit = 0.
        ls_mara-price_unit = 1.
      ENDIF.
      WRITE ls_mara-price_unit TO lv_price_unit NO-GAP NO-GROUPING DECIMALS 0.
      CONDENSE lv_price_unit.
**      IF ls_xheader-currency = 'IDR' OR ls_xheader-currency = 'THB'.
**        ls_mara-net_price = ls_mara-net_price / 100.
**      ENDIF.

      PERFORM f_price_conversion USING ls_mara-net_price ls_xheader-currency
                                       lv_dcpfm
                                 CHANGING lv_price.
      "      lv_price = lv_price * 10.
      CLEAR: cr[], lv_varkey, key_fields, ls_komk, ls_komp, t_komv_idoc,
            t_komv_idoc[], ld_new_record, ld_datab, ld_datbi, ld_prdat.
      lv_kotabnr = '018'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_xheader-vendor
        IMPORTING
          output = ls_xheader-vendor.

      CONCATENATE ls_xheader-vendor ls_mara-material ls_xheader-purch_org '0'
                  INTO lv_varkey RESPECTING BLANKS.

      CALL FUNCTION 'SD_CONDITION_KOMG_FILL'
        EXPORTING
          p_kotabnr = lv_kotabnr
          p_kvewe   = 'A'
          p_vakey   = lv_varkey
        IMPORTING
          p_komg    = key_fields.

*- Fill KOMK
      MOVE-CORRESPONDING key_fields TO ls_komk.
      ls_komk-mandt = sy-mandt.
      ls_komk-kappl = 'M'.

*- Fill KOMP
      MOVE-CORRESPONDING key_fields TO ls_komp.
      ls_komp-kposn = '000001'.

*- Fill KOMV_IDOC
      t_komv_idoc-kznep = ' '.
      t_komv_idoc-kosrt = ls_xheader-quotation.
      "      t_komv_idoc-anzauf = '01'.
      APPEND t_komv_idoc.

*- Fill KOMV
      cr-kappl = 'M'.
      cr-kschl = 'ZPB0'.
      cr-kopos = '01'.
      CLEAR: cr-kzbzg.
      cr-stfkz = 'A'. " A --> Base-scale, B --> To-scale
      cr-kzbzg = 'C'. " C --> quantity Scale
      "      cr-kstbm = 0.
      cr-konms = ls_mara-unit. "'KG'.
      CLEAR: cr-konws, cr-kzbzg, cr-stfkz.
      cr-krech = 'C'. "C --> berdasarkan qty
      cr-kpein = lv_price_unit. "'1'.
      PERFORM f_conversion_unit USING ls_mara-unit
                                CHANGING cr-kmein.

      "      cr-kmein = ls_mara-unit. "'KG'. "i_matnr-meins.
      "      cr-meins = ls_mara-unit.

      cr-waers = ls_xheader-currency. "'USD'. "gt_zediscst002-konwa. "'%'.
      cr-kbetr = lv_price.                                  " -10000 .
      cr-kumza = 1.
      cr-kumne = 1.
      "cr-kstbw = 0.
      CONCATENATE '$' lv_norut INTO cr-knumh.
      cr-mandt = sy-mandt.
      "CLEAR: cr-kzbzg, cr-konms, cr-konws, cr-kzbzg. "
      APPEND cr.

      DATA: lv_scale(20), lv_scale1(20), lv_scale2(20)..
      CLEAR: copy_staffel[].
      SORT gt_price_scale BY rfq_no item_rfq klfn1.
      CLEAR: ld_ctr, ld_cal.
      LOOP AT gt_price_scale WHERE rfq_no = ls_xheader-doc_number AND
                                   item_rfq = ls_mara-doc_item.
        ADD 1 TO ld_ctr.
*** Untuk PIR khusus yang ada scale maka harga diambil adalah scale yg tengah.
***        copy_staffel-klfn1      = gt_price_scale-klfn1.
***        copy_staffel-kopos      = '01'.
***        WRITE gt_price_scale-qty_scale TO lv_scale NO-GAP NO-GROUPING. "CURRENCY 'IDR'
***        CONDENSE lv_scale NO-GAPS.
***        SPLIT lv_scale AT '.' INTO lv_scale1 lv_scale2.
***        TRANSLATE lv_scale1 USING '. '.
***        TRANSLATE lv_scale1 USING ',.'.
***        CONDENSE lv_scale1 NO-GAPS.
***        copy_staffel-kstbm   = lv_scale1. " Scale Price
***
***        WRITE gt_price_scale-amount_scale TO lv_scale NO-GAP NO-GROUPING. "CURRENCY 'IDR'
***        CONDENSE lv_scale NO-GAPS.
***        TRANSLATE lv_scale USING '. '.
***        TRANSLATE lv_scale USING ',.'.
***        copy_staffel-kbetr      = lv_scale. "gt_zediscst002-kstbm. "'1'.
***        copy_staffel-konpkonms = ls_mara-unit.
***        copy_staffel-rv13akonwa = ls_xheader-currency. "gt_price_scale-currency.
***        copy_staffel-kzbzg      = 'C'. " C -  Scale By quantity
***
***        "        copy_staffel-klfka = 'X'.
***        copy_staffel-konpkmein = ls_mara-unit.
***        CLEAR: copy_staffel-konpkonws.
***        copy_staffel-konpkonms = ls_mara-unit.
***        APPEND copy_staffel.
      ENDLOOP.
      IF ld_ctr > 1.
        ld_cal2 = ld_ctr MOD 2.
        ld_cal1 = ld_ctr / 2 .
        CALL FUNCTION 'ROUND'
          EXPORTING
            input         = ld_cal1
            sign          = '-'
          IMPORTING
            output        = ld_cal
          EXCEPTIONS
            input_invalid = 1
            overflow      = 2
            type_invalid  = 3
            OTHERS        = 4.
        ld_cal = ld_cal + 1.
        SORT gt_price_scale BY  rfq_no item_rfq urutan.
        READ TABLE gt_price_scale WITH KEY rfq_no = ls_xheader-doc_number
                                     item_rfq = ls_mara-doc_item
                                     urutan = ld_cal
                                     BINARY SEARCH.
        IF sy-subrc EQ 0.
**          IF ls_xheader-currency = 'IDR' OR ls_xheader-currency = 'THB'.
**            gt_price_scale-amount_scale = gt_price_scale-amount_scale / 1000.
**          ENDIF.

          PERFORM f_price_conversion USING gt_price_scale-amount_scale ls_xheader-currency
                                 lv_dcpfm
                           CHANGING lv_price.
          LOOP AT cr.
            cr-kbetr = lv_price.
            MODIFY cr TRANSPORTING kbetr.
          ENDLOOP.
        ENDIF.
      ENDIF.

      ld_datab = sy-datum. " - 3.
      ld_datbi = '99991231'.
      CALL FUNCTION 'RV_CONDITION_COPY'
        EXPORTING
          application              = 'M'
          condition_table          = '018' "lv_kotabnr "'661' "gt_zediscst001-KOTABNR "'304'
          condition_type           = 'ZPB0'
          date_from                = ld_datab "sy-datum "p_datab "sy-datum "gt_zediscst001-datab "'20131101'
          date_to                  = ld_datbi "p_datbi "sy-datum "gt_zediscst001-datbi "'99991231'
          enqueue                  = 'X'
          i_komk                   = ls_komk
          i_komp                   = ls_komp
          key_fields               = key_fields
          maintain_mode            = 'A'
          no_authority_check       = 'X'
          keep_old_records         = ' '
          used_by_idoc             = 'X'      " when suppling scales prices, this flag must be X else price will be created with Zero price.
          overlap_confirmed        = 'X'
        IMPORTING
          e_komk                   = ls_komk
          e_komp                   = ls_komp
          new_record               = ld_new_record
          e_datab                  = ld_datab
          e_datbi                  = ld_datbi
          e_prdat                  = ld_prdat
        TABLES
          copy_records             = cr
          copy_staffel             = copy_staffel
          copy_recs_idoc           = t_komv_idoc
        EXCEPTIONS
          enqueue_on_record        = 01
          invalid_application      = 02
          invalid_condition_number = 03
          invalid_condition_type   = 04
          no_authority_ekorg       = 05
          no_authority_kschl       = 06
          no_authority_vkorg       = 07
          no_selection             = 08
          table_not_valid          = 09.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'RV_CONDITION_SAVE'
          TABLES
            knumh_map = lt_knumh.
        CALL FUNCTION 'RV_CONDITION_RESET'.
        COMMIT WORK AND WAIT.
      ELSE.
      ENDIF.
      LOOP AT lt_knumh.
        IF lt_knumh-knumh_new IS NOT INITIAL.
          WRITE: / 'Material : ', ls_mara-material, 'Kode Knumh : ', lt_knumh-knumh_new.
        ELSE.
        ENDIF.
      ENDLOOP.
      REFRESH lt_knumh.

********      PERFORM f_bdc_data TABLES t_bdcdata USING :
********           'X'  'SAPMM06I'          '0100',
********           ' '  'BDC_OKCODE'        '/00',
********           ' '  'EINA-LIFNR'        ls_xheader-vendor,
********           ' '  'EINA-MATNR'        ls_mara-material,
********           ' '  'EINE-EKORG'        ls_xheader-purch_org,
********           ' '  'RM06I-NORMB'       'X'.
********      PERFORM f_bdc_data TABLES t_bdcdata USING :
********           'X'  'SAPMM06I'          '0101',
********           ' '  'BDC_OKCODE'        '=KO',
********           ' '  'EINA-MEINS'        ls_mara-unit.
********      PERFORM f_bdc_data TABLES t_bdcdata USING :
********           'X'  'SAPLV14A'          '0102',
********           ' '  'BDC_OKCODE'        '=NEWD'.
********
********      PERFORM f_bdc_data TABLES t_bdcdata USING :
********           'X'  'SAPMV13A'          '0201',
********           ' '  'BDC_OKCODE'        '=SICH',
********           ' '  'RV13A-DATBI'       '31.12.9999', " 22-12-23 dihard code jadi 31 des 9999 ikut manual  tnt maintance pir ls_mara-trackingno,
********           ' '  'KONP-KBETR(01)'    lv_price,
********           ' '  'KONP-KONWA(01)'    ls_xheader-currency,
********           ' '  'KONP-KPEIN(01)'    lv_price_unit,  "ls_mara-price_unit.
********           ' '  'KONP-KMEIN(01)'    ls_mara-unit.
********
**********      PERFORM f_bdc_data TABLES t_bdcdata USING :
**********           'X'  'SAPMV13A'          '0200',
**********           ' '  'BDC_OKCODE'        '=SICH'.
********      CALL TRANSACTION 'ME12' USING t_bdcdata
********                              MODE lv_mode
********                              UPDATE lv_update
********                              MESSAGES INTO t_bdcmsg.
********      READ TABLE t_bdcmsg INTO ls_bdcmsg
********                          WITH KEY msgtyp = 'E'.
********      IF sy-subrc = 0.
********        PERFORM f_add_error_table USING ls_xheader-doc_number ls_mara-material
********                                        ls_mara-net_price ls_xheader-currency
********                                        '' ''.
********        WRITE: / 'Update PIR material. ',   ls_mara-material, sy-vline, 'Gagal Change PIR'.
********      ELSE.
********        WRITE: / 'Update PIR material. ',   ls_mara-material, sy-vline, 'Berhasil Change PIR'.
********      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_CHANGE_PIR

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_PR
*&---------------------------------------------------------------------*
FORM f_delete_pr  TABLES   quotation_items           STRUCTURE bs01mmitem
                           quotation_item_schedules  STRUCTURE bs01mmschedule
                           quotation_header          STRUCTURE bs01mmhead.

  DATA : bapimereqheader TYPE STANDARD TABLE OF bapimereqheader,
         return          TYPE STANDARD TABLE OF bapiret2,
         pritem          TYPE STANDARD TABLE OF bapimereqitemimp,
         pritemx         TYPE STANDARD TABLE OF bapimereqitemx,
         ls_pritem       TYPE bapimereqitemimp,
         ls_pritemx      TYPE bapimereqitemx,
         ls_return       TYPE bapiret2.

  DATA : lt_eban  TYPE STANDARD TABLE OF eban,
         ls_eban  LIKE LINE OF lt_eban,
         lt_xeban TYPE STANDARD TABLE OF eban,
         ls_xeban LIKE LINE OF lt_xeban.

  DATA : ls_header          TYPE bs01mmhead.

  DATA : lv_lfdat           TYPE eban-lfdat.
  SKIP 1.
  WRITE: / 'Proses Delete PR'.

  LOOP AT quotation_header INTO ls_header.
    PERFORM f_get_pr TABLES lt_eban
                     USING  ls_header-doc_number.

    SORT lt_eban BY lfdat.
    READ TABLE lt_eban INTO ls_eban INDEX 1.
    IF sy-subrc = 0.
      lv_lfdat  = ls_eban-lfdat.
    ENDIF.

    lt_xeban[]  = lt_eban[].
    SORT lt_xeban BY banfn.
    DELETE ADJACENT DUPLICATES FROM lt_xeban COMPARING banfn.
    IF lt_xeban[] IS NOT INITIAL.
      LOOP AT lt_xeban INTO ls_xeban.
        CLEAR : pritem[], pritemx[], pritem, pritemx.
        LOOP AT lt_eban INTO ls_eban WHERE banfn = ls_xeban-banfn.
          IF ls_eban-frgkz = '1'.
            ls_pritem-preq_item   = ls_eban-bnfpo.
            ls_pritem-delete_ind  = 'X'.
            APPEND ls_pritem TO pritem.
            CLEAR ls_pritem.

            ls_pritemx-preq_item   = ls_eban-bnfpo.
            ls_pritemx-preq_itemx  = 'X'.
            ls_pritemx-delete_ind  = 'X'.
            APPEND ls_pritemx TO pritemx.
            CLEAR ls_pritemx.
          ENDIF.
        ENDLOOP.

        CALL FUNCTION 'BAPI_PR_CHANGE'
          EXPORTING
            number  = ls_xeban-banfn
          TABLES
            return  = return
            pritem  = pritem
            pritemx = pritemx.
        IF sy-subrc = 0.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.
        ELSE.
          READ TABLE return INTO ls_return
                            WITH KEY type = 'E'.
          IF sy-subrc = 0.
            PERFORM f_add_error_table USING '' '' '' ''
                                            ls_header-doc_number ls_xeban-banfn.
            WRITE: / 'PR No : ', ls_xeban-banfn, sy-vline, ' Gagal didelete cek di table ZHSMMMDT004'.
          ELSE.
            WRITE: / 'PR No : ', ls_xeban-banfn, sy-vline, ' Berhasil didelete'.
          ENDIF.

        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_DELETE_PR

*&---------------------------------------------------------------------*
*&      Form  F_GET_MATERIAL_MPN
*&---------------------------------------------------------------------*
FORM f_get_material_mpn  TABLES   ft_items STRUCTURE bs01mmitem
                                  ft_mara STRUCTURE bs01mmitem
                         USING    fu_ebeln fu_lifnr fu_ekorg.

  TYPES : BEGIN OF ty_mpn,
            infnr TYPE infnr,
            matnr TYPE matnr,
            matkl TYPE matkl,
            lifnr TYPE elifn,
            ekorg TYPE ekorg,
            esokz TYPE esokz,
            werks TYPE ewerk,
            inco1 TYPE inco1,
          END OF ty_mpn.

  DATA : lt_xmara  TYPE STANDARD TABLE OF mara,
         lt_ymara  TYPE STANDARD TABLE OF mara,
         lt_xitems TYPE STANDARD TABLE OF bs01mmitem,
         lt_mpn    TYPE STANDARD TABLE OF ty_mpn,
         ls_mpn    LIKE LINE OF lt_mpn,
         ls_xmara  LIKE LINE OF lt_xmara,
         ls_ymara  LIKE LINE OF lt_ymara,
         ls_mara   TYPE bs01mmitem,
         ls_items  TYPE bs01mmitem.

  DATA : lv_subrc     TYPE sy-subrc.

  lt_xitems[] = ft_items[].
  SORT lt_xitems BY material.
  DELETE ADJACENT DUPLICATES FROM lt_xitems COMPARING material.
  IF lt_xitems[] IS NOT INITIAL.
    SELECT *
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE lt_xmara
      FOR ALL ENTRIES IN lt_xitems
      WHERE matnr = lt_xitems-material
        AND mprof <> space.

    IF lt_xmara[] IS NOT INITIAL.
      SELECT *
        FROM mara
        INTO CORRESPONDING FIELDS OF TABLE lt_ymara
        FOR ALL ENTRIES IN lt_xmara
        WHERE bmatn = lt_xmara-matnr
        ORDER BY PRIMARY KEY.

      IF lt_ymara[] IS NOT INITIAL.
        SELECT eina~infnr eina~matnr eina~matkl eina~lifnr
          eine~ekorg eine~esokz eine~werks eine~inco1
          FROM eina JOIN eine ON eina~infnr = eine~infnr
          INTO CORRESPONDING FIELDS OF TABLE lt_mpn
          FOR ALL ENTRIES IN lt_ymara
          WHERE eina~matnr = lt_ymara-matnr
            AND eina~loekz = space
            AND eina~lifnr = fu_lifnr
            AND eine~ekorg = fu_ekorg
            AND eine~esokz = '0'
            AND eine~werks = space
            AND eine~loekz = space.

        SORT lt_mpn BY matnr.
        LOOP AT lt_mpn INTO ls_mpn.
          ls_mara-material    = ls_mpn-matnr.
          CLEAR ls_ymara.
          READ TABLE lt_ymara INTO ls_ymara
                              WITH KEY matnr = ls_mpn-matnr.
          IF sy-subrc = 0.
            CLEAR ls_items.
            READ TABLE ft_items INTO ls_items
                                WITH KEY doc_number = fu_ebeln
                                         material   = ls_ymara-bmatn.
            IF sy-subrc = 0.
              ls_mara-doc_number = ls_items-doc_number.
              ls_mara-doc_item   = ls_items-doc_item.
              ls_mara-net_price   = ls_items-net_price.
              ls_mara-unit        = ls_items-unit.
              ls_mara-price_unit  = ls_items-price_unit.
              PERFORM f_date_conversion USING ls_items-trackingno
                                        CHANGING ls_mara-trackingno.
              APPEND ls_mara TO ft_mara.
              CLEAR ls_mara.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ELSE.
      lv_subrc = 4.
    ENDIF.
  ENDIF.

  IF lv_subrc = 0.
    LOOP AT ft_items INTO ls_items WHERE doc_number = fu_ebeln.
      READ TABLE lt_xmara INTO ls_xmara
                          WITH KEY matnr = ls_items-material.
      IF sy-subrc <> 0.
        ls_mara-doc_number = ls_items-doc_number.
        ls_mara-doc_item   = ls_items-doc_item.
        ls_mara-material    = ls_items-material.
        ls_mara-net_price   = ls_items-net_price.
        ls_mara-unit        = ls_items-unit.
        ls_mara-price_unit  = ls_items-price_unit.
        PERFORM f_date_conversion USING ls_items-trackingno
                                  CHANGING ls_mara-trackingno.
        APPEND ls_mara TO ft_mara.
        CLEAR ls_mara.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT ft_items INTO ls_items WHERE doc_number = fu_ebeln.
      ls_mara-doc_number = ls_items-doc_number.
      ls_mara-doc_item   = ls_items-doc_item.
      ls_mara-material    = ls_items-material.
      ls_mara-net_price   = ls_items-net_price.
      ls_mara-unit        = ls_items-unit.
      ls_mara-price_unit  = ls_items-price_unit.
      PERFORM f_date_conversion USING ls_items-trackingno
                                CHANGING ls_mara-trackingno.
      APPEND ls_mara TO ft_mara.
      CLEAR ls_mara.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_MATERIAL_MPN

*&---------------------------------------------------------------------*
*&      Form  F_PRICE_CONVERSION
*&---------------------------------------------------------------------*
FORM f_price_conversion  USING    fu_price fu_currency fu_dcpfm
                         CHANGING fc_price.
  DATA : lv_netpr   TYPE ekpo-netpr.

** Khusus pakai call function harus dibagi 10 klau bdc bagi 100

  IF fu_currency = 'IDR' OR fu_currency = 'THB'.
    lv_netpr  = fu_price / 100.
    fc_price = lv_netpr.
  ELSE.
    lv_netpr = fu_price.
    WRITE lv_netpr TO fc_price CURRENCY fu_currency NO-GAP NO-GROUPING.
  ENDIF.
  TRANSLATE fc_price USING ',.'.
  CONDENSE fc_price NO-GAPS.
ENDFORM.                    " F_PRICE_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_PRICE_CONVERSION
*&---------------------------------------------------------------------*
FORM f_price_conversion_bdc  USING    fu_price fu_currency fu_dcpfm
                         CHANGING fc_price.
  DATA : lv_netpr   TYPE ekpo-netpr.

** Khusus pakai call function harus dibagi 10 klau bdc bagi 100

  IF fu_currency = 'IDR' OR fu_currency = 'THB'.
    lv_netpr  = fu_price / 100.
    WRITE lv_netpr TO fc_price CURRENCY fu_currency NO-GAP NO-GROUPING DECIMALS 0.
  ELSE.
    lv_netpr = fu_price.
    WRITE lv_netpr TO fc_price CURRENCY fu_currency NO-GAP NO-GROUPING.
  ENDIF.
  "  lv_netpr = lv_netpr * 10.
  "  TRANSLATE fc_price USING '. '.
  "  IF fu_dcpfm = ' '.
  "  TRANSLATE fc_price USING '.,'.
  " ENDIF.
  CONDENSE fc_price NO-GAPS.
ENDFORM.                    " F_PRICE_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_DATE_CONVERSION
*&---------------------------------------------------------------------*
FORM f_date_conversion  USING    fu_value
                        CHANGING fc_value.
  DATA : lv_date(10),
         lv_chr1(4),
         lv_chr2(4),
         lv_chr3(4).

  lv_chr3 = fu_value+6(2).
  lv_chr2 = fu_value+4(2).
  lv_chr1 = fu_value(4).
*  lv_date = fu_value.
*  SPLIT lv_date AT '-' INTO lv_chr1 lv_chr2 lv_chr3.
  CONCATENATE lv_chr3 lv_chr2 lv_chr1 INTO lv_date
  SEPARATED BY '.'.
  fc_value = lv_date.
ENDFORM.                    " F_DATE_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_GET_PR
*&---------------------------------------------------------------------*
FORM f_get_pr  TABLES   ft_eban          STRUCTURE eban
               USING    fu_ebeln.

  DATA : lt_eket      TYPE STANDARD TABLE OF eket.

  CLEAR : ft_eban[], ft_eban.

  SELECT *
    FROM eket
    INTO CORRESPONDING FIELDS OF TABLE lt_eket
    WHERE ebeln = fu_ebeln
    ORDER BY PRIMARY KEY.

  IF lt_eket[] IS NOT INITIAL.
    SELECT *
      FROM eban
      INTO CORRESPONDING FIELDS OF TABLE ft_eban
      FOR ALL ENTRIES IN lt_eket
      WHERE banfn = lt_eket-banfn
        AND loekz = space
        AND estkz NE 'R'
      ORDER BY PRIMARY KEY.
  ENDIF.
ENDFORM.                    " F_GET_PR

*&---------------------------------------------------------------------*
*&      Form  F_ADD_ERROR_TABLE
*&---------------------------------------------------------------------*
FORM f_add_error_table  USING    fu_submi fu_matnr fu_netpr fu_waers
                                 fu_anfnr fu_banfn.
  DATA : lt_004 TYPE STANDARD TABLE OF zhsmmmdt004,
         ls_004 LIKE LINE OF gt_004.

  ls_004-submi    = fu_submi.
  ls_004-anfnr    = fu_anfnr.
  ls_004-banfn    = fu_banfn.
  ls_004-matnr    = fu_matnr.
  ls_004-netpr    = fu_netpr.
  ls_004-waers    = fu_waers.
  APPEND ls_004 TO gt_004.
ENDFORM.                    " F_ADD_ERROR_TABLE
*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear_data .
  CLEAR:  gv_quotation, gv_str, gv_anfnr, gt_quoi, gt_quois, gt_quoh, return, gt_004.
  CLEAR: "gv_tender-tender[],
         gv_quotation-data[],
         "gs_detail-schedule[],
         gt_quoi[],
         gt_quois[],
         gt_quoh[],
         return[],
         gt_004[].
  REFRESH: "gv_tender-tender,
         gv_quotation-data, "detail,
         "gs_detail-schedule,
         gt_quoi,
         gt_quois,
         gt_quoh,
         return,
         gt_004.

ENDFORM.                    " F_CLEAR_DATA
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_data .
  DATA: lv_str TYPE string.
  DATA: lv_json TYPE string.
  DATA: lv_nama(15).
  DATA: lv_sw(1).
  DATA: gs_zhsmmmdt003 TYPE zhsmmmdt003.
  DATA: lv_line(120)      TYPE c.

  PERFORM f_convert_json USING gv_str CHANGING gv_quotation.
  "  gv_nama = gv_norfq.
  CONDENSE gv_norfq.
  CONCATENATE 'G_'  gv_norfq INTO gv_nama.
  PERFORM f_create_text_json(ztdsit_i001) USING gv_str gv_nama '/inbound/tnt/' 'HSM_QOUT'.
*    PERFORM f_change_quotation TABLES gt_quoi gt_quois
*                               USING  gs_quoh
*                               CHANGING gv_anfnr.

  PERFORM f_change_pir TABLES gt_quoi gt_quois
                              gt_quoh.
**  PERFORM f_change_pir_function TABLES gt_quoi gt_quois
**                              gt_quoh.

  PERFORM f_change_quotation_bdc TABLES gt_quoi gt_quois
                                        gt_quoh.

  PERFORM f_delete_pr TABLES gt_quoi gt_quois
                             gt_quoh.

*    PERFORM f_change_quotation_bapi TABLES gt_quoi gt_quois
*                                           gt_quoh.

  IF gt_004[] IS NOT INITIAL.
    TRY .
        MODIFY zhsmmmdt004 FROM TABLE gt_004.
      CATCH cx_root.
    ENDTRY.
  ENDIF.
  IF gt_004[] IS INITIAL.
    CLEAR: gs_zhsmmmdt003.
    gs_zhsmmmdt003-zdata = p_tender.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF  gs_zhsmmmdt003 FROM zhsmmmdt003
         WHERE zproses = 'HSM_QOUT'
           AND zdata = gs_zhsmmmdt003-zdata.
    IF sy-subrc EQ 0.
      gs_zhsmmmdt003-status = 'D'.
      MODIFY zhsmmmdt003 FROM gs_zhsmmmdt003.
    ENDIF.
  ENDIF.
  CLEAR : gt_quoi[], gt_quois[], gt_quoh[].

  SKIP 1.
  DELETE gt_return[] WHERE msgtyp NE 'E'.
  IF gt_return[] IS NOT INITIAL.
    WRITE: / 'Error Message Create PIR / Quotation'.
    LOOP AT gt_return WHERE msgtyp = 'E' AND doc_number(1) NE '6'.
      CLEAR: lv_line.
      MESSAGE ID gt_return-msgid TYPE gt_return-msgtyp
                     NUMBER gt_return-msgnr
                       WITH gt_return-msgv1
                            gt_return-msgv2
                            gt_return-msgv3
                            gt_return-msgv4
                       INTO lv_line.
      WRITE: / gt_return-doc_number, sy-vline, lv_line.
    ENDLOOP.
    SKIP 3.
    LOOP AT gt_return WHERE msgtyp = 'E' AND doc_number(1) EQ '6'.
      CLEAR: lv_line.
      MESSAGE ID gt_return-msgid TYPE gt_return-msgtyp
                     NUMBER gt_return-msgnr
                       WITH gt_return-msgv1
                            gt_return-msgv2
                            gt_return-msgv3
                            gt_return-msgv4
                       INTO lv_line.
      WRITE: / gt_return-doc_number, sy-vline, lv_line.
    ENDLOOP.
    IF p_tender IS NOT INITIAL.
      PERFORM send_email.
    ENDIF.
  ENDIF.
**** send data to WEB
  IF gt_post[] IS NOT INITIAL.
    WRITE: / 'Send Data to WEB'.
    LOOP AT gt_post.
      CLEAR: lv_json, lv_str, lv_nama, gs_zhsmmmdt003.
      SELECT SINGLE * INTO CORRESPONDING FIELDS OF   gs_zhsmmmdt003 FROM zhsmmmdt003
        WHERE zproses = 'HSM_QOUT'
              AND zdata = gt_post-coll_no.
      IF sy-subrc EQ 0.
        gs_zhsmmmdt003-status = 'D'.
        MODIFY zhsmmmdt003 FROM gs_zhsmmmdt003.
      ENDIF.
      CONCATENATE '{ "RFQ_no" : "' gt_post-rfq_no  '", "status" : "S" } ' INTO lv_json.
      WRITE: / lv_json.
      PERFORM f_post_data_json(ztdsit_i001) USING lv_json 'HSM_QOUT' sy-subrc lv_str.
      CONCATENATE 'POST_' gt_post-rfq_no INTO  lv_nama.
      PERFORM f_create_text_json(ztdsit_i001) USING lv_json lv_nama '/inbound/tnt/' 'HSM_QOUT'.
      CLEAR: gt_post.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PROSES_DATA
*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_UNIT
*&---------------------------------------------------------------------*
FORM f_conversion_unit  USING    fu_meins
                        CHANGING fc_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      input          = fu_meins
    IMPORTING
      output         = fc_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_CONVERSION_UNIT
*&---------------------------------------------------------------------*
*&      Form  SEND_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_email .

  DATA: send_request   TYPE REF TO cl_bcs,
        lv_sent_to_all TYPE os_boolean,
        mailsubject    TYPE so_obj_des,
        mailtext       TYPE bcsy_text,
        document       TYPE REF TO cl_document_bcs,
        sender         TYPE REF TO cl_cam_address_bcs,
        recipient_to   TYPE REF TO cl_cam_address_bcs,
        recipient_cc   TYPE REF TO cl_cam_address_bcs,
        recipient_bcc  TYPE REF TO cl_cam_address_bcs,
        bcs_exception  TYPE REF TO cx_bcs.
  DATA: lv_message(150).
  DATA: lv_email TYPE ad_smtpadr. " ADR6-SMTP_ADDR.
  DATA: lt_tvarvc TYPE STANDARD TABLE OF tvarvc WITH HEADER LINE.
  TRY.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_tvarvc FROM tvarvc WHERE name = 'ZHSMMM_E002'.
      send_request = cl_bcs=>create_persistent( ).
      CONCATENATE '[e-Procu]-Create PIR dan Update RFQ (' p_tender ')' INTO mailsubject.
      lv_message = '<P><br> Error Message Data PIR </br></P>'.
      APPEND lv_message TO mailtext.
      LOOP AT gt_return WHERE msgtyp = 'E' AND doc_number(1) NE '6'.
        CLEAR: lv_message.
        MESSAGE ID gt_return-msgid TYPE gt_return-msgtyp
                       NUMBER gt_return-msgnr
                         WITH gt_return-msgv1
                              gt_return-msgv2
                              gt_return-msgv3
                              gt_return-msgv4
                         INTO lv_message.
        CONCATENATE '<br>' gt_return-doc_number '| Error : ' lv_message '</br>' INTO lv_message SEPARATED BY space.
        APPEND lv_message TO mailtext.
      ENDLOOP.
      lv_message = '<P><br> Error Message Data RFQ </br></P>'.
      APPEND lv_message TO mailtext.

      LOOP AT gt_return WHERE msgtyp = 'E' AND doc_number(1) EQ '6'.
        CLEAR: lv_message.
        MESSAGE ID gt_return-msgid TYPE gt_return-msgtyp
                       NUMBER gt_return-msgnr
                         WITH gt_return-msgv1
                              gt_return-msgv2
                              gt_return-msgv3
                              gt_return-msgv4
                         INTO lv_message.
        CONCATENATE '<br>' gt_return-doc_number '| Error : ' lv_message '</br>' INTO lv_message SEPARATED BY space.
        APPEND lv_message TO mailtext.
      ENDLOOP.

      lv_message = '<P><br> Mohon Cek backgroud job  ZEPROCUREMENT dan Lihat spool program ZHSMMM_E002</br></P>'.
      APPEND lv_message TO mailtext.

      CONCATENATE '<P><br>Re-Run Program ZHSMMM_E002 dan masukan Collective No : ' p_tender  '</br></P>' INTO lv_message SEPARATED BY space.
      APPEND lv_message TO mailtext.

      CONCATENATE '<br></br><br></br><br> Email Auto Generated by System </br> <br> </br> <br> </br> <br>' sy-uname  '</br></P>' INTO lv_message SEPARATED BY space.
      APPEND lv_message TO mailtext.
      document = cl_document_bcs=>create_document(
       i_type = 'HTM' "'RAW'
       i_text = mailtext
       i_subject = mailsubject ).

      send_request->set_document( document ).
      sender = cl_cam_address_bcs=>create_internet_address( 'eproc_info@thetempogroup.com' ).
      send_request->set_sender( sender ).

**      recipient_to = cl_cam_address_bcs=>create_internet_address( 'sukardi@thetempogroup.com' ). "'budi.p@TheTempoGroup.com' ).
**      send_request->add_recipient( i_recipient = recipient_to ).

      LOOP AT lt_tvarvc WHERE opti = 'TO'.
        lv_email = lt_tvarvc-low.
        recipient_to = cl_cam_address_bcs=>create_internet_address( lv_email ). "'budi.p@TheTempoGroup.com' ).
        send_request->add_recipient( i_recipient = recipient_to ).
      ENDLOOP.

      LOOP AT lt_tvarvc WHERE opti = 'CC'.
        lv_email = lt_tvarvc-low.
        recipient_cc = cl_cam_address_bcs=>create_internet_address( lv_email ).
        send_request->add_recipient( i_recipient = recipient_cc
        i_copy = 'X' ).
      ENDLOOP.
**        sender = cl_cam_address_bcs=>create_internet_address( 'sukardi@thetempogroup.com' ).
**        send_request->add_recipient( i_recipient = recipient_cc
**        i_blind_copy = 'X' ).


      LOOP AT lt_tvarvc WHERE opti = 'BC'.
        lv_email = lt_tvarvc-low.
        recipient_bcc = cl_cam_address_bcs=>create_internet_address( lv_email ).
        send_request->add_recipient( i_recipient = recipient_bcc
        i_blind_copy = 'X' ).
      ENDLOOP.

**        sender = cl_cam_address_bcs=>create_internet_address( 'sukardi@thetempogroup.com' ).
**        send_request->add_recipient( i_recipient = recipient_bcc
**        i_blind_copy = 'X' ).

      IF lt_tvarvc[] IS INITIAL.
        recipient_to = cl_cam_address_bcs=>create_internet_address( 'Support.Center@TheTempoGroup.com' ). "'budi.p@TheTempoGroup.com' ).
        send_request->add_recipient( i_recipient = recipient_to ).
        recipient_cc = cl_cam_address_bcs=>create_internet_address( 'sekar.mulya@thetempogroup.com' ).
        send_request->add_recipient( i_recipient = recipient_cc
        i_copy = 'X' ).

        recipient_cc = cl_cam_address_bcs=>create_internet_address( 'prayogo.s@thetempogroup.com' ).
        send_request->add_recipient( i_recipient = recipient_cc
        i_copy = 'X' ).

        recipient_bcc = cl_cam_address_bcs=>create_internet_address( 'sukardi@thetempogroup.com' ).
        send_request->add_recipient( i_recipient = recipient_bcc
        i_copy = 'X' ).
      ENDIF.

      "    recipient_cc = cl_cam_address_bcs=>create_internet_address( 'sekar.mulya@thetempogroup.com' ).
      "    send_request->add_recipient( i_recipient = recipient_cc
      .

**      recipient_bcc = cl_cam_address_bcs=>create_internet_address( 'sukardi@thetempogroup.com' ).
**      send_request->add_recipient( i_recipient = recipient_bcc
**       i_blind_copy = 'X' ).

*    data(lv_sent_to_all) = send_request->send( ).
      lv_sent_to_all = send_request->send( ).
**      IF lv_sent_to_all = 'X'.
**        WRITE: / 'Email sent to all recipients'.
**      ELSE.
**        WRITE: / 'Email could not be sent to all recipients!'.
**      ENDIF.

      COMMIT WORK.

    CATCH cx_bcs INTO bcs_exception.

      WRITE: 'Error occurred while sending email: Error Type', bcs_exception->error_type.

  ENDTRY.

ENDFORM.                    " SEND_EMAIL
