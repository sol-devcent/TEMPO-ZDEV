FUNCTION zsff_weight.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_PROCESS) TYPE  CHAR30
*"     VALUE(PI_DATA) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(PE_DATA) TYPE  STRING
*"     REFERENCE(PE_MSGTYP) TYPE  CHAR1
*"     REFERENCE(PE_MESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      PT_FP_PGI STRUCTURE  ZSFFST001_TMP OPTIONAL
*"      PT_WH_PRINT STRUCTURE  ZSFFST003 OPTIONAL
*"      PT_WH_PRINT_VND STRUCTURE  ZSFFST004 OPTIONAL
*"----------------------------------------------------------------------

  IF pi_data IS NOT INITIAL.
    CASE pi_process.
      WHEN 'PF_PGI'.
        PERFORM f_fullpack_pgi TABLES   pt_fp_pgi
                               USING    pi_data
                               CHANGING pe_data pe_msgtyp pe_message.

      WHEN 'WH_PRINT'.
        PERFORM f_wh_print TABLES   pt_wh_print pt_wh_print_vnd
                           USING    pi_data
                           CHANGING pe_data pe_msgtyp pe_message.

      WHEN 'WH_PGI'.
        PERFORM f_wh_pgi USING    pi_data
                         CHANGING pe_data pe_msgtyp pe_message.

      WHEN 'STR_DATE'.
        PERFORM f_str_date USING    pi_data
                           CHANGING pe_data pe_msgtyp pe_message.

      WHEN OTHERS.
    ENDCASE.
  ENDIF.

ENDFUNCTION.
