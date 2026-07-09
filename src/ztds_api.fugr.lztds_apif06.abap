*----------------------------------------------------------------------*
***INCLUDE LZTDS_APIF06 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_TMART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_GV_EVENT  text
*      <--P_ZDATA  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_proses_tmart  CHANGING p_zproses
                             p_event
                             p_zdata
                             p_status.
  DATA: lt_ztdsitdt006 TYPE STANDARD TABLE OF ztdsitdt006 WITH HEADER LINE.
  DATA: ls_ztdsitdt006 TYPE ztdsitdt006.
  DATA: lv_phone(15), lv_no_order TYPE char25, lv_exti1 TYPE exti1.
  DATA: lv_status(1), lv_message(100), lv_sap_id TYPE kunnr.
  DATA: lv_belnr(10).
  DATA: lv_event TYPE char40.
  DATA: lv_vbeln TYPE vbeln_vl.
  DATA: lv_wbstk LIKE vbuk-wbstk.
  DATA : header_data    LIKE bapiobdlvhdrchg,
         header_control LIKE bapiobdlvhdrctrlchg,
         techn_control  LIKE bapidlvcontrol,
         delivery       TYPE bapishpdelivnumb-deliv_numb,
         return         LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

  p_status = 'S'.
  CONDENSE p_zdata.
  ls_ztdsitdt006-zproses = 'TMART'.
  ls_ztdsitdt006-zevent = p_event.
  ls_ztdsitdt006-zdata = p_zdata.
  ls_ztdsitdt006-erdat = sy-datum.
  ls_ztdsitdt006-ernam = sy-uname.
  ls_ztdsitdt006-erzet = sy-uzeit.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.
  CLEAR: lv_message.
  p_status = 'S'.
  CASE p_event.
    WHEN 'TMART_EVOUCHER'.
      p_status = 'S'.
      CONDENSE p_zdata.
      lv_no_order = p_zdata.
      CONCATENATE p_event 'success trigger' INTO p_zdata.
      CALL FUNCTION 'ZTDNSD_F0006'
        EXPORTING
          no_order = lv_no_order " phone_number = lv_phone
        IMPORTING
          belnr    = lv_belnr
          status   = lv_status
          message  = lv_message.
      p_zdata = lv_message.
      p_status = lv_status.

    WHEN 'TMART_STATUS'.
      p_status = 'S'.
      CONDENSE p_zdata.
      lv_no_order = p_zdata.
      CONCATENATE p_event 'success trigger' INTO p_zdata.
      CALL FUNCTION 'ZTDNSD_F0007'
        EXPORTING
          no_order = lv_no_order " phone_number = lv_phone
        IMPORTING
          status   = lv_status
          message  = lv_message.
      p_zdata = lv_message.
      p_status = lv_status.
    WHEN 'TMART_CANCEL'.
      CLEAR: lv_wbstk, lv_vbeln.
      p_status = 'S'.
      CONDENSE p_zdata.
      lv_vbeln = p_zdata.
      SELECT SINGLE wbstk INTO lv_wbstk FROM vbuk WHERE vbeln = lv_vbeln. " and wbstk ne 'C'.
      IF lv_wbstk NE 'C'.
        header_data-deliv_numb    = lv_vbeln.
        header_data-dlv_block = 'ZT'.
        header_control-deliv_numb = lv_vbeln.
        header_control-dlv_block_flg = 'X'.
        delivery                  = lv_vbeln.
        techn_control-upd_ind     = 'U'.
        CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
          EXPORTING
            header_data    = header_data
            header_control = header_control
            delivery       = delivery
            techn_control  = techn_control
          TABLES
            return         = return.
        BREAK tds_dev01.
        READ TABLE return WITH KEY type = 'E'.
        IF sy-subrc = 0.
          LOOP AT return.
            IF return-id = 'VL' AND
              return-number = '198'.
              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            ELSE.
              p_status = 'E'.
              lv_message = p_zdata = return-message.
            ENDIF.
          ENDLOOP.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.
          p_zdata = 'Sukses'.
        ENDIF.
      ELSE.
        p_zdata = 'DN sudah GI'.
        p_status = 'S'.
      ENDIF.
    WHEN 'TMART_SHIP'.
      lv_event = p_event.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = lv_event "'TMART_SHIP'
        EXCEPTIONS
          bad_eventid            = 1
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      IF sy-subrc EQ 0.
        CONCATENATE p_event 'success trigger' INTO lv_message.
        p_status = 'S'.
      ELSE.
        CONCATENATE 'Err: ' p_event ' Gagal Create' INTO lv_message.
        p_status = 'E'.
      ENDIF.

    WHEN 'TMART_SHIPSTART'.
      " Call function untuk membuat shipment start

      p_status = 'S'.
      CONDENSE p_zdata.
      lv_exti1 = p_zdata.
"      CONCATENATE p_event 'success trigger' INTO p_zdata.
      CALL FUNCTION 'ZTDNSD_F0008'
        EXPORTING
          no_shipment = lv_exti1 " phone_number = lv_phone
        IMPORTING
          status      = lv_status
          message     = lv_message.
      p_zdata = lv_message.
      p_status = lv_status.

**      CONCATENATE 'Err: ' p_event ' Belum diImplementasi' INTO p_zdata.
**      p_status = 'E'.

    WHEN OTHERS.
      CONCATENATE 'Err: ' p_event ' not found' INTO p_zdata.
      p_status = 'E'.
  ENDCASE.

  ls_ztdsitdt006-status = p_status.
  ls_ztdsitdt006-message = lv_message.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.

ENDFORM.                    " F_PROSES_TMART
