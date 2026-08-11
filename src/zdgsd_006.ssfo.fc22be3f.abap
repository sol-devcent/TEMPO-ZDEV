IF NOT va_pay IS INITIAL.
  WRITE va_pay CURRENCY 'IDR' TO d_pay.
ENDIF.

IF NOT va_pay_f IS INITIAL.
  WRITE va_pay_f CURRENCY t_header-waerk TO d_pay_f.
ENDIF.

























