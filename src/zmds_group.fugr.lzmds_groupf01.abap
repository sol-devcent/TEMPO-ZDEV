*----------------------------------------------------------------------*
***INCLUDE LZMDS_GROUPF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_ADV_UJP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PI_DATA  text
*      -->P_PI_REFERENCE  text
*      <--P_PI_TYPE  text
*      <--P_PI_MESSAGE  text
*      <--P_PI_DOCUMENT  text
*----------------------------------------------------------------------*
FORM f_proses_adv_ujp  USING    p_data
                                p_reference
                       CHANGING p_type
                                p_message
                                p_document
                                p_export.
  TYPES: BEGIN OF ty_adv_ujp,
           transaction_id      TYPE string,
           vendor_code         TYPE string,
           sales_office        TYPE string,
           deliveryman_name    TYPE string,
           posting_date        TYPE string,
           voucher_no          TYPE string,
           vehicle_no          TYPE string,
           total               TYPE string,
           gl_account_ujp      TYPE string,
           gl_account_cashbank TYPE string,
           user_request        TYPE string,
           date_process        TYPE string,
           time_process        TYPE string,
           sap_document        TYPE string,
           voucher_nosap       TYPE string,
           status              TYPE string,
           message             TYPE string,
         END OF ty_adv_ujp.
  DATA: ls_adv_ujp TYPE ty_adv_ujp.
  DATA : lv_json_data  TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  DATA : zl_json_data TYPE REF TO zcl_trex_json_serializer.
  DATA: ls_zf63trnhdr2 TYPE zf63trnhdr2.
  DATA: ls_zf63trndtl2 TYPE zf63trndtl2.
  DATA: ls_zf63acckasexp TYPE zf63acckasexp.
  DATA: ls_zf63nomor TYPE zf63nomor.
  DATA: lv_transaction_id TYPE zf63trnhdr2-transaction_id.
  DATA: lv_err(1), error_msg(100).
  DATA: lv_spmon TYPE zf63nomor-spmon.
  DATA: lv_proses TYPE char15.
  lv_json_data = p_data.
*****  CONCATENATE 'Get_'  PI_REFERENCE INTO lv_nama.
*****  PERFORM f_create_text_json(ztdsit_i001) USING lv_json_data lv_nama '/outbound/mds/api/' 'SFA_CUSTOMER'.
***
***
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_adv_ujp ).

  IF ls_adv_ujp-transaction_id IS NOT INITIAL.
    CLEAR: lv_err, error_msg.
    lv_transaction_id = ls_adv_ujp-transaction_id.
    SELECT SINGLE * INTO ls_zf63trnhdr2 FROM zf63trnhdr2
      WHERE transaction_id = lv_transaction_id
        AND gtype = '15'.
    IF sy-subrc EQ 0.
      p_document = ls_zf63trnhdr2-zidvc.
      p_type = 'S'.
      CONCATENATE 'Dokumen tersimpan dengan no. '  ls_zf63trnhdr2-zidvc INTO p_message.
    ELSE.
*** Lanjut proses seimpan ke table
      ls_zf63trnhdr2-transaction_id = lv_transaction_id.
      IF ls_adv_ujp-sales_office(2) = '02'.
        ls_zf63trnhdr2-bukrs = '8020'.
      ELSE.
        ls_zf63trnhdr2-bukrs = '8070'.
      ENDIF.
      ls_zf63trnhdr2-gsber = ls_adv_ujp-sales_office.
      ls_zf63trnhdr2-vkbur = ls_adv_ujp-sales_office.
      ls_zf63trnhdr2-gtype = '15'.
      ls_zf63trnhdr2-gjahr = ls_adv_ujp-posting_date(4).
      ls_zf63trnhdr2-hkont = ls_adv_ujp-gl_account_cashbank.

      SELECT SINGLE * INTO ls_zf63acckasexp
        FROM zf63acckasexp
        WHERE gsber = ls_zf63trnhdr2-gsber AND
              gtype = ls_zf63trnhdr2-gtype AND
              hkont = ls_zf63trnhdr2-hkont. "gl_account_cashbank
      IF sy-subrc NE 0.
        lv_err =  'E'.
        CONCATENATE ls_zf63trnhdr2-gsber ls_zf63trnhdr2-gtype ls_zf63trnhdr2-hkont INTO error_msg SEPARATED BY '/'.
        CONCATENATE error_msg ' tidak ditemukan di table zf63acckasexp' INTO error_msg.
      ELSE.
        lv_spmon = ls_adv_ujp-posting_date(6).
        SELECT SINGLE * INTO ls_zf63nomor FROM zf63nomor
          WHERE bukrs = ls_zf63trnhdr2-bukrs AND
                vkbur = ls_zf63trnhdr2-vkbur AND
                shkzg = 'H' AND
                nmvch = ls_zf63acckasexp-nmvoucher AND
                spmon = lv_spmon.
        IF sy-subrc NE 0.
          lv_err =  'E'.
          CONCATENATE ls_zf63trnhdr2-bukrs ls_zf63trnhdr2-vkbur ls_zf63acckasexp-nmvoucher lv_spmon
             INTO error_msg SEPARATED BY '/'.
          CONCATENATE error_msg ' tidak ditemukan di table zf63nomor' INTO error_msg.
        ENDIF.
        "Format ZIDVC : KDVCH/SPMON/Nomor; cth: CPV/202411/00001"
        ADD 1 TO ls_zf63nomor-nomor.
        CONCATENATE ls_zf63nomor-kdvch  ls_zf63nomor-spmon ls_zf63nomor-nomor
        INTO ls_zf63trnhdr2-zidvc SEPARATED BY '/'.
        ls_zf63trnhdr2-zidno = ls_adv_ujp-vendor_code.
        CONCATENATE 'Adv.' ls_adv_ujp-deliveryman_name
           INTO ls_zf63trnhdr2-bktxt SEPARATED BY space.
        ls_zf63trnhdr2-waers = 'IDR'.
        ls_zf63trnhdr2-wrbtr = ls_adv_ujp-total / 100.
        ls_zf63trnhdr2-shkzg = 'S'.
        ls_zf63trnhdr2-ernam = ls_adv_ujp-user_request.
        ls_zf63trnhdr2-erdat = sy-datum.
        ls_zf63trnhdr2-erzet = sy-uzeit.
        ls_zf63trnhdr2-xblnradv = ls_adv_ujp-voucher_no.
        ls_zf63trnhdr2-budatpadv = ls_adv_ujp-posting_date.
        ls_zf63trnhdr2-gjahrpadv = ls_adv_ujp-posting_date(4).
