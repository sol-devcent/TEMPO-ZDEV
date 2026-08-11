DATA : text LIKE spell,
       l_total LIKE ekpo-netpr.

*l_total = header-total.
l_total = header-grossamt.
CALL FUNCTION 'SPELL_AMOUNT'
     EXPORTING
          amount                = l_total
          currency              = 'IDR'
          language              = 'i'
     IMPORTING
          in_words              = text
     EXCEPTIONS
          records_not_found     = 1
          records_not_requested = 2
          OTHERS                = 3.

*va_say = text-word.
CONCATENATE text-word 'RUPIAH' INTO va_say SEPARATED BY space.



























