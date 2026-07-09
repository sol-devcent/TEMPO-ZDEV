*----------------------------------------------------------------------*
***INCLUDE LZTDS_APIF03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_TIARA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_GV_EVENT  text
*      <--P_ZDATA  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_proses_tiara  CHANGING p_zproses
                              p_event
                              p_zdata
                              p_status.

  DATA: lv_user TYPE zusweb.
  DATA: lv_vkbur TYPE gsber,
        lv_nomor TYPE znomor_ar,
        l_len    TYPE i, l_pos TYPE i.
  DATA: lt_ztdsitdt006 TYPE STANDARD TABLE OF ztdsitdt006 WITH HEADER LINE.
  DATA: ls_ztdsitdt006 TYPE ztdsitdt006.
  p_status = 'S'.
  CONDENSE p_zdata.
  ls_ztdsitdt006-zproses = 'TIARA'.
  ls_ztdsitdt006-zevent = p_event.
  ls_ztdsitdt006-zdata = p_zdata.
  ls_ztdsitdt006-erdat = sy-datum.
  ls_ztdsitdt006-ernam = sy-uname.
  ls_ztdsitdt006-erzet = sy-uzeit.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.
  p_status = 'S'.
  CLEAR: lv_user.
  CASE p_event.
    WHEN 'TIA_REJECT'.
      CONDENSE p_zdata.
      l_len = strlen( p_zdata ).
      lv_vkbur = p_zdata(4).
      l_pos = l_len - 4.
      lv_nomor = p_zdata+4(l_pos).
      SUBMIT ztiara_in0003 WITH  p_gsber = lv_vkbur
                           WITH  p_nomor = lv_nomor
                           WITH  p_check = space
                      AND RETURN.
    WHEN 'TIA_USER'.
      CONDENSE p_zdata.
      lv_user = p_zdata.
      SUBMIT ztiara_in0001 WITH  p_user = lv_user
                      AND RETURN.
    WHEN 'TIA_GETAR'.
      CONDENSE p_zdata.
      l_len = strlen( p_zdata ).
      lv_vkbur = p_zdata(4).
      l_pos = l_len - 4.
      lv_nomor = p_zdata+4(l_pos).
      SUBMIT ztiara_in0002 WITH  p_gsber = lv_vkbur
                           WITH  p_nomor = lv_nomor
                      AND RETURN.
    WHEN OTHERS.
      p_status = 'E'.
  ENDCASE.
ENDFORM.                    " F_PROSES_TIARA
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_ODOO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_GV_EVENT  text
*      <--P_ZDATA  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_proses_odoo  CHANGING p_zproses
                             p_event
                             p_zdata
                             p_status.
  DATA: lv_user TYPE zusweb.
  DATA: lv_vkbur TYPE gsber,
        lv_nomor TYPE znomor_ar,
        l_len    TYPE i, l_pos TYPE i.
  DATA: lt_ztdsitdt006 TYPE STANDARD TABLE OF ztdsitdt006 WITH HEADER LINE.
  DATA: ls_ztdsitdt006 TYPE ztdsitdt006.
  p_status = 'S'.
  CONDENSE p_zdata.
  ls_ztdsitdt006-zproses = 'DISKON'.
  ls_ztdsitdt006-zevent = p_event.
  ls_ztdsitdt006-zdata = p_zdata.
  ls_ztdsitdt006-erdat = sy-datum.
  ls_ztdsitdt006-ernam = sy-uname.
  ls_ztdsitdt006-erzet = sy-uzeit.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.
  p_status = 'S'.
  CLEAR: lv_user.
  CASE p_event.
    WHEN 'ODOO_PR'.
      CONDENSE p_zdata.
      p_zdata = 'Mess: Testing PR done - tidak digunakan'.
      p_status = 'S'.
    WHEN 'ODOO_GR'.
      CONDENSE p_zdata.
      p_zdata = 'Mess: Testing GR done - tidak digunakan'.
      p_status = 'S'.
    WHEN OTHERS.
      p_zdata = 'Err: Zevent'.
      p_status = 'E'.
  ENDCASE.
