DATA : lv_menge   TYPE mseg-menge.

*CLEAR : va_menge, va_decimal, va_meins.

ADD 1 TO va_nou.
wa_detail-menge = wa_detail-menge - wa_detail-bsmng.

CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
  EXPORTING
    input                = wa_detail-menge
    matnr                = wa_detail-matnr
    meinh                = t_header-meins
    meins                = wa_detail-meins
  IMPORTING
    output               = lv_menge
  EXCEPTIONS
    conversion_not_found = 1
    input_invalid        = 2
    material_not_found   = 3
    meinh_not_found      = 4
    meins_missing        = 5
    no_meinh             = 6
    output_invalid       = 7
    overflow             = 8
    OTHERS               = 9.

IF sy-subrc <> 0.
ELSE.
*  break tds_dev01.
  WRITE lv_menge TO va_menge DECIMALS 3. "UNIT wa_detail-meins.
  SPLIT va_menge AT ',' INTO va_menge va_decimal.
  CONDENSE va_menge NO-GAPS.
  CONDENSE va_decimal NO-GAPS.
  va_meins = wa_detail-meins.
ENDIF.
























