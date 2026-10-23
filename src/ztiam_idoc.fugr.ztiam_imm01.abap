FUNCTION ztiam_imm01.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(ZBANFN) TYPE  BANFN
*"  EXPORTING
*"     VALUE(BANFN) TYPE  BANFN
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
  DATA: p_proses(15) VALUE 'TIAM_PRCREATE'.
  DATA : gt_response_body     TYPE TABLE OF text WITH HEADER LINE.
  DATA: lv_str TYPE string.
  DATA: lv_banfn TYPE banfn.
  DATA: p_return(1).
  DATA: lv_status(1), lv_message(100).
  DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
        lv_json             TYPE string.
  DATA: ls_eban TYPE t_pr.
  DATA: ls_ztiammmdt001 TYPE ztiammmdt001.
  DATA: lv_name(15).

  p_proses =  'TIAM_PRCREATE'.
  lv_banfn = zbanfn.
  CLEAR: p_return.
  SELECT SINGLE banfn INTO lv_banfn FROM eban WHERE banfn = lv_banfn.
  IF sy-subrc EQ 0.
    PERFORM p_post_prtiam USING lv_banfn 'S' CHANGING lv_str.
    lv_message = lv_str.
    SELECT SINGLE * INTO ls_ztiammmdt001 FROM ztiammmdt001 WHERE zbanfn = lv_banfn AND banpr EQ space.
    IF sy-subrc EQ 0.
      ls_ztiammmdt001-banpr = lv_banfn.
      ls_ztiammmdt001-status = 'S'.
      ls_ztiammmdt001-aedat = sy-datum.
      ls_ztiammmdt001-arzet = sy-uzeit.
      ls_ztiammmdt001-aenam = sy-uname.
      MODIFY ztiammmdt001 FROM ls_ztiammmdt001.
    ENDIF.
    p_return = 0.
  ELSE.
    CONCATENATE '{ "BANFN": "' lv_banfn '" } ' INTO gt_response_body-line.
    APPEND gt_response_body.
    PERFORM f_get_data_json_json(ztdsit_i001) TABLES   gt_response_body
                                           USING    p_proses
                                           CHANGING lv_str sy-subrc.
    IF lv_str IS NOT INITIAL.
      PERFORM f_convert_json_prtiam USING lv_str CHANGING gs_eban.
      IF gs_eban-result[] IS NOT INITIAL.
        lv_name = lv_banfn.
        PERFORM f_create_text_json(ztdsit_i001) USING lv_str lv_name '/inbound/tiam/' p_proses.
        PERFORM f_proses_pr USING gs_eban CHANGING p_return lv_message.
      ELSE.
        p_return = 4.
        lv_message = 'No data'.
      ENDIF.
    ELSE.
      p_return = 4.
      lv_message = 'No data'.
    ENDIF.
  ENDIF.
  IF p_return  = 0.
    status = 'S'.
  ELSE.
    status = 'E'.
  ENDIF.
  banfn = zbanfn.
  message = lv_message.
ENDFUNCTION.
