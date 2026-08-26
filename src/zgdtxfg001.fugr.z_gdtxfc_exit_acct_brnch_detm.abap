FUNCTION z_gdtxfc_exit_acct_brnch_detm .
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(FI_BUKRS) TYPE  BUKRS
*"     REFERENCE(FI_BRNCH) TYPE  ZGDTXDE_BRNCH
*"     REFERENCE(FI_BSEG) LIKE  ZGDTXST0008 STRUCTURE  ZGDTXST0008
*"  EXPORTING
*"     REFERENCE(FE_BSEG) LIKE  ZGDTXST0008 STRUCTURE  ZGDTXST0008
*"  TABLES
*"      FT_TX00101 STRUCTURE  ZGDTXDT0101
*"  EXCEPTIONS
*"      BRANCH_IS_NOT_MAINTAINED
*"----------------------------------------------------------------------
*&  This function maps branch for non-trade tax transaction based on
*&  whatever criteria defined for the implementation. This routine will
*&  be changed based on the implementation
*----------------------------------------------------------------------*

  fe_bseg = fi_bseg.

***TSP, SFF, TNT
*---Determine branch
*   For Tempo: branch is Company code
  READ TABLE ft_tx00101 WITH KEY bukrs = fi_bseg-bukrs
                                 brnch = fi_bseg-bukrs.
*                                 brnch = fi_bseg-gsber.
  IF sy-subrc <> 0.
    MESSAGE e000(zab) RAISING branch_is_not_maintained.
  ENDIF.
  fe_bseg-brnch = ft_tx00101-brnch.

ENDFUNCTION.
