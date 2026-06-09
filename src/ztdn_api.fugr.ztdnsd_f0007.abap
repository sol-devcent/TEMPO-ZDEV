FUNCTION ztdnsd_f0007.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(NO_ORDER) TYPE  BSTKD
*"  EXPORTING
*"     VALUE(STATUS) TYPE  CHAR1
*"     VALUE(MESSAGE) TYPE  CHAR100
*"----------------------------------------------------------------------
  TYPES : BEGIN OF ty_result,
          order_id TYPE string,
          status TYPE string,
          message TYPE string,
        END OF ty_result.
  DATA: ls_result TYPE ty_result.
  DATA: p_proses(15) VALUE 'TMART_STATUS'.
  DATA: lv_str TYPE string.
  DATA: lv_order TYPE bstkd.
  DATA: p_return(1).
  DATA: lt_ztdnsddt010 TYPE STANDARD TABLE OF ztdnsddt010.
  DATA: ls_ztdnsddt010 TYPE ztdnsddt010.
  "gv_err TYPE sysubrc.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        lv_json             TYPE string.
  data: lv_belnr type VBELN.
  p_proses =  'TMART_EVOUCHER'.
  lv_order = no_order.
  "  perform f_proses_voucher using lv_order.
**  SELECT * INTO CORRESPONDING FIELDS OF TABLE  lt_ztdnsddt010 FROM ztdnsddt010 WHERE order_id = lv_order.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE  gt_out FROM ztdnsddt010 WHERE order_id = lv_order.
  IF sy-subrc EQ 0.
    DELETE gt_out[] WHERE belnr IS NOT INITIAL.
    IF gt_out[] IS INITIAL.
      gv_status = 'S'.
    ELSE.
      gv_status = 'E'.
      gt_out-flag = 'X'.
      MODIFY gt_out TRANSPORTING flag
                    WHERE flag = space.
      PERFORM f_posting_document_fi CHANGING gv_status lv_belnr.
      IF gv_status IS NOT INITIAL.
        LOOP AT gt_outlog ASSIGNING <fs_out>.
          CONCATENATE  <fs_out>-vcrno <fs_out>-vcr_encrp <fs_out>-matnr   INTO gv_message SEPARATED BY '|'.
          gv_status = 'E'.
        ENDLOOP.
        LOOP AT gt_error ASSIGNING <fs_err>.
          gv_message = <fs_err>-message.
        ENDLOOP.
      ELSE.
        gv_status = 'S'.
      ENDIF.
    ENDIF.
  ELSE.
    gv_status = 'E'.
    CONCATENATE lv_order 'tidak ada di SAP' INTO gv_message.
  ENDIF.
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
    PERFORM f_post_data_json(ztdsit_i001) USING lv_json p_proses sy-subrc lv_str.
    REPLACE ALL OCCURRENCES OF '{' IN lv_str WITH '' .
    REPLACE ALL OCCURRENCES OF '}' IN lv_str WITH '' .
    REPLACE ALL OCCURRENCES OF '"' IN lv_str WITH '' .
    "    REPLACE ALL OCCURRENCES OF ' ' IN lv_str WITH '' .
    gv_message = lv_str.
  ENDIF.
  status = gv_status.
  message = gv_message.
ENDFUNCTION.
