*----------------------------------------------------------------------*
***INCLUDE LZSFA_GROUPF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_ORDER_SFA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_ORDER_SFA  text
*      -->P_LV_JSON  text
*      <--P_LV_QUOTATION  text
*      <--P_LV_STATUS  text
*      <--P_LV_MESSAGE_ERROR  text
*----------------------------------------------------------------------*
FORM f_create_order_sfa  USING    p_order_sfa
                                  p_json
                         CHANGING p_idoc
                                  p_quotation
                                  p_status
                                  p_message_error.

  TYPES: BEGIN OF ts_order_item,
           material      TYPE c LENGTH 10,
           quantity      TYPE c LENGTH 10,
           material_uom  TYPE c LENGTH 5,
           item_category TYPE c LENGTH 4,
           ket_detail    TYPE c LENGTH 50,
         END OF ts_order_item .
  TYPES: BEGIN OF ts_create_order_sfa ,
           sales_org_code       TYPE string, "c LENGTH 4,
           sales_office         TYPE string, "c LENGTH 4,
           sales_doc_type       TYPE string, "c LENGTH 4,
           customer_code        TYPE string, "c LENGTH 10,
           salesman_code        TYPE string, "c LENGTH 10,
           customer_nomor_po    TYPE string, "c LENGTH 35,
           customer_tgl_po      TYPE string, "c LENGTH 10,
           payment_type         TYPE string, "c LENGTH 1,
           tgl_jatuh_tempo      TYPE string, "c LENGTH 10,
           nomor_order_sfa      TYPE string, "c LENGTH 10,
           collector_route_list TYPE string, "c LENGTH 10,
           delivery_route_list  TYPE string, "c LENGTH 10,
           order_reason         TYPE string, "c LENGTH 4,
           nomor_call_id        TYPE string, "c LENGTH 10,
           keterangan           TYPE string, "c LENGTH 50,
           inco2                TYPE string, "c LENGTH 40,
           cashback_amt         TYPE string,
           nomor_quotation      TYPE string, "c LENGTH 10,
           status               TYPE string, "c LENGTH 1,
           error_message        TYPE string, "c LENGTH 200,
           sales_order_details  TYPE STANDARD TABLE OF ts_order_item WITH DEFAULT KEY,
         END OF ts_create_order_sfa .
  DATA: lv_count TYPE i.
  DATA: lv_count1 TYPE i.
  DATA: ls_order TYPE ts_create_order_sfa.
  DATA: ls_order_item TYPE ts_order_item.
  DATA: lv_vbeln TYPE vbak-vbeln.
  DATA : lv_json_data  TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  DATA : zl_json_data TYPE REF TO zcl_trex_json_serializer.
  DATA: lv_uom                TYPE char3.
  DATA: lv_posnr              TYPE vbap-posnr.
  DATA: lv_order_sfa(10).
  DATA: lv_cash_back TYPE bapikbetr1.
  DATA: lv_idoc TYPE edinum.
  DATA      : gt_order_items_in     TYPE STANDARD TABLE OF bapisditm,
              gt_order_schedules_in TYPE STANDARD TABLE OF bapischdl,
              gt_order_partners     TYPE STANDARD TABLE OF bapiparnr, "e1bpparnr, "
              gt_return             TYPE STANDARD TABLE OF bapiret2,
              gt_order_text         TYPE STANDARD TABLE OF bapisdtext,
              gt_conditions         TYPE STANDARD TABLE OF bapicond,
              wa_order_text         TYPE bapisdtext,
              wa_return             TYPE bapiret2,
              wa_order_header_in    TYPE bapisdhd1,
              wa_order_header_inx   TYPE  bapisdhd1x,
              wa_order_partners     TYPE bapiparnr, "e1bpparnr, "
              wa_order_items_in     TYPE bapisditm,
              wa_order_schedules_in TYPE bapischdl,
              wa_conditions         LIKE LINE OF gt_conditions.
  DATA: lc_parvw                TYPE knvp-parvw VALUE 'SP',
        lc_distribution_channel TYPE knvp-vtweg VALUE '10',
        lc_division             TYPE knvp-spart VALUE '00'.
  TYPES: BEGIN OF ty_item_err,
           no_item       TYPE numc06,
           message_error TYPE char255,
         END OF ty_item_err.
  DATA: BEGIN OF lt_matkl OCCURS 0,
          matnr TYPE matnr,
          matkl TYPE matkl,
        END OF lt_matkl.
  DATA: ls_zsmapping_soff TYPE zsmapping_soff.
  DATA: ls_tvstz TYPE tvstz.
  DATA: lv_lgort TYPE vbap-lgort.
  DATA: lv_vstel TYPE vbap-vstel.
  DATA: lv_auart TYPE vbak-auart.
  "        lv_vstel TYPE tvstz-vstel.

  DATA: BEGIN OF i_status,
          nomor_order_sfa(10),
          nomor_quotation(10),
          tanggal_quotation(10),
          nomor_dn(10),
          tanggal_dn(10),
          nomor_billing(10),
          tanggal_billing(10),
          nomor_shipment(10),
          tanggal_shipment(10),
          amount(15),
          status(1),
          idoc(20),
          items_err             TYPE STANDARD TABLE OF ty_item_err WITH DEFAULT KEY,
        END  OF i_status.
  DATA: ls_item_err TYPE ty_item_err.
  DATA: lv_vkorg TYPE vbak-vkorg.
  DATA: lv_vkbur LIKE vbak-vkbur.
  DATA:  gv_str TYPE string.
  DATA: lv_ctr TYPE i.
  DATA: ls_zsfasddt010 TYPE zsfasddt010.
  DATA: ls_zsfasddt002 TYPE zsfasddt002.
  DATA: ls_zsfasddt010d TYPE zsfasddt010d.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        gv_json      TYPE string.
  DATA: l_name(15).
  DATA: lv_text1024 TYPE text1024.
  DATA: lr_imatkl TYPE RANGE OF matkl,
        lr_ematkl TYPE RANGE OF matkl,
        ls_matkl  LIKE LINE OF lr_imatkl.

  ls_matkl-low    = 'NTR*'.
  ls_matkl-sign   = 'I'.
  ls_matkl-option = 'CP'.
  APPEND ls_matkl TO lr_imatkl.
  CLEAR ls_matkl.
  ls_matkl-low    = 'SGM*'.
  ls_matkl-sign   = 'I'.
  ls_matkl-option = 'CP'.
  APPEND ls_matkl TO lr_imatkl.
  CLEAR ls_matkl.

  ls_matkl-low    = 'NTR*'.
  ls_matkl-sign   = 'E'.
  ls_matkl-option = 'CP'.
  APPEND ls_matkl TO lr_ematkl.
  CLEAR ls_matkl.
  ls_matkl-low    = 'SGM*'.
  ls_matkl-sign   = 'E'.
  ls_matkl-option = 'CP'.
  APPEND ls_matkl TO lr_ematkl.
  CLEAR ls_matkl.
  ls_matkl-low    = 'DUMMY'.
  ls_matkl-sign   = 'E'.
  ls_matkl-option = 'EQ'.
  APPEND ls_matkl TO lr_ematkl.
  CLEAR ls_matkl.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_order ).
  "  IF p_order_sfa = 'ORDER_SFA'.
  CLEAR: wa_order_header_in, wa_order_header_inx, lv_vbeln, wa_conditions, lv_cash_back,
         gt_return[], gt_order_items_in[], gt_order_schedules_in[],
         gt_order_text[], gt_order_partners[], gt_conditions[].

