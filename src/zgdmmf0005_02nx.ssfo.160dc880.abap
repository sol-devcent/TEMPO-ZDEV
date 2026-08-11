DATA : ls_suppl   LIKE LINE OF t_suppl.

CLEAR : va_value1, va_value2, va_value3.

READ TABLE t_suppl INTO ls_suppl
                   WITH KEY lifnr = wa_supplier-lifnr1
                            zeile = 16.
IF sy-subrc = 0.
  va_value1  = ls_suppl-value.
ENDIF.

READ TABLE t_suppl INTO ls_suppl
                   WITH KEY lifnr = wa_supplier-lifnr2
                            zeile = 16.
IF sy-subrc = 0.
  va_value2  = ls_suppl-value.
ENDIF.

READ TABLE t_suppl INTO ls_suppl
                   WITH KEY lifnr = wa_supplier-lifnr3
                            zeile = 16.
IF sy-subrc = 0.
  va_value3  = ls_suppl-value.
ENDIF.




















