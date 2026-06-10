FUNCTION zwmsfm006.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_CHECK) TYPE  CHAR10 OPTIONAL
*"     VALUE(PI_VALUE) TYPE  STRING OPTIONAL
*"  EXPORTING
*"     VALUE(PE_SUBRC) TYPE  SY-SUBRC
*"----------------------------------------------------------------------
  DATA : lv_string TYPE string,
         lv_length TYPE i,
         lv_char   TYPE c LENGTH 1000,
         lv_pos    TYPE sy-tabix.

  lv_string = pi_value.

  CASE pi_check.
    WHEN 'NUMERIC'.
      lv_length = strlen( lv_string ).
      DO lv_length TIMES.
        lv_char = lv_string+lv_pos(1).
        IF lv_char CA 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.
          pe_subrc = 4.
          EXIT.
        ENDIF.
        lv_pos = lv_pos + 1.
      ENDDO.
  ENDCASE.


ENDFUNCTION.
