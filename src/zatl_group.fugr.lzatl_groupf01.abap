*----------------------------------------------------------------------*
***INCLUDE LZATL_GROUPF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_PO_ATL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PI_DATA  text
*      -->P_PI_PO_ATL  text
*      <--P_PE_TYPE  text
*      <--P_PE_MESSAGE  text
*      <--P_PE_PO_NUMBER  text
*----------------------------------------------------------------------*
FORM f_create_po_atl  USING    p_data
                               p_po_atl
                      CHANGING p_type
                               p_message
                               p_po_number
                               p_po_date.
  TYPES:
    BEGIN OF ts_po_detail,
      po_item               TYPE c LENGTH 6,
      acct_assignment       TYPE c LENGTH 1,
      item_category         TYPE c LENGTH 10,
      short_text            TYPE c LENGTH 40,
      po_quantity           TYPE c LENGTH 15,
      order_unit            TYPE c LENGTH 5,
      delivery_date         TYPE c LENGTH 10,
      material_group        TYPE c LENGTH 18,
      plant                 TYPE c LENGTH 4,
      zpb1_gross_price      TYPE c LENGTH 20,
      price_unit            TYPE c LENGTH 10,
      currency              TYPE c LENGTH 5,
      agency_fee            TYPE c LENGTH 2,
      sequence_a_assignment TYPE c LENGTH 1,
      acc_assign_qty        TYPE c LENGTH 1,
      gl_account            TYPE c LENGTH 10,
      unloading_point       TYPE c LENGTH 30,
      order                 TYPE c LENGTH 20,
      cost_center           TYPE c LENGTH 20,
      "bukrs                 TYPE c LENGTH 4,
      werks                 TYPE c LENGTH 4,
      "gsber                 TYPE c LENGTH 4,
      "kokrs                 TYPE c LENGTH 10,
      prctr                 TYPE c LENGTH 20,
      wwsec                 TYPE c LENGTH 10,
    END OF ts_po_detail .

  TYPES: BEGIN OF ts_po,
           po_atl           TYPE string, "po_atl":"ATL1758684622",
           po_type          TYPE string, "po_type":"ZLOC",
           po_date          TYPE string, "po_date":"14102025",
           vendor           TYPE string, "vendor":"NSB8100",
           purchasing_org   TYPE string, "purchasing_org":"BCL",
           purchasing_group TYPE string, "purchasing_group":"ADV",
           company_code     TYPE string, "company_code":"8180",
           detail           TYPE TABLE OF ts_po_detail WITH DEFAULT KEY,
         END OF ts_po.

  DATA : ls_po TYPE ts_po.
  DATA : lv_json_data  TYPE string.
  DATA: ls_detail TYPE ts_po_detail.
  DATA : po_header         TYPE bapimepoheader,
         po_headerx        TYPE bapimepoheaderx,
         return            TYPE STANDARD TABLE OF bapiret2,
         po_item           TYPE STANDARD TABLE OF bapimepoitem,
         ls_item           LIKE LINE OF po_item,
         po_itemx          TYPE STANDARD TABLE OF bapimepoitemx,
         ls_itemx          LIKE LINE OF po_itemx,
         po_schedule       TYPE STANDARD TABLE OF bapimeposchedule,
         ls_schedule       LIKE LINE OF po_schedule,
         po_schedulex      TYPE STANDARD TABLE OF bapimeposchedulx,
         ls_schedulex      LIKE LINE OF po_schedulex,
         po_account        TYPE STANDARD TABLE OF bapimepoaccount,
         ls_account        LIKE LINE OF po_account,
         po_accountx       TYPE STANDARD TABLE OF bapimepoaccountx,
         ls_accountx       LIKE LINE OF po_accountx,
         po_account_profit TYPE STANDARD TABLE OF bapimepoaccountprofitsegment,
         ls_account_profit LIKE LINE OF po_account_profit,
         po_cond           TYPE STANDARD TABLE OF bapimepocond,
         ls_cond           LIKE LINE OF po_cond,
         po_condx          TYPE STANDARD TABLE OF bapimepocondx,
         ls_condx          LIKE LINE OF po_condx.
  DATA: l_pincr LIKE t161-pincr.
  DATA: l_ctr TYPE i.
  DATA: l_num TYPE i.
  DATA: po_num LIKE bapimepoheader-po_number.
  DATA: lv_success TYPE abap_bool VALUE abap_true.
  DATA: po_return                    TYPE TABLE OF bapiret2.


  lv_json_data = p_data.

  zcl_json=>deserialize(
      EXPORTING
        json             = lv_json_data
      CHANGING
        data             = ls_po ).

  SELECT SINGLE ebeln INTO po_num FROM ekko
    WHERE verkf = ls_po-po_atl
      AND bsart = ls_po-po_type
      AND bstyp = 'F'
      AND bukrs = ls_po-company_code
      AND loekz EQ space.
  IF sy-subrc EQ 0.
    p_po_number = po_num.
    CONCATENATE 'PO ATL : ' ls_po-po_atl ' sudah ada PO SAP No ' po_num
    INTO p_message SEPARATED BY space.
    p_type = 'S'.
    RETURN.
  ELSE.
    SELECT SINGLE ebeln INTO po_num FROM ekpo
      WHERE bednr = ls_po-po_atl
        AND loekz EQ space.
    IF sy-subrc EQ 0.
      p_po_number = po_num.
      CONCATENATE 'PO ATL : ' ls_po-po_atl ' sudah ada PO SAP No ' po_num
      INTO p_message SEPARATED BY space.
      p_type = 'S'.
      RETURN.
    ENDIF.
  ENDIF.

  po_header-doc_type    = ls_po-po_type.
  po_header-doc_date    = ls_po-po_date.
  po_header-vendor      = ls_po-vendor.
  po_header-purch_org   = ls_po-purchasing_org.
  po_header-pur_group   = ls_po-purchasing_group.
  po_header-comp_code   = ls_po-company_code.
  "  po_header-currency    = ls_po-currency. "
  po_header-sales_pers      = ls_po-po_atl. " (VERKF)

  po_headerx-doc_date   = 'X'.
  po_headerx-vendor     = 'X'.
  po_headerx-purch_org  = 'X'.
  po_headerx-pur_group  = 'X'.
  po_headerx-comp_code  = 'X'.
  po_headerx-currency   = 'X'.
  po_headerx-sales_pers = 'X'. " (VERKF)

  CLEAR: l_ctr, l_pincr.  po_headerx-doc_type   = 'X'.
  SELECT SINGLE pincr INTO l_pincr FROM t161 WHERE bstyp = 'F' AND bsart = po_header-doc_type.
  IF sy-subrc EQ 0.
    ADD l_pincr TO l_ctr.
  ELSE.
    l_pincr =  l_ctr = 1.
  ENDIF.

  LOOP AT ls_po-detail INTO ls_detail.
    po_header-currency    = ls_detail-currency. "
    ls_item-po_item     = ls_detail-po_item. "l_ctr. "
    ls_item-acctasscat  = ls_detail-acct_assignment.
    ls_item-item_cat    = ls_detail-item_category.
    ls_item-short_text  = ls_detail-short_text.
    ls_item-quantity    = ls_detail-po_quantity.
    ls_item-po_unit     = ls_detail-order_unit.
    ls_item-orderpr_un  = ls_detail-order_unit.
    ls_item-net_price   = ls_detail-zpb1_gross_price.
    ls_item-price_unit  = ls_detail-price_unit.
    ls_item-po_price    = ' '. " 1 = Gross; 2 = Net
    ls_item-matl_group  = ls_detail-material_group.
    ls_item-plant       = ls_detail-plant.
    ls_item-trackingno  = ls_po-po_atl.

    ls_itemx-po_item    = ls_item-po_item.
    ls_itemx-po_itemx   = 'X'.
    ls_itemx-acctasscat = 'X'.
    ls_itemx-item_cat   = 'X'.
    ls_itemx-short_text = 'X'.
    ls_itemx-quantity   = 'X'.
    ls_itemx-po_unit    = 'X'.
    ls_itemx-orderpr_un = 'X'.
    ls_itemx-matl_group = 'X'.
    ls_itemx-plant      = 'X'.
    ls_itemx-net_price  = 'X'.
    ls_itemx-price_unit = 'X'.
    ls_itemx-po_price   = 'X'.
    ls_itemx-trackingno = 'X'.

    ls_schedule-po_item         = ls_detail-po_item. "l_ctr. "
    ls_schedule-sched_line      = '0001'. "ls_schedule-po_item+1. "l_ctr. "ls_detail-po_item+1.
    ls_schedule-delivery_date   = ls_detail-delivery_date.
    ls_schedule-quantity        = ls_detail-po_quantity.

    ls_schedulex-po_item        = ls_schedule-po_item.
    ls_schedulex-sched_line     = ls_schedule-sched_line.
    ls_schedulex-po_itemx       = 'X'.
    ls_schedulex-sched_linex    = 'X'.
    ls_schedulex-delivery_date  = 'X'.
    ls_schedulex-quantity       = 'X'.

    IF ls_detail-agency_fee IS NOT INITIAL.
      "      ls_cond-condition_no    = l_ctr. "ls_detail-po_item.
      ls_cond-itm_number      = ls_detail-po_item. "l_ctr. "
      ls_cond-cond_st_no      = ls_cond-itm_number+2. "l_ctr.. "'030'. "l_ctr. "ls_detail-po_item.
      ls_cond-cond_type       = 'ZAGF'.
      ls_cond-cond_value      = ls_detail-agency_fee.
      ls_cond-currency        = '%'.
      ls_cond-cond_unit  = '%'. "wa_detail-satuan.
