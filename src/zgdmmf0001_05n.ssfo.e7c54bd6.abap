IF wa_hd-waers EQ 'IDR'.
  va_waers = 'Rp'.
ELSE.
  va_waers = wa_hd-waers.
  SELECT SINGLE waers INTO va_waers1
    FROM konv
    WHERE knumv = wa_hd-knumv AND
          kposn = '000010'    AND
          stunr = '010'.
ENDIF.
























