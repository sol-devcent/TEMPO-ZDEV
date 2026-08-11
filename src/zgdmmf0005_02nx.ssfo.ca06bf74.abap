DATA: ld_kpein1 TYPE char15,
      ld_kpein2 TYPE char15,
      ld_kpein3 TYPE char15.

** Revise by budi 10/10/2006
WRITE wa_supplier-kbetr1 TO va_kbetr1 CURRENCY wa_supplier-konwa1.
WRITE wa_supplier-kbetr2 TO va_kbetr2 CURRENCY wa_supplier-konwa2.
WRITE wa_supplier-kbetr3 TO va_kbetr3 CURRENCY wa_supplier-konwa3.

*WRITE wa_supplier-kbetr1 TO va_kbetr1 CURRENCY 'USD'.
*IF va_kbetr1+16(3) = ',00'.
*  SHIFT va_kbetr1 RIGHT BY 4 PLACES.
*ENDIF.
*
*WRITE wa_supplier-kbetr2 TO va_kbetr2 CURRENCY 'USD'.
*IF va_kbetr2+16(3) = ',00'.
*  SHIFT va_kbetr2 RIGHT BY 4 PLACES.
*ENDIF.
*
*WRITE wa_supplier-kbetr3 TO va_kbetr3 CURRENCY 'USD'.
*IF va_kbetr3+16(3) = ',00'.
*  SHIFT va_kbetr3 RIGHT BY 4 PLACES.
*ENDIF.
** End revise

SHIFT va_kbetr1 LEFT DELETING LEADING space.
SHIFT va_kbetr2 LEFT DELETING LEADING space.
SHIFT va_kbetr3 LEFT DELETING LEADING space.
CONCATENATE wa_supplier-konwa1 va_kbetr1 INTO va_kbetr1
  SEPARATED BY space.
CONCATENATE wa_supplier-konwa2 va_kbetr2 INTO va_kbetr2
  SEPARATED BY space.
CONCATENATE wa_supplier-konwa3 va_kbetr3 INTO va_kbetr3
  SEPARATED BY space.

ld_kpein1 = wa_supplier-kpein1.
ld_kpein2 = wa_supplier-kpein2.
ld_kpein3 = wa_supplier-kpein3.

SHIFT ld_kpein1 LEFT DELETING LEADING space.
SHIFT ld_kpein2 LEFT DELETING LEADING space.
SHIFT ld_kpein3 LEFT DELETING LEADING space.

CONCATENATE '( /' ld_kpein1 wa_supplier-kmein1 ')' INTO va_per1.
CONCATENATE '( /' ld_kpein2 wa_supplier-kmein2 ')' INTO va_per2.
CONCATENATE '( /' ld_kpein3 wa_supplier-kmein3 ')' INTO va_per3.



