*** inisial awal untuk variable buat select data
  lv_vkorg = ls_order-sales_org_code.
  lv_auart = ls_order-sales_doc_type.
  lv_vstel = lv_vkbur = ls_order-sales_office.
  lv_lgort = '1000'.

*** masukan ke dalam table cek / kontrol
  ls_zsfasddt010-vkorg = ls_order-sales_org_code.
  ls_zsfasddt010-vkbur = ls_order-sales_office.
  ls_zsfasddt010-submi = ls_order-nomor_order_sfa.
  ls_zsfasddt010-logdat = sy-datum.
  ls_zsfasddt010-logtim = sy-uzeit.
  ls_zsfasddt010-uname = sy-uname.
  ls_zsfasddt010-nodcp = ls_order-nomor_call_id.
  ls_zsfasddt010-auart = ls_order-sales_doc_type.
  IF ls_zsfasddt010-submi IS NOT INITIAL.
    PERFORM f_lock_ezsfasddt010 USING ls_zsfasddt010-vkorg
                                      ls_zsfasddt010-vkbur
                                      ls_zsfasddt010-submi
                                CHANGING sy-subrc.
    IF sy-subrc EQ 0.
      IF ls_zsfasddt010-vkorg IS NOT INITIAL AND ls_zsfasddt010-vkbur IS NOT INITIAL AND ls_zsfasddt010-submi IS NOT INITIAL.
        MODIFY zsfasddt010 FROM ls_zsfasddt010.
        COMMIT WORK AND WAIT.
      ELSE.
        CLEAR: ls_order-sales_order_details[].
        p_status = 'E'.
        CONCATENATE 'No. Order SFA' ls_zsfasddt010-submi 'data tidak lengkap' INTO p_message_error SEPARATED BY space.
        RETURN.
      ENDIF.
    ELSE.
      CLEAR: ls_order-sales_order_details[].
      p_status = 'E'.
      CONCATENATE 'No. Order SFA' ls_zsfasddt010-submi 'tidak dapat dilock' INTO p_message_error SEPARATED BY space.
      RETURN.
    ENDIF.
  ENDIF.
  lv_order_sfa = wa_order_header_in-collect_no       = ls_order-nomor_order_sfa.
  wa_order_header_inx-collect_no      = 'X'.
  wa_order_header_inx-updateflag      = 'X'.
  wa_order_header_in-sales_org        = ls_order-sales_org_code.
  wa_order_header_inx-sales_org        = 'X'.
  wa_order_header_in-distr_chan       = lc_distribution_channel.
  wa_order_header_inx-distr_chan       = 'X'.
  wa_order_header_in-division         = lc_division.
  wa_order_header_inx-division         = 'X'.
  wa_order_header_in-doc_type         = ls_order-sales_doc_type.
  wa_order_header_inx-doc_type         = 'X'.
  wa_order_header_in-purch_no_c       = ls_order-customer_nomor_po. "wa_vbak-bstkd. "no po
  wa_order_header_inx-purch_no_c       = 'X'.
  IF ls_order-customer_tgl_po IS INITIAL.
    ls_order-customer_tgl_po = sy-datum.
  ENDIF.
  wa_order_header_in-price_date       = ls_order-customer_tgl_po. "wa_vbak-bstdk. "tgl po
  wa_order_header_inx-price_date       = 'X'.
  wa_order_header_in-purch_date       = ls_order-customer_tgl_po. "wa_vbak-bstdk. "tgl po
  wa_order_header_inx-purch_date       = 'X'.
