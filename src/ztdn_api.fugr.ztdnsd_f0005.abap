FUNCTION ztdnsd_f0005.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(NO_ORDER) TYPE  CHAR25
*"  EXPORTING
*"     VALUE(NO_AWB) TYPE  ZNOAWB
*"     VALUE(STATUS) TYPE  CHAR1
*"     VALUE(MESSAGE) TYPE  CHAR100
*"----------------------------------------------------------------------
  TYPES : BEGIN OF text,
          line(1500),
        END OF text.
  DATA: p_proses(15) VALUE 'TDN_RELOADAWB'.
  DATA : gt_response_body     TYPE TABLE OF text WITH HEADER LINE.
  DATA: gv_str TYPE string,
        gv_err TYPE sysubrc.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        gv_json             TYPE string.

  p_proses =  'TDN_RELOADAWB'.
  CONCATENATE '{ "no_order": "' no_order '" } ' INTO gt_response_body-line.
  APPEND gt_response_body.

  PERFORM f_get_data_json_json(ztdsit_i001) TABLES   gt_response_body
                                         USING    p_proses
                                         CHANGING gv_str gv_err.

  FIND 'awb_image' IN gv_str.
  IF sy-subrc EQ 0.
    REPLACE ALL OCCURRENCES OF '\' IN gv_str WITH ''.
    CLEAR: gv_err.
    PERFORM f_convert_json_awb USING gv_str CHANGING gt_awbimage.
    IF gt_awbimage-awb_image[] IS NOT INITIAL.
      PERFORM f_save_to_table USING gt_awbimage.
      no_awb = gv_noawb.
      status = gv_status.
      message = gv_message.
    ENDIF.

  ELSE.
    gv_err = 4.
  ENDIF.




ENDFUNCTION.