**ls_ZF63TRNHDR2-USERPOST =
**ls_ZF63TRNHDR2-TGLPOST
**ls_ZF63TRNHDR2-JAMPOST
        ls_zf63trnhdr2-hkont = ls_adv_ujp-gl_account_cashbank.
        ls_zf63trndtl2-zidvc = ls_zf63trnhdr2-zidvc.
        ls_zf63trndtl2-type = '303'.
        ls_zf63trndtl2-buzei = '001'.
        ls_zf63trndtl2-bukrs = ls_zf63trnhdr2-bukrs.
        ls_zf63trndtl2-gsber = ls_zf63trnhdr2-gsber.
        ls_zf63trndtl2-vkbur = ls_zf63trnhdr2-vkbur.
        ls_zf63trndtl2-gtype = '15'.
        ls_zf63trndtl2-gjahr = ls_adv_ujp-posting_date(4).
        "    ls_zf63trnhdr2-ZIDVC =  ls_ZF63TRNHDR2-ZIDVC.
        "    ls_zf63trndtl2-type = ls_adv_ujp-gl_account_ujp. --> gl_account_type
        ls_zf63trndtl2-znopol = ls_adv_ujp-vehicle_no.
        ls_zf63trndtl2-description = 'ADV DELIVERY'.
        ls_zf63trndtl2-waers = 'IDR'.
        ls_zf63trndtl2-shkzg = 'S'.
        ls_zf63trndtl2-wrbtr = ls_adv_ujp-total / 100.
        CONCATENATE 'ADV DELIVERY' ls_adv_ujp-deliveryman_name
        INTO ls_zf63trndtl2-text SEPARATED BY space.
      ENDIF.
      IF ls_zf63trndtl2 IS NOT INITIAL AND ls_zf63trnhdr2 IS NOT INITIAL AND lv_err NE 'E'.
        MODIFY zf63trnhdr2 FROM ls_zf63trnhdr2.
        MODIFY zf63trndtl2 FROM ls_zf63trndtl2.
        p_document = ls_zf63trnhdr2-zidvc.
        p_type = 'S'.
        CONCATENATE 'Dokumen tersimpan dengan no. '  ls_zf63trnhdr2-zidvc INTO p_message.
        UPDATE zf63nomor SET nomor = ls_zf63nomor-nomor
          WHERE bukrs = ls_zf63nomor-bukrs AND
                vkbur = ls_zf63nomor-vkbur AND
                shkzg = 'H' AND
                nmvch = ls_zf63nomor-nmvch AND
                spmon = ls_zf63nomor-spmon.

      ELSE.
        IF lv_err =  'E'.
          p_type = 'E'.
          p_message = error_msg.
        ELSE.
          p_type = 'E'.
          CONCATENATE 'Transaction id.'  lv_transaction_id 'Gagal diproses' INTO p_message.
        ENDIF.
      ENDIF.
      COMMIT WORK.
      ls_adv_ujp-voucher_nosap = ls_zf63trnhdr2-zidvc..
      ls_adv_ujp-status = p_type.
      ls_adv_ujp-message = p_message.

    ENDIF.
    IF p_type = 'S'.
      DATA: lr_zf63n TYPE REF TO data,
            ls_zf63n TYPE REF TO data.
      IF ls_zf63trnhdr2-belnrpadv IS INITIAL.
        WAIT UP TO 2 SECONDS.
        SUBMIT zf_jurnal_expv1 WITH pa_bukrs = ls_zf63trnhdr2-bukrs
                                     WITH pa_vkbur = ls_zf63trnhdr2-vkbur
                                    WITH pa_gsber  = ls_zf63trnhdr2-gsber
                                     WITH pa_gtype = ls_zf63trnhdr2-gtype
                                     WITH pa_zidv2 = ls_zf63trnhdr2-zidvc
                                     WITH pa_gjahr = ls_zf63trnhdr2-gjahr
                                     WITH radio6 = 'X'
                                     WITH p_timde6 = 'X'
                                     WITH radio1 =  ' '
                                     WITH radio2 =  ' '
                                     WITH radio3  =  ' '
                                     WITH radio14  =  ' '
                                     WITH radio4  =  ' '
                                     WITH radio15  =  ' '
                                     WITH radio5  =  ' '
                                     WITH radio8  =  ' '
                                     WITH radio17  =  ' '
                                     WITH radio7  =  ' '
                                     WITH radio9  =  ' '
                                     WITH radio10  =  ' '
                                     WITH radio11  =  ' '
                                     WITH radio12  =  ' '
                                     WITH radio13  =  ' ' AND RETURN.
        WAIT UP TO 2 SECONDS.
        SELECT SINGLE belnrpadv INTO ls_zf63trnhdr2-belnrpadv
          FROM zf63trnhdr2
          WHERE bukrs = ls_zf63trnhdr2-bukrs
                AND vkbur = ls_zf63trnhdr2-vkbur
                AND gtype = ls_zf63trnhdr2-gtype
                AND zidvc = ls_zf63trnhdr2-zidvc
                AND gjahr = ls_zf63trnhdr2-gjahr.
        IF sy-subrc EQ 0.
          IF ls_zf63trnhdr2-belnrpadv IS NOT INITIAL.
            p_export = ls_zf63trnhdr2-belnrpadv.
          ENDIF.
        ENDIF.
      ELSE.
        p_export = ls_zf63trnhdr2-belnrpadv.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_SET_UJP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PI_DATA  text