**  wa_order_header_in-po_supplem       = wa_vbak-bstzd.
**  wa_order_header_inx-po_supplem       = 'X'.
  wa_order_header_in-ship_cond        = '00'. "wa_vbak-vsbed.
  wa_order_header_inx-ship_cond       = 'X'.
  wa_order_header_in-dlvschduse       = ls_order-payment_type. "wa_vbak-abrvw.
  wa_order_header_inx-dlvschduse      = 'X'.
  wa_order_header_in-dun_date         = ls_order-tgl_jatuh_tempo. "wa_vbak-mahdt.
  wa_order_header_inx-dun_date        = 'X'.
  wa_order_header_in-ord_reason       = ls_order-order_reason. "wa_vbak-augru.
  wa_order_header_inx-ord_reason       = 'X'.

**** siapkan data untuk customer partners
  wa_order_partners-partn_role = lc_parvw.
  wa_order_partners-partn_numb = ls_order-customer_code. "l_kunn2.
  APPEND wa_order_partners TO gt_order_partners .
  IF ls_order-delivery_route_list IS NOT INITIAL.
    wa_order_partners-partn_role = 'ZS'.
    wa_order_partners-partn_numb = ls_order-delivery_route_list. "l_kunn2.
    APPEND wa_order_partners TO gt_order_partners .
  ENDIF.
  IF ls_order-collector_route_list IS NOT INITIAL.
    wa_order_partners-partn_role = 'ZC'.
    wa_order_partners-partn_numb = ls_order-collector_route_list. "l_kunn4.
    APPEND wa_order_partners TO gt_order_partners .
  ENDIF.
  IF ls_order-salesman_code IS NOT INITIAL.
    wa_order_partners-partn_role = 'VE'.
    wa_order_partners-partn_numb = ls_order-salesman_code. "  l_kunn3.
    APPEND wa_order_partners TO gt_order_partners .
    wa_order_partners-partn_role = 'ZP'.
    wa_order_partners-partn_numb = ls_order-salesman_code. "  l_kunn3.
    APPEND wa_order_partners TO gt_order_partners .
  ENDIF.

