*----------------------------------------------------------------------*
***INCLUDE LZTDS_APIF05 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_ACC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_GV_EVENT  text
*      <--P_ZDATA  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_proses_acc  CHANGING p_zproses
                             p_event
                             p_zdata
                             p_status.

  TABLES: zaccppdt001, zaccppdt002.
  DATA: lv_event TYPE char40.
  DATA: ls_zaccppdt001 TYPE zaccppdt001.
  DATA: ls_zaccppdt002 TYPE zaccppdt002.
  DATA: lt_ztdsitdt006 TYPE STANDARD TABLE OF ztdsitdt006 WITH HEADER LINE.
  DATA: ls_ztdsitdt006 TYPE ztdsitdt006.
  DATA: lv_err(1).
  DATA: lv_zdata TYPE zaccsapid.
  p_status = 'S'.
  CONDENSE p_zdata.
  ls_ztdsitdt006-zproses = 'ACC'.
  ls_ztdsitdt006-zevent = p_event.
  ls_ztdsitdt006-zdata = p_zdata.
  ls_ztdsitdt006-erdat = sy-datum.
  ls_ztdsitdt006-ernam = sy-uname.
  ls_ztdsitdt006-erzet = sy-uzeit.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.

  p_status = 'S'.
  CASE p_event.
    WHEN 'ACC_AGGR'.
      CONDENSE p_zdata.
      lv_event = p_event.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = lv_event "'ZACC_AGGR'
        EXCEPTIONS
          bad_eventid            = 1 " eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      "OTHERS                 = 5.
      CLEAR: lv_err.
      lv_zdata = p_zdata.
      SELECT SINGLE * INTO ls_zaccppdt001 FROM zaccppdt001
        WHERE zproses = ls_ztdsitdt006-zevent AND
              zdata = lv_zdata. "ls_ztdsitdt006-zdata.
      IF sy-subrc EQ 0 AND ls_zaccppdt001-status NE space.
        lv_err = 'X'.
      ENDIF.
      SELECT SINGLE  zproses zdata MAX( zcounter ) AS zcounter INTO CORRESPONDING FIELDS OF ls_zaccppdt002 FROM zaccppdt002
        WHERE zproses = ls_ztdsitdt006-zevent AND
              zdata = lv_zdata
          GROUP BY zproses zdata. "ls_ztdsitdt006-zdata.
      IF sy-subrc EQ 0 AND ls_zaccppdt001-status NE space.
        lv_err = 'X'.
      ENDIF.
      "and   ls_zaccppdt001-STATUS
      ls_zaccppdt002-zproses = ls_ztdsitdt006-zevent. "p_event.
      ls_zaccppdt002-zdata = lv_zdata. "p_zdata.
      IF ls_zaccppdt002-zcounter IS NOT INITIAL.
        ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
      ELSE.
        ls_zaccppdt002-zcounter = 0.
      ENDIF.
      ls_zaccppdt002-erdat = sy-datum.
      ls_zaccppdt002-ernam = sy-uname.
      ls_zaccppdt002-erzet = sy-uzeit.
      "        ls_zaccppdt002-status = ls_zaccppdt001-status = 'U'.
      "        ls_zaccppdt002-message = 'Di trigger'.
      IF lv_err NE 'X'.
        ls_zaccppdt002-zproses = ls_zaccppdt001-zproses =  ls_ztdsitdt006-zevent. "p_event.
        ls_zaccppdt002-zdata = ls_zaccppdt001-zdata = lv_zdata. "p_zdata.
        IF ls_zaccppdt002-zcounter IS NOT INITIAL.
          ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
        ELSE.
          ls_zaccppdt002-zcounter = 0.
        ENDIF.
        ls_zaccppdt002-erdat = ls_zaccppdt001-erdat = sy-datum.
        ls_zaccppdt002-ernam = ls_zaccppdt001-ernam = sy-uname.
        ls_zaccppdt002-erzet = ls_zaccppdt001-erzet = sy-uzeit.
        ls_zaccppdt002-status = ls_zaccppdt001-status = 'U'.
        ls_zaccppdt002-message = 'Di trigger'.
        MODIFY zaccppdt001 FROM ls_zaccppdt001.
        COMMIT WORK.
      ELSEIF ls_zaccppdt001-status = 'E'.
        ls_zaccppdt002-zproses = ls_zaccppdt001-zproses =  ls_ztdsitdt006-zevent. "p_event.
        ls_zaccppdt002-zdata = ls_zaccppdt001-zdata = lv_zdata. "p_zdata.
        IF ls_zaccppdt002-zcounter IS NOT INITIAL.
          ls_zaccppdt002-zcounter = ls_zaccppdt002-zcounter + 1.
        ELSE.
          ls_zaccppdt002-zcounter = 0.
        ENDIF.
        ls_zaccppdt002-erdat = ls_zaccppdt001-erdat = sy-datum.
        ls_zaccppdt002-ernam = ls_zaccppdt001-ernam = sy-uname.
        ls_zaccppdt002-erzet = ls_zaccppdt001-erzet = sy-uzeit.
        ls_zaccppdt002-status = ls_zaccppdt001-status = 'U'.
        ls_zaccppdt002-message = 'Di ulang trigger'.
        MODIFY zaccppdt001 FROM ls_zaccppdt001.
        COMMIT WORK.
      ELSE.
        p_status = 'S'.
        p_zdata = 'Sdh pernah ditrigger'.
        ls_zaccppdt002-status = 'S'.
        ls_zaccppdt002-message = 'Sdh pernah ditrigger'.
      ENDIF.
      MODIFY zaccppdt002 FROM ls_zaccppdt002.
    WHEN 'ZACCSEND'.
      CONDENSE p_zdata.
      lv_event = p_event.
      CALL FUNCTION 'ZBP_EVENT_RAISE'
        EXPORTING
          eventid                = lv_event "'ZACC_AGGR'
        EXCEPTIONS
          bad_eventid            = 1 " eventparm = gv_EVENTPARM
          eventid_does_not_exist = 2
          eventid_missing        = 3
          raise_failed           = 4.
      "OTHERS                 = 5.
      IF sy-subrc EQ 0.
        p_zdata = 'berhasil create event (ZACCSEND)'.
      ENDIF.
      ls_zaccppdt001-zproses =  ls_ztdsitdt006-zevent. "p_event.
      ls_zaccppdt001-zdata = lv_zdata. "p_zdata.
      ls_zaccppdt001-erdat = sy-datum.
      ls_zaccppdt001-ernam = sy-uname.
      ls_zaccppdt001-erzet = sy-uzeit.
      ls_zaccppdt001-status = 'S'.
      MODIFY zaccppdt001 FROM ls_zaccppdt001.
      COMMIT WORK.
      p_status = 'S'.
      CLEAR: lv_err.
      lv_zdata = p_zdata.
    WHEN OTHERS.
      CONCATENATE 'Acc Err: ' p_event ' not found' INTO p_zdata.
      "      p_zdata = 'Err: Zevent'.
      p_status = 'E'.
  ENDCASE.

ENDFORM.                    " F_PROSES_ACC
