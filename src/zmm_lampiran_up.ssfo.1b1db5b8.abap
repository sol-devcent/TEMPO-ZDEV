CASE gs_header-beban.
  WHEN 'Beban Marketing TRF' OR
       'Beban Marketing CH'  OR
       'Beban Tempo Research'  OR
       'Beban Marketing Export'.
    gv_type = '1'.
  WHEN 'Beban Factory' OR
       'Claim Insurance'.
    gv_type = '2'.
  WHEN OTHERS.
    gv_type = '3'.
ENDCASE.

IF gs_header-value LE 100000.
  gv_limit = '10'.
ELSEIF gs_header-value LE 1000000.
  gv_limit = '100'.
*ELSEIF gs_header-value LE 1500000.
ELSE.
  gv_limit = '150'.
ENDIF.

CASE gs_header-werks.
  WHEN '0101' OR '0102' OR '3603'.
    gv_comp = 'TSP'.
  WHEN '0401'.
    gv_comp = 'TNP'.
  WHEN OTHERS.
    gv_comp = 'OTH'.
ENDCASE.