*** masukkan data cash back amt dari timos
  CONDENSE ls_order-cashback_amt.
  IF ls_order-cashback_amt IS NOT INITIAL.
    lv_cash_back = ls_order-cashback_amt.
    lv_cash_back = abs( lv_cash_back ) * -1.
    wa_conditions-itm_number  = '000000'.
    wa_conditions-cond_type   = 'ZD12'.
    wa_conditions-cond_value  = lv_cash_back. "ls_order-cashback_amt. "gs_001h-vcham.
    wa_conditions-currency    = 'IDR'.
    wa_conditions-condcoinhd  = '01'.
    APPEND wa_conditions TO gt_conditions.
    CLEAR wa_conditions.
  ENDIF.

*** validasi untuk ganti sales office dan lgort jika memenuhi syarat
  SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_zsmapping_soff FROM zsmapping_soff
          WHERE auart = lv_auart AND
                vkorg = lv_vkorg AND
                vkbur1 = lv_vstel.
  IF sy-subrc EQ 0.
    lv_vkbur = ls_zsmapping_soff-vkbur2.
    lv_lgort = ls_zsmapping_soff-lgort.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_tvstz
      FROM tvstz
      WHERE vsbed = 'HB' AND
            werks = ls_zsmapping_soff-reswk.
    IF sy-subrc EQ 0.
      lv_vstel = ls_tvstz-vstel.
    ENDIF.
  ENDIF.
  DATA: lv_low TYPE tvarvc-low.
