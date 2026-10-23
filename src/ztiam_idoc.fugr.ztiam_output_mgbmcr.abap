FUNCTION ZTIAM_OUTPUT_MGBMCR.
*"--------------------------------------------------------------------
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
*"--------------------------------------------------------------------
  DATA: lv_mblnr    TYPE mblnr,
        lv_mjahr    TYPE mjahr,
        lv_string   TYPE string.

  DATA: a(1).

** check type goods movement
  PERFORM f_check_type_goodsmvt.

* predefine data
  MOVE object TO nast.

  lv_mblnr  = nast-objky(10).
  lv_mjahr  = nast-objky+10(4).

  PERFORM f_get_material_document_data USING lv_mblnr     "MSEG, MKPF, EKKO, EKPO
                                             lv_mjahr.


  PERFORM f_get_idoctype_complete USING c_idoctyp_imm02
                                        space.

  PERFORM f_generate_ctrl_data_prc_code.

  PERFORM f_generate_data_record_mgbmcr.

  MOVE control_record_in TO control_record_out.
  control_record_out-direct   = '1'.
  control_record_out-serial   = sy-datum.
  control_record_out-serial+8 = sy-uzeit.

ENDFUNCTION.
