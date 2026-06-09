*----------------------------------------------------------------------*
***INCLUDE LZTDS_APIF12 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_TIAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ZPROSES  text
*      <--P_GV_EVENT  text
*      <--P_ZDATA  text
*      <--P_STATUS  text
*----------------------------------------------------------------------*
FORM f_proses_tiam  CHANGING p_zproses
                             p_zevent
                             p_zdata
                             p_status.
  DATA: lt_ztdsitdt006 TYPE STANDARD TABLE OF ztdsitdt006 WITH HEADER LINE.
  DATA: ls_ztdsitdt006 TYPE ztdsitdt006.
  DATA: ls_ztdnsddt023 TYPE ztdnsddt023.
  DATA: lv_banfn TYPE banfn.
  DATA: lv_status(1), lv_message(100).
  DATA: lv_event TYPE char40.
  p_status = 'S'.
  CONDENSE p_zdata.
  ls_ztdsitdt006-zproses = 'TIAM'.
  ls_ztdsitdt006-zevent = p_zevent.
  ls_ztdsitdt006-zdata = p_zdata.
  ls_ztdsitdt006-erdat = sy-datum.
  ls_ztdsitdt006-ernam = sy-uname.
  ls_ztdsitdt006-erzet = sy-uzeit.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.

  p_status = 'S'.
  CASE p_zevent.
    WHEN 'TIAM_PRCREATE'.
      p_status = 'S'.
      CONDENSE p_zdata.
      lv_banfn = p_zdata.
      CONCATENATE p_zevent 'success trigger ' INTO p_zdata.
      CALL FUNCTION 'ZTIAM_IMM01'
        EXPORTING
          zbanfn  = lv_banfn
        IMPORTING
          banfn   = lv_banfn
          status  = lv_status
          message = lv_message.
      p_zdata = lv_message.
      p_status = lv_status.
    WHEN OTHERS.
      CONCATENATE 'Err: ' p_zevent ' not found' INTO p_zdata.
      CONCATENATE 'Err: ' p_zevent ' not found' INTO lv_message.
      p_status = 'E'.
  ENDCASE.
  ls_ztdsitdt006-status = p_status.
  ls_ztdsitdt006-message = lv_message.
  MODIFY ztdsitdt006 FROM ls_ztdsitdt006.

ENDFORM.                    " F_PROSES_TIAM