*      -->P_PI_REFERENCE  text
*      <--P_PI_TYPE  text
*      <--P_PI_MESSAGE  text
*      <--P_PI_DOCUMENT  text
*      <--P_PI_EXPORT  text
*----------------------------------------------------------------------*
FORM f_proses_set_ujp  USING    p_data
                                p_reference
                       CHANGING p_type
                                p_message
                                p_document
                                p_export.

  TYPES:
    BEGIN OF ts_settlementdetail,
      gl_type     TYPE string,
      gl_account  TYPE string,
      total       TYPE string,
      description TYPE string,
      makan       TYPE string,
      qty         TYPE string,
      satuan      TYPE string,
      km_start    TYPE string,
      km_end      TYPE string,
      tarif       TYPE string,
      ltr         TYPE string,
      jml_ban     TYPE string,
    END OF ts_settlementdetail .
  TYPES: BEGIN OF ts_detail_shipment,
           shipment_no         TYPE string, " : "",
           year_shipment       TYPE string, ":"",
           shipment_start_date TYPE string, ":""
         END OF ts_detail_shipment.
  TYPES: BEGIN OF ts_post_settlement ,
           transaction_id    TYPE string,
           sales_office      TYPE string,
           deliveryman_idsap TYPE string,
           keterangan        TYPE string,
           posting_date      TYPE string,
           voucher_no_bpv    TYPE string,
           voucher_no_brv    TYPE string,
           vehicle_no        TYPE string,
           total             TYPE string,
           doc_no_ujp_sap    TYPE string,
           year_ujp_sap      TYPE string,
           gl_account        TYPE string,
           voucher_nosap_bpv TYPE string,
           voucher_nosap_brv TYPE string,
           no_doc_sap_bpv    TYPE string,
           no_doc_sap_brv    TYPE string,
           status            TYPE string,
           message           TYPE string,
           detail            TYPE TABLE OF ts_settlementdetail WITH DEFAULT KEY,
           detail_ship       TYPE TABLE OF ts_detail_shipment WITH DEFAULT KEY,
         END OF ts_post_settlement.
  DATA: ls_set_ujp TYPE ts_post_settlement.
  DATA: ls_header TYPE ts_post_settlement.
  DATA: ls_item TYPE ts_settlementdetail.
  DATA: ls_ship TYPE ts_detail_shipment.
  DATA: lt_item TYPE STANDARD TABLE OF ts_settlementdetail.

  DATA : lv_json_data  TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  DATA : zl_json_data TYPE REF TO zcl_trex_json_serializer.
  DATA: ls_zf63trnhdr2 TYPE zf63trnhdr2.
  DATA: ls_zf63trndtl2 TYPE zf63trndtl2.
  DATA: ls_zf63acckasexp TYPE zf63acckasexp.
  DATA: ls_zf63nomor TYPE zf63nomor.
  DATA: lv_transaction_id TYPE zf63trnhdr2-transaction_id.
  DATA: lv_err(1), error_msg(100).
  DATA: lv_spmon TYPE zf63nomor-spmon.
  DATA: lv_nourut TYPE i.
  DATA: lt_zf63tytpeexpdesc TYPE STANDARD TABLE OF zf63tytpeexpdesc.
  DATA: ls_zf63tytpeexpdesc LIKE LINE OF lt_zf63tytpeexpdesc.
  DATA: lt_zf63trnshp2 TYPE STANDARD TABLE OF zf63trnshp2 WITH HEADER LINE.
  DATA: lt_zf63kmhexph TYPE STANDARD TABLE OF zf63kmhexph WITH HEADER LINE.
  DATA: ls_zf63kmhexph TYPE zf63kmhexph .
  DATA: lv_nopol TYPE zf63trndtl2-znopol.
  DATA: lv_no_voucher(50), lv_no_sap(25), lv_text(100).
  lv_json_data = p_data.

  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_set_ujp ).
  IF ls_set_ujp-transaction_id IS NOT INITIAL.
    CLEAR: lv_err, error_msg.
    lv_transaction_id = ls_set_ujp-transaction_id.
    SELECT SINGLE * INTO ls_zf63trnhdr2 FROM zf63trnhdr2
      WHERE transaction_id = lv_transaction_id
        AND gtype = '20'.
    IF sy-subrc EQ 0.
      p_document = ls_zf63trnhdr2-zidvc.
      p_type = 'S'.
      CONCATENATE 'Dokumen tersimpan dengan no. '  ls_zf63trnhdr2-zidvc INTO p_message.
    ELSE.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zf63tytpeexpdesc
        FROM zf63tytpeexpdesc
        WHERE gtype = '24'.
      ls_zf63trnhdr2-transaction_id = lv_transaction_id.
      IF ls_set_ujp-sales_office(2) = '02'.
        ls_zf63trnhdr2-bukrs = '8020'.
      ELSE.
        ls_zf63trnhdr2-bukrs = '8070'.
      ENDIF.
      ls_zf63trnhdr2-gsber = ls_set_ujp-sales_office.
      ls_zf63trnhdr2-vkbur = ls_set_ujp-sales_office.
      ls_zf63trnhdr2-gtype = '20'.
      ls_zf63trnhdr2-gjahr = ls_set_ujp-posting_date(4).
      ls_zf63trnhdr2-hkont = ls_set_ujp-gl_account. "_cashbank.
      CLEAR: lv_err.
      SELECT SINGLE * INTO ls_zf63acckasexp
        FROM zf63acckasexp
        WHERE gsber = ls_zf63trnhdr2-gsber AND
              gtype = ls_zf63trnhdr2-gtype AND
              hkont = ls_zf63trnhdr2-hkont. "gl_account_cashbank
      IF sy-subrc NE 0.
        lv_err =  'E'.
        CONCATENATE ls_zf63trnhdr2-gsber ls_zf63trnhdr2-gtype ls_zf63trnhdr2-hkont INTO error_msg SEPARATED BY '/'.
        CONCATENATE error_msg ' tidak ditemukan di table zf63acckasexp' INTO error_msg.
      ELSE.
        lv_spmon = ls_set_ujp-posting_date(6).
        CLEAR: ls_zf63nomor.
        SELECT SINGLE * INTO ls_zf63nomor FROM zf63nomor
          WHERE bukrs = ls_zf63trnhdr2-bukrs AND
                vkbur = ls_zf63trnhdr2-vkbur AND
                shkzg = 'H' AND
                nmvch = ls_zf63acckasexp-nmvoucher AND
                spmon = lv_spmon.
        IF sy-subrc NE 0.
          lv_err =  'E'.
          CONCATENATE ls_zf63trnhdr2-bukrs ls_zf63trnhdr2-vkbur ls_zf63acckasexp-nmvoucher lv_spmon
             INTO error_msg SEPARATED BY '/'.
          CONCATENATE error_msg ' tidak ditemukan di table zf63nomor' INTO error_msg.
        ELSE.
          ADD 1 TO ls_zf63nomor-nomor.
          MODIFY zf63nomor FROM ls_zf63nomor.
        ENDIF.
        "Format ZIDVC : KDVCH/SPMON/Nomor; cth: CPV/202411/00001"
        "        ADD 1 TO ls_zf63nomor-nomor.
        CONCATENATE ls_zf63nomor-kdvch  ls_zf63nomor-spmon ls_zf63nomor-nomor
        INTO ls_zf63trnhdr2-zidvc SEPARATED BY '/'.

        CLEAR: ls_zf63nomor.
        SELECT SINGLE * INTO ls_zf63nomor FROM zf63nomor
          WHERE bukrs = ls_zf63trnhdr2-bukrs AND
                vkbur = ls_zf63trnhdr2-vkbur AND
                shkzg = 'S' AND
                nmvch = ls_zf63acckasexp-nmvoucher AND
                spmon = lv_spmon.
        IF sy-subrc NE 0.
          lv_err =  'E'.
          CONCATENATE ls_zf63trnhdr2-bukrs ls_zf63trnhdr2-vkbur ls_zf63acckasexp-nmvoucher lv_spmon
             INTO error_msg SEPARATED BY '/'.
          CONCATENATE error_msg ' tidak ditemukan di table zf63nomor' INTO error_msg.
        ELSE.
          ADD 1 TO ls_zf63nomor-nomor.
          MODIFY zf63nomor FROM ls_zf63nomor.
        ENDIF.
        CONCATENATE ls_zf63nomor-kdvch  ls_zf63nomor-spmon ls_zf63nomor-nomor
        INTO ls_zf63trnhdr2-zidvc2 SEPARATED BY '/'.

        ls_zf63trnhdr2-zidno = ls_set_ujp-deliveryman_idsap.  " ambil driver id dan masukkan ke sini ( driver id = vendor id )
        ls_zf63trnhdr2-bktxt  = ls_set_ujp-keterangan.
        ls_zf63trnhdr2-waers = 'IDR'.
        ls_zf63trnhdr2-wrbtr = ls_set_ujp-total / 100.
        ls_zf63trnhdr2-shkzg = 'S'.
