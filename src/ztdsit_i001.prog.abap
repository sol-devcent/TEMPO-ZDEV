*&---------------------------------------------------------------------*
REPORT    ztdsit_i001.
*&---------------------------------------------------------------------*
TABLES: ztdsitdt001.
*&---------------------------------------------------------------------*
*&      Form  f_get_data_json
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PROSES   text
*      -->P_XML      text
*----------------------------------------------------------------------*
FORM f_get_data_json_nobody USING  p_proses TYPE char10
                     CHANGING p_xml TYPE xstring
                              p_return.
  TYPES: BEGIN OF text,
*        line(5000),
           line(4045),
         END OF text.

  DATA: ls_ztdsitdt001  LIKE ztdsitdt001.
  DATA: lv_status_code(10), "   TYPE C ,
        lv_status_text(100), "   TYPE C ,
        lv_response_entity_body_length TYPE i,
        lv_request_entity_body_length  TYPE i, "(80). " = 'Check type of data required'.

        lt_request_entity_body         TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_entity_body	       TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_headers	           TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_body               TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_request_headers             TYPE TABLE OF text WITH HEADER LINE. "TYPE STANDARD TABLE OF string,"TABLES PARAM

  DATA writer TYPE REF TO cl_sxml_string_writer.
  DATA temp_json TYPE string.
  DATA : g_str        TYPE string.
  DATA: gs_rif_ex   TYPE REF TO cx_root,
        ls_var_text TYPE string.
  p_return = 4.
  SELECT SINGLE * INTO ls_ztdsitdt001 FROM ztdsitdt001
    WHERE zproses = p_proses.
  IF sy-subrc EQ 0.
    p_return = 0.
    CONDENSE: ls_ztdsitdt001-phead, ls_ztdsitdt001-urlget, ls_ztdsitdt001-rfcdest, ls_ztdsitdt001-urlpos.
    IF ls_ztdsitdt001-phead IS NOT INITIAL.
      lt_request_headers = ls_ztdsitdt001-phead.
      APPEND  lt_request_headers.
    ENDIF.
    lt_request_headers = 'Content-Type:application/json'.
    APPEND lt_request_headers.
    lv_request_entity_body_length = 0.
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
        response_entity_body        = lt_response_entity_body
        response_headers            = lt_response_headers
        request_headers             = lt_request_headers.
    IF sy-subrc EQ 0.
      LOOP AT lt_response_entity_body INTO temp_json.
        CONDENSE: temp_json, g_str.
        CONCATENATE g_str temp_json INTO g_str. "loc_tempjson-json.
      ENDLOOP.
      REPLACE ALL OCCURRENCES OF REGEX 'null' IN g_str WITH '"  "'.
      writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_xml10 ). "co_xt_json ).
      TRY.
          CALL TRANSFORMATION id SOURCE XML g_str "loc_tempjson-json
                                 RESULT XML writer.
          p_xml = writer->get_output( ).
        CATCH cx_root INTO gs_rif_ex.
          ls_var_text = gs_rif_ex->get_text( ).
          p_return = 1.
          "          WRITE: / 'Message Error JSON to XML: ', ls_var_text.
      ENDTRY.
    ELSE.
      "      WRITE: / 'Error HTTP GET : ', sy-subrc.
      p_return = 2.
    ENDIF.
  ELSE.
    p_return = 3.
  ENDIF.
  IF p_xml IS INITIAL.
    p_return = 5.
  ENDIF.
ENDFORM.                    "f_get_data_json

*&---------------------------------------------------------------------*
*&      Form  f_get_data_json
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PROSES   text
*      -->P_XML      text
*----------------------------------------------------------------------*
FORM f_get_data_json TABLES p_request_body TYPE STANDARD TABLE
                     USING  p_proses TYPE char15
                     CHANGING p_xml TYPE xstring.
  TYPES: BEGIN OF text,
*           line(5000),
           line(4045),
         END OF text.

  DATA: ls_ztdsitdt001  LIKE ztdsitdt001.
  DATA: lv_status_code(10), "   TYPE C ,
        lv_status_text(100), "   TYPE C ,
        lv_response_entity_body_length TYPE i,
        lv_request_entity_body_length  TYPE i, "(80). " = 'Check type of data required'.

        lt_request_entity_body         TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_entity_body	       TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_headers	           TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_body               TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_request_headers             TYPE TABLE OF text WITH HEADER LINE. "TYPE STANDARD TABLE OF string,"TABLES PARAM

  DATA writer TYPE REF TO cl_sxml_string_writer.
  DATA temp_json TYPE string.
  DATA : g_str        TYPE string.
  DATA: gs_rif_ex   TYPE REF TO cx_root,
        ls_var_text TYPE string.

  SELECT SINGLE * INTO ls_ztdsitdt001 FROM ztdsitdt001
    WHERE zproses = p_proses.
  IF sy-subrc EQ 0.
    CONDENSE: ls_ztdsitdt001-phead, ls_ztdsitdt001-urlget, ls_ztdsitdt001-rfcdest, ls_ztdsitdt001-urlpos.
    IF ls_ztdsitdt001-phead IS NOT INITIAL.
      lt_request_headers = ls_ztdsitdt001-phead.
      APPEND  lt_request_headers.
    ENDIF.
    lt_request_headers = 'Content-Type:application/json'.
    APPEND lt_request_headers.
    lv_request_entity_body_length = 0.
    lt_request_entity_body[] = p_request_body[].

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
        response_entity_body        = lt_response_entity_body
        request_entity_body         = lt_request_entity_body
        response_headers            = lt_response_headers
        request_headers             = lt_request_headers.
    IF sy-subrc EQ 0.
      LOOP AT lt_response_entity_body INTO temp_json.
        CONDENSE: temp_json, g_str.
        CONCATENATE g_str temp_json INTO g_str. "loc_tempjson-json.
      ENDLOOP.
      REPLACE ALL OCCURRENCES OF REGEX 'null' IN g_str WITH '"  "'.
      REPLACE ALL OCCURRENCES OF REGEX '#' IN g_str WITH '"  "'.

      writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_xml10 ). "co_xt_json ).
      TRY.
          CALL TRANSFORMATION id SOURCE XML g_str "loc_tempjson-json
                                 RESULT XML writer.
          p_xml = writer->get_output( ).
        CATCH cx_root INTO gs_rif_ex.
          ls_var_text = gs_rif_ex->get_text( ).
          "          WRITE: / 'Message Error JSON to XML: ', ls_var_text.
      ENDTRY.
    ELSE.
      IF  ( sy-uname NE 'ALEREMOTE' AND sy-uname NE 'TDS_DEV01' ).
        "    WRITE: / 'Error HTTP GET : ', sy-subrc.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_get_data_json

