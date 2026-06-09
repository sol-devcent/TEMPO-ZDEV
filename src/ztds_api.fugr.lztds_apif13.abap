*----------------------------------------------------------------------*
***INCLUDE LZTDS_APIF13.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_TNF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_GV_EVENT  text
*      <--P_ZDATA  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_proses_tnf  CHANGING p_zproses
                             p_zevent
                             p_zdata
                             p_status.
  DATA: lt_ztdsitdt006 TYPE STANDARD TABLE OF ztdsitdt006 WITH HEADER LINE.
  DATA: ls_ztdsitdt006 TYPE ztdsitdt006.
  DATA: lv_message(150).
  DATA: BEGIN OF lt_ekpo OCCURS 0,
          ebeln TYPE ekpo-ebeln,
          banfn TYPE ekpo-banfn,
        END OF lt_ekpo.
  DATA: lv_banfn TYPE ekpo-banfn.
  DATA: lv_subrc TYPE sy-subrc.
  p_status = 'S'.
  CONDENSE p_zdata.
  ls_ztdsitdt006-zproses = 'TNF'.
  ls_ztdsitdt006-zevent = p_zevent.
  ls_ztdsitdt006-zdata = p_zdata.
  ls_ztdsitdt006-erdat = sy-datum.
  ls_ztdsitdt006-ernam = sy-uname.
  ls_ztdsitdt006-erzet = sy-uzeit.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.

  p_status = 'S'.
  CASE p_zevent.
    WHEN 'TNF_GETGR'.
      "    lv_pr_tnf = deep_entity-data-pr_doc_no.
      CONDENSE p_zdata.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = 'TNF_GETGR'
        EXCEPTIONS
          bad_eventid            = 1 " eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.

      IF sy-subrc EQ 0.
        p_status = 'S'.
      ELSE.
        CONCATENATE 'Err: ' p_zevent 'Gagal Create Event' INTO lv_message.
        p_zdata = lv_message.
        p_status = 'E'.
      ENDIF.
    WHEN 'TNF_SENDPO'.
      CONDENSE p_zdata.
      lv_banfn = p_zdata.
      lv_subrc = 1.
      p_status = 'E'.
      CLEAR: lt_ekpo[], lt_ekpo.
      lv_message = 'Not Found/No Data'. " SEPARATED BY space.
      p_zdata = lv_message.
      SELECT ebeln banfn INTO TABLE lt_ekpo FROM ekpo
        WHERE banfn = lv_banfn GROUP BY ebeln banfn.
      LOOP AT lt_ekpo.
        PERFORM f_send_api(ztnfmm_i001) USING  lt_ekpo-ebeln
                                             CHANGING lv_subrc.
        IF lv_subrc = 0.
          CONCATENATE 'PO.' lt_ekpo-ebeln 'Send' INTO lv_message SEPARATED BY space.
          p_zdata = lv_message.
          p_status = 'S'.
        ENDIF.
      ENDLOOP.
    WHEN OTHERS.
      CONCATENATE 'Err: ' p_zevent ' not found' INTO p_zdata.
      CONCATENATE 'Err: ' p_zevent ' not found' INTO lv_message.
      p_status = 'E'.
  ENDCASE.
  ls_ztdsitdt006-status = p_status.
  ls_ztdsitdt006-message = lv_message.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.

ENDFORM.
