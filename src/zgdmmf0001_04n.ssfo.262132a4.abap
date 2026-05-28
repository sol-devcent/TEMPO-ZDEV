DATA : text LIKE spell,
l_waers(6),
l_waers1(40).

WRITE wa_hd-total TO va_total1 CURRENCY wa_hd-waers.

CALL FUNCTION 'SPELL_AMOUNT'
EXPORTING
amount                = wa_hd-total
currency              = wa_hd-waers
language              = sy-langu
IMPORTING
in_words              = text
EXCEPTIONS
records_not_found     = 1
records_not_requested = 2
OTHERS                = 3.

IF wa_hd-waers NE 'IDR'.
SELECT SINGLE ktext
FROM tcurt
INTO l_waers1
WHERE spras EQ sy-langu AND
waers EQ wa_hd-waers.
translate l_waers1 to upper case.
ENDIF.

IF text-currdec EQ 0.
IF wa_hd-waers EQ 'IDR'.
l_waers = 'RUPIAH'.
va_total2 = 'Rp'.
CONCATENATE text-word l_waers INTO va_jumlah
SEPARATED BY SPACE.
ELSE.
l_waers = wa_hd-waers.
va_total2 = wa_hd-waers.
CONCATENATE l_waers1 text-word INTO va_jumlah
SEPARATED BY SPACE.
ENDIF.
ELSE.
IF wa_hd-waers EQ 'IDR'.
l_waers = 'RUPIAH'.
va_total2 = 'Rp'.
CONCATENATE text-word l_waers INTO va_jumlah
SEPARATED BY SPACE.
ELSE.
va_total2 = wa_hd-waers.
IF text-decword EQ 'ZERO'.
CONCATENATE l_waers1 text-word INTO va_jumlah
SEPARATED BY SPACE.
ELSE.
CONCATENATE l_waers1 text-word 'AND' text-decword 'CENTS'
INTO va_jumlah
SEPARATED BY SPACE.
ENDIF.
ENDIF.
ENDIF.



