*&---------------------------------------------------------------------*
*&      Form  f_get_data_json
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PROSES   text
*      -->P_XML      text
*----------------------------------------------------------------------*
FORM f_get_data_json_params USING  p_proses TYPE char15
                                 p_params TYPE char50
                     CHANGING p_str TYPE string
                              p_return.
  TYPES: BEGIN OF text,
*           line(5000),
           line(4045),
         END OF text.

  DATA: ls_ztdsitdt001  LIKE ztdsitdt001.
  DATA: lv_status_code(10), "   TYPE C ,
        lv_status_text(100), "   TYPE C ,
        lv_response_entity_body_length TYPE i,
        lv_request_entity_body_length  TYPE i, "(80). " = 'Check type of data required'.

        lt_request_entity_body         TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_entity_body	       TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_headers	           TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_body               TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_request_headers             TYPE TABLE OF text WITH HEADER LINE. "TYPE STANDARD TABLE OF string,"TABLES PARAM
  "  DATA writer TYPE REF TO cl_sxml_string_writer.
  DATA temp_json TYPE string.
  CLEAR: p_str.
  SELECT SINGLE * INTO ls_ztdsitdt001 FROM ztdsitdt001
    WHERE zproses = p_proses.
  IF sy-subrc EQ 0.
    CONDENSE: ls_ztdsitdt001-phead, ls_ztdsitdt001-urlget, ls_ztdsitdt001-rfcdest, ls_ztdsitdt001-urlpos.
    IF ls_ztdsitdt001-phead IS NOT INITIAL.
      lt_request_headers = ls_ztdsitdt001-phead.
      APPEND  lt_request_headers.
    ENDIF.
    IF p_proses(3) = 'ODO'.
      lt_request_headers = 'Content-Type:'.
    ELSE.
      lt_request_headers = 'Content-Type:application/json'.
    ENDIF.
    APPEND  lt_request_headers.
**    APPEND lt_request_headers.
    lv_request_entity_body_length = 0.
    "    lt_request_entity_body[] = p_request_body[].
    CONDENSE: p_params.
    IF p_params IS NOT INITIAL.
      CONDENSE ls_ztdsitdt001-urlget.
      CONCATENATE ls_ztdsitdt001-urlget p_params INTO ls_ztdsitdt001-urlget.
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
        response_entity_body        = lt_response_entity_body
        request_entity_body         = lt_request_entity_body
        response_headers            = lt_response_headers
        request_headers             = lt_request_headers.
    p_return = sy-subrc.
    IF sy-subrc EQ 0.
      LOOP AT lt_response_entity_body INTO temp_json.
        CONDENSE: temp_json, p_str.
        CONCATENATE p_str temp_json INTO p_str. "loc_tempjson-json.
      ENDLOOP.
      "REPLACE ALL OCCURRENCES OF REGEX 'null' IN p_str WITH ' '.
    ELSE.
      CONCATENATE '{ "Error" : " ' p_return '" }' INTO p_str.
      "     WRITE: / 'Error HTTP GET : ', sy-subrc.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_get_data_json

*&---------------------------------------------------------------------*
*&      Form  f_get_data_json
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PROSES   text
*      -->P_XML      text
*----------------------------------------------------------------------*
FORM f_get_data_json_json TABLES p_request_body TYPE STANDARD TABLE
                     USING  p_proses TYPE char15
                     CHANGING p_str TYPE string
                              p_return.
  TYPES: BEGIN OF text,
