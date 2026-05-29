*****DATA : lv_lines   TYPE int4.
****ADD 1 TO gv_lines.
****ADD 1 TO gv_count.
****SUBTRACT 1 FROM gv_sisa.
****
****if gs_new-cdisca ne '0'.
****  if GV_KSCHL ne 'ZDE7' and GV_KSCHL  ne 'ZDE8'.
****    ADD 1 TO gv_lines.
****    ADD 1 TO gv_count.
****    SUBTRACT 1 FROM gv_sisa.
****  endif.
****endif.
*****break tds_dev01.
****CASE gv_lines.
****  WHEN 10 or 11.
*****    IF gv_sisa = 2 OR gv_sisa = 4.
****    IF gv_sisa BETWEEN 2 AND 3.
****      gv_newpage  = 'X'.
****      CLEAR gv_lines.
****    ELSE.
****      if gv_lines = 11 and gv_sisa = 1.
****        gv_newpage  = 'X'.
****        CLEAR gv_lines.
****      else.
****        CLEAR gv_newpage.
****      endif.
****    ENDIF.
****  WHEN 13 or 14.
****    gv_newpage  = 'X'.
****    CLEAR gv_lines.
****  WHEN OTHERS.
****    CLEAR gv_newpage.
****ENDCASE.
****
****
****
****
****
****
****
****
****
****
****
****
****
****
****
