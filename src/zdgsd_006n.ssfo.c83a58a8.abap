*IF gv_lines = gv_totallines.
*  IF gv_count GE 22 AND gv_modlines IS INITIAL.
*    gv_lines = gv_lines - 1.
*    gv_modlines = 'X'.
*  ENDIF.
*ENDIF.

IF gv_totallines LE 30.
  IF gv_lines = gv_totallines.
    NEW-PAGE.
  ENDIF.
ELSE.
ENDIF.











