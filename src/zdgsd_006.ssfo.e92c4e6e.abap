
va_harga_rp = wa_condtype-harga_rp.
DO 3 TIMES.
  REPLACE '.' WITH space INTO va_harga_rp.
ENDDO.
CONDENSE va_harga_rp NO-GAPS.
ADD va_harga_rp TO va_subtotal.
IF va_harga_rp NE 0.
  va_cek = va_harga_rp.
ENDIF.






















