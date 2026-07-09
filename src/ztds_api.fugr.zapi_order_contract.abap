FUNCTION zapi_order_contract.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(NO_CONTRACT) TYPE  BSTKD
*"  EXPORTING
*"     VALUE(SALESDOCUMENT) LIKE  BAPIVBELN-VBELN
*"     VALUE(ZMESSAGE) TYPE  CHAR255
*"     VALUE(ZSTATUS) TYPE  CHAR1
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"----------------------------------------------------------------------
  DATA: lv_data(20).
  DATA: lv_return(1).
  DATA: p_sales_order(10),
        p_message(255),
        p_status(1).
  gv_contract = no_contract.
  PERFORM f_get_data_contract USING gv_contract CHANGING lv_return gv_str.
  IF lv_return IS INITIAL.
    PERFORM f_convert_json_contract USING gv_str CHANGING p_sales_order p_message p_status. "gt_goodsmvt.
    salesdocument = p_sales_order.
    zstatus = p_status.
    IF p_message IS INITIAL.
      zmessage = p_sales_order.
    ELSE.
      zmessage = p_message.
    ENDIF.
  ELSE.
    zstatus = lv_return.
    IF gv_str IS INITIAL.
      zmessage = 'Data tidak ditemukan'.
    ENDIF.
  ENDIF.
ENDFUNCTION.
