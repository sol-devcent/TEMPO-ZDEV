*----------------------------------------------------------------------*
***INCLUDE LZTDS_APIF02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_TDN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_GV_EVENT  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_proses_tdn  CHANGING p_proses
                            p_event
                            p_status.
  DATA: lv_proses(10), lv_market(15), ld_mess(100).
  DATA: BEGIN OF lt_material OCCURS 0.
          INCLUDE STRUCTURE mara.
  DATA: END OF lt_material.
  DATA: lv_low LIKE tvarvc-low.
  lv_market = p_event.
  p_status = 'P'.
  lv_proses = p_event.
  CASE p_event.
    WHEN 'TDN_ORDER'.
      SELECT SINGLE low INTO lv_low FROM tvarvc WHERE name = 'ZTDNSD_I006'.
      IF sy-subrc EQ 0 and lv_low = 'X'.
        SUBMIT ztdnsd_i006  WITH p_proses = lv_proses
                            "WITH p_market = lv_market
                            AND RETURN.
      ELSE.
        lv_market = 'SHOPEE'.
        CALL FUNCTION 'ZBP_EVENT_RAISE'
          EXPORTING
            eventid                = 'TDN_ORDER'
          EXCEPTIONS
            bad_eventid            = 1" eventparm = gv_EVENTPARM
            eventid_does_not_exist = 2
            eventid_missing        = 3
            raise_failed           = 4.
      ENDIF.
      p_status = 'S'.
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
          bad_eventid            = 1" eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.

**      SUBMIT ztdnsd_i009  WITH p_proses = lv_proses
**                          AND RETURN.
      p_status = 'S'.
    WHEN 'TDN_GETAWB'.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = 'TDN_GETAWB'
        EXCEPTIONS
          bad_eventid            = 1" eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.

***      SUBMIT ztdnsd_i011 AND RETURN. "  WITH p_proses = lv_proses
      p_status = 'S'.
    WHEN 'TDN_CANCEL'.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = 'TDN_CANCEL'
        EXCEPTIONS
          bad_eventid            = 1" eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
**      SUBMIT ztdnsd_i014 WITH p_proses = lv_proses
**                          AND RETURN.
      p_status = 'S'.
    WHEN 'TDN_SHIP'.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = 'TDN_SHIP'
        EXCEPTIONS
          bad_eventid            = 1" eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
**      SUBMIT ztdnsd_i014 WITH p_proses = lv_proses
**                          AND RETURN.
      p_status = 'S'.
    WHEN 'TDN_TSHD'.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = 'TDN_TSHD'
        EXCEPTIONS
          bad_eventid            = 1" eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.

**      SUBMIT ztdnsd_i012 WITH p_proses = lv_proses
**                          AND RETURN.
      p_status = 'S'.
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
          MESSAGE      = ld_mess
        TABLES
          t_material   = lt_material.
**    WHEN 'TDN_PAYMENT'.
**"      CONDENSE p_zdata.
**      CALL FUNCTION 'ZBP_EVENT_RAISE'
**        EXPORTING
**          eventid                = 'TDN_PAYMENT'
**        EXCEPTIONS
**          bad_eventid            = 1" eventparm = gv_EVENTPARM
**          eventid_does_not_exist = 2
**          eventid_missing        = 3
**          raise_failed           = 4.
****      SUBMIT ztdnsd_i018 WITH p_proses = lv_proses
****                          AND RETURN.
    WHEN OTHERS.
      p_status = 'T'.
  ENDCASE.

ENDFORM.                    " F_PROSES_TDN
