ADD 1 TO gv_page.
IF sfsy-page <> sfsy-formpages.
  gv_display = 'X'.
ELSE.
  CLEAR : gv_display.
ENDIF.