** Prepare data item
  CLEAR: lv_posnr.
  DESCRIBE TABLE ls_order-sales_order_details LINES lv_count.
  SELECT SINGLE low INTO lv_low FROM tvarvc WHERE name = 'ZTIMOS_ORDER'.
  IF sy-subrc EQ 0.
    lv_count1 = lv_low.
    IF lv_count > lv_count1.
      CLEAR: gt_return[], wa_return.
      wa_return-message_v1 = 'Order no.'.
      wa_return-message_v2 = p_order_sfa.
      wa_return-message_v3 = lv_count.
      wa_return-message_v4 = lv_count1.
      CONDENSE wa_return-message_v3.
      CONCATENATE 'Jumlah order melebih ketentuan (' wa_return-message_v4 ') :' wa_return-message_v3
           INTO wa_return-message_v3 SEPARATED BY space.
      wa_return-type = 'E'.
      wa_return-id = 'ZAB'.
      wa_return-number = '000'.
      APPEND wa_return TO gt_return.
      PERFORM f_record_error TABLES gt_return USING ls_zsfasddt010 CHANGING lv_idoc.
      p_idoc = lv_idoc.
      RETURN.
    ENDIF.
  ENDIF.
  LOOP AT ls_order-sales_order_details INTO ls_order_item.
    ADD 10 TO lv_posnr.
    wa_order_items_in-material = ls_order_item-material.
    CONDENSE: ls_order_item-quantity.
    wa_order_items_in-target_qty = ls_order_item-quantity.
    wa_order_items_in-ship_point = lv_vstel. "ls_order-sales_office.
    wa_order_items_in-plant = lv_vkbur. "ls_order-sales_office.
    wa_order_items_in-store_loc = lv_lgort. "'1000'.
    PERFORM f_convert_internal_uom USING ls_order_item-material_uom
                                         lv_uom.
    wa_order_items_in-target_qu = lv_uom.
    wa_order_items_in-plant = lv_vkbur. "ls_order-sales_office.
    wa_order_items_in-ship_point = lv_vstel. "ls_order-sales_office.
    wa_order_items_in-store_loc = lv_lgort. "'1000'.
    wa_order_items_in-item_categ =  ls_order_item-item_category.
    wa_order_schedules_in-itm_number = lv_posnr.
    wa_order_schedules_in-req_qty = ls_order_item-quantity.
    APPEND wa_order_items_in TO gt_order_items_in.
    APPEND wa_order_schedules_in TO gt_order_schedules_in.
    CLEAR: wa_order_schedules_in, wa_order_items_in.
    wa_order_text-itm_number = lv_posnr.
    wa_order_text-text_id    = 'Z001'.
    wa_order_text-langu      = 'EN'.
    wa_order_text-format_col = '*'. "wa_xe1edpt2-TDFORMAT.
    wa_order_text-text_line  = ls_order_item-ket_detail. "ltext1
    wa_order_text-function   = '005'.
    APPEND wa_order_text TO gt_order_text.
    CLEAR: ls_order_item.
  ENDLOOP.
  DATA: lv_subrc TYPE sy-subrc.
  IF gt_order_items_in[] IS NOT INITIAL.
