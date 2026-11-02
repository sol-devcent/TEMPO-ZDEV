FUNCTION zatlmm_f001 .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_PROSES) TYPE  CHAR15
*"     VALUE(PI_DATA) TYPE  STRING
*"     REFERENCE(PI_PO_ATL) TYPE  CHAR35 OPTIONAL
*"  EXPORTING
*"     REFERENCE(PE_PO_NUMBER) TYPE  EBELN
*"     REFERENCE(PE_PO_DATE) TYPE  ERDAT
*"     REFERENCE(PE_TYPE) TYPE  BAPI_MTYPE
*"     REFERENCE(PE_MESSAGE) TYPE  BAPI_MSG
*"     REFERENCE(PE_GR_NUMBER) TYPE  MBLNR
*"     REFERENCE(PE_GR_YEAR) TYPE  MJAHR
*"     REFERENCE(PE_MIRO_NUMBER) TYPE  MBLNR
*"     REFERENCE(PE_MIRO_YEAR) TYPE  MJAHR
*"     REFERENCE(PE_INV_NUMBER) TYPE  BELNR_D
*"     REFERENCE(PE_INV_YEAR) TYPE  GJAHR
*"  EXCEPTIONS
*"      CUSTOM_EXCEPTION
*"----------------------------------------------------------------------
  CASE pi_proses.
    WHEN 'CREATE_POATL'.
          PERFORM f_create_po_atl USING pi_data pi_po_atl CHANGING pe_type pe_message pe_po_number pe_po_date.
    WHEN 'GRATL'.
          PERFORM f_proses_gr_atl USING pi_data pi_po_atl CHANGING pe_type pe_message pe_gr_number pe_gr_year.
    WHEN 'MIROATL'.
          PERFORM f_proses_miro_atl USING pi_data pi_po_atl CHANGING pe_type pe_message pe_miro_number pe_miro_year.
    WHEN 'INVATL'.
          PERFORM f_proses_INV_atl USING pi_data pi_po_atl CHANGING pe_type pe_message pe_inv_number pe_inv_year.
    WHEN OTHERS.
  ENDCASE.
ENDFUNCTION.
