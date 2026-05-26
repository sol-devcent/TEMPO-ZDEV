DATA: ld_amtcn LIKE vbrk-netwr,
      ld_vatcn LIKE vbrk-netwr,
      ld_value TYPE p DECIMALS 4.

*break tds_dev01.

WRITE va_kzwi1 TO va_value1 CURRENCY 'IDR'.
WRITE va_skfbp TO va_value2 CURRENCY 'IDR'.

CASE wa_header-ppn.
  WHEN '10'.
    ld_amtcn = va_kzwi5 * 10 / 11.
    ld_value = va_kzwi5 * 10 / 11.
  WHEN '11'.
    ld_amtcn = va_kzwi5 * 100 / 111.
    ld_value = va_kzwi5 * 100 / 111.
ENDCASE.

CALL FUNCTION 'ROUND'
  EXPORTING
    decimals      = '2'
    input         = ld_value
    sign          = '+'
  IMPORTING
    output        = ld_amtcn
  EXCEPTIONS
    input_invalid = 1
    overflow      = 2
    type_invalid  = 3
    OTHERS        = 4.

WRITE ld_amtcn TO va_value4 CURRENCY 'IDR'.
ld_vatcn = va_kzwi5 - ld_amtcn.
WRITE ld_vatcn TO va_value5 CURRENCY 'IDR'.

















