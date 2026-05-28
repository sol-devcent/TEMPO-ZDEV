DATA : lv_month(2).

lv_month  = sy-datum+4(2).

CALL FUNCTION 'ZMONTH_NAME'
  EXPORTING
    month = lv_month
  IMPORTING
    name  = va_date.

CONCATENATE sy-datum+6(2) va_date sy-datum(4) INTO va_date
SEPARATED BY space.






















