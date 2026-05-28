*IF va_subttl = wa_hd-total.
*  va_flag2 = 0.
*ELSE.
va_flag2 = 1.
*ENDIF.

IF wa_dt-ebelp EQ 99998.
CLEAR: va_count, va_count1.
ENDIF.



























