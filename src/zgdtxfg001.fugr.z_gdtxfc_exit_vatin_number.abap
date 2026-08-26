FUNCTION z_gdtxfc_exit_vatin_number.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(FI_BSEG) LIKE  ZGDTXST0008 STRUCTURE  ZGDTXST0008
*"     VALUE(FI_BSEG2) LIKE  ZGDTXST0008 STRUCTURE  ZGDTXST0008
*"       OPTIONAL
*"  EXPORTING
*"     VALUE(FE_FAKTURNO) LIKE  ZGDTXDT0012-FAKTURNO
*"----------------------------------------------------------------------

*----------------------------------------------------------------------*
* This user exit is to determine how to get Faktur pajak number from   *
* an accounting document. The field used for storing Faktur pajak no   *
* must be included in structure ZGDTXST0008                            *
* The optional passing parameter is used if we need to get additional  *
* data to be part of VAT-in FP number                                  *
*----------------------------------------------------------------------*

***Tempo: Faktur pajak no. is stored as combination between
***STCD1, STCD2 and ZUONR
  DATA: ld_len TYPE i.

  ld_len = strlen( fi_bseg-bktxt ).
  ld_len = ld_len - 4.

  IF fi_bseg-bktxt+ld_len(4) GT 2006.
    fe_fakturno = fi_bseg-zuonr.
  ELSE.
    IF fi_bseg2-stcd1 IS INITIAL.
*---PIUD/PIB Number
      fe_fakturno = fi_bseg-zuonr.
    ELSE.
*---Common FP number
      CONCATENATE fi_bseg2-stcd1
             '-'
*              fi_bseg-stcd2
                  fi_bseg-zuonr
                  INTO fe_fakturno.
*                SEPARATED BY '-'.
    ENDIF.
  ENDIF.
ENDFUNCTION.
