DATA : lv_msehi   TYPE t006-msehi.

SELECT SINGLE msehi
  FROM t006
  INTO lv_msehi
  WHERE isocode = 'CEL'.

CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
  EXPORTING
    input          = lv_msehi
  IMPORTING
    output         = gv_celcius
  EXCEPTIONS
    unit_not_found = 1
    OTHERS         = 2.

CONCATENATE 'SIMPAN PADA SUHU 2-8' gv_celcius INTO gv_simpan.




















