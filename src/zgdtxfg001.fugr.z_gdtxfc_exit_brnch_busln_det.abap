FUNCTION z_gdtxfc_exit_brnch_busln_det.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(FI_VBRK) LIKE  ZGDTXST0007 STRUCTURE  ZGDTXST0007
*"  EXPORTING
*"     VALUE(FE_VBRK) LIKE  ZGDTXST0007 STRUCTURE  ZGDTXST0007
*"     VALUE(FE_SUBRC) LIKE  SY-SUBRC
*"  TABLES
*"      FT_TX00101 STRUCTURE  ZGDTXDT0101
*"      FT_ERROR STRUCTURE  ZGDTXST0011
*"----------------------------------------------------------------------
*&  This function maps the branch and busln based on whatever criteria
*&  defined for the implementation. This routine will be changed based
*&  on implementation
*----------------------------------------------------------------------*

***TSP,SFF,TNT

  fe_vbrk = fi_vbrk.
  CLEAR fe_subrc.

*---Determine branch
*   For Tempo: branch is Company code
  READ TABLE ft_tx00101 WITH KEY bukrs = fi_vbrk-bukrs
                                 brnch = fi_vbrk-bukrs.
*                                 brnch = fi_vbrk-gsber.
  IF sy-subrc <> 0.
    MOVE-CORRESPONDING fi_vbrk TO ft_error.
    ft_error-msg = 'Branch is not defined'.
    APPEND ft_error.
    fe_subrc = 1.
    EXIT.
  ENDIF.
  fe_vbrk-brnch = ft_tx00101-brnch.

*---Determine business line
  fe_vbrk-busln = '01'.  "Trade business line

**---Determine Autopart business line (based on ZUKRI field)
*  IF NOT fi_vbrk-zukri+13(10) IS INITIAL.
*    SELECT SINGLE busln INTO fe_vbrk-busln
*                        FROM ZGDTXdt0107
*                        WHERE sortl = fi_vbrk-zukri+13(10).
*    IF sy-subrc <> 0.
*      MOVE-CORRESPONDING fi_vbrk TO ft_error.
*      ft_error-msg = 'Business line is not defined'.
*      APPEND ft_error.
*      fe_subrc = 2.
*      EXIT.
*    ENDIF.
*  ENDIF.

ENDFUNCTION.