**    IF ls_order-sales_doc_type = 'ZQN4'.
**      CLEAR: lt_matkl[], p_status.
**      SELECT matnr matkl INTO TABLE lt_matkl FROM mara
**        FOR ALL ENTRIES IN gt_order_items_in
**        WHERE matnr = gt_order_items_in-material.
**      IF sy-subrc EQ 0.
**        SORT lt_matkl BY matkl.
**        DELETE ADJACENT DUPLICATES FROM lt_matkl COMPARING matkl.
**        lv_subrc = 4.
**        LOOP AT lt_matkl .
**          IF lt_matkl-matkl IN lr_imatkl.
**            CLEAR lv_subrc.
**            EXIT.
**          ENDIF.
**        ENDLOOP.
**        IF lv_subrc = 0.
**          LOOP AT lt_matkl .
**            IF lt_matkl-matkl IN lr_ematkl.
**              p_message_error = 'Tidak boleh ada selain NTR atau SGM'.
**              p_status = 'E'.
**              EXIT.
**            ENDIF.
**          ENDLOOP.
**        ENDIF.
**        IF p_status = 'E'.
**          wa_return-message_v1 = 'Order no.'.
**          wa_return-message_v2 = p_order_sfa.
**          wa_return-message_v3 = 'Tidak boleh ada selain NTR atau SGM'.
**          wa_return-type = 'E'.
**          wa_return-id = 'ZAB'.
**          wa_return-number = '000'.
**          APPEND wa_return TO gt_return.
**          PERFORM f_record_error TABLES gt_return USING ls_zsfasddt010.
**          RETURN.
**        ENDIF.
**      ENDIF.
**    ENDIF.
    IF ls_order-sales_org_code = '8020'.
      CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
        EXPORTING
          order_header_in     = wa_order_header_in
          order_header_inx    = wa_order_header_inx
          convert             = 'X'
          "INT_NUMBER_ASSIGNMENT = 'X'
        IMPORTING
          salesdocument       = lv_vbeln        " ORDER_HEADER_INX = wa_BAPISDHD1X
        TABLES
          return              = gt_return
          order_items_in      = gt_order_items_in
          order_schedules_in  = gt_order_schedules_in
          order_text          = gt_order_text
          order_partners      = gt_order_partners
          order_conditions_in = gt_conditions
        EXCEPTIONS
          error_message       = 99
          OTHERS              = 01.
    ELSE.
      CALL FUNCTION 'BAPI_QUOTATION_CREATEFROMDATA2'
        EXPORTING
          quotation_header_in     = wa_order_header_in
          quotation_header_inx    = wa_order_header_inx
          convert                 = 'X'
        IMPORTING
          salesdocument           = lv_vbeln        " ORDER_HEADER_INX = wa_BAPISDHD1X
        TABLES
          return                  = gt_return
          quotation_items_in      = gt_order_items_in
          quotation_schedules_in  = gt_order_schedules_in
          quotation_text          = gt_order_text
          quotation_partners      = gt_order_partners
          quotation_conditions_in = gt_conditions
        EXCEPTIONS
          error_message           = 99.        "
    ENDIF.
  ELSE.
    CLEAR: wa_return.
    CONCATENATE 'Order no.' p_order_sfa 'tidak ada detailnya' INTO p_message_error SEPARATED BY space.
    CONCATENATE 'Order no.' p_order_sfa 'tidak ada detailnya' INTO wa_return-message SEPARATED BY space.
    wa_return-message_v1 = 'Order no.'.
    wa_return-message_v2 = p_order_sfa.
    wa_return-message_v3 = 'tidak ada detailnya'.
    wa_return-type = 'E'.
    wa_return-id = 'ZAB'.
    wa_return-number = '000'.
    APPEND wa_return TO gt_return.
    CLEAR: lv_vbeln.
  ENDIF.
  SORT gt_return BY type
                    id
                    number
                    message_v1
                    message_v2
                    message_v3
                    message_v4.
  DELETE ADJACENT DUPLICATES FROM gt_return COMPARING type
                                                      id
                                                      number
                                                      message_v1
                                                      message_v2
                                                      message_v3
                                                      message_v4.
  IF lv_vbeln IS NOT INITIAL.
    CLEAR: ls_zsfasddt010-docnum.
    ls_zsfasddt010-vbeln = lv_vbeln.
    ls_zsfasddt010-erdat = sy-datum.
    ls_zsfasddt010-erzet = sy-uzeit.
    ls_zsfasddt010-ernam = sy-uname.
    PERFORM f_unlock_ezsfasddt010 USING ls_zsfasddt010-vkorg
                                          ls_zsfasddt010-vkbur
                                          ls_zsfasddt010-submi
                                          CHANGING sy-subrc.
    PERFORM f_lock_ezsfasddt010 USING ls_zsfasddt010-vkorg
                                      ls_zsfasddt010-vkbur
                                      ls_zsfasddt010-submi
                                CHANGING sy-subrc.
    IF sy-subrc EQ 0.
      MODIFY zsfasddt010 FROM ls_zsfasddt010.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING ls_zsfasddt010 TO ls_zsfasddt002.
        ls_zsfasddt002-vkbur1 = lv_vkbur.
        MODIFY zsfasddt002 FROM ls_zsfasddt002.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        p_quotation = lv_vbeln.
        p_status = 'S'.
        CONCATENATE 'Order SFA no.' lv_order_sfa  'Berhasil terbentuk di SAP no.' lv_vbeln INTO p_message_error
        SEPARATED BY space.
