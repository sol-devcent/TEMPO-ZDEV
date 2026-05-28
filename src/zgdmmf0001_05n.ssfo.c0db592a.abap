va_absolper1 = abs( va_absolper / 10 ).

WRITE va_absol TO va_absol1 NO-SIGN CURRENCY wa_hd-waers.
SHIFT va_absol1 LEFT DELETING LEADING space.
CONCATENATE '(' va_absol1 INTO va_absol1 SEPARATED BY space.

IF wa_hd-bsart EQ 'ZIMP'.
  va_flag1 = 0.
ELSE.
  IF wa_dt-taxim EQ space.
    IF va_ppn01 EQ 0.
      va_flag1 = 0.
    ELSE.
      va_flag1 = 1.
      va_ppnper = va_ppn01 / 10.
      WRITE va_ppnper TO va_ppn02.
      WRITE va_ppnval TO va_ppnval1 CURRENCY wa_hd-waers.
    ENDIF.
  ELSEIF wa_dt-taxim EQ '1'.
    va_flag1 = 0.
  ELSEIF wa_dt-taxim EQ '2'.
    IF va_ppn01 EQ 0.
      va_flag1 = 0.
    ELSE.
      va_flag1 = 1.
      va_ppnper = va_ppn01 / 10.
      WRITE va_ppnper TO va_ppn02.
      WRITE va_ppnval TO va_ppnval1 CURRENCY wa_hd-waers.
    ENDIF.
  ENDIF.
ENDIF.

























