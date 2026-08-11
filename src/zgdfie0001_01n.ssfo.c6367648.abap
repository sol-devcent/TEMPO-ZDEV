DATA: ld_datab  LIKE zproject-datab.

break bcdik.

SELECT SINGLE datab
FROM zproject
INTO ld_datab
WHERE name EQ 'ZGDTAX'.

IF header-budat GE ld_datab.
  va_materai  = 'X'.
ELSE.
  CLEAR: va_materai.
ENDIF.

























