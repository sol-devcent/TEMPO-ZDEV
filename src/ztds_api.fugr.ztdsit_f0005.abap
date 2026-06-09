FUNCTION ztdsit_f0005.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(ZTEXTIN) TYPE  TEXT1024
*"  EXPORTING
*"     VALUE(ZTEXTOUT) TYPE  TEXT1024
*"----------------------------------------------------------------------
  DATA: c_value_check(20) TYPE c VALUE '1234567890|kgKG.,'.

  IF ztextin CN c_value_check.
    CLEAR: ztextout.
  ELSE.
    ztextout = ztextin.
  ENDIF.


ENDFUNCTION.
