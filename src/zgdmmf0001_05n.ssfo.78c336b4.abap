CASE wa_hd-ekgrp.
  WHEN 'P01' OR 'R01' OR 'T01'.
    va_footer  = '1.SUPPLIER     2.FIN/ACC BU     3.FILE    4.FIN TNT'.
  WHEN 'P02' OR 'R02'.
    va_footer  =
    '1.SUPPLIER     2.FIN/ACC BU     3.FILE    4.FIN TNT     5.PPIC     6.WH'.
  WHEN 'T02'.
    va_footer  =
    '1.SUPPLIER     2.FIN/ACC BU     3.FILE    4.FIN TNT     5.REQUESTIONER     6.BUDGET CO'.
  WHEN 'SP1' OR 'SP2'.
    va_footer  =
    '1.SUPPLIER     2.FIN/ACC BU     3.FILE    4.FIN TNT     5.REQUESTIONER'.
  WHEN 'FAC'.
    IF wa_hd-bukrs = '8330'.
      va_footer  =
      '1.SUPPLIER      2.FINANCE      3.FILE      4.ADMINISTRASI'.
    ENDIF.
ENDCASE.





















