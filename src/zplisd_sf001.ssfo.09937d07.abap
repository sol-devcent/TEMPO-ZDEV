va_vbeln = t_header-vbeln.
CONCATENATE va_fakturno(3) '.' va_fakturno+3(3) '-' INTO va_faktur.
CONCATENATE va_faktur va_fakturno+6(2) '.' va_fakturno+8(8) INTO va_faktur.

SELECT SINGLE datab INTO @DATA(lv_datab)
  FROM zproject WHERE name = 'CORETAX'.
IF sy-subrc = 0.
  IF t_header-fkdat GT lv_datab.
    CLEAR va_faktur.
    WRITE va_fakturno TO va_faktur USING EDIT MASK '__.__.__.___-________'.
  ENDIF.
ENDIF.























