READ TABLE t_subtotal WITH KEY nonr  = wa_detail-nonr
                               zpage = sfsy-page.
IF sy-subrc EQ 0.
  WRITE t_subtotal-kzwi1 TO va_subtotal CURRENCY 'IDR'.
ENDIF.
va_page = sfsy-page + 1.


























