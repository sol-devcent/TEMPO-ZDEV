FUNCTION zwmsfm004.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_PROCESS) TYPE  CHAR30 OPTIONAL
*"     VALUE(PI_LGNUM) TYPE  LTAK-LGNUM OPTIONAL
*"     VALUE(PI_TANUM) TYPE  LTAK-TANUM OPTIONAL
*"     REFERENCE(PI_STRDT) TYPE  SY-DATUM OPTIONAL
*"     REFERENCE(PI_STRTM) TYPE  SY-UZEIT OPTIONAL
*"     REFERENCE(PI_ENDDT) TYPE  SY-DATUM OPTIONAL
*"     REFERENCE(PI_ENDTM) TYPE  SY-UZEIT OPTIONAL
*"----------------------------------------------------------------------

  CASE pi_process.
    WHEN 'PUTAWAY'.
      TRY .
          UPDATE ltak SET stdat = pi_strdt
                          stuzt = pi_strtm
                          endat = pi_enddt
                          enuzt = pi_endtm
                WHERE lgnum = pi_lgnum
                  AND tanum = pi_tanum.
        CATCH cx_sy_open_sql_db.
      ENDTRY.
  ENDCASE.



ENDFUNCTION.