ENDFORM.                    " F_PROSES_ODOO
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_EPROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_GV_EVENT  text
*      <--P_ZDATA  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_proses_eproc  CHANGING p_zproses
                             p_event
                             p_zdata
                             p_status
                             p_message.
  TABLES zhsmmmdt003.
  DATA: ls_zhsmmmdt003 TYPE zhsmmmdt003.
  DATA: lt_ztdsitdt006 TYPE STANDARD TABLE OF ztdsitdt006 WITH HEADER LINE.
  DATA: ls_ztdsitdt006 TYPE ztdsitdt006.
  DATA: lv_message(255).
  p_status = 'S'.
  CONDENSE p_zdata.
  ls_ztdsitdt006-zproses = 'EPROC'.
  ls_ztdsitdt006-zevent = p_event.
  ls_ztdsitdt006-zdata = p_zdata.
  ls_ztdsitdt006-erdat = sy-datum.
  ls_ztdsitdt006-ernam = sy-uname.
  ls_ztdsitdt006-erzet = sy-uzeit.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.

  p_status = 'S'.
  CASE p_event.
    WHEN 'HSM_QOUT'.
      CONDENSE p_zdata.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = 'EPROC_QUOT'
        EXCEPTIONS
          bad_eventid            = 1 " eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      "OTHERS                 = 5.
      ls_zhsmmmdt003-zproses =  p_event.
      ls_zhsmmmdt003-zdata = p_zdata.
      ls_zhsmmmdt003-erdat = sy-datum.
      ls_zhsmmmdt003-ernam = sy-uname.
      ls_zhsmmmdt003-erzet = sy-uzeit.
      MODIFY zhsmmmdt003 FROM ls_zhsmmmdt003.
      COMMIT WORK.
    WHEN OTHERS.
      CONCATENATE 'Err: ' p_event ' not found' INTO p_zdata.
      CONCATENATE 'Err: ' p_event ' not found' INTO lv_message.
      p_message = lv_message.
      "      p_zdata = 'Err: Zevent'.
      p_status = 'E'.
  ENDCASE.
ENDFORM.                    " F_PROSES_EPROC
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_NEW_TDN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_GV_EVENT  text
*      <--P_ZDATA  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_proses_new_tdn  CHANGING p_zproses
                             p_event
                             p_zdata
                             p_status
                             p_message.
  DATA: lt_ztdsitdt006 TYPE STANDARD TABLE OF ztdsitdt006 WITH HEADER LINE.
  DATA: ls_ztdsitdt006 TYPE ztdsitdt006.
  DATA: ls_ztdnsddt023 TYPE ztdnsddt023.
  DATA: lv_phone(15), lv_no_order TYPE char25.
  DATA: lv_status(1), lv_message(100), lv_sap_id TYPE kunnr.
  DATA: lv_event TYPE char40.
  DATA: lv_low LIKE tvarvc-low.
  DATA: lv_proses(10), lv_market(15), ld_mess(100).
  DATA: BEGIN OF lt_material OCCURS 0.
          INCLUDE STRUCTURE mara.
        DATA: END OF lt_material.
  lv_market = p_event.
  p_status = 'P'.
  lv_proses = p_event.


  p_status = 'S'.
  CONDENSE p_zdata.
  ls_ztdsitdt006-zproses = 'TDN'.
  ls_ztdsitdt006-zevent = p_event.
  ls_ztdsitdt006-zdata = p_zdata.
  ls_ztdsitdt006-erdat = sy-datum.
  ls_ztdsitdt006-ernam = sy-uname.
  ls_ztdsitdt006-erzet = sy-uzeit.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.
  CLEAR: lv_message.
  p_status = 'S'.
  CASE p_event.
    WHEN 'TDN_CREATECUST'.
      CONDENSE p_zdata.
      lv_no_order = p_zdata.
      CALL FUNCTION 'ZTDNSD_F0004'
        EXPORTING
          proses   = p_event
          no_order = lv_no_order " phone_number = lv_phone
          api      = 'X'
