FUNCTION zfmwait.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_COUNT) TYPE  I DEFAULT 10
*"----------------------------------------------------------------------
  DATA : t1    TYPE t,
         t2    TYPE t,
         tdiff TYPE i.

  t1 = sy-uzeit.

  DO.
    GET TIME FIELD t2.
    tdiff = t2 - t1.
    IF tdiff >= pi_count.
      EXIT.
    ENDIF.
  ENDDO.
ENDFUNCTION.
