IF wa_dt-prueflos EQ 0.
  va_prueflos = space.
ELSE.
  va_prueflos = wa_dt-prueflos.
ENDIF.

IF wa_dt-knttp = 'F'.
  va_prueflos = wa_dt-aufnr.
ENDIF.





