**      ls_cond-stat_con  = 'X'.
      ls_cond-calctypcon = 'A'.
      ls_cond-change_id = 'I'.
      APPEND ls_cond TO po_cond.


      "      ls_condx-condition_no   = ls_cond-condition_no. "fu_out-po_item.
      ls_condx-itm_number     = ls_cond-itm_number. "fu_out-po_item.
      ls_condx-cond_st_no     = ls_cond-cond_st_no. "fu_out-po_item.

      ls_condx-condition_nox  = 'X'.
      ls_condx-itm_numberx    = 'X'.
      ls_condx-cond_st_nox    = 'X'.
      ls_condx-cond_type      = 'X'.
      ls_condx-cond_value     = 'X'.
      ls_condx-cond_unit      = 'X'. "wa_detail-satuan.
      ls_condx-calctypcon     = 'X'.
      ls_condx-change_id      = 'X'.
      ls_condx-currency       = 'X'.
      APPEND ls_condx TO po_condx.
      CLEAR: ls_cond, ls_condx.
    ENDIF.

    IF ls_detail-zpb1_gross_price IS NOT INITIAL.
      ls_cond-itm_number      = ls_detail-po_item. "l_ctr. "
      ls_cond-cond_st_no      = ls_cond-itm_number+2. "'020'."l_ctr. "ls_detail-po_item+2.
      ls_cond-cond_type       = 'ZPB1'.
      ls_cond-cond_value      = ls_detail-zpb1_gross_price.
      ls_cond-cond_unit       = ls_detail-order_unit.
      ls_cond-cond_p_unt      = ls_detail-price_unit.
      ls_cond-currency        = ls_detail-currency.
      ls_cond-currency_iso    = ls_detail-currency.
