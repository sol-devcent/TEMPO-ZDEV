DATA: ld_month(10).

ld_month = wa_header-nrdt+4(2).
CALL FUNCTION 'ZMONTH_NAME'
  EXPORTING
    month = ld_month
  IMPORTING
    name  = ld_month.

CONCATENATE wa_header-nrdt+6(2) ld_month wa_header-nrdt(4) INTO date
  SEPARATED BY space.
























