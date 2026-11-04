DATA: lv_gsber LIKE zfgstt-gsber.

CASE sf_header-bukrs.
  WHEN '8020'.
    lv_gsber = '0200'.
  WHEN '8070'.
    lv_gsber = '0700'.
ENDCASE.

SELECT SINGLE graph
  INTO va_graph
  FROM zfgstt
  WHERE gsber = lv_gsber
    AND zform = 'DN'.













