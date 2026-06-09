FUNCTION ztdnsd_f0008.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(NO_SHIPMENT) TYPE  EXTI1
*"  EXPORTING
*"     VALUE(STATUS) TYPE  CHAR1
*"     VALUE(MESSAGE) TYPE  CHAR100
*"----------------------------------------------------------------------
  TYPES : BEGIN OF text,
          line(1500),
        END OF text.

  DATA: p_proses(15) VALUE 'TMART_SHIPSTART'.
  DATA : lt_response_body     TYPE TABLE OF text WITH HEADER LINE.
  DATA: lv_str TYPE string.
  DATA: lv_exti1 TYPE exti1.
  DATA: p_return(1).
  p_proses =  'TMART_SHIPSTART'.
  lv_exti1 = no_shipment.

  CONCATENATE '{ "no_shipment": "' lv_exti1 '" } ' INTO lt_response_body-line.
  APPEND lt_response_body.
  PERFORM f_get_data_json_json(ztdsit_i001) TABLES   lt_response_body
                                         USING    p_proses
                                         CHANGING lv_str sy-subrc.
  IF lv_str IS NOT INITIAL.
    PERFORM f_convert_json_shipment_start USING lv_str CHANGING p_return gv_message.
  ENDIF.

  status = p_return.
  message = gv_message.
ENDFUNCTION.