**      ls_cond-stat_con        = 'X'.
**      ls_cond-calctypcon      = 'B'.
      ls_cond-change_id       = 'I'. " Insert
      "ls_cond-change_id = 'U'.
      APPEND ls_cond TO po_cond.

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
      APPEND ls_condx TO po_condx.
      CLEAR: ls_cond, ls_condx.
    ENDIF.
**
**Account
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_detail-gl_account
      IMPORTING
        output = ls_account-gl_account.
    ls_account-po_item      = ls_detail-po_item. "l_ctr. "gv_po_item.
    ls_account-serial_no    = '1'. "gv_serial_no.
    ls_account-quantity     = ls_detail-po_quantity.
    "    ls_account-gl_account   = ls_detail-gl_account.
    ls_account-orderid      = ls_detail-order.
    ls_account-costcenter   = ls_detail-cost_center.
    ls_account-unload_pt    = ls_detail-unloading_point.
    APPEND ls_account TO po_account.
    "  ls_account-gr_rcpt      = ls_detail-recipient.
    ls_accountx-po_item     = ls_account-po_item. "gv_po_item.
    ls_accountx-serial_no   = ls_account-serial_no. "gv_serial_no.
    ls_accountx-po_itemx    = 'X'.
    ls_accountx-serial_nox  = 'X'.

    ls_accountx-quantity    = 'X'.
    ls_accountx-gl_account  = 'X'.
    ls_accountx-orderid     = 'X'.
    ls_accountx-costcenter  = 'X'.
    ls_accountx-unload_pt   = 'X'.
    "  ls_accountx-gr_rcpt     = 'X'.
    APPEND ls_accountx TO po_accountx.

**Profit
    CLEAR: l_num .
    l_num = 1.
    "    IF ls_detail-bukrs IS NOT INITIAL.
    "    ADD 1 TO l_num.
    ls_account_profit-po_item   = ls_detail-po_item. "l_ctr. "gv_po_item.
    ls_account_profit-serial_no = '1'. "l_num.
    ls_account_profit-fieldname = 'BUKRS'.
    ls_account_profit-value     = ls_po-company_code. "ls_detail-bukrs.
    APPEND ls_account_profit TO po_account_profit.
    "    ENDIF.
    IF ls_detail-werks IS NOT INITIAL..
      "     ADD 1 TO l_num.
      ls_account_profit-po_item   = ls_detail-po_item. "l_ctr. "gv_po_item.
      ls_account_profit-serial_no = '1'. "l_num.
      ls_account_profit-fieldname = 'WERKS'.
      ls_account_profit-value     = ls_detail-werks.
      APPEND ls_account_profit TO po_account_profit.
      ADD 1 TO l_num.
      ls_account_profit-po_item   = ls_detail-po_item. "l_ctr. "gv_po_item.
      ls_account_profit-serial_no = '1'. "l_num.
      ls_account_profit-fieldname = 'GSBER'.
      ls_account_profit-value     = ls_detail-werks. "ls_detail-gsber.
      APPEND ls_account_profit TO po_account_profit.
    ENDIF.
    IF ls_detail-prctr IS NOT INITIAL..
      "      ADD 1 TO l_num.
      ls_account_profit-po_item   = ls_detail-po_item. "l_ctr. "gv_po_item.
      ls_account_profit-serial_no = '1'. "l_num.
      ls_account_profit-fieldname = 'PRCTR'.
      ls_account_profit-value     = ls_detail-prctr.
      APPEND ls_account_profit TO po_account_profit.
    ENDIF.
    ls_account_profit-po_item   = ls_detail-po_item. "l_ctr. "gv_po_item.
    ls_account_profit-serial_no = '1'. "l_num.
    ls_account_profit-fieldname = 'KOKRS'.
    ls_account_profit-value     = '8010'. "ls_detail-kokrs.
    APPEND ls_account_profit TO po_account_profit.
    "    ENDIF.
    IF ls_detail-wwsec IS NOT INITIAL..
      "     ADD 1 TO l_num.
      ls_account_profit-po_item   = ls_detail-po_item. "l_ctr. "gv_po_item.
      ls_account_profit-serial_no = '1'. "l_num.
      ls_account_profit-fieldname = 'WWSEC'.
      ls_account_profit-value     = ls_detail-wwsec.
      APPEND ls_account_profit TO po_account_profit.
    ENDIF.

    APPEND ls_item TO po_item.
    APPEND ls_schedule TO po_schedule.
    APPEND ls_itemx TO po_itemx.
    APPEND ls_schedulex TO po_schedulex.
    ADD l_pincr TO l_ctr.
    CLEAR: ls_cond, ls_condx, ls_item, ls_itemx, ls_schedule, ls_schedulex, ls_account, ls_accountx..
  ENDLOOP.
  IF po_item[] IS NOT INITIAL.
    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader               = po_header
        poheaderx              = po_headerx
        no_price_from_po       = 'X'   "NO_PRICE_FROM_PO
      IMPORTING
        exppurchaseorder       = po_num
      TABLES
        return                 = po_return
        poitem                 = po_item
        poitemx                = po_itemx
        poschedule             = po_schedule
        poschedulex            = po_schedulex
        pocond                 = po_cond
        pocondx                = po_condx
        poaccount              = po_account
        poaccountx             = po_accountx
        poaccountprofitsegment = po_account_profit.

    IF sy-subrc EQ 0.
      LOOP AT po_return INTO DATA(wa_return).
        WRITE: / wa_return-type, wa_return-message.
        IF wa_return-type = 'E' OR wa_return-type = 'A'.
          lv_success = abap_false.
          p_message =  wa_return-message.
        ELSE.
        ENDIF.
      ENDLOOP.
      IF lv_success = abap_true.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        p_po_number = po_num.
        p_type = 'S'.
        p_po_date = po_header-creat_date.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        p_type = 'E'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_GR_ATL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PI_DATA  text