*           line(5000),
           line(4045),
         END OF text.

  DATA: ls_ztdsitdt001  LIKE ztdsitdt001.
  DATA: lv_status_code(10), "   TYPE C ,
        lv_status_text(100), "   TYPE C ,
        lv_response_entity_body_length TYPE i,
        lv_request_entity_body_length  TYPE i, "(80). " = 'Check type of data required'.

        lt_request_entity_body         TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_entity_body	       TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_headers	           TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_body               TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_request_headers             TYPE TABLE OF text WITH HEADER LINE. "TYPE STANDARD TABLE OF string,"TABLES PARAM

  "  DATA writer TYPE REF TO cl_sxml_string_writer.
  DATA temp_json TYPE string.
  CLEAR: p_str.
  SELECT SINGLE * INTO ls_ztdsitdt001 FROM ztdsitdt001
    WHERE zproses = p_proses.
  IF sy-subrc EQ 0.
    CONDENSE: ls_ztdsitdt001-phead, ls_ztdsitdt001-urlget, ls_ztdsitdt001-rfcdest, ls_ztdsitdt001-urlpos.
    IF ls_ztdsitdt001-phead IS NOT INITIAL.
      lt_request_headers = ls_ztdsitdt001-phead.
      APPEND  lt_request_headers.
    ENDIF.
    lt_request_headers = 'Content-Type:application/json'.
    APPEND lt_request_headers.
    lv_request_entity_body_length = 0.
    lt_request_entity_body[] = p_request_body[].

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
        response_entity_body        = lt_response_entity_body
        request_entity_body         = lt_request_entity_body
        response_headers            = lt_response_headers
        request_headers             = lt_request_headers.
    p_return = sy-subrc.
    IF sy-subrc EQ 0.
      LOOP AT lt_response_entity_body INTO temp_json.
        CONDENSE: temp_json, p_str.
        CONCATENATE p_str temp_json INTO p_str. "loc_tempjson-json.
      ENDLOOP.
      "REPLACE ALL OCCURRENCES OF REGEX 'null' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '&' IN p_str WITH ' ' .
