FUNCTION Z_GDTXFC_EXIT_ADDT_INF .
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(FI_VBRK) LIKE  ZGDTXST0007 STRUCTURE  ZGDTXST0007
*"  EXPORTING
*"     VALUE(FE_VBRK) LIKE  ZGDTXST0007 STRUCTURE  ZGDTXST0007
*"----------------------------------------------------------------------

fe_vbrk = fi_vbrk.

*----------------------------------------------------------------------*
*  Please put company specific additional information for tax system   *
*  down here. Make sure that the fields for the additional info are    *
*  already in ZGDTXST0007 structure                                    *
*----------------------------------------------------------------------*



ENDFUNCTION.
