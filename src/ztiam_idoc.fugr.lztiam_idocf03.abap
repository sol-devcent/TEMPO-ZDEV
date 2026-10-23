*----------------------------------------------------------------------*
***INCLUDE LZTIAM_IDOCF03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_PO_TIAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_PO_WEB  text
*      -->P_LV_JSON  text
*      <--P_LV_NOPO  text
*      <--P_LV_STATUS  text
*      <--P_LV_MESSAGE_ERROR  text
*----------------------------------------------------------------------*
FORM f_create_po_tiam  USING    p_po_web
                                p_json
                       CHANGING p_nopo
                                p_status
                                p_message_error
                                p_log_error.
  TYPES: BEGIN OF ty_error,
           no_urut(6),
           message(220),
         END OF ty_error.
  TYPES:
    BEGIN OF ts_po_schedule,
      po_item       TYPE c LENGTH 6,
      schedule_line TYPE c LENGTH 6,
      delivery_date TYPE c LENGTH 10,
      quantity      TYPE c LENGTH 15,
      pr_no         TYPE c LENGTH 10,
      item_pr       TYPE c LENGTH 6,
    END OF ts_po_schedule.
  TYPES:
    BEGIN OF po_items,
      po_item               TYPE c LENGTH 6,
      acct_assignment       TYPE c LENGTH 2,
      item_category         TYPE c LENGTH 10,
      short_text            TYPE c LENGTH 40,
      material              TYPE c LENGTH 18,
      po_quantity           TYPE c LENGTH 15,
      order_unit            TYPE c LENGTH 5,
      material_group        TYPE c LENGTH 18,
      plant                 TYPE c LENGTH 4,
      zpb1_gross_price      TYPE c LENGTH 20,
      price_unit            TYPE c LENGTH 10,
      currency              TYPE c LENGTH 5,
      sequence_a_assignment TYPE c LENGTH 2,
      acc_assign_qty        TYPE c LENGTH 10,
      gl_account            TYPE c LENGTH 10,
      unloading_point       TYPE c LENGTH 30,
      cost_center           TYPE c LENGTH 20,
      requirement_number    TYPE c LENGTH 10,
      discount              TYPE c LENGTH 20,
      curr_disc             TYPE c LENGTH 5,
      schedule              TYPE STANDARD TABLE OF ts_po_schedule WITH DEFAULT KEY,
    END OF po_items .
  TYPES:
    BEGIN OF  ts_create_po_tiam ,
      proses           TYPE c LENGTH 15,
      po_web           TYPE c LENGTH 10,
      po_date          TYPE c LENGTH 10,
      po_type          TYPE c LENGTH 5,
      kode_vendor      TYPE c LENGTH 10,
      purchasing_org   TYPE c LENGTH 4,
      purchasing_group TYPE c LENGTH 3,
      company_code     TYPE c LENGTH 4,
      currency         TYPE c LENGTH 10,
      username         TYPE c LENGTH 12,
      discount         TYPE c LENGTH 20,
      curr_disc        TYPE c LENGTH 5,
      status           TYPE c LENGTH 1,
      po_sap           TYPE c LENGTH 20,
      type             TYPE c LENGTH 1,
      message          TYPE c LENGTH 220,
      items            TYPE STANDARD TABLE OF po_items WITH DEFAULT KEY, "ts_po_header with DEFAULT KEY, "
    END OF ts_create_po_tiam .
  DATA: log_error  TYPE STANDARD TABLE OF ty_error WITH DEFAULT KEY.
  DATA: ls_error TYPE ty_error.
  DATA: ls_po_tiam TYPE ts_create_po_tiam.
  DATA: ls_items TYPE po_items.
  DATA: ls_schedule TYPE ts_po_schedule.
  DATA : lv_json_data  TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  DATA : zl_json_data TYPE REF TO zcl_trex_json_serializer.
  DATA: lv_ebeln TYPE ebeln.
  DATA: lv_log_error TYPE string.

  DATA: lt_poheader         LIKE bapimepoheader OCCURS 0 WITH HEADER LINE,
        lt_poheaderx        LIKE bapimepoheaderx OCCURS 0 WITH HEADER LINE,
        lt_poitem           LIKE bapimepoitem OCCURS 0 WITH HEADER LINE,
        lt_poitemx          LIKE bapimepoitemx OCCURS 0 WITH HEADER LINE,
        lt_poschedule       LIKE bapimeposchedule OCCURS 0 WITH HEADER LINE,
        lt_poschedulex      LIKE bapimeposchedulx OCCURS 0 WITH HEADER LINE,
        lt_return           LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
        lt_expheader        LIKE bapimepoheader OCCURS 0 WITH HEADER LINE,
        ld_exppurchaseorder LIKE bapimepoheader-po_number,
        lv_poitem           LIKE lt_poitem-po_item,
        lt_account          TYPE STANDARD TABLE OF bapimepoaccount,
        ls_account          LIKE LINE OF lt_account,
        lt_accountx         TYPE STANDARD TABLE OF bapimepoaccountx,
        ls_accountx         LIKE LINE OF lt_accountx,
        lt_account_profit   TYPE STANDARD TABLE OF bapimepoaccountprofitsegment,
        ls_account_profit   LIKE LINE OF lt_account_profit,
        lt_cond             TYPE STANDARD TABLE OF bapimepocond,
        ls_cond             LIKE LINE OF lt_cond,
        lt_condx            TYPE STANDARD TABLE OF bapimepocondx,
        ls_condx            LIKE LINE OF lt_condx,
        lv_testrun          LIKE bapiflag-bapiflag.
  DATA: lv_kalsk TYPE lfm1-kalsk.
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer.

  lv_json_data = p_json.

  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_po_tiam ).
  IF ls_po_tiam-po_web IS NOT INITIAL AND ls_po_tiam-proses = 'PO_TIAM'.
