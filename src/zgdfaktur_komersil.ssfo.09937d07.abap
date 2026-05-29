va_vbeln = t_header-vbeln.
CONCATENATE va_fakturno(3) '.' va_fakturno+3(3) '-' INTO va_faktur.
CONCATENATE va_faktur va_fakturno+6(2) '.' va_fakturno+8(8) INTO va_faktur.
























