FUNCTION zmdsfi_f001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_PROCESS) TYPE  CHAR30
*"     VALUE(PI_DATA) TYPE  STRING
*"     REFERENCE(PI_REFERENCE) TYPE  CHAR40 OPTIONAL
*"  EXPORTING
*"     REFERENCE(PI_TYPE) TYPE  CHAR1
*"     REFERENCE(PI_MESSAGE) TYPE  BAPI_MSG
*"     REFERENCE(PI_DOCUMENT) TYPE  CHAR40
*"     REFERENCE(PI_EXPORT) TYPE  STRING
*"----------------------------------------------------------------------


  CASE pi_process.
    WHEN 'MST_DELIVERYMAN'.
      PERFORM f_proses_mst_deliveryman USING pi_data pi_reference CHANGING pi_type pi_message pi_document pi_export.
    WHEN 'MST_VEHICLE'.
      PERFORM f_proses_mst_vehicle USING pi_data pi_reference CHANGING pi_type pi_message pi_document pi_export.
    WHEN 'ADV_UJP'.
      PERFORM f_proses_adv_ujp USING pi_data pi_reference CHANGING pi_type pi_message pi_document pi_export.
    WHEN 'SETTLEMENT_UJP'.
      PERFORM f_proses_set_ujp USING pi_data pi_reference CHANGING pi_type pi_message pi_document pi_export.
    WHEN 'POST_SHIPMENT'.
      PERFORM f_proses_post_shipment USING pi_data pi_reference CHANGING pi_type pi_message pi_document pi_export.
    WHEN 'CANCEL_ADV'.
      PERFORM f_proses_cancel_adv USING pi_data pi_reference CHANGING pi_type pi_message pi_document pi_export.
    WHEN OTHERS.
  ENDCASE.
ENDFUNCTION.
