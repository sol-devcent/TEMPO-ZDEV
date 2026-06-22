FUNCTION zsfasd_f002.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_SUBRC) TYPE  SY-SUBRC
*"     VALUE(PI_FUNCTION) TYPE  RS38L-NAME
*"  EXPORTING
*"     REFERENCE(PE_MESSAGE) TYPE  BAPI_MSG
*"----------------------------------------------------------------------

  CASE pi_function.
    WHEN 'SD_CUSTOMER_MAINTAIN_ALL'.
      CASE pi_subrc.
        WHEN 1.
          pe_message = 'CLIENT_ERROR'.
        WHEN 2.
          pe_message = 'KNA1_INCOMPLETE'.
        When 3.
          pe_message = 'KNB1_INCOMPLETE'.
        WHEN 4.
          pe_message = 'KNB5_INCOMPLETE'.
        WHEN 5.
          pe_message = 'KNVV_INCOMPLETE'.
        WHEN 6.
          pe_message = 'KUNNR_NOT_UNIQUE'.
        WHEN 8.
          pe_message = 'SALES_AREA_NOT_UNIQUE'.
        WHEN 9.
          pe_message = 'SALES_AREA_NOT_VALID'.
        WHEN 10.
          pe_message = 'INSERT_UPDATE_CONFLICT'.
        WHEN 11.
          pe_message = 'NUMBER_ASSIGNMENT_ERROR'.
        WHEN 12.
          pe_message = 'NUMBER_NOT_IN_RANGE'.
        WHEN 13.
          pe_message = 'NUMBER_RANGE_NOT_EXTERN'.
        WHEN 14.
          pe_message = 'NUMBER_RANGE_NOT_INTERN'.
        WHEN 15.
          pe_message = 'ACCOUNT_GROUP_NOT_VALID'.
        WHEN 16.
          pe_message = 'PARNR_INVALID'.
        WHEN 17.
          pe_message = 'BANK_ADDRESS_INVALID'.
        WHEN 18.
          pe_message = 'TAX_DATA_NOT_VALID'.
        WHEN 19.
          pe_message = 'NO_AUTHORITY'.
        WHEN 20.
          pe_message = 'COMPANY_CODE_NOT_UNIQUE'.
        WHEN 21.
          pe_message = 'DUNNING_DATA_NOT_VALID'.
        WHEN 22.
          pe_message = 'KNB1_REFERENCE_INVALID'.
        WHEN 23.
          pe_message = 'CAM_ERROR'.
        WHEN OTHERS.
          pe_message = 'Error Outher'.
     ENDCASE.

  ENDCASE.
ENDFUNCTION.
