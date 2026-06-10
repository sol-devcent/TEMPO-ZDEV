FUNCTION zwm_ean11_matnr.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(EAN11) TYPE  MEAN-EAN11 OPTIONAL
*"  EXPORTING
*"     REFERENCE(MATNR) TYPE  MARA-MATNR
*"----------------------------------------------------------------------

  DATA : lv_matnr   TYPE mara-matnr,
         lv_jmatnr  TYPE mara-matnr.

  lv_matnr  = ean11.

  SELECT SINGLE matnr
    FROM mean
    INTO matnr
    WHERE ean11 = lv_matnr.
  IF sy-subrc = 0.
    CONCATENATE 'J' ean11 INTO lv_jmatnr.
    SELECT SINGLE matnr
      FROM mean
      INTO matnr
      WHERE ean11 = lv_jmatnr.
    IF sy-subrc = 0.
      SELECT SINGLE matnr
        FROM mara
        INTO matnr
        WHERE matnr = lv_matnr.
    ENDIF.
  ENDIF.
ENDFUNCTION.
