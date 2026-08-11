DATA: ld_stkza LIKE kna1-stkza.

*IF header-budat(4) GT 2006.
*  SELECT SINGLE stkza
*    FROM kna1
*    INTO ld_stkza
*    WHERE kunnr EQ header-kunnr.
*
*  IF ld_stkza EQ 'X'.
*    CONCATENATE header-stceg '     N.P.P.K.P :' header-stceg
*      INTO va_npwp
*      SEPARATED BY space.
*  ELSE.
*    CONCATENATE header-stceg '     N.P.P.K.P :'
*      INTO va_npwp
*      SEPARATED BY space.
*  ENDIF.
*ELSE.
  va_npwp = header-stceg.
*ENDIF.
























