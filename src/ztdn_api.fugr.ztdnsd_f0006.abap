FUNCTION ztdnsd_f0006.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(NO_ORDER) TYPE  CHAR25
*"  EXPORTING
*"     VALUE(BELNR) TYPE  BELNR_D
*"     VALUE(STATUS) TYPE  CHAR1
*"     VALUE(MESSAGE) TYPE  CHAR100
*"----------------------------------------------------------------------
  TYPES : BEGIN OF text,
          line(1500),
        END OF text.
  TYPES : BEGIN OF ty_result,
           order_id TYPE string,
           status TYPE string,
           message TYPE string,
         END OF ty_result.
  DATA: ls_result TYPE ty_result.
  DATA: p_proses(15) VALUE 'TMART_EVOUCHER'.
  DATA : gt_response_body     TYPE TABLE OF text WITH HEADER LINE.
  DATA: lv_str TYPE string.
  DATA: lv_order TYPE bstkd.
  DATA: p_return(1).
  DATA: lv_status(1), lv_message(100).
  "gv_err TYPE sysubrc.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        lv_json             TYPE string.

  p_proses =  'TMART_EVOUCHER'.
  lv_order = no_order.
  SELECT SINGLE order_id INTO lv_order FROM ztdnsddt010 WHERE order_id = lv_order.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'ZTDNSD_F0007'
      EXPORTING
        no_order = lv_order " phone_number = lv_phone
      IMPORTING
        status   = lv_status
        MESSAGE  = lv_message.
    message = lv_message.
    status = lv_status.
  ELSE.
    lv_order = no_order.
    CONCATENATE '{ "order_id": "' lv_order '" } ' INTO gt_response_body-line.
    APPEND gt_response_body.
**    CONCATENATE '{ "order_id": "' lv_order '" } ' INTO lv_json.
**    PERFORM f_post_data_json(ztdsit_i001) USING lv_json p_proses sy-subrc lv_str.

    PERFORM f_get_data_json_json(ztdsit_i001) TABLES   gt_response_body
                                           USING    p_proses
                                           CHANGING lv_str sy-subrc.
    IF lv_str IS NOT INITIAL.
      PERFORM f_convert_json_voucher USING lv_str CHANGING gs_evoucher.
      IF gs_evoucher-items[] IS NOT INITIAL.
        PERFORM f_save_to_voucher USING gs_evoucher CHANGING p_return.
        gv_status = 'S'.
        IF gt_error[] IS NOT INITIAL.
          LOOP AT gt_error ASSIGNING <fs_err>.
            gv_message = <fs_err>-MESSAGE.
            gv_status = 'E'.
          ENDLOOP.
        ELSEIF p_return IS NOT INITIAL.
          LOOP AT gt_outlog ASSIGNING <fs_out>.
            CONCATENATE  <fs_out>-vcrno <fs_out>-vcr_encrp <fs_out>-matnr   INTO gv_message SEPARATED BY '|'.
            gv_status = 'E'.
          ENDLOOP.
        ENDIF.
        belnr = gv_belnr.
        status = gv_status.
        message = gv_message.
      ELSE.
        gv_status = 'E'.
        CONDENSE lv_order.
        REPLACE ALL OCCURRENCES OF '{' IN lv_str WITH '' .
        REPLACE ALL OCCURRENCES OF '}' IN lv_str WITH '' .
        REPLACE ALL OCCURRENCES OF '"' IN lv_str WITH '' .
        gv_message = lv_str.
      ENDIF.
    ELSE.
      gv_status = 'E'.
      CONDENSE lv_order.
      CONCATENATE lv_order  '-Data tidak ditemukan' INTO gv_message.
    ENDIF.
    status = gv_status.
    message = gv_message.
    IF gv_status = 'S'.
      CLEAR: lv_json.
      "    CONCATENATE '{ "order_id": "' lv_order '" } ' INTO lv_json.
      ls_result-order_id = lv_order.
      ls_result-status = gv_status.
      ls_result-message = gv_message.

      CREATE OBJECT cl_json_data
        EXPORTING
          DATA = ls_result.
      cl_json_data->serialize( ).
      lv_json = cl_json_data->get_data( ).
      PERFORM f_post_data_json(ztdsit_i001) USING lv_json 'TMART_STATUS' sy-subrc lv_str.
      REPLACE ALL OCCURRENCES OF '{' IN lv_str WITH '' .
      REPLACE ALL OCCURRENCES OF '}' IN lv_str WITH '' .
      REPLACE ALL OCCURRENCES OF '"' IN lv_str WITH '' .
      message = lv_str.
    ENDIF.
  ENDIF.
ENDFUNCTION.
