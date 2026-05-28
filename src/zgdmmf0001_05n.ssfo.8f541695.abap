  va_subttl = va_subttl - va_cek.
  WRITE va_subttl TO va_subttl1 CURRENCY wa_hd-waers.

  va_page = sfsy-page + 1.

  IF wa_hd-waers EQ 'IDR'.
    va_waers = 'Rp'.
  ELSE.
    va_waers = wa_hd-waers.
  ENDIF.

  va_subttl = va_subttl + va_cek.


















