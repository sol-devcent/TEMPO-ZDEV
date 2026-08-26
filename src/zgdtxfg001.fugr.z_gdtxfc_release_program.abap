FUNCTION Z_GDTXFC_RELEASE_PROGRAM .
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(FI_REPID) TYPE  REPID
*"  EXPORTING
*"     VALUE(FE_SUBRC) LIKE  SY-SUBRC
*"  EXCEPTIONS
*"      NO_PROGRAM_FOUND
*"----------------------------------------------------------------------
  fe_subrc = 0.
  CLEAR zgdtxdt0106.
  SELECT SINGLE * FROM zgdtxdt0106
                  WHERE txprog = fi_repid.
  fe_subrc = sy-subrc.
  IF fe_subrc = 0.
    CLEAR: zgdtxdt0106-status, zgdtxdt0106-uname.
    MODIFY zgdtxdt0106.
  ELSE.
    MESSAGE e000(zab) RAISING no_program_found.
  ENDIF.

ENDFUNCTION.
