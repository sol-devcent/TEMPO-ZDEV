FUNCTION ZTEST.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(NILAI1) TYPE  P DEFAULT 0
*"     REFERENCE(NILAI2) TYPE  P DEFAULT 0
*"  EXPORTING
*"     VALUE(PERCENT) TYPE  P
*"----------------------------------------------------------------------
PERCENT = ( ( NILAI2 - NILAI1 ) * 100 ) / NILAI1.

ENDFUNCTION.
