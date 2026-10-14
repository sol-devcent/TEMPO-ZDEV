FUNCTION ZTNFMM_F001 .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_PROSES) TYPE  CHAR15
*"     VALUE(PI_DATA) TYPE  STRING
*"     REFERENCE(PI_DOCUMENT) TYPE  CHAR35 OPTIONAL
*"  EXPORTING
*"     REFERENCE(PE_PR_NUMBER) TYPE  BANFN
*"     REFERENCE(PE_PR_DATE) TYPE  ERDAT
*"     REFERENCE(PE_TYPE) TYPE  BAPI_MTYPE
*"     REFERENCE(PE_MESSAGE) TYPE  BAPI_MSG
*"  EXCEPTIONS
*"      CUSTOM_EXCEPTION
*"----------------------------------------------------------------------
  CASE pi_proses.
    WHEN 'CREATE_PRTNF'.
          PERFORM f_create_pr_tnf USING pi_data pi_document CHANGING pe_type pe_message pe_pr_number pe_pr_date.

    WHEN OTHERS.
  ENDCASE.


ENDFUNCTION.
