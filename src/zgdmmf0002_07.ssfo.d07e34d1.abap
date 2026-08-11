  IF gv_cntr LE 15.
    ADD wa_dt-menge TO gv_menge.
  ELSE.
    ADD wa_dt-menge TO gv_menge_tmp.
  ENDIF.

*CASE gv_cntr.
*  WHEN 1.
*    IF gv_menge_tmp IS NOT INITIAL AND
*       va_counter NE '0001'.
*      ADD gv_menge_tmp TO gv_menge.
*      CLEAR gv_menge_tmp.
*    ENDIF.
*  WHEN OTHERS.
*ENDCASE.
*
*IF va_counter = gv_lines AND gv_menge_tmp IS NOT INITIAL.
*  BREAK-POINT.
*  ADD gv_menge_tmp TO gv_menge.
*ENDIF.








