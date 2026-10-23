FUNCTION ztiam_imm02.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_PROSES) TYPE  CHAR15
*"     VALUE(PI_DATA) TYPE  STRING
*"     REFERENCE(PI_NOWEB) TYPE  CHAR20 OPTIONAL
*"  EXPORTING
*"     REFERENCE(PE_NOSAP) TYPE  CHAR20
*"     REFERENCE(PE_STATUS) TYPE  CHAR1
*"     REFERENCE(PE_MESSAGE_ERROR) TYPE  CHAR200
*"     REFERENCE(PE_LOG_ERROR) TYPE  STRING
*"----------------------------------------------------------------------
  DATA: lv_proses(15),
        lv_po_web        TYPE char20,
        lv_json          TYPE string,
        lv_nopo          TYPE ebeln,
        lv_status(1),
        lv_message_error TYPE char200.
  lv_proses = pi_proses.
  lv_po_web = pi_noweb.
  CONDENSE: lv_proses, lv_po_web.
  CASE lv_proses.
    WHEN 'PO_TIAM'.
      lv_json = pi_data.
      PERFORM f_create_po_tiam USING lv_po_web lv_json CHANGING lv_nopo lv_status lv_message_error pe_log_error.
      "      PERFORM f_create_order_sfa USING lv_order_sfa lv_json CHANGING lv_quotation lv_status lv_message_error.
    WHEN OTHERS.

  ENDCASE.
  CONDENSE: lv_nopo, lv_status, lv_message_error.
  pe_nosap = lv_nopo.
  pe_status = lv_status.
  pe_message_error = lv_message_error.
ENDFUNCTION.
