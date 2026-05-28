IF wa_hd-ekorg EQ 'TNT'.
  va_butxt = 'PT.TEMPO NAGADI TRADING'.
ELSEIF wa_hd-ekorg EQ 'RSF' OR
  wa_hd-ekorg EQ 'TLOG' OR
  wa_hd-ekorg EQ 'PMH' OR
  wa_hd-ekorg EQ 'TKM'.
  SELECT SINGLE butxt INTO va_butxt FROM t001 WHERE bukrs EQ wa_hd-bukrs.
ENDIF.

DESCRIBE TABLE i_dt LINES va_lines.



















