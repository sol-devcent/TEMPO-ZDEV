SELECT SINGLE name1
  FROM t001 JOIN adrc ON t001~adrnr = adrc~addrnumber
  INTO va_butxt
  WHERE bukrs = sf_header-bukrs.

TRANSLATE va_butxt TO UPPER CASE.

DESCRIBE TABLE gt_detail LINES va_lines.

















