FUNCTION zkmmfi_update_xref2.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_BUKRS) TYPE  BUKRS
*"     VALUE(PI_BELNR) TYPE  BELNR_D
*"     VALUE(PI_GJAHR) TYPE  GJAHR
*"     VALUE(PI_HKONT) TYPE  HKONT
*"     VALUE(PI_XREF2) TYPE  XREF2
*"----------------------------------------------------------------------
  IF pi_bukrs = '8360'.
    CLEAR gv_hkont.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = pi_hkont
      IMPORTING
        output = gv_hkont.

    "Update BSEG
    UPDATE bseg SET xref3 = pi_xref2
                WHERE bukrs = pi_bukrs
                  AND belnr = pi_belnr
                  AND gjahr = pi_gjahr.

    "Update BSIS
    UPDATE bsis SET xref3 = pi_xref2
                WHERE bukrs = pi_bukrs
                  AND belnr = pi_belnr
                  AND gjahr = pi_gjahr.

    "Update BSAS
    UPDATE bsas SET xref3 = pi_xref2
                WHERE bukrs = pi_bukrs
                  AND belnr = pi_belnr
                  AND gjahr = pi_gjahr.
  ENDIF.
ENDFUNCTION.