*      -->P_PI_PO_ATL  text
*      <--P_PE_TYPE  text
*      <--P_PE_MESSAGE  text
*      <--P_PE_PO_NUMBER  text
*----------------------------------------------------------------------*
FORM f_proses_gr_atl  USING    p_data
                               p_po_atl
                      CHANGING p_type
                               p_message
                               p_gr_number
                               p_gr_year.

  TYPES:
    BEGIN OF ts_gr_detail,
      po_item     TYPE c LENGTH 6,
      "      move_type     TYPE c LENGTH 3,
      plant       TYPE c LENGTH 4,
      gr_quantity TYPE c LENGTH 10,
      order_unit  TYPE c LENGTH 3,
      item_text   TYPE string,
      "      mvt_ind       TYPE c LENGTH 1,
    END OF ts_gr_detail .
  TYPES:
    BEGIN OF ts_gr,
      po_number       TYPE c LENGTH 10,
      posting_date    TYPE c LENGTH 10,
      doc_date        TYPE c LENGTH 10,
      sap_matdoc      TYPE c LENGTH 10,
      delivery_note   TYPE c LENGTH 10,
      unloading_point TYPE c LENGTH 30,
      matdoc_date     TYPE c LENGTH 10,
      type            TYPE c LENGTH 1,
      message         TYPE c LENGTH 220,
      detail          TYPE TABLE OF ts_gr_detail WITH DEFAULT KEY,
    END OF ts_gr.


  DATA : ls_gr TYPE ts_gr.
  DATA : lv_json_data  TYPE string.
  DATA: ls_detail TYPE ts_gr_detail.

  DATA : goodsmvt_header  TYPE bapi2017_gm_head_01,
         goodsmvt_code    TYPE bapi2017_gm_code,
         goodsmvt_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
         materialdocument TYPE bapi2017_gm_head_ret-mat_doc,
         matdocumentyear  TYPE bapi2017_gm_head_ret-doc_year,
         return           TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE,
         gs_item          LIKE LINE OF goodsmvt_item.

  DATA : lv_subrc  TYPE sy-subrc,
         gt_return TYPE STANDARD TABLE OF bapiret2.

  lv_json_data = p_data.
  zcl_json=>deserialize(
      EXPORTING
        json             = lv_json_data
      CHANGING
        data             = ls_gr ).

**  p_message = 'Test Post GR ATL'.
**  p_po_number = 'MATdoctest'.

  SELECT SINGLE mblnr mjahr INTO  (p_gr_number, p_gr_year) FROM mkpf WHERE xblnr = ls_gr-delivery_note.
  IF sy-subrc EQ 0.
    SELECT SINGLE mblnr INTO p_gr_number FROM mseg WHERE smbln = p_gr_number AND bwart = '102'.
    IF sy-subrc EQ 0.
      CLEAR: p_gr_number, p_gr_year.
    ELSE.
      p_type = 'S'.
      RETURN.
    ENDIF.
  ENDIF.
  goodsmvt_code                     = '01'.
  goodsmvt_header-pstng_date        = ls_gr-posting_date.
  goodsmvt_header-doc_date          = ls_gr-doc_date.
  goodsmvt_header-ver_gr_gi_slip    = '3'.
  goodsmvt_header-ver_gr_gi_slipx   = 'X'.
  goodsmvt_header-ref_doc_no        = ls_gr-delivery_note.
  goodsmvt_header-header_txt        = ls_gr-unloading_point.
  LOOP AT ls_gr-detail INTO ls_detail.
    gs_item-po_number         = ls_gr-po_number.
    gs_item-po_item           = ls_detail-po_item.
    gs_item-move_type         = '101'.
    gs_item-plant             = ls_detail-plant.
    gs_item-entry_qnt         = ls_detail-gr_quantity.
    gs_item-entry_uom         = ls_detail-order_unit.
    gs_item-mvt_ind           = 'B'.
    gs_item-item_text         = 'json-item_text'.
    APPEND gs_item TO goodsmvt_item.
    CLEAR gs_item.
  ENDLOOP.
  IF goodsmvt_item[] IS NOT INITIAL.
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = goodsmvt_header
        goodsmvt_code    = goodsmvt_code
      IMPORTING
        materialdocument = materialdocument
        matdocumentyear  = matdocumentyear
      TABLES
        goodsmvt_item    = goodsmvt_item
        return           = return.
    CLEAR: lv_subrc.
    LOOP AT return.
      IF return-type = 'E'.
        lv_subrc  = 4.
      ENDIF.
      p_message = return-message.
      CLEAR return.
    ENDLOOP.

    IF materialdocument IS NOT INITIAL.
      p_gr_number    = materialdocument.
      p_gr_year = matdocumentyear.
      p_type = 'S'.
      "        fc_mjahr    = matdocumentyear.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      p_type = 'E'.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_MIRO_ATL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PI_DATA  text
