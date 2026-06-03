*----------------------------------------------------------------------*
***INCLUDE LZSTARGET_CONTROLF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FETCH_VALUE
*&---------------------------------------------------------------------*
FORM f_fetch_value.
  zstarget_control-ernam      = sy-uname.
  zstarget_control-erdat      = sy-datum.
  zstarget_control-erzet      = sy-uzeit.
ENDFORM.                    "F_FETCH_VALUE
