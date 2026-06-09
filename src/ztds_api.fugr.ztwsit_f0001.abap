FUNCTION ztwsit_f0001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(ZPROSES) TYPE  CHAR15
*"     VALUE(ZEVENT) TYPE  CHAR20
*"     VALUE(ZDATA) TYPE  CHAR20
*"  EXPORTING
*"     VALUE(PROSES) TYPE  CHAR15
*"     VALUE(EVENT) TYPE  CHAR20
*"     VALUE(DATA) TYPE  CHAR20
*"     VALUE(STATUS) TYPE  CHAR1
*"     VALUE(MESSAGE) TYPE  CHAR255
*"----------------------------------------------------------------------

  DATA: gv_event LIKE ztdsitdt001-zproses.
  DATA: lv_event LIKE ztdsitdt001-zproses.
  DATA: lv_message TYPE char255.
***  CALL FUNCTION 'DIALOG_SET_NO_DIALOG'.

  TRANSLATE zproses TO UPPER CASE.
  TRANSLATE zevent TO UPPER CASE.
  CONDENSE:  zproses, zevent.
  lv_event = zevent.
  CONDENSE lv_event.
  SELECT SINGLE zproses INTO gv_event FROM ztdsitdt001
    WHERE zproses = lv_event.
  IF sy-subrc NE 0.
    sy-subrc = 1.
    status = 'N'.
    CONCATENATE 'Err: Event' lv_event 'tidak ditemukan' INTO lv_message SEPARATED BY space.
    CONCATENATE 'Err: ' lv_event ' not found' INTO zdata.
    message = lv_message.
  ELSE.
    status = 'S'.
    CASE zproses.
      WHEN 'TIMWAS'.
        PERFORM f_tws_data CHANGING zproses gv_event zdata status.
        proses = zproses.
        event = gv_event.
        data = zdata.
      WHEN 'DISKON'.
        status = 'D'.
        PERFORM f_proses_diskon CHANGING zproses zevent zdata status.
        proses = zproses.
        event = gv_event.
        data = zdata.
      WHEN 'TIVEM'.
        PERFORM f_proses_tivem CHANGING zproses gv_event zdata status.
        proses = zproses.
        event = gv_event.
        data = zdata.
      WHEN 'TIARA'.
        PERFORM f_proses_tiara CHANGING zproses gv_event zdata status.
        proses = zproses.
        event = gv_event.
        data = zdata.
      WHEN 'ODOO'.
        PERFORM f_proses_odoo CHANGING zproses gv_event zdata status.
        proses = zproses.
        event = gv_event.
        data = zdata.
      WHEN 'EPROC'.
        PERFORM f_proses_eproc CHANGING zproses gv_event zdata status lv_message.
        proses = zproses.
        event = gv_event.
        data = zdata.
        message = lv_message.
        "HSM_QOUT
      WHEN 'TDN'.
        PERFORM f_proses_new_tdn CHANGING zproses gv_event zdata status lv_message.
        proses = zproses.
        event = gv_event.
        data = zdata.
        message = lv_message.
      WHEN 'ACC'.
        PERFORM f_proses_acc CHANGING zproses gv_event zdata status.
        proses = zproses.
        event = gv_event.
        data = zdata.
      WHEN 'TMART'.
        PERFORM f_proses_tmart CHANGING zproses gv_event zdata status.
        proses = zproses.
        event = gv_event.
        data = zdata.
      WHEN 'TR'.
        PERFORM f_proses_tr CHANGING zproses gv_event zdata status.
        proses = zproses.
        event = gv_event.
        data = zdata.
      WHEN 'TREX'.
        PERFORM f_proses_trex CHANGING zproses gv_event zdata status lv_message.
        proses = zproses.
        event = gv_event.
        data = zdata.
        message = lv_message.
      WHEN 'TIAM'.
        PERFORM f_proses_tiam CHANGING zproses gv_event zdata status.
        proses = zproses.
        event = gv_event.
        data = zdata.
      WHEN 'TNF'.
        PERFORM f_proses_tnf CHANGING  zproses gv_event zdata status.
        proses = zproses.
        event = gv_event.
        data = zdata.
      WHEN OTHERS.
        sy-subrc = 1.
        CONCATENATE 'Err: Project' zproses 'tidak ditemukan' INTO lv_message SEPARATED BY space.
        CONCATENATE 'Err: ' zproses ' not found' INTO zdata.
        status = 'N'.
        proses = zproses.
        event = zevent.
        data = zdata.
    ENDCASE.
  ENDIF.
***  CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.
ENDFUNCTION.