*      -->P_PI_PO_ATL  text
*      <--P_PE_TYPE  text
*      <--P_PE_MESSAGE  text
*      <--P_PE_MIRO_NUMBER  text
*      <--P_PE_MIRO_DATE  text
*----------------------------------------------------------------------*
FORM f_proses_miro_atl  USING    p_data
                               p_po_atl
                      CHANGING p_type
                               p_message
                               p_miro_number
                               p_miro_year.


  TYPES:
    BEGIN OF ts_miro_gl_data,
      invoice_doc_item  TYPE c LENGTH 6,
      amount            TYPE c LENGTH 20,
      assignment_number TYPE c LENGTH 20,
      item_text         TYPE c LENGTH 40,
      gl_account        TYPE c LENGTH 15,
      db_cr_ind         TYPE c LENGTH 1,
    END OF ts_miro_gl_data ,

    BEGIN OF ts_miro_detail,
      po_number        TYPE c LENGTH 10,
      po_item          TYPE c LENGTH 6,
      invoice_doc_item TYPE c LENGTH 6,
      ref_doc          TYPE c LENGTH 20,
      ref_doc_year     TYPE c LENGTH 5,
      ref_doc_it       TYPE c LENGTH 6,
      tax_code         TYPE c LENGTH 5,
      miro_quantity    TYPE c LENGTH 10,
      order_unit       TYPE c LENGTH 3,
      item_amount      TYPE c LENGTH 20,
    END OF ts_miro_detail .
  TYPES:
    BEGIN OF ts_miro,
      invoice_date   TYPE c LENGTH 10,
      posting_date   TYPE c LENGTH 10,
      ref_doc_no     TYPE c LENGTH 20,
      company_code   TYPE c LENGTH 4,
      currency       TYPE c LENGTH 5,
      gross_amount   TYPE c LENGTH 20,
      invoice_ind    TYPE c LENGTH 1,
      text           TYPE c LENGTH 40,
      payment_term   TYPE c LENGTH 10,
      baseline_date  TYPE c LENGTH 10,
      due_on         TYPE c LENGTH 10,
      assignment     TYPE c LENGTH 20,
      header_text    TYPE c LENGTH 40,
      exchange_rate  TYPE c LENGTH 20,
      inv_party      TYPE c LENGTH 10,
      gl_account     TYPE c LENGTH 10,
      bussiness_area TYPE c LENGTH 4,
      tax_code       TYPE c LENGTH 3,
      sap_miro_no    TYPE c LENGTH 10,
      sap_miro_year  TYPE c LENGTH 4,
      type           TYPE c LENGTH 1,
      message        TYPE c LENGTH 220,
      detail         TYPE TABLE OF ts_miro_detail WITH DEFAULT KEY,
      gl_data        TYPE TABLE OF ts_miro_gl_data WITH DEFAULT KEY,
    END OF ts_miro.


  DATA : ls_miro TYPE ts_miro.
  DATA : lv_json_data  TYPE string.
  DATA: ls_detail TYPE ts_miro_detail.
  DATA: ls_gl_data TYPE ts_miro_gl_data.
  DATA: lv_xblnr TYPE rbkp-xblnr.


  DATA: itemdata      TYPE STANDARD TABLE OF bapi_incinv_create_item,
        taxdata       TYPE STANDARD TABLE OF bapi_incinv_create_tax,
        withtaxdata   TYPE STANDARD TABLE OF bapi_incinv_create_withtax,
        glaccountdata TYPE STANDARD TABLE OF bapi_incinv_create_gl_account,
        headerdata    TYPE bapi_incinv_create_header.

  DATA : return           TYPE STANDARD TABLE OF bapiret2,
         ls_bapiret2      TYPE bapiret2,
         invoicedocnumber TYPE bapi_incinv_fld-inv_doc_no,
         fiscalyear       TYPE bapi_incinv_fld-fisc_year.
  DATA : ls_itemdata      TYPE bapi_incinv_create_item,
         ls_taxdata       TYPE bapi_incinv_create_tax,
         ls_withtaxdata   TYPE bapi_incinv_create_withtax,
         ls_glaccountdata LIKE LINE OF glaccountdata,
         lt_services      TYPE TABLE OF bapiesll,
         ls_return        LIKE LINE OF return,
         ls_services      LIKE LINE OF lt_services.
  DATA: ls_zatldt001 TYPE zatldt001.
  CLEAR : invoicedocnumber, fiscalyear.
  lv_json_data = p_data.
  zcl_json=>deserialize(
      EXPORTING
        json             = lv_json_data
      CHANGING
        data             = ls_miro ).
  lv_xblnr = ls_miro-ref_doc_no.
  ls_zatldt001-xblnr = ls_miro-ref_doc_no.
  ls_zatldt001-zuonr = ls_miro-assignment.
  ls_zatldt001-lifnr = ls_miro-inv_party.
  ls_zatldt001-bukrs = ls_miro-company_code.
  ls_zatldt001-gsber = ls_miro-bussiness_area.

  SELECT SINGLE belnr gjahr INTO (invoicedocnumber, fiscalyear) FROM rbkp WHERE xblnr = lv_xblnr.
  IF sy-subrc EQ 0.
    p_miro_number = invoicedocnumber.
    p_miro_year = fiscalyear.
    p_type = 'S'.
    SELECT SINGLE * INTO ls_zatldt001 FROM zatldt001 WHERE belnr = invoicedocnumber AND gjahr = fiscalyear.
    IF sy-subrc NE 0.
      ls_zatldt001-belnr = invoicedocnumber..
      ls_zatldt001-gjahr = fiscalyear.
      ls_zatldt001-erdat = sy-datum.
      ls_zatldt001-erzet = sy-uzeit.
      ls_zatldt001-ernam = sy-uname.
      MODIFY zatldt001 FROM ls_zatldt001.
      COMMIT WORK.
    ENDIF.
    RETURN.
  ENDIF.
  ls_zatldt001-xblnr = ls_miro-ref_doc_no.
  ls_zatldt001-zuonr = ls_miro-assignment.
  ls_zatldt001-bukrs = ls_miro-company_code.
  ls_zatldt001-gsber = ls_miro-bussiness_area.

  headerdata-invoice_ind     = 'X'.
  headerdata-doc_type        = 'RE'.
  headerdata-doc_date        = ls_miro-invoice_date.
  headerdata-pstng_date      = ls_miro-posting_date.
  headerdata-ref_doc_no      = ls_miro-ref_doc_no.
  headerdata-comp_code       = ls_miro-company_code.
  headerdata-currency        = ls_miro-currency.
  headerdata-gross_amount    = ls_miro-gross_amount. " : "192887760",                      --
  headerdata-calc_tax_ind    = space.
  headerdata-exch_rate       = ls_miro-exchange_rate.
  headerdata-bline_date      = ls_miro-baseline_date.
  headerdata-header_txt      = ls_miro-header_text.
  headerdata-pmnttrms        = ls_miro-payment_term.
  headerdata-item_text       = ls_miro-text.
  headerdata-alloc_nmbr      = ls_miro-assignment.
  headerdata-bus_area        = ls_miro-bussiness_area.
  headerdata-diff_inv        = ls_miro-inv_party.

  LOOP AT ls_miro-detail INTO ls_detail.
    ls_itemdata-po_number        = ls_detail-po_number. "'ls_dt03-ebeln'.
    ls_itemdata-po_item          = ls_detail-po_item. "'ls_dt03-ebelp'.
    ls_itemdata-invoice_doc_item = ls_detail-invoice_doc_item. "'lv_rblgp'.
    ls_itemdata-ref_doc          = ls_detail-ref_doc. "'5001475042'.
    ls_itemdata-ref_doc_year     = ls_detail-ref_doc_year. "'2025'.
    ls_itemdata-ref_doc_it       = ls_detail-ref_doc_it. "'0001'.
    ls_itemdata-tax_code         = ls_detail-tax_code. "'ls_t001-vstki'.
    ls_itemdata-quantity         = ls_detail-miro_quantity. "'ls_dt03-menge'.
    ls_itemdata-po_unit          = ls_detail-order_unit. "'ls_dt03-meins'.
    CONDENSE ls_detail-item_amount.
    ls_itemdata-item_amount      = ls_detail-item_amount.
    APPEND ls_itemdata TO itemdata.
    CLEAR : ls_itemdata.
  ENDLOOP.
  LOOP AT ls_miro-gl_data INTO ls_gl_data.
    ls_glaccountdata-invoice_doc_item = ls_gl_data-invoice_doc_item. " : "00010",                                --
    CONDENSE ls_gl_data-amount.
    ls_glaccountdata-item_amount = ls_gl_data-amount. " : "19125040",
    ls_glaccountdata-comp_code   = ls_miro-company_code.
    ls_glaccountdata-alloc_nmbr = ls_gl_data-assignment_number. " : "04010201301301",      --
    ls_glaccountdata-item_text = ls_gl_data-item_text. " : "PPN  Test input SysAd",                   --
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_gl_data-gl_account
      IMPORTING
        output = ls_glaccountdata-gl_account.
    ls_glaccountdata-db_cr_ind = ls_gl_data-db_cr_ind. " : "S"                                                         --
    APPEND ls_glaccountdata TO glaccountdata.
    CLEAR: ls_glaccountdata, ls_gl_data.
  ENDLOOP.

  IF itemdata[] IS NOT INITIAL.
    CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
      EXPORTING
        headerdata       = headerdata
      IMPORTING
        invoicedocnumber = invoicedocnumber
        fiscalyear       = fiscalyear
      TABLES
        itemdata         = itemdata
        glaccountdata    = glaccountdata
        return           = return.
    IF invoicedocnumber IS NOT INITIAL.
      ls_zatldt001-belnr = invoicedocnumber.
      ls_zatldt001-gjahr = fiscalyear.
      ls_zatldt001-erdat = sy-datum.
      ls_zatldt001-erzet = sy-uzeit.
      ls_zatldt001-ernam = sy-uname.
      MODIFY zatldt001 FROM ls_zatldt001.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
      p_miro_number = invoicedocnumber.
      p_miro_year = fiscalyear.
      p_type = 'S'.
    ELSE.
      LOOP AT return INTO ls_return..
        p_message = ls_return-message.
      ENDLOOP.
      p_type = 'E'.
      p_miro_number = ' '.
    ENDIF.
  ELSE.
    p_type = 'E'.
    p_miro_number = ' '.
    p_message = 'data not found'.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_CURRENCY_TO_EXTERNAL
