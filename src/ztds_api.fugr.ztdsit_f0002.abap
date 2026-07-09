FUNCTION ztdsit_f0002.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(ZTEXTIN) TYPE  TEXT1024
*"  EXPORTING
*"     VALUE(ZTEXTOUT) TYPE  TEXT1024
*"----------------------------------------------------------------------
  DATA: c_alfanumeric(70) TYPE c VALUE '1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM '.

  IF ztextin CN c_alfanumeric.
    REPLACE ALL OCCURRENCES OF '&' IN ztextin WITH ' ' .
    REPLACE ALL OCCURRENCES OF '\''' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '/' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '''' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '"' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '{' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '}' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '[' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF ']' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '>' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '<' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '.' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF ',' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '~' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '@' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '#' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '$' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '%' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '^' IN ztextin WITH ' '.
    REPLACE ALL OCCURRENCES OF '*' IN ztextin WITH ' '.
  ENDIF.
  ztextout = ztextin.


ENDFUNCTION.
