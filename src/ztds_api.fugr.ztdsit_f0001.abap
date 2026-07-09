FUNCTION ztdsit_f0001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(ZPROSES) TYPE  CHAR15
*"     VALUE(ZEVENT) TYPE  CHAR20
*"  EXPORTING
*"     VALUE(PROSES) TYPE  CHAR15
*"     VALUE(EVENT) TYPE  CHAR20
*"     VALUE(STATUS) TYPE  CHAR1
*"----------------------------------------------------------------------

  DATA: gv_event LIKE ztdsitdt001-zproses.
  DATA: lv_event LIKE ztdsitdt001-zproses.
  IF zproses = 'TIMWAS'.
    status = 'S'.
    CONDENSE zevent.
    lv_event = zevent.
    CONDENSE lv_event.
    SELECT SINGLE zproses INTO gv_event FROM ztdsitdt001
      WHERE zproses = lv_event.
    IF sy-subrc EQ 0.
      PERFORM f_proses_timwas CHANGING zproses gv_event status.
    ELSE.
      sy-subrc = 1.
    ENDIF.
    proses = zproses.
    event = gv_event.
  ELSEIF zproses = 'TDN'. " or zproses = 'TDN_TEST'.
    status = 'E'.
    CONDENSE zevent.
    lv_event = zevent.
    CONDENSE lv_event.
    SELECT SINGLE zproses INTO gv_event FROM ztdsitdt001
      WHERE zproses = lv_event.
    IF sy-subrc EQ 0.
      PERFORM f_proses_tdn CHANGING zproses gv_event status.
      "status = 'S'.
    ENDIF.
    proses = zproses.
    event = gv_event.
  ELSE.
    status = 'N'.
    proses = zproses.
    event = zevent.
  ENDIF.
ENDFUNCTION.