***        ls_zf63trnhdr2-REKANAN = ??  --> diisi dengan apa ?
        ls_zf63trnhdr2-ernam = sy-uname. "ls_set_ujp-user_request.
        ls_zf63trnhdr2-erdat = sy-datum.   "ls_set_ujp-date_process. "
        ls_zf63trnhdr2-erzet = sy-uzeit.   "ls_set_ujp-time_process. "
        ls_zf63trnhdr2-xblnradv = ls_set_ujp-voucher_no_brv.
        ls_zf63trnhdr2-budatpadv = ls_set_ujp-posting_date.
        ls_zf63trnhdr2-gjahrpadv = ls_set_ujp-posting_date(4).
        ls_zf63trnhdr2-bldatpadv = ls_set_ujp-posting_date.

        ls_zf63trnhdr2-xblnrexp  = ls_set_ujp-voucher_no_bpv.
        ls_zf63trnhdr2-budatpexp = ls_zf63trnhdr2-budatpadv.
        ls_zf63trnhdr2-bldatpexp = ls_zf63trnhdr2-budatpadv.
        ls_zf63trnhdr2-adv_gjahr = ls_set_ujp-year_ujp_sap. "posting_date(4). "ls_set_ujp-doc_no_ujp_sap_year.
        ls_zf63trnhdr2-adv_belnr = ls_set_ujp-doc_no_ujp_sap. "doc_no_ujp_sap.

        "        ls_zf63trnhdr2-userpost = sy-uname. "ls_set_ujp-nama_kirim_data.
        "        ls_zf63trnhdr2-tglpost = sy-datum.   "ls_set_ujp-tanggal_kirim_data.
        "        ls_zf63trnhdr2-jampost = sy-uzeit.   "ls_set_ujp-tanggal_kirim_data(4).
        ls_zf63trnhdr2-hkont = ls_set_ujp-gl_account.

        MODIFY zf63trnhdr2 FROM ls_zf63trnhdr2.
        lv_nourut = 1.
        LOOP AT ls_set_ujp-detail INTO ls_item..
          ls_zf63trndtl2-bukrs = ls_zf63trnhdr2-bukrs.
          ls_zf63trndtl2-gsber = ls_zf63trnhdr2-gsber.
          ls_zf63trndtl2-vkbur = ls_zf63trnhdr2-vkbur.
          ls_zf63trndtl2-gtype = ls_zf63trnhdr2-gtype.
          ls_zf63trndtl2-zidvc = ls_zf63trnhdr2-zidvc.
          ls_zf63trndtl2-type = ls_item-gl_type.
          ls_zf63trndtl2-buzei = lv_nourut. "ls_zf63trnhdr2-
          ls_zf63trndtl2-menge = ls_item-qty.
          "          ls_zf63trndtl2-SPEED = ls_item-
          ls_zf63trndtl2-kmstr = ls_item-km_start.
          ls_zf63trndtl2-kmend = ls_item-km_end.
          ls_zf63trndtl2-znopol = ls_set_ujp-vehicle_no.
          IF ls_zf63trndtl2-znopol IS NOT INITIAL.
            lv_nopol = ls_zf63trndtl2-znopol.
          ENDIF.
          ls_zf63trndtl2-description = ls_item-description.
          ls_zf63trndtl2-gjahr = ls_zf63trnhdr2-gjahr.
          ls_zf63trndtl2-waers = 'IDR'.
          ls_zf63trndtl2-wrbtr =  ls_item-total / 100.
          ls_zf63trndtl2-tarif =  ls_item-tarif / 100.
          ls_zf63trndtl2-shkzg = 'S'.
          DATA: lv_date TYPE sy-datum.
          lv_date = '20260131'.
          IF ls_zf63trnhdr2-budatpadv <= lv_date.
            ls_zf63trndtl2-wwpos = '035'.
            CONCATENATE '000' ls_zf63trndtl2-gsber+1(3) '0201' INTO ls_zf63trndtl2-kostl.
          ELSE.
            CLEAR: ls_zf63trndtl2-wwpos.
            CONCATENATE '000' ls_zf63trndtl2-gsber+1(3) '0235' INTO ls_zf63trndtl2-kostl.
          ENDIF.
          CLEAR: ls_zf63trndtl2-speed, ls_zf63trndtl2-kmstr, ls_zf63trndtl2-kmend.
          SORT lt_zf63tytpeexpdesc BY type.
          READ TABLE lt_zf63tytpeexpdesc INTO ls_zf63tytpeexpdesc WITH KEY type = ls_zf63trndtl2-type
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            IF ls_zf63tytpeexpdesc-meins IS NOT INITIAL.
              ls_zf63trndtl2-meins = ls_zf63tytpeexpdesc-meins.
            ELSE.
              CLEAR: ls_zf63trndtl2-menge, ls_zf63trndtl2-meins.
            ENDIF.
            IF ls_zf63tytpeexpdesc-speed IS NOT INITIAL.
              IF ls_item-km_end IS NOT INITIAL.
                ls_zf63trndtl2-speed = ls_zf63tytpeexpdesc-speed.
                ls_zf63trndtl2-kmstr = ls_item-km_start.
                ls_zf63trndtl2-kmend = ls_item-km_end.
                ls_zf63kmhexph-bukrs  = ls_zf63trnhdr2-bukrs.
                ls_zf63kmhexph-vkbur  = ls_zf63trnhdr2-vkbur.
                ls_zf63kmhexph-gsber  = ls_zf63trnhdr2-gsber.
                ls_zf63kmhexph-znopol = lv_nopol.
                ls_zf63kmhexph-type   = ls_item-gl_type. "ls_zf63trnhdr2-gtype.
                SELECT SINGLE  MAX( item ) INTO ls_zf63kmhexph-item FROM zf63kmhexph
                   WHERE bukrs  = ls_zf63trnhdr2-bukrs
                      AND vkbur  = ls_zf63trnhdr2-vkbur
                      AND gsber  = ls_zf63trnhdr2-gsber
                      AND znopol = lv_nopol
                      AND type   = ls_zf63kmhexph-type. "ls_zf63trnhdr2-gtype.
                IF sy-subrc EQ 0.
                  ls_zf63kmhexph-item = ls_zf63kmhexph-item + 1.
                ELSE.
                  CLEAR: ls_zf63kmhexph-item.
                ENDIF.
                ls_zf63kmhexph-bldat = ls_zf63trnhdr2-budatpadv.
                ls_zf63kmhexph-speed = ls_zf63tytpeexpdesc-speed.
                ls_zf63kmhexph-kmstr = ls_item-km_start.
                ls_zf63kmhexph-kmend = ls_item-km_end.
                ls_zf63kmhexph-zidvc = ls_zf63trnhdr2-zidvc.
                APPEND ls_zf63kmhexph TO lt_zf63kmhexph.
                MODIFY zf63kmhexph FROM ls_zf63kmhexph.
                CLEAR: ls_zf63kmhexph.
              ENDIF.
            ELSE.
              CLEAR: ls_zf63trndtl2-speed, ls_zf63trndtl2-kmstr, ls_zf63trndtl2-kmend.
            ENDIF.
          ENDIF.
          MODIFY zf63trndtl2 FROM ls_zf63trndtl2.
          ADD 1 TO lv_nourut.
        ENDLOOP.
        LOOP AT ls_set_ujp-detail_ship INTO ls_ship.
          lt_zf63trnshp2-bukrs  = ls_zf63trnhdr2-bukrs.
          lt_zf63trnshp2-gsber  = ls_zf63trnhdr2-gsber.
          lt_zf63trnshp2-vkbur  = ls_zf63trnhdr2-vkbur.
          lt_zf63trnshp2-gtype  = ls_zf63trnhdr2-gtype.
          lt_zf63trnshp2-zidvc  = ls_zf63trnhdr2-zidvc.
          lt_zf63trnshp2-znopol  = lv_nopol.
          lt_zf63trnshp2-tknum  = ls_ship-shipment_no.
          lt_zf63trnshp2-gjahr = ls_ship-year_shipment.
          lt_zf63trnshp2-erdat = ls_ship-shipment_start_date.
          APPEND lt_zf63trnshp2.
          MODIFY zf63trnshp2 FROM lt_zf63trnshp2.
          CLEAR: lt_zf63trnshp2.
        ENDLOOP.
      ENDIF.
      IF lv_err NE 'E'.
        p_type = 'S'.
      ELSE.
        p_type = 'E'.
        p_message = error_msg.
      ENDIF.
    ENDIF.
    IF p_type = 'S'.
      IF ls_zf63trnhdr2-belnrpadv IS INITIAL.
        WAIT UP TO 2 SECONDS.
        SUBMIT zf_jurnal_expv1 WITH pa_bukrs = ls_zf63trnhdr2-bukrs
                                     WITH pa_vkbur = ls_zf63trnhdr2-vkbur
                                    WITH pa_gsber  = ls_zf63trnhdr2-gsber
                                     WITH pa_gtype = ls_zf63trnhdr2-gtype
                                     WITH pa_zidv2 = ls_zf63trnhdr2-zidvc
                                     WITH pa_gjahr = ls_zf63trnhdr2-gjahr
                                     WITH radio6 = 'X'
                                     WITH p_timde6 = 'X'
                                     WITH radio1 =  ' '
                                     WITH radio2 =  ' '
                                     WITH radio3  =  ' '
                                     WITH radio14  =  ' '
                                     WITH radio4  =  ' '
                                     WITH radio15  =  ' '
                                     WITH radio5  =  ' '
                                     WITH radio8  =  ' '
                                     WITH radio17  =  ' '
                                     WITH radio7  =  ' '
                                     WITH radio9  =  ' '
                                     WITH radio10  =  ' '
                                     WITH radio11  =  ' '
                                     WITH radio12  =  ' '
                                     WITH radio13  =  ' ' AND RETURN.

        WAIT UP TO 2 SECONDS.
        SELECT SINGLE belnrpadv belnrpexp INTO (ls_zf63trnhdr2-belnrpadv, ls_zf63trnhdr2-belnrpexp)
          FROM zf63trnhdr2
          WHERE bukrs = ls_zf63trnhdr2-bukrs
                AND vkbur = ls_zf63trnhdr2-vkbur
                AND gtype = ls_zf63trnhdr2-gtype
                AND zidvc = ls_zf63trnhdr2-zidvc
                AND gjahr = ls_zf63trnhdr2-gjahr.
        IF sy-subrc EQ 0.
          IF ls_zf63trnhdr2-belnrpadv IS NOT INITIAL.
            CONCATENATE ls_zf63trnhdr2-zidvc ls_zf63trnhdr2-zidvc2 ls_zf63trnhdr2-belnrpadv ls_zf63trnhdr2-belnrpexp INTO lv_text SEPARATED BY '|'.
            p_export = lv_text.
            p_document = ls_zf63trnhdr2-zidvc.
          ELSE.
            CONCATENATE ls_zf63trnhdr2-zidvc ls_zf63trnhdr2-zidvc2 ls_zf63trnhdr2-belnrpadv ls_zf63trnhdr2-belnrpexp INTO lv_text SEPARATED BY '|'.
            p_export = lv_text.
            p_document = ls_zf63trnhdr2-zidvc.
          ENDIF.
        ENDIF.
      ELSE.
        CONCATENATE ls_zf63trnhdr2-zidvc ls_zf63trnhdr2-zidvc2 ls_zf63trnhdr2-belnrpadv ls_zf63trnhdr2-belnrpexp INTO lv_text SEPARATED BY '|'.
        p_export = lv_text.
        p_document = ls_zf63trnhdr2-zidvc.
      ENDIF.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_POST_SHIPMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PI_DATA  text
