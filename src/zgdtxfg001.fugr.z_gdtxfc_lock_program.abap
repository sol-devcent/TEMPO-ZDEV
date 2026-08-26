FUNCTION z_gdtxfc_lock_program.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(FI_REPID) TYPE  REPID
*"  EXPORTING
*"     VALUE(FE_UNAME) LIKE  SY-UNAME
*"  EXCEPTIONS
*"      NO_PROGRAM_FOUND
*"      PROGRAM_RUNNING
*"----------------------------------------------------------------------
  DATA: tx04usr LIKE indx-srtfd VALUE 'ZGDTXDT0106'.

  CLEAR: zgdtxdt0106, fe_uname.
  SELECT SINGLE * FROM zgdtxdt0106
                  WHERE txprog = fi_repid.
  IF sy-subrc = 0.
    IF zgdtxdt0106-status = 'R'.
      fe_uname = zgdtxdt0106-uname.
      EXPORT zgdtxdt0106-uname TO MEMORY ID tx04usr.
      MESSAGE e000(zab) RAISING program_running.
    ELSE.
      zgdtxdt0106-status = 'R'.
      zgdtxdt0106-uname = sy-uname.
      MODIFY zgdtxdt0106.
    ENDIF.
  ELSE.
    MESSAGE e000(zab) RAISING no_program_found.
  ENDIF.

ENDFUNCTION.
