*----------------------------------------------------------------------*
***INCLUDE LZFI_CONTROLF01 .
*----------------------------------------------------------------------*
FORM fetch_value .
  zfi_control-ernam = sy-uname.
  zfi_control-erdat = sy-datum.
  zfi_control-erzet = sy-uzeit.
ENDFORM.                    " FETCH_VALUE
