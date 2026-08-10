*----------------------------------------------------------------------*
***INCLUDE LZGDPPDT0014F01 .
*----------------------------------------------------------------------*
FORM f_assign_user1.
  zgdppdt0014-uname = sy-uname.
  zgdppdt0014-udate = sy-datum.
  zgdppdt0014-utime = sy-uzeit.
ENDFORM.                    "F_ASSIGN_USER
