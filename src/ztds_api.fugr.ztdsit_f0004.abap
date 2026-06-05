FUNCTION ZTDSIT_F0004.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(ZTEXTIN) TYPE  TEXT1024
*"  EXPORTING
*"     VALUE(ZTEXTOUT) TYPE  TEXT1024
*"--------------------------------------------------------------------
  DATA: c_alfanumeric(70) TYPE c VALUE '1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM '.

  IF ztextin CN c_alfanumeric.
    REPLACE ALL OCCURRENCES OF '&' IN ztextin WITH '&#38;' .
 "   REPLACE ALL OCCURRENCES OF '\' IN ztextin WITH '"\" '.
 "   REPLACE ALL OCCURRENCES OF '/' IN ztextin WITH '"/" '.
    REPLACE ALL OCCURRENCES OF '''' IN ztextin WITH '&#39;'.
    REPLACE ALL OCCURRENCES OF '"' IN ztextin WITH '&#34;'.
 "   REPLACE ALL OCCURRENCES OF '{' IN ztextin WITH '"{"'.
 "   REPLACE ALL OCCURRENCES OF '}' IN ztextin WITH '"}"'.
 "   REPLACE ALL OCCURRENCES OF '[' IN ztextin WITH '"["'.
 "   REPLACE ALL OCCURRENCES OF ']' IN ztextin WITH '"]"'.
    REPLACE ALL OCCURRENCES OF '>' IN ztextin WITH '&#62;'.
    REPLACE ALL OCCURRENCES OF '<' IN ztextin WITH '&#60;'.
"    REPLACE ALL OCCURRENCES OF '.' IN ztextin WITH '"."'.
"    REPLACE ALL OCCURRENCES OF ',' IN ztextin WITH '","'.
"    REPLACE ALL OCCURRENCES OF '~' IN ztextin WITH '"~"'.
"    REPLACE ALL OCCURRENCES OF '@' IN ztextin WITH '"@"'.
"    REPLACE ALL OCCURRENCES OF '#' IN ztextin WITH '"#"'.
"    REPLACE ALL OCCURRENCES OF '$' IN ztextin WITH '"$"'.
"    REPLACE ALL OCCURRENCES OF '%' IN ztextin WITH '"%"'.
"    REPLACE ALL OCCURRENCES OF '^' IN ztextin WITH '"^"'.
"    REPLACE ALL OCCURRENCES OF '*' IN ztextin WITH '"*"'.
  ENDIF.
  ztextout = ztextin.


ENDFUNCTION.
