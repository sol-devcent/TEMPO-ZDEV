DATA : lv_gebeh   TYPE zgdqmst0010-gebeh.

CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
  EXPORTING
    input          = wa_itab-gebeh
  IMPORTING
    output         = lv_gebeh
  EXCEPTIONS
    unit_not_found = 1
    OTHERS         = 2.

COMPUTE va_zgesstichpr1 = CEIL( wa_itab-zgesstichpr ).

WRITE wa_itab-zgesstichpr TO va_sample UNIT wa_itab-gebeh.
SHIFT va_sample LEFT DELETING LEADING space.

CONCATENATE va_sample lv_gebeh INTO va_sample
SEPARATED BY space.



