*      -->P_PI_REFERENCE  text
*      <--P_PI_TYPE  text
*      <--P_PI_MESSAGE  text
*      <--P_PI_DOCUMENT  text
*      <--P_PI_EXPORT  text
*----------------------------------------------------------------------*
FORM f_proses_post_shipment  USING p_data
                                   p_reference
                       CHANGING p_type
                                p_message
                                p_document
                                p_export.

  TYPES:
    BEGIN OF ts_shipdetail,
      dn_number             TYPE string, "c LENGTH 10,
      status                TYPE string, "c LENGTH 2,
      customer_receive_date TYPE string, "c LENGTH 8,
      customer_receive_time TYPE string, "c LENGTH 8,
    END OF ts_shipdetail ,
    BEGIN OF ts_post_ship ,
      no_shipment         TYPE string, "c LENGTH 10,
      shipment_start_date TYPE string, "c LENGTH 8,
      shipment_start_time TYPE string, "c LENGTH 8,
      shipment_end_date   TYPE string, "c LENGTH 8,
      shipment_end_time   TYPE string, "c LENGTH 8,
      detail              TYPE TABLE OF ts_shipdetail WITH DEFAULT KEY,
    END OF  ts_post_ship .
  DATA: ls_ship TYPE ts_post_ship .
  DATA: ls_detail TYPE ts_shipdetail.
  DATA : lv_json_data  TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  DATA : zl_json_data TYPE REF TO zcl_trex_json_serializer.
  DATA: ls_zmshphist TYPE zmshphist.
  DATA: lt_zmshphist TYPE STANDARD TABLE OF zmshphist.
  DATA: lt_zmm_cust_rec TYPE STANDARD TABLE OF zmm_cust_rec.
  DATA: ls_zmm_cust_rec TYPE zmm_cust_rec.

  DATA : headerdata       LIKE bapishipmentheader,
         headerdataaction LIKE bapishipmentheaderaction,
         return           LIKE bapiret2 OCCURS 0 WITH HEADER LINE.
  DATA : ls_vttk         TYPE vttk,
         lv_message(150),
         lv_status(1),
         lv_tknum        TYPE vttk-tknum,
         lv_datbg        TYPE sy-datum,
         lv_uatbg        TYPE sy-uzeit,
         lv_daten        TYPE sy-datum,
         lv_uaten        TYPE sy-uzeit,
         lv_datab        TYPE sy-datum.
  DATA : lv_error(1).

  lv_json_data = p_data.

  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_ship ).
**      dn_number             TYPE string, "c LENGTH 10,
**      status                TYPE string, "c LENGTH 2,
**      customer_receive_date TYPE string, "c LENGTH 8,
**      customer_receive_time TYPE string, "c LENGTH 8,

  IF ls_ship-no_shipment IS NOT INITIAL.
    CLEAR: lv_error.
    lv_tknum = ls_ship-no_shipment.
    SELECT SINGLE * INTO ls_vttk FROM vttk WHERE tknum = lv_tknum.
    IF sy-subrc EQ 0.
      lv_datbg = ls_ship-shipment_start_date.
      lv_uatbg = ls_ship-shipment_start_time.
      lv_daten = ls_ship-shipment_end_date.
      lv_uaten = ls_ship-shipment_end_time.

      headerdata-shipment_num         = lv_tknum.
      headerdata-status_shpmnt_start  = 'X'.
      headerdata-status_shpmnt_end    = 'X'.

      headerdataaction-status_shpmnt_start = 'C'.
      headerdataaction-status_shpmnt_end   = 'C'.

      CALL FUNCTION 'BAPI_SHIPMENT_CHANGE'
        EXPORTING
          headerdata       = headerdata
          headerdataaction = headerdataaction
        TABLES
          return           = return.

      READ TABLE return WITH KEY type = 'E'.
      IF sy-subrc = 0.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        lv_error  = 'X'.
        RAISE planned_has_not_been_set.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
        CLEAR: lv_error.
        UPDATE vttk SET datbg = lv_datbg
                        uatbg = lv_uatbg
                        daten = lv_daten
                        uaten = lv_uaten
                    WHERE tknum = lv_tknum.

      ENDIF.
      IF lv_error NE 'X'.
        LOOP AT ls_ship-detail INTO ls_detail.
          ls_zmshphist-tknum = ls_ship-no_shipment.
          ls_zmshphist-vbeln = ls_detail-dn_number.
          ls_zmshphist-zreason = ls_detail-status.
          ls_zmshphist-zdate = ls_detail-customer_receive_date.
          ls_zmshphist-ztime = ls_detail-customer_receive_time.
          ls_zmshphist-zuser = sy-uname.
          APPEND ls_zmshphist TO lt_zmshphist.
          MODIFY zmshphist FROM ls_zmshphist.
          SELECT SINGLE * INTO CORRESPONDING FIELDS OF  ls_zmm_cust_rec
            FROM zmm_cust_rec
            WHERE vbeln = ls_zmshphist-vbeln.
          IF sy-subrc EQ 0.
            ls_zmm_cust_rec-predat = ls_zmshphist-zdate.
            ls_zmm_cust_rec-pretim = ls_zmshphist-ztime.
            ls_zmm_cust_rec-datum = sy-datum.
            ls_zmm_cust_rec-uzeit = sy-uzeit.
            ls_zmm_cust_rec-uname = sy-uname.