*&---------------------------------------------------------------------*
FORM f_currency_to_external  USING    fu_currency fu_value
                             CHANGING fc_value.
  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
    EXPORTING
      currency        = fu_currency
      amount_internal = fu_value
    IMPORTING
      amount_external = fc_value.
ENDFORM.                    " F_CURRENCY_TO_EXTERNAL
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_INV_ATL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PI_DATA  text
*      -->P_PI_PO_ATL  text
*      <--P_PE_TYPE  text
*      <--P_PE_MESSAGE  text
*      <--P_PE_INV_NUMBER  text
*      <--P_PE_INV_YEAR  text
*----------------------------------------------------------------------*

FORM f_proses_inv_atl  USING    p_data
                                p_po_atl
                       CHANGING p_type
                                p_message
                                p_inv_number
                                p_inv_year .

  TYPES:
    BEGIN OF ts_inv_detail,
      posting_key    TYPE c LENGTH 2,
      account_id     TYPE c LENGTH 10,
      tax_code       TYPE c LENGTH 2,
      business_area  TYPE c LENGTH 4,
      assignment     TYPE c LENGTH 20,
      text           TYPE c LENGTH 50,
      amount         TYPE c LENGTH 20,
      currency       TYPE c LENGTH 5,
      profit_center  TYPE c LENGTH 20,
      internal_order TYPE c LENGTH 20,
      sec            TYPE c LENGTH 10,
    END OF ts_inv_detail.
  TYPES:
    BEGIN OF ts_inv,
      company_code    TYPE c LENGTH 4,
      year            TYPE c LENGTH 4,
      document_date   TYPE c LENGTH 10,
      posting_date    TYPE c LENGTH 10,
      reference       TYPE c LENGTH 40,
      doc_header_text TYPE c LENGTH 30,
      currency        TYPE c LENGTH 5,
      calculate_tax   TYPE c LENGTH 10,
      rate            TYPE c LENGTH 10,
      payment_term    TYPE c LENGTH 10,
      sap_inv_no      TYPE c LENGTH 10,
      sap_inv_year    TYPE c LENGTH 4,
      type            TYPE c LENGTH 1,
      message         TYPE c LENGTH 220,
      detail          TYPE TABLE OF ts_inv_detail WITH DEFAULT KEY,
    END OF ts_inv.


  DATA : ls_inv TYPE ts_inv.
  DATA : lv_json_data  TYPE string.
  DATA: ls_detail TYPE ts_inv_detail.
  DATA : obj_type   TYPE bapiache09-obj_type.

  DATA : documentheader    TYPE bapiache09,
         accountgl         TYPE STANDARD TABLE OF bapiacgl09 WITH HEADER LINE,
         accountreceivable TYPE STANDARD TABLE OF bapiacar09 WITH HEADER LINE, " OPTIONAL
         accountpayable    TYPE STANDARD TABLE OF bapiacap09 WITH HEADER LINE,
         currencyamount    TYPE STANDARD TABLE OF bapiaccr09 WITH HEADER LINE,
         criteria          TYPE STANDARD TABLE OF bapiackec9 WITH HEADER LINE,
         extension1        TYPE STANDARD TABLE OF bapiacextc WITH HEADER LINE,
         extension2        TYPE STANDARD TABLE OF bapiparex WITH HEADER LINE.
  DATA: gv_belnr TYPE belnr_d,
        gv_gjahr TYPE bkpf-gjahr.

  DATA : lv_subrc         TYPE sy-subrc.
  DATA: lv_amt_base  TYPE bapiaccr09-amt_base.

  DATA : return           TYPE STANDARD TABLE OF bapiret2,
         ls_bapiret2      TYPE bapiret2,
         invoicedocnumber TYPE bapi_incinv_fld-inv_doc_no,
         lv_buzei         TYPE mseg-buzei,
         fiscalyear       TYPE bapi_incinv_fld-fisc_year.
  DATA: lt_zfidt020 TYPE STANDARD TABLE OF zfidt020.
  DATA: ls_zfidt020 TYPE zfidt020.
  DATA: lv_vbund TYPE lfa1-vbund.
  DATA: lv_hkont_numc TYPE hkont.
  DATA: ls_bkpf TYPE bkpf.
  lv_json_data = p_data.
  zcl_json=>deserialize(
      EXPORTING
        json             = lv_json_data
      CHANGING
        data             = ls_inv ).

  CLEAR: ls_zfidt020.
  documentheader-bus_act     = 'RFBU'.
  documentheader-username    = sy-uname.
  ls_bkpf-bukrs = ls_zfidt020-bukrs = documentheader-comp_code   = ls_inv-company_code.
  documentheader-doc_date = ls_inv-document_date.
  ls_zfidt020-budat = documentheader-pstng_date = ls_inv-posting_date.
  ls_bkpf-gjahr = documentheader-fisc_year = ls_inv-year.
  documentheader-doc_type = 'KR'.
  ls_bkpf-xblnr = ls_zfidt020-zuonr = documentheader-ref_doc_no = ls_inv-reference.
  documentheader-header_txt = ls_inv-doc_header_text.

  SELECT SINGLE * INTO ls_bkpf FROM bkpf
    WHERE bukrs = ls_bkpf-bukrs
      AND gjahr = ls_bkpf-gjahr
      AND xblnr = ls_bkpf-xblnr
      AND stblg = space
      AND blart = 'KR'.
  IF sy-subrc EQ 0.
    SELECT SINGLE * INTO ls_zfidt020 FROM zfidt020
      WHERE zuonr = ls_zfidt020-zuonr.
    IF sy-subrc NE 0.
      ls_zfidt020-belnr = p_inv_number = ls_bkpf-belnr.
      ls_zfidt020-gjahr = p_inv_year = ls_bkpf-gjahr.
      ls_zfidt020-erdat = sy-datum.
      ls_zfidt020-erzet = sy-uzeit.
      ls_zfidt020-ernam = sy-uname.
      MODIFY zfidt020 FROM ls_zfidt020.
    ENDIF.
    p_inv_number = ls_bkpf-belnr.
    p_inv_year = ls_bkpf-gjahr.
    p_type = 'S'.
    RETURN.
  ENDIF.
  CLEAR: lv_vbund, lv_buzei.
  LOOP AT ls_inv-detail INTO ls_detail.
    ADD 1 TO lv_buzei.
    "    lv_amt_base = ls_detail-amount.
    IF ls_detail-posting_key = '40'.
      lv_amt_base = ls_detail-amount.
      "    elseif ls_detail-posting_key = '40'..
    ELSE.
      lv_amt_base = ls_detail-amount * -1.
    ENDIF.
    IF ls_detail-posting_key = '31'.
      accountpayable-itemno_acc = lv_buzei.
      ls_zfidt020-lifnr = accountpayable-vendor_no = ls_detail-account_id.
      ls_zfidt020-gsber = accountpayable-bus_area = ls_detail-business_area.
      accountpayable-tax_code = ls_detail-tax_code.
      accountpayable-alloc_nmbr = ls_detail-assignment.
      accountpayable-item_text = ls_detail-text.
      accountpayable-pmnttrms = ls_inv-payment_term.
      APPEND accountpayable.
      SELECT SINGLE vbund INTO lv_vbund FROM lfa1 WHERE lifnr = accountpayable-vendor_no.

      extension1-field1(3) = lv_buzei.
      extension1-field1+3(2) = ls_detail-posting_key.
      APPEND extension1.

      currencyamount-itemno_acc = lv_buzei.
      currencyamount-curr_type =  '00'.
      currencyamount-currency = ls_detail-currency.
      currencyamount-amt_doccur = lv_amt_base. "ls_detail-amount. "(nilainya dikalikan -1)
      currencyamount-exch_rate = ls_inv-rate.
      APPEND currencyamount.
    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_detail-account_id
        IMPORTING
          output = lv_hkont_numc.

      IF ls_detail-internal_order IS NOT INITIAL.
        accountgl-itemno_acc = lv_buzei.
        accountgl-gl_account = lv_hkont_numc. "ls_detail-account_id.
        accountgl-bus_area = ls_detail-business_area.
        accountgl-tax_code = ls_detail-tax_code.
        accountgl-alloc_nmbr = ls_detail-assignment.
        accountgl-item_text = ls_detail-text.
        accountgl-trade_id = lv_vbund.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_detail-profit_center
          IMPORTING
            output = accountgl-profit_ctr. "lv_hkont_numc.

        "        accountgl-profit_ctr = ls_detail-profit_center.
        accountgl-orderid = ls_detail-internal_order.
        APPEND accountgl.
        criteria-itemno_acc = lv_buzei..
        criteria-fieldname = 'WWSEC'.
        criteria-character = ls_detail-sec.
        APPEND criteria.
      ELSE.
        accountgl-itemno_acc = lv_buzei.
        accountgl-gl_account = lv_hkont_numc. "ls_detail-account_id.
        accountgl-bus_area = ls_detail-business_area.
        accountgl-tax_code = ls_detail-tax_code.
        accountgl-alloc_nmbr = ls_detail-assignment.
        accountgl-item_text = ls_detail-text.
        accountgl-trade_id = lv_vbund.
        APPEND accountgl.
      ENDIF.
      extension1-field1(3) = lv_buzei.
      extension1-field1+3(2) = ls_detail-posting_key.
      APPEND extension1.
      IF ls_detail-business_area = '0100' AND lv_hkont_numc = '0315100040'.
        extension2-structure = 'ACCIT'.
        extension2-valuepart1 = lv_buzei.
        extension2-valuepart2 = '310'.
        APPEND extension2.
      ENDIF.
      currencyamount-itemno_acc = lv_buzei.
      currencyamount-curr_type = '00'.
      currencyamount-currency = ls_detail-currency.
      currencyamount-amt_doccur = lv_amt_base. "ls_detail-amount." (nilainya dikalikan 1)
      currencyamount-exch_rate = ls_inv-rate.
      APPEND currencyamount.
    ENDIF.
    "    APPEND: accountpayable, accountgl, currencyamount, extension1, criteria.
  ENDLOOP.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
    EXPORTING
      documentheader = documentheader
    TABLES
      accountgl      = accountgl
      accountpayable = accountpayable
      currencyamount = currencyamount
      criteria       = criteria
      extension1     = extension1
      extension2     = extension2
      return         = return.
  READ TABLE return INTO ls_bapiret2 WITH KEY type = 'E'.
  IF sy-subrc NE 0.
    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader = documentheader
      IMPORTING
        obj_type       = obj_type
      TABLES
        accountgl      = accountgl
        accountpayable = accountpayable
        currencyamount = currencyamount
        criteria       = criteria
        extension1     = extension1
        extension2     = extension2
        return         = return.

    LOOP AT return INTO ls_bapiret2.
      IF ls_bapiret2-type = 'A' OR ls_bapiret2-type = 'E'.
        p_message = ls_bapiret2-message.
      ELSEIF ls_bapiret2-type = 'S'.
        gv_belnr    = ls_bapiret2-message_v2(10).
        gv_gjahr    = ls_bapiret2-message_v2+14(4).
      ENDIF.
    ENDLOOP.
    IF gv_belnr IS NOT INITIAL.
      ls_zfidt020-belnr = p_inv_number = gv_belnr.
      ls_zfidt020-gjahr = p_inv_year = gv_gjahr.
      ls_zfidt020-erdat = sy-datum.
      ls_zfidt020-erzet = sy-uzeit.
      ls_zfidt020-ernam = sy-uname.
      MODIFY zfidt020 FROM ls_zfidt020.
      p_type = 'S'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ELSE.
      p_type = 'E'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ENDIF.
  ELSE.
    p_type = 'E'.
    p_message = ls_bapiret2-message.
  ENDIF.
ENDFORM.
