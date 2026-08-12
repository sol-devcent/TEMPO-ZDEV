FUNCTION zdmpfm001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_PROCESS) TYPE  CHAR30
*"     VALUE(PI_DATA) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(PE_SECOND) TYPE  INT4
*"     REFERENCE(PE_MESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      LINES STRUCTURE  TLINE OPTIONAL
*"----------------------------------------------------------------------

  IF pi_data IS NOT INITIAL.
    CASE pi_process.
      WHEN 'GET_HOUR'.
        PERFORM f_get_hour USING    pi_data
                           CHANGING pe_second.

      WHEN 'POST_COR6N'.
        PERFORM f_post_cor6n TABLES   lines
                             USING    pi_data
                             CHANGING pe_message.

      WHEN OTHERS.
    ENDCASE.
  ENDIF.



ENDFUNCTION.
