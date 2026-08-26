FUNCTION z_gdtxfc_exit_vatin_date.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(FI_BSEG) LIKE  ZGDTXST0008 STRUCTURE  ZGDTXST0008
*"  EXPORTING
*"     VALUE(FE_FAKDAT) LIKE  ZGDTXDT0003-FAKDAT
*"     VALUE(FE_MASATX) LIKE  ZGDTXDT0003-MASATX
*"----------------------------------------------------------------------

*----------------------------------------------------------------------*
* This user exit is to determine where to get Faktur pajak date from   *
* an accounting document.                                              *
* The field used for storing FP date must be defined in structure      *
* ZGDTXST0008                                                          *
*----------------------------------------------------------------------*

***added for Tempo
***Faktur pajak date is taken from document header text (BKTXT)
  CONCATENATE fi_bseg-bktxt+6(4)
              fi_bseg-bktxt+3(2)
              fi_bseg-bktxt+(2) INTO fe_fakdat.

  CONCATENATE fi_bseg-bktxt+6(4)
              fi_bseg-bktxt+3(2)
              INTO fe_masatx.
***end of addition



ENDFUNCTION.