******        CLEAR: i_status, gv_str.
******        i_status-nomor_order_sfa = lv_order_sfa.
******        i_status-nomor_quotation = lv_vbeln.
******        i_status-tanggal_quotation = sy-datum.
******        CLEAR: i_status-nomor_dn, i_status-tanggal_dn, i_status-nomor_billing, i_status-idoc,
******               i_status-tanggal_billing, i_status-nomor_shipment, i_status-tanggal_shipment, i_status-amount.
******        i_status-status = 'S'.
******        CLEAR: i_status-items_err[].
******        CREATE OBJECT cl_json_data
******          EXPORTING
******            data = i_status.
******        cl_json_data->serialize( ).
******        gv_json = cl_json_data->get_data( ).
******        PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'SFA_UPDATE_STS' sy-subrc gv_str.
******        l_name  = lv_order_sfa.
******        CONCATENATE 'St_' l_name INTO l_name.
******        CONDENSE l_name.
******        PERFORM f_create_text_json(ztdsit_i001) USING gv_json l_name '/outbound/sfa/api/' 'SFA_UPDATE_STS'.
        PERFORM f_unlock_ezsfasddt010 USING ls_zsfasddt010-vkorg
                                              ls_zsfasddt010-vkbur
                                              ls_zsfasddt010-submi
                                              CHANGING sy-subrc.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        CLEAR: lv_vbeln.
      ENDIF.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      PERFORM f_unlock_ezsfasddt010 USING ls_zsfasddt010-vkorg
                                            ls_zsfasddt010-vkbur
                                            ls_zsfasddt010-submi
                                            CHANGING sy-subrc.
      p_status = 'E'.
      CONCATENATE 'SFA no.' lv_order_sfa  'atas quotation' lv_vbeln 'dirollback'
      INTO p_message_error  SEPARATED BY space.
      CLEAR: lv_vbeln.
      RETURN.
    ENDIF.
  ENDIF.
  IF lv_vbeln IS INITIAL.
    DATA:   lv_no_error TYPE edinum.
    READ TABLE gt_return  INTO wa_return  WITH KEY type = 'E'.
    IF sy-subrc EQ 0.
      IF lv_order_sfa IS INITIAL.
        lv_order_sfa = p_order_sfa.
      ENDIF.
      CLEAR: p_quotation.
      p_message_error = wa_return-message.
      p_status = 'E'.
      CONCATENATE 'Error SFA no.' lv_order_sfa  p_message_error  INTO p_message_error
      SEPARATED BY space.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      PERFORM f_record_error TABLES gt_return USING ls_zsfasddt010 CHANGING lv_idoc.
      p_idoc = lv_idoc.
    ENDIF.
  ENDIF.
ENDFORM.

FORM f_lock_ezsfasddt010  USING    fu_vkorg
                                   fu_vkbur
                                   fu_submi
                         CHANGING fu_return.
  CALL FUNCTION 'ENQUEUE_EZSFASDDT010'
    EXPORTING
      vkorg          = fu_vkorg
      vkbur          = fu_vkbur
      submi          = fu_submi
*     _wait          = 'X'
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  fu_return = sy-subrc.
ENDFORM.                    " F_LOCK_EZDG2CADT0001H

*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_EZDG2CADT0001H
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_unlock_ezsfasddt010  USING  fu_vkorg
                                   fu_vkbur
                                   fu_submi
                          CHANGING fu_return..
  CALL FUNCTION 'DEQUEUE_EZSFASDDT010'
    EXPORTING
      vkorg          = fu_vkorg
      vkbur          = fu_vkbur
      submi          = fu_submi
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  fu_return = sy-subrc.
ENDFORM.                    " F_UNLOCK_EZDG2CADT0001H