**            IF ls_zmm_cust_rec-crdat IS INITIAL.
**              ls_zmm_cust_rec-crdat = sy-datum.
**              ls_zmm_cust_rec-crtim = sy-uzeit.
**            ENDIF.
            MODIFY zmm_cust_rec FROM ls_zmm_cust_rec.
          ELSE.
            ls_zmm_cust_rec-vbeln = ls_zmshphist-vbeln.
            ls_zmm_cust_rec-predat = ls_zmshphist-zdate.
            ls_zmm_cust_rec-pretim = ls_zmshphist-ztime.
            ls_zmm_cust_rec-datum = sy-datum.
            ls_zmm_cust_rec-uzeit = sy-uzeit.
            ls_zmm_cust_rec-uname = sy-uname.
            ls_zmm_cust_rec-crdat = sy-datum.
            ls_zmm_cust_rec-crtim = sy-uzeit.
            MODIFY zmm_cust_rec FROM ls_zmm_cust_rec.
          ENDIF.
        ENDLOOP.
**        SORT lt_zmshphist BY vbeln.
**        DELETE ADJACENT DUPLICATES FROM lt_zmshphist COMPARING vbeln.
**        IF lt_zmshphist[] IS NOT INITIAL.
**          SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_zmm_cust_rec
**            FROM zmm_cust_rec
**            FOR ALL ENTRIES IN lt_zmshphist
**            WHERE vbeln = lt_zmshphist-vbeln.
**          IF lt_zmm_cust_rec[] IS NOT INITIAL.
**            SORT lt_zmm_cust_rec BY vbeln.
**            LOOP AT lt_zmm_cust_rec INTO ls_zmm_cust_rec.
**              READ TABLE lt_zmshphist INTO ls_zmshphist WITH KEY vbeln = ls_zmm_cust_rec-vbeln BINARY SEARCH.
**              IF sy-subrc EQ 0.
**                ls_zmm_cust_rec-predat = ls_zmshphist-zdate.
**                ls_zmm_cust_rec-pretim = ls_zmshphist-ztime.
**                MODIFY lt_zmm_cust_rec FROM ls_zmm_cust_rec TRANSPORTING predat pretim.
**                UPDATE zmm_cust_rec SET predat = ls_zmm_cust_rec-predat
**                                        pretim = ls_zmm_cust_rec-pretim
**                    WHERE vbeln = ls_zmm_cust_rec-vbeln.
**              ENDIF.
**            ENDLOOP.
**          ENDIF.
**      ENDIF.
        CONCATENATE 'Ship No.'  lv_tknum 'sukses update di SAP' INTO lv_message SEPARATED BY space.
        lv_status = 'S'.
      ELSE.
        CONCATENATE 'Ship No.'  lv_tknum 'Gagal update di SAP' INTO lv_message SEPARATED BY space.
        lv_status = 'E'.
      ENDIF.
    ELSE.
      CONCATENATE 'Ship No.'  lv_tknum 'Tidak ditemukan di SAP' INTO lv_message SEPARATED BY space.
      lv_status = 'E'.
    ENDIF.
  ENDIF.
  IF lv_status NE 'S'.
    CLEAR: lv_tknum.
  ENDIF.
  p_type = lv_status.
  p_message = lv_message.
  p_document = lv_tknum.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_CANCEL_ADV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PI_DATA  text
