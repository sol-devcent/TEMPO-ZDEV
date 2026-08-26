FUNCTION z_gdtxfc_exit_ppnbm_item_detm .
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(FI_VBRK) LIKE  ZGDTXST0007 STRUCTURE  ZGDTXST0007
*"  EXPORTING
*"     VALUE(FE_SUBRC) LIKE  SY-SUBRC
*"----------------------------------------------------------------------
  DATA ld_matnr LIKE mara-matnr.

  CLEAR ld_matnr.
*  CASE fi_vbrk-bukrs.
*    WHEN '1000'.
*      SELECT SINGLE matnr INTO ld_matnr
*                          FROM a004
*                          WHERE
*                                kappl = 'V' AND
*                                kschl = 'ZA52' AND
*                                matnr = fi_vbrk-matnr AND
*                                datbi GE fi_vbrk-fkdat.
*      fe_subrc = sy-subrc.
*  ENDCASE.
  fe_subrc = 0.

ENDFUNCTION.
