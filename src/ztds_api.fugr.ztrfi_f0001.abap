FUNCTION ztrfi_f0001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PROSES) TYPE  CHAR15 DEFAULT 'TR_APPROVAL'
*"     VALUE(INVOICE_NO) TYPE  ZINVNO
*"  EXPORTING
*"     VALUE(STATUS) TYPE  CHAR1
*"     VALUE(MESSAGE) TYPE  CHAR100
*"----------------------------------------------------------------------
  TYPES : BEGIN OF text,
            line(1500),
          END OF text.
  DATA: p_proses(15) VALUE 'TR_APPROVAL'.
  DATA : gt_response_body     TYPE TABLE OF text WITH HEADER LINE.
  DATA: lv_str TYPE string,
        lv_invoice_no  TYPE  zinvno.
  CLEAR: lv_str.
  p_proses =  proses. "'TMART_EVOUCHER'.
  lv_invoice_no = invoice_no.
  CONCATENATE '{ "budget_no" : "' invoice_no '" } ' INTO gt_response_body-line.
  APPEND gt_response_body.
  PERFORM f_get_data_json_json(ztdsit_i001) TABLES   gt_response_body
                                         USING    p_proses
                                         CHANGING lv_str sy-subrc.
  IF lv_str IS NOT INITIAL.
    PERFORM f_convert_json_trapproval USING lv_str lv_invoice_no.
    status = gv_status.
    message = gv_message.
  ENDIF.
ENDFUNCTION.
