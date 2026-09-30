FUNCTION zwmsfm005.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_EAN11) TYPE  MEAN-EAN11 OPTIONAL
*"  EXPORTING
*"     VALUE(PE_EAN11) TYPE  MEAN-EAN11
*"----------------------------------------------------------------------
  DATA : lv_xean11 TYPE string,
         lv_ean11  TYPE mean-ean11.

  lv_ean11 = pi_ean11.

  IF lv_ean11(1) = 'J'.
    SHIFT lv_ean11 LEFT DELETING LEADING 'J'.
  ENDIF.

  SPLIT lv_ean11 AT '_' INTO pe_ean11 lv_ean11.
ENDFUNCTION.
