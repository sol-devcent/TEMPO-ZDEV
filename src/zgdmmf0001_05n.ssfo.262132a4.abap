DATA : text LIKE spell,
       l_waers(6),
       l_waers1(40).

WRITE wa_hd-total TO va_total1 CURRENCY wa_hd-waers.

CALL FUNCTION 'SPELL_AMOUNT'
     EXPORTING
          amount                = wa_hd-total
          currency              = wa_hd-waers
          language              = 'i'
     IMPORTING
          in_words              = text
     EXCEPTIONS
          records_not_found     = 1
          records_not_requested = 2
          OTHERS                = 3.

IF text-currdec EQ 0.
  IF wa_hd-waers EQ 'IDR'.
    l_waers = 'RUPIAH'.
    va_total2 = 'Rp'.
  ELSE.
    l_waers = wa_hd-waers.
    va_total2 = wa_hd-waers.
  ENDIF.
ELSE.
  IF wa_hd-waers EQ 'IDR'.
    l_waers = 'RUPIAH'.
    va_total2 = 'Rp'.
  ELSE.
    l_waers = wa_hd-waers.
    va_total2 = wa_hd-waers.
  ENDIF.
ENDIF.

IF wa_hd-waers NE 'IDR'.
  SELECT SINGLE ktext
    FROM tcurt
    INTO l_waers1
    WHERE spras EQ sy-langu AND
          waers EQ wa_hd-waers.
  TRANSLATE l_waers1 TO UPPER CASE.
ENDIF.

IF text-currdec EQ 0.
  IF wa_hd-waers EQ 'IDR'.
    l_waers = 'RUPIAH'.
    CONCATENATE text-word l_waers INTO va_jumlah
      SEPARATED BY space.
  ELSE.
    CONCATENATE l_waers1 text-word INTO va_jumlah
      SEPARATED BY space.
  ENDIF.
ELSE.
  IF text-decword EQ 'ZERO' OR
    text-decword EQ 'NOL'.
    CONCATENATE l_waers1 text-word  INTO va_jumlah
      SEPARATED BY space.
  ELSE.
    CONCATENATE l_waers1 text-word 'DAN' text-decword 'SEN'
      INTO va_jumlah
      SEPARATED BY space.
  ENDIF.
ENDIF.
