"          PATHNAME = '/inbound/tdn/customer/customer_trd.json'
        IMPORTING
          sap_id   = lv_sap_id
          status   = lv_status
          message  = lv_message.
       p_message = lv_message.
       p_zdata = lv_message.
      "OTHERS                 = 5.
    WHEN 'TDN_AWBIMAGE'.
      lv_event = p_event.
      ls_ztdnsddt023-zproses = 'TDN'.
      ls_ztdnsddt023-zevent = p_event.
      ls_ztdnsddt023-zdata = p_zdata.
      ls_ztdnsddt023-erdat = sy-datum.
      ls_ztdnsddt023-ernam = sy-uname.
      ls_ztdnsddt023-erzet = sy-uzeit.
      MODIFY ztdnsddt023 FROM ls_ztdnsddt023.

      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = lv_event "'ZACC_AGGR'
        EXCEPTIONS
          bad_eventid            = 1 " eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      IF sy-subrc EQ 0.
        p_status = 'S'.
      ELSE.
        CONCATENATE 'Err: ' p_event 'Gagal Create Event' INTO p_zdata.
        CONCATENATE 'Err: ' p_event 'Gagal Create Event' INTO lv_message.
        p_message = lv_message.
        p_status = 'E'.
      ENDIF.
    WHEN 'TDN_APIGL'.
      lv_event = p_event.
      ls_ztdnsddt023-zproses = 'TDN'.
      ls_ztdnsddt023-zevent = p_event.
      ls_ztdnsddt023-zdata = p_zdata.
      ls_ztdnsddt023-erdat = sy-datum.
      ls_ztdnsddt023-ernam = sy-uname.
      ls_ztdnsddt023-erzet = sy-uzeit.
      MODIFY ztdnsddt023 FROM ls_ztdnsddt023.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = lv_event "'ZACC_AGGR'
        EXCEPTIONS
          bad_eventid            = 1 " eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      IF sy-subrc EQ 0.
        p_status = 'S'.
      ELSE.
        CONCATENATE 'Err: ' p_event 'Gagal Create' INTO p_zdata.
        CONCATENATE 'Err: ' p_event 'Gagal Create Event' INTO lv_message.
        p_message = lv_message.
        p_status = 'E'.
      ENDIF.

    WHEN 'TDN_APIGLSHOPEE'.
      lv_event = p_event.
      ls_ztdnsddt023-zproses = 'TDN'.
      ls_ztdnsddt023-zevent = p_event.
      ls_ztdnsddt023-zdata = p_zdata.
      ls_ztdnsddt023-erdat = sy-datum.
      ls_ztdnsddt023-ernam = sy-uname.
      ls_ztdnsddt023-erzet = sy-uzeit.
      MODIFY ztdnsddt023 FROM ls_ztdnsddt023.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = lv_event "'ZACC_AGGR'
        EXCEPTIONS
          bad_eventid            = 1 " eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      IF sy-subrc EQ 0.
        p_status = 'S'.
      ELSE.
        CONCATENATE 'Err: ' p_event 'Gagal Create' INTO p_zdata.
        CONCATENATE 'Err: ' p_event 'Gagal Create Event' INTO lv_message.
        p_message = lv_message.
        p_status = 'E'.
      ENDIF.
    WHEN 'TDN_APIGLTIKTOK'.
      lv_event = p_event.
      ls_ztdnsddt023-zproses = 'TDN'.
      ls_ztdnsddt023-zevent = p_event.
      ls_ztdnsddt023-zdata = p_zdata.
      ls_ztdnsddt023-erdat = sy-datum.
      ls_ztdnsddt023-ernam = sy-uname.
      ls_ztdnsddt023-erzet = sy-uzeit.
      MODIFY ztdnsddt023 FROM ls_ztdnsddt023.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = lv_event "'ZACC_AGGR'
        EXCEPTIONS
          bad_eventid            = 1 " eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      IF sy-subrc EQ 0.
        p_status = 'S'.
      ELSE.
        CONCATENATE 'Err: ' p_event 'Gagal Create' INTO p_zdata.
        CONCATENATE 'Err: ' p_event 'Gagal Create Event' INTO lv_message.
        p_message = lv_message.
        p_status = 'E'.
      ENDIF.

    WHEN 'TDN_APIGLTOKPED'.
      lv_event = p_event.
      ls_ztdnsddt023-zproses = 'TDN'.
      ls_ztdnsddt023-zevent = p_event.
      ls_ztdnsddt023-zdata = p_zdata.
      ls_ztdnsddt023-erdat = sy-datum.
      ls_ztdnsddt023-ernam = sy-uname.
      ls_ztdnsddt023-erzet = sy-uzeit.
      MODIFY ztdnsddt023 FROM ls_ztdnsddt023.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = lv_event "'ZACC_AGGR'
        EXCEPTIONS
          bad_eventid            = 1 " eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      IF sy-subrc EQ 0.
        p_status = 'S'.
      ELSE.
        CONCATENATE 'Err: ' p_event 'Gagal Create' INTO p_zdata.
        CONCATENATE 'Err: ' p_event 'Gagal Create Event' INTO lv_message.
        p_message = lv_message.
        p_status = 'E'.
      ENDIF.
    WHEN 'TDN_ORDER'.
      p_status = 'S'.
      SELECT SINGLE low INTO lv_low FROM tvarvc WHERE name = 'ZTDNSD_I006'.
      IF sy-subrc EQ 0 AND lv_low = 'X'.
        SUBMIT ztdnsd_i006  WITH p_proses = 'TDN_ORDER'
                            AND RETURN.
      ELSE.
        lv_market = 'SHOPEE'.
        CALL FUNCTION 'ZBP_EVENT_RAISE'
          EXPORTING
            eventid                = 'TDN_ORDER'
          EXCEPTIONS
            bad_eventid            = 1 " eventparm = gv_EVENTPARM
            eventid_does_not_exist = 2
            eventid_missing        = 3
            raise_failed           = 4.
        IF sy-subrc EQ 0.
          p_status = 'S'.
        ELSE.
          CONCATENATE 'Err: ' p_event 'Gagal Create Event' INTO p_zdata.
          CONCATENATE 'Err: ' p_event 'Gagal Create Event' INTO lv_message.
          p_message = lv_message.
          p_status = 'E'.
        ENDIF.
      ENDIF.
