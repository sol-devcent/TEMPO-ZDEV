break bcdik.
DESCRIBE TABLE t_detail LINES va_lines.
IF va_lines GT 10.
  va_pindah = 1.
ENDIF.

SELECT SINGLE datab
  FROM zproject
  INTO va_datab
  WHERE name EQ 'ZGDTAX'.

IF sy-datum GE va_datab.
  va_flag1  = 1.
ENDIF.






















