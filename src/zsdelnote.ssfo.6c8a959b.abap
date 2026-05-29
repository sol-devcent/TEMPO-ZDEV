****DATA : lv_lines   TYPE int4.
***ADD 1 TO gv_lines.
***ADD 1 TO gv_count.
***SUBTRACT 1 FROM gv_sisa.
***break tds_dev01.
***CASE gv_lines.
***  WHEN 10.
****    IF gv_sisa = 2 OR gv_sisa = 4.
***    IF gv_sisa BETWEEN 2 AND 4.
***      gv_newpage  = 'X'.
***      CLEAR gv_lines.
***    ELSE.
***      CLEAR gv_newpage.
***    ENDIF.
***  WHEN 13. " or 15.
***    if GS_NEW-CDISCA <> '0'.
***      CLEAR gv_newpage.
***    else.
***      gv_newpage  = 'X'.
***      CLEAR gv_lines.
***    endif.
***  WHEN OTHERS.
***    CLEAR gv_newpage.
***ENDCASE.
***
***
***
***
***
***
***
***
***
***
***
***
***
***
***
***
