FUNCTION ztdsit_f0006.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_PROSES) TYPE  CHAR30
*"     VALUE(PI_JSONIN) TYPE  STRING
*"     VALUE(PI_TYPE) TYPE  CHAR10
*"     REFERENCE(PI_PARAM) TYPE  C OPTIONAL
*"  EXPORTING
*"     VALUE(PE_TYPE) TYPE  CHAR1
*"     VALUE(PE_MESSAGE) TYPE  BAPI_MSG
*"     VALUE(PE_JSONOUT) TYPE  STRING
*"----------------------------------------------------------------------
  TYPES: BEGIN OF text,
*           line(5000),
           line(4045),
         END OF text.
  DATA: lv_err TYPE sysubrc.
  DATA: lv_mode TYPE char10.
  DATA: lv_proses TYPE char15.
  DATA: lv_jsonin    TYPE string,
        lv_jsonout   TYPE string,
        lv_status(1),
        lv_message   TYPE bapi_msg.
  DATA: l_len TYPE i, l_ctr TYPE i.
  DATA: ls_ztdsitdt001 TYPE ztdsitdt001.
  DATA: lt_request_body     TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_body    TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_headers	TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_request_headers  TYPE TABLE OF text WITH HEADER LINE. "TYPE STANDARD TABLE OF string,"TABLES PARAM
  DATA: lv_status_code(10), "   TYPE C ,
        lv_status_text(100), "   TYPE C ,
        lv_response_entity_body_length TYPE i,
        lv_request_entity_body_length  TYPE i. "(80). " = 'Check type of data required'.
  DATA: lv_mess(100).
  DATA: lv_param(50).
  CLEAR: lv_jsonin, lv_jsonout, lv_status, lv_message,
         lt_request_body[], lt_response_body[], lt_request_headers[], lt_response_headers[],
         l_len, l_ctr, lv_err.

  lv_proses = pi_proses.
  TRANSLATE lv_proses TO UPPER CASE.
  SELECT SINGLE * INTO ls_ztdsitdt001 FROM ztdsitdt001
    WHERE zproses = lv_proses.
  IF sy-subrc EQ 0.
    IF ls_ztdsitdt001-phead IS NOT INITIAL.
      lt_request_headers-line = ls_ztdsitdt001-phead. "'Authorization:21eb1a9d57028adc26a2faae7b512b1b'.
      APPEND lt_request_headers.
    ENDIF.
    lt_request_headers-line = 'Content-Type: application/json'.
    APPEND lt_request_headers.
  ELSE.
    pe_type = 'E'.
    pe_message = 'Mohon setting URL di table ZTDSITDT001'.
    pe_jsonout = '{ "Message Error" : "Mohon setting URL di table ZTDSITDT001" }'.
    RETURN.
  ENDIF.

  lv_jsonin = pi_jsonin.
  l_len = strlen( lv_jsonin ).
  IF lv_jsonin IS NOT INITIAL.
    DO 7500000 TIMES.
      FIND '",' IN lv_jsonin MATCH OFFSET l_ctr.
      IF sy-subrc NE 0.
        FIND '"},' IN lv_jsonin MATCH OFFSET l_ctr.
      ENDIF.
      IF sy-subrc EQ 0.
        l_ctr = l_ctr + 2 .
        IF l_ctr > l_len.
          l_ctr = l_len.
        ENDIF.
        lt_request_body-line = lv_jsonin(l_ctr). "(500).

        REPLACE ALL OCCURRENCES OF '\&' IN lt_request_body-line WITH space.

        CONDENSE: lt_request_body-line.
        APPEND lt_request_body.
        IF l_ctr > l_len.
          l_len = l_ctr.
          l_ctr = 1000.
        ELSE.
          l_len = l_len - l_ctr.
        ENDIF.
        lv_jsonin = lv_jsonin+l_ctr(l_len).
      ELSE.
        IF lv_jsonin IS INITIAL.
        ELSE.
          lt_request_body-line = lv_jsonin(l_len). "(500).
          CONDENSE: lt_request_body-line.
          APPEND lt_request_body.
        ENDIF.
        EXIT.
      ENDIF.
    ENDDO.
  ENDIF.
  lv_mode = pi_type.
  TRANSLATE lv_mode TO UPPER CASE.
  CASE lv_mode.
    WHEN 'GET'.
      IF pi_param IS NOT INITIAL.
        lv_param = pi_param.
        CONDENSE: lv_param, ls_ztdsitdt001-urlget.
        CONCATENATE ls_ztdsitdt001-urlget '/' lv_param INTO ls_ztdsitdt001-urlget.
      ENDIF.
      CALL FUNCTION 'HTTP_GET'
        EXPORTING
          absolute_uri                = ls_ztdsitdt001-urlget "p_url "ld_absolute_uri
          request_entity_body_length  = 0 "lv_request_entity_body_length
          rfc_destination             = ls_ztdsitdt001-rfcdest "p_rfc
          blankstocrlf                = 'Y'
        IMPORTING
          status_code                 = lv_status_code    "timeout = '0'
          status_text                 = lv_status_text
          response_entity_body_length = lv_response_entity_body_length
        TABLES
          response_entity_body        = lt_response_body
          request_entity_body         = lt_request_body
          response_headers            = lt_response_headers
          request_headers             = lt_request_headers.
      lv_err = sy-subrc.
      CLEAR: lv_jsonout.

      IF sy-subrc EQ 0.
        LOOP AT lt_response_body.
          CONDENSE: lt_response_body-line.
          CONCATENATE lv_jsonout lt_response_body-line INTO lv_jsonout.
        ENDLOOP.
      ELSE.
      ENDIF.
      IF lv_status_code = '200'.
        pe_type = 'S'.
        pe_jsonout = lv_jsonout.
      ELSE.
        pe_type = 'E'.
        pe_message =  lv_jsonout.
      ENDIF.
    WHEN 'POST'.
      lv_response_entity_body_length = 3000.
      CALL FUNCTION 'HTTP_POST'
        EXPORTING
          absolute_uri                = ls_ztdsitdt001-urlpos
          request_entity_body_length  = 0 "ld_request_entity_body_length
          blankstocrlf                = 'X'
        IMPORTING
          status_code                 = lv_status_code
          status_text                 = lv_status_text
          response_entity_body_length = lv_response_entity_body_length
        TABLES
          request_entity_body         = lt_request_body
          response_entity_body        = lt_response_body
          response_headers            = lt_response_headers
          request_headers             = lt_request_headers
        EXCEPTIONS
          connect_failed              = 1
          timeout                     = 2
          internal_error              = 3
          tcpip_error                 = 4
          system_failure              = 5
          communication_failure       = 6
          OTHERS                      = 7.
      lv_err = sy-subrc.
      CLEAR: lv_jsonout.
      LOOP AT lt_response_body.
        CONDENSE: lt_response_body-line.
        CONCATENATE lv_jsonout lt_response_body-line INTO lv_jsonout.
      ENDLOOP.
      CONCATENATE 'Respon Status : '  lv_status_code INTO lv_mess.
      pe_message =  lv_mess.
      IF lv_status_code = '200'.
        pe_type = 'S'.
        pe_message =  pe_jsonout = lv_jsonout.
      ELSE.
        pe_type = 'E'.
        pe_jsonout = lv_jsonout.
      ENDIF.

    WHEN OTHERS.
      pe_type = 'E'.
      lv_mess = 'Gunakan Metod --> "POST" atau "GET" '.
      pe_message =  lv_mess.

  ENDCASE.
ENDFUNCTION.
