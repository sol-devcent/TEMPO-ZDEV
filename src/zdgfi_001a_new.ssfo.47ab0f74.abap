SELECT SINGLE name1
  FROM t001 JOIN adrc on t001~adrnr = adrc~addrnumber
  INTO va_butxt
  WHERE bukrs = sf_header-bukrs.

TRANSLATE va_butxt TO UPPER CASE.





















