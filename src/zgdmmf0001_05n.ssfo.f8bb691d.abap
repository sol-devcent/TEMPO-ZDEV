IF wa_hd-ekorg EQ 'TNT'.
  va_butxt = 'PT.TEMPO NAGADI TRADING'.
ELSEIF wa_hd-ekorg EQ 'RSF' OR
  wa_hd-ekorg EQ 'TLOG' OR
  wa_hd-ekorg EQ 'BCL' OR
  wa_hd-ekorg EQ 'FAC' OR
  wa_hd-ekorg EQ 'PMH' OR
  wa_hd-ekorg EQ 'TKM'.
  SELECT SINGLE butxt
  FROM t001
  INTO va_butxt
  WHERE bukrs EQ wa_hd-bukrs.
ENDIF.




















