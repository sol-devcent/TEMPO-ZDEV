DATA: ld_count TYPE i.
CLEAR: ld_count.

IF ld_count EQ 0.
  ld_count = 1.
  READ TABLE t_sub INDEX sfsy-page.
  IF sy-subrc EQ 0.
    va_subttl = t_sub-menge.
  ENDIF.
ENDIF.




*ADD wa_detail-menge TO va_subttl2.
*IF va_subttl2 EQ va_menget.
*  va_count = 1.
*ENDIF.




