**    WHEN 'TDN_LAZADA'.
**      lv_market = 'LAZADA'.
**      SUBMIT ztdnsd_i006  WITH p_proses = lv_proses
**                          WITH p_market = lv_market
**                          AND RETURN.
    WHEN 'TDN_STATUS'.
      lv_market = 'STATUS'.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = 'TDN_STATUS'
        EXCEPTIONS
          bad_eventid            = 1 " eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      IF sy-subrc EQ 0.
        p_status = 'S'.
      ELSE.
        CONCATENATE 'Err: ' p_event 'Gagal Create Event' INTO p_zdata.
        CONCATENATE 'Err: ' p_event 'Gagal Create Event' INTO lv_message.
        p_message = lv_message.
        p_status = 'E'.
      ENDIF.
    WHEN 'TDN_GETAWB'.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = 'TDN_GETAWB'
        EXCEPTIONS
          bad_eventid            = 1 " eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      IF sy-subrc EQ 0.
        p_status = 'S'.
      ELSE.
        CONCATENATE 'Err: ' p_event ' Gagal Create Event' INTO p_zdata.
        CONCATENATE 'Err: ' p_event 'Gagal Create Event' INTO lv_message.
        p_message = lv_message.
        p_status = 'E'.
      ENDIF.
    WHEN 'TDN_CANCEL'.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = 'TDN_CANCEL'
        EXCEPTIONS
          bad_eventid            = 1 " eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      IF sy-subrc EQ 0.
        p_status = 'S'.
      ELSE.
        CONCATENATE 'Err: ' p_event ' Gagal Create Event' INTO p_zdata.
        CONCATENATE 'Err: ' p_event 'Gagal Create Event' INTO lv_message.
        p_message = lv_message.
        p_status = 'E'.
      ENDIF.
    WHEN 'TDN_SHIP'.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = 'TDN_SHIP'
        EXCEPTIONS
          bad_eventid            = 1 " eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      IF sy-subrc EQ 0.
        p_status = 'S'.
      ELSE.
        CONCATENATE 'Err: ' p_event ' Gagal Create Event' INTO p_zdata.
        CONCATENATE 'Err: ' p_event 'Gagal Create Event' INTO lv_message.
        p_message = lv_message.
        p_status = 'E'.
      ENDIF.
    WHEN 'TDN_TSHD'.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = 'TDN_TSHD'
        EXCEPTIONS
          bad_eventid            = 1 " eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      IF sy-subrc EQ 0.
        p_status = 'S'.
      ELSE.
        CONCATENATE 'Err: ' p_event ' Gagal Create Event' INTO p_zdata.
        CONCATENATE 'Err: ' p_event 'Gagal Create Event' INTO lv_message.
        p_message = lv_message.
        p_status = 'E'.
      ENDIF.
    WHEN 'TDN_TRD'.
      p_status = 'S'.
      CALL FUNCTION 'ZTDNSD_F0003'
        EXPORTING
          proses       = 'TDN_TRD'
          sales_office = '3800'
          periode      = '2022'
          api          = 'X'
        IMPORTING
          status       = p_status
          message      = ld_mess
        TABLES
          t_material   = lt_material.
      p_message = ld_mess.
    WHEN OTHERS.
      CONCATENATE 'Err: ' p_event ' not found' INTO p_zdata.
      CONCATENATE 'Err: ' p_event ' not found' INTO lv_message.
      p_message = lv_message.
      p_status = 'E'.
  ENDCASE.
  ls_ztdsitdt006-status = p_status.
  ls_ztdsitdt006-message = p_message.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.

ENDFORM.                    " F_PROSES_NEW_TDN