**    SELECT SINGLE ebeln INTO lv_ebeln FROM ekko WHERE verkf = ls_po_tiam-po_web AND bukrs = ls_po_tiam-company_code.
**    IF sy-subrc EQ 0.
**      p_nopo = lv_ebeln.
**      p_status = 'S'.
**      CONCATENATE 'PO Web' ls_po_tiam-po_web ' sudah terbentuk po sap no' lv_ebeln
**      INTO p_message_error SEPARATED BY space.
**      RETURN.
**    ENDIF.


    lt_poheader-doc_type  = ls_po_tiam-po_type. "'ZLOC'.
    lt_poheader-purch_org   = ls_po_tiam-purchasing_org.
    lt_poheader-doc_date    = ls_po_tiam-po_date. "sy-datum. "created_date.
    lt_poheader-vendor      = ls_po_tiam-kode_vendor.
    lt_poheader-currency    = ls_po_tiam-currency.
    lt_poheader-pur_group  = ls_po_tiam-purchasing_group.
    lt_poheader-created_by = ls_po_tiam-username.
    lt_poheader-comp_code = ls_po_tiam-company_code.
    lt_poheader-sales_pers = ls_po_tiam-po_web.
    lt_poheader-ref_1 = ls_po_tiam-po_web.

    lt_poheaderx-purch_org   = 'X'.
    lt_poheaderx-doc_date    = 'X'.
    lt_poheaderx-doc_type    = 'X'.
    lt_poheaderx-vendor      = 'X'.
    lt_poheaderx-currency    = 'X'.
    lt_poheaderx-pur_group  = 'X'.
    lt_poheaderx-created_by = 'X'.
    lt_poheaderx-comp_code = 'X'.
    lt_poheaderx-sales_pers = 'X'.
    lt_poheaderx-ref_1 = 'X'.

    CONDENSE: ls_po_tiam-curr_disc, ls_po_tiam-discount.
    CLEAR ls_cond.
    IF ls_po_tiam-curr_disc = '%'.
      ls_cond-currency = '%'.
    ELSE.
      ls_cond-currency = ls_po_tiam-curr_disc.
    ENDIF.
    ls_cond-itm_number = '00000'. " IMPORTANT → header level
    ls_cond-cond_type = 'ZR00'.
    IF ls_po_tiam-discount EQ space OR ls_po_tiam-discount = '0'.
    ELSE.
      ls_cond-cond_value = ls_po_tiam-discount.
      APPEND ls_cond TO lt_cond.
      CLEAR ls_condx.
      ls_condx-itm_number = '00000'.
      ls_condx-cond_type = 'ZR00'.
      ls_condx-cond_value = 'X'.
      ls_condx-currency = 'X'.
      APPEND ls_condx TO lt_condx.
    ENDIF.



    LOOP AT ls_po_tiam-items INTO ls_items.
      lt_poitem-po_item    = ls_items-po_item.
      IF ls_items-order_unit IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
          EXPORTING
            input          = ls_items-order_unit
          IMPORTING
            output         = lt_poitem-po_unit
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.
      ENDIF.
      "      lt_poitem-pricedate  = 1.
      lt_poitem-trackingno = ls_items-requirement_number.
      lt_poitem-short_text = ls_items-short_text.
      lt_poitem-material = ls_items-material.
      lt_poitem-quantity = ls_items-po_quantity.
      lt_poitem-matl_group = ls_items-material_group.
      lt_poitem-plant      = ls_items-plant.
      lt_poitem-acctasscat = ls_items-acct_assignment.
      lt_poitem-item_cat = ls_items-item_category.
      lt_poitem-po_price = '2'.
      lt_poitem-net_price = ls_items-zpb1_gross_price.

      lt_poitemx-po_item    = ls_items-po_item.
      lt_poitemx-trackingno = 'X'.
      lt_poitemx-short_text = 'X'.
      lt_poitemx-material = 'X'. "ls_items-material.
      lt_poitemx-quantity = 'X'. "ls_items-po_quantity.
      lt_poitemx-matl_group = 'X'. "ls_items-material_group.
      lt_poitemx-plant      = 'X'.
      lt_poitemx-acctasscat = 'X'.
      lt_poitemx-item_cat = 'X'.
      lt_poitemx-po_price = 'X'.
      lt_poitemx-net_price = 'X'.
      APPEND: lt_poitem, lt_poitemx.
      CLEAR: lt_poitem, lt_poitemx.


      ls_cond-itm_number      = ls_items-po_item. "l_ctr. "
      ls_cond-cond_st_no      = '020'. "ls_cond-itm_number+2. "'020'."l_ctr. "ls_detail-po_item+2.
      ls_cond-cond_type       = 'ZPB1'.
      ls_cond-cond_value      =  ls_items-zpb1_gross_price. "": "10000000",
      ls_cond-cond_unit      = lt_poitem-po_unit. "ls_items-order_unit. "": .
      ls_cond-cond_p_unt     = ls_items-price_unit. "'1'.
      ls_cond-currency       = ls_items-currency. "": "IDR",
      ls_cond-currency_iso   = ls_items-currency.
      ls_cond-change_id       = 'I'. " Insert
      APPEND ls_cond TO lt_cond.
      ls_condx-itm_number     = ls_cond-itm_number. "fu_out-po_item.
      ls_condx-cond_st_no     = ls_cond-cond_st_no. "fu_out-po_item+2.
      ls_condx-condition_nox  = 'X'.
      ls_condx-itm_numberx    = 'X'.
      ls_condx-cond_st_nox    = 'X'.
      ls_condx-cond_type      = 'X'.
      ls_condx-cond_value     = 'X'.
      ls_condx-cond_unit      = 'X'.
      ls_condx-cond_p_unt     = 'X'.
      ls_condx-currency       = 'X'.
      ls_condx-currency_iso   = 'X'.
      ls_condx-change_id      = 'X'.
      APPEND ls_condx TO lt_condx.
      CLEAR: ls_cond, ls_condx.

      IF ls_items-gl_account IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_items-gl_account
          IMPORTING
            output = ls_account-gl_account.
        ls_accountx-gl_account  = 'X'.
      ENDIF.
      ls_account-po_item      = ls_items-po_item. "l_ctr. "gv_po_item.
      ls_account-serial_no    = '1'. "gv_serial_no.
      ls_account-quantity     = ls_items-po_quantity.
      "    ls_account-gl_account   = ls_detail-gl_account.
      "      ls_account-orderid      = ls_items-order.
      ls_account-costcenter   = ls_items-cost_center.
      ls_account-unload_pt    = ls_items-unloading_point.
      APPEND ls_account TO lt_account.
      "  ls_account-gr_rcpt      = ls_detail-recipient.
      ls_accountx-po_item     = ls_account-po_item. "gv_po_item.
      ls_accountx-serial_no   = ls_account-serial_no. "gv_serial_no.
      ls_accountx-po_itemx    = 'X'.
      ls_accountx-serial_nox  = 'X'.

      ls_accountx-quantity    = 'X'.
      ls_accountx-orderid     = 'X'.
      ls_accountx-costcenter  = 'X'.
      ls_accountx-unload_pt   = 'X'.
      "  ls_accountx-gr_rcpt     = 'X'.
      APPEND ls_accountx TO lt_accountx.



      LOOP AT ls_items-schedule INTO ls_schedule.
        "Schedule PO
        lt_poschedule-po_item        = ls_schedule-po_item.
        lt_poschedule-sched_line     = ls_schedule-schedule_line.
        lt_poschedule-del_datcat_ext = 'D'.
        lt_poschedule-delivery_date  = ls_schedule-delivery_date.
        lt_poschedule-quantity       = ls_schedule-quantity.
        lt_poschedule-preq_no        = ls_schedule-pr_no.
        lt_poschedule-preq_item      = ls_schedule-item_pr.

        lt_poschedulex-po_item        = lt_poschedule-po_item.
        lt_poschedulex-sched_line     = lt_poschedule-sched_line.
        lt_poschedulex-del_datcat_ext = 'X'.
        lt_poschedulex-delivery_date  = 'X'.
        lt_poschedulex-quantity       = 'X'.
        lt_poschedulex-preq_no        = 'X'.
        lt_poschedulex-preq_item      = 'X'.
        APPEND: lt_poschedule, lt_poschedulex.
        CLEAR: lt_poschedule, lt_poschedulex.
      ENDLOOP.
    ENDLOOP.
    IF lt_poitem[] IS NOT INITIAL.
      CALL FUNCTION 'BAPI_PO_CREATE1'
        EXPORTING
          poheader          = lt_poheader
          poheaderx         = lt_poheaderx
          memory_uncomplete = ''
          memory_complete   = 'X'
        IMPORTING
          exppurchaseorder  = lv_ebeln
  "       expheader         = lt_expheader
        TABLES
          return            = lt_return
          poitem            = lt_poitem
          poitemx           = lt_poitemx
          poschedule        = lt_poschedule
          poschedulex       = lt_poschedulex
          pocond            = lt_cond
          pocondx           = lt_condx
          poaccount         = lt_account
          poaccountx        = lt_accountx.

      IF lv_ebeln IS NOT INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        p_nopo = lv_ebeln.
        p_status = 'S'.
        CONCATENATE 'PO Web' ls_po_tiam-po_web ' berhasil terbentuk po sap no' lv_ebeln
        INTO p_message_error SEPARATED BY space.
      ELSE.
        CLEAR:  p_nopo.
        p_status = 'E'.
        CONCATENATE 'PO Web' ls_po_tiam-po_web 'Gagal keproses '
        INTO p_message_error SEPARATED BY space.
        PERFORM f_return_message  TABLES lt_return
                       CHANGING p_message_error.

      ENDIF.
      DATA: lv_nou TYPE i.
      IF lt_return[] IS NOT INITIAL.
        CLEAR: lv_nou, log_error[].
        LOOP AT lt_return. " INTO ls_return..
          ADD 1 TO lv_nou.
          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = lt_return-id
              lang      = sy-langu
              no        = lt_return-number
              v1        = lt_return-message_v1
              v2        = lt_return-message_v2
              v3        = lt_return-message_v3
              v4        = lt_return-message_v4
            IMPORTING
              msg       = p_message_error
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          ls_error-no_urut = lv_nou.
          ls_error-message = p_message_error.
          APPEND ls_error TO log_error.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ELSE.
    p_status = 'E'.
    p_message_error = 'Tidak ada data yang diproses'.
  ENDIF.
  IF log_error[] IS NOT INITIAL.
    CREATE OBJECT cl_json_data
      EXPORTING
        data = log_error.
    cl_json_data->serialize( ).
    p_log_error = cl_json_data->get_data( ).

  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_RETURN_MESSAGE
*&---------------------------------------------------------------------*
FORM f_return_message  TABLES p_table
                       CHANGING p_message.
  DATA : lv_message(200),
         lt_return  LIKE bapiret2 OCCURS 0 WITH HEADER LINE.
  CLEAR: lv_message.
  lt_return[] = p_table[].

  READ TABLE lt_return WITH KEY type = 'E'.
  IF sy-subrc = 0.
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id        = lt_return-id
        lang      = sy-langu
        no        = lt_return-number
        v1        = lt_return-message_v1
        v2        = lt_return-message_v2
        v3        = lt_return-message_v3
        v4        = lt_return-message_v4
      IMPORTING
        msg       = lv_message
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
  ELSE.
  ENDIF.
  p_message = lv_message.
ENDFORM.                    " F_RETURN_MESSAGE