*      -->P_PI_REFERENCE  text
*      <--P_PI_TYPE  text
*      <--P_PI_MESSAGE  text
*      <--P_PI_DOCUMENT  text
*      <--P_PI_EXPORT  text
*----------------------------------------------------------------------*
FORM f_proses_cancel_adv  USING p_data
                                p_reference
                       CHANGING p_type
                                p_message
                                p_document
                                p_export.
  TYPES: BEGIN OF ty_cancel_adv,
           transaction_id	      TYPE string,
           voucher_nosap        TYPE string,
           voucher_no           TYPE string,
           sales_office         TYPE string,
           posting_date         TYPE string,
           gl_account           TYPE string,
           no_posting_sap       TYPE string,
           payment_type         TYPE string,
           reference_cancel_adv TYPE string,
           status               TYPE string,
           message              TYPE string,
         END OF ty_cancel_adv.

  DATA: ts_post_cancel_adv TYPE ty_cancel_adv.
  DATA : lv_json_data  TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  DATA : zl_json_data TYPE REF TO zcl_trex_json_serializer.
  DATA: ls_zf63trnhdr2 TYPE zf63trnhdr2.
  DATA: lv_refer TYPE char40,
        lv_date  TYPE sy-datum,
        lv_hkont TYPE hkont.
  lv_json_data = p_data.

  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ts_post_cancel_adv ).
  IF ts_post_cancel_adv-no_posting_sap IS NOT INITIAL.
    lv_refer = ts_post_cancel_adv-reference_cancel_adv.
    lv_date = ts_post_cancel_adv-posting_date.
    lv_hkont = ts_post_cancel_adv-gl_account.
    ls_zf63trnhdr2-zidvc = ts_post_cancel_adv-voucher_nosap.
    ls_zf63trnhdr2-transaction_id = ts_post_cancel_adv-transaction_id.
    ls_zf63trnhdr2-belnrpadv =  ts_post_cancel_adv-no_posting_sap.
    IF ts_post_cancel_adv-sales_office(2) = '02'.
      ls_zf63trnhdr2-bukrs = '8020'.
    ELSE.
      ls_zf63trnhdr2-bukrs = '8070'.
    ENDIF.
    ls_zf63trnhdr2-gsber = ts_post_cancel_adv-sales_office.
    ls_zf63trnhdr2-vkbur = ts_post_cancel_adv-sales_office.
    ls_zf63trnhdr2-gtype = '15'.
    ls_zf63trnhdr2-gjahr = ts_post_cancel_adv-posting_date(4).
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF ls_zf63trnhdr2
      FROM zf63trnhdr2
      WHERE bukrs = ls_zf63trnhdr2-bukrs
        AND vkbur = ls_zf63trnhdr2-vkbur
        AND gtype = ls_zf63trnhdr2-gtype
        AND zidvc = ls_zf63trnhdr2-zidvc
        AND gjahr = ls_zf63trnhdr2-gjahr
        AND belnrpadv = ls_zf63trnhdr2-belnrpadv
        AND transaction_id = ls_zf63trnhdr2-transaction_id.
    IF sy-subrc EQ 0.
      IF ls_zf63trnhdr2-belnrpadvrev IS INITIAL.
        WAIT UP TO 2 SECONDS.
        SUBMIT zf_jurnal_expv1 WITH pa_bukrs = ls_zf63trnhdr2-bukrs
                               WITH pa_vkbur = ls_zf63trnhdr2-vkbur
                               WITH pa_gsber = ls_zf63trnhdr2-bukrs
                               WITH pa_zidv2 = ls_zf63trnhdr2-zidvc
                               WITH pa_belnr = ls_zf63trnhdr2-belnrpadv
                               WITH pa_gtype = ls_zf63trnhdr2-gtype
                               WITH pa_vjahr = ls_zf63trnhdr2-gjahr
                               WITH radio17 = 'X'
                               WITH p_timde7 = 'X'
                               WITH radio6 = ' '
                               WITH radio1 =  ' '
                               WITH radio2 =  ' '
                               WITH radio3  =  ' '
                               WITH radio14  =  ' '
                               WITH radio4  =  ' '
                               WITH radio15  =  ' '
                               WITH radio5  =  ' '
                               WITH radio8  =  ' '
                               WITH radio7  =  ' '
                               WITH radio9  =  ' '
                               WITH radio10  =  ' '
                               WITH radio11  =  ' '
                               WITH radio12  =  ' '
                               WITH radio13  =  ' '
                               WITH c_refer = lv_refer
                               WITH c_date = lv_date
                               WITH c_hkont = lv_hkont AND RETURN.

        "        p_message = 'Lanjut ke proses posting'.
        p_type = 'S'.
        WAIT UP TO 1 SECONDS.
        SELECT SINGLE belnrpadvrev INTO ls_zf63trnhdr2-belnrpadvrev
          FROM zf63trnhdr2
          WHERE bukrs = ls_zf63trnhdr2-bukrs
                AND vkbur = ls_zf63trnhdr2-vkbur
                AND gtype = ls_zf63trnhdr2-gtype
                AND zidvc = ls_zf63trnhdr2-zidvc
                AND belnrpadv = ls_zf63trnhdr2-belnrpadv
                AND gjahr = ls_zf63trnhdr2-gjahr.
        IF sy-subrc EQ 0.
          IF ls_zf63trnhdr2-belnrpadvrev IS NOT INITIAL.
            p_document = ls_zf63trnhdr2-belnrpadvrev.
          ENDIF.
        ENDIF.
      ELSE.
        p_document = ls_zf63trnhdr2-belnrpadvrev.
        p_type = 'S'.
      ENDIF.
    ELSE.
      p_message = 'Data tidak ditemukan'.
      p_type = 'E'.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_MST_DELIVERYMAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PI_DATA  text
*      -->P_PI_REFERENCE  text
*      <--P_PI_TYPE  text
*      <--P_PI_MESSAGE  text
*      <--P_PI_DOCUMENT  text
*      <--P_PI_EXPORT  text
*----------------------------------------------------------------------*
FORM f_proses_mst_deliveryman  USING p_data
                                p_reference
                       CHANGING p_type
                                p_message
                                p_document
                                p_export.
  TYPES: BEGIN OF ty_deliveryman,
           vendor_code       TYPE string,  " C length 10,
           sales_office      TYPE string,  " C length 4,
           vehicle_no        TYPE string,  " C length 10,
           deliveryman_id    TYPE string,  " C length 20,
           deliveryman_name  TYPE string,  " C length 40,
           jenis_vendor      TYPE string,  " C length 40,
           deliveryman_idsap TYPE string,  " C length 10,
           message           TYPE string,  " C length 200,
           status            TYPE string,  " C length 1,
         END OF ty_deliveryman.

  DATA: er_entity TYPE ty_deliveryman.
  DATA : lv_json_data  TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  DATA : zl_json_data TYPE REF TO zcl_trex_json_serializer.
  DATA: gs_zf63masterkend TYPE zf63masterkend.
  DATA: gs_zf63masterperson TYPE zf63masterperson.
  DATA: lv_zidno TYPE zf63masterperson-zidno.
  DATA: lv_message(200), lv_status(1).
  DATA: lv_zidke TYPE zf63masterkend-zidke.

  lv_json_data = p_data.

  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = er_entity ).


  IF er_entity-sales_office(2) = '02'.
    gs_zf63masterperson-bukrs = '8020'.
  ELSE.
    gs_zf63masterperson-bukrs = '8070'.
  ENDIF.
  gs_zf63masterperson-vkbur = er_entity-sales_office.
  gs_zf63masterperson-gsber = er_entity-sales_office.
  gs_zf63masterperson-gtype = '20'.
  CONDENSE: er_entity-vehicle_no, er_entity-deliveryman_id, er_entity-vendor_code.

  gs_zf63masterperson-lifnr = er_entity-vendor_code.
  gs_zf63masterperson-delivery_id = er_entity-deliveryman_id.

  SELECT SINGLE * INTO CORRESPONDING FIELDS OF gs_zf63masterperson
    FROM zf63masterperson
    WHERE lifnr = gs_zf63masterperson-lifnr
      AND delivery_id = gs_zf63masterperson-delivery_id.
  IF sy-subrc NE 0.
    gs_zf63masterperson-name1 = er_entity-deliveryman_name.
    CONCATENATE '000' gs_zf63masterperson-vkbur+1(3) '0201' INTO gs_zf63masterperson-kostl.
    gs_zf63masterperson-wwpos = '035'.
    gs_zf63masterperson-jabatpd = 'Delivery'.
    gs_zf63masterperson-vbund = 'OTHERS'.
    gs_zf63masterperson-jnsvendor = er_entity-jenis_vendor.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = 'ZIDPERSON'
"       subobject               = lv_zidke
      IMPORTING
        number                  = lv_zidno
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc EQ 0.
      lv_status = 'S'.
      gs_zf63masterperson-zidno = lv_zidno.
    ELSE.
      lv_status = 'E'.
    ENDIF.
    gs_zf63masterkend-znopol  =  er_entity-vehicle_no.
    gs_zf63masterkend-bukrs = gs_zf63masterperson-bukrs.
    gs_zf63masterkend-vkbur = gs_zf63masterperson-vkbur.
    CLEAR: lv_zidke.
    SELECT SINGLE zidke INTO lv_zidke FROM zf63masterkend
      WHERE znopol = gs_zf63masterkend-znopol.
    gs_zf63masterperson-zidke = lv_zidke.
    "          MODIFY zf63masterperson FROM gs_zf63masterperson.
  ELSE.
    gs_zf63masterperson-name1 = er_entity-deliveryman_name.
    gs_zf63masterperson-jnsvendor = er_entity-jenis_vendor.
    gs_zf63masterkend-znopol  =  er_entity-vehicle_no.
    gs_zf63masterkend-bukrs = gs_zf63masterperson-bukrs.
    gs_zf63masterkend-vkbur = gs_zf63masterperson-vkbur.
    CLEAR: lv_zidke.
    SELECT SINGLE zidke INTO lv_zidke FROM zf63masterkend
      WHERE znopol = gs_zf63masterkend-znopol.

    gs_zf63masterperson-zidke = lv_zidke.
    lv_status = 'S'.
  ENDIF.

  IF lv_status NE 'E'.
    er_entity-deliveryman_idsap = gs_zf63masterperson-zidno.
    MODIFY zf63masterperson FROM gs_zf63masterperson.
    IF sy-subrc EQ 0.
      CONCATENATE 'Delivery id. ' er_entity-deliveryman_id ' Berhasil di update dengan id sap'
      er_entity-deliveryman_idsap INTO lv_message SEPARATED BY space.
    ELSE.
      lv_status = 'E'.
      CONCATENATE 'Delivery id. ' er_entity-deliveryman_id ' Gagal Proses Cek SNRO IDPERSON'
      er_entity-deliveryman_idsap INTO lv_message SEPARATED BY space.
    ENDIF.
  ENDIF.
  er_entity-status = lv_status.
  er_entity-message = lv_message.

  p_type = lv_status.
  p_message = lv_message.
  p_document = er_entity-deliveryman_idsap.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_MST_VEHICLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PI_DATA  text
