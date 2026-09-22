
DATA ls_reguh LIKE LINE OF t_reguh.
"Break 4
break dg2_co01.
IF D_MULTIPLE eq 'X'.
  READ TABLE t_reguh into ls_reguh INDEX 1.
  CLEAR t_reguh[].
  APPEND ls_reguh to t_reguh.
ENDIF.

DESCRIBE TABLE t_reguh LINES D_REGUH_COUNT.














