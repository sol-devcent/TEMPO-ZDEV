*----------------------------------------------------------------------*
***INCLUDE LZTDS_APIF07 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_TR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_GV_EVENT  text
*      <--P_ZDATA  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_proses_tr   CHANGING p_zproses
                             p_event
                             p_zdata
                             p_status.
  DATA: lt_ztdsitdt006 TYPE STANDARD TABLE OF ztdsitdt006 WITH HEADER LINE.
  DATA: ls_ztdsitdt006 TYPE ztdsitdt006.
  DATA: ls_ztdnsddt023 TYPE ztdnsddt023.
  DATA: lv_no_invoce TYPE zinvno.
  DATA: lv_status(1), lv_message(100).
  DATA: lv_event TYPE char40.
  p_status = 'S'.
  CONDENSE p_zdata.
  ls_ztdsitdt006-zproses = 'TR'.
  ls_ztdsitdt006-zevent = p_event.
  ls_ztdsitdt006-zdata = p_zdata.
  ls_ztdsitdt006-erdat = sy-datum.
  ls_ztdsitdt006-ernam = sy-uname.
  ls_ztdsitdt006-erzet = sy-uzeit.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.

  p_status = 'S'.
  CASE p_event.
    WHEN 'TR_APPROVAL'.
      p_status = 'S'.
      CONDENSE p_zdata.
      lv_no_invoce = p_zdata.
      CONCATENATE p_event 'success trigger ' INTO p_zdata.
      CALL FUNCTION 'ZTRFI_F0001'
        EXPORTING
          proses     = 'TR_APPROVAL'
          invoice_no = lv_no_invoce " phone_number = lv_phone
        IMPORTING
          status     = lv_status
          message    = lv_message.
      p_zdata = lv_message.
      p_status = lv_status.
    WHEN OTHERS.
      CONCATENATE 'Err: ' p_event ' not found' INTO p_zdata.
      CONCATENATE 'Err: ' p_event ' not found' INTO lv_message.
      p_status = 'E'.
  ENDCASE.
  ls_ztdsitdt006-status = p_status.
  ls_ztdsitdt006-message = lv_message.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.
ENDFORM.                    " F_PROSES_TR