*      -->P_PI_REFERENCE  text
*      <--P_PI_TYPE  text
*      <--P_PI_MESSAGE  text
*      <--P_PI_DOCUMENT  text
*      <--P_PI_EXPORT  text
*----------------------------------------------------------------------*
FORM f_proses_mst_vehicle  USING p_data
                                p_reference
                       CHANGING p_type
                                p_message
                                p_document
                                p_export.
  TYPES: BEGIN OF ty_vehicle,
           vendor_code  TYPE string,  " C length 10,
           sales_office TYPE string,  " C length 4,
           vehicle_no   TYPE string,  " C length 10,
           vehicle_name TYPE string,  " C length 20,
           chassis_no   TYPE string,  " C length 20,
           vehicle_type TYPE string,  " TYPE string,  " C length 20,
           is_active    TYPE string,  " C length 1,
           vehicle_id   TYPE string,  " C length 10,
           message      TYPE string,  " C length 200,
           status       TYPE string,  " C length 1,
         END OF ty_vehicle.

  DATA: er_entity TYPE ty_vehicle.
  DATA : lv_json_data  TYPE string.
  DATA: lv_nama(15).
  DATA: lv_str TYPE string.
  DATA : zl_json_data TYPE REF TO zcl_trex_json_serializer.
  DATA: gs_zf63masterkend TYPE zf63masterkend.
  DATA: lv_zidke TYPE zf63masterkend-zidke.
  DATA: lv_message(200), lv_status(1).

  lv_json_data = p_data.

  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = er_entity ).
  CONDENSE er_entity-vehicle_no.
  gs_zf63masterkend-znopol = er_entity-vehicle_no.
  lv_message = gs_zf63masterkend-znopol.
  IF gs_zf63masterkend-znopol IS NOT INITIAL.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF gs_zf63masterkend
      FROM zf63masterkend
      WHERE znopol = gs_zf63masterkend-znopol.
    "and gtype = '20'.
    IF sy-subrc EQ 0.
      SELECT SINGLE MAX( buzei ) INTO gs_zf63masterkend-buzei
        FROM zf63masterkend
        WHERE znopol = gs_zf63masterkend-znorangka
          AND bukrs = gs_zf63masterkend-bukrs
          AND vkbur = gs_zf63masterkend-vkbur
          AND gsber = gs_zf63masterkend-gsber
          AND zidke = gs_zf63masterkend-zidke.
      gs_zf63masterkend-buzei = gs_zf63masterkend-buzei + 10.
      lv_status = 'U'.
      gs_zf63masterkend-vkbur = er_entity-sales_office.
      gs_zf63masterkend-gsber = er_entity-sales_office.
      IF er_entity-sales_office(2) = '02'.
        gs_zf63masterkend-bukrs = '8020'.
      ELSE.
        gs_zf63masterkend-bukrs = '8070'.
      ENDIF.
      gs_zf63masterkend-znorangka = er_entity-chassis_no.
      gs_zf63masterkend-jnskend = er_entity-vehicle_type.
      gs_zf63masterkend-txt50 = er_entity-vehicle_name.
      gs_zf63masterkend-gtype = '20'.
      gs_zf63masterkend-znopol = er_entity-vehicle_no.
      CONCATENATE 'No.' lv_message 'Sdh ada Vehicle id :' gs_zf63masterkend-zidke
          INTO lv_message SEPARATED BY space.
      IF er_entity-is_active = 'N'.
        gs_zf63masterkend-zaktif = 'X'.
      ELSE.
        CLEAR: gs_zf63masterkend-zaktif.
      ENDIF.
    ELSE.
      lv_status = 'A'.
      gs_zf63masterkend-buzei = '010'.
      gs_zf63masterkend-vkbur = er_entity-sales_office.
      IF er_entity-sales_office(2) = '02'.
        gs_zf63masterkend-bukrs = '8020'.
      ELSE.
        gs_zf63masterkend-bukrs = '8070'.
      ENDIF.
      gs_zf63masterkend-gsber = er_entity-sales_office.
      gs_zf63masterkend-znorangka = er_entity-chassis_no.
      gs_zf63masterkend-jnskend = er_entity-vehicle_type.
      gs_zf63masterkend-txt50 = er_entity-vehicle_name.
      gs_zf63masterkend-gtype = '20'.
      gs_zf63masterkend-znopol = er_entity-vehicle_no.
      IF er_entity-is_active = 'N'.
        gs_zf63masterkend-zaktif = 'X'.
      ELSE.
        CLEAR: gs_zf63masterkend-zaktif.
      ENDIF.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr             = '01'
          object                  = 'ZIDKEND'
"         subobject               = lv_zidke
        IMPORTING
          number                  = lv_zidke
        EXCEPTIONS
          interval_not_found      = 1
          number_range_not_intern = 2
          object_not_found        = 3
          quantity_is_0           = 4
          quantity_is_not_1       = 5
          interval_overflow       = 6
          buffer_overflow         = 7
          OTHERS                  = 8.
      IF sy-subrc EQ 0.
        gs_zf63masterkend-zidke = lv_zidke.
        CONCATENATE 'No.' lv_message 'Vehicle id ' gs_zf63masterkend-zidke
            INTO lv_message SEPARATED BY space.
      ELSE.
        lv_status = 'E'.
        CONCATENATE 'No.' lv_message ' tidak berhasil terbentuk di SAP (Mohon cek SNRO ZIDKEND)'
            INTO lv_message SEPARATED BY space.
      ENDIF.
    ENDIF.
    er_entity-vehicle_id = gs_zf63masterkend-zidke.
    IF gs_zf63masterkend-zidke IS NOT INITIAL AND lv_status NE 'E'.
      MODIFY zf63masterkend FROM gs_zf63masterkend.
      IF sy-subrc EQ 0.
        CONCATENATE lv_message 'Berhasil disimpan di SAP'
            INTO lv_message SEPARATED BY space.
      ELSE.
        CONCATENATE lv_message 'Gagal disimpan di SAP'
            INTO lv_message SEPARATED BY space.
        lv_status = 'E'.
      ENDIF.
    ENDIF.
    er_entity-message = lv_message.
    er_entity-status = lv_status.
  ENDIF.

  p_type = lv_status.
  p_message = lv_message.
  p_document = gs_zf63masterkend-zidke.


ENDFORM.
