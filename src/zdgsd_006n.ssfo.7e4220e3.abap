DATA: ls_detail LIKE LINE OF t_detail.

IF gv_modlines IS INITIAL.
  CLEAR gv_count.
ENDIF.

CLEAR gv_totallines.

LOOP AT t_detail INTO ls_detail.
  ADD 1 TO gv_totallines.
  IF ls_detail-refer IS NOT INITIAL.
    ADD 1 TO gv_totallines.
  ENDIF.
  IF ls_detail-refer2 IS NOT INITIAL.
    ADD 1 TO gv_totallines.
  ENDIF.
  IF ls_detail-refer3 IS NOT INITIAL.
    ADD 1 TO gv_totallines.
  ENDIF.
  IF ls_detail-refer4 IS NOT INITIAL.
    ADD 1 TO gv_totallines.
  ENDIF.
  IF ls_detail-refer5 IS NOT INITIAL.
    ADD 1 TO gv_totallines.
  ENDIF.
ENDLOOP.







