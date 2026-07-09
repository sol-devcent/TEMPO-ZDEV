FUNCTION ztdsfi_f0001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(PROSES) TYPE  CHAR15 DEFAULT 'TREX_SPLITDN'
*"     REFERENCE(NO_GS) TYPE  ZGSNO
*"  EXPORTING
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
  DATA: p_proses(15) VALUE 'TREX_SPLITDN'.
  DATA : gt_response_body     TYPE TABLE OF text WITH HEADER LINE.
  DATA: lv_str TYPE string.
  DATA: lv_nogs TYPE zgsno.
  DATA: p_return(1).
  DATA: lv_status(1), lv_message(100).
  "gv_err TYPE sysubrc.
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        lv_json             TYPE string.
  p_proses =  'TREX_SPLITDN'.
  lv_nogs = no_gs.
  PERFORM f_getdata_splitdn USING lv_nogs p_proses CHANGING lv_str.
  IF lv_str IS NOT INITIAL.
    PERFORM f_convert_json_splitdn USING lv_str CHANGING lv_status lv_message. " CHANGING gt_dn_split.
    status = lv_status.
    message = lv_message.
  ELSE.
    status = 'E'.
    message = 'No Data'.
  ENDIF.

ENDFUNCTION.
