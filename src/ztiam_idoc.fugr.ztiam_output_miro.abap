FUNCTION ZTIAM_OUTPUT_MIRO.
*"----------------------------------------------------------------------
*"*"Global Interface:
*"  IMPORTING
*"     REFERENCE(OBJECT) TYPE  NAST
*"     REFERENCE(CONTROL_RECORD_IN) TYPE  EDIDC
*"  EXPORTING
*"     REFERENCE(OBJECT_TYPE) TYPE  WFAS1-ASGTP
*"     REFERENCE(CONTROL_RECORD_OUT) TYPE  EDIDC
*"  TABLES
*"      INT_EDIDD STRUCTURE  EDIDD
*"  EXCEPTIONS
*"      ERROR_MESSAGE_RECEIVED
*"      FIELDMAP_NOT_FOUND
*"      MATERIAL_DOCUMENT_NOT_FOUND
*"----------------------------------------------------------------------
  DATA: lv_belnr    TYPE belnr_d,
        lv_gjahr    TYPE gjahr,
        lv_string   TYPE string.

data: a(1).
*** check type invoice
  PERFORM f_check_type_invoice.

* predefine data
  MOVE object TO nast.

  lv_belnr  = nast-objky+4(10).
  lv_gjahr  = nast-objky+14(4).

  PERFORM f_get_invoice_data USING lv_belnr
                                   lv_gjahr.

  PERFORM f_get_idoctype_complete USING c_idoctyp_inv02
                                        space.

  PERFORM f_gen_ctrl_data_prc_code_inv.


  PERFORM f_generate_data_record_invoice. " USING lv_belnr
                                           "    lv_gjahr.

  MOVE control_record_in TO control_record_out.
  control_record_out-direct   = '1'.
  control_record_out-serial   = sy-datum.
  control_record_out-serial+8 = sy-uzeit.


ENDFUNCTION.