*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_INTERNAL_UOM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_VBAP_VRKME  text
*----------------------------------------------------------------------*
FORM f_convert_internal_uom  USING p_input
                                   p_output.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      input          = p_input
    IMPORTING
      output         = p_output
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " F_CONVERT_INTERNAL_UOM
*&---------------------------------------------------------------------*
*&      Form  F_RECORD_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_RETURN  text
*      -->P_LS_ZSFASDDT010  text
*----------------------------------------------------------------------*
FORM f_record_error  TABLES   p_return
                     USING    p_header
                     CHANGING p_idoc.
  TYPES: BEGIN OF ty_item_err,
           no_item       TYPE numc06,
           message_error TYPE char255,
         END OF ty_item_err.
  DATA:   lv_no_error TYPE edinum.
  DATA: BEGIN OF i_status,
          nomor_order_sfa(10),
          nomor_quotation(10),
          tanggal_quotation(10),
          nomor_dn(10),
          tanggal_dn(10),
          nomor_billing(10),
          tanggal_billing(10),
          nomor_shipment(10),
          tanggal_shipment(10),
          amount(15),
          status(1),
          idoc(20),
          items_err             TYPE STANDARD TABLE OF ty_item_err WITH DEFAULT KEY,
        END  OF i_status.
  DATA: ls_item_err TYPE ty_item_err.
  DATA: lv_vkorg TYPE vbak-vkorg.
  DATA: lv_vkbur LIKE vbak-vkbur.
  DATA:  gv_str TYPE string.
  DATA: lv_ctr TYPE i.
  DATA: ls_zsfasddt010 TYPE zsfasddt010.
  DATA: ls_zsfasddt002 TYPE zsfasddt002.
  DATA: ls_zsfasddt010d TYPE zsfasddt010d.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        gv_json      TYPE string.
  DATA: l_name(15).
  DATA: lv_text1024 TYPE text1024.
  DATA: lv_str TYPE i.
  DATA: lt_return TYPE STANDARD TABLE OF bapiret2,
        ls_header TYPE zsfasddt010,
        wa_return LIKE LINE OF lt_return.
  ls_zsfasddt010 = p_header.
  lt_return[] = p_return[].
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZSFA_ERROR'
"     subobject               = lv_no_error
    IMPORTING
      number                  = lv_no_error
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.
  ls_zsfasddt010-docnum = lv_no_error.
  CLEAR: ls_zsfasddt010-vbeln.
  ls_zsfasddt010-erdat = sy-datum.
  ls_zsfasddt010-erzet = sy-uzeit.
  ls_zsfasddt010-ernam = sy-uname.
  MODIFY zsfasddt010 FROM ls_zsfasddt010.
  PERFORM f_unlock_ezsfasddt010 USING ls_zsfasddt010-vkorg
                                        ls_zsfasddt010-vkbur
                                        ls_zsfasddt010-submi
                                        CHANGING sy-subrc.
  CLEAR: i_status, gv_str.
  i_status-nomor_order_sfa = ls_zsfasddt010-submi.
  CLEAR: i_status-nomor_quotation, i_status-tanggal_quotation, i_status-nomor_dn, i_status-tanggal_dn, i_status-nomor_billing,
         i_status-tanggal_billing, i_status-nomor_shipment, i_status-tanggal_shipment, i_status-amount.
  i_status-status = 'Q'.
  p_idoc = i_status-idoc = lv_no_error.

  CLEAR: lv_str.
  LOOP AT lt_return INTO wa_return.
    ADD 1 TO lv_ctr.
    ls_item_err-no_item = lv_ctr.
    "         ls_item_err-message_error
    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id        = wa_return-id
        lang      = sy-langu
        no        = wa_return-number
        v1        = wa_return-message_v1
        v2        = wa_return-message_v2
        v3        = wa_return-message_v3
        v4        = wa_return-message_v4
      IMPORTING
        msg       = ls_item_err-message_error "gv_message
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    ls_zsfasddt010d-docnum = lv_no_error.
    ls_zsfasddt010d-no_item = ls_item_err-no_item.

    lv_text1024 = ls_item_err-message_error.
    CALL FUNCTION 'ZTDSIT_F0002'
      EXPORTING
        ztextin  = lv_text1024
      IMPORTING
        ztextout = lv_text1024.
    ls_item_err-message_error = lv_text1024.
    ls_zsfasddt010d-message_error = ls_item_err-message_error.
    MODIFY zsfasddt010d FROM ls_zsfasddt010d.
    APPEND ls_item_err TO i_status-items_err.
    CLEAR: ls_item_err.
  ENDLOOP.
  COMMIT WORK AND WAIT.
  CREATE OBJECT cl_json_data
    EXPORTING
      data = i_status.
  cl_json_data->serialize( ).
  gv_json = cl_json_data->get_data( ).
  PERFORM f_post_data_json(ztdsit_i001) USING gv_json 'SFA_STATUS_STS' sy-subrc gv_str.
  l_name  = ls_zsfasddt010-submi.
  CONCATENATE 'St_' l_name '_err' INTO l_name.
  CONDENSE l_name.
  PERFORM f_create_text_json(ztdsit_i001) USING gv_json l_name '/outbound/sfa/api/' 'SFA_STATUS_STS'.


ENDFORM.