**        REPLACE ALL OCCURRENCES OF '\' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '/' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '''' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '"' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '>' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '<' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '.' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '`' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '~' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '@' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '#' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '$' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '%' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '^' IN p_str WITH ' '.
**        REPLACE ALL OCCURRENCES OF '*' IN p_str WITH ' '.

    ELSE.
      CONCATENATE '{ "Error" : " ' p_return '" }' INTO p_str.
      "     WRITE: / 'Error HTTP GET : ', sy-subrc.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_get_data_json

*&---------------------------------------------------------------------*
*&      Form  f_post_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_REQUEST_BODY  text
*      -->P_PROSES        text
*----------------------------------------------------------------------*
FORM f_post_data TABLES  p_request_body TYPE STANDARD TABLE
  USING  p_proses TYPE char15.

  TYPES: BEGIN OF text,
*           line(5000),
           line(4045),
         END OF text.
  DATA: ls_ztdsitdt001  LIKE ztdsitdt001.
  DATA: lv_status_code(10), "   TYPE C ,
        lv_status_text(100), "   TYPE C ,
        lv_response_entity_body_length TYPE i,
        lv_request_entity_body_length  TYPE i, "(80). " = 'Check type of data required'.

        lt_request_entity_body         TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_entity_body	       TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_headers	           TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_body               TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_request_headers             TYPE TABLE OF text WITH HEADER LINE. "TYPE STANDARD TABLE OF string,"TABLES PARAM
  DATA: ls_ztdsitdt004 TYPE ztdsitdt004,
        lt_ztdsitdt004 TYPE STANDARD TABLE OF ztdsitdt004.

  SELECT SINGLE * INTO ls_ztdsitdt001 FROM ztdsitdt001
    WHERE zproses = p_proses.
  IF sy-subrc EQ 0.
    REFRESH: lt_request_entity_body, lt_response_entity_body, lt_response_headers, lt_request_headers.
    lt_request_headers-line = ls_ztdsitdt001-phead. "'Authorization:21eb1a9d57028adc26a2faae7b512b1b'.
    APPEND lt_request_headers.
    lt_request_headers-line = 'Content-Type: application/json'.
    APPEND lt_request_headers.
    lt_request_entity_body[] = p_request_body[].
    CALL FUNCTION 'HTTP_POST'
      EXPORTING
        absolute_uri                = ls_ztdsitdt001-urlpos "p_url1
        request_entity_body_length  = 0 "ld_request_entity_body_length
        blankstocrlf                = 'X'
      IMPORTING
        status_code                 = lv_status_code
        status_text                 = lv_status_text
        response_entity_body_length = lv_response_entity_body_length
      TABLES
        request_entity_body         = lt_request_entity_body
        response_entity_body        = lt_response_entity_body
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
    IF sy-subrc NE 0.
      "  WRITE: / 'Http Post gagal update, Errorcode : ', sy-subrc.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_post_data

*&---------------------------------------------------------------------*
*&      Form  f_post_data_json
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_REQUEST_BODY  text
*      -->P_PROSES        text
*----------------------------------------------------------------------*
FORM f_post_data_json USING p_json TYPE string
                            p_proses TYPE char15
                    CHANGING p_return
                             p_str TYPE string.
  TYPES: BEGIN OF text,
*           line(5000),
           line(4045),
         END OF text.
  DATA: p_err TYPE sysubrc.
  DATA: lv_status_code(10), "   TYPE C ,
        lv_status_text(100), "   TYPE C ,
        lv_response_entity_body_length TYPE i,
        lv_request_entity_body_length  TYPE i. "(80). " = 'Check type of data required'.
  DATA: ls_ztdsitdt001  LIKE ztdsitdt001.
  DATA: lt_request_body     TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_body    TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_headers	TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_request_headers  TYPE TABLE OF text WITH HEADER LINE. "TYPE STANDARD TABLE OF string,"TABLES PARAM

  DATA: p_url TYPE zurl100.
  DATA temp_json TYPE string.
  DATA: l_len TYPE i, l_ctr TYPE i.
  DATA: ls_ztdsitdt004 TYPE ztdsitdt004,
        lt_ztdsitdt004 TYPE STANDARD TABLE OF ztdsitdt004.

  CLEAR: temp_json, lt_request_body[], lt_response_body[], lt_request_headers[], lt_response_headers[], l_len, l_ctr, p_url.
  temp_json = p_json.
  l_len = strlen( p_json ).

**  CALL FUNCTION 'SCMS_STRING_TO_FTEXT'
**    EXPORTING
**      text      = temp_json
***        IMPORTING
***     length    = wa_comp-comp_size
**    TABLES
**      ftext_tab = lt_request_body
**    EXCEPTIONS
**      OTHERS    = 99.

  DO 7500000 TIMES.
    FIND '",' IN temp_json MATCH OFFSET l_ctr.
    IF sy-subrc NE 0.
      FIND '"},' IN temp_json MATCH OFFSET l_ctr.
    ENDIF.
    IF sy-subrc EQ 0.
      l_ctr = l_ctr + 2 .
      IF l_ctr > l_len.
        l_ctr = l_len.
      ENDIF.
      lt_request_body-line = temp_json(l_ctr). "(500).

      REPLACE ALL OCCURRENCES OF '\&' IN lt_request_body-line WITH space.

      CONDENSE: lt_request_body-line.
      APPEND lt_request_body.
      IF l_ctr > l_len.
        l_len = l_ctr.
        l_ctr = 1000.
      ELSE.
        l_len = l_len - l_ctr.
      ENDIF.
      temp_json = temp_json+l_ctr(l_len).
    ELSE.
      IF temp_json IS INITIAL.
      ELSE.
        lt_request_body-line = temp_json(l_len). "(500).
        CONDENSE: lt_request_body-line.
        APPEND lt_request_body.
      ENDIF.
      EXIT.
    ENDIF.
  ENDDO.

  SELECT SINGLE * INTO ls_ztdsitdt001 FROM ztdsitdt001
    WHERE zproses = p_proses.
  IF sy-subrc EQ 0.
    IF ls_ztdsitdt001-phead IS NOT INITIAL.
      lt_request_headers-line = ls_ztdsitdt001-phead. "'Authorization:21eb1a9d57028adc26a2faae7b512b1b'.
      APPEND lt_request_headers.
    ENDIF.
**    IF p_proses(4) eq 'ODOO'.
**      lt_request_headers-line = 'Content-Type:'.
**    ELSE.
    lt_request_headers-line = 'Content-Type: application/json'.
    APPEND lt_request_headers.
**    ENDIF.
  ENDIF.

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
  p_return = sy-subrc.
  p_err = sy-subrc.
  IF p_err NE 0.
    CLEAR: p_str.
    LOOP AT lt_response_body.
      CONDENSE: lt_response_body-line.
      CONCATENATE p_str lt_response_body-line INTO p_str.
    ENDLOOP.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZHTTPNO'
      IMPORTING
        number      = ls_ztdsitdt004-zhttpno.
    ls_ztdsitdt004-zproses = p_proses.
    ls_ztdsitdt004-bodyjson = p_json.
    ls_ztdsitdt004-urlget = ls_ztdsitdt001-urlpos.
    ls_ztdsitdt004-status_code = lv_status_code.
    ls_ztdsitdt004-status_text = lv_status_text.
    ls_ztdsitdt004-return_code = p_err. "sy-subrc.
    ls_ztdsitdt004-zmess = p_str.
    ls_ztdsitdt004-erdat = sy-datum.
    ls_ztdsitdt004-ernam = sy-uname.
    ls_ztdsitdt004-erzet = sy-uzeit.
    MODIFY ztdsitdt004 FROM ls_ztdsitdt004.
    "    WRITE: / 'Http Post gagal update, Errorcode : ', sy-subrc.
  ELSE.
    CLEAR: p_str.
    LOOP AT lt_response_body.
      CONDENSE: lt_response_body-line.
      CONCATENATE p_str lt_response_body-line INTO p_str.
    ENDLOOP.
  ENDIF.
  FIND 'error' IN p_str.
  IF sy-subrc EQ 0. " AND p_proses(3) NE 'TDN'.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZHTTPNO'
      IMPORTING
        number      = ls_ztdsitdt004-zhttpno.
    ls_ztdsitdt004-zproses = p_proses.
    ls_ztdsitdt004-bodyjson = p_json.
    ls_ztdsitdt004-urlget = ls_ztdsitdt001-urlpos.
    ls_ztdsitdt004-status_code = lv_status_code.
    ls_ztdsitdt004-status_text = lv_status_text.
    ls_ztdsitdt004-return_code = p_return. "sy-subrc.
    ls_ztdsitdt004-zmess = p_str.
    ls_ztdsitdt004-erdat = sy-datum.
    ls_ztdsitdt004-ernam = sy-uname.
    ls_ztdsitdt004-erzet = sy-uzeit.
    MODIFY ztdsitdt004 FROM ls_ztdsitdt004.
  ENDIF.
ENDFORM.                    "f_post_data_json

FORM f_post_token USING p_json TYPE string
                            p_proses TYPE char15
                    CHANGING p_return
                             p_token TYPE string.


  TYPES: BEGIN OF text,
*           line(5000),
           line(4045),
         END OF text.
  DATA: p_err TYPE sysubrc.
  DATA: lv_status_code(10), "   TYPE C ,
        lv_status_text(100), "   TYPE C ,
        lv_response_entity_body_length TYPE i,
        lv_request_entity_body_length  TYPE i. "(80). " = 'Check type of data required'.
  DATA: ls_ztdsitdt001  LIKE ztdsitdt001.
  DATA: lt_request_body     TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_body    TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_headers	TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_request_headers  TYPE TABLE OF text WITH HEADER LINE. "TYPE STANDARD TABLE OF string,"TABLES PARAM
  DATA : cl_json_data TYPE REF TO zcl_trex_json_serializer.

  DATA: p_url TYPE zurl100.
  DATA temp_json TYPE string.
  DATA: l_len TYPE i, l_ctr TYPE i.
  DATA: ls_ztdsitdt004 TYPE ztdsitdt004,
        lt_ztdsitdt004 TYPE STANDARD TABLE OF ztdsitdt004.

  CLEAR: temp_json, lt_request_body[], lt_response_body[], lt_request_headers[], lt_response_headers[], l_len, l_ctr, p_url.
  temp_json = p_json.
  l_len = strlen( p_json ).

  DO 7500000 TIMES.
    FIND '",' IN temp_json MATCH OFFSET l_ctr.
    IF sy-subrc NE 0.
      FIND '"},' IN temp_json MATCH OFFSET l_ctr.
    ENDIF.
    IF sy-subrc EQ 0.
      l_ctr = l_ctr + 2 .
      IF l_ctr > l_len.
        l_ctr = l_len.
      ENDIF.
      lt_request_body-line = temp_json(l_ctr). "(500).

      REPLACE ALL OCCURRENCES OF '\&' IN lt_request_body-line WITH space.

      CONDENSE: lt_request_body-line.
      APPEND lt_request_body.
      IF l_ctr > l_len.
        l_len = l_ctr.
        l_ctr = 1000.
      ELSE.
        l_len = l_len - l_ctr.
      ENDIF.
      temp_json = temp_json+l_ctr(l_len).
    ELSE.
      IF temp_json IS INITIAL.
      ELSE.
        lt_request_body-line = temp_json(l_len). "(500).
        CONDENSE: lt_request_body-line.
        APPEND lt_request_body.
      ENDIF.
      EXIT.
    ENDIF.
  ENDDO.

  SELECT SINGLE * INTO ls_ztdsitdt001 FROM ztdsitdt001
    WHERE zproses = p_proses.
  IF sy-subrc EQ 0.
    IF ls_ztdsitdt001-phead IS NOT INITIAL.
      lt_request_headers-line = ls_ztdsitdt001-phead. "'Authorization:21eb1a9d57028adc26a2faae7b512b1b'.
      APPEND lt_request_headers.
    ENDIF.
**    IF p_proses(4) eq 'ODOO'.
**      lt_request_headers-line = 'Content-Type:'.
**    ELSE.
    lt_request_headers-line = 'Content-Type: application/json'.
    APPEND lt_request_headers.
    lt_request_headers-line = 'Accept: application/json'.
    APPEND lt_request_headers.
**    ENDIF.
  ENDIF.

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
  p_return = sy-subrc.
  p_err = sy-subrc.
  CLEAR: temp_json.
  IF p_err NE 0.
    CLEAR: temp_json.
    LOOP AT lt_response_body.
      CONDENSE: lt_response_body-line.
      CONCATENATE temp_json lt_response_body-line INTO temp_json.
    ENDLOOP.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZHTTPNO'
      IMPORTING
        number      = ls_ztdsitdt004-zhttpno.
    ls_ztdsitdt004-zproses = p_proses.
    ls_ztdsitdt004-bodyjson = p_json.
    ls_ztdsitdt004-urlget = ls_ztdsitdt001-urlpos.
    ls_ztdsitdt004-status_code = lv_status_code.
    ls_ztdsitdt004-status_text = lv_status_text.
    ls_ztdsitdt004-return_code = p_err. "sy-subrc.
    ls_ztdsitdt004-zmess = temp_json.
    ls_ztdsitdt004-erdat = sy-datum.
    ls_ztdsitdt004-ernam = sy-uname.
    ls_ztdsitdt004-erzet = sy-uzeit.
    MODIFY ztdsitdt004 FROM ls_ztdsitdt004.
    "    WRITE: / 'Http Post gagal update, Errorcode : ', sy-subrc.
  ELSE.
    CLEAR: temp_json.
    LOOP AT lt_response_body.
      CONDENSE: lt_response_body-line.
      CONCATENATE temp_json lt_response_body-line INTO temp_json.
    ENDLOOP.

  ENDIF.
  FIND 'error' IN temp_json.
  IF sy-subrc EQ 0 AND p_proses(3) NE 'TDN'.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZHTTPNO'
      IMPORTING
        number      = ls_ztdsitdt004-zhttpno.
    ls_ztdsitdt004-zproses = p_proses.
    ls_ztdsitdt004-bodyjson = p_json.
    ls_ztdsitdt004-urlget = ls_ztdsitdt001-urlpos.
    ls_ztdsitdt004-status_code = lv_status_code.
    ls_ztdsitdt004-status_text = lv_status_text.
    ls_ztdsitdt004-return_code = p_return. "sy-subrc.
    ls_ztdsitdt004-zmess = temp_json.
    ls_ztdsitdt004-erdat = sy-datum.
    ls_ztdsitdt004-ernam = sy-uname.
    ls_ztdsitdt004-erzet = sy-uzeit.
    MODIFY ztdsitdt004 FROM ls_ztdsitdt004.
  ENDIF.
  p_token = temp_json.
ENDFORM.                    "f_post_data_json

FORM f_post_data_with_token USING p_json TYPE string
                            p_proses TYPE char15
                            p_token TYPE string
                    CHANGING p_return
                             p_str TYPE string.
  TYPES: BEGIN OF text,
*           line(5000),
           line(4045),
         END OF text.
  DATA: p_err TYPE sysubrc.
  DATA: lv_status_code(10), "   TYPE C ,
        lv_status_text(100), "   TYPE C ,
        lv_response_entity_body_length TYPE i,
        lv_request_entity_body_length  TYPE i. "(80). " = 'Check type of data required'.
  DATA: ls_ztdsitdt001  LIKE ztdsitdt001.
  DATA: lt_request_body     TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_body    TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_headers	TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_request_headers  TYPE TABLE OF text WITH HEADER LINE. "TYPE STANDARD TABLE OF string,"TABLES PARAM

  DATA: p_url TYPE zurl100.
  DATA temp_json TYPE string.
  DATA: l_len TYPE i, l_ctr TYPE i.
  DATA: ls_ztdsitdt004 TYPE ztdsitdt004,
        lt_ztdsitdt004 TYPE STANDARD TABLE OF ztdsitdt004.

  CLEAR: temp_json, lt_request_body[], lt_response_body[], lt_request_headers[], lt_response_headers[], l_len, l_ctr, p_url.
  temp_json = p_json.
  l_len = strlen( p_json ).

  DO 7500000 TIMES.
    FIND '",' IN temp_json MATCH OFFSET l_ctr.
    IF sy-subrc NE 0.
      FIND '"},' IN temp_json MATCH OFFSET l_ctr.
    ENDIF.
    IF sy-subrc EQ 0.
      l_ctr = l_ctr + 2 .
      IF l_ctr > l_len.
        l_ctr = l_len.
      ENDIF.
      lt_request_body-line = temp_json(l_ctr). "(500).

      REPLACE ALL OCCURRENCES OF '\&' IN lt_request_body-line WITH space.

      CONDENSE: lt_request_body-line.
      APPEND lt_request_body.
      IF l_ctr > l_len.
        l_len = l_ctr.
        l_ctr = 1000.
      ELSE.
        l_len = l_len - l_ctr.
      ENDIF.
      temp_json = temp_json+l_ctr(l_len).
    ELSE.
      IF temp_json IS INITIAL.
      ELSE.
        lt_request_body-line = temp_json(l_len). "(500).
        CONDENSE: lt_request_body-line.
        APPEND lt_request_body.
      ENDIF.
      EXIT.
    ENDIF.
  ENDDO.

  SELECT SINGLE * INTO ls_ztdsitdt001 FROM ztdsitdt001
    WHERE zproses = p_proses.
  IF sy-subrc EQ 0.
    IF ls_ztdsitdt001-phead IS NOT INITIAL.
      lt_request_headers-line = ls_ztdsitdt001-phead. "'Authorization:21eb1a9d57028adc26a2faae7b512b1b'.
      APPEND lt_request_headers.
    ENDIF.
**    IF p_proses(4) eq 'ODOO'.
**      lt_request_headers-line = 'Content-Type:'.
**    ELSE.
    CONCATENATE 'Authorization:' p_token INTO lt_request_headers-line.
    APPEND lt_request_headers.
    lt_request_headers-line = 'Content-Type: application/json'.
    APPEND lt_request_headers.
**    ENDIF.
  ENDIF.

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
  p_return = sy-subrc.
  p_err = sy-subrc.
  IF p_err NE 0.
    CLEAR: p_str.
    LOOP AT lt_response_body.
      CONDENSE: lt_response_body-line.
      CONCATENATE p_str lt_response_body-line INTO p_str.
    ENDLOOP.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZHTTPNO'
      IMPORTING
        number      = ls_ztdsitdt004-zhttpno.
    ls_ztdsitdt004-zproses = p_proses.
    ls_ztdsitdt004-bodyjson = p_json.
    ls_ztdsitdt004-urlget = ls_ztdsitdt001-urlpos.
    ls_ztdsitdt004-status_code = lv_status_code.
    ls_ztdsitdt004-status_text = lv_status_text.
    ls_ztdsitdt004-return_code = p_err. "sy-subrc.
    ls_ztdsitdt004-zmess = p_str.
    ls_ztdsitdt004-erdat = sy-datum.
    ls_ztdsitdt004-ernam = sy-uname.
    ls_ztdsitdt004-erzet = sy-uzeit.
    MODIFY ztdsitdt004 FROM ls_ztdsitdt004.
    "    WRITE: / 'Http Post gagal update, Errorcode : ', sy-subrc.
  ELSE.
    CLEAR: p_str.
    LOOP AT lt_response_body.
      CONDENSE: lt_response_body-line.
      CONCATENATE p_str lt_response_body-line INTO p_str.
    ENDLOOP.
  ENDIF.
  FIND 'error' IN p_str.
  IF sy-subrc EQ 0 AND p_proses(3) NE 'TDN'.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZHTTPNO'
      IMPORTING
        number      = ls_ztdsitdt004-zhttpno.
    ls_ztdsitdt004-zproses = p_proses.
    ls_ztdsitdt004-bodyjson = p_json.
    ls_ztdsitdt004-urlget = ls_ztdsitdt001-urlpos.
    ls_ztdsitdt004-status_code = lv_status_code.
    ls_ztdsitdt004-status_text = lv_status_text.
    ls_ztdsitdt004-return_code = p_return. "sy-subrc.
    ls_ztdsitdt004-zmess = p_str.
    ls_ztdsitdt004-erdat = sy-datum.
    ls_ztdsitdt004-ernam = sy-uname.
    ls_ztdsitdt004-erzet = sy-uzeit.
    MODIFY ztdsitdt004 FROM ls_ztdsitdt004.
  ENDIF.
ENDFORM.                    "f_post_data_json

FORM f_post_data_param_with_token USING p_json TYPE string
                            p_proses TYPE char15
                            p_token TYPE string
                            p_param type any
                    CHANGING p_return
                             p_str TYPE string.
  TYPES: BEGIN OF text,
*           line(5000),
           line(4045),
         END OF text.
  DATA: p_err TYPE sysubrc.
  DATA: lv_status_code(10), "   TYPE C ,
        lv_status_text(100), "   TYPE C ,
        lv_response_entity_body_length TYPE i,
        lv_request_entity_body_length  TYPE i. "(80). " = 'Check type of data required'.
  DATA: ls_ztdsitdt001  LIKE ztdsitdt001.
  DATA: lt_request_body     TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_body    TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_response_headers	TYPE TABLE OF text WITH HEADER LINE, "TYPE STANDARD TABLE OF string,"TABLES PARAM
        lt_request_headers  TYPE TABLE OF text WITH HEADER LINE. "TYPE STANDARD TABLE OF string,"TABLES PARAM
  data: lv_param(100).
  DATA: p_url TYPE zurl100.
  DATA temp_json TYPE string.
  DATA: l_len TYPE i, l_ctr TYPE i.
  DATA: ls_ztdsitdt004 TYPE ztdsitdt004,
        lt_ztdsitdt004 TYPE STANDARD TABLE OF ztdsitdt004.
  lv_param = p_param.
  CLEAR: temp_json, lt_request_body[], lt_response_body[], lt_request_headers[], lt_response_headers[], l_len, l_ctr, p_url.
  temp_json = p_json.
  l_len = strlen( p_json ).

  DO 7500000 TIMES.
    FIND '",' IN temp_json MATCH OFFSET l_ctr.
    IF sy-subrc NE 0.
      FIND '"},' IN temp_json MATCH OFFSET l_ctr.
    ENDIF.
    IF sy-subrc EQ 0.
      l_ctr = l_ctr + 2 .
      IF l_ctr > l_len.
        l_ctr = l_len.
      ENDIF.
      lt_request_body-line = temp_json(l_ctr). "(500).

      REPLACE ALL OCCURRENCES OF '\&' IN lt_request_body-line WITH space.

      CONDENSE: lt_request_body-line.
      APPEND lt_request_body.
      IF l_ctr > l_len.
        l_len = l_ctr.
        l_ctr = 1000.
      ELSE.
        l_len = l_len - l_ctr.
      ENDIF.
      temp_json = temp_json+l_ctr(l_len).
    ELSE.
      IF temp_json IS INITIAL.
      ELSE.
        lt_request_body-line = temp_json(l_len). "(500).
        CONDENSE: lt_request_body-line.
        APPEND lt_request_body.
      ENDIF.
      EXIT.
    ENDIF.
  ENDDO.

  SELECT SINGLE * INTO ls_ztdsitdt001 FROM ztdsitdt001
    WHERE zproses = p_proses.
  IF sy-subrc EQ 0.
    IF ls_ztdsitdt001-phead IS NOT INITIAL.
      lt_request_headers-line = ls_ztdsitdt001-phead. "'Authorization:21eb1a9d57028adc26a2faae7b512b1b'.
      APPEND lt_request_headers.
    ENDIF.
**    IF p_proses(4) eq 'ODOO'.
**      lt_request_headers-line = 'Content-Type:'.
**    ELSE.
    CONCATENATE 'Authorization:' p_token INTO lt_request_headers-line.
    APPEND lt_request_headers.
    lt_request_headers-line = 'Content-Type: application/json'.
    APPEND lt_request_headers.
**    ENDIF.
  ENDIF.
  CONDENSE: ls_ztdsitdt001-urlpos, lv_param.
  CONCATENATE ls_ztdsitdt001-urlpos '/' lv_param into ls_ztdsitdt001-urlpos.
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
  p_return = sy-subrc.
  p_err = sy-subrc.
  IF p_err NE 0.
    CLEAR: p_str.
    LOOP AT lt_response_body.
      CONDENSE: lt_response_body-line.
      CONCATENATE p_str lt_response_body-line INTO p_str.
    ENDLOOP.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZHTTPNO'
      IMPORTING
        number      = ls_ztdsitdt004-zhttpno.
    ls_ztdsitdt004-zproses = p_proses.
    ls_ztdsitdt004-bodyjson = p_json.
    ls_ztdsitdt004-urlget = ls_ztdsitdt001-urlpos.
    ls_ztdsitdt004-status_code = lv_status_code.
    ls_ztdsitdt004-status_text = lv_status_text.
    ls_ztdsitdt004-return_code = p_err. "sy-subrc.
    ls_ztdsitdt004-zmess = p_str.
    ls_ztdsitdt004-erdat = sy-datum.
    ls_ztdsitdt004-ernam = sy-uname.
    ls_ztdsitdt004-erzet = sy-uzeit.
    MODIFY ztdsitdt004 FROM ls_ztdsitdt004.
    "    WRITE: / 'Http Post gagal update, Errorcode : ', sy-subrc.
  ELSE.
    CLEAR: p_str.
    LOOP AT lt_response_body.
      CONDENSE: lt_response_body-line.
      CONCATENATE p_str lt_response_body-line INTO p_str.
    ENDLOOP.
  ENDIF.
  FIND 'error' IN p_str.
  IF sy-subrc EQ 0 AND p_proses(3) NE 'TDN'.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZHTTPNO'
      IMPORTING
        number      = ls_ztdsitdt004-zhttpno.
    ls_ztdsitdt004-zproses = p_proses.
    ls_ztdsitdt004-bodyjson = p_json.
    ls_ztdsitdt004-urlget = ls_ztdsitdt001-urlpos.
    ls_ztdsitdt004-status_code = lv_status_code.
    ls_ztdsitdt004-status_text = lv_status_text.
    ls_ztdsitdt004-return_code = p_return. "sy-subrc.
    ls_ztdsitdt004-zmess = p_str.
    ls_ztdsitdt004-erdat = sy-datum.
    ls_ztdsitdt004-ernam = sy-uname.
    ls_ztdsitdt004-erzet = sy-uzeit.
    MODIFY ztdsitdt004 FROM ls_ztdsitdt004.
  ENDIF.
ENDFORM.                    "f_post_data_json

*&---------------------------------------------------------------------*
*&      Form  f_create_text_json
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JSON     text
*      -->P_NAMA     text
*      -->P_PATH     text
*----------------------------------------------------------------------*
FORM f_create_text_json USING p_json TYPE string
                              p_nama TYPE char15
                              p_path  LIKE edi_path-pthnam
                              p_proses TYPE char15.

  DATA: BEGIN OF lt_request_body OCCURS 0,
*          line(3000), " TYPE string,
          line(4045),
        END OF  lt_request_body.

  DATA: ls_ztdsitdt001  LIKE ztdsitdt001.

  DATA: l_len TYPE i.
  DATA: json1             TYPE string.
  DATA:  gv_str TYPE string.
  DATA:        l_ctr TYPE i.

  SELECT SINGLE * INTO ls_ztdsitdt001 FROM ztdsitdt001
  WHERE zproses = p_proses.
  IF ls_ztdsitdt001-text IS NOT INITIAL.
    CLEAR: lt_request_body[].
    json1 = p_json.
    l_len = strlen( json1 ).
**    CALL FUNCTION 'SCMS_STRING_TO_FTEXT'
**      EXPORTING
**        text      = json1
***        IMPORTING
***       length    = wa_comp-comp_size
**      TABLES
**        ftext_tab = lt_request_body
**      EXCEPTIONS
**        OTHERS    = 99.
    DO 7500000 TIMES.
      FIND '",' IN json1 MATCH OFFSET l_ctr.
      IF sy-subrc NE 0.
        FIND '"},' IN json1 MATCH OFFSET l_ctr.
      ENDIF.
      IF sy-subrc EQ 0.
        l_ctr = l_ctr + 2 .
        IF l_ctr > l_len.
          l_ctr = l_len.
        ENDIF.
        lt_request_body-line = json1(l_ctr). "(500).
        CONDENSE: lt_request_body-line.
        APPEND lt_request_body.
        IF l_ctr > l_len.
          l_len = l_ctr.
          l_ctr = 1000.
        ELSE.
          l_len = l_len - l_ctr.
        ENDIF.
        json1 = json1+l_ctr(l_len).
      ELSE.
        IF json1 IS INITIAL.
        ELSE.
          lt_request_body-line = json1(l_len). "(500).
          CONDENSE: lt_request_body-line.
          APPEND lt_request_body.
        ENDIF.
        EXIT.
      ENDIF.
    ENDDO.
    DATA:    gv_fullfile  LIKE edi_path-pthnam.

    gv_fullfile = p_path.
    CONCATENATE gv_fullfile p_nama '.json' INTO gv_fullfile.
    OPEN DATASET gv_fullfile FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
    IF sy-subrc EQ 0.
      LOOP AT lt_request_body.
        gv_str = lt_request_body-line.
        TRANSFER  gv_str TO gv_fullfile.
      ENDLOOP.
      CLOSE DATASET gv_fullfile.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_create_text_json
