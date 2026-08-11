IF wa_dt-mtart EQ 'ZRM' OR
  wa_dt-mtart EQ 'ZPM' OR
  wa_dt-mtart EQ 'ZSFG' .
  va_flag = 0.
ELSE.
  va_flag = 1.
ENDIF.























