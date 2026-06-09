FUNCTION ZAPI_ORDER_CONTRACT1.
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
*"----------------------------------------------------------------------

  DATA: gv_event LIKE ztdsitdt001-zproses.
  DATA: lv_event LIKE ztdsitdt001-zproses.
***  CALL FUNCTION 'DIALOG_SET_NO_DIALOG'.

  TRANSLATE zproses TO UPPER CASE.
  TRANSLATE zevent TO UPPER CASE.
  CONDENSE:  zproses, zevent.
  IF zproses = 'TIMWAS'.
    status = 'S'.

    lv_event = zevent.
    CONDENSE lv_event.
    SELECT SINGLE zproses INTO gv_event FROM ztdsitdt001
      WHERE zproses = lv_event.
    IF sy-subrc EQ 0.
      PERFORM f_tws_data CHANGING zproses gv_event zdata status.
    ELSE.
      sy-subrc = 1.
      status = 'T'.
    ENDIF.
    proses = zproses.
    event = gv_event.
    data = zdata.
  ELSEIF zproses = 'DISKON'.
    status = 'D'.
    PERFORM f_proses_diskon CHANGING zproses zevent zdata status.
    proses = zproses.
    event = gv_event.
    data = zdata.
  ELSEIF zproses = 'TIVEM'.
    status = 'S'.
    lv_event = zevent.
    CONDENSE lv_event.
    SELECT SINGLE zproses INTO gv_event FROM ztdsitdt001
      WHERE zproses = lv_event.
    IF sy-subrc EQ 0.
      PERFORM f_proses_tivem CHANGING zproses gv_event zdata status.
    ELSE.
      sy-subrc = 1.
      status = 'T'.
    ENDIF.
    proses = zproses.
    event = gv_event.
    data = zdata.
  ELSEIF zproses = 'TIARA'.
    status = 'S'.
    lv_event = zevent.
    CONDENSE lv_event.
    SELECT SINGLE zproses INTO gv_event FROM ztdsitdt001
      WHERE zproses = lv_event.
    IF sy-subrc EQ 0.
      PERFORM f_proses_tiara CHANGING zproses gv_event zdata status.
    ELSE.
      sy-subrc = 1.
      status = 'I'.
    ENDIF.
    proses = zproses.
    event = gv_event.
    data = zdata.
  ELSEIF zproses = 'ODOO'.
    status = 'S'.
    lv_event = zevent.
    CONDENSE lv_event.
    SELECT SINGLE zproses INTO gv_event FROM ztdsitdt001
      WHERE zproses = lv_event.
    IF sy-subrc EQ 0.
      PERFORM f_proses_odoo CHANGING zproses gv_event zdata status.
    ELSE.
      zdata = 'Error: no data'.
      sy-subrc = 1.
      status = 'E'.
    ENDIF.
    proses = zproses.
    event = gv_event.
    data = zdata.
  ELSEIF zproses = 'EPROC'.
    status = 'S'.
    lv_event = zevent.
    CONDENSE lv_event.
    SELECT SINGLE zproses INTO gv_event FROM ztdsitdt001
      WHERE zproses = lv_event.
    IF sy-subrc EQ 0.
      PERFORM f_proses_eproc CHANGING zproses gv_event zdata status gv_message.
    ELSE.
      sy-subrc = 1.
      status = 'I'.
    ENDIF.
    proses = zproses.
    event = gv_event.
    data = zdata.

    "HSM_QOUT
  ELSEIF zproses = 'TDN'.
    status = 'S'.
    lv_event = zevent.
    CONDENSE lv_event.
    SELECT SINGLE zproses INTO gv_event FROM ztdsitdt001
      WHERE zproses = lv_event.
    IF sy-subrc EQ 0.
      PERFORM f_proses_new_tdn CHANGING zproses gv_event zdata status gv_message.
    ELSE.
      sy-subrc = 1.
      status = 'E'.
    ENDIF.
    proses = zproses.
    event = gv_event.
    data = zdata.
  ELSEIF zproses = 'ACC'.
    status = 'S'.
    lv_event = zevent.
    CONDENSE lv_event.
    SELECT SINGLE zproses INTO gv_event FROM ztdsitdt001
      WHERE zproses = lv_event.
    IF sy-subrc EQ 0.
      PERFORM f_proses_acc CHANGING zproses gv_event zdata status.
    ELSE.
      sy-subrc = 1.
      status = 'E'.
    ENDIF.
    proses = zproses.
    event = gv_event.
    data = zdata.
  ELSEIF zproses = 'TMART'.
    status = 'S'.
    lv_event = zevent.
    CONDENSE lv_event.
    SELECT SINGLE zproses INTO gv_event FROM ztdsitdt001
      WHERE zproses = lv_event.
    IF sy-subrc EQ 0.
      PERFORM f_proses_tmart CHANGING zproses gv_event zdata status.
    ELSE.
      sy-subrc = 1.
      status = 'E'.
    ENDIF.
    proses = zproses.
    event = gv_event.
    data = zdata.
  ELSEIF zproses = 'TR'.
    status = 'S'.
    lv_event = zevent.
    CONDENSE lv_event.
    SELECT SINGLE zproses INTO gv_event FROM ztdsitdt001
      WHERE zproses = lv_event.
    IF sy-subrc EQ 0.
      PERFORM f_proses_tr CHANGING zproses gv_event zdata status.
    ELSE.
      sy-subrc = 1.
      status = 'E'.
    ENDIF.
    proses = zproses.
    event = gv_event.
    data = zdata.

  ELSE.
    CONCATENATE 'Err: ' zevent ' not found' INTO zdata.
    status = 'N'.
    proses = zproses.
    event = zevent.
    data = zdata.
  ENDIF.
***  CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.
ENDFUNCTION.
