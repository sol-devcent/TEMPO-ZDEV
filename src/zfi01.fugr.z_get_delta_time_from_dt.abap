FUNCTION Z_GET_DELTA_TIME_FROM_DT.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(T1) TYPE  T
*"     VALUE(T2) TYPE  T
*"     VALUE(D1) TYPE  D
*"     VALUE(D2) TYPE  D
*"  EXPORTING
*"     VALUE(T3) TYPE  T
*"----------------------------------------------------------------------
  DATA:
    SEC TYPE P,
    MIN TYPE P DECIMALS 2,
    HOU TYPE P DECIMALS 2,
    TSTR(7),
    THELP TYPE T VALUE '240000',
    DAYS TYPE I,
    TINT TYPE I.


  IF D2 GE D1.

    DAYS = D2 - D1.
    DAYS = DAYS - 1.


    TINT = T2 - T1.
    TINT = TINT + 86400.

    HOU = TRUNC( TINT / 3600 ).
    MIN = TRUNC( ( TINT - HOU * 3600 ) / 60 ).
    SEC = TINT - HOU * 3600 - MIN * 60.
    TINT = 1000000 + ( HOU * 10000 )  + ( MIN * 100 ) + SEC.
    TINT = TINT + DAYS * 240000.
    TSTR = TINT.
    SHIFT TSTR BY 1 PLACES LEFT.
    T3 = TSTR.
  ELSE.
    T3 = '000000'.
  ENDIF.
*  IF T3 > '240000'.
*    T3 = '000000'.
*  endif.
ENDFUNCTION.
