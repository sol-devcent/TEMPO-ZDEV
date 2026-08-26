FUNCTION z_gdtxfc_check_tax_period.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  EXPORTING
*"     VALUE(FE_STATUS) TYPE  CHAR01
*"     VALUE(FE_UNAME) LIKE  SY-UNAME
*"  EXCEPTIONS
*"      PROGRAM_RUNNING
*"      TAX_PERIOD_PROGRAM_NOT_FOUND
*"----------------------------------------------------------------------
  DATA: tx04usr LIKE indx-srtfd VALUE 'ZGDTXDT0106'.

  CLEAR: zgdtxdt0106, fe_status.
  SELECT SINGLE * FROM zgdtxdt0106
                  WHERE txprog = 'ZGDTX_E0012'.
  IF sy-subrc <> 0.
    MESSAGE e000(zab) RAISING tax_period_program_not_found.
  ELSE.
    IF zgdtxdt0106-status = 'R'.
      fe_status = 'R'.
      fe_uname = zgdtxdt0106-uname.
      EXPORT zgdtxdt0106-uname TO MEMORY ID tx04usr.
      MESSAGE e000(zab) RAISING program_running.
    ENDIF.
  ENDIF.

ENDFUNCTION.
